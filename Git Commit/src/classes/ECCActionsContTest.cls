@isTest
private class ECCActionsContTest {
	
	@isTest static void test_method_one() {
		Case c = new Case();
		c.ConstituentID__c = 'notaquid';
		c.ConstituentType__c = 'INDIVIDUAL';
        insert c;

        Test.startTest();

        ECCActionsController ccac = new ECCActionsController(new ApexPages.StandardController(c));

	
		Test.stopTest();
	
	}
	
}