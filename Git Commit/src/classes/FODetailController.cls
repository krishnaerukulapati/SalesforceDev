public with sharing class FODetailController {
	public domainSoapStjudeOrg.Constituent con {get; set;}
	public string relId {get; private set;}
	public string leadType {get; private set;}
    public boolean isUUIDSet {get; set;}
	private string name;
	public string contId {get; set;}
	private List<ConstituentInformation__c> consIds;
	public String consId {get; set;}
	public String consType {get; set;}
	public String isSF1 {get; set;}
	
	public FODetailController(ApexPages.StandardController controller) {
		init();
	}

	public FODetailController() {
		init();
	}

	private void init() {
		relId = System.currentPageReference().getParameters().get('id');
		leadType = System.currentPageReference().getParameters().get('leadType');
		if (String.isNotEmpty(System.currentPageReference().getParameters().get('SF1'))) {
            isSF1 = 'true';
        }
        else {
            isSF1 = 'false';
        }
		if (String.isBlank(leadType)) leadType = 'ORG';
        system.debug(relId);
        EVMUtil.consInfo ci = EVMUtil.getConsInfo(relId, leadType);
        system.debug(ci.consId);
        if (String.isEmpty(ci.consId)) {
        	isUUIDSet = false;
        }
		else {
			isUUIDSet = true;
			//consIds = FOUtil.getConstituentIds(currCase.ConstituentUUID__c);
			con = FOUtil.getConstituent(null, ci.consId, new string[] {'PROFILE', 'PREFERENCES'}, 'ALL');
			consId = con.ConstituentID;
			consType = con.Type_x.Code;
			
			consIds = EVMUtil.getConstituentInformationByConsInfo(ci);

			//get them from the constituent infos now - gonna write a wrapper in another util
			system.debug('FODetailController.FODetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
			//consId = consIds.get(0).ConstituentId__c;
		}
	}
	
	public void changeCons() {
		con = FOUtil.getConstituent(null, consId, new string[] {'PROFILE'}, consType);
	}
	
	public LIST<SelectOption> getItems() {
		return EVMUtil.getConstituentIdsForSelect(consIds);
	}
	
	public string getName() {
		return con.LastName + ', ' + con.FirstName;
	}
	
	public PageReference EditAddress() {
		PageReference edit = Page.FOConstituentAddressEdit; 
    	system.debug('contId: ' + contId);
    	edit.setRedirect(true);
    	edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
    	edit.getParameters().put('consId', consId);
    	edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	edit.getParameters().put('leadType', leadType);
    	if (String.isNotEmpty(isSF1)) edit.getParameters().put('SF1', isSF1);
    	return edit;
	}

	public PageReference NewAddress() {
		PageReference newItem = Page.FOConstituentAddressEdit; 
    	system.debug('id: ' + relId);
    	newItem.setRedirect(true);
    	newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	newItem.getParameters().put('consId', consId);
    	newItem.getParameters().put('leadType', leadType);
    	if (String.isNotEmpty(isSF1)) newItem.getParameters().put('SF1', isSF1);
    	return newItem;
	}

	public PageReference EditPhone() {
		PageReference edit = Page.FOConstituentPhoneEdit; 
    	system.debug('contId: ' + contId);
    	edit.setRedirect(true);
    	edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
    	edit.getParameters().put('consId', consId);
    	edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	edit.getParameters().put('leadType', leadType);
    	if (String.isNotEmpty(isSF1)) edit.getParameters().put('SF1', isSF1);
    	return edit;
	}

	public PageReference NewPhone() {
		PageReference newItem = Page.FOConstituentPhoneEdit; 
    	system.debug('id: ' + relId);
    	newItem.setRedirect(true);
    	newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	newItem.getParameters().put('consId', consId);
    	newItem.getParameters().put('leadType', leadType);
    	if (String.isNotEmpty(isSF1)) newItem.getParameters().put('SF1', isSF1);
    	return newItem;
	}

	public PageReference EditEmail() {
		PageReference edit = Page.FOConstituentEmailEdit; 
    	system.debug('contId: ' + contId);
    	system.debug('consId: ' + consId);
    	edit.setRedirect(true);
    	edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
    	edit.getParameters().put('consId', consId);
    	edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	edit.getParameters().put('leadType', leadType);
    	if (String.isNotEmpty(isSF1)) edit.getParameters().put('SF1', isSF1);
    	return edit;
	}

	public PageReference NewEmail() {
		PageReference newItem = Page.FOConstituentEmailEdit; 
    	system.debug('id: ' + relId);
    	newItem.setRedirect(true);
    	newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	newItem.getParameters().put('consId', consId);
    	newItem.getParameters().put('leadType', leadType);
    	if (String.isNotEmpty(isSF1)) newItem.getParameters().put('SF1', isSF1);
    	return newItem;
	}

	public PageReference EditPreference() {
		PageReference edit = Page.FOConstituentPreferenceEdit; 
    	system.debug('contId: ' + contId);
    	edit.setRedirect(true);
    	edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
    	edit.getParameters().put('consId', consId);
    	edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	edit.getParameters().put('leadType', leadType);
    	return edit;
	}

	public PageReference NewPreference() {
		PageReference newItem = Page.FOConstituentPreferenceEdit; 
    	system.debug('id: ' + relId);
    	newItem.setRedirect(true);
    	newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	newItem.getParameters().put('consId', consId);
    	newItem.getParameters().put('leadType', leadType);
    	return newItem;
	}

	public PageReference Back() {
		PageReference pr = new PageReference('/Apex/FOSearchMobile');
		pr.getParameters().put('cid', relId);

		return pr;
	}
}