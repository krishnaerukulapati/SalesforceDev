@isTest
private class FOFitnessEventSupportContTest {

	@isTest static void test() {
		Lead c = new Lead();
		c.ConstituentID__c = 'notaquid';
        c.lastname = 'test lead';
    	c.company = 'test company';
		insert c;

		EnvironmentSettings__c es = new EnvironmentSettings__c(
            FitnessEventSupport__c = 'https://test/'
        );
        insert es;

        Test.startTest();
        PageReference pageRef = Page.FOFitnessEventSupport;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('id', c.id);

        FOFitnessEventSupportController fesc = new FOFitnessEventSupportController();

        fesc.LoadFitnessEventSupport();

		Test.stopTest();
	}
}