public with sharing class OIMProductSearchController {
	public String orderId { get; set; }
    public String eventId { get; set; }
    public String leadId { get; set; }
    public String leadType { get; set; }
	public String eventTypeId { get; set; }
	public String SKU { get; set; }
	public String description { get; set; }
	public String categoryId { get; set; }
	public String productId { get; set; }
	public String comments { get; set; }
	public Integer quantity { get; set; }
	public Boolean active { get; set; } 
	public Boolean resultsFound { get; set; }
	public List<V_ProductInfo__x> prods { get; set; }
	public ECCUtil.consInfo ci {get; private set;}
	public Integer each { get; set;}
	public Integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	private Integer pageSize = 10;
	public List<String> before = new List<String>();
    public List<String> after = new List<String>();
    public boolean bNew {get; private set;}

	public OIMProductSearchController() {
		init();
	}

	private void init() {
		orderId = System.currentPageReference().getParameters().get('orderId');
		eventId = System.currentPageReference().getParameters().get('eventId');
		leadId =  System.currentPageReference().getParameters().get('leadId');
		leadType =  System.currentPageReference().getParameters().get('leadType');
		System.debug('leadId = ' + leadId);
		System.debug('leadType = ' + leadType);
		if (String.isBlank(leadType)) leadType = 'ORG';
        ci = ECCUtil.getConsInfo(leadId, leadType);
        System.debug('ci.consId = ' +ci.consId);
		currPage = 0;
		totalPages = 0;
		active = true;
	}

	public Boolean getFirstPage() {
		return currPage == 1;
	}
	
	public Boolean getLastPage() {
		return currPage == totalPages;
	}

	public PageReference newSearch() {
		currPage = 1;
		totalPages = 0;

		return search();
	}

	public PageReference search() {
		//todo: make sure there's not already a line item for this product.
		String q = 'select EventTypeName__c, SKU__c, Description__c, Category__c, FulfilledBy__c, IsActive__c, ProductId__c, Each__c from V_ProductInfo__x';
		String w = ' where IsActive__c = ' + String.valueOf(active);
		String p = ' limit ' + pageSize + ' offset ' + ((currPage - 1) * pageSize);
		String o = ' order by EventTypeName__c, Description__c, SKU__c';

		if (String.isNotBlank(eventTypeId)) {
			w += ' and EventTypeID__c = \'' + eventTypeId + '\'';
		}
		if (String.isNotBlank(SKU)) {
			w += ' and SKU__c like \'%' + SKU + '%\'';
		}
		if (String.isNotBlank(description)) {
			w += ' and Description__c like \'%' + description + '%\'';
		}
		if (String.isNotBlank(categoryId)) {
			w += ' and CategoryID__c = \'' + categoryId + '\'';
		}

		q += w;
		q += o;
		q += p;


		system.debug('q: ' + q);

		if (totalPages == 0) {
			String qc = 'select count() from V_ProductInfo__x' + w;
			system.debug('qc: ' + qc);
			totalPages = OdataExtension.countByQuery(qc, null);
			if (totalPages > 0) {
				totalPages = Integer.valueOf(Math.ceil(Decimal.valueOf(totalPages) / Decimal.valueOf(pageSize)));
			}
		}

		prods = OdataExtension.V_ProductInfoQuery(q, null);

		system.debug('prods.size(): ' + prods.size());
		system.debug('totalPages: ' + totalPages);

		if (prods.size() > 0) {
			resultsFound = true;
		}
		else {
			resultsFound = false;
		}

		return null;
	}

	public PageReference selectProduct() {
		system.debug('productId: ' + productId);
		system.debug('quantity: ' + quantity);
		system.debug('comments: ' + comments);
		system.debug('each: ' + each);

		//CONMG-1189
		//Divide quantity by each (+1 if remainder)
		if (each != null && each > 1)
		{
			Integer remainder = math.mod(quantity,each);
			Double divisor = math.ceil(quantity/each);
			system.debug('remainder: ' + remainder);
			system.debug('divisor: ' + divisor);
			if (remainder > 0)
			{
				system.debug('incrementing quantity +1');
				divisor = divisor + 1;
			}

			system.debug('productId: ' + productId);
			quantity = (Integer)divisor;
		}

		LineItems__x li = new LineItems__x(
			OrderId__c = orderId
			, ProductId__c = productId
			, Quantity__c = quantity
			, Comments__c = comments
			, createdBy__c = UserInfo.getUserName()
			, modifiedBy__c = UserInfo.getUserName()
			, modified__c = DateTime.now()
			, created__c = DateTime.now()
		);

		System.debug(' AM I Saving here');
		OdataExtension.saveOIMLineItem(null, li);
		bNew = true;
		System.debug('ECCUtil.createTask ');
		listValuesForCompare(after);
		ECCUtil.createTask(ci, bNew ? 'LineItem Add' : 'Create', 'Completed', '', null , after); 
		//todo: add task to lead indicating addition of product
		//	before should be blank
		//  after should be line item details
		//         product, qty
		//  ECCUtil.CreateTask


		PageReference order = Page.OIMOrderDetail;
		order.setRedirect(true);
		order.getParameters().put('orderId', orderId);
		order.getParameters().put('eventId', eventId);
		order.getParameters().put('leadId', leadId);
		order.getParameters().put('leadType', leadType);
		return order;
	}
	
	public PageReference nextPage() {
		System.debug('nextPage');
		System.debug('currPage: ' + string.valueOf(currPage));

		currPage++;

		return search();
	}
	
	public PageReference prevPage() {
		System.debug('prevPage');
		System.debug('currPage: ' + string.valueOf(currPage));

		if (currPage > 1) {
			currPage--;
		}

		return search();
	}

	public List<SelectOption> getEventTypes() {
		List<SelectOption> so = new List<SelectOption>();
		List<EventTypes__x> ets = OdataExtension.GetAllECCRecruitedEventTypes();
		so.add(new SelectOption('', 'Select One'));
		if (ets != null && ets.size() > 0) {
			for(EventTypes__x et : ets) {
				so.add(new SelectOption(et.EventTypeID__c, et.EventTypeName__c));
			}
		}
		return so;
	}

	public List<SelectOption> getCategories() {
		List<SelectOption> so = new List<SelectOption>();
		List<LookupValues__x> stats = OdataExtension.LookupValuesByTopic('EventProductCategory', false, null);
		so.add(new SelectOption('', 'Select One'));
		if (stats != null && stats.size() > 0) {
			for(LookupValues__x stat : stats) {
				so.add(new SelectOption(stat.LookupValueId__c, stat.Display__c));
			}
		}
		return so;
	}

	public void listValuesForCompare(List<String> vals) {
		vals.add(String.format('{0} = {1}', new String[] {'ProductId', productId == null ? '' : productId}));
		vals.add(String.format('{0} = {1}', new String[] {'Quantity', String.valueOf(quantity)}));
		vals.add(String.format('{0} = {1}', new String[] {'OrderId', orderId == null ? '' : orderId}));
	}
}