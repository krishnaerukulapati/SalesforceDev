public with sharing class C360NoblePopController{
	
	public C360NoblePopController(ApexPages.StandardController controller) {
		
	}

	public PageReference loadSearch() {
		PageReference pr = Page.C360Search;
		system.debug('System.currentPageReference().getParameters().get(\'ani\'):' + System.currentPageReference().getParameters().get('ani'));
		system.debug('System.currentPageReference().getParameters().get(\'dnis\'):' + System.currentPageReference().getParameters().get('ani'));
		system.debug('System.currentPageReference().getParameters().get(\'_c\'):' + System.currentPageReference().getParameters().get('_c'));
		system.debug('System.currentPageReference().getParameters().get(\'callid\'):' + System.currentPageReference().getParameters().get('callid'));
		system.debug('System.currentPageReference().getParameters().get(\'mode\'):' + System.currentPageReference().getParameters().get('mode'));
		pr.getParameters().put('ani', System.currentPageReference().getParameters().get('ani'));
		pr.getParameters().put('mode', System.currentPageReference().getParameters().get('mode'));

		String callId = System.currentPageReference().getParameters().get('_c');
		if (String.isEmpty(callId)) {
			callId = System.currentPageReference().getParameters().get('callid');
		}
		pr.getParameters().put('callid', callId);

		String ani = System.currentPageReference().getParameters().get('ani');
		if (String.isEmpty(ani)) {
			ani = System.currentPageReference().getParameters().get('dnis');
		}
		pr.getParameters().put('ani', ani);
		return pr;
	}
}