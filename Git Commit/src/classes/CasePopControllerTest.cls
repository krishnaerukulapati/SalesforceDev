@isTest
global class CasePopControllerTest{
	@isTest static void PopCase() {
		Case c1 = new Case();
		insert c1;

        Test.startTest();
        PageReference pageRef = Page.CasePop;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('ani', '9999999999');
        ApexPages.currentPage().getParameters().put('_c', '123456');

        CasePopController ccac = new CasePopController(new ApexPages.StandardController(c1));

        ccac.createAndLoad();

		List<Case> c = [
            select 
                  Id
                , CallObject__c
                , Subject
            from 
                Case 
            where 
                CallObject__c = :'123456' And Subject =:'Inbound Call from 9999999999'];

        system.Assert(c != null);
        system.Assert(c.size() == 1);        
		Test.stopTest();
	}
}