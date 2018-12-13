public with sharing class FONoblePopController{
	
	public FONoblePopController(ApexPages.StandardController controller) {
		
	}

	public PageReference loadSearch() {
		PageReference pr = Page.FOSearch;
		pr.getParameters().put('ani', System.currentPageReference().getParameters().get('ani'));
		pr.getParameters().put('callid', System.currentPageReference().getParameters().get('callid'));
		pr.getParameters().put('mode', System.currentPageReference().getParameters().get('mode'));
		return pr;
	}
	
}