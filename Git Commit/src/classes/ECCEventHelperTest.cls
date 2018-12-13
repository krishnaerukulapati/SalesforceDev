@isTest
public class ECCEventHelperTest{
    static testMethod void testMethod_1(){
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123123';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        insert ld;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.StateID__c = state.StateID__c;
        
        Account acc = new Account();
        acc.Name = 'ALSAC';
        insert acc;
        
        Opportunity opp = new Opportunity(Name ='Opportunity');
        opp.CloseDate = Date.ValueOf(system.today());
        opp.AccountId= acc.id;
        opp.Event_Organizer__c = ld.id;
        opp.stageName = 'Name';
        opp.EventID__c = evnt.EventId__c;
        //insert opp;
        
        Test.startTest();
        
        ECCEventHelper eh = new ECCEventHelper();
        Opportunity eventOpp;
        Events__x  ee = ECCEventHelper.GetDIYEventFromLead(ld, eventOpp);
        //PreferredConstituentInfos__x tmp = ECCEventHelper.GetDIYEventContactFromLead(ld,Guid.createGuid() ,evnt,opp,null);
        
        test.stopTest();
        
    }
    
    static TestMethod void can_Strip_NonNumericData(){
        String expectedResult = '9015176262';
        String retVal = ECCEventHelper.RemoveNonNumericData('(901) 517-6262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('9015176262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('901a$$sdf517a  sdf6262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('90asdf  151762!asdf62');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('901a!sdf51762as%df62');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('9015asdf176%asdf262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('901517JOhn $$6262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('901%5176262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('90151^76262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('9015176~262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('90151&76262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('9015*176262');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData(' 9015*176262 ext. 1234');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData(' 9015*176262 x.1234');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('3.54E+11');
        system.assert(retVal == '354');


        retVal = ECCEventHelper.RemoveNonNumericData('-97736');
        system.assert(retVal == '97736');

        retVal = ECCEventHelper.RemoveNonNumericData('4.47849E+11');
        system.assert(retVal == '447849');

        retVal = ECCEventHelper.RemoveNonNumericData('4.48E+11');
        system.assert(retVal == '448');


        expectedResult = '';

        retVal = ECCEventHelper.RemoveNonNumericData('');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData(' ');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('NA');
        system.assert(retVal == expectedResult);

        retVal = ECCEventHelper.RemoveNonNumericData('none');
        system.assert(retVal == expectedResult);

        expectedResult = null;

        retVal = ECCEventHelper.RemoveNonNumericData(null);
        system.assert(retVal == expectedResult);
    }

   static testMethod void testMethod_2(){
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123123';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        ld.ConstituentID__c = Guid.createGuid();
        insert ld;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.StateID__c = state.StateID__c;
        
        Account acc = new Account();
        acc.Name = 'ALSAC';
        insert acc;
        
        /*Opportunity opp = new Opportunity(Name ='Opportunity');
        opp.CloseDate = Date.ValueOf(system.today());
        opp.AccountId= acc.id;
        opp.Event_Organizer__c = ld.id;
        opp.stageName = 'Name';
        //opp.EventID__c = evnt.EventId__c;
        insert opp;*/
        
        Test.startTest();
        
        ECCEventHelper eh = new ECCEventHelper();
        Opportunity eventOpp;
        Events__x  ee = ECCEventHelper.GetDIYEventFromLead(ld, eventOpp);
        
        
        test.stopTest();
        
    } 
    
    
    static testMethod void fetchEventCoordinatorTest(){
        
        Map<String,EventConstituentRoleViews__x> mp = ECCEventHelper.fetchEventCoordinator(new set<string>{Guid.createGuid()});
        
    }
    
     static testMethod void fetchEventOrganizerTest(){
        
        Map<String,EventConstituentRoleViews__x> mp = ECCEventHelper.fetchEventOrganizer(new set<string>{Guid.createGuid()});
        
    }
}