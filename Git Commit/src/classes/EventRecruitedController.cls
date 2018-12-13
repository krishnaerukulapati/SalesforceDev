public with sharing class EventRecruitedController {
    public String eventId { get; set; }
    public String leadId { get; set; }
    public EventHighlights__x highlights { get; private set; }
    public Lead eventLead { get; set; }
    public String accId { get; set; }
    public Campaign eventCamp { get; set; }
    public RecordType rtOpp { get; set; }
    public RecordType rtLead { get; set; }
    public ECCUtil.SSLeads currLead { get; set; }
    public PreferredConstituentInfos__x pci { get; set; }
    public PreferredConstituentInfos__x pcc {get; set; }
    public Contact con {get;set;}
    public Opportunity opp {get;set;}
    static final String prosStage = 'Staged';

    public EventRecruitedController() {
        eventId = System.currentPageReference().getParameters().get('eventId');
        leadId = System.currentPageReference().getParameters().get('id');
        currLead = ECCUtil.getCurrLead(leadID);
        
        system.debug('currLead: ' + currLead);
        //system.debug('currLead.SSLead.CurrentCampaign__r.EventTypeID__c: ' + currLead.SSLead.CurrentCampaign__r.EventTypeID__c);
        system.debug('recruit - eventId: ' + eventId);
    }

    public PageReference recruit() {
        try {
            List<Opportunity> os = [select id from Opportunity where EventId__c = :eventId];

            if (os.size() > 0) {
                //this event already exists in salesforce!
                throw new ECCUtil.ECCException('This event has already been recruited.');
            }
            Boolean hasPartnership = false;

            //get partnership value from lead if exists
            if(currLead != null) {
                if(currLead.SSLead != null) {
                    if(currLead.SSLead.Partnership_Name__c != null) {
                        hasPartnership = true;
                    }
                }
            }
            if (Test.isRunningTest()) {
             highlights =new EventHighlights__x(EventID__c = 'notaguid', FiscalYear__c=2018, OrganizerId__c='orgid',EventTypeID__c='tfhgggygyg-hbhbhjhjh', CoordinatorId__c='corid',StartDate__c=System.Now(), EventName__c='some event');
            }
            else{            
              highlights = OdataExtension.GetEventHighLightsById(eventId);
            }
            if (highlights == null) {
                throw new ECCUtil.ECCException('Event not found for id=' + eventId);
            }
            String evmFiscalYear = String.valueOf(highlights.FiscalYear__c);
            System.debug('String.valueOf(highlights.FiscalYear__c) : ' + evmFiscalYear);

            //get PCI Info for Organizer
            pci = OdataExtension.GetPreferredConstituentInfos(highlights.OrganizerId__c);
            
            //get PCI Info for Coordinator
             if (Test.isRunningTest()) {
                pcc =new PreferredConstituentInfos__x(
                        name__c = 'Name'
                        , last_name__c = 'Last'
                        , first_name__c = 'First'
                        , address__c = '501 St Jude Pl'
                        , extra_line_1__c = '' 
                        , extra_line_2__c = '' 
                        , addressType__c = 'Home' 
                        , phone_number__c = '9015551234'
                        , email_address__c = 'test@test.com'
                        , city__c = 'Memphis'
                        , state__c = Guid.createGuid()
                        , country__c = Guid.createGuid()
                        , zip__c = '38117'
                        , constituent_id__c = null
                    );
            }
            else{
                pcc = OdataExtension.GetPreferredConstituentInfos(highlights.CoordinatorId__c);
            }
            //get the support parent campaign associated with the event type of the event that was just created
            //system.debug('ecrvOrg.EventTypeId__c: ' + ecrvOrg.EventTypeId__c);
            List<Campaign> camps = new List<Campaign>();

            if(highlights.EventTypeID__c.ToUpperCase() == 'B1C0820D-04D0-458D-9B7B-4F0C1CFE9F56') {
                camps = [                    
                    select id, Name, OppRecordType__c, LeadRecType__c, OppAcc__c, EventTypeID__c
                    from Campaign
                    where EventTypeIdUpper__c = :highlights.EventTypeID__c.ToUpperCase()
                    and IsSupportParent__c = true
                    and Has_Partnership__c = :hasPartnership
                    and Fiscal_Year__c = :evmFiscalYear
                ];
            }
            else {
                camps = [
                    select id, Name, OppRecordType__c, LeadRecType__c, OppAcc__c, EventTypeID__c
                    from Campaign
                    where EventTypeIdUpper__c = :highlights.EventTypeID__c.ToUpperCase()
                    and IsSupportParent__c = true
                    and Fiscal_Year__c = :evmFiscalYear
                ];
            }
            if (camps.size() != 1) {
                //if there are too few or too many, we don't know which one to choose. throw an error
                throw new ECCUtil.ECCException('There are ' + camps.size() + ' campaigns for event type ' + highlights.EventTypeID__c);
            }

            //should only be one. let's get it.
            eventCamp = camps[0];

            accId = eventCamp.OppAcc__c;

            List<RecordType> rts = [select Id from RecordType where DeveloperName = :eventCamp.OppRecordType__c and sObjectType = 'Opportunity'];

            if (rts.size() != 1) {
                throw new ECCUtil.ECCException('There are ' + rts.size() + ' record types for opp record type ' + eventCamp.OppRecordType__c);
            }
            if (String.isBlank(accId)) {
                throw new ECCUtil.ECCException('Opportunity Account not set on Support Campaign ' + eventCamp.Name + '.');
            }

            rtOpp = rts.get(0);

            rts = [select Id from RecordType where DeveloperName = :eventCamp.LeadRecType__c and sObjectType = 'Lead'];

            if (rts.size() != 1) {
                throw new ECCUtil.ECCException('There are ' + rts.size() + ' record types for lead record type ' + eventCamp.OppRecordType__c);
            }

            rtLead = rts.get(0);

            system.debug('highlights.EventTypeId__c.ToUpperCase() = ' + highlights.EventTypeId__c.ToUpperCase());
            system.debug('highlights.OrganizerId__c = ' + highlights.OrganizerId__c);

            //get event types
            String leadET = '';
            String highlightET = '';

            //get current lead's campaign event type
            if(currLead != null || Test.isRunningTest()) {
                if(currLead.SSLead != null) {
                    if(currLead.SSLead.CurrentCampaign__r != null) {
                        if(currLead.SSLead.CurrentCampaign__r.EventTypeID__c != null) {
                            leadET = currLead.SSLead.CurrentCampaign__r.EventTypeID__c.ToUpperCase();
                        }
                    }
                }
            }

            //get the highlights event type
            if(highlights != null ) {
                if(highlights.EventTypeID__c != null) {
                    highlightET = highlights.EventTypeId__c.ToUpperCase();
                }
            }

            List<CampaignMember> cms = new List<CampaignMember>();

            //this will get the campaign members from recruitment campaigns and move them to
            //the support campaign for the event type that's been recruited
            if(leadET != '' && leadET != null ) {
                cms = [SELECT Id, LeadId, CampaignId FROM CampaignMember WHERE CampaignId IN(select id from Campaign where (EventTypeIdUpper__c In(:leadET, :highlightET) and isRecruited__c = true) or (id = :currLead.SSLead.CurrentCampaign__r.Id and IsSupportParent__c = false)) AND Lead.ConstituentId__c = :highlights.OrganizerId__c];
            }
            else {
                cms = [SELECT Id, LeadId, CampaignId FROM CampaignMember WHERE CampaignId IN(select id from Campaign where (EventTypeIdUpper__c In(:highlightET) and isRecruited__c = true) or (id = :currLead.SSLead.CurrentCampaign__r.Id and IsSupportParent__c = false)) AND Lead.ConstituentId__c = :highlights.OrganizerId__c];
            }
            

            system.debug('cms.size(): ' + cms.size());

            if (cms.size() > 0) {
                //we found a lead!
                system.debug('existing lead');
                //eventLead = [select id, CoordinatorID__c, Recruited_Date__c, Event_Status__c from lead where id = :cms.get(0).LeadId];
                //if (highlights.CoordinatorId__c != null) {
                    //eventLead.CoordinatorID__c = highlights.CoordinatorId__c;
                //}
                delete cms;

                //system.debug('eventCamp.Id = ' + eventCamp.Id);
                //eventLead.CurrentCampaign__c = eventCamp.Id;
                //eventLead.XREF__c = eventId + '|' + eventLead.CoordinatorID__c;
                //eventLead.Recruited_Date__c = highlights.StartDate__c.date();
                //eventLead.Event_Status__c = highlights.Status__c;
                //update eventLead;
            }
            //prosStage = 'Staged';
            
             system.debug('move lead');
            eventLead = MoveLead();
            List<Contact> conlist=[SELECT Id,AccountId,Lead_Name__c FROM Contact WHERE Lead_Name__c=:eventLead.Id];
            if(conlist==null){
            con=CreateContact(eventLead,pcc,highlights,accId);
            }
            else{
                con=conlist.get(0);
            }
            system.debug('recruit - eventId: ' + eventId);
            opp=CreateOpp(eventId,con.Id,eventLead,pcc,highlights,eventCamp,accId,rtOpp);
            CreateOpportunityContact(con,opp);
        }
        catch(Exception ex) {
            //something went wrong, show the exception
            system.debug('error message: ' + ex.getMessage());
            system.debug('stack trace: ' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }

        //return null;
        //Redirect to EventMastering view with eventid guid
       /* String retURL = CustomSettings__c.getValues('EventsRecruitment').Value__c;
        System.debug('The Return URL: ' + retURL);
        retURL = retURL + 'Recruitment/View/' + eventId;
        System.debug('The Completed URL: ' + retURL);
        PageReference eventView = new PageReference(retURL);
        eventView.setRedirect(true);
        return eventView;*/
         return new pagereference('/'+con.id);
        
    }
 public PageReference updateEvent() {
        try {
            System.debug('Event Id: ' + eventId);
            List<Events__x> evntlist=new List<Events__x>();
            //This code is added by for updating the related Opportunity based on Event updated info. code starts
            if(Test.isRunningTest()){
                evntlist.add(new Events__x(
                            DateInserted__c=System.Now(),
            EventDescription__c='event description',
            EventID__c='80b6a5e9-9854-418e-876f-002a1203c596',
            FiscalYear__c=2018,
            ShipToAddress__c='200 North Gray St.',
            ShipToAddress2__c='test ship adddrss2',
            ShipToCity__c='Stanton',
            ShipToZipCode__c='79782',
            ShipToStateID__c='TX',
            ContactAddress__c='con test addrs',
            ContactAddress2__c='con test addrs',
            ContactCity__c='test city',
            DateUpdated__c=System.Now(),
            EndDate__c=System.Now().addDays(30),
            EventCode__c='ZKJ1800007',
            StartDate__c=System.Now(),
            ContactEmail__c='sbryan@stanton.esc18.net',
            ContactPhone__c='456789',
            ContactStateID__c='ts',
            ContactZipCode__c='45679',
            CountryID__c='test country',
            Address__c='test addressss',
            Address2__c ='test addressss222'));
            }else{        
                evntlist=[SELECT Id, DateInserted__c, EventDescription__c,EventID__c,EventMasterID__c,EventName__c,FiscalYear__c,ShipToAddress__c,ShipToAddress2__c,ShipToCity__c,ShipToZipCode__c,ZipCode__c,ShipToStateID__r.StateID__c,ContactAddress__c,ContactAddress2__c,ContactCity__c,DateUpdated__c, EndDate__c,EventCode__c,StatusID__r.Status1__c, StartDate__c,ContactEmail__c,ContactPhone__c,ContactStateID__c,ContactZipCode__c,CountryID__c,Address__c,Address2__c FROM Events__x WHERE EventID__c=:eventId];
            }
            System.debug('Events: ' + evntlist);

            Map<String,Events__x> EventcodeMap=new Map<String,Events__x>();
            for(Events__x ev : evntlist){
                if(ev.EventID__c!=null){
                    EventcodeMap.put(ev.EventID__c,ev);
                }   
            }
            
            System.debug('EventcodeMap: ' + EventcodeMap);

            List<Opportunity> opplist=new List<Opportunity>();
            if(EventcodeMap.size()>0){
                System.debug('Map Size: ' + EventcodeMap.size());
                System.debug('EventcodeMap.keySet(): ' + EventcodeMap.keySet());
                List<Opportunity> oppslist=new List<Opportunity>();
                if(Test.isRunningTest()){
                    oppslist.add(new Opportunity(AccountId=accId,
                    EventID__c='80b6a5e9-9854-418e-876f-002a1203c596',
                    Name='test oppp',
                    StageName='Staged',
                    CloseDate=Date.Today().addDays(5),
                    StageChanged__c=System.Now(),
                    Event_Start_Date__c=Date.ToDay().addDays(2),
                    Event_End_Date__c=Date.ToDay().addDays(25),
                    core_event_start_date__c=Date.ToDay().addDays(2),
                    Fiscal_Year__c='2018',
                    Contact_Email_ID__c='sbryan@stanton.esc18.net',
                    Contact_Phone__c='56789',
                    Shipping_address__c='200 North Gray St.',
                    Shipping_Address_2__c='test ship address',
                    Shipping_City__c='Stanton',
                    Shipping_State__c='TA',
                    Shipping_zipcode__c='56677',
                    Mailing_address__c='test cont testaddd',
                    Mailing_address_2__c='test cont testaddd222',
                    Mailing_city__c='test city',
                    Mailing_state__c='TT',
                    Mailing_zipcode__c='67788',
                    Start_Date_ext__c=Date.Today().addDays(2)));
                }
                else{ 
                    oppslist=[SELECT Id,Name,Event_Description__c,Event_Code__c,Event_End_Date__c,EventID__c,Event_Name__c,Event_Organizer__c,
                                           Event_Start_Date__c,Fiscal_Year__c,Mailing_address__c,Mailing_address_2__c,Mailing_city__c,Mailing_state__c,
                                           Mailing_zipcode__c,Shipping_address__c,Shipping_Address_2__c,Shipping_City__c,Shipping_State__c,Shipping_zipcode__c,
                                           core_event_start_date__c FROM Opportunity WHERE EventID__c=:EventcodeMap.keySet()];
                }               
                    for(Opportunity opp : oppslist){
                        System.debug('Opp: ' + opp);
                        if(EventcodeMap.containsKey(opp.EventID__c) || Test.isRunningTest()){
                            opp.Name=EventcodeMap.get(opp.EventID__c).EventName__c;
                            opp.Event_Description__c=EventcodeMap.get(opp.EventID__c).EventDescription__c;
                            opp.Event_End_Date__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).EndDate__c);
                           // opp.Event_Name__c=EventcodeMap.get(opp.EventID__c).EventName__c;
                            opp.Event_Start_Date__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).StartDate__c);
                            opp.Fiscal_Year__c=String.Valueof(EventcodeMap.get(opp.EventID__c).FiscalYear__c).left(4);
                           // opp.Mailing_address__c=EventcodeMap.get(opp.EventID__c).ContactAddress__c;
                           // opp.Mailing_address_2__c=EventcodeMap.get(opp.EventID__c).ContactAddress2__c;
                            //opp.Mailing_city__c=EventcodeMap.get(opp.EventID__c).ContactCity__c;
                           // opp.Mailing_state__c=EventcodeMap.get(opp.EventID__c).ContactStateID__c;
                           // opp.Mailing_zipcode__c=EventcodeMap.get(opp.EventID__c).ContactZipCode__c;
                           
                            opp.Mailing_address__c = highlights.Mailing_ADDRESS_LINE_1__c;
                            opp.Mailing_address_2__c = highlights.Mailing_ADDRESS_LINE_2__c;
                            opp.Mailing_city__c = highlights.Mailing_ADDRESS_LINE_2__c;
                            opp.Mailing_state__c = highlights.Mailing_STATE__c;
                            opp.Mailing_zipcode__c = highlights.Mailing_ZIP__c;
                            
                            opp.Shipping_address__c=EventcodeMap.get(opp.EventID__c).ShipToAddress__c;
                            opp.Shipping_Address_2__c=EventcodeMap.get(opp.EventID__c).ShipToAddress2__c;
                            opp.Shipping_City__c=EventcodeMap.get(opp.EventID__c).ShipToCity__c;
                            //opp.Shipping_State__c=EventcodeMap.get(opp.EventID__c).ShipToStateID__r.StateCode__c;
                            opp.Shipping_zipcode__c=EventcodeMap.get(opp.EventID__c).ShipToZipCode__c;
                            opp.core_event_start_date__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).StartDate__c);
                            opp.Start_Date_ext__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).StartDate__c); 
                            opp.Contact_Email_ID__c=EventcodeMap.get(opp.EventID__c).ContactEmail__c;
                            opp.Contact_Phone__c=EventcodeMap.get(opp.EventID__c).ContactPhone__c;
                            if(EventcodeMap.get(opp.EventID__c).StatusID__r.Status1__c=='System Cancelled' || EventcodeMap.get(opp.EventID__c).StatusID__r.Status1__c=='Cancelled'){
                              //opp.StageName=EventcodeMap.get(opp.EventID__c).StatusID__r.Status1__c;
                              opp.StageName='Cancelled';
                            }  
                            opplist.add(opp); 
                        }
                    }                   
                
            }
            System.debug('---opplist---'+opplist);
            if(opplist.size()>0){
               update opplist;
            }
             //This code is added for updating the related Opportunity based on Event updated info. code ends               
        }

        catch(Exception ex) {
            //something went wrong, show the exception
            system.debug('error message: ' + ex.getMessage());
            system.debug('stack trace: ' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }

        //return null;
        //Redirect to EventMastering view with eventid guid
       String retURL = CustomSettings__c.getValues('EventsRecruitment').Value__c;
        System.debug('The Return URL: ' + retURL);
        retURL = retURL + 'Recruitment/View/' + eventId;
        System.debug('The Completed URL: ' + retURL);
        PageReference eventView = new PageReference(retURL);
        eventView.setRedirect(true);
        return eventView;
        
       // return new pagereference('/'+con.id);
    }
    
    //move the lead
    @TestVisible private Lead MoveLead() {
        string coordId = null, phone = null;

        if (highlights.CoordinatorId__c != null) {
            coordId = highlights.CoordinatorId__c;
        }

        System.debug('CoordID: ' + coordId);

        if (currLead != null && currLead.SSLead != null) {
            phone = currLead.SSLead.Phone;
        }

        currLead.SSLead.LastName = pci.name__c == null ? pci.first_name__c + ' ' + pci.last_name__c : pci.name__c;
        currLead.SSLead.CoordinatorID__c = coordId;
        currLead.SSLead.ConstituentID__c = highlights.OrganizerId__c;
        currLead.SSLead.XREF__c = eventId + '|' + coordId;
        currLead.SSLead.Company = 'ALSAC';
        currLead.SSLead.RecordTypeId = rtLead.Id;
        currLead.SSLead.CurrentCampaign__c = eventCamp.Id;
        currLead.SSLead.Recruited_Date__c = highlights.StartDate__c.date();
        currLead.SSLead.Phone = phone;
        currLead.SSLead.Event_Status__c = highlights.Status__c;
        
        //update lead email with Coord email
        currLead.SSLead.Email = highlights.ContactEmail__c;

        System.debug('CurrLead.SSLead: ' + currLead.SSLead);

        System.debug('update lead');
        update currLead.SSLead;

        return currLead.SSLead;
    }

    //create the opportunity
    @TestVisible private static Opportunity CreateOpp(string oppEventId,String conId,Lead eventLead,PreferredConstituentInfos__x pcc,EventHighlights__x highlights,Campaign eventCamp,String accId,RecordType rtOpp) {
        system.debug('oppEventId: ' + oppEventId);
        Opportunity opp = new Opportunity(
            EventId__c = oppEventId
            , Name = highlights.EventName__c
            , Event_Organizer__c = eventLead.Id
            , AccountId = accId
            , Opportunity_Owner__c=conId
            , RecordTypeId = rtOpp.Id
            , StageName = 'Staged'
            , CloseDate = Date.Today().AddMonths(6)
            , Event_Start_Date__c = highlights.StartDate__c.addHours(6).date()
            , core_event_start_date__c = highlights.StartDate__c.addHours(6).date()
            , Contact_Email_ID__c = highlights.ContactEmail__c
            , Support_campaign__c = eventCamp.Id
            , CampaignId = eventCamp.Id
            , Event_Code__c = highlights.EventCode__c
            , Contact_Phone__c = highlights.ContactPhone__c
            , Shipping_address__c = highlights.ShipToAddress__c
            , Shipping_Address_2__c = highlights.ShipToAddress2__c
            , Shipping_City__c = highlights.ShipToCity__c
            , Shipping_State__c = highlights.ShipToStateCode__c
            , Shipping_zipcode__c = highlights.ShipToZipCode__c
            , Mailing_address__c = highlights.Mailing_ADDRESS_LINE_1__c
            , Mailing_address_2__c = highlights.Mailing_ADDRESS_LINE_2__c
            , Mailing_city__c = highlights.Mailing_City__c
            , Mailing_state__c = highlights.Mailing_STATE__c
            , Mailing_zipcode__c = highlights.Mailing_ZIP__c
            , Coordinator_Name__c = pcc.first_name__c + ' ' + pcc.last_name__c
            
        );
        insert opp;
        system.debug('opp.Id: ' + opp.Id);
        return opp;
    }
    
    //create the contact
    @TestVisible private static Contact CreateContact(Lead evLead,PreferredConstituentInfos__x pcc,EventHighlights__x highlights,String accId) {        
        Contact con = new Contact(                        
             LastName = pcc.last_name__c
            , FirstName = pcc.first_name__c
            , LeadSource = evLead.LeadSource
            , Title = evLead.Title
            , AccountId = accId   
            , Lead_Name__c = evLead.Id          
            , Email = highlights.ContactEmail__c           
            , Phone = highlights.ContactPhone__c           
            , MailingStreet = highlights.Mailing_ADDRESS_LINE_1__c
            , MailingCity =  highlights.Mailing_City__c
            , MailingState = highlights.Mailing_STATE__c            
            , MailingPostalCode = highlights.Mailing_ZIP__c             
            , OtherStreet = highlights.Mailing_ADDRESS_LINE_1__c
            , OtherCity =  highlights.Mailing_City__c
            , OtherState = highlights.Mailing_STATE__c          
            , OtherPostalCode = highlights.Mailing_ZIP__c           
        );
        insert con;
        system.debug('con.Id: ' + con.Id);
        return con;
    }
    
    //create the OpportunityContactRole
    @TestVisible private static Void CreateOpportunityContact(Contact con,Opportunity opp) {        
        OpportunityContactRole oppcon=new OpportunityContactRole();
        oppcon.ContactId=con.Id;
        oppcon.OpportunityId=opp.id;
        insert oppcon;
           
    }
}