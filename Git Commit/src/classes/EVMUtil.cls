public without sharing class EVMUtil {
    public static List<ConstituentInformation__c> getConstituentInformationByCase (string consId, string caseId) {
        return getConstituentInformationByCase(consId, caseId, null);
    }

    public static List<ConstituentInformation__c> getConstituentInformationByCase (string consId, string caseId, domainSoapStjudeOrg.Constituent con) {
        List<ConstituentInformation__c> cis = [
            select id, ConstituentId__c, Preferred__c from ConstituentInformation__c where CaseId__c = :caseId
            order by Preferred__c desc];

        system.debug('EVMUtil.getConstituentInformationByCase cis.size(): ' + string.valueOf(cis.size()));
        return cis;
    }

    public static List<ConstituentInformation__c> getConstituentInformationByConsInfo(consInfo ci) {
        List<ConstituentInformation__c> cis;
        if (ci.objectType == 'Case') {
            cis = getConstituentInformationByCase(ci.consId, ci.objectId);
        }
        else {
            ConstituentInformation__c consInfos = new ConstituentInformation__c();
            consInfos.ConstituentID__c = ci.consId;
            consInfos.Preferred__c = true;
            cis = new ConstituentInformation__c[] { consInfos };
        }
        return cis;
    }

    public static Case clearCons(string caseId) {
        system.debug(caseId);
        List<Case> cases = EVMUtil.getCurrCase(caseId);
        Case resetCase;

        if (cases.size() > 0) {
            resetCase = cases.get(0);
            EVMUtil.createTask(caseId, 'Removed Constituent', 'Completed', 
                resetCase.ConstituentId__c, new String[] { 'Preferred Constituent Id = ' + resetCase.ConstituentId__c,
                'UUID = ' + resetCase.ConstituentUUID__c}, 
                new String[] { '', '' });
            resetCase.ConstituentId__c = '';
            resetCase.ConstituentUUID__c = '';
            resetCase.ConstituentType__c = '';
            resetCase.Constituent_Name__c = '';

            removeConsIds(resetCase);

            update resetCase;
        }
        return resetCase;
    }

    public static Case resetCaseConstituent(Case c, string selectUUID, string consName, string consType, string relConsId){

        Case retCase = setCaseConstituent(c, selectUUID, consName, consType, relConsId);

        EVMUtil.createTask(retCase.Id, 'Removed Constituent', 'Completed', 
            retCase.ConstituentId__c, new String[] { 'Preferred Constituent Id = ' + retCase.ConstituentId__c,
            'UUID = ' + retCase.ConstituentUUID__c}, 
            new String[] { '', '' });

        return retCase;
    }

  public static void removeConsIds(Case c) {
    if (string.isnotempty(c.id)) {
        List<ConstituentInformation__c> cInfo = [
            select id from ConstituentInformation__c where CaseId__c = :c.Id
        ];
        delete cInfo;
    }
  }
    public static Case setCaseConstituent(Case c, string selectUUID, string consName, string consType, string relConsId) {
        return setCaseConstituent(c, selectUUID, consName, consType, relConsId, null);
    }

    public static Case setCaseConstituent(Case c, string selectUUID, string consName, string consType, string relConsId, string selectConsId) {
        if (selectUUID == null || selectUUID == '') {
            try {
                domainSoapStjudeOrg.Constituent con = FOUtil.GetConstituent(null, relConsId, null, 'ALL');
                selectUUID = con.UUID;
                consType = con.Type_x.Code;
            }
            catch(Exception e) {
                //eat it.  :\
            }
        }
        c.ConstituentUUID__c = selectUUID;
        c.ConstituentId__c = selectConsId;
      //  if ( String.isEmpty(c.origin) || c.origin.toLowerCase() != 'research' ) {
            c.Constituent_Name__c = consName;
       // } 
        c.ConstituentType__c = consType.toUpperCase();

        //get the constituent ids
        LIST<String> consIds;
        try {
            consIds = FOUtil.getConstituentIds(c.ConstituentUUID__c, true); 
        }
        catch(Exception e) {
            //eat it :/
            consIds = new string[] { selectConsId };
        }
        system.debug('consIds length: ' + consIds.size());
        
        removeConsIds(c);

        upsert c;

        //create the constituent informations to house the constituent ids for this uuid upon selection
        createConstituentInfos(consIds, c.ConstituentUUID__c, c.Id, c.ConstituentId__c);
        createTask(c.Id, 'Selected Constituent', 'Completed', 
            c.ConstituentId__c, new String[] { '' }, new String[] { c.ConstituentId__c });
        //}
        return c;
    }

    public static List<ConstituentInformation__c> createConstituentInfos(string uuId, string caseId, string prefConsId) {
        return createConstituentInfos(null, uuId, caseId, prefConsId);
    }

    public static List<ConstituentInformation__c> createConstituentInfos(List<String> consIds, string uuId, string caseId, string prefConsId) {
        List<ConstituentInformation__c> cis = new List<ConstituentInformation__c>();
        boolean upsertCis = consIds != null;
        if (!upsertCis) {
            system.debug('getting constituent ids');
            consIds = FOUtil.getConstituentIds(uuId); 
        }
        for(String cId : consIds) {
            cis.add(new ConstituentInformation__c(CaseId__c = caseId, ConstituentId__c = cId, Preferred__c = (cId == prefConsId)));
        }
        if (upsertCis) upsert cis;
        return cis;
    }

    public static String formatPhone(String phone) {
        phone = deFormatPhone(phone);
        //0123456789
        return String.format('({0}) {1}-{2}', 
            new String[] {phone.substring(0, 3), phone.substring(3, 6), phone.substring(6)});
    }

    public static String deFormatPhone(String phone) {
        return phone.replaceAll('[^0-9]', '');
    }

    public static string getToken() {
        string now = datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss') + 'Z';
        
        return 
            EncodingUtil.urlEncode(
            Encodingutil.base64Encode(Blob.valueOf(
            now + '|' +
            EncodingUtil.convertToHex(Crypto.generateDigest('MD5', 
            Blob.valueOf(
                now + '|loquacious lisa likes lilting locutions'))))),
                'UTF-8');
    }

    public static string getToken(string key) {
        string now = datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss') + 'Z';
        
        return 
            EncodingUtil.urlEncode(
            Encodingutil.base64Encode(Blob.valueOf(
            now + '|' +
            EncodingUtil.convertToHex(Crypto.generateDigest('MD5', 
            Blob.valueOf(
                now + '|' + key))))),
                'UTF-8');
    }
    
    public static LIST<SelectOption> getConstituentIdsForSelect(List<ConstituentInformation__c> consIds) {
        LIST<SelectOption> so = new LIST<SelectOption>();
        Integer i = 0;
        for(ConstituentInformation__c ci : consIds) {
            i++;
            so.add(new SelectOption(ci.ConstituentID__c, string.valueof(i)));
        }
        return so;
    }

    public static LIST<SelectOption> getSelectFromFOAtt(objectSoapStjudeOrg.Attribute[] atts) {
        return getSelectFromFOAtt(atts, true);
    }
    
    public static LIST<SelectOption> getSelectFromFOAtt(objectSoapStjudeOrg.Attribute[] atts, Boolean name) {
        LIST<SelectOption> so = new LIST<SelectOption>();
        if (atts != null && atts.size() > 0) {
            for(objectSoapStjudeOrg.Attribute att : atts) {
                if((name ? att.Name : att.Id) != null) {
                    so.add(new SelectOption(name ? att.Name : att.Id, att.Desc_x));
                }
            }
        }
        so.sort();
        return so;
    }

    public static void compareBeforeAfter(List<String> before, List<String> after) {
        for(Integer i = before.size() - 1; i >= 0; i--) {
            if (before.get(i) == after.get(i)) {
                before.remove(i);
                after.remove(i);
            }
        }
    }

    public static void createTask(string caseId, string subject, string status, string contId,
        list<string> before, list<string> after) {
        String bef = '';
        String aft = '';
        if (before != null && after != null) {
            EVMUtil.compareBeforeAfter(before, after);
            bef = String.join(before, '\n');
            aft = String.join(after, '\n');
        }
            
        Task newTask = new Task();
        
        newTask.WhatId = caseId;
        newTask.Subject = subject;
        newTask.BeforeValues__c = bef.substring(0, Math.min(bef.length(), 255));
        newTask.AfterValues__c = aft.substring(0, Math.min(aft.length(), 255));
        newTask.Status = status;
        newTask.Description = contId;
        
        insert newTask;
    }

    public static void createTask(consInfo ci, string subject, string status, string contId,
        list<string> before, list<string> after) {
        String bef = '';
        String aft = '';
        if (before != null && after != null) {
            EVMUtil.compareBeforeAfter(before, after);
            bef = String.join(before, '\n');
            aft = String.join(after, '\n');
        }
        
        Task newTask = new Task();
        
        if (ci.objectType == 'Case') newTask.WhatId = ci.objectId;
        else newTask.WhoId = ci.objectId;
        newTask.Subject = subject;
        newTask.BeforeValues__c = bef.substring(0, Math.min(bef.length(), 255));
        newTask.AfterValues__c = aft.substring(0, Math.min(aft.length(), 255));
        newTask.Status = status;
        newTask.Description = contId;
        
        insert newTask;
    }

    public static Task createTask(Opportunity opp, String subject, String status, String aftervalue, String coordId) {
        
        Task newTask = new Task();   
        newTask.WhatId = opp.Id;
        newTask.Subject = subject;
        newTask.AfterValues__c = aftervalue;
        newTask.Status = status;
        newTask.Description = coordId;
        
        return newTask;
    }

    public static List<Case> getCurrCase(String caseId) {
//        return [select id, ConstituentUUID__c, ConstituentID__c, Case.ConstituentType__c, Case.Origin,
        return [select id, recordTypeId, ConstituentUUID__c, ConstituentID__c, Constituent_Name__c, Case.ConstituentType__c, Case.Origin,
            Case.Technique_Method__c, SuppliedEmail from case where id = :caseId];
    }

    public static domainSoapStjudeOrg.SystemXRef getXrefFromLead(Lead currLead) {
        String xref = '|0';  //default to name line 0
        domainSoapStjudeOrg.Constituent con;

        if (currLead.name_id__c != null) {
            xref = '|' + currLead.name_id__c;
        }
        xref = currLead.account_id__c + xref;
        domainSoapStjudeOrg.SystemXRef xr = new domainSoapStjudeOrg.SystemXRef();
        domainSoapStjudeOrg.Sys sys = new domainSoapStjudeOrg.Sys();

        sys.Name = 'TA';

        xr.XRefKey = xref;
        xr.Sys = sys;
        return xr;
    }

    public static SSLeads getCurrLead(String leadId) {
        //Campaign.RoleId__c,
        //Campaign.RoleTypeId__c,
        //Campaign.EventTypeId__c,
        List<Lead> cms = [
            select 
                Id 
                , ConstituentID__c
                , Constituent_Type__c
                , account_id__c
                , name_id__c
                , Technique_Method__c
                , TR_ID__c
                , EventID__c
                , Name
                , CheckedIn__c
                , CheckInPaymentAmount__c
                , CheckInNotes__c
                , TransSourceCode__c
                , CurrentCampaign__r.Event_Type__c
                , CurrentCampaign__r.Evaluated_EventTypeID__c
                , CurrentCampaign__r.Evaluated_EventID__c
                , CurrentCampaign__r.Evaluated_EVM_EventID__c
                , CurrentCampaign__r.EventsMasteringPath__c
                , CurrentCampaign__r.EvaluatedEventsMasteringPath__c
                , CurrentCampaign__r.DGGCampaignId__c
                , CurrentCampaign__r.EvaluatedDGGCampaignId__c
                , CurrentCampaign__r.TRSurveyQuestionId__c
                , CurrentCampaign__r.EvaluatedTRSurveyQuestionId__c
                , CurrentCampaign__r.AllowOTCheckPledges__c
                , CurrentCampaign__r.CCDonate_Gift_ID__c
                , CurrentCampaign__r.CCDonate_Recommit_ID__c
                , CurrentCampaign__r.FitDay_Enabled__c
                , CoordinatorID__c
                , xref__c
                , Phone
            from 
                Lead 
            where 
                Id = :leadId];
        SSLeads retLeads;

        if (cms.size() == 1) {
            retLeads = new SSLeads();
            
            retLeads.SSLead = cms[0];
        }
        system.debug('retLeads = ' + retLeads);
        return retLeads;
    }

    public static DateTime JavaDateStringToDateTime(String dt) {
        //2013-04-24T05:00:00.000Z
        system.debug('JavaDateStringToDate: ' + dt);
        return (DateTime)json.deserialize(dt, DateTime.class);
    }

    public static DateTime JavaDateStringToDate(String inDate) {
        //2013-04-24T05:00:00.000Z
        Date dateRes = null;
        //  1 - Try locale specific mm/dd/yyyy or dd/mm/yyyy    
        try {
            String candDate = inDate.substring(0,Math.min(10,inDate.length()));// grab date portion only m[m]/d[d]/yyyy , ignore time
            system.debug('candDate: ' + candDate);
            dateRes = Date.parse(candDate);
            system.debug('dateRes: ' + dateRes);
        }
        catch (Exception e) {}

        if (dateRes == null) {
            //  2 - Try yyyy-mm-dd          
            try {
                String candDate = inDate.substring(0,10);           // grab date portion only, ignore time, if any
                system.debug('candDate: ' + candDate);
                dateRes = Date.valueOf(candDate);
                system.debug('dateRes: ' + dateRes);
            }
            catch (Exception e) {} 
        }

        return dateRes;
    }

    public static Set<id> GetUserIdsFromGroup(Id groupId) {
        // store the results in a set so we don't get duplicates
        Set<Id> result=new Set<Id>();
        String userType = Schema.SObjectType.User.getKeyPrefix();
        String groupType = Schema.SObjectType.Group.getKeyPrefix();

        // Loop through all group members in a group
        for (GroupMember m : [Select Id, UserOrGroupId From GroupMember Where GroupId = :groupId])
        {
            // If the user or group id is a user
            if (((String)m.UserOrGroupId).startsWith(userType))
            {
                result.add(m.UserOrGroupId);
            }
            // If the user or group id is a group
            // Note: there may be a problem with governor limits if this is called too many times
            else if (((String)m.UserOrGroupId).startsWith(groupType))
            {
                // Call this function again but pass in the group found within this group
                result.addAll(GetUSerIdsFromGroup(m.UserOrGroupId));
            }
        }

        return result;  
    }

    static public void createDeceasedPrefs(String consId, boolean noMail, String technique, String name) {
        system.debug('createDeceasedPrefs');
        String prefIdNoPhone = null,
            prefIdNoMail = null;

        domainSoapStjudeOrg.Preference[] prefs = FOUtil.getPreferences(consId);

        if (prefs != null) {
            for(domainSoapStjudeOrg.Preference pref : prefs) {
                if (pref.Preference == 'MAIL' && pref.PreferenceType == 'MAIL') {
                    prefIdNoMail = pref.PreferenceId;
                }
                if (pref.Preference == 'PHONE_PREF' && pref.PreferenceType == 'PHONE') {
                    prefIdNoPhone = pref.PreferenceId;
                }
            }
        }
        
        if(noMail) {
            system.debug('add no mail');
            FOUtil.editPreference(
                consId, prefIdNoMail, 'MAIL', 'N', 'MAIL',
                null, null, null, null, 'A');
            createInt(consId, technique, 'SM', 'NOMAIL', 'No mail preference added at request of bereaved.');
        }

        createInt(consId, technique, 'DS', 'NOPHONE', 'No phone preference added. Deceased donor.');
        createInt(consId, technique, 'AU ', 'DECEASED', name + ' as deceased.');
        system.debug('add no phone');
        FOUtil.editPreference(
            consId, prefIdNoPhone, 'PHONE_PREF', 'N', 'PHONE',
            null, null, null, null, 'A');
    }

    static public void createInt(String consId, String technique, String contactCategory, String contactType, String longComments) {
        domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();

        i.ContactDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        i.Page_x = 1;
        i.ContactCategory = contactCategory;
        i.ContactType = contactType;

        i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
        i.TransactionSource.Technique = technique;
        i.LongComments = longComments;

        system.debug('i.ContactDate = ' + i.ContactDate +
            '\ni.Page_x = ' + i.Page_x +
            '\ni.ContactCategory = ' + i.ContactCategory +
            '\ni.ContactType = ' + i.ContactType +
            '\ni.TransactionSource.Technique = ' + i.TransactionSource.Technique +
            '\ni.LongComments = ' + i.LongComments);

        FOUtil.createInteraction(consId, i);
    }

    static public consInfo getConsInfo(String id) {
        return getConsInfo(id, 'ORG');
    }

    static public consInfo getConsInfo(String id, String leadType) {
        consInfo ci = new consInfo();
        ci.objectId = id;
        ci.objectType = getTypeById(id);

        system.debug('id: ' + id + ', object type: ' + ci.objectType);
        if (ci.objectType == 'Case') {
            Case c = getCurrCase(id).get(0);
            ci.consId = c.ConstituentId__c;
            ci.consType = c.ConstituentType__c;
            ci.technique = c.Technique_Method__c;
        }
        else if (ci.objectType == 'Lead') {
            SSLeads currLead = getCurrLead(id);
            if (String.isNotBlank(leadType) && leadType.toUpperCase() == 'COORDINATOR') {
                ci.ConsId = currLead.SSLead.CoordinatorID__c;
            }
            else {
                ci.ConsId = currLead.SSLead.ConstituentID__c;
            }

            domainSoapStjudeOrg.Constituent con = FOUtil.getConstituent(null, ci.ConsId, null);
            ci.consType = con.Type_x.Code.toUpperCase();
            ci.technique = currLead.SSLead.Technique_Method__c;
        }
        return ci;
    }

    static public String getTypeById(String id) {
        String myIdPrefix = String.valueOf(id).substring(0,3); //get just the prefix
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
        String objectType = '';

        for(Schema.SObjectType stype : gd.values())
        {
            Schema.DescribeSObjectResult r = stype.getDescribe();
            String prefix = r.getKeyPrefix();

            if(prefix!=null && prefix.equals(myIdPrefix))
            {
                System.debug('Stop hammer time! ' + r.getName());
                objectType = r.getName();
                break;
            }
        }
        return objectType;
    }

    public static Id CreateLeadReferral(ID campaignId, String selectConsId, String consType, String consName, 
        String recordTypeId, String phoneNumber) {
        //RecordType rt = [select id from RecordType where DeveloperName = 'St_Jude_Challenge' and SObjectType = 'Lead'];

        Lead l = new Lead (
                RecordTypeId = recordTypeId
                , LastName = consName
                , CurrentCampaign__c = campaignId
                , Status = 'Open'
                , Company = 'ALSAC'
                , Phone = phoneNumber
            );
        if (consType == 'Individual') {
            //it's the coordinator
            l.CoordinatorID__c = selectConsId;
        }
        else if (consType == 'Organization') {
            //it's the organizer
            l.ConstituentID__c = selectConsId;
        }
        else {
            throw new EVMException('You must choose an Individual (\'Coordinator\') or Organization (\'Organizer\').');
        }

        insert l;
        return l.Id;
    }

    public static void ReplaceCoordinator(EVMUtil.SSLeads currLead, String selectConsId) {
        List<RecordType> rts = [select id from RecordType where DeveloperName = 'St_Jude_Challenge'];
        currLead.SSLead.CoordinatorID__c = selectConsId;
        if (rts.size() > 0 && currLead.SSLead.RecordTypeId == rts.get(0).Id) {
            currLead.SSLead.Xref__c = currLead.SSLead.CoordinatorID__c + '|' + rts.get(0).Id;
        }
        update currLEad.SSLead;
    }

    public static void ReplaceCoordinator(String oppChangeCoord, String selectConsId) {
        EnvironmentSettings__c es = [
            SELECT 
                EVMCoordinatorRoleID__c
                , EVMActiveStatusID__c
                , EVMDeletedStatusID__c
            from
                EnvironmentSettings__c 
            where
                SetupOwnerId = :UserInfo.getOrganizationId()];

        List<Opportunity> opps = [select id, EventID__c from Opportunity where id = :oppChangeCoord];
        if (opps != null && opps.size() == 1) {
            Boolean bAlreadyExists = false;
            Opportunity opp = opps.get(0);
            List<EventConstituentRoles__x> ecrs = [
                select
                    EventConstituentRoleID__c,
                    EventConstituentID__r.ConstituentID__c,
                    EventTypeRoleID__r.RoleID__c,
                    StatusID__c
                from
                    EventConstituentRoles__x
                where
                    EventConstituentID__r.EventID__c = :opp.EventID__c
            ];
            for(EventConstituentRoles__x ecr : ecrs) {
                if (ecr.EventTypeRoleID__r.RoleID__c == es.EVMCoordinatorRoleID__c) {
                    Boolean bUpdate = true;
                    //loop through the constituent roles
                    if (ecr.EventConstituentID__r.ConstituentID__c != selectConsId) {
                        //we have one *and* the newly selected constituent isn't already the coordinator
                        //now eliminate this coordinator with extreme prejudice
                        ecr.StatusID__c = es.EVMDeletedStatusID__c;
                    }
                    else {
                        bAlreadyExists = true;
                        //so, looks like the user selected the guy who's already the coordinaotr
                        if (ecr.StatusID__c == es.EVMActiveStatusID__c) {
                            //nothing to do.  this guy's already the constituent and the role is active
                            bUpdate = false;
                        }
                        else {
                            //it was a coordinators, but it had been 'deleted'
                            ecr.StatusID__c = es.EVMActiveStatusID__c;
                        }
                    }
                    //if we got here, then update the thing
                    if (bUpdate) OdataExtension.saveEventConstituentRole(ecr.EventConstituentRoleID__c, ecr);
                }
            }
            if (!bAlreadyExists) {
                String ecId = '';
                Boolean updateEventCons = true;
                //see if we already have an event constituent for this combination
                List<EventConstituents__x> ecs = [
                    select 
                        EventConstituentID__c,
                        EventID__c, 
                        ConstituentID__c
                    from 
                        EventConstituents__x 
                    where
                        EventId__c = :opp.EventID__c
                        and ConstituentID__c = :selectConsId];
                //get the event for the event type id
                Events__x ev = [select EventID__c, EventTypeID__c from Events__x where EventID__c = :opp.EventID__c];
                //get the coordinator event type role
                EventTypeRoles__x etr = [
                    select 
                        EventTypeRoleID__c
                    from 
                        EventTypeRoles__x 
                    where
                        EventTypeID__c = :ev.EventTypeID__c
                        and RoleID__c = :es.EVMCoordinatorRoleID__c
                        ];
                EventConstituents__x ec;
                if (ecs.size() > 0) {
                    //if we have an event constituent
                    ec = ecs.get(0);
                    ecId = ec.EventConstituentID__c;
                    if (ec.StatusID__c != es.EVMActiveStatusID__c) {
                        //activate it if it's not active
                        ec.StatusID__c = es.EVMActiveStatusID__c;
                    }
                    else {
                        //if it's active, we're good!
                        updateEventCons = false;
                    }
                }
                else {
                    //no event constituent, create a new one
                    ec = new EventConstituents__x();
                    ec.EventID__c = opp.EventID__c;
                    ec.ConstituentID__c = selectConsId;
                    ec.StatusID__c = es.EVMActiveStatusID__c;
                }
                if (updateEventCons) {
                    //upsert the event constituent
                    ecId = OdataExtension.saveEventConstituent(ecId, ec);
                }

                //create the event constituent role
                EventConstituentRoles__x newECR = new EventConstituentRoles__x();
                newECR.EventConstituentID__c = ecId;
                newECR.StatusID__c = es.EVMActiveStatusID__c;
                newECR.EventTypeRoleID__c = etr.EventTypeRoleID__c;
                OdataExtension.saveEventConstituentRole('', newECR);
            } 
        }
        else {
            //what are you doing!?
            throw new EVMUtil.EVMException ('Opportunity not set or doesn\'t exist');
        }
    }

    @future(callout=true)
    public static void processInteractionsFuture(Set<String> dispositions, Set<String> whoIds, Set<String> taskIds){
        processInteractions(dispositions, whoIds, taskIds);
    }

    public static void processInteractions(Set<String> dispositions, Set<String> whoIds, Set<String> taskIds){
        List<Lead> leadList = [select id, account_id__c, constituentid__c, TransSourceCode__c, CurrentCampaign__c from lead where id in :whoIds];
        Set<String> campIds = new Set<String>();
        system.debug('leadList.size(): ' + leadList.size());
        for(Lead ld : leadList){
            campIds.add(ld.CurrentCampaign__c);
        }
        system.debug('campIds.size(): ' + campIds.size());

        List<CampaignDispConfig__c> dispositionsSet = [
            select disp__c, Action__c, Campaign__c, ContCat__c, ContType__c, Filter__c, RespCat__c, RespType__c, Effort__c 
            from CampaignDispConfig__c where disp__c = :dispositions and Campaign__c in :campIds ];

        system.debug('dispositionsSet.size(): ' + dispositionsSet.size());
        if(dispositionsSet.size() > 0){
            List<Task> taskList = [Select CallDisposition, WhoId from Task where id in :taskIds];
            system.debug('taskList.size(): ' + taskList.size());
            for(Task tsk : taskList){
                for(Lead ld : leadList){
                    if(ld.Id == tsk.WhoId){
                        for(CampaignDispConfig__c dispConfig : dispositionsSet ){
                            if(dispConfig.disp__c == tsk.CallDisposition && dispConfig.Campaign__c == ld.CurrentCampaign__c){
                               processInteraction(ld, tsk, dispConfig);
                            }
                        }
                    }   
                }
            }
        }
    }

    private static void processInteraction(Lead ld, Task tsk, CampaignDispConfig__c dispConfig){
        String sourceCode = getSourceCode(dispConfig.Effort__c, ld.TransSourceCode__c);
        if(dispConfig.Action__c == 'Add Interaction'){
            FOUtil.createInteraction(ld.constituentid__c, ld.Id, dispConfig.ContCat__c, dispConfig.ContType__c, null, dispConfig.RespCat__c, 
                dispConfig.RespType__c, null, null, null, sourceCode);
        }
        else if(dispConfig.Action__c == 'Update Interaction'){
            List<Interactions__x> interactions = OdataExtension.getInteractions(Decimal.valueOf(ld.account_id__c), sourceCode);
            if(interactions.size() > 0){
                Interactions__x inte = interactions.get(0);
                FOUtil.editInteraction(ld.constituentid__c, inte.CONTACT_DATE__c.formatGMT('yyyy-MM-dd HH:mm:ss'), Integer.ValueOf(inte.CONTACT_SEQ__c), 
                    Integer.ValueOf(inte.PAGE__c), dispConfig.ContCat__c, dispConfig.ContType__c, null, dispConfig.RespCat__c, dispConfig.RespType__c,
                    sourceCode);
            }
        }
    }

    private static String getSourceCode(String effort, String sourceCode){
        if(String.isNotBlank(effort) && String.isNotBlank(sourceCode) && sourceCode.length() >= 9){
             sourceCode = sourceCode.Substring(0, 7) + effort + sourceCode.Substring(9); 
        }
        return sourceCode;
    }

    public class SSLeads {
        public Lead SSLead { get; set; }
        public String EventTypeId { get; set; }
        public String EventRoleId { get; set; }
    }

    public class consInfo {
        public String consId { get; set; }
        public String consType { get; set; }
        public String objectType { get; set; }
        public String objectId { get; set; }
        public String technique { get; set; }
    }

    public class EVMException extends Exception {
        
    }
}