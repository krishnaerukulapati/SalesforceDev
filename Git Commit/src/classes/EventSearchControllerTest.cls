@isTest
public class EventSearchControllerTest{

   
    static testMethod void testMethod_1(){

        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123456789';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        EventSearchController esObj = new EventSearchController();
        boolean b = esObj.hasPrevious;
        system.assertEquals(b,false);
        integer n = esObj.currPage;
        b = esObj.hasNext;
        b = esObj.validate();
        esObj.search();
        list<Events__x> searchResults = esObj.searchResults;
        esObj.eventName = 'eventName';
        esObj.StartDate = '01/01/2006';
        esObj.endDate = '01/01/2006';
        esObj.selectedEventType = 'selectedEventType';
        esObj.eventCode = 'eventCode';
        esObj.sortOrder = 'EventName__c_ASC';
        searchResults = esObj.searchResults;
        string s = esObj.queryString();
        b = esObj.validate(); 
        esObj.sortOrder = 'EventName__c_DESC';
        s = esObj.queryString();
        b = esObj.validate(); 
        searchResults = esObj.searchResults;
        b = esObj.hasNext;
        b = esObj.hasPrevious;
        esObj.nextPage();
        esObj.prevPage();
        n = esObj.currPage;
        // esObj.changeSort();
        
        
    }

}