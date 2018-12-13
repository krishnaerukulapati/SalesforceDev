public without sharing class RecruitEventController{
    Lead led;
    public PreferredConstituentInfos__x Organizer {get; set;}
    public PreferredConstituentInfos__x Coordinator {get; set;}
    public Events__x Event {get; set;}
    public EventTypes__x et {get; set;}
    public EventNotes__x eventNotes {get; set;}
    public EventAttributeViews__x eventAttributeView {get; set;}
    public String StartDate {get; set;}
    public String EndDate {get; set;}
    public Boolean fakeEvent {get; set;}
    public Boolean fakeEventMaster {get; set;}
    public EventAttributes__x OfflineOnly {get; set;}
    public Boolean OfflineOnlyUI {get; set;}
    public EnvironmentSettings__c es;
    public EventAttributes__x Location {get; set;}
    public EventAttributes__x MaterialLang {get; set;}
    public EventAttributes__x EventTime {get; set;}
    public EventAttributes__x TypeOfEvent {get; set;}
    public String editRecruitEvent {get; set;}
    public Opportunity eventOpp {get; private set;}
    public ECCUtil.SSLeads currLead {get; private set;}
    public List<SelectOption>lstStates {get; set;}
    public List<SelectOption>lstContactTypes {get; set;}
    public List<SelectOption>lstStatuses {get; set;}
    public List<SelectOption>lstReasons {get; set;}
    public String leadId {get; private set;}
    private List<States__x> states {get; private set;}
    private List<Statuses__x> statuses {get; private set;}
    private List<Reasons__x> reasons {get; private set;}
    private List<ContactTypes__x> contactTypes {get; private set;} 
    private ContactTypes__x defaultContactType;
    @testVisible private EventTypeAttributeViews__x locationAttr;
    @testVisible private EventTypeAttributeViews__x materialLangAttr;
    @testVisible private EventTypeAttributeViews__x eventTimeAttr;
    @testVisible private EventTypeAttributeViews__x typeOfEventAttr;
    @testVisible private EventTypeAttributeViews__x offlineOnlyAttr;
    private String locationAttrName = 'event location';
    private String materialLangAttrName = 'material language';
    private String eventTimeAttrName = 'event time';
    private String typeOfEventAttrName = 'type of event:';
    private String offlineOnlyAttrName = 'offline';

    static final String prosStage = 'Staged';

    public RecruitedEvents__x recEvent{get;set;} 
    public EventConstituentRoleViews__x  roleView{get;set;}
    public String eventId {get;private set;}
    public EventConstituentRoleViews__x editOrganizer{get;set;}
    public EventConstituentRoleViews__x editCoordinator{get;set;}
 //   public EventNotes__x eventNotes{get;set;}
//    public EventAttributeViews__x eventAttributeView{get;set;}


    public RecruitEventController(){
        leadId = System.currentPageReference().getParameters().get('id');
        currLead = ECCUtil.getCurrLead(leadId);
        led = currLead.SSLead;
        Organizer = new PreferredConstituentInfos__x();
        Coordinator = new PreferredConstituentInfos__x();
        //eventAttributeView = new EventAttributeViews__x();
        fakeEvent = false;
        fakeEventMaster = false;
        recEvent = new RecruitedEvents__x ();
        event = new Events__x ();
        roleView = new EventConstituentRoleViews__x();
        editOrganizer = new  EventConstituentRoleViews__x();
        editCoordinator = new  EventConstituentRoleViews__x();
        eventNotes = new EventNotes__x();
        //eventAttributeView= new EventAttributeViews__x();

        es = [
            SELECT 
                EVMActiveStatusID__c
                , EVMCancelledStatusID__c
                , EVMCoordinatorRoleID__c
                , EVMDeletedStatusID__c
                , EVMOrganizerRoleID__c
            from
                EnvironmentSettings__c 
            where
            SetupOwnerId = :UserInfo.getOrganizationId()];
    }

    public PageReference changeCoord() {
        PageReference change = Page.C360Search;
        change.getParameters().put('leadChangeCoord', currLead.SSLead.id);
        return change;
    }

    public void init(){
        loadStates();
        loadStatuses();
        loadReasons();
        loadContactTypes();
        eventOpp = null;
        system.debug('eventOpp');
        eventOpp = ECCEventHelper.GetDIYOppFromLead(led.Id, eventOpp);      
        system.debug('eventOpp == ' + eventOpp);   
        editRecruitEvent =  System.currentPageReference().getParameters().get('editDetails');
        system.debug('editRecruitEvent == ' + editRecruitEvent); 
        eventId = System.currentPageReference().getParameters().get('eventId');
        if(editRecruitEvent == 'true'){
           // Events__x e = null;
            //Event.EventID__c = eventId;
            Set<String> eventIds = new Set<String>();
            eventIds.add(eventId);
            system.debug(' Event.EventID__c  = ' +  Event.EventID__c );
            List<Events__x> lstEvents  = new List<Events__x>();
            lstEvents = OdataExtension.GetEventById(eventIds);
            if (lstEvents.size() == 1) {
                Event = lstEvents.get(0);
                Organizer = OdataExtension.GetPreferredConstituentInfos(currLead.SSLead.ConstituentID__c);
                Coordinator = OdataExtension.GetPreferredConstituentInfos(currLead.SSLead.CoordinatorID__c);
            }
            else {
                throw new ECCUtil.ECCException('Opportunity event does not exist or there are duplicates!');
            }
        }
        else{
            Event = ECCEventHelper.GetDIYEventFromLead(led, eventOpp);
            Organizer = ECCEventHelper.GetDIYEventContactFromLead(led, es.EVMOrganizerRoleID__c, 
            eventOpp == null ? null : Event, eventOpp, currLead.SSLead.ConstituentID__c);
            Coordinator = ECCEventHelper.GetDIYEventContactFromLead(led, es.EVMCoordinatorRoleID__c, 
            eventOpp == null ? null : Event, eventOpp, currLead.SSLead.CoordinatorID__c);
        }     
        //system.debug('Event.FiscalYear__c = ' + Event.FiscalYear__c);
        if (Event == null || editRecruitEvent != 'true') {
            system.debug('defaulting event');
            defaultEvent();
        }
        else {
            system.debug('have an event: ' + Event.EventID__c);
            //get notes
            List<EventNotes__x> lstEventNotes = OdataExtension.GetEventNotesByEventID(Event.EventID__c);
          
            StartDate = String.valueOf(Event.StartDate__c);
            EndDate = String.valueOf(Event.EndDate__c);

            if(lstEventNotes.size() > 0){
                eventNotes = lstEventNotes.get(0);
            }
        }
        getEventAttributes();  
        getEventAttributeValues();
        getEventDetails();
        
        if (editRecruitEvent != 'true') {
            if(Organizer == null){
                if(coordinator.first_name__c == null){
                    Event.EventName__c = coordinator.last_name__c;
                }else if (coordinator.last_name__c == null){
                    Event.EventName__c = coordinator.first_name__c;
                }else{
                    Event.EventName__c = coordinator.first_name__c +' '+ coordinator.last_name__c;
                }
                Location.EventAttributeValue__c = coordinator.city__c +','+' '+ coordinator.state__c;
            }else {
                if(organizer.name__c == null){
                    if(organizer.first_name__c == null){
                        Event.EventName__c = organizer.last_name__c;
                    }else if(organizer.last_name__c == null){
                        Event.EventName__c = organizer.first_name__c;
                    }else {
                        Event.EventName__c = organizer.first_name__c +' '+ organizer.last_name__c;
                    }
                }else{
                    Event.EventName__c = organizer.name__c;
                }
                Location.EventAttributeValue__c = organizer.city__c +','+' '+ organizer.state__c;
            }
            EventTime.EventAttributeValue__c = '12:00 PM';
        }
    }

     private void getEventDetails(){
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
        }
    }

    @testVisible private void defaultEvent() {
        Event = new Events__x();
        et = OdataExtension.GetEventTypeById(currLead.SSLead.CurrentCampaign__r.Evaluated_EventTypeID__c);
        if (et != null) {
            system.debug('et.ActivePrefix__c: ' + et.ActivePrefix__c);
            Event.EventCode__c = et.ActivePrefix__c + 'XXXXXD17';
            PreferredConstituentInfos__x defaultAddr = Organizer != null ? Organizer : Coordinator;
            PreferredConstituentInfos__x defaultCont = Coordinator != null ? Coordinator : Organizer;

            Event.SendIncentives__c = true;

            if (defaultAddr != null) {
                Event.EventTypeID__c = et.EventTypeID__c;
                //Event.EventName__c = defaultCont.first_name__c + defaultCont.last_name__c;
                //Event.EventName__c = Organizer.first_name__c +  Organizer.last_name__c;

                Event.ShipToAddress__c = defaultAddr.address__c;
                Event.ShipToAddress2__c = defaultAddr.extra_line_1__c;
                Event.ShipToCity__c = defaultAddr.city__c;
                Event.ShipToZipCode__c = defaultAddr.zip__c;

                Event.Address__c = defaultAddr.address__c;
                Event.Address2__c = defaultAddr.extra_line_1__c;
                Event.City__c = defaultAddr.city__c;
                Event.ZipCode__c = defaultAddr.zip__c;

                Event.PreferredContactTypeID__c = defaultContactType.ContactTypeID__c;

                for(States__x thisState : states) {
                    if(thisState.StateCode__c == defaultAddr.state__c) {
                        Event.ShipToStateID__c = thisState.StateID__c;
                        Event.StateID__c = thisState.StateID__c;
                        break;
                    }
                }
            }

            if (defaultCont != null) {
                Event.ContactPhone__c = defaultCont.phone_number__c;
                Event.ContactEmail__c = defaultCont.email_address__c;
            }
        }
        else {
            throw new ECCUtil.ECCException('Cannot determine event type for this lead.  Please ensure that it is in the correct campaign');
        }
    }
    
    public LIST<SelectOption> getSurveyQuestions() {
        List<SurveyQuestionOptions__x>  optns = OdataExtension.getSurvQuestOptByQuestId(
                currLead.SSLead.CurrentCampaign__r.EvaluatedTRSurveyQuestionId__c);
        List<SelectOption> lstOptns = new List<SelectOption>();
        lstOptns.add(new SelectOption('','--Select One--'));
        if (optns != null) {
            system.debug('gotten optns count: ' + optns.size());
            for(SurveyQuestionOptions__x thisOptn : optns) {
                lstOptns.add(new SelectOption(thisOptn.OptionValue__c, thisOptn.OptionLabel__c));
            }
        }
        return lstOptns;
    }

    private void loadStates(){
        states = OdataExtension.GetStates();
        lstStates = new List<SelectOption>();
        lstStates.add(new SelectOption('','--NONE--'));
        if (states != null) {
            system.debug('gotten states count: ' + states.size());
            for(States__x thisState : states) {
                lstStates.add(new SelectOption(thisState.StateID__c, thisState.StateCode__c));
            }
        }
    }

    private void loadStatuses(){
        statuses = OdataExtension.GetStatus();
        lstStatuses = new List<SelectOption>();
        lstStatuses.add(new SelectOption('','--NONE--'));
        if (statuses != null) {
            system.debug('gotten statuses count: ' + statuses.size());
            for(Statuses__x thisStatus : statuses) {
                lstStatuses.add(new SelectOption(thisStatus.StatusID__c, thisStatus.Status1__c));
            }
        }
    }

    private void loadReasons(){
        reasons = OdataExtension.GetReasons();
        lstReasons = new List<SelectOption>();
        lstReasons.add(new SelectOption('','--NONE--'));
        if (reasons != null) {
            system.debug('gotten reasons count: ' + reasons.size());
            for(Reasons__x thisReason : reasons) {
                lstReasons.add(new SelectOption(thisReason.ReasonID__c, thisReason.Reason1__c));
            }
        }
    }
    
    private void loadContactTypes(){
        contactTypes = OdataExtension.GetContactTypes();
        lstContactTypes = new List<SelectOption>();
        lstContactTypes.add(new SelectOption('','--NONE--'));
        if (contactTypes != null) {
            system.debug('gotten states count: ' + contactTypes.size());
            for(ContactTypes__x thisCT : contactTypes) {
                if (thisCT.ContactType1__c == 'Phone') {
                    defaultContactType = thisCT;
                }
                lstContactTypes.add(new SelectOption(thisCT.ContactTypeID__c, thisCT.ContactType1__c));
            }
        }
    }

    @testVisible
    private void fetchOrganizer(){
        //Organizer = PreferredConstituentInfos__x();
    }
    
    public void cancelEvent(){
        init();
    }

    public PageReference saveEvent(){
        try{
            DateTime dtStart;
            DateTime dtEnd;
            Account acc;
            RecordType rt;
            system.debug('saveEvent!');
            //HARD CODEZ
            List<Account> accs = [select Id from Account where name = 'ALSAC Challenge'];
            List<RecordType> rts = [select Id from RecordType where DeveloperName = 'St_Jude_Challenge' and sObjectType = 'Opportunity'];
            List<Opportunity> existingOpps = [select Id from Opportunity where Event_Organizer__c = :led.Id and EventID__c != null];

             //validate start date
            if (String.isEmpty(StartDate)) {
                throw new ECCUtil.ECCException('Start Date is required.');
            }

            // validate start and end date and set fiscal year
            if(!test.isRunningTest()){
                getEventAttributes();
            }
            try {
                dtStart = ECCUtil.JavaDateStringToDate(StartDate);
                Event.StartDate__c = dtStart;
            }
            catch (Exception ex) {
                system.debug(ex.getStackTraceString());
                throw new ECCUtil.ECCException('Invalid start date.');
            }
            
            //validate end date
            if (String.isNotEmpty(EndDate)) {
                try {
                    dtEnd = ECCUtil.JavaDateStringToDate(EndDate);
                    Event.EndDate__c = dtEnd;
                }
                catch (Exception ex) {
                    system.debug(ex.getStackTraceString());
                    throw new ECCUtil.ECCException('Invalid end date.');
                }
            }

            if(dtStart.month() <= 6) {
                event.FiscalYear__c = dtStart.Year();
            }
            else {
                event.FiscalYear__c = dtStart.Year() + 1;
            }
            
            List<EventConstituentRoleViews__x> eventConsRoles = OdataExtension.getCoordEvent(Coordinator.constituent_id__c, Event.FiscalYear__c, Event.EventTypeID__c);

            system.debug('eventConsRoles = ' + eventConsRoles);
            system.debug('existingOpps = '+existingOpps);

            validate(existingOpps, accs, rts, event.EventName__c, eventConsRoles);

            acc = accs.get(0);
            rt = rts.get(0);

            EventMasters__x em;
            Map<String, String> eventTypeRoleIds = new Map<String, String>();

            //Get the correct eventtyperoleids for organizer and coordinator
            List<EventTypeRoles__x> etrs = 
                OdataExtension.GetEventTypeRolesByRoleType(es.EVMOrganizerRoleID__c, es.EVMCoordinatorRoleID__c, 
                    led.CurrentCampaign__r.Evaluated_EventTypeID__c);

            for (EventTypeRoles__x etr : etrs) {
                eventTypeRoleIds.put(etr.RoleID__r.RoleName__c, etr.EventTypeRoleID__c);
            }

            if(em == null) {
                //create the event master
                List<EventMasters__x> emExist = OdataExtension.GetEventMasterByName(event.EventName__c, fakeEventMaster);
                system.debug('emExist  '+emExist);
                em = new EventMasters__x(
                        EventTypeId__c = led.CurrentCampaign__r.Evaluated_EventTypeID__c
                        , Address__c = Event.Address__c
                        , City__c = Event.City__c
                        , ZipCode__c = Event.ZipCode__c
                        , EventMasterName__c = event.EventName__c
                        , StatusID__c = es.EVMActiveStatusID__c
                    );
                if (emExist.size() == 0) {
                    
                    //have to get it from the database to get the event master code
                    system.debug('new Event Master');
                    em.EventMasterID__c = OdataExtension.saveEventMaster('', em);
                    em = OdataExtension.GetEventMasterById(em.EventMasterID__c);
                }
                else {
                    system.debug('em.EventMasterID__c = ' + em.EventMasterID__c);
                    em = OdataExtension.GetEventMasterById(Event.EventMasterID__c);
                    em.EventMasterID__c = OdataExtension.saveEventMaster(em.EventMasterID__c, em);
                }   
            }
                                                    
            System.debug('Datatype Inserted : ' + em.EventMasterID__c);

            system.debug('set fiscal year!');
            //get fiscal year for getting the event name
            String fy = String.valueOf(event.FiscalYear__c);
            fy = fy.substring(fy.length() - 2, fy.length());
           
            system.debug('editRecruitEvent = ' + editRecruitEvent);
            Events__x newEvent = Event;
            if(editRecruitEvent != 'true'){ 
                newEvent.StatusID__c = es.EVMActiveStatusID__c;
                newEvent.StartDate__c = dtStart;
                newEvent.EndDate__c = dtEnd; 
                newEvent.EventMasterID__c = em.EventMasterID__c;
                newEvent.EventCode__c = em.EventMasterCode__c + fy;
                eventId = OdataExtension.saveEvent('', newEvent);
            }
            else{
                eventId = OdataExtension.saveEvent(Event.EventID__c, Event);
                            
            }
            
            system.debug('after save');
            // Create new Event Notes
            if (EventNotes != null && EventNotes.Notes__c != null && String.isNotBlank(EventNotes.Notes__c)) {
                EventNotes__x notes = new EventNotes__x(
                    Notes__c = EventNotes.Notes__c
                    , EventNoteID__c = EventNotes.EventNoteID__c
                    , EventID__c = eventId);
                if(String.isNotBlank(Notes.EventNoteID__c)){
                    OdataExtension.saveEventNote(EventNotes.EventNoteID__c, notes); 
                }else{
                    OdataExtension.saveEventNote('', notes); 
                }  
            }

            //Create Organizer
            if (Organizer != null && editRecruitEvent != 'true') {
                EventConstituents__x newOrg = new EventConstituents__x(
                    ConstituentID__c = led.ConstituentID__c
                    , EventID__c = eventId
                    , StatusId__c = es.EVMActiveStatusID__c);
                String orgECID = OdataExtension.saveEventConstituent('', newOrg);

                EventConstituentRoles__x organizerRole = new EventConstituentRoles__x(
                    EventConstituentID__c = orgECID
                    , EventTypeRoleID__c = eventTypeRoleIds.get('Organizer')
                    , StatusID__c = es.EVMActiveStatusID__c
                    );
                OdataExtension.saveEventConstituentRole('', organizerRole);
            }

            //Create Coordinator - it's required for challenge
            if(editRecruitEvent != 'true'){
                EventConstituents__x neewCoord = new EventConstituents__x(
                    ConstituentID__c = Coordinator.constituent_id__c
                    , EventID__c = eventId
                    , StatusID__c = es.EVMActiveStatusID__c);
                String coordECID = OdataExtension.saveEventConstituent('', neewCoord);

                EventConstituentRoles__x coordRole = new EventConstituentRoles__x(
                    EventConstituentID__c = coordECID
                    , EventTypeRoleID__c = eventTypeRoleIds.get('Coordinator')
                    , StatusID__c = es.EVMActiveStatusID__c
                    );
                OdataExtension.saveEventConstituentRole('', coordRole);
            }   

            String locationID = '' ;
            String eventTimeID = '';
            String toeID = '';
            String offlineOnlyID = '';
            String materialLangID = '' ;
            Location.EventID__c = eventId;
            MaterialLang.EventID__c = eventId;
            EventTime.EventID__c = eventId;
            TypeOfEvent.EventID__c = eventId;
            OfflineOnly.EventID__c = eventId;

           
            if(!OfflineOnlyUI){
                OfflineOnly.EventAttributeValue__c = 'N';
            }else{
                OfflineOnly.EventAttributeValue__c = 'Y';
            }

            locationID = OdataExtension.saveEventAttribute(Location.EventAttributeID__c, Location);
            materialLangID = OdataExtension.saveEventAttribute(MaterialLang.EventAttributeID__c, MaterialLang);
            eventTimeID = OdataExtension.saveEventAttribute(EventTime.EventAttributeID__c, EventTime);
            toeID = OdataExtension.saveEventAttribute(TypeOfEvent.EventAttributeID__c, TypeOfEvent);
            offlineOnlyID = OdataExtension.saveEventAttribute(OfflineOnly.EventAttributeID__c, OfflineOnly);
            system.debug('editRecruitEvent: ' + editRecruitEvent);
            if(editRecruitEvent != 'true'){
                Opportunity opp = new Opportunity(
                    EventId__c = eventId
                    , Name = newEvent.EventName__c
                    , Event_Organizer__c = led.Id
                    , AccountId = acc.Id
                    , RecordTypeId = rt.Id
                    , StageName = prosStage
                    , CloseDate = Date.Today().AddMonths(6)
                );
                 insert opp;
                 system.debug('opp done: ' + opp.Id);
            }

            PageReference detail = new PageReference('/Apex/ECCCloseSubTab');
            detail.setRedirect(true);
            system.debug(detail.getUrl());
            return detail;
            //notes.EventNoteID__c= GUID.createGuid();
            //Database.insertAsync(notes);
        }
        catch(Exception ex){
            system.debug('error message: ' + ex.getMessage());
            system.debug('stack trace: ' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        } 
    }

    public void validate(list<Opportunity> existingOpps, List<Account> accs, List<RecordType> rts, String eventName, List<EventConstituentRoleViews__x> eventConsRoles) {
        if (String.isEmpty(event.EventTypeID__c)) {
            throw new ECCUtil.ECCException('Cannot determine event type for this lead.  Please ensure that it is in the correct campaign');
        }

        if (eventConsRoles.size() > 0){
            List<String> eventIds = new List<String>();
            for(EventConstituentRoleViews__x eventConRol : eventConsRoles){
                if(eventConRol.EventID__c != Event.EventID__c){
                    eventIds.add(eventConRol.EventID__c);
                }else{
                     system.debug('eventConRol.EventID__c else = ' + eventConRol.EventID__c);
                } 
            }
            List<EventAttributeViews__x> eventOfflineViews = OdataExtension.GetEventAttributeOfflineViews(eventIds);
            system.debug('eventOfflineViews.size() ' + eventOfflineViews.size());
            system.debug('OfflineOnlyUI = ' + OfflineOnlyUI);
            if (eventOfflineViews.size() > 0 && !OfflineOnlyUI){
                throw new ECCUtil.ECCException('(Online) Event already created for this Event type, Lead and Fiscal Year.');
            }
        }
             
        if (Coordinator == null) {
            throw new ECCUtil.ECCException('Coordinator must be set.');
        }
        else if (String.isBlank(Coordinator.email_address__c) && !OfflineOnlyUI) {
            throw new ECCUtil.ECCException('Coordinator must have a preferred email address.');
        }

        //make sure the account exists
        if (accs.size() == 0) {
            throw new ECCUtil.ECCException('ALSAC account does not exist.');
        }

        //make sure the record type exists
        if (rts.size() == 0) {
            throw new ECCUtil.ECCException('Event record type does not exist.');
        }
        //validate Event name
        if(String.isEmpty(eventName)){
            throw new ECCUtil.ECCException('Event Name is required.');
        }

        if (String.isBlank(Location.EventAttributeValue__c)) {
            throw new ECCUtil.ECCException('Location is required.');
        }

        if (String.isBlank(EventTime.EventAttributeValue__c)) {
            throw new ECCUtil.ECCException('Event Time is required.');
        }

        if (String.isBlank(TypeOfEvent.EventAttributeValue__c)) {
            throw new ECCUtil.ECCException('Type of Event is required.');
        }

        system.debug('Event.StatusID__c = ' + Event.StatusID__c);

        List<Statuses__x> stats = OdataExtension.GetStatus(Event.StatusID__c);
        Boolean cancelled = false;
        if (stats.size() > 0) {
            Statuses__x stat = stats[0];
            if (stat.Status1__c.toLowerCase() == 'cancelled') {
                cancelled = true;
            }
        }

        if (!cancelled && String.isNotBlank(Event.ReasonID__c)) {
            throw new ECCUtil.ECCException('Cancellation Reason is only allowed when Status is cancelled'); 
        }
        else if (cancelled && String.isBlank(Event.ReasonID__c)) {
            throw new ECCUtil.ECCException('Cancellation Reason is required when Status is cancelled'); 
        }

        //CONMG-152,Required parts of address on other parts.
        
        if (String.isNotBlank(Event.ShipToAddress__c) || String.isNotBlank(Event.ShipToStateID__c)
                || String.isNotBlank(Event.ShipToCity__c) || String.isNotBlank(Event.ShipToZipCode__c)) {
            if (String.isBlank(Event.ShipToAddress__c) || String.isBlank(Event.ShipToStateID__c)
                || String.isBlank(Event.ShipToCity__c) || String.isBlank(Event.ShipToZipCode__c)) {
                throw new ECCUtil.ECCException('Shipping Address, City, State and Zip are required if Address, City, State or Zip are entered.');
            }
        }
        if (String.isNotBlank(Event.Address__c) || String.isNotBlank(Event.StateID__c)
                || String.isNotBlank(Event.City__c) || String.isNotBlank(Event.ZipCode__c)) {
            if (String.isBlank(Event.Address__c) || String.isBlank(Event.StateID__c)
                || String.isBlank(Event.City__c) || String.isBlank(Event.ZipCode__c)) {
                throw new ECCUtil.ECCException('Event Address, City, State and Zip are required if Address, City, State or Zip are entered.');
            }
        }
        if(Event.SendKit__c || Event.SendIncentives__c){
            if (String.isBlank(Event.ShipToAddress__c) || String.isBlank(Event.ShipToStateID__c)
                || String.isBlank(Event.ShipToCity__c) || String.isBlank(Event.ShipToZipCode__c)) {
                throw new ECCUtil.ECCException('Shipping Address is required if Send Kit or Incentives are checked.');
            }
        }
        //see if this event already exists (if not edit mode)
        List<Events__x> evExist = OdataExtension.GetEventByName(eventName, fakeEvent);
                  
        if (evExist.size() > 0 && editRecruitEvent != 'true') {
            throw new ECCUtil.ECCException('Event \'' + eventName + '\' already exists.');
        }
    }

    @testVisible private void getEventAttributes() {
        List<EventTypeAttributeViews__x> etavs = OdataExtension.GetEventTypeAttributeViews(event.EventTypeID__c);
        for(EventTypeAttributeViews__x etav : etavs) {
            if (etav.AttributeName__c.toLowerCase() == locationAttrName) {
                locationAttr = etav;
            }
            else if (etav.AttributeName__c.toLowerCase() == materialLangAttrName) {
                materialLangAttr = etav;
            }
            else if(etav.AttributeName__c.toLowerCase() == eventTimeAttrName) {
                eventTimeAttr = etav;
            }
            else if(etav.AttributeName__c.toLowerCase() == typeOfEventAttrName) {
                typeOfEventAttr = etav;
            }
            else if (etav.AttributeName__c.toLowerCase() == offlineOnlyAttrName) {
                offlineOnlyAttr = etav;
            }
        }
        if (locationAttr == null) {
            throw new ECCUtil.ECCException('Could not find \'' + locationAttrName + '\' Event Attribute.');
        }
        if (eventTimeAttr == null) {
            throw new ECCUtil.ECCException('Could not find \'' + eventTimeAttrName + '\' Event Attribute.');
        }
        if (typeOfEventAttr == null) {
            throw new ECCUtil.ECCException('Could not find \'' + typeOfEventAttrName + '\' Event Attribute.');
        }
    }

    private void getEventAttributeValues() {
        //this will call new methnod OdataExtension.GetEventAttributesByEvIDETAIDs(event id, )
        List<String> typeAttrIds = new List<String>();
        system.debug('locationAttr =' + locationAttr);

        if (locationAttr != null) {
            typeAttrIds.add(locationAttr.EventTypeAttributeID__c);
        }

        if (materialLangAttr != null) {
            typeAttrIds.add(MaterialLangAttr.EventTypeAttributeID__c);
        }

        if (eventTimeAttr != null) {
            typeAttrIds.add(EventTimeAttr.EventTypeAttributeID__c);
        }

        if (typeOfEventAttr != null) {
            typeAttrIds.add(TypeOfEventAttr.EventTypeAttributeID__c);
        }

         if (offlineOnlyAttr != null) {
            typeAttrIds.add(OfflineOnlyAttr.EventTypeAttributeID__c);
        }

        List<EventAttributes__x> eavs = OdataExtension.GetEventAttributesByEvIDETAIDs(Event.EventID__c, 
            typeAttrIds);
     
     //   List<EventAttributes__x> eas  = OdataExtension.GetEventAttributesByEvIDETAIDs(eventId, eavs.EventTypeAttributeID__c);


        for(EventAttributes__x eav : eavs) {
            system.debug('in for loop attribute values');
            //rename 'Name' variable to ETAId variable and get the eventattribute based on the eventtypeattributeid
            if (eav.EventTypeAttributeID__c.toLowerCase() == locationAttr.EventTypeAttributeID__c.toLowerCase()) {
                Location = eav;
            }
            else if (eav.EventTypeAttributeID__c.toLowerCase() == materialLangAttr.EventTypeAttributeID__c.toLowerCase()) {
                MaterialLang = eav;
            }
            else if (eav.EventTypeAttributeID__c.toLowerCase() == eventTimeAttr.EventTypeAttributeID__c.toLowerCase()) {
                EventTime = eav;
            }
            else if (eav.EventTypeAttributeID__c.toLowerCase() == typeOfEventAttr.EventTypeAttributeID__c.toLowerCase()) {
                TypeOfEvent = eav;
            }
            else if (eav.EventTypeAttributeID__c.toLowerCase() == offlineOnlyAttr.EventTypeAttributeID__c.toLowerCase()) {
                OfflineOnly = eav;
                if (eav.EventAttributeValue__c == 'N') {
                    OfflineOnlyUI = false;
                }
                else {
                    OfflineOnlyUI = true;
                }
            }
        }
 
        //Create Event Location - it's required for challenge
        if (Location == null) {
            Location = new EventAttributes__x(
            EventID__c = eventId
            , EventTypeAttributeID__c = locationAttr.EventTypeAttributeID__c);
            system.debug('Location = ' + Location);
        }
         if (MaterialLang == null) {
            MaterialLang = new EventAttributes__x(
            EventID__c = eventId
            , EventTypeAttributeID__c = materialLangAttr.EventTypeAttributeID__c);
            system.debug('MaterialLang = ' + MaterialLang);
        }
        //Create Event Time - it's required for challenge
        if (EventTime == null) {
            EventTime = new EventAttributes__x(
            EventID__c = eventId
            , EventTypeAttributeID__c = eventTimeAttr.EventTypeAttributeID__c);
        }
        //Create Event Type - it's required for challenge
        if (TypeOfEvent == null) {
            TypeOfEvent = new EventAttributes__x(
            EventID__c = eventId
            , EventTypeAttributeID__c = typeOfEventAttr.EventTypeAttributeID__c);
        }
        //Create Offline only  - it's required for challenge when email for coordinator is null
        if (OfflineOnlyUI == null) {
            OfflineOnly = new EventAttributes__x(
            EventID__c = eventId
            , EventTypeAttributeID__c = offlineOnlyAttr.EventTypeAttributeID__c);   
            system.debug('OfflineOnly = ' + OfflineOnly);
        }
    }
}