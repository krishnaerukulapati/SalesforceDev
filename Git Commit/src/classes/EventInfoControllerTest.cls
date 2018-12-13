@isTest
public class EventInfoControllerTest{
    

    static testMethod void testMethod_1(){
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        
        PageReference pf = page.EventInfo;
        test.setCurrentPage(pf);
        pf.getParameters().put('eventId',evnt.EventId__c);
        
        EventInfoController eObj = new EventInfoController();
        eobj.init();
        
    }
    
}