public with sharing class OppHistoryController{
	public List<Opportunity> oppHist = new List<Opportunity>();
	public integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	public Boolean hasOppHistory {get; private Set;}

	private String relId = '';
	private String leadRelType = '';
	private Boolean isConsIdSet = false;
    public ECCutil.consInfo ci {get; private set;}

	private Integer pageSize = 6;
	
	public List<Opportunity> getOppHist() {
		return oppHist;
	}
	
	public OppHistoryController() {
		init();
	}

	private void init() {
		currPage = 1;
		totalPages = 0;
		hasOppHistory = false;
		
		relId = System.currentPageReference().getParameters().get('id');
		leadRelType = System.currentPageReference().getParameters().get('leadRelType'); //coordinator or organizer
        system.debug(relId);

        ci = ECCUtil.getConsInfo(relId, leadRelType);
        
        system.debug('ci.consId: ' + ci.consId);
        if (ci.consId == null) {
        	isConsIdSet = false;
        }
		else {
			isConsIdSet = true;
			GetPage();
		}
	}

	public PageReference nextPage() {
		if (currPage < totalPages) {
			currPage++;
			GetPage();
		}
		return null;		
	}
	
	public PageReference prevPage() {
		if (currPage > 1) {
			currPage--;
			GetPage();
		}
		return null;
	}
	
	public void GetPage() {
		System.debug('GetPage()');
		System.debug('ci.consId: ' + ci.consId);
		System.debug('relId: ' + relId);
		
		LIST<Opportunity> allOppHist = [
			Select
				Id
				, Name
				, Stagename
				, RecordType.Name
				, CreatedDate
			from
				Opportunity
			where
				Event_Organizer__c in (
				select
					Id
				from
					Lead
				where
					(ConstituentID__c = :ci.consId
					or CoordinatorID__c = :ci.consId)
					//and Id <> :relId
				)
			order by
				CreatedDate desc];
		
		System.debug('items: ' + allOppHist.size());
		System.debug('totalPages: ' + totalPages);
		System.debug('pageSize: ' + pageSize);
		
		if (allOppHist.size() > 0) {
			hasOppHistory = true;
			totalPages =  integer.valueOf(string.valueOf(Math.ceil(double.valueOf(allOppHist.size()) / double.valueOf(pageSize))));
			
			System.debug('totalPages: ' + totalPages);

			Integer i;
			oppHist = new List<Opportunity>();
			for(i = (currPage - 1) * pageSize; i < currPage * pageSize && i < allOppHist.size(); i++) {
				System.debug(i);
				oppHist.add(allOppHist.get(i));
			}
			System.debug('GetPage() exit');
		}
	}
}