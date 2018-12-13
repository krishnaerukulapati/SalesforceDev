@isTest
public class RecruitEventControllerTest{
    

    static testMethod void testMethod_1(){
        
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123123';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        system.debug(es);
        
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        insert ld;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x	em = new EventMasters__x();
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
        
        EventNotes__x evntnote =  new EventNotes__x();
        //evntnote.Notes__c = 'notes';
        evntnote.EventID__c = evnt.EventId__c;
        
        Account acc = new Account();
        acc.Name = 'ALSAC Challenge';
        insert acc;
        acc = [select id, name from account limit 1];
        system.debug('acc Name'+acc.Name); 
        
        Opportunity opp = new Opportunity(Name ='Opportunity');
        opp.CloseDate = Date.ValueOf(system.today());
        opp.AccountId= acc.id;
        //opp.Event_Organizer__c = ld.id;
        opp.stageName = 'Name';
        //opp.EventID__c = evnt.EventId__c;
        insert opp;
        
        Test.startTest();
        PageReference pf = page.RecruitEvent;
        test.setCurrentPage(pf);
        
        ApexPages.currentPage().getParameters().put('id', ld.id);
        RecruitEventController eObj = new RecruitEventController();
        //eobj.init();
        eObj.cancelEvent();
        eObj.fetchOrganizer();
        eobj.StartDate = '2013-04-24T05:00:00.000Z';
        eObj.EndDate = '2013-04-24T05:00:00.000Z';
        //eobj.Location = 'Us';
        //eobj.EventTime = 'Morning';
        //eobj.TypeOfEvent = 'Morning';
        eobj.locationAttr = OdataExtension.GetEventTypeAttributeViews(Guid.createGuid())[0];
        eobj.eventTimeAttr = OdataExtension.GetEventTypeAttributeViews(Guid.createGuid())[0];
        eobj.typeOfEventAttr = OdataExtension.GetEventTypeAttributeViews(Guid.createGuid())[0];
        eobj.saveEvent();
        
        eobj.StartDate = null;
        eobj.saveEvent();
        eobj.EndDate = null;
        eobj.saveEvent();
        opp.EventID__c = evnt.EventId__c;
        update opp;
        eobj.saveEvent();
        
        eObj.changeCoord();
        delete acc;
        eobj.saveEvent();
        
        
        test.stopTest();
        
    }
    
    static testMethod void assigningDefaultEvent(){
        
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123123';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        system.debug(es);
        
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        insert ld;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x	em = new EventMasters__x();
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
        
        EventNotes__x evntnote =  new EventNotes__x();
        //evntnote.Notes__c = 'notes';
        evntnote.EventID__c = evnt.EventId__c;
        
        Account acc = new Account();
        acc.Name = 'ALSAC Challenge';
        insert acc;
        
        Opportunity opp = new Opportunity(Name ='Opportunity');
        opp.CloseDate = Date.ValueOf(system.today());
        opp.AccountId= acc.id;
        //opp.Event_Organizer__c = ld.id;
        opp.stageName = 'Name';
        //opp.EventID__c = evnt.EventId__c;
        insert opp;
        
        Test.startTest();
        PageReference pf = page.RecruitEvent;
        test.setCurrentPage(pf);

        ApexPages.currentPage().getParameters().put('id', ld.id);
        
        RecruitEventController eObj = new RecruitEventController();
        //eobj.init();
        eObj.cancelEvent();
        eObj.fetchOrganizer();
        eobj.StartDate = '2013-04-24T05:00:00.000Z';
        eObj.EndDate = '2013-04-24T05:00:00.000Z';
        //eobj.Location = 'Us';
        //eobj.EventTime = 'Morning';
        //eobj.TypeOfEvent = 'Morning';
        eobj.init();
        try{
            eobj.Event = evnt;
            eobj.getEventAttributes();
        }catch(exception e){
            
        }
        test.stopTest();
        
    }
    
    static testMethod void testMethod_2(){
        
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123123';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        system.debug(es);
        
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        insert ld;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x	em = new EventMasters__x();
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
        
        EventNotes__x evntnote =  new EventNotes__x();
        //evntnote.Notes__c = 'notes';
        evntnote.EventID__c = evnt.EventId__c;
        
        Account acc = new Account();
        acc.Name = 'ALSAC Challenge';
        insert acc;
        acc = [select id, name from account limit 1];
        system.debug('acc Name'+acc.Name); 
        
        Opportunity opp = new Opportunity(Name ='Opportunity');
        opp.CloseDate = Date.ValueOf(system.today());
        opp.AccountId= acc.id;
        opp.Event_Organizer__c = ld.id;
        opp.stageName = 'Name';
        opp.EventID__c = evnt.EventId__c;
        insert opp;
        
        Test.startTest();
        PageReference pf = page.RecruitEvent;
        test.setCurrentPage(pf);
        
        ApexPages.currentPage().getParameters().put('id', ld.id);
        RecruitEventController eObj = new RecruitEventController();
        eobj.init();
        eobj.StartDate = '2013-04-24T05:00:00.000Z';
        eObj.EndDate = '2013-04-24T05:00:00.000Z';
        //eobj.Location = 'Us';
        //eobj.EventTime = 'Morning';
        //eobj.TypeOfEvent = 'Morning';
        eobj.saveEvent();
        
        test.stopTest();
        
    }
    
}