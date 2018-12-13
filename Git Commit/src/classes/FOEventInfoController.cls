public class FOEventInfoController{ 
    public Events__x event {get;set;}
    //public RecruitedEvents__x recEvent{get;set;} 
    public EventConstituentRoleViews__x  roleView{get;set;}
    String eventId = '';
    public EventConstituentRoleViews__x organizer{get;set;}
    public EventConstituentRoleViews__x Coordinator{get;set;}
    public EventNotes__x eventNotes{get;set;}
    public EventAttributeViews__x eventAttributeView{get;set;}
    
    
    public FOEventInfoController(){
        eventId = ApexPages.currentPage().getParameters().get('eventId');
        System.debug('EventInfoController eventid =  ' + eventId);
        //recEvent = new RecruitedEvents__x ();
        event = new Events__x ();
        roleView = new EventConstituentRoleViews__x();
        organizer = new  EventConstituentRoleViews__x();
        coordinator = new  EventConstituentRoleViews__x();
        eventNotes = new EventNotes__x();
        eventAttributeView= new EventAttributeViews__x();
    }
    
    public void init(){
        fetchEventDetails();
    }
    
   public static Map<String, RecruitedEvents__x> fetchEventCodeRecruitedEvents(Set<String> setEventCodes){
        Map<String, RecruitedEvents__x> mapEventCodeWithRecruitedEvents = new Map<String, RecruitedEvents__x>();
        List<RecruitedEvents__x> lstRecruitedEvents = new List<RecruitedEvents__x>();

        if (setEventCodes.size() > 0) {
            lstRecruitedEvents = OdataExtension.GetRecruitedEvents(setEventCodes);
            for(RecruitedEvents__x recEvent :lstRecruitedEvents){
                mapEventCodeWithRecruitedEvents.put(recEvent.SOURCECODE__c, recEvent);
            }
        }

        return mapEventCodeWithRecruitedEvents;
    }

    public string getTotalRevenue(){
        if (event != null) {
            EventRevenues__x evtRev = OdataExtension.GetEventRevenueById(event.EventID__c);
            if (evtRev != null && evtRev.Amount__c != null)
                return '$' + String.ValueOf(evtRev.Amount__c.setScale(2));
        }

        return '$0.00';
    }

    private void fetchEventDetails(){
        // Fetching Events
        List<Events__x> lstEvents = new list<Events__x >();
        lstEvents = OdataExtension.GetEventById(new set<string>{eventId});
        if(lstEvents.size()>0){
            Set<String>setEventIds = new Set<String>();
            setEventIds.add(lstEvents[0].EventID__c);
            Set<String>setEventCodes = new Set<String>();
            if(lstEvents[0].EventCode__c != NULL)
                setEventCodes.add(lstEvents[0].EventCode__c);
            
            //Material Language: Will now be a attribute for that event, from EventAttributeViews__x get the 
            //EventAttributeValue__c where we have the matching EventID__c and AttributeName__c = 'Material Language'
            List<EventAttributeViews__x> lstEventAttributeViews = new list<EventAttributeViews__x>(); 
            lstEventAttributeViews = OdataExtension.GetEventAttributeViews(lstEvents[0].EventID__c);
            if(lstEventAttributeViews.size()>0){
                eventAttributeView = lstEventAttributeViews[0];
            } 
            // Fetching Event Coordinator
            Map<String,EventConstituentRoleViews__x> mapEventIdWithCoordinator = new Map<String,EventConstituentRoleViews__x>();
            if(setEventIds.size()>0){
                mapEventIdWithCoordinator = ECCEventHelper.fetchEventCoordinator(setEventIds);
            }
            
            // Fetching Event Organizer
            Map<String,EventConstituentRoleViews__x> mapEventIdWithOrganizer = new Map<String,EventConstituentRoleViews__x>();
            if(setEventIds.size()>0){
                mapEventIdWithOrganizer = ECCEventHelper.fetchEventOrganizer(setEventIds);
            }
            event = lstEvents[0];
            
            // Fetching Event Notes
            List<EventNotes__x> lstEventNotes = new list<EventNotes__x>(); 
            lstEventNotes = OdataExtension.GetEventNotesByEventID(event.EventID__c);
            if(lstEventNotes.size()>0)
                EventNotes = lstEventNotes[0];
                
            //// Fetching Event RecruitedEvents
            //Map<String,RecruitedEvents__x>mapEventCodeWithRecruitedEvents = new Map<String,RecruitedEvents__x>();
            //if(setEventCodes.size()>0)
            //    mapEventCodeWithRecruitedEvents  = fetchEventCodeRecruitedEvents(setEventCodes);
                
                
            //if(event.EventCode__c != NULL  && mapEventCodeWithRecruitedEvents.containsKey(event.EventCode__c))
            //    recEvent = mapEventCodeWithRecruitedEvents.get(event.EventCode__c);
            if(mapEventIdWithCoordinator.containsKey(event.EventID__c))
                Coordinator = mapEventIdWithCoordinator.get(event.EventID__c);
            if(mapEventIdWithOrganizer.containsKey(event.EventID__c))
                organizer = mapEventIdWithOrganizer.get(event.EventID__c);
            
        }
    }
     
}