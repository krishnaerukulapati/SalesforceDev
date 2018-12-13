@isTest
private class RefundHistoryContTest {

	@isTest static void RefundHistoryController() {
		
		Case c = new Case();
		c.ConstituentID__c = 'notaquid';
		insert c;

		List<Refund_Request__c> rrc = new List<Refund_Request__c>();
		//rrc.DonorName__c = 'testName';
		insert rrc;

		Test.startTest();
		PageReference pageRef = Page.RefHistory;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', c.ConstituentID__C);
		RefundHistoryController rhc = new RefundHistoryController(new ApexPages.StandardController(c));

		//rhc.getRefHist();
		rhc.nextPage();
		rhc.prevPage();
		rhc.getPage();

		Test.stopTest();
	}
}