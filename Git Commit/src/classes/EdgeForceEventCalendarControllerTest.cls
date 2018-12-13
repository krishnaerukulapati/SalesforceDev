/**
  * Apex Class: EdgeForceEventCalendarControllerTest
  * Description: Test Class for EdgeForceEventCalendarController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: October 21stth, 2013.
  */
@isTest
private class EdgeForceEventCalendarControllerTest {

    static testMethod void eventCalendarTest() {
       Event testEvent = new Event();
         testEvent.Subject = 'Test Event';
         testEvent.StartDateTime = Datetime.now();
         testEvent.EndDateTime = Datetime.now().addDays(5);
         insert testEvent;
         
         Apexpages.currentPage().getParameters().put('Portal', 'R&D');
         EdgeForceEventCalendarController controller = new EdgeForceEventCalendarController();
         
         //Assert test for jsonOutput
         System.assert(controller.jsonOutput <> null);
         
         controller.fetchEvents();
         //Assert test for jsonOutput
         System.assert(controller.jsonOutput <> null);
         
         //Assert test for createNewEvent
         System.assert(controller.createNewEvent() <> null);
    }
}