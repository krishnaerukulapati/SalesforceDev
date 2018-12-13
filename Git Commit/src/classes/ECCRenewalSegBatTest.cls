@isTest
public class ECCRenewalSegBatTest {
	@TestSetup
    static void prepareData(){
        EmailSettings__c emailSet = new EmailSettings__c(name = 'Heroes Segmentation',Email__c= 'HeroesSegmentation@test.com');
        insert emailSet;
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.ActHoursToWait__c = 22;
        es.Act2HoursToWait__c = 22;
        es.CultHoursToWait__c = 22;
        es.Cult2HoursToWait__c = 22;
        insert es;
    }

     @isTest
    static void runBat() {
        Account a = new Account(Name = 'Heroes');
        insert a;

        String parCampId;
        Campaign c = new Campaign(
            Name = 'Test Renewal PCampaign'
            , EventId__c = '1234');
        insert c;
        parCampId = c.Id;

        Lead l = new Lead(
            LastName = 'TestLead',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            TR_ID__c = '321654',
            CurrentCampaign__c = parCampId,
            XREF__c = '123|321'
            );
      
        insert l;

        //this is the segmentation campaign
            //added IsSeg__c = true
            //changed SegFiltReg__c = 'D' to 'E',
            //SegFiltPart__c = 'whatever it was' t0 'Classic Hero level|Platinum Hero', 
       /* c = new Campaign(
            Name = 'Test Renewal CCampaign',
            
            EventTypeID__c = Guid.createGuid(),
            EventId__c = '12254345';
            ParentId = c.Id);

        insert c;*/

        //set the current revenue to 5 which is different from the zero in the test registration
        Opportunity opp = new Opportunity(
            Name = 'test',
            StageChanged__c = System.today(),
            Probability = 0.0,
            Stagename = 'Closed Won', 
            CloseDate=System.today(),
            Revenue__c = 5.00,
            CampaignId = c.Id,
            Event_Organizer__c=l.id);
        insert opp;

        //this lead doesn't have an opportunity
        l = new Lead(
            LastName = 'TestLead1',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            TR_ID__c = '321654',
            CurrentCampaign__c = parCampId,
            XREF__c = '123|123'
            );
      
        insert l;

        Test.startTest();
        DataBase.executeBatch(new ECCRenewalSegBat(c.ParentId, c.EventTypeID__c));
        ECCRenewalSegBat.sendErrorEmail('error', 'campaignid');
        
        Test.stopTest();
    }




}