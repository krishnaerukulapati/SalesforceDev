public with sharing class FOCaseHistoryController{
	public List<Case> caseHist = new List<Case>();
	public integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	public Boolean hasCaseHistory {get; private Set;}

	private String relId = '';
	private String leadRelType = '';
	private Boolean isConsIdSet = false;
    public EVMutil.consInfo ci {get; private set;}

	private Integer pageSize = 10;
	
	public List<Case> getCaseHist() {
		return caseHist;
	}
	
	public FOCaseHistoryController() {
		init();
	}

	private void init() {
		currPage = 1;
		totalPages = 0;
		hasCaseHistory = false;
		
		relId = System.currentPageReference().getParameters().get('id');
		leadRelType = System.currentPageReference().getParameters().get('leadRelType'); //coordinator or organizer
        system.debug(relId);

        ci = EVMUtil.getConsInfo(relId, leadRelType);
        
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
		
		LIST<Case> allCaseHist = [
			select
				CaseNumber
				, Constituent_Name__c
				, Subject
				, Origin
				, CreatedDate
				, ClosedDate
			from
				Case
			where
				ConstituentID__c = :ci.consId
				and Id <> :relId
			order by
				CreatedDate desc];
		
		System.debug('items: ' + allCaseHist.size());
		System.debug('totalPages: ' + totalPages);
		System.debug('pageSize: ' + pageSize);
		
		if (allCaseHist.size() > 0) {
			hasCaseHistory = true;
			totalPages =  integer.valueOf(string.valueOf(Math.ceil(double.valueOf(allCaseHist.size()) / double.valueOf(pageSize))));
			
			System.debug('totalPages: ' + totalPages);

			Integer i;
			caseHist = new List<Case>();
			for(i = (currPage - 1) * pageSize; i < currPage * pageSize && i < allCaseHist.size(); i++) {
				System.debug(i);
				caseHist.add(allCaseHist.get(i));
			}
			System.debug('GetPage() exit');
		}
	}
}