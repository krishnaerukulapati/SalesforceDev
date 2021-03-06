global with sharing class FOInteractionController{
	public string relId {get; private set;}
	public ECCUtil.consInfo ci {get; private set;}
	public integer page {get; private Set;}
	public integer pageTotal {get; private Set;}
	public String consId {get; set;}
	public List<domainSoapStjudeOrg.Interaction> interactions = new List<domainSoapStjudeOrg.Interaction>();
	
	private integer pageSize = 10;
	private Integer totalItems = 0;
	private LIST<ConstituentInformation__c> consIds;
	
	public FOInteractionController.FOInteractionController() {
		init();
	}

	public FOInteractionController(ApexPages.StandardController controller) {
		init();
	}

	private void init() {
		relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);

        if (String.isNotEmpty(relId)) {
	        ci = ECCUtil.getConsInfo(relId);
	        system.debug('consId: ' + ci.consId);
	        if (ci.consId != null) {
				consIds = ECCUtil.getConstituentInformationByConsInfo(ci);
				//consIds = C360Util.getConstituentIds(currCase.ConstituentUUID__c);
				consId = consIds.get(0).ConstituentId__c;
				//loadInteractions();
			}
        }
	}

    public string getSourceURL() {
        return C360Settings__c.getInstance('SOURCE').C360SettingsURL__c;
    }
	
	public PageReference changeCons() {
		return null;
	}

	@RemoteAction
	global static soapStjudeOrg.GetInteractionsResponse_element getInteractionPage(string consId, integer startRow, integer endRow) {
		try {
			return C360Util.getInteractions(consId, 'ALL', startRow, endRow);
		}
		catch(Exception e) {
			return new soapStjudeOrg.GetInteractionsResponse_element();
		}
	}
	
	public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
	}
}