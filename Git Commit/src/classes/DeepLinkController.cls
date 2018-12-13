public with sharing class DeepLinkController {
	DeepLink__c dl { get; set; }

	public DeepLinkController(ApexPages.StandardController controller) {
		String linkName = System.currentPageReference().getParameters().get('linkname');
		if (String.isNotBlank(linkName)) {
			dl = DeepLink__c.getInstance(linkName);
		}
		else {

		}
	}

    public String getQueryString() {
    	String[] path = dl.Path__c.split('?');
    	String qs;

    	if(path.size() == 1) {
    		qs += '?';
    	}
    	else {
    		qs += '&';
    	}

    	for(String parm : System.currentPageReference().getParameters().keySet()) {
    		qs += parm + '=' + System.currentPageReference().getParameters().get(parm) + '&';
    	}

    	if (dl != null) {
    		if (String.isNotBlank(dl.TokenField__c) && String.isNotBlank(dl.Key__c)) {
		        qs += dl.TokenField__c + '=' + EVMUtil.getToken(dl.Key__c) + '&';
	    	}
	    	if (String.isNotBlank(dl.UserField__c)) {
	    		qs += dl.UserField__c + '=' + UserInfo.getUserName() + '&';
	    	}
	    }

	    //no matter which if's are traversed the string will always end with an &. get rid of it
    	qs = qs.substring(0, qs.length() - 1);

    	return qs;
    }
}