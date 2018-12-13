@isTest
private class C360NoblePopContTest {
	
	@isTest static void PopNoble() {
		Case c = new Case();
		insert c;

        Test.startTest();
        PageReference pageRef = Page.C360NoblePop;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('ani', 'ani');

        C360NoblePopController ccac = new C360NoblePopController(new ApexPages.StandardController(c));

        ccac.loadSearch();

		Test.stopTest();
	}
	
}