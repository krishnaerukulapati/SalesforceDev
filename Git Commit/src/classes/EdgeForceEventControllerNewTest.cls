/**
  * Apex Class: EdgeForceEventControllerNewTest
  * Description: Test class for EdgeForceEventControllerNew
  * Created By: Ashish Sharma (JDC)
  * Created Date: December 6th, 2013. 
*/
@isTest
private class EdgeForceEventControllerNewTest {

    static testMethod void edgeforceEventTest() {
     Event testEvent = new Event();
         testEvent.Subject = 'Test Event';
         testEvent.StartDateTime = Datetime.now();
         testEvent.EndDateTime = Datetime.now().addDays(5);
         testEvent.Event_Type__c = 'Company Event';
         //testEvent.Event_Subtype__c = 'Teleconference';
         //testEvent.Mandatory__c = true;
         //testEvent.Portal__c = 'R&D';
         insert testEvent;
         Apexpages.currentPage().getParameters().put('Portal', 'R&D');
         EdgeForceEventControllerNew controller = new EdgeForceEventControllerNew();
         
         System.assert(controller.createNewEvent() <> null);
         
         controller.fetchEvents();
         //Assert test for jsonOutput
         System.assert(controller.jsonOutput <> null);
    }
}