global class OdataExtension {
    //Get odata info from custom setting
    private static final String BASE_URL = OdataExtensionSettings__c.getInstance().Base_URL__c;
    private static final Integer TIMEOUT_MS = (Integer)OdataExtensionSettings__c.getInstance().Timeout_Milliseconds__c;
    private static final String USERNAME= OdataExtensionSettings__c.getInstance().Username__c;
    private static final String PASSWORD= OdataExtensionSettings__c.getInstance().Password__c;
    private static final String EVENTS_ENDPOINT = OdataExtensionSettings__c.getInstance().Events_Endpoint__c;
    private static final String FOINTERACTIONS_ENDPOINT = OdataExtensionSettings__c.getInstance().FOInteractions_Endpoint__c;
    private static final String ORDERS_ENDPOINT = OdataExtensionSettings__c.getInstance().Orders_Endpoint__c;
    private static final String LINEITEMS_ENDPOINT = OdataExtensionSettings__c.getInstance().LineItems_Endpoint__c;
    private static final String EVENT_MASTERS_ENDPOINT = OdataExtensionSettings__c.getInstance().Event_Masters_Endpoint__c;
    private static final String EVENT_ATTRIBUTES_ENDPOINT = OdataExtensionSettings__c.getInstance().Event_Attributes_Endpoint__c;
    private static final String EVENT_CONSTITUENTS_ENDPOINT = OdataExtensionSettings__c.getInstance().Event_Constituents_Endpoint__c;
    private static final String EVENT_CONSTITUENT_ROLES_ENDPOINT = OdataExtensionSettings__c.getInstance().Event_Constituent_Roles_Endpoint__c;
    private static final String EVENT_NOTES_ENDPOINT = OdataExtensionSettings__c.getInstance().Event_Notes_Endpoint__c;
    
    //Setup 2 constructors: one for a standard controller & one of a standard set controller
    //This lets the class be set as an extension on any VF page
    global OdataExtension(ApexPages.StandardController controller) {}
    global OdataExtension(ApexPages.StandardSetController controller) {}

    @RemoteAction
    global static String saveFOInteraction(String recordGuid, FOInteractions__x i) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        i.InteractionID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: FOInteractions__x.sObjectType.getDescribe().Fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if (dfr.getName().endsWith('__c')) {
                if (i.get(f) != null) {
                    if (dfr.getType() == Schema.DisplayType.DATE) {
                        gen.writeDateField(f.getDescribe().getName().replace('__c', ''), Date.valueOf(i.get(f)));
                    }
                    else if (dfr.getType() == Schema.DisplayType.DATETIME) {
                        gen.writeDateTimeField(f.getDescribe().getName().replace('__c', ''), DateTime.valueOf(i.get(f)));
                    }
                    else {
                        gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(i.get(f)));
                    }
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();
        buildHttpRequest('POST', FOINTERACTIONS_ENDPOINT, isNewRecord, recordGuid, jsonString);
        return recordGuid;
    }

    @RemoteAction
    global static String saveOIMOrder(String recordGuid, Orders__x o) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;
        System.debug('recordGuid = ' + recordGuid);
        o.OrderId__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: Orders__x.sObjectType.getDescribe().Fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if (dfr.getName().endsWith('__c')) {
                if (o.get(f) != null) {
                    if (dfr.getType() == Schema.DisplayType.DATE) {
                        gen.writeDateField(f.getDescribe().getName().replace('__c', ''), Date.valueOf(o.get(f)));
                    }
                    else if (dfr.getType() == Schema.DisplayType.DATETIME) {
                        gen.writeDateTimeField(f.getDescribe().getName().replace('__c', ''), DateTime.valueOf(o.get(f)));
                    }
                    else {
                        gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(o.get(f)));
                    }
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();
        System.debug('isNewRecord = ' + isNewRecord);
        buildHttpRequest('POST', ORDERS_ENDPOINT, isNewRecord, recordGuid, jsonString);
        return recordGuid;
    }

    @RemoteAction
    global static String saveOIMLineItem(String recordGuid, LineItems__x li) {
        return saveOIMLineItem(recordGuid, li, false);
    }

    @RemoteAction
    global static String saveOIMLineItem(String recordGuid, LineItems__x li, Boolean isDelete) {
        System.debug(' recordGuid = ' + recordGuid);
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;
         System.debug(' recordGuid set = ' + recordGuid);
        li.LineItemId__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: LineItems__x.sObjectType.getDescribe().Fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if (dfr.getName().endsWith('__c')) {
                if (li.get(f) != null) {
                    if (dfr.getType() == Schema.DisplayType.DATE) {
                        gen.writeDateField(f.getDescribe().getName().replace('__c', ''), Date.valueOf(li.get(f)));
                    }
                    else if (dfr.getType() == Schema.DisplayType.DATETIME) {
                        gen.writeDateTimeField(f.getDescribe().getName().replace('__c', ''), DateTime.valueOf(li.get(f)));
                    }
                    else {
//                        system.debug('f.getDescribe().getName().replace(\'__c\', \'\'): ' + f.getDescribe().getName().replace('__c', '') +
//                            ', String.valueOf(li.get(f)): ' + String.valueOf(li.get(f)));
                        gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(li.get(f)));
                    }
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();
        buildHttpRequest('POST', LINEITEMS_ENDPOINT, isNewRecord, recordGuid, jsonString, isDelete);
        return recordGuid;
    }
    
    @RemoteAction
    global static String saveEvent(String recordGuid, Events__x event) { //editRecruitEvent != true
        system.debug('recordGuid = ' + recordGuid);
        system.debug('event = ' + event);
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        event.EventID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: Events__x.sObjectType.getDescribe().Fields.getMap().values()) {
            Schema.DescribeFieldResult dfr = f.getDescribe();
            if (dfr.getName().endsWith('__c')) {
                if (event.get(f) != null) {
                    if (dfr.getType() == Schema.DisplayType.DATE) {
                        gen.writeDateField(f.getDescribe().getName().replace('__c', ''), Date.valueOf(event.get(f)));
                    }
                    else if (dfr.getType() == Schema.DisplayType.DATETIME) {
                        gen.writeDateTimeField(f.getDescribe().getName().replace('__c', ''), DateTime.valueOf(event.get(f)));
                    }
                    else {
                        gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(event.get(f)));
                    }
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();
        buildHttpRequest('POST', EVENTS_ENDPOINT, isNewRecord, recordGuid, jsonString);
        return recordGuid;
    }
    
    @RemoteAction
    global static String saveEventAttribute(String recordGuid, EventAttributes__x eventAttribute) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        //system.debug('eventAttribute == ' + eventAttribute);
        eventAttribute.EventAttributeID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: EventAttributes__x.sObjectType.getDescribe().Fields.getMap().values()) {
            if (f.getDescribe().getName().endsWith('__c')) {
                if (eventAttribute.get(f) != null) {
                    gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(eventAttribute.get(f)));
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();

        System.debug(eventAttribute);
        buildHttpRequest('POST', EVENT_ATTRIBUTES_ENDPOINT, isNewRecord, recordGuid, jsonString);

        return recordGuid;
    }

    @RemoteAction
    global static String saveEventConstituent(String recordGuid, EventConstituents__x eventConstituent) { //,String jsonString) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        eventConstituent.EventConstituentID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: EventConstituents__x.sObjectType.getDescribe().Fields.getMap().values()) {
            if (f.getDescribe().getName().endsWith('__c')) {
                if (eventConstituent.get(f) != null) {
                    gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(eventConstituent.get(f)));
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();

        System.debug(eventConstituent);

        buildHttpRequest('POST', EVENT_CONSTITUENTS_ENDPOINT, isNewRecord, recordGuid, jsonString);

        return recordGuid;
    }

    @RemoteAction
    global static String saveEventConstituentRole(String recordGuid, EventConstituentRoles__x eventConstituentRole) {// ,String jsonString) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        eventConstituentRole.EventConstituentRoleID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: EventConstituentRoles__x.sObjectType.getDescribe().Fields.getMap().values()) {
            if (f.getDescribe().getName().endsWith('__c')) {
                if (eventConstituentRole.get(f) != null) {
                    gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(eventConstituentRole.get(f)));
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();

        System.debug(eventConstituentRole);
                                
        buildHttpRequest('POST', EVENT_CONSTITUENT_ROLES_ENDPOINT, isNewRecord, recordGuid, jsonString);
       
        return recordGuid;
    }

    global static HttpResponse UpdateEvent(String eventId, String coordinatorId){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + 'api/EventUpdate/UpdateConstituents?eventId=' + eventId + '&coordinatorId=' + coordinatorId); //This will change from dev to QA
        req.setMethod('GET');
        req.setTimeout(5000);

        String username = USERNAME;
        String password = PASSWORD;

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'BASIC ' +
        EncodingUtil.base64Encode(headerValue);
        System.debug('authorizationHeader = ' + authorizationHeader);
        req.setHeader('Authorization', authorizationHeader);
        System.debug('request = ' + req);

        Http http = new Http();
        HttpResponse res = http.send(req);
        System.debug('start of body = ' + res.getBody());
        return res;
    }

    @RemoteAction
    global static String saveEventMaster(String recordGuid, EventMasters__x eventMaster) {// ,String jsonString) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        eventMaster.EventMasterID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: EventMasters__x.sObjectType.getDescribe().Fields.getMap().values()) {
            system.debug('f.getDescribe().getName() = ' + f.getDescribe().getName());
            if (f.getDescribe().getName().endsWith('__c')) {
                if (eventMaster.get(f) != null) {
                    gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(eventMaster.get(f)));
                }
            }
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();

        System.debug('eventMaster = ' + eventMaster);
        buildHttpRequest('POST', EVENT_MASTERS_ENDPOINT, isNewRecord, recordGuid, jsonString);
       
        return recordGuid;
    }

    @RemoteAction
    global static String saveEventNote(String recordGuid, EventNotes__x eventNote) {// ,String jsonString) {
        Boolean isNewRecord = Guid.isEmpty(recordGuid);
        String jsonString;
        recordGuid = isNewRecord ? Guid.createGuid() : recordGuid;

        eventNote.EventNoteID__c = recordGuid;

        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
        for(SObjectField f: EventNotes__x.sObjectType.getDescribe().Fields.getMap().values()) {
            if (f.getDescribe().getName().endsWith('__c')) {
                if (eventNote.get(f) != null) {
                    gen.writeStringField(f.getDescribe().getName().replace('__c', ''), String.valueOf(eventNote.get(f)));
                }
            } 
        }
        gen.writeEndObject();
        jsonString = gen.getAsString();
        buildHttpRequest('POST', EVENT_NOTES_ENDPOINT, isNewRecord, recordGuid, jsonString);
       
        return recordGuid;
    }

    public static List<Events__x> GetEventByName(String name) {
        return GetEventByName(name, false);
    }

    public static List<Events__x> GetEventByName(String name, Boolean fakeEvent) {
        List<Events__x> evExist = new List<Events__x>();

        if (Test.isRunningTest()) {
            if (fakeEvent) {
                evExist.add(new Events__x(
                    EventID__c = Guid.createGuid()
                ));
            }
        }
        else {
            evExist = [select
                EventID__c
            from
                Events__x
            where
                EVentName__c = :name];
        }
        return evExist;
    }

    public static EventHighlights__x GetEventHighLightsById(string eventId)
    {
        List<EventHighlights__x> ehl = new List<EventHighlights__x>();
        EventHighlights__x retval;

        if (Test.isRunningTest()) {
           ehl.Add(new EventHighlights__x(EventID__c = 'notaguid', OrganizerId__c='orgid', CoordinatorId__c=null, EventName__c='some event'));
        }
        else {
            ehl = [SELECT ActualParticipants__c,Mailing_ADDRESS_LINE_1__c,Mailing_ADDRESS_LINE_2__c,Mailing_CITY__c,Mailing_STATE__c,Mailing_ZIP__c,Address2__c,Address__c,CancelledAgent__c,CancelledDate__c,City__c,ContactAddress2__c,ContactAddress__c,ContactCity__c,
            ContactEmail__c,ContactPhone__c,ContactStateID__c,ContactType__c,ContactZipCode__c,CostCenterID__c,CountryID__c,CreatedBy__c,DateInserted__c,
            DateUpdated__c,DisplayUrl,EndDate__c,EventCode__c,EventDescription__c,EventID__c,EventMasterID__c,EventName__c,EventProgramID__c,
            EventStartMonth__c,EventStartYear__c,EventTimeZoneID__c,EventTypeID__c,EventWebSite__c,ExpectedParticipants__c,ExternalId,FiscalYear__c,
            Id,LeadStaffEmail__c,ModifiedBy__c,PreferredContactTypeID__c,ReasonID__c,RegionID__c,SendIncentives__c,SendKit__c,ShipToAddress2__c,ShipToAddress__c,
            ShipToCity__c,ShipToStateID__c,ShipToZipCode__c,StaffAddress__c,StaffPhone__c,StaffUserId__c,StartDate__c,StateID__c,StatusID__c,SystemOfOrigin__c,
            TeamRaiserId__c,ZipCode__c, CoordinatorId__c, OrganizerId__c,Status__c, ContactStateCode__c, ShipToStateCode__c
            FROM EventHighlights__x
            where EventID__c =:eventId AND (Status__c!='Completed' OR Status__c!='Cancelled') Order BY DateUpdated__c DESC];
        }
        if (ehl.size() > 0) {
            retval = ehl.get(0);
        }

        system.debug('odataextension.GetEventHighLightsById = ' + retval);
        return retval;
    }
 
    public static EventRevenues__x GetEventRevenueById(string eventId)
    {
        List<EventRevenues__x> ehl = new List<EventRevenues__x>();
        EventRevenues__x retval;

        if (Test.isRunningTest()) {
           ehl.Add(new EventRevenues__x(EventID__c = eventId, Amount__c=123.00));
        }
        else {
            ehl = [select EventId__c, Amount__c from EventRevenues__x where EventId__c = :eventId];

            system.debug('odataextension.GetEventRevenueById = ' + retval);
        }

        if (ehl.size() > 0) {
            retval = ehl.get(0);
        }

        return retval;
    }
    
     public static List<EventTypes__x> GetAllEventTypes() {
        List<EventTypes__x> evExist = new List<EventTypes__x>();

        if (Test.isRunningTest()) {
            evExist.add(new EventTypes__x(
                EventTypeID__c = GUID.createGuid(),
                StatusID__c = '123456789',
                EventTypeName__c = 'Event Type Name'
            ));
        }
        else {
                evExist = [select 
                                EventTypeName__c,
                                StatusID__c,
                                EventTypeID__c 
                            from 
                                EventTypes__x 
                            where EventTypeName__c !=null order by EventTypeName__c];
            
        }
        return evExist;
    }

    public static List<EventTypes__x> GetAllECCRecruitedEventTypes() {
        List<EventTypes__x> evExist = new List<EventTypes__x>();

        if (Test.isRunningTest()) {
            evExist.add(new EventTypes__x(
                EventTypeID__c = GUID.createGuid(),
                StatusID__c = '123456789',
                EventTypeName__c = 'Event Type Name'
            ));
        }
        else {
                evExist = [select 
                                EventTypeName__c,
                                StatusID__c,
                                EventTypeID__c 
                            from 
                                EventTypes__x 
                            where EventTypeName__c != null
                            and IsEccRecruited__c = true 
                            order by EventTypeName__c];
            
        }
        return evExist;
    }

    public static EventPrograms__x getProgramtype(String EventProgramID) {
        List<EventPrograms__x> eps = new List<EventPrograms__x>();
        EventPrograms__x ep;
        String programType = '';

        if (Test.isRunningTest()) {
            eps.add(new EventPrograms__x(
                EventProgramID__c = GUID.createGuid(),
                EventProgram1__c = 'Event Program Name'
            ));
        }
        else {
            eps = [
                select
                    EventProgramID__c
                    , EventProgram1__c
                from 
                    EventPrograms__x 
                where EventProgramID__c =: EventProgramID];          
        }

        if (eps.size() > 0) {
            ep = eps.get(0);
        }

        return ep;
    }
    
    public static List<Events__x> eventsByQuery(string qry,dateTime sd, dateTime ed) {
        system.debug('sd '+sd);
        List<Events__x> evExist = new List<Events__x>();

        if (Test.isRunningTest()) {
            evExist.add(new Events__x(
                EventID__c = Guid.createGuid()
            ));
        }
        else {
            if(qry != null){
                system.debug(qry);
                evExist = database.query(qry);
            }
        }
        return evExist;
    }

    public static Integer countByQuery(string q, List<AggregateResult> testRes) {
        Integer countRes = 0;

        if (Test.isRunningTest()) {
            if (testRes == null) {
                testRes = new List<AggregateResult>();
            }
            countRes = testRes.size();
        }
        else {
            if(q != null){
                system.debug(q);
                countRes = database.countQuery(q);
            }
        }
        return countRes;
    }
    
    public static List<V_ProductInfo__x> V_ProductInfoQuery(String q, List<V_ProductInfo__x> testRes) {
        List<V_ProductInfo__x> pInfos = new List<V_ProductInfo__x>();

        if (Test.isRunningTest()) {
            if (testRes == null) {
                testRes = new List<V_ProductInfo__x>();
            }
            pInfos = testRes;
        }
        else {
            if(q != null){
                system.debug(q);
                pInfos = database.query(q);
            }
        }
        return pInfos;
    }

    public static List<V_OrderInfo__x> V_OrderInfoQuery(String q, List<V_OrderInfo__x> testRes) {
        List<V_OrderInfo__x> ois = new List<V_OrderInfo__x>();

        if (Test.isRunningTest()) {
            if (testRes == null) {
                testRes = new List<V_OrderInfo__x>();
            }
            ois = testRes;
        }
        else {
            if(q != null){
                system.debug(q);
                ois = database.query(q);
                system.debug(' ois = ' + ois);
            }
        }
        return ois;
    }

    public static List<V_LineItemInfo__x> V_LineItemInfoQuery(String q, List<V_LineItemInfo__x> testRes) {
        List<V_LineItemInfo__x> lii = new List<V_LineItemInfo__x>();

        if (Test.isRunningTest()) {
            if (testRes == null) {
                testRes = new List<V_LineItemInfo__x>();
            }
            lii = testRes;
        }
        else {
            if(q != null){
                system.debug(q);
                lii = database.query(q);
                system.debug('lii = ' + lii);
            }
        }
        return lii;
    }

    public static List<LookupValues__x> LookupValuesByTopic (String topic, Boolean includeInactive, List<LookupValues__x> testRes) {
        String q = 'select LookupValueID__c, Display__c ' +
                    'from LookupValues__x ' + 
                    'where Topic__c = \'' + topic + '\'' + 
                    (includeInactive ? '' : 'and IsActive__c = true ') +
                    'order by Display__c';
        return LookupValuesQuery(q, testRes);
    }

    public static List<LookupValues__x> LookupValuesQuery(String q, List<LookupValues__x> testRes) {
        List<LookupValues__x> lv = new List<LookupValues__x>();

        if (Test.isRunningTest()) {
            if (testRes == null) {
                testRes = new List<LookupValues__x>();

                testRes.add(new LookupValues__x(
                    //Id='x0nM00000008OI5IAM',
                    IsActive__c=true,
                    LookupValueId__c=Guid.createGuid(),
                    Display__c = 'Registration Card',
                    Topic__c='QuestionCategory',
                    Value__c='Registration Card'
                ));
            }
            lv = testRes;
        }
        else {
            if(q != null){
                system.debug(q);
                lv = database.query(q);
            }
        }
        return lv;
    }

    public static List<EventTypeRoles__x> GetEventTypeRolesByRoleType (String roleId1, String roleId2, String eventTypeId) {
        List<EventTypeRoles__x> etrs = new List<EventTypeRoles__x>();
        if(Test.isRunningTest()) {
            etrs.add(new EventTypeRoles__x(
                RoleID__r = new Roles__x(
                    RoleName__c = 'role1'
                )
                , EventTypeRoleID__c = Guid.createGuid()
            ));
            etrs.add(new EventTypeRoles__x(
                RoleID__r = new Roles__x(
                    RoleName__c = 'role2'
                )
                , EventTypeRoleID__c = Guid.createGuid()
            ));
        }
        else {
            etrs = [
                select
                    EventTypeRoleID__c
                    , RoleID__r.RoleName__c
                from
                    EventTypeRoles__x
                where
                    (RoleID__c =  :roleId1
                    or RoleID__c = :roleId2)
                    and EventTypeID__c = :eventTypeId];
        }

        return etrs;
    }

    //public static List<V_OrderInfo__x> V_OrderInfoByOrderId (String orderId) {
    //    List<V_OrderInfo__x> ois = new List<V_OrderInfo__x>();
    //    if(Test.isRunningTest()) {
    //        ois.add(new V_OrderInfo__x(
    //                EventID__c = Guid.createGuid()
    //            ));
    //    }
    //    else {
    //        ois = [
    //            select
    //                EventID__c
    //                , OrderId__c
    //                , ShipmentMethodDisplay__c
    //                , DateOrdered__c
    //                , DateToShip__c
    //                , DateSubmitted__c
    //                , DateShipped__c
    //                , createdBy__c
    //                , StatusDisplay__c
    //                , LineItemCount__c
    //                , IsPriority__c
    //                , Status__c
    //                , ShipmentMethodId__c
    //            from
    //                V_OrderInfo__x
    //            where
    //                OrderId__c = :orderId];
    //    }

    //    return ois;
    //}

    public static List<EventTypeAttributeViews__x> GetEventTypeAttributeViews (String eventTypeId) {
        List<EventTypeAttributeViews__x> etavs = new List<EventTypeAttributeViews__x>();
        if(Test.isRunningTest()) {
            etavs.add(new EventTypeAttributeViews__x(
                EventTypeAttributeID__c = Guid.createGuid()
                , EventTypeID__c = Guid.createGuid()
                , AttributeID__c = Guid.createGuid()
                , AttributeName__c = 'event location'
            ));
            etavs.add(new EventTypeAttributeViews__x(
                EventTypeAttributeID__c = Guid.createGuid()
                , EventTypeID__c = Guid.createGuid()
                , AttributeID__c = Guid.createGuid()
                , AttributeName__c = 'event time'
            ));
            etavs.add(new EventTypeAttributeViews__x(
                EventTypeAttributeID__c = Guid.createGuid()
                , EventTypeID__c = Guid.createGuid()
                , AttributeID__c = Guid.createGuid()
                , AttributeName__c = 'type of event:'
            ));
            etavs.add(new EventTypeAttributeViews__x(
                EventTypeAttributeID__c = Guid.createGuid()
                , EventTypeID__c = Guid.createGuid()
                , AttributeID__c = Guid.createGuid()
                , AttributeName__c = 'material language'
            ));
            etavs.add(new EventTypeAttributeViews__x(
                EventTypeAttributeID__c = Guid.createGuid()
                , EventTypeID__c = Guid.createGuid()
                , AttributeID__c = Guid.createGuid()
                , AttributeName__c = 'offline'
            ));
        }
        else {
            etavs = [
                select
                    EventTypeAttributeID__c
                    , EventTypeID__c
                    , AttributeID__c
                    , AttributeName__c
                from
                    EventTypeAttributeViews__x
                where
                    EventTypeID__c = :eventTypeId];
        }

        return etavs;
    }

    public static List<IncentiveInfos__x> GetIncentiveInfosByCampCons (String campaignId, String consId) {
        List<IncentiveInfos__x> iis = new List<IncentiveInfos__x>();
        if(Test.isRunningTest()) {
            iis.add(new IncentiveInfos__x(
                CampaignId__c = campaignId
                , CampaignMemberId__c = 'fake id'
                , CampaignName__c = 'fake name'
                , Category__c = 'fake categor'
                , Property__c = 'property Name'
                , sj_P2P_ID_c__c = consId
                , Value__c = 'property value'
            ));
        }
        else {
            iis = [
                select
                   CampaignId__c
                    , CampaignMemberId__c
                    , CampaignName__c
                    , Category__c
                    , Property__c
                    , sj_P2P_ID_c__c
                    , Value__c
                from
                    IncentiveInfos__x
                where
                    CampaignId__c = :campaignId
                    and sj_P2P_ID_c__c = :consId
                order by
                    Category__c desc];
        }

        return iis;
    }

    public static MarathonRecommits__x GetMarathonRecommits (Decimal eventId, String consId) {
        List<MarathonRecommits__x> mrs = new List<MarathonRecommits__x>();
        MarathonRecommits__x mr = null;

        if(Test.isRunningTest()) {
            mrs.add(new MarathonRecommits__x(
                Id__c = Guid.createGuid()
                , GiftName__c = 'test'
                , CCDecision__c = 'ACCEPT'
                , CreatedDate__c = DateTime.now()
                , ConsId__c = consId
                , P2PEventId__c = eventId
            ));
        }
        else {
            mrs = [
                select
                    Id__c
                    , GiftName__c
                    , CCDecision__c
                    , CreatedDate__c
                    , ConsId__c
                    , P2PEventId__c
                from
                    MarathonRecommits__x
                where
                    P2PEventId__c = :eventId
                    and ConsId__c = :consId];
        }

        if (mrs.size() > 0) {
            mr = mrs.get(0);
        }
        return mr;
    }

    public static EventTypes__x GetEventTypeById(String eventTypeId) {
        List<EventTypes__x> types = new List<EventTypes__x>();
        EventTypes__x et = null;

        if (Test.isRunningTest()) {
            types.add(new EventTypes__x(
                EventTypeID__c = Guid.createGuid()
                , EventTypeName__c = 'Test Event Type'
                , ActivePrefix__c = 'ABC123'
                , StatusID__c = Guid.createGuid()
                , EventProgramID__c = Guid.createGuid()
                , IsEccRecruited__c = false
            ));
        }
        else {
            types = [
                select
                    EventTypeID__c
                    , EventTypeName__c
                    , ActivePrefix__c
                    , StatusID__c
                    , EventProgramID__c
                    , IsEccRecruited__c
                from
                    EventTypes__x
                where
                    EventTypeID__c = :eventTypeId];
        }

        if (types.size() > 0) {
            et = types.get(0);
        }

        return et;
    }

    public static PreferredConstituentInfos__x GetPreferredConstituentInfos(String consId) {
        List<PreferredConstituentInfos__x> cons = new List<PreferredConstituentInfos__x>();
        PreferredConstituentInfos__x retPrefCon = null;

        if (Test.isRunningTest()) {
            cons.add(new PreferredConstituentInfos__x(
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
                    , constituent_id__c = consId
                ));
        }
        else {
            cons = [
                select 
                    name__c
                    , last_name__c
                    , first_name__c
                    , address__c
                    , extra_line_1__c
                    , extra_line_2__c
                    , addressType__c
                    , phone_number__c
                    , email_address__c
                    , city__c
                    , state__c
                    , country__c
                    , zip__c
                    , constituent_id__c
                From
                    PreferredConstituentInfos__x
                where
                    constituent_id__c = :consId];
        }
 
        if (cons.size() == 1) {
            retPrefCon = cons.get(0);
        }

        return retPrefCon;
    }

      public static List<Events__x> GetEventMasterByName(String name) {
        return GetEventByName(name, false);
    }

    public static List<EventMasters__x> GetEventMasterByName(String name, Boolean fakeEvent) {
        List<EventMasters__x> emExist = new List<EventMasters__x>();

        if (Test.isRunningTest()) {
            if (fakeEvent) {
                emExist.add(new EventMasters__x(
                    EventMasterID__c = Guid.createGuid()
                    , EVentMasterName__c = name
                ));
            }
        }
        else {
            emExist = [
                select
                    EventMasterID__c
                from
                    EventMasters__x
                where
                    EVentMasterName__c = :name];
        }

        return emExist;
    }

    public static EventMasters__x GetEventMasterById(
                String eventMasterID) {
        List<EventMasters__x> eventMasters = new List<EventMasters__x>();
        EventMasters__x em = null;

        if (Test.isRunningTest()) {
            eventMasters.add(new EventMasters__x(
                EventMasterID__c = eventMasterID
                , EventMasterCode__c = 'EVMCODE'
                , EventMasterName__c = 'Event Master Name'
            ));
        }
        else {
            eventMasters = [
                select 
                    EventMasterID__c,
                    EventMasterCode__c,
                    EventMasterName__c
                from
                    EventMasters__x
                where
                    EventMasterID__c = :eventMasterID];
        }

        if (eventMasters.size() > 0) {
            em = eventMasters.get(0);
        }

        return em;
    }

    public static List<ConstituentPlans__x> GetDMSPlanByConsId(String consId, Boolean isActive) {
        List<ConstituentPlans__x> cp = new List<ConstituentPlans__x>();

        if (Test.isRunningTest()) {
            cp.add(new ConstituentPlans__x(
                PlanID__c = Guid.createGuid(),
                ConstituentID__c = Guid.createGuid(),
                StaffID__c = Guid.createGuid(),
                StaffFirstName__c = 'Test First Name',
                StaffLastName__c = 'Test Last Name',
                StaffLongName__c = 'Test Long Name',
                PlanIsActive__c = true,
                PlanName__c = 'Test Plan Name',
                PlanStartDate__c = DateTime.now()
            ));
        }  
        else {
            cp = [
                select 
                    PlanID__c,                   
                    ConstituentID__c,
                    StaffID__c,
                    StaffFirstName__c,
                    StaffLastName__c,
                    StaffLongName__c,                                    
                    PlanIsActive__c,
                    PlanName__c,
                    PlanStartDate__c
                From
                    ConstituentPlans__x
                where
                    ConstituentID__c = :consId
                    and PlanIsActive__c = :isActive];
        }

        return cp;
    }

    public static List<Events__x> GetEventById(Set<String> eventIds) {
        List<Events__x> events = new List<Events__x>();

        if (Test.isRunningTest()) {
            for(String s : eventIds) {
                events.add(
                    new Events__x(
                        EventTypeID__r = new EventTypes__x(
                                EventTypeName__c = 'Test Event Type'
                                , ActivePrefix__c = 'TEST'
                            )
                        , StatusID__r = new Statuses__x(
                            Status1__c = 'Active'
                            )
                        , EventMasterID__r = new EventMasters__x(
                            EventMasterName__c = 'Test Event Master'
                            )
                        , EventID__c = s
                        , ExpectedParticipants__c = 9
                        , StartDate__c = DateTime.now().addYears(-1)
                        , EndDate__c = DateTime.now().addYears(-1).addDays(1)
                        , EventDescription__c = 'Test Event Description'
                        , EventName__c = 'Test Event'
                        , EventMasterID__c = Guid.createGuid()
                        , EventCode__c = 'TEST091815'
                        , FiscalYear__c = 2015
                        , PreferredContactTypeID__c = Guid.createGuid()
                        , Address__c = '501 St Jude Pl'
                        , Address2__c = ''
                        , City__c = 'Memphis'
                        , StateID__c = Guid.createGuid()
                        , ZipCode__c = '38117'
                        , ShipToAddress__c = '501 St Jude Pl'
                        , ShipToAddress2__c = ''
                        , ShipToCity__c = 'Memphis'
                        , ShipToStateID__c = Guid.createGuid()
                        , ShipToZipCode__c = '38117'
                        , ContactPhone__c = '9015551234'
                        , ContactEmail__c = 'test@test.com'
                        , EventTypeID__c = Guid.createGuid()
                        , DateInserted__c = DateTime.now()
                        , SendKit__c = false
                        , SendIncentives__c = false
                        , ReasonID__c = Guid.createGuid()
                    )
                );
            }
        }
        else {
            events = [
                select
                    EventID__c
                    , ExpectedParticipants__c
                    , StartDate__c
                    , EndDate__c
                    , EventDescription__c
                    , EventName__c
                    , EventMasterID__c
                    , EventCode__c
                    , EventTypeID__r.EventTypeName__c
                    , StatusID__r.Status1__c
                    , EventMasterID__r.EventMasterName__c
                    , FiscalYear__c
                    , EventTypeID__r.ActivePrefix__c
                    , PreferredContactTypeID__c
                    , ActualParticipants__c 
                    , Address__c
                    , Address2__c
                    , City__c
                    , StateID__c
                    , ZipCode__c
                    , ShipToAddress__c
                    , ShipToAddress2__c
                    , ShipToCity__c
                    , ShipToStateID__c
                    , ShipToZipCode__c
                    , ContactPhone__c
                    , ContactEmail__c
                    , DateInserted__c
                    , DateUpdated__c
                    , SendKit__c
                    , SendIncentives__c
                    , ReasonID__c
                    , SystemOfOrigin__c
                from
                    Events__x
                where
                    EventID__c in :eventIds AND StatusID__r.Status1__c='Active'
                order by
                    StartDate__c,DateUpdated__c DESC];
        }

        return events;
    }
    
    public static List<Events__x> GetEventsById(Set<String> eventIds) {
        List<Events__x> events = new List<Events__x>();

        if (Test.isRunningTest()) {
            for(String s : eventIds) {
                events.add(
                    new Events__x(
                        EventTypeID__r = new EventTypes__x(
                                EventTypeName__c = 'Test Event Type'
                                , ActivePrefix__c = 'TEST'
                            )
                        , EventMasterID__r = new EventMasters__x(
                            EventMasterName__c = 'Test Event Master'
                            )
                        , EventID__c = s
                        , ExpectedParticipants__c = 9
                        , StartDate__c = DateTime.now().addYears(-1)
                        , EndDate__c = DateTime.now().addYears(-1).addDays(1)
                        , EventDescription__c = 'Test Event Description'
                        , EventName__c = 'Test Event'
                        , EventMasterID__c = Guid.createGuid()
                        , EventCode__c = 'TEST091815'
                        , FiscalYear__c = 2015
                        , PreferredContactTypeID__c = Guid.createGuid()
                        , Address__c = '501 St Jude Pl'
                        , City__c = 'Memphis'
                        , StateID__c = Guid.createGuid()
                        , ZipCode__c = '38117'
                        , ShipToAddress__c = '501 St Jude Pl'
                        , ShipToAddress2__c = ''
                        , ShipToCity__c = 'Memphis'
                        , ShipToStateID__c = Guid.createGuid()
                        , ShipToZipCode__c = '38117'
                        , ContactPhone__c = '9015551234'
                        , ContactEmail__c = 'test@test.com'
                        , DateInserted__c = DateTime.now().addDays(-5)
                        , StatusID__c = Guid.createGuid()
                    )
                );
            }
        }
        else {
            events = [
                select
                    EventID__c
                    , ExpectedParticipants__c
                    , StartDate__c
                    , EndDate__c
                    , EventDescription__c
                    , EventName__c
                    , EventMasterID__c
                    , EventCode__c
                    , EventTypeID__r.EventTypeName__c
                    , EventMasterID__r.EventMasterName__c
                    , FiscalYear__c
                    , EventTypeID__r.ActivePrefix__c
                    , PreferredContactTypeID__c
                    , ActualParticipants__c 
                    , Address__c
                    , City__c
                    , StateID__c
                    , ZipCode__c
                    , ShipToAddress__c
                    , ShipToAddress2__c
                    , ShipToCity__c
                    , ShipToStateID__c
                    , ShipToZipCode__c
                    , ContactPhone__c
                    , ContactEmail__c
                    , PreferredContactTypeID__r.ContactType1__c
                    , DateInserted__c
                    , DateUpdated__c
                    , SendKit__c
                    , StatusID__c
    , StatusID__r.Status1__c
                    , EventTypeID__c
                from
                    Events__x
                where
                    EventID__c in :eventIds AND StatusID__r.Status1__c='Active'
                order by
                    StartDate__c,DateUpdated__c DESC];
        }

        return events;
    }
    
   public static List<EventNotes__x> GetEventNotesByEventID(String eventId) {
        List<EventNotes__x> evtNotes = new List<EventNotes__x>();

        if (Test.isRunningTest()) {
            evtNotes.add(new EventNotes__x(
                Notes__c = 'Test Note'
            ));
        }
        else {
            evtNotes = [
                select 
                    Notes__c,
                    EventNoteID__c 
                from
                    EventNotes__x
                where
                    EventID__c = :eventId];           
        } 
        
        return evtNotes;
    }

    public static TREventRegistrationDetails__x GetTREventRegDetailByConsEvent(Decimal consId, Decimal eventId) {
        List<TREventRegistrationDetails__x> details = new List<TREventRegistrationDetails__x>();
        TREventRegistrationDetails__x detail = null;

        if (Test.isRunningTest()) {
            details.add(new TREventRegistrationDetails__x(
                P2P_ID__c = consId
                , Team_Name__c = 'Test Team Name'
                , Is_Team_Captain__c = 'N'
                , Participation_Type_Fundrasing_Level__c = 'Gold Test'
                , RevenueGoal__c = 1000
                , Current_Event_Revenue__c = 1500
                , Current_Event_Gifts__c = 200
                , Last_Years_Amout_Raised__c = 1000
                , Last_Year_s_Participation__c = 'Gold Test'
                , MinimumGoal__c = 1000
                , Region__c = 'E'
            ));
        }
        else {
            details = [
                select 
                    P2P_ID__c
                    , EventId__c
                    , Team_Name__c
                    , Is_Team_Captain__c
                    , Participation_Type_Fundrasing_Level__c
                    , RevenueGoal__c
                    , Current_Event_Revenue__c
                    , Current_Event_Gifts__c
                    , Last_Years_Amout_Raised__c
                    , Last_Year_s_Participation__c
                    , MinimumGoal__c
                    , Region__c
                    , CreationDate__c
                from
                    TREventRegistrationDetails__x 
                where
                    P2P_ID__c = :consId
                    and EventID__c = :eventId Order By CreationDate__c DESC];
        }

        if (details.size() > 0) {
            detail = details.get(0);
        }
        return detail;
    }
    
      public static SingletOrders__x GetSingletOrdersByEvent(Decimal eventId, Decimal consId) {
        List<SingletOrders__x> details = new List<SingletOrders__x>();
        SingletOrders__x detail = null;

        if (Test.isRunningTest()) {
             details.add(new SingletOrders__x(
                EventID__c = eventId
                , ParticipantConsId__c = consId
                , SingletOrdered__c = 'Y'
            ));
        }
        else {
            details = [
                select
                    EventId__c
                    , ParticipantConsId__c
                    , SingletOrdered__c 
                from
                    SingletOrders__x
                where
                    EventID__c = :eventId
                    and ParticipantConsId__c = :consId];
        }

        if (details.size() > 0) {
            detail = details.get(0);
        }

        return detail;
    }

    public static TREventDetails__x GetTREventDetailByEvent(Decimal eventId) {
        List<TREventDetails__x> details = new List<TREventDetails__x>();
        TREventDetails__x detail = null;

        if (Test.isRunningTest()) {
             details.add(new TREventDetails__x(
                EventID__c = eventId
                , Name__c = 'Test Event'
                , EventDate__c = DateTime.now().addMonths(6)
                , Event_Type__c = 'Test Event Type'
                , EventAddressStreet1__c = '501 St Jude Pl'
                , EventAddressStreet2__c = ''
                , EventAddressStreet3__c = ''
                , EventAddressCity__c = 'Memphis'
                , EventAddressState__c = 'TN'
                , EventAddressZip__c = '38117'
                , EventAddressCountry__c = 'USA'
            ));
        }
        else {
            details = [
                select
                    EventID__c
                    , Name__c
                    , EventDate__c
                    , Event_Type__c
                    , EventAddressStreet1__c
                    , EventAddressStreet2__c
                    , EventAddressStreet3__c
                    , EventAddressCity__c
                    , EventAddressState__c
                    , EventAddressZip__c
                    , EventAddressCountry__c
                from
                    TREventDetails__x
                where
                    EventID__c = :eventId];
        }

        if (details.size() > 0) {
            detail = details.get(0);
        }

        return detail;
    }

    public static List<EventConstituentRoles__x> GetECFromEventId(String eventId, String roleId, String activeStatusID) {
        List<EventConstituentRoles__x> ecrs = new List<EventConstituentRoles__x>();
        system.debug('eventId: ' + eventId);
        system.debug('roleId: ' + roleId);
        system.debug('activeStatusID: ' + activeStatusID);
        if (Test.isRunningTest()) {
            ecrs.add(
                new EventConstituentRoles__x(
                    EventConstituentRoleID__c = Guid.createGuid()
                    , StatusID__c = activeStatusID
                    , EventTypeRoleID__r = new EventTypeRoles__x(
                        RoleID__c = roleId
                    )
                    , EventConstituentID__r = new EventConstituents__x (
                        ConstituentID__c = Guid.createGuid()
                        , EventId__c = eventId
                        , StatusID__c = activeStatusID
                    )
                )
            );
        }
        else {
            ecrs = [
                select
                    EventConstituentRoleID__c
                    , EventConstituentID__r.ConstituentID__c
                    , EventConstituentID__r.EventId__c
                    , StatusID__c
                    , EventConstituentID__r.StatusID__c
                    , EventTypeRoleID__r.RoleID__c
                from
                    EventConstituentRoles__x
                where
                    EventConstituentID__r.EventID__c = :eventId];

        }

        //salesforce be dumb!
        system.debug('ecrs returned, size: ' + ecrs.size());
        for (Integer i = ecrs.size() - 1; i >= 0; i--) {
            EventConstituentRoles__x ecr = ecrs.get(i);
            system.debug('ecr.EventTypeRoleID__r.RoleID__c: ' + ecr.EventTypeRoleID__r.RoleID__c);
            system.debug('ecr.StatusID__c: ' + ecr.StatusID__c);
            system.debug('ecr.EventConstituentID__r.StatusID__c: ' + ecr.EventConstituentID__r.StatusID__c);
            if (ecr.EventTypeRoleID__r.RoleID__c != roleId || 
                ecr.StatusID__c != activeStatusID ||
                ecr.EventConstituentID__r.StatusID__c != activeStatusID) {
                ecrs.remove(i);
            }
        }

        return ecrs;
    }

    public static List<States__x> GetStates () {
        List<States__x> lstStates = new List<States__x>();

        if (Test.isRunningTest()) {
            lstStates.add(new States__x(
                StateID__c = Guid.createGuid()
                , StateCode__c = 'TN'
            ));
        }
        else {
            lstStates = [
                select 
                    StateID__c
                    , StateCode__c 
                from
                    States__x
                order by
                    StateCode__c];
        }
        
        system.debug('state count: ' + lstStates.size());
        return lstStates;
    }    

    public static List<ContactTypes__x> GetContactTypes () {
        List<ContactTypes__x> lstContactTypes = new List<ContactTypes__x>();

        if (Test.isRunningTest()) {
            lstContactTypes.add(new ContactTypes__x(
                ContactTypeID__c = Guid.createGuid()
                , ContactType1__c = 'Phone'
            ));
        }
        else {
            lstContactTypes= [
                select 
                    ContactType1__c
                    , ContactTypeID__c 
                from 
                   ContactTypes__x
                order by
                    ContactType1__c ];
            }
        
        return lstContactTypes;
    }   
    
  
    public static List<EventAttributeViews__x> GetEventAttributeViews (string EventID) {
        //because this was originally written to only return 1 event attribute
        return GetEventAttributeViews(new String[] {EventID}, 'Material Language');
    }
    
    public static List<EventAttributeViews__x> GetEventAttributeViews (string EventID, Boolean newParm) {
        return GetEventAttributeViews(new String[] {EventID}, null);
    }

    public static List<EventAttributeViews__x> GetEventAttributeViews (List<String> EventIDs, String attName) {
        List<EventAttributeViews__x> lstEventAttributeViews = new List<EventAttributeViews__x>();

        if (Test.isRunningTest()) {
            if (String.isBlank(attName)) {
                for(String eventId : EventIDs) {
                    lstEventAttributeViews.add(new EventAttributeViews__x(
                        EventId__c = eventId
                        , EventAttributeID__c = Guid.createGuid()
                        , EventTypeAttributeID__c = Guid.createGuid()
                        , AttributeName__c = 'Test Attr Name'
                        , EventAttributeValue__c = 'Test Attribute'
                    ));
                }
            }
            else {
                for(String eventId : EventIDs) {
                    lstEventAttributeViews.add(new EventAttributeViews__x(
                        EventId__c = eventId
                        , EventAttributeID__c = Guid.createGuid()
                        , EventTypeAttributeID__c = Guid.createGuid()
                        , AttributeName__c = attName
                        , EventAttributeValue__c = 'Test Attribute'
                    ));
                }
            }
        }
        else {
            if (String.isBlank(attName)) {
                lstEventAttributeViews= [
                    select 
                        EventID__c
                        , EventAttributeID__c
                        , EventTypeAttributeID__c
                        , AttributeName__c
                        , EventAttributeValue__c
                    from
                        EventAttributeViews__x  
                    where
                        EventID__c in :EventIDs];
            }
            else {
                lstEventAttributeViews= [
                    select 
                        EventID__c
                        , EventAttributeID__c
                        , EventTypeAttributeID__c
                        , AttributeName__c
                        , EventAttributeValue__c
                    from
                        EventAttributeViews__x  
                    where
                        EventID__c in :EventIDs
                        and AttributeName__c = :attName];
            }
        }
        system.debug('lstEventAttributeViews = ' + lstEventAttributeViews);
        return lstEventAttributeViews;
    }

    public static List<EventAttributeViews__x> GetEventAttributeOfflineViews (List<String> EventIDs) {
        List<EventAttributeViews__x> lstEventAttributeOfflineViews = new List<EventAttributeViews__x>();

        if (Test.isRunningTest()) {
           // if (String.isBlank(attName)) {
                    lstEventAttributeOfflineViews.add(new EventAttributeViews__x(
                        EventId__c = '12345678'
                        , EventAttributeID__c = Guid.createGuid()
                        , EventTypeAttributeID__c = Guid.createGuid()
                        , AttributeName__c = 'Test Attr Name'
                        , EventAttributeValue__c = 'Test Attribute'
                    ));
          // }
        }
        if(EventIDs.size() > 0) {
                lstEventAttributeOfflineViews= [
                    select 
                        EventID__c
                        , EventAttributeID__c
                        , EventTypeAttributeID__c
                        , AttributeName__c
                        , EventAttributeValue__c
                    from
                        EventAttributeViews__x  
                    where
                        EventID__c in :EventIDs
                        and (AttributeName__c = 'Offline')
                        and (EventAttributeValue__c = 'N' or EventAttributeValue__c = null)];
        }
        system.debug('lstEventAttributeOfflineViews = ' + lstEventAttributeOfflineViews);
        return lstEventAttributeOfflineViews;
    }

     public static List<EventAttributes__x> GetEventAttributesByEvIDETAIDs (String eventId,  List<String> eventTypeAttributeIDs) {
        List<EventAttributes__x> lstEventAttribute = new List<EventAttributes__x>();
        system.debug('eventTypeAttributeIDs =' + eventTypeAttributeIDs);
        if (Test.isRunningTest()) {
           // if (String.isBlank(attName)) {
                    lstEventAttribute.add(new EventAttributes__x(
                        EventId__c = '12345678'
                        , EventAttributeID__c = Guid.createGuid()
                        , EventTypeAttributeID__c = Guid.createGuid()
                        , EventAttributeValue__c = 'Test Attribute'
                    ));
          // }
        }
        if(String.isNotBlank(eventId)){
            lstEventAttribute= [
                select 
                    EventID__c
                    , EventAttributeID__c
                    , EventTypeAttributeID__c
                    , EventAttributeValue__c
                from
                    EventAttributes__x  
                where
                    EventID__c = :eventId AND
                    EventTypeAttributeID__c in :eventTypeAttributeIDs];
        }
        return lstEventAttribute;
    }
    


    public static List<RecruitedEvents__x> GetRecruitedEvents(Set<string> setEventCodes) {
        List<RecruitedEvents__x> lstRecruitedEvents = new List<RecruitedEvents__x>();

        if (Test.isRunningTest()) {
            for(String s : setEventCodes ){
                lstRecruitedEvents.add(new RecruitedEvents__x(
                     OFFLINEREVENUE__c = 1000.00
                     , ONLINEREVENUE__c = 1000.00
                     , TOTALREVENUE__c = 1000.00
                     , SOURCECODE__c = s
                )); 
            }
        }
        else {
            lstRecruitedEvents= [
                select 
                   OFFLINEREVENUE__c
                   , ONLINEREVENUE__c
                   , TOTALREVENUE__c
                   , SOURCECODE__c
                from
                    RecruitedEvents__x
                where
                    SOURCECODE__c in : setEventCodes];

        }
        
        return lstRecruitedEvents;
    }

    //This is a place holder for the Odata that will query new object for Online Revenue
        //This is based off the query above, which is the old way of getting online revenue

    public static EventRevenues__x GetEventRevenue(String eventId) {
        List<EventRevenues__x> lstEventRevenues = new List<EventRevenues__x>();
        EventRevenues__x eventRevenue= new EventRevenues__x();

        if (Test.isRunningTest()) {
            //for(String s : eventId ){
            //    lstEventRevenues.add(new EventRevenues__x(
            //         Amount__c = 1000.00
            //         , EventId__c = 'test'
            //    )); 
            //}
        }
        else {
            lstEventRevenues= [
                select 
                    EventId__c
                  , Amount__c
                from
                    EventRevenues__x
                where
                    EventId__c = :eventId];
        }
        if (lstEventRevenues.size() > 0) {
            eventRevenue = lstEventRevenues.get(0);
        }
        return eventRevenue;
    }

    public static List<EventRevenues__x> GetEventRevenuesByEventIds(Set<string> eventIds) {
        List<EventRevenues__x> lstRecruitedEvents = new List<EventRevenues__x>();

        if (Test.isRunningTest()) {
            for(String s : eventIds ){
                lstRecruitedEvents.add(new EventRevenues__x(
                     OnlineAmount__c = 500.00,
                     OfflineAmount__c = 500.00,
                     Amount__c = 1000.00,
                     EventId__c = s
                )); 
            }
        }
        else {
            lstRecruitedEvents= [
                select 
                    EventId__c
                  , OnlineAmount__c
                  , OfflineAmount__c
                  , Amount__c
                from
                    EventRevenues__x
                where
                    EventId__c in : eventIds];

        }
        
        return lstRecruitedEvents;
    }

    //public static List<TeamRaiserRevenueBreakdown__x> GetTeamRaiserEventRevenueBreakdownByEventIds(Set<string> eventIds) {
    //    List<TeamRaiserRevenueBreakdown__x> listEvtRevenue = new List<TeamRaiserRevenueBreakdown__x>();

    //    if (Test.isRunningTest()) {
    //        for(String s : eventIds ){
    //            listEvtRevenue.add(new TeamRaiserRevenueBreakdown__x(
    //                 TotalAmount__c = 1000.00,
    //                 OfflineAmount__c = 500.00,
    //                 OnlineAmount__c = 500.00,
    //                 EventId__c = s
    //            )); 
    //        }
    //    }
    //    else {
    //        listEvtRevenue= [
    //            select 
    //                EventID__c
    //              , OfflineAmount__c
    //              , OnlineAmount__c
    //              , TotalAmount__c
    //            from
    //                TeamRaiserRevenueBreakdown__x
    //            where
    //                EventID__c in : eventIds];

    //    }
        
    //    return listEvtRevenue;
    //}

    public static List<EventRevenueDetails__x> GetEventRevenueDetails(String eventId) {
        List<EventRevenueDetails__x> lstRevenueDetails = new List<EventRevenueDetails__x>();

        if (Test.isRunningTest()) {
            //for(String s : eventId ){
            //lstRevenueDetails.add(new EventRevenueDetails__x(
            //     TransactionAmount__c = 1000.00
            //     , EventId__c = 'test'
            //)); 
            //}
        }
        else {
            lstRevenueDetails= [
                select 
                  ConstituentId__c,
                  EventId__c,
                  FirstName__c,Id,
                  KeyName__c,
                  PaymentMethod__c,
                  PostDate__c,
                  TransactionAmount__c,
                  TransactionId__c,Type__c
                from
                    EventRevenueDetails__x
                where
                    EventId__c = :eventId
                ORDER BY PostDate__c DESC];
        }

        return lstRevenueDetails;
    }

    public static List<EventConstituentRoleViews__x> GetEventConstituentRoleViews(Set<string> setEventIds, string RecTypeID) {
        List<EventConstituentRoleViews__x> lstEventConstituentRoleViews = new List<EventConstituentRoleViews__x>();

        if (Test.isRunningTest()) {
            for(string s : setEventIds){
                lstEventConstituentRoleViews.add(new EventConstituentRoleViews__x(
                  EventConstituentRoleID__c = Guid.createGuid()
                  , ConstituentID__c = 'notaguid'
                  , RoleName__c = 'organizer'
                  , EventId__c = s
                  , EventTypeId__c = 'testeventtype'
                  , EventName__c = 'testeventname'
                ));
                lstEventConstituentRoleViews.add(new EventConstituentRoleViews__x(
                  EventConstituentRoleID__c = Guid.createGuid()
                  , ConstituentID__c = 'notaguid1'
                  , RoleName__c = 'coordinator'
                  , EventId__c = s
                  , EventTypeId__c = 'testeventtype'
                  , EventName__c = 'testeventname'
                ));
            }
        }
        else {
            if (String.isBlank(RecTypeID)) {
                lstEventConstituentRoleViews = [
                    select 
                        EventID__c
                        , EventTypeId__c
                        , EventName__c
                        , EventTypeName__c
                        , RoleName__c
                        , Status__c
                        , ConstituentID__c
                        , first_name__c
                        , last_name__c
                        , name__c
                        , StartDate__c
                        , EndDate__c
                        , phone_number__c
                        , email_address__c
                    from
                        EventConstituentRoleViews__x
                    where
                        EventID__c IN :setEventIds Order BY StartDate__c DESC ];
            }
            else {
                lstEventConstituentRoleViews = [
                    select 
                        EventID__c
                        , EventTypeId__c
                        , EventName__c
                        , EventTypeName__c
                        , RoleName__c
                        , Status__c
                        , ConstituentID__c
                        , first_name__c
                        , last_name__c
                        , StartDate__c
                        , EndDate__c
                        , name__c
                        , phone_number__c
                        , email_address__c
                    from
                        EventConstituentRoleViews__x
                    where
                        EventID__c IN :setEventIds
                        and RoleID__c = :RecTypeID Order BY StartDate__c DESC];
            }
        }
        
        return lstEventConstituentRoleViews;
    }
    
    public static List<EventConstituentRoleViews__x> GetEventConstituentRoleViews(Set<string> setEventIds) {
        return GetEventConstituentRoleViews(setEventIds, null);
    }
    

     public static List<EventHistorySummaries__x> GetEventHistorySummaryByQuery(string qry) {
        List<EventHistorySummaries__x> lstEventHistorySummary = new List<EventHistorySummaries__x>();

        if (Test.isRunningTest()) {
            lstEventHistorySummary.add(new EventHistorySummaries__x(
                EventID__c = Guid.createGuid()
                , EventName__c = 'some event'
                , EventDescription__c = 'test event description'
                , StartDate__c = DateTime.now()
                , EndDate__c = DateTime.now()
                , EventCode__c = 'ABCD1234'
                , EventTypeName__c = 'Test Event Type Name'
                , EventMasterName__c = 'Test Event Master Name'
                , Status__c = 'Active'
                , EventTypeID__c = '123456'
                , SystemOfOrigin__c = 'Test origin'
                , IsEccRecruited__c = false
                ,ConstituentID__c ='notaguid'
            ));
        }
        else {
             if(qry != null){
                system.debug(qry);
                lstEventHistorySummary = database.query(qry);
            }
        }
        
        return lstEventHistorySummary;
    }

    public static List<EventConstituentRoleViews__x> GetEventConstituentRoleViewsByConstituentID(string ConstituentID) {
        List<EventConstituentRoleViews__x> lstEventConstituentRoleViews = new List<EventConstituentRoleViews__x>();

        if (Test.isRunningTest()) {
            lstEventConstituentRoleViews.add(new EventConstituentRoleViews__x(
                EventID__c = Guid.createGuid()
                , RoleName__c = 'test role name'
                , RoleDescription__c = 'test role description'
                , EventName__c = 'test event name'
                , EventDescription__c = 'test event description'
                , StartDate__c = DateTime.now()
                , EndDate__c = DateTime.now()
                , EventCode__c = 'ABCD1234'
                , EventTypeName__c = 'Test Event Type Name'
                , EventMasterName__c = 'Test Event Master Name'
                , Status__c = 'Active'
                , EventTypeID__c = '123456'
                , SystemOfOrigin__c = 'Test origin'
                , IsEccRecruited__c = false
            ));
        }
        else {
            lstEventConstituentRoleViews = [
                select 
                    EventID__c
                    , RoleName__c
                    , RoleDescription__c
                    , EventName__c
                    , EventDescription__c
                    , StartDate__c
                    , EndDate__c
                    , EventCode__c
                    , EventTypeName__c
                    , EventMasterName__c
                    , Status__c
                    , EventTypeID__c
                    , SystemOfOrigin__c
                    , IsEccRecruited__c
                from
                    EventConstituentRoleViews__x
                where
                    ConstituentID__c = :ConstituentID
                order by
                    EventTypeName__c, StartDate__c DESC];
        }
        
        return lstEventConstituentRoleViews;
    }

    public static List<Roles__x> GetRoles(string strRoleName) {
        List<Roles__x> lstRoles = new List<Roles__x>();

        if (Test.isRunningTest()) {
            lstRoles.add(new Roles__x(
                RoleName__c = 'Coordinator'
                , RoleID__c = Guid.createGuid()
            ));
        }
        else {
            lstRoles = [
                select 
                    RoleID__c
                    , RoleName__c
                    , RoleTypeID__c 
                from
                    Roles__x
                where
                    RoleName__c = :strRoleName];           
        }
        
        return lstRoles;
    }


    public static List<TREventRegistrationDetails__x> GetEventRegDetailsByEventIdCons(String eventId, List<Decimal> consIds) {
        return GetEventRegDetailsByEventIdCons(new Decimal[] { Decimal.valueOf(eventId) }, consIds);
    }

    public static List<TREventRegistrationDetails__x> GetEventRegDetailsByEventIdCons(List<Decimal> eventIds, List<Decimal> consIds) {
        List<TREventRegistrationDetails__x> trEventRegs = new List<TREventRegistrationDetails__x>();

        if (Test.isRunningTest()) {
            Integer cnt = 0;
            for(Decimal consId : consIds) {
                trEventRegs.add(new TREventRegistrationDetails__x(
                    P2P_ID__c = consId
                    , Current_Event_Revenue__c = cnt++
                    , Participation_Type_Fundrasing_Level__c = Math.mod(cnt, 2) == 0 ? 'Classic Hero level' : 'Platinum Hero' 
                    , MinimumGoal__c = 1000
                    , Region__c = 'E'
                    , Is_Team_Captain__c = 'CaptainTest'
                    , Birthdate__c = DateTime.now()
                    , EventId__c = 12345
                    , EventDate__c = DateTime.now()
                ));
            }
        }
        else {
            trEventRegs = [
                select
                    P2P_ID__c
                    , Current_Event_Revenue__c
                    , Participation_Type_Fundrasing_Level__c
                    , MinimumGoal__c
                    , Region__c
                    , Is_Team_Captain__c
                    , Birthdate__c
                    , EventId__c
                    , EventDate__c
                from
                    TREventRegistrationDetails__x 
                where 
                    EventId__c in :eventIds 
                    and P2P_ID__c in :consIds];
        }

        return trEventRegs;
    }

    public static List<RecruitedEvents__x> GetEventRevenueFromRecruitedEvents(Set<String> eventIds) {
        List<RecruitedEvents__x> trEventRevenuefromRE = new List<RecruitedEvents__x>();

        if (Test.isRunningTest()) {
            for(String evId : eventIds)
                trEventRevenuefromRE.add(new RecruitedEvents__x(
                    TOTALREVENUE__c = 1000  
                  , SOURCECODE__c = evId
                ));
        }
        else {
            trEventRevenuefromRE = [
                select
                    TOTALREVENUE__c,
                    SOURCECODE__c
                from
                    RecruitedEvents__x 
                where 
                    SOURCECODE__c  in :eventIds];
        }

        return trEventRevenuefromRE;
    }
    
    public static List<EventConsRoleAttrViews__x> getEventConsRoleAttrViews(String eventId, string consId) {
        return getEventConsRoleAttrViews(new String[] { eventId }, consId, 'CGI_CONF_NUMBER');
    }

    public static List<EventConsRoleAttrViews__x> getEventConsRoleAttrViews(List<String> eventId, string consId, string attrName) {
    List<EventConsRoleAttrViews__x> evntConsRoleAttrViews = new List<EventConsRoleAttrViews__x>();

        if (Test.isRunningTest()) {
            if (String.isNotBlank(attrName)) {

                if (String.isNotBlank(consId)) {
                    for (String eId : eventId) {
                        evntConsRoleAttrViews.add(new EventConsRoleAttrViews__x(
                            ConstituentID__c  = consId
                            , EventID__c  = eId
                            , AttributeName__c  = attrName
                            , AttributeValue__c  = '1234'
                            , StartDate__c = DateTime.now()
                            , EndDate__c = DateTime.now()
                            , DateInserted__c = DateTime.now()
                            , EventCode__c = 'EventCode'
                        ));
                    }
                }
                else {
                    for (String eId : eventId) {
                        evntConsRoleAttrViews.add(new EventConsRoleAttrViews__x(
                            ConstituentID__c  = Guid.createGuid()
                            , EventID__c  = eId
                            , AttributeName__c  = attrName
                            , AttributeValue__c  = '1234'
                            , StartDate__c = DateTime.now()
                            , EndDate__c = DateTime.now()
                            , DateInserted__c = DateTime.now()
                            , EventCode__c = 'EventCode'
                        ));
                    }
                }
            }
            else if (String.isNotBlank(consId)) { 
                for (String eId : eventId) {
                    evntConsRoleAttrViews.add(new EventConsRoleAttrViews__x(
                        ConstituentID__c  = consId
                        , EventID__c  = eId
                        , AttributeName__c  = 'SOME_ATTRIBUTE'
                        , AttributeValue__c  = '1234'
                        , StartDate__c = DateTime.now()
                        , EndDate__c = DateTime.now()
                        , DateInserted__c = DateTime.now()
                        , EventCode__c = 'EventCode'
                    ));
                }
            }
            else {
                for (String eId : eventId) {
                    evntConsRoleAttrViews.add(new EventConsRoleAttrViews__x(
                        ConstituentID__c  = Guid.createGuid()
                        , EventID__c  = eId
                        , AttributeName__c  = 'SOME_ATTRIBUTE'
                        , AttributeValue__c  = '1234'
                        , StartDate__c = DateTime.now()
                        , EndDate__c = DateTime.now()
                        , DateInserted__c = DateTime.now()
                        , EventCode__c = 'EventCode'
                    ));
                }
            }
        }
        else {
            if (String.isNotBlank(attrName)) {
                if (String.isNotBlank(consId)) {
                    evntConsRoleAttrViews = [
                        select
                            ConstituentID__c
                            , AttributeValue__c 
                            , EventID__c
                            , AttributeName__c
                            , StartDate__c
                            , EndDate__c
                            , DateInserted__c
                            , EventCode__c
                        from
                            EventConsRoleAttrViews__x 
                        where 
                            EventId__c in :eventId 
                            and AttributeName__c  = :attrName
                            and ConstituentID__c = :consId Order BY StartDate__c,DateInserted__c DESC];
                }
                else {
                    evntConsRoleAttrViews = [
                        select
                            ConstituentID__c
                            , AttributeValue__c 
                            , EventID__c
                            , AttributeName__c
                            , StartDate__c
                            , EndDate__c
                            , DateInserted__c
                            , EventCode__c
                        from
                            EventConsRoleAttrViews__x 
                        where 
                            EventId__c in :eventId 
                            and AttributeName__c  = :attrName Order BY StartDate__c,DateInserted__c DESC];
                }
            }
            else if (String.isNotBlank(consId)) {
                evntConsRoleAttrViews = [
                    select
                        ConstituentID__c
                        , AttributeValue__c 
                        , EventID__c
                        , AttributeName__c
                        , StartDate__c
                        , EndDate__c
                        , DateInserted__c
                        , EventCode__c
                    from
                        EventConsRoleAttrViews__x 
                    where 
                        EventId__c in :eventId 
                        and ConstituentID__c =:consId Order BY StartDate__c,DateInserted__c DESC];
            }
            else {
                evntConsRoleAttrViews = [
                    select
                        ConstituentID__c
                        , AttributeValue__c 
                        , EventID__c
                        , AttributeName__c
                        , StartDate__c
                        , EndDate__c
                        , DateInserted__c
                        , EventCode__c
                    from
                        EventConsRoleAttrViews__x 
                    where 
                        EventId__c in :eventId Order BY StartDate__c,DateInserted__c DESC];
            }
        }

        return evntConsRoleAttrViews;
    }    

    public static List<EventConstituentRoleViews__x> getCoordEvent(String consId, Decimal fiscalYear, String eventTypeId) {
    List<EventConstituentRoleViews__x> coordEventInfo = new List<EventConstituentRoleViews__x>();

        if (Test.isRunningTest()) {
                if (String.isNotBlank(consId)) {
                        coordEventInfo.add(new EventConstituentRoleViews__x(
                            ConstituentID__c  = consId
                            , StartDate__c = DateTime.now()
                            , EndDate__c = DateTime.now()
                            , RoleName__c = 'RoleName'
                            , FiscalYear__c = 1234
                        ));
                }
            }
        if (String.isNotBlank(consId)) {
                    coordEventInfo = [
                        select
                             ConstituentID__c
                            , EventID__c
                            , StartDate__c
                            , EndDate__c
                            , RoleName__c
                            , FiscalYear__c
                        from
                            EventConstituentRoleViews__x 
                        where 
                            ConstituentID__c = :consId 
                            and RoleName__c = 'Coordinator'
                            and EventTypeID__c = :eventTypeId
                            and FiscalYear__c = :fiscalYear];
                }
        return coordEventInfo;
    } 

    public static List<SurveyQuestionOptions__x> getSurvQuestOptByQuestId(Decimal questId) { 
    List<SurveyQuestionOptions__x> survQuestOpts = new List<SurveyQuestionOptions__x>();

        if (Test.isRunningTest()) {
            survQuestOpts.add(new SurveyQuestionOptions__x(
                OptionLabel__c = 'label',
                OptionSortOrder__c = 0,
                OptionValue__c = 'test',
                QuestionId__c = questId
            ));
        }                 
        else {
            survQuestOpts = [
                select                    
                    OptionLabel__c,
                    OptionSortOrder__c,
                    OptionValue__c,
                    QuestionId__c
                from
                    SurveyQuestionOptions__X
                where 
                    QuestionId__c = :questId
                order by
                    OptionSortOrder__c];        
        }

        return survQuestOpts;
    }
    
    public static List<Interactions__x> getInteractions(Decimal accountId, String sourceCode) { 
        List<Interactions__x> interactions = new List<Interactions__x>();

        if (Test.isRunningTest()) {
            interactions.add(new Interactions__x(
                ACCOUNT_ID__c = 123456,
                CONTACT_DATE__c = DateTime.now(),
                CONTACT_SEQ__c = 1,
                PAGE__c = 1
            ));
        }                 
        else {
            interactions = [
                select                    
                    ACCOUNT_ID__c,
                    CONTACT_DATE__c,
                    CONTACT_SEQ__c,
                    PAGE__c,
                    CONTACT_CATEGORY__c,
                    CONTACT_TYPE__c,
                    RESPONSE_CATEGORY__c,
                    RESPONSE_TYPE__c
                from
                    Interactions__x
                where 
                    ACCOUNT_ID__c = :accountId and 
                    Source__c = :sourceCode
                order by
                    CONTACT_DATE__c ];        
        }

        return interactions;
    }

    public static List<FOInteractions__x> getFOInteraction(domainSoapStjudeOrg.Interaction i, Decimal accountId, Decimal nameId) { 
        List<FOInteractions__x> interactions = new List<FOInteractions__x>();

        if (Test.isRunningTest()) {
            interactions.add(new FOInteractions__x(
                AccountID__c = 123456,
                CONTACT_DATE__c = DateTime.now(),
                CONTACT_SEQ__c = 1,
                PAGE__c = 1,
                Name_ID__c = 1

            ));
        }                 
        else {
            interactions = [
                select
                    InteractionID__c, CreatedBy__c, CreatedDate__c
                from
                    FOInteractions__x
                where 
                    AccountId__c = :accountId and
                    CONTACT_DATE__c = :DateTime.valueOf(i.ContactDate) and
                    CONTACT_SEQ__c = :i.ContactSeq and
                    PAGE__c = :i.Page_x and
                    Name_ID__c = :nameId];        
        }

        return interactions;
    }


    public static List<Reasons__x> GetReasons () {
        List<Reasons__x> lstReasons = new List<Reasons__x>();

        if (Test.isRunningTest()) {
            lstReasons.add(new Reasons__x(
                ReasonID__c = Guid.createGuid()
                , Reason1__c = 'TESTREASON'
            ));
        }
        else {
            lstReasons = [
                select 
                    ReasonID__c
                    , Reason1__c 
                from
                    Reasons__x
                order by
                    Reason1__c];
        }
        return lstReasons;
    } 

    public static List<Statuses__x> GetStatus () {
        return GetStatus(null);
    } 

    public static List<Statuses__x> GetStatus (String StatusID) {
        List<Statuses__x> lstStatus = new List<Statuses__x>();

        if (Test.isRunningTest()) {
            lstStatus.add(new Statuses__x(
                StatusID__c = Guid.createGuid()
                , Status1__c = 'TESTSTATUS'
            ));
        }
        else {
            if (String.isBlank(StatusID)) {
                lstStatus = [
                    select 
                        StatusID__c
                        , Status1__c 
                    from
                        Statuses__x
                    order by
                        Status1__c];
            }
            else {
                lstStatus = [
                    select 
                        StatusID__c
                        , Status1__c 
                    from
                        Statuses__x
                    where
                        StatusID__c = :StatusID
                    order by
                        Status1__c];   
            }
        }
        return lstStatus;
    } 

    public static List<ConstituentRevenueNotes__x> GetRevenueNotes (String ConstituentID, Integer off, Integer lim) {
        List<ConstituentRevenueNotes__x> revNotes = new List<ConstituentRevenueNotes__x>();

        if (Test.isRunningTest()) {
            revNotes.add(new ConstituentRevenueNotes__x(
                FinancialTransactionID__c = Guid.createGuid()
            ));
        }
        else {
            revNotes = [
                select  FinancialTransactionID__c
                from ConstituentRevenueNotes__x
                where ConstituentID__c = :ConstituentID
                order by FinancialTransactionID__c
                limit :lim offset :off];   
        }
        System.debug('revNotes = ' + revNotes);
        return revNotes;
    } 

    @TestVisible private static void buildHttpRequest(String method, String endpoint, Boolean isNewRecord, String recordGuid, String jsonString) {
        buildHttpRequest(method, endpoint, isNewRecord, recordGuid, jsonString, false);   
    }

    @TestVisible private static void buildHttpRequest(String method, String endpoint, Boolean isNewRecord, String recordGuid, String jsonString, Boolean isDelete) {
        //replace __c and weird time format for .net consumption
        jsonString = jsonString.replace('__c', '');
        jsonString = jsonString.replace('+0000', 'Z');

        System.debug('json=' + jsonString);
        System.debug('isnewrecord' + isNewRecord);
        String fullEndpoint = BASE_URL + endpoint;
        System.debug('fullEndpoint BASE_URL  = ' + BASE_URL);
        System.debug('fullEndpoint  endpoint = ' + endpoint);
        if(!isNewRecord) {
            fullEndpoint += '(guid\'' + recordGuid + '\')';
        }
       if(!Test.isRunningTest()){
            HttpRequest request = new HttpRequest();
            request.setEndpoint(fullEndpoint);
            
            System.debug('fullEndpoint = ' + fullEndpoint);
            Blob headerValue = Blob.valueOf(USERNAME+':' +PASSWORD);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            system.debug('Encoder Value' + EncodingUtil.base64Encode(headerValue));
            request.setHeader('Authorization', authorizationHeader);
            
            System.debug('full Endpoint=' + request.getEndpoint());
            request.setMethod(method);
            request.setTimeout(TIMEOUT_MS);
    
            request.setHeader('Content-Type', 'application/json');
            if(!isNewRecord) {
                if(isDelete) {
                    request.setHeader('DELETE', 'data');
                }
                else {
                    request.setHeader('POSTPATCH', 'data');
                }
            }
            if(jsonString != null) {
                request.setBody(jsonString);
            }
    
            Http http = new Http();
            HttpResponse response = http.send(request);
            system.debug('request = ' + request);
            system.debug('request body= ' + request .getBody());
    
            validateResponse(response);
        }
    }

    private static void validateResponse(HttpResponse response) {
        if(response.getStatusCode() >= 300) {
            system.debug('response.getBody()' + response.getBody()); //OMG - SO HELPFUL
            throw new HttpResponseException('Received status code ' + response.getStatusCode());
        }
    }

    private class HttpResponseException extends Exception {}
}