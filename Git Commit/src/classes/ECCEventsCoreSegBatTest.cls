@isTest 
private class ECCEventsCoreSegBatTest {

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
	private static void testECCEventsCoreSegBat() {
		Account a = new Account(Name = 'ALSAC Challenge');
        insert a;

		//Id rtId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('ECC Campaign').getRecordTypeId();

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

		Test.startTest();
		ECCEventsCoreSegBat obj = new ECCEventsCoreSegBat(c.ParentId);

		obj.query = 'select id, name, eventid__c, event_organizer__c, stagename, accountid, revenue__c, stagechanged__c, Recruited_Date__c, recruited_fy__c, recordtypeid, campaignid, support_campaign__c, probability from Opportunity where (CampaignId = \'' + c.ParentId + '\' or Support_Campaign__c = \'' + c.ParentId + '\') LIMIT 10';

		Boolean inList = obj.IsInList('TEST|TEST2|TEST3', 'TEST2');

        DataBase.executeBatch(obj, 10);
        ECCEventsCoreSegBat.sendErrorEmail('error', 'campaignid');
        
        Test.stopTest();
	}

	@isTest 
	public static void testGetRevenue() {
        //EmailSettings__c es = new EmailSettings__c();
        //    es.Name = 'Heroes Segmentation';
        //    es.Email__c = 'mail@mail.com';
        //    insert es;
            
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
        ECCEventsCoreSegBat ecc = new ECCEventsCoreSegBat(cmp.id);

        string rev = ecc.getTotalRevenue(cmp.EventID__c);

        Test.stopTest();
    }
}