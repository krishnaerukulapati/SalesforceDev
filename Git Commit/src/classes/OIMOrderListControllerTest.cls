@isTest
private class OIMOrderListControllerTest {

	@isTest static void testOIMOrderListController() {
		
		Test.startTest();

		PageReference pageRef = Page.OIMOrderList;
		Test.setCurrentPage(pageRef);

		OIMOrderListController olc = new OIMOrderListController();
		
		Test.stopTest();
	}
	
}