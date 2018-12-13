@isTest
public class ECCHeroesSegBatTest {

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

    static testMethod void leadWithOpp(){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.welCompStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        system.debug('Test.startTest()');
        Test.startTest();
        DataBase.executeBatch(new ECCHeroesSegBat());
        
        Test.stopTest();
        system.debug('Test.stopTest()');
    }
    
    static testMethod void leadWithoutOpp(){
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName='Activation',accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()),Revenue__c=1000));
        //insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        DataBase.executeBatch(new ECCHeroesSegBat());
        
        Test.stopTest();
        
    }
    
    static testMethod void oppStageactCompStage(){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.actCompStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        DataBase.executeBatch(new ECCHeroesSegBat());
        
        Test.stopTest();
        
    
        
    }
    
    
    static testMethod void oppStagecultCompStage(){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.cultCompStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()-100),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        ECCHeroesSegBat obj = new ECCHeroesSegBat();
        //obj.sendErrorEmail('Errormsg');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    } 
    
    static testMethod void leadWithOppwelStage(){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.welStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        DataBase.executeBatch(new ECCHeroesSegBat());
        
        Test.stopTest();
        
    }
    
    static testMethod void oppStageact2Stage  (){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.act2Stage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()-100),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        ECCHeroesSegBat obj = new ECCHeroesSegBat();
        //obj.sendErrorEmail('Errormsg');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    } 
    
    static testMethod void oppStagecult2CompStage (){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.cult2CompStage ,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()-100),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        ECCHeroesSegBat obj = new ECCHeroesSegBat();
        //obj.sendErrorEmail('Errormsg');
        DataBase.executeBatch(obj);
        ECCHeroesSegBat.sendErrorEmail('test');
        Test.stopTest();
    } 
    
     static testMethod void oppStagecultStage(){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.cultStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()-100),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        ECCHeroesSegBat obj = new ECCHeroesSegBat();
        //obj.sendErrorEmail('Errormsg');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    } 
    static testMethod void oppStagecult2Stage(){
        
        
        Account acc = new Account(Name=ECCHeroesSegBat.accountName);
        insert acc;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
        
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c;
        
        Campaign cmp = new Campaign(Name= ECCHeroesSegBat.parentCampName, EventID__c = '123',EndDate = Date.valueOf(system.today()));
        insert cmp;
        
        
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2CampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.welVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.actVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.act2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cultVCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name= ECCHeroesSegBat.cult2VCampName, ParentId = cmp.id,EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;
        
        Lead ld = new lead(lastName = 'LastName', company = 'Company',Status = 'Open',TR_ID__c= '123456');
        insert ld;
        
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.cult2Stage ,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.today()-100),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        
        Test.startTest();
        ECCHeroesSegBat obj = new ECCHeroesSegBat();
        String str = obj.query;
        Boolean b = obj.errorOnInit;
        obj.rType = new RecordType();
        //obj.sendErrorEmail('Errormsg');
        DataBase.executeBatch(obj);
        
        Test.stopTest();
    }
}