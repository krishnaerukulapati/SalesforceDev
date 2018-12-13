/**
  * Apex Class: IntranetEventCalendarController
  * Description: T-201225 : Intranet - Create new Calendar Visualforce page
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: October 18th, 2013.
  */
public class EdgeForceEventCalendarController {
    public List<EventWrapper> listOfEvent{get; set;}
    public String jsonOutput{get; set;} 
    public Event event{get ; set;} 
    public boolean isSearch{get ; set ;}
    public String portal{get; set;}
    
    public EdgeForceEventCalendarController(){
        listOfEvent = new List<EventWrapper>();
        event = new Event();
        isSearch = false;
        if(ApexPages.currentPage().getParameters().get('Portal') != null) {
                portal = ApexPages.currentPage().getParameters().get('Portal');
        }
        
        for(Event ev : [SELECT ID, Subject, StartDateTime, EndDateTime,Event_Type__c, IsAllDayEvent
                        FROM Event
                       
                       ]){
            if(portal == null )
            portal = '';            
            listOfEvent.add(new EventWrapper(ev, portal));                  
        }
        
        jsonOutput = Json.serialize(listOfEvent);
    }
    
    public void fetchEvents(){
        String query = 'Select ID, Subject,StartDateTime, EndDateTime, IsAllDayEvent,Event_Type__c FROM Event ';
       // query += ' WHERE (Portal__c = null OR Portal__c =: portal) ';
       
       if((event.Event_Type__c != null && event.Event_Type__c != '')){
          //  || (event.Event_Subtype__c != null && event.Event_Subtype__c != '')
        //    || event.Mandatory__c){
          //  query += ' AND ';
            
            if(event.Event_Type__c != null && event.Event_Type__c != ''){
                query += 'WHERE Event_Type__c = \''+ event.Event_Type__c +'\'';
               // if(event.Event_Subtype__c != null && event.Event_Subtype__c != ''){
                   // query += 'AND ';
               // }
            }
            
           /* if(event.Event_Subtype__c != null && event.Event_Subtype__c != ''){
                query += 'Event_Subtype__c = \'' + event.Event_Subtype__c + '\'';
                if(event.Mandatory__c){
                    query += 'AND ';
                }
            }
            
            if(event.Mandatory__c){
                query += 'Mandatory__c = true';
            }*/
        }
        
        listOfEvent =  new List<EventWrapper>();
        for(Event ev : Database.query(query)){
            listOfEvent.add(new EventWrapper(ev, portal));
        }
        
        jsonOutput = Json.serialize(listOfEvent);
        isSearch = true;
    }
    
    public Pagereference createNewEvent(){
        return new Pagereference('/apex/EdgeForceCreateEvent');
    }
    
    public class EventWrapper{
        public String startDate{get; set;}
        public String endDate{get; set;}
        public String title{get; set;}
        public String url{get; set;}
        public boolean allDay{get; set;}
        public String backgroundColor{get; set;}
        public String borderColor{get; set;}
        public String textColor{get; set;}
        
        public EventWrapper(Event ev, String portal){
            title = ev.Subject;
            if(ev.IsAllDayEvent){
                DateTime startDt = DateTime.valueOf(ev.StartDateTime +' 00:00:00');
                startDate = startDt.format('MM/dd/yyyy'); 
                
                DateTime endDt = DateTime.valueOf(ev.EndDateTime +' 00:00:00');
                endDate = endDt.format('MM/dd/yyyy');
            }else{
                startDate = ev.StartDateTime.format('yyyy-MM-dd HH:mm:ss');
                endDate = ev.EndDateTime.format('yyyy-MM-dd HH:mm:ss');
            }
            
            url = '/apex/EF_EventDetail?id=' + ev.Id ;
            allDay = ev.IsAllDayEvent; 
         if(ev.Event_Type__c == 'Trade Association Meeting'){
                backgroundColor = 'Red';
            }else if(ev.Event_Type__c == 'Health Authority Meeting - Product'){
                backgroundColor = 'Green';
            }else if(ev.Event_Type__c == 'Health Authority Meeting - General'){
                backgroundColor = 'Green';
            }else if(ev.Event_Type__c == 'Training - Internal'){
                backgroundColor = 'Yellow';
                textColor = 'black';
            }else if(ev.Event_Type__c == 'Training - External'){
                backgroundColor = 'Yellow';
                textColor = 'black';
            }else if(ev.Event_Type__c == 'Conference/Workshop'){
                backgroundColor = 'Purple';
            }else if(ev.Event_Type__c == 'Team Meeting'){
                backgroundColor = 'Orange';
            }
            
            borderColor = 'black';
        }
    }
}