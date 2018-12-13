public with sharing class FOLeadHistoryController{
	public List<Lead> leadHist = new List<Lead>();
	public integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	public Boolean hasLeadHistory {get; private Set;}

	private String relId = '';
	private String leadRelType = '';
	private Boolean isConsIdSet = false;
    public EVMutil.consInfo ci {get; private set;}

	private Integer pageSize = 10;
	
	public List<Lead> getLeadHist() {
		return leadHist;
	}
	
	public FOLeadHistoryController() {
		init();
	}

	private void init() {
		currPage = 1;
		totalPages = 0;
		hasLeadHistory = false;
		
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
		
		LIST<Lead> allLeadHist = [
			select
				Id
				, Name
				, CoordinatorID__c
				, ConstituentID__c
				, RecordType.Name
				, CurrentCampaign__r.Name
				, CreatedDate
			from
				Lead
			where
				(ConstituentID__c = :ci.consId
				or CoordinatorID__c = :ci.consId)
				and Id <> :relId
			order by
				CreatedDate desc];
		
		System.debug('items: ' + allLeadHist.size());
		System.debug('totalPages: ' + totalPages);
		System.debug('pageSize: ' + pageSize);
		
		if (allLeadHist.size() > 0) {
			hasLeadHistory = true;
			totalPages =  integer.valueOf(string.valueOf(Math.ceil(double.valueOf(allLeadHist.size()) / double.valueOf(pageSize))));
			
			System.debug('totalPages: ' + totalPages);

			Integer i;
			leadHist = new List<Lead>();
			for(i = (currPage - 1) * pageSize; i < currPage * pageSize && i < allLeadHist.size(); i++) {
				System.debug(i);
				leadHist.add(allLeadHist.get(i));
			}
			System.debug('GetPage() exit');
		}
	}
}