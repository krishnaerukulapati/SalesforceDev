public with sharing class FOOppHistoryController{
	public List<Opportunity> oppHist = new List<Opportunity>();
	public List<ConstituentPlans__x> dmsPlans = new List<ConstituentPlans__x>();
	public Integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	public Integer dmsResults {get; private set;}
	public Boolean hasOppHistory {get; private Set;}
	public Boolean hasDMSHistory {get; private set;}
	public String switchLabel {get; private set;}
	public Boolean dmsPlanIsActive {get; set;}
	public Boolean viewOpps {get; set;}
	private String relId = '';
	private String leadRelType = '';
	private Boolean isConsIdSet = false;
    public EVMUtil.consInfo ci {get; private set;}

	private Integer pageSize = 10;
	
	public List<Opportunity> getOppHist() {
		return oppHist;
	}

	public List<ConstituentPlans__x> getDMSPlans() {
		return dmsPlans;
	}
	
	public FOOppHistoryController() {
		init();
	}

	private void init() {
		currPage = 1;
		totalPages = 1;
		hasOppHistory = false;
		hasDMSHistory = false;
		dmsPlanIsActive = true;
		dmsResults = 0;
		viewOpps = true;
		
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
		if (currPage <= totalPages) {
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

	public void SwitchView() {
		if (viewOpps == true) {
			switchLabel = 'View Opportunities';
			viewOpps = false;
		}
		else {
			if (viewOpps == false) {
				switchLabel = 'View GP/SP Plans (' + dmsResults + ')';
				viewOpps = true;
			} 
		}	
		GetPage();
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
					and Id <> :relId
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

			oppHist = new List<Opportunity>();
			for(Integer i = (currPage - 1) * pageSize; i < currPage * pageSize && i < allOppHist.size(); i++) {
				System.debug(i);
				oppHist.add(allOppHist.get(i));
			}
			System.debug('GetPage() exit');
		}
		try {
			List<ConstituentPlans__x> allDMSPlans = OdataExtension.GetDMSPlanByConsId(ci.consId, dmsPlanIsActive);
			System.debug('DMS Plans returned: ' + allDMSPlans.size());
			if (allDMSPlans.size() > 0) {
				hasDMSHistory = true;
				dmsResults = allDMSPlans.size();
				if (String.isBlank(switchLabel)) switchLabel = 'View GP/SP Plans (' + dmsResults + ')';
				totalPages =  Integer.valueOf(string.valueOf(Math.ceil(double.valueOf(dmsResults) / double.valueOf(pageSize))));
				System.debug('totalPages: ' + totalPages);
				dmsPlans = new List<ConstituentPlans__x>();
				for(Integer i = (currPage - 1) * pageSize; i < currPage * pageSize && i < dmsResults; i++) {
					System.debug(i);
					dmsPlans.add(allDMSPlans.get(i));
				}
				System.debug('GetPage() exit');
			}
		}
		catch (Exception e) {
			System.debug(e);
		}
	}

	public string getBbecURL() {
        return BbecSettings__c.getInstance('Plans').BbecURL__c;
    }
}