@isTest
private class C360NewDonationContTest {
  
  @isTest static void test_method_one() {
    Lead c = new Lead();
    c.ConstituentID__c = 'notaquid';
        c.lastname = 'test lead';
    c.company = 'test company';
                insert c;


                ccDonateSettings__c setting = new ccDonateSettings__c();
                setting.Name = 'Master';
                setting.ccDonateSettingsURL__c = 'dummy';
                insert setting;

                CustomSettings__c cs = new CustomSettings__c(
                        Name = 'ccDonateECCDonation'
                        , Value__c = '1234'
                        );
                insert cs;
                
                cs = new CustomSettings__c(
                        Name = 'ccDonateRecommitDonation'
                        , Value__c = '1234'
                        );
                insert cs;

                Test.startTest();
                PageReference pageRef = Page.C360NewDonationStart;
                Test.setCurrentPage(pageRef);

                ApexPages.currentPage().getParameters().put('id', c.id);
                ApexPages.currentPage().getParameters().put('donationId', 'donationId');
                ApexPages.currentPage().getParameters().put('confNum', 'confNum');

                C360NewDonationController ccac = new C360NewDonationController();

                ccac.NewDonation();
                //ccac.NewDonationComplete();
  
    Test.stopTest();
  }
  
}