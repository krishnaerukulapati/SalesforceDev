@isTest
private class ECCEventsSegBatTest {
    
        @TestSetup
    static void prepareData(){
                //RecordType rt = new RecordType();
                ////assign values
                //insert rt;

                EnvironmentSettings__c es = new EnvironmentSettings__c();
                es.ActHoursToWait__c = 22;
                es.Act2HoursToWait__c = 22;
                es.CultHoursToWait__c = 22;
                es.Cult2HoursToWait__c = 22;
                insert es;

    }

    @isTest static void testECCSegBat(){

                //RecordType rt = new RecordType();
                //insert rt; 
                
                EmailSettings__c es = new EmailSettings__c();
                    es.Name = 'Heroes Segmentation';
                    es.Email__c = 'mail@mail.com';
                    insert es;     

                //Campaign c = new Campaign(Id='7018A0000001zuRQAQ');
                //Campaign cmp = new Campaign();
                //cmp.Name = 'St Jude Trike-a-thon FY16 Support';
                //cmp.EventId__c = '123';
                //cmp.EndDate = Date.valueOf(system.today());
                //insert cmp;

                //list<Campaign> childCmpLst = new list<Campaign>();
                //childCmpLst.add(new Campaign(Name= 'ECC Event Confirmation Call', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
                //childCmpLst.add(new Campaign(Name= 'ECC Event Kit Received Call', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
                //childCmpLst.add(new Campaign(Name= 'ECC Event Funbook Call', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
                //childCmpLst.add(new Campaign(Name= 'ECC Event Money Encouragement Call 1', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
                //childCmpLst.add(new Campaign(Name= 'ECC Event Money Encouragement Call 2', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
                //childCmpLst.add(new Campaign(Name= 'ECC Event Closed', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
                //insert childCmpLst;

				Account a = new Account(Name = 'ALSAC Challenge');
				insert a;

				String parCampId;
        Campaign c = new Campaign(
            Name = 'Test parent PCampaign'
            , EventId__c = '1234'
            , OppRecordType__c = 'St_Jude_Challenge'
            , OppAcc__c = a.Id);
        insert c;
        parCampId = c.Id;

		Lead l = new Lead(
            LastName = 'TestLead',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            CurrentCampaign__c = parCampId
            );
      
        insert l;

		c = new Campaign(
            Name = 'Test child CCampaign',
            SegFiltRev__c = 0, 
            SegFiltReg__c = 'E',
            SegFiltPart__c = 'Classic Hero level|Platinum Hero', 
            SegStageName__c = 'Welcome',
            SegHrsToWait__c = 0,
			SegDaysFromEvent__c = 0,
            AllowPreStages__c = 'Staged',
            IsSeg__c = true,
            ParentId = c.Id);

        insert c;

		Opportunity opp = new Opportunity(
            Name = 'test',
            StageChanged__c = System.today(),
            Probability = 0.0,
            Stagename = 'Staged', 
            CloseDate=System.today(),
            Revenue__c = 5.00,
            CampaignId = c.ParentId,
            Event_Organizer__c=l.id,
			EventID__c = 'BFBFE580-76E4-4B97-AA7F-6593D19946DE');
        insert opp;

		l = new Lead(
            LastName = 'TestLead1',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            CurrentCampaign__c = parCampId
            );
      
        insert l;


                system.debug('Test.startTest()');
                Test.startTest();

				ECCEventsSegBat obj = new ECCEventsSegBat(c.ParentId);

				Boolean inList = obj.IsInList('TEST|TEST2|TEST3', 'TEST2');

                DataBase.executeBatch(new ECCEventsSegBat(c.ParentId));
        
                Test.stopTest();
                //system.debug('Test.stopTest()');
    }

        //@isTest static void testExecute(){
        //        List<sObject> scope = new List<sObject>();

        //        Test.startTest();
        //        ECCEventsSegBat.execute(null, scope);
        //        Test.stopTest();
        //}
        
    @isTest static void testGetRevenue() {
        EmailSettings__c es = new EmailSettings__c();
            es.Name = 'Heroes Segmentation';
            es.Email__c = 'mail@mail.com';
            insert es;
            
        Campaign c = new Campaign(Id='7018A0000001zuRQAQ');
        Campaign cmp = new Campaign();
        cmp.Name = 'St Jude Trike-a-thon FY16 Support';
        cmp.EventId__c = '123';
        cmp.EndDate = Date.valueOf(system.today());
        insert cmp;

        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= 'ECC Event Confirmation Call', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= 'ECC Event Kit Received Call', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= 'ECC Event Funbook Call', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= 'ECC Event Money Encouragement Call 1', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= 'ECC Event Money Encouragement Call 2', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= 'ECC Event Closed', ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        insert childCmpLst;

        Test.startTest();
        ECCEventsSegBat ecc = new ECCEventsSegBat(cmp.id);

        string rev = ecc.getTotalRevenue(cmp.EventID__c);

        Test.stopTest();
    }
}