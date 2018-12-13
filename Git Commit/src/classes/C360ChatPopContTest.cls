@isTest
private class C360ChatPopContTest {
	
	@isTest static void testLoadSearch() {
		
		Case c = new Case();
		c.ConstituentID__c = 'notaquid';
		insert c;
		Test.startTest();

		C360ChatPopController cac = new C360ChatPopController(new ApexPages.StandardController(c));

		cac.loadSearch();

		Test.stopTest();
	}
}