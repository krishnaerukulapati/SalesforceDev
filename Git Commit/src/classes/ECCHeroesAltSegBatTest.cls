@isTest
public class ECCHeroesAltSegBatTest {
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
            Name = 'Test parent PCampaign'
            , EventId__c = '1234'
            , OppRecordType__c = 'Heroes'
            , OppAcc__c = a.Id);
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
        c = new Campaign(
            Name = 'Test child CCampaign',
            SegFiltRev__c = 0, 
            SegFiltReg__c = 'E',
            SegFiltPart__c = 'Classic Hero level|Platinum Hero', 
            SegStageName__c = 'Welcome',
            SegHrsToWait__c = 1,
            AllowPreStages__c = '',
            IsSeg__c = true,
            ParentId = c.Id);

        insert c;

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
        DataBase.executeBatch(new ECCHeroesAltSegBat(c.ParentId));
        ECCHeroesAltSegBat.sendErrorEmail('error', 'campaignid');
        
        Test.stopTest();
    }

}