public with sharing class ECCEventHelper {
    private static EnvironmentSettings__c es;

    private static void GetES() {
        if (es == null) {
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
    }

    public static String RemoveNonNumericData(string input)
    {
        if (input == null)
            return null;

        input = input.trim();

        //remove ext. ex. x. from phone number string 9015176262 ext. 1234=9015176262
        if (input.containsIgnoreCase('x') || input.containsIgnoreCase('e'))
        {
            if (input.containsIgnoreCase('x'))
            {
                system.debug('input.indexOf(x)=' + input.indexOf('x'));

                if (input.indexOf('x') == -1)
                    input = input.substring(0, input.indexOf('X'));  
                else
                    input = input.substring(0, input.indexOf('x'));    
                //input = input.substring(0, input.indexOf('x'));
            }

            if (input.containsIgnoreCase('e'))
            {
                system.debug('input.indexOf(e)=' + input.indexOf('e'));

                if (input.indexOf('e') == -1)
                    input = input.substring(0, input.indexOf('E'));  
                else
                    input = input.substring(0, input.indexOf('e'));                   
            }            
        }

        String numericString = '';
        integer strLength = input.length();
        for(integer i =0;i<input.length();i++){
            String s= input.mid(i,1);
            if(s.isNumeric()){
                numericString +=s;
            }
        }
        System.debug('Number is: ' + numericString);
        return numericString;
    }


    //jak: deprecated 10/26/17
    public static EventHighlights__x GetHighlightByLeadId(string leadId, Opportunity o)
    {
        return GetHighlightByLeadId(leadId);
    }

    public static EventHighlights__x GetHighlightByLeadId(string leadId)
    {
        EventHighlights__x e = null;

        system.debug('leadId = ' + leadId);
        if (leadId == '')
            return new EventHighlights__x();

        Opportunity eventOpp = GetDIYOppFromLead(leadId);
        system.debug('eventOpp = ' + eventOpp);
        if (eventOpp != null) {
            if (String.isEmpty(eventOpp.Event_Organizer__c)) {
                throw new ECCUtil.ECCException('Opportunity does not have an event id.');
            }
            system.debug('eventOpp.EventID__c = ' + eventOpp.EventID__c);
            e = OdataExtension.GetEventHighLightsById(eventOpp.EventID__c);
        }

        system.debug('EventHighlights__x = ' + e);
        return e;
    }

    public static string GetConstituentEmail(domainSoapStjudeOrg.Constituent con)
    {
        system.debug('start GetConstituentEmail');
        system.debug('GetConstituentEmail.con=' + con);
        string retVal = '';
        if (con.Profile != null && con.Profile.Emails != null && con.Profile.Emails.size() > 0) {
            for(domainSoapStjudeOrg.Email e : con.Profile.Emails) {
                retVal = e.EmailAddress;
                if (e.Preferred != null && e.Preferred == true)
                break;
            }
        }
        else retVal = 'Email Address';

        return retVal;
    }

    public static string GetConstituentPhone(domainSoapStjudeOrg.Constituent con)
    {
        string retVal = '';
        if (con.Profile != null && con.Profile.Phones != null && con.Profile.Phones.size() > 0) {
            for(domainSoapStjudeOrg.Phone p : con.Profile.Phones) {
                retVal = p.PhoneNumber;
                if(p.Preferred != null && p.Preferred == true) break;
            }
        }
        else retVal = 'Phone Number';

        return retVal;
    }

    public static string GetConstituentName(domainSoapStjudeOrg.Constituent con)
    {
        String retVal = '';
        String consType = con.Type_x.Code;
        if (consType == 'INDIVIDUAL') {
            if (String.isBlank(con.LongName)) 
                retVal = con.FirstName + ' ' + con.LastName;
            else 
                retVal = con.LongName;
        }
        else {
            retVal = con.Name;
        }

        return retVal;
    }

    public static Boolean IsVip(domainSoapStjudeOrg.Constituent con)
    {
        String[] ConstToWatch = new string[] {'VIP_YES', 'BOARD_CURRENT', 'BOARD_PAST', 'St Jude Parent YES', 'St. Jude Parent - Deceased',
        'St. Jude Parent - Live', 'STJFAMILY_DECEASED', 'STJFAMILY_LIVING', 'STJFAMILY_YES', 'STJPATIENT_ACTIVE', 'STJPATIENT_REMISSION'};
        Boolean isVIP = false;
        if (con.Properties != null && con.Properties.size() > 0) {
            for(domainSoapStjudeOrg.Property prop : con.Properties) {
                if (string.isNotBlank(prop.Property)) {
                    for(string cons : ConstToWatch) {   
                        if(prop.Property == cons) {
                            if (prop.Status.toUpperCase() == 'ACTIVE') {
                                if (prop.StartDate == null || DateTime.now() >= prop.StartDate) {
                                    if (prop.EndDate == null || DateTime.now() <= prop.EndDate) {
                                        isVIP = true;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return isVIP;
    }

    public static string GetDisplayAddress(domainSoapStjudeOrg.Constituent con)
    {
        string address = '';
        if (con != null && con.Profile != null && con.Profile.Addresses != null && con.Profile.Addresses.size() > 0) {
            for(domainSoapStjudeOrg.Address a : con.Profile.Addresses) {
                address = 
                    (string.isNotBlank(a.Street1) ? a.Street1 + '<br/>' : '') +
                    (string.isNotBlank(a.Street2) ? a.Street2 + '<br/>' : '') +
                    (string.isNotBlank(a.Street3) ? a.Street3 + '<br/>' : '') +
                    (string.isNotBlank(a.City) ? a.City + ', ' : '') +
                    (string.isNotBlank(a.State) ? a.State + ' ' : '') +
                    (string.isNotBlank(a.ZipCode) ? a.ZipCode : '');

                //if (a.AddressType != null) {
                //    AddressType = a.AddressType.Code;
                //}

                if (a.Preferred != null && a.Preferred ==true) break;
            }
        }
        else address = 'Address';

        return address;
    }
    //newcode: display opportunity address
    public static string GetDisplayMailingAddress(Opportunity oppy)
    {
        Opportunity opp=[select id,name, Mailing_address__c, Mailing_address_2__c,Mailing_city__c, Mailing_state__c,Mailing_zipcode__c from opportunity WHERE id=: oppy.id];
        string address = '';
        if (opp != null) {            
                address = 
                    (string.isNotBlank(opp.Mailing_address__c) ? opp.Mailing_address__c + '<br/>' : '') +
                    (string.isNotBlank(opp.Mailing_address_2__c) ? opp.Mailing_address_2__c + '<br/>' : '') +                    
                    (string.isNotBlank(opp.Mailing_city__c) ? opp.Mailing_city__c + ', ' : '') +
                    (string.isNotBlank(opp.Mailing_state__c) ? opp.Mailing_state__c + ' ' : '') +
                    (string.isNotBlank(opp.Mailing_zipcode__c) ? opp.Mailing_zipcode__c : '');        
        }
        else address = 'Address';

        return address;
    }
    public static Events__x GetDIYEventFromLead(Lead diyLead, Opportunity eventOpp) {
        system.debug('diyLead = ' + diyLead + ' eventOpp = ' + eventOpp);
        eventOpp = GetDIYOppFromLead(diyLead.Id, eventOpp);
        system.debug('GetDIYOppFromLead = ' + eventOpp);
        List<Events__x> lstEvents  = new List<Events__x>(); 
        Events__x e = null;

        GetES();

        if (eventOpp != null) {
            if (String.isEmpty(eventOpp.Event_Organizer__c)) {
                throw new ECCUtil.ECCException('Opportunity does not have an event id.');
            }

            system.debug('eventOpp != null');

            Set<String> eventId = new Set<String>();
            eventId.add(eventOpp.EventID__c);

            lstEvents = OdataExtension.GetEventById(eventId);
            List<Events__x> listEvents  = new List<Events__x>();
            for(Events__x ev : lstEvents){
                if(ev.StatusID__r.Status1__c=='Active'){
                   listEvents.add(ev);
                }   
            }
            
            if (listEvents.size() == 1) {
                
                e = lstEvents.get(0);
            }
            else {
                throw new ECCUtil.ECCException('Opportunity event does not exist or there are duplicates.');
            }
        }

        return e;
    }

    public static Opportunity GetDIYOppFromLead(String leadId, Opportunity eventOpp) {
        Opportunity newEventOpp = null;

        if (eventOpp != null) {
            newEventOpp = eventOpp;
        }
        else {
            newEventOpp = GetDIYOppFromLead(leadId);
        }
        system.debug('newEventOpp');
        system.debug(newEventOpp);
        return newEventOpp;
    }

    public static Opportunity GetDIYOppFromLead(String leadId) {
        Opportunity newEventOpp = null;

        List<Opportunity> opps = [
            select
                Id
                , EventID__c                
                , Event_Organizer__c
                , Stagename
                , Probability
                , LastModifiedDate 
            from
                Opportunity
            where
                Event_Organizer__c = :leadId AND (Stagename!='Completed' AND Stagename!='Cancelled')
            order by StageChanged__c DESC];

        if(opps.size() > 0) {
            newEventOpp = opps.get(0);
        }
        
        //more than 1 opp, only show the one that is within calling range
        if(opps.size() > 1) {
            List<Opportunity> opps2 = [
            select
                Id
                , EventID__c                
                , Event_Organizer__c
                , Stagename
                , Probability
                , LastModifiedDate 
            from
                Opportunity
            where
                Event_Organizer__c = :leadId AND (Stagename!='Completed' AND Stagename!='Cancelled')
                and core_event_start_date__c < :Date.Today().AddMonths(3)
            order by StageChanged__c DESC LIMIT 1];

            if(opps2.size() > 0) {
                newEventOpp = opps2.get(0);
            }
        }
        
        system.debug('opps.size() = ' + opps.size());

        //didn't find any active events, so show what's available
        if( newEventOpp == null) {
            system.debug('No Active Event');
            opps = [
                select
                    Id
                    , EventID__c                
                    , Event_Organizer__c
                    , Stagename
                    , Probability
                    , LastModifiedDate 
                from
                    Opportunity
                where
                    Event_Organizer__c = :leadId
                order by StageChanged__c DESC Limit 1];

            if(opps.size() > 0) {
                newEventOpp = opps.get(0);
            }
        }
        
        return newEventOpp;
    }

    public static String GetLeadIdByEventId(String eventId)
    {
        Opportunity o;
        List<Opportunity> opps = [
                select Id, 
                EventID__c,                             
                Event_Organizer__c,
                LastModifiedDate ,
                Stagename, Mailing_address__c, Mailing_address_2__c, Mailing_city__c, Mailing_state__c, Mailing_zipcode__c
                from Opportunity 
                where EventID__c=:eventId AND (Stagename!='Completed' AND Stagename!='Cancelled') Order BY LastModifiedDate DESC LIMIT 1] ;


        if(opps.size() > 0) {
            o = opps.get(0);
        }

        system.debug('ECCEventHelper.GetLeadIdByEventId.Opportunity=' + o);
        return o == null ? '' : o.Event_Organizer__c;
    }

    public static PreferredConstituentInfos__x GetDIYEventContactFromLead(Lead diyLead, String roleId, 
            Events__x event, Opportunity eventOpp, String consId) {

        PreferredConstituentInfos__x pci = null;

        if (event != null)
            pci = GetDIYEventContactFromLead(diyLead, roleId, event.EventID__c, eventOpp, consId);
        else 
            pci = OdataExtension.GetPreferredConstituentInfos(consId);

        return pci;
    }

    public static PreferredConstituentInfos__x GetDIYEventContactFromLead(Lead diyLead, String roleId, 
            EventHighlights__x event, Opportunity eventOpp, String consId) {

        PreferredConstituentInfos__x pci = null;

        if (event != null)
        {
            system.debug('event: ' + event);
            pci = GetDIYEventContactFromLead(diyLead, roleId, event.EventID__c, eventOpp, consId);
        }
        else {
            system.debug('consId: ' + consId);
            pci = OdataExtension.GetPreferredConstituentInfos(consId);
        }

        return pci;
    }

    public static PreferredConstituentInfos__x GetDIYEventContactFromLead(Lead diyLead, String roleId, string eventId, Opportunity eventOpp, String consId) {
        eventOpp = GetDIYOppFromLead(diyLead.Id, eventOpp);
        PreferredConstituentInfos__x pci = null;

        if (eventOpp != null) {
            system.debug('have an opp, getting coordinator from event');
                
            if (eventId != null) {
                GetES();
                system.debug('event set, hooray!');
                system.debug('eventId: ' + eventId);
                system.debug('roleId: ' + roleId);
                system.debug('es.EVMActiveStatusID__c: ' + es.EVMActiveStatusID__c);

                List<EventConstituentRoles__x> ecrs = OdataExtension.GetECFromEventId(eventId, roleId, es.EVMActiveStatusID__c);
                system.debug('ecrs count: ' + ecrs.size());
                if (ecrs.size() > 0) {
                    system.debug('have some ecrs');
                    consId = ecrs.get(0).EventConstituentID__r.ConstituentID__c;
                    system.debug('consId: ' + consId);
                    pci = OdataExtension.GetPreferredConstituentInfos(consId);
                }
            }
        }
        else {
            system.debug('no opp, getting from lead: ' + consId);
            pci = OdataExtension.GetPreferredConstituentInfos(consId);
        }

        return pci;
    }

    /// Future Functions
    @future
    public static void RemoveFromCampaign(string leadId) { //Get ParentID
        String parentCampName = 'St Jude Challenge FY16';
        System.debug('St Jude Challenge FY16 leadId = ' + leadId);
        List<CampaignMember> camMem = [SELECT Id FROM CampaignMember WHERE LeadId =:leadId AND CampaignId in (Select id from campaign where IsSupportParent__c = false )];
        CampaignMember currCamMem;
        System.debug('camMem.size() = ' + camMem.size());
        if (camMem != null && camMem.size() > 0) {
            delete camMem;
        }
    }

    // Search Coordinator
     public static Map<String,EventConstituentRoleViews__x>fetchEventCoordinator(Set<String>setEventIds){
        return fetchEventCoordinator(setEventIds, null);
     }
    // Search Coordinator
     public static Map<String,EventConstituentRoleViews__x>fetchEventCoordinator(Set<String>setEventIds, String status){
        Map<String,EventConstituentRoleViews__x> mapEventIdWithMapEventConstituentRoleViews = new Map<String,EventConstituentRoleViews__x>();
        List<Roles__x >lstRoles = OdataExtension.GetRoles('Coordinator');
        if(lstRoles.size()>0){
            list<EventConstituentRoleViews__x> lstECRViews = new list<EventConstituentRoleViews__x>();
            lstECRViews = OdataExtension.GetEventConstituentRoleViews(setEventIds,lstRoles[0].RoleID__c);
            for(EventConstituentRoleViews__x roleView : lstECRViews){
                system.debug('roleView.Status__c: ' + roleView.Status__c + ', statusId: ' + status);
                if (String.isBlank(status) || roleView.Status__c == status) {
                   mapEventIdWithMapEventConstituentRoleViews.put(roleView.EventId__c,roleView);
                }
            }
        }  
        return mapEventIdWithMapEventConstituentRoleViews ;
    }
    
    // Search Organizer
    public static Map<String,EventConstituentRoleViews__x>fetchEventOrganizer(Set<String>setEventIds){
        
        Map<String,EventConstituentRoleViews__x> mapEventIdWithMapEventConstituentRoleViews = new Map<String,EventConstituentRoleViews__x>();
        List<Roles__x >lstRoles = OdataExtension.GetRoles('Organizer');
        if(lstRoles.size()>0){
           list<EventConstituentRoleViews__x> lstECRViews = new list<EventConstituentRoleViews__x>();
           lstECRViews = OdataExtension.GetEventConstituentRoleViews(setEventIds,lstRoles[0].RoleID__c);   
            for(EventConstituentRoleViews__x roleView : lstECRViews){
                mapEventIdWithMapEventConstituentRoleViews.put(roleView.EventId__c,roleView);
            }
        }  
        return mapEventIdWithMapEventConstituentRoleViews ;
    }

}