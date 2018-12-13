@isTest
global class ReportUtilTest {
	@isTest static void Can_GetDialerStatusReportData()
	{
		Test.startTest();
        Campaign c = new Campaign();
        c.name = 'test campaign';
        c.Status = 'In Progress';
        c.IsActive = true;
        insert c;

        Lead l = new Lead();
        l.LastName = 'Test lead';
        l.CurrentCampaign__c = c.id;
        l.Company = 'some company';
        l.DialerStatus__c = 'Ready';
        l.Phone = '9015176262';
        insert l;

		List<ReportUtil.DialerStatusModel> retList = ReportUtil.GetDialerStatusReportData();

        system.assert(retList.size() == 1);

        Test.stopTest();
	}

	@isTest static void Can_BuildDialerStatusModel()
	{
		Test.startTest();
        Campaign c = new Campaign();
        c.name = 'test campaign';
        insert c;

        Lead l = new Lead();
        l.LastName = 'Test lead';
        l.CurrentCampaign__c = c.id;
        l.Company = 'some company';
        l.DialerStatus__c = 'Ready';
        l.Phone = '9015176262';
        insert l;

        Lead l2 = new Lead();
        l2.LastName = 'Test lead';
        l2.CurrentCampaign__c = c.id;
        l2.Company = 'some company';
        l2.DialerStatus__c = 'Not Ready';
        l2.Phone = '9015176262';
        insert l2;

        Lead l3 = new Lead();
        l3.LastName = 'Test lead';
        l3.CurrentCampaign__c = c.id;
        l3.Company = 'some company';
        l3.DialerStatus__c = 'Failed';
        l3.Phone = '9015176262';
        insert l3;

		ReportUtil.DialerStatusModel model = new ReportUtil.DialerStatusModel(c.id);

        system.assert(model.TotalCount == 3);

        Test.stopTest();
	}
}