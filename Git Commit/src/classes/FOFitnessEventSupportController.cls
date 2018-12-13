public with sharing class FOFitnessEventSupportController {
	public FOFitnessEventSupportController() {
		
	}

	public PageReference LoadFitnessEventSupport() {
		PageReference ret = null;
	    String leadId = System.currentPageReference().getParameters().get('id');
	    EVMUtil.SSLeads currLead = EVMUtil.getCurrLead(leadId);

	    String destination = '';
	    String appURL = '';
	    String p2pID = '';
	    String eventID = ''; 

	    if (currLead != null) {
	    	System.debug(currLead);

	    	EnvironmentSettings__c es = [SELECT FitnessEventSupport__c FROM EnvironmentSettings__c];
	    	appURL = es.FitnessEventSupport__c;

	    	p2pID = currLead.SSLead.TR_ID__c;
	    	eventID = currLead.SSLead.CurrentCampaign__r.Evaluated_EVM_EventID__c;
	    }

	    Blob returnURL = Blob.valueOf(URL.getSalesforceBaseUrl().toExternalForm() + Page.FOFitnessEventSupport.getURL() + '?id=' + leadId);
	    destination = appURL + 'Participants/Details/' + p2pID + '?eventId=' + eventID
	    + '&showHeader=false&returnURL64=' + Encodingutil.base64Encode(returnURL);

	    // destination = 'https://services.stjude.org/odata/FitnessEventSupport/Participants/Details/4125455?eventId=af11d012-6ca0-4e16-8b5c-25d10e68f046'
	    //+ '&showHeader=false&returnURL=' + Encodingutil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + Page.FOFitnessEventSupport.getURL() + '?id=' + leadId, 'UTF-8');  
        
    	system.debug(destination);
    	ret = new PageReference(destination);
        
        return ret;
	}
}