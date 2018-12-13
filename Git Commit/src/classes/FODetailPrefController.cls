public with sharing class FODetailPrefController {
	public domainSoapStjudeOrg.Preference[] prefs {get; set;}
	public string relId {get; private set;}
	public EVMUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
	private string name;
	public string contId {get; set;}
	private List<ConstituentInformation__c> consIds;
	public String consId {get; set;}
    public boolean bShowInactive {get; set;}
	
	public FODetailPrefController(ApexPages.StandardController controller) {
		init();
	}
	
	public FODetailPrefController() {
		init();
	}

	private void init() {
		relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);
        ci = EVMUtil.getConsInfo(relId);
        system.debug(ci.consId);
        if (ci.consId == null) {
        	isUUIDSet = false;
        }
		else {
			isUUIDSet = true;
			//consIds = FOUtil.getConstituentIds(currCase.ConstituentUUID__c);
			prefs = FOUtil.getPreferences(ci.consId);
			consId = ci.consId;
			
			consIds = EVMUtil.getConstituentInformationByConsInfo(ci);

			//get them from the constituent infos now - gonna write a wrapper in another util
			system.debug('FODetailController.FODetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
			//consId = consIds.get(0).ConstituentId__c;
		}
	}
	
	public void changeCons() {
		prefs = FOUtil.getPreferences(consId);
	}
	
	public LIST<SelectOption> getItems() {
		return EVMUtil.getConstituentIdsForSelect(consIds);
	}

	public PageReference EditPreference() {
		PageReference edit = Page.FOConstituentPreferenceEdit; 
    	system.debug('contId: ' + contId);
    	edit.setRedirect(true);
    	edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
    	edit.getParameters().put('consId', consId);
    	edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	return edit;
	}

	public PageReference NewPreference() {
		PageReference newItem = Page.FOConstituentPreferenceEdit; 
    	system.debug('id: ' + relId);
    	newItem.setRedirect(true);
    	newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
    	newItem.getParameters().put('consId', consId);
    	return newItem;
	}
}