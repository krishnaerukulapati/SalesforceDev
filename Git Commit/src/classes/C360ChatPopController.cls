public with sharing class C360ChatPopController{
	
	public C360ChatPopController(ApexPages.StandardController controller) {
		
	}

	public PageReference loadSearch() {
		PageReference pr = Page.C360Search;
		pr.getParameters().put('chat', 'true');
		return pr;
	}
}