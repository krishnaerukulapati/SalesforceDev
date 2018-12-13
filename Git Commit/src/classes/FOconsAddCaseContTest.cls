@isTest
global class FOconsAddCaseContTest {


	@isTest static void ControllerTest() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.FOConsAddCase;
        Test.setCurrentPage(pageRef);

        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.Constituent_Name__c = 'Test Name';
        insert c;

        ApexPages.currentPage().getParameters().put('caseId', c.id);
        ApexPages.currentPage().getParameters().put('consId', c.ConstituentId__c);
        ApexPages.currentPage().getParameters().put('name', c.Constituent_Name__c);
        ApexPages.currentPage().getParameters().put('consType', c.ConstituentType__c);

        FOConsAddCaseController cac = new FOConsAddCaseController(new ApexPages.StandardController(c));

        cac.prepopulateValues();    
	
		Test.stopTest();
	}
}