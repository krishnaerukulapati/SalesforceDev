/**
  * Apex Class: IntranetEventDetailsController
  * Description: Controller for IntranetEventDetail and IntranetCalendarEventDetail page
  * Created By: Ashish Sharma (Appirio Off)
  * Modified Date: October 23rd, 2013.
  */
public without sharing class EdgeForceEventDetailsController {
    public Event ev;
    public Event recEvent{get; set;}
    public boolean hasParent {get ; set ;}
    public String portal{get ; set ;}
    public String startDate { get; set; }
    public String endDate { get; set; }
    public EdgeForceEventDetailsController() {
      try{
        if(ApexPages.currentPage().getParameters().get('Portal') != null) {
                portal = ApexPages.currentPage().getParameters().get('Portal');
        }
        String evId = ApexPages.currentPage().getParameters().get('id');
        ev = new Event();
        recEvent = new Event();
        
        ev = [SELECT Id,Subject,IsAllDayEvent,StartDateTime,EndDateTime,
              URL__c,Type,Location,Description,
              Event_Type__c, RecurrenceActivityId,
              OwnerId FROM Event WHERE Id = :evId];  

        DateTime startDt = DateTime.valueOf(ev.StartDateTime +' 00:00:00');
        startDate = startDt.format('MM/dd/yyyy'); 
        
        DateTime endDt = DateTime.valueOf(ev.EndDateTime +' 00:00:00');
        endDate = endDt.format('MM/dd/yyyy');
        
       //Fecth parent event record if Event is Recurring Event
       if(ev.RecurrenceActivityId != null) {
         hasParent = true;
         for(Event tempEvent : [SELECT Id,
                                (SELECT StartDateTime,EndDateTime FROM
                                RecurringEvents WHERE StartDateTime >= : Datetime.now()
                                order by StartDateTime) FROM Event
                                WHERE ID =: ev.RecurrenceActivityId]){
             recEvent = tempEvent;
         }
       }  
      }catch(Exception e){
        System.debug('ERROR :: ' + e.getMessage());
      }
    }
    
    public Event getEvent() {
        return ev;
    }
    
    public Pagereference edit(){
        return new Pagereference('/apex/EdgeForceCalendarEventEdit?Id=' + ev.Id );
    }
    
    public PageReference deleteEvent(){
        Event currentEvent = [select id from Event where id=:ApexPages.currentPage().getParameters().get('id')];
        delete currentEvent;
        return new PageReference('apex/IntranetEventCalendarRD?name=Calendar&tabName=Calendar&Portal='+ Encodingutil.urlEncode(portal, 'UTF-8'));
    }
}