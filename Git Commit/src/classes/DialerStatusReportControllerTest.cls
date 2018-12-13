@isTest
global class DialerStatusReportControllerTest {
	@isTest static void ViewReport()
	{
		 Test.startTest();
        
        PageReference pageRef = Page.DialerStatusReport;
        Test.setCurrentPage(pageRef);

        DialerStatusReportController ccac = new DialerStatusReportController();

        Test.stopTest();
	}
}