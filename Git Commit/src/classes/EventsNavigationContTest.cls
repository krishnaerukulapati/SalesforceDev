@isTest
private class EventsNavigationContTest {

	@isTest static void testEventsNavigationController() {
		
		EnvironmentSettings__c esc = new EnvironmentSettings__c();
		esc.EventsOrg__c = 'test';
		insert esc;

		Test.startTest();

		EventsNavigationController enc1 = new EventsNavigationController();
		EventsNavigationController enc = new EventsNavigationController(new ApexPages.StandardController(esc));
		enc.getEnvSett();
		enc.getSearchURL();
		enc.getEventSearchURL();
		enc.getContactSearchURL();
		enc.getContextUserUiTheme();
		Test.stopTest();
	}
}