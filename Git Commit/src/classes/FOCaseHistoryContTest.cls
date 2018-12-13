@isTest
private class FOCaseHistoryContTest {
	
	@isTest static void testCaseHistoryCase() {
                Case c = new Case();
                c.ConstituentID__c = 'notaquid';
                c.ConstituentType__c = 'INDIVIDUAL';
                c.ConstituentUUID__c = 'notaguid';
                insert c;

                Case c1 = new Case();
                c1.ConstituentID__c = 'notaquid';
                c1.ConstituentType__c = 'INDIVIDUAL';
                c1.ConstituentUUID__c = 'notaguid';
                insert c1;

                ConstituentInformation__c ci = new ConstituentInformation__c();
                ci.ConstituentId__c = 'notaguid';
                ci.CaseId__c = c.id;
                ci.Preferred__c = true;
                insert ci;

                C360Settings__c setting = new C360Settings__c();
                setting.Name = 'Master';
                setting.C360SettingsURL__c = 'dummy';
                insert setting;

                Test.startTest();
                PageReference pageRef = Page.FOCaseHistory;
                Test.setCurrentPage(pageRef);

                ApexPages.currentPage().getParameters().put('id', c.id);

                FOCaseHistoryController ccac = new FOCaseHistoryController();

                ccac.nextPage();
                ccac.prevPage();
                ccac.getCaseHist();
	
		Test.stopTest();
	}
	
}