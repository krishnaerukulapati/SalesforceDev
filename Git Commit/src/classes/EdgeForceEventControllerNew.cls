//
// (c) 2014 Appirio, Inc.
//
// <Summary of the requirements that we have received in the task/story>
//
// <Created Date>   <Created By>    Original (Ref. <Task No.>)
// Modified: 23 Sept, 2014 Sumit tanwar Added new where clause in Event query Edgeforce_Calendar_Event_Type__c in ('ALSAC Event','Divisional Event','Field Event')
// Task T-321188
//

public class EdgeForceEventControllerNew {
    public List<EventWrapper> listOfEvent{get; set;}
    public String jsonOutput{get; set;} 
    public Event event{get ; set;} 
    public boolean isSearch{get ; set ;}
    public String portal{get ; set ;}
    
    public EdgeForceEventControllerNew(){
        listOfEvent = new List<EventWrapper>();
        event = new Event();
        isSearch = false;
        portal = Apexpages.currentPage().getParameters().get('Portal');
        // updated by Sumit tanwar Ref T-321188
        for(Event ev : [SELECT ID, Subject, StartDateTime, EndDateTime, IsAllDayEvent
                        FROM Event where Edgeforce_Calendar_Event_Type__c in ('ALSAC Event','Divisional Event','Field Event')]){
            listOfEvent.add(new EventWrapper(ev, portal));                  
        }
        
        jsonOutput = Json.serialize(listOfEvent);
    }
    
    public void fetchEvents(){
    	  //Commented by Sumit tanwar Ref T-321188
        //String query = 'Select ID, Subject, StartDateTime, EndDateTime, IsAllDayEvent FROM Event Where Edgeforce_Calendar_Event_Type__c in (\'ALSAC Event\','Divisional Event','Field Event')';
        
        listOfEvent =  new List<EventWrapper>();
        // updated by Sumit tanwar Ref T-321188
        for(Event ev : [SELECT ID, Subject, StartDateTime, EndDateTime, IsAllDayEvent
                        FROM Event where Edgeforce_Calendar_Event_Type__c in ('ALSAC Event','Divisional Event','Field Event')]){
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
        public long allDayStartDate{get; set;}
        public long allDayEndDate{get; set;}
        public String title{get; set;}
        public String description{get; set;}
        public String url{get; set;}
        public boolean allDay{get; set;}
        
        
        public EventWrapper(Event ev, String portalName){
            title = ev.Subject;
            
            TimeZone customerTimeZone = UserInfo.getTimeZone();
            
            if(ev.IsAllDayEvent){
                allDayStartDate = ev.StartDateTime.getTime() + customerTimeZone.getOffset(ev.StartDateTime); //ev.StartDateTime.format('yyyy-MM-dd');
               allDayEndDate = ev.EndDateTime.getTime() + customerTimeZone.getOffset(ev.StartDateTime); //.format('yyyy-MM-dd');
            }else{
                startDate = ev.StartDateTime.format('MMMM d, yyyy HH:mm');
                endDate = ev.EndDateTime.format('MMMM d, yyyy HH:mm');
            }
            
            
            url = '/apex/ef_eventDetail?id=' + ev.Id;
            description='';
            allDay = ev.IsAllDayEvent; 
        }
    }
}