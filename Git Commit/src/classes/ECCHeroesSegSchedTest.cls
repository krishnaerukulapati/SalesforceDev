@isTest
public class ECCHeroesSegSchedTest {
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
    static testMethod void doTest(){
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
        ECCHeroesSegSched cntrl  = new ECCHeroesSegSched ();
        cntrl.execute(null);
    }
    
    static testMethod void zeroRevenue(){
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
        ECCHeroesSegBat ee = new ECCHeroesSegBat();
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.welCompStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.now().addHours(-ee.actHoursToWait-5)),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        ECCHeroesSegSched cntrl  = new ECCHeroesSegSched ();
        cntrl.execute(null);
    }
    
    static testMethod void act2HoursToWait(){
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
        ECCHeroesSegBat ee = new ECCHeroesSegBat();
        list<Opportunity> oppLst = new list<opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCHeroesSegBat.actCompStage,accountId=acc.id,Probability = 10,StageChanged__c=date.valueOf(system.now().addHours(-ee.act2HoursToWait-5)),Revenue__c=0,Event_Organizer__c = ld.id));
        insert oppLst;
        
        CampaignMember cmem = new CampaignMember(CampaignId = cmp.id, LeadId = ld.id);
        insert cmem;
        ECCHeroesSegSched cntrl  = new ECCHeroesSegSched ();
        cntrl.execute(null);
    }
     
    
    
}