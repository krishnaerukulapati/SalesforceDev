/**
  * Apex Class: EdgeForceIntranetEventDetailsControllerTest
  * Description: Test class for EdgeForceIntranetEventDetailsController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: October 23rd, 2013.
  */
@isTest
private class EdgeforceEventDetailsControllerTest {
    static testMethod void eventDetailTest() {
        // TO DO: implement unit test
        Event recEvent = new Event();
        recEvent.Subject = 'Test Recurring Event';
        recEvent.StartDateTime = Datetime.now();
        recEvent.EndDateTime = Datetime.now().addDays(1);
        recEvent.RecurrenceStartDateTime = Datetime.now();
        recEvent.RecurrenceEndDateOnly = Date.today().addDays(30);
        recEvent.RecurrenceDayOfWeekMask = 2;
        recEvent.RecurrenceType = 'RecursWeekly';
        recEvent.RecurrenceInterval = 2;
        recEvent.IsRecurrence = true;
        insert recEvent;
        
        Apexpages.currentPage().getParameters().put('id', recEvent.Id);
        Apexpages.currentPage().getParameters().put('Portal', 'R&D');
        EdgeForceEventDetailsController controller = new EdgeForceEventDetailsController();
        
        EdgeForceEventDetailsController edController = new EdgeForceEventDetailsController();
        
        edController.getEvent();
        
        edController.edit();
        
        Apexpages.currentPage().getParameters().put('id', recEvent.id);
        edController.deleteEvent();
        
        //Assert test for events size
       // System.assert(controller.ev <> null);
        
        //Assert test for edit
       // System.assert(controller.edit() <> null);
    }
}