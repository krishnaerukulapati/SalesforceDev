@isTest
private class FONoblePopContTest {
	
	@isTest static void PopNoble() {
		Case c = new Case();
		insert c;

        Test.startTest();
        PageReference pageRef = Page.FONoblePop;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('ani', 'ani');

        FONoblePopController ccac = new FONoblePopController(new ApexPages.StandardController(c));

        ccac.loadSearch();

		Test.stopTest();
	}
	
}