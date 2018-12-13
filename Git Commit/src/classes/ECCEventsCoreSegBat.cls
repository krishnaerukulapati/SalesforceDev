global class ECCEventsCoreSegBat implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {

    //globals
    //-------------------------------------------------------------------------------------
    global String query;
    global Boolean errorOnInit;

    //parent campaign
    global Campaign cParent;

    //campaign account - Ex: ALSAC Challenge
    global Account cAccount;
    global RecordType cRecordType;

    //report and error email settings
    global static final String fromEmail = 'josh.hovey@stjude.org';
    global static final String fromName = 'Hovey';

    global String defaultStage = 'Staged';

    //list of campaigns under the parent support campaign
    global List<Campaign> segments;
    global Map<String, Integer> segCounts = new Map<String, Integer> ();

    //list of opp stage probabilities
    global Map<String, Double> oppProbs;

    //event statuses for cancelled events
    global final String cancelled = '59311144-A18E-4F50-9E74-AE3DD6B4C096';
    global final String systemCancelled = '19DC3506-66F7-48BE-8ADD-5343E3F34EFE';
    //-------------------------------------------------------------------------------------

    //constructors
    //-------------------------------------------------------------------------------------

    //workflow constructor
    global ECCEventsCoreSegBat(String parentCampId) {

        //prepare for the worst
        errorOnInit = true;

        system.debug('init ECCEventsCoreSegBat for ' + parentCampId);

        //get list of parent campaigns by Id; ideally there would only be 1
        List<Campaign> parents=new List<Campaign>();
        if(parentCampId!=null){
            parents = [select Id, EventId__c, EndDate, OppRecordType__c, OppAcc__r.id, Name from Campaign where Id = :parentCampId];
        }
        //make sure there's only 1
        if (parents.size() == 1) {
            //get parent from list
            cParent = parents.get(0);

            system.debug('found parent campaign');

            //get parent's record type
            //List<RecordType> rTypes = [select Id from RecordType where sObjectType = 'Opportunity' and DeveloperName = :cParent.OppRecordType__c];

            //make sure there's only 1
            //if (rTypes.size() == 1) {
                //get parent campaign record type from list
                //cRecordType = rTypes.get(0);

                //make sure parent has account set
                if (cParent.OppAcc__c != null) {

                    system.debug('found account');

                    //get parent campaign account
                    cAccount = cParent.OppAcc__r;

                    //get the child campaigns from support parent
                    segments = [
                        select
                        Id, Name, SegName__c, SegFiltRev__c, SegFiltReg__c, SegFiltPart__c,
                        SegStageName__c, SegHrsToWait__c, AllowPreStages__c, SegTeamCaptain__c,
                        SegDaysFromEvent__c, IsSegSendKit__c
                        from
                        Campaign
                        where
                        ParentId = :cParent.Id
                        and IsSeg__c = true
                        order by SegAppOrder__c
                    ];

                    system.debug('child campaigns = ' + segments);
                    system.debug('found ' + segments.size() + ' children');

                    //get opportunity stage probabilities
                    List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage];
                    oppProbs = new Map<String, Double> ();

                    //load stage probabilities for use
                    for (OpportunityStage os : oppStages) {
                        oppProbs.put(os.MasterLabel, os.DefaultProbability);
                    }

                    //new query, looks at Opps instead of Leads
                    query = 'select id, name, eventid__c, event_organizer__c, stagename, accountid, revenue__c, stagechanged__c, Recruited_Date__c, recruited_fy__c, recordtypeid, campaignid, support_campaign__c, probability from Opportunity where (CampaignId = \'' + cParent.Id + '\' or Support_Campaign__c = \'' + cParent.Id + '\')';

                    system.debug(query);

                    //the worst didn't happen
                    errorOnInit = false;
                }
                else {
                    //error - malconfigured account
                    sendErrorEmail('Account not set on parent campaign', parentCampId);
                }
            //}
            //else {
            //  //error - missing record type
            //  sendErrorEmail('Missing record type, developer name \'' + cParent.OppRecordType__c + '\' was missing', parentCampId);
            //}
        }
        else {
            //error - malconfigured campaign
            sendErrorEmail('Malconfigured campaign, campaign \'' + parentCampId + '\' was missing', parentCampId);
        }
    }

    //batch methods
    //-------------------------------------------------------------------------------------

    //batch start - load query
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    //batch execute - should be about 15 records
    global void execute(Database.BatchableContext BC, List<sObject> scope) {

        //abort batch if an error occurred in constructor
        System.debug('errorOnInit ' + errorOnInit);
        if (errorOnInit) {
            System.abortJob(BC.getJobId());
        }

        //do all the stuff
        system.debug('execute');

        //declare a bunch of things we'll use

        //list of opportunities to save
        List<Opportunity> oppSave = new List<Opportunity> ();

        //list of campaign members to save
        List<CampaignMember> campMems = new List<CampaignMember> ();
        
        //leadskills to be created
        List<LeadSkill__c> ls = new List<LeadSkill__c> ();
        
        //Update existing leadskills records with dailerstatus value
        List<LeadSkill__c> oldls=new List<LeadSkill__c>();

        //list of campaign members we'll remove (going to try to just...update them first, see if that works)
        List<Id> campMemsRemove = new List<Id> ();

        //list of event IDs
        Set<String> eventIds = new Set<String> ();

        //list of event codes
        Set<String> eventCodes = new Set<String> ();

        //our opportunity
        Opportunity opp;

        //list of opps
        List<Opportunity> opps = new List<Opportunity> ();

        //lists of invalid objects
        List<Id> invalidOpps = new List<Id>();
        List<Id> invalidLeads = new List<Id>();
        List<Id> invalidCamps = new List<Id>();

        Map<Id, List<Task>> oppTasks = new Map<Id, List<Task>> ();
        
        //scope should be about 15
        system.debug('scope.size(): ' + scope.size());

        //loop through batch, creating a list of Opportunities
        for (sObject o : scope) {

            //get Opp from scope
            opp = (Opportunity) o;

            System.debug('Loaded Opportunity ' + opp.Id + ': ' + opp.Name);

            //make sure the Opp is a legitimate event
            if (String.isNotBlank(opp.EventID__c)) {
                System.debug('opp.EventID__c = ' + opp.EventID__c);

                //make sure event is attached to a lead
                if(opp.Event_Organizer__c != null) {
                    //add valid opp to list
                    opps.add(opp);
                    eventIds.add(opp.EventID__c);
                }               
            }
            else {
                //Opp not valid, ignore it
                System.debug('No event ID, not a valid Opp');
                IncrementCount('noOppEventCount');
            }
        }
        
        //get events using Odata
        List<Events__x> events = OdataExtension.GetEventsById(eventIds);

        //get event codes to print
        for (Events__x e : events) {
            eventCodes.add(e.EventCode__c);
            system.debug('eventCodes being processed this batch = ' + eventCodes);
        }

        String eventRevenue = '';
        Set<Id> Leadid=new Set<id>();
        Map<Id,Opportunity> oppMap=new Map<Id,Opportunity>();
        Map<Id,Lead> leadMap=new Map<Id,Lead>();
         //loop through list of Opporunities loaded from batch
        for (Opportunity opp1 : opps) {
            leadid.add(opp1.Event_Organizer__c);
            oppMap.put(opp1.Id,opp);
            System.debug('Opportunity: ' + opp1);
        }
        if(leadmap.size()>0){
            //get this Opp's Lead
            leadMap.putAll([select Id, name, ConstituentID__c, Coordinator__c, Email, DialerStatus__c from Lead where Id = :leadid]);
        }
        
        //getting the old leadskill records
        List<LeadSkill__c> oldrecords=new List<LeadSkill__c>();
        if(leadMap.size()>0 && oppMap.size()>0){
            oldrecords = [select id, Dialerstatus__c,Lead__c,Opportunity__c from LeadSkill__c where Lead__c  = :leadMap.keySet() AND Opportunity__c=:oppMap.keySet()] ;
        }
        
        for (Opportunity o : opps) {
        //if Opp doesn't have a lead, it is invalid
            if (leadMap.isEmpty() || leadMap == null||!leadMap.containsKey(o.Event_Organizer__c)){
                System.debug('Event Organizer is not set for Opp Id ' + o.Id);
                invalidOpps.add(o.Id);
                break;
            }
            
            //at the moment, it aint worth saving
            Boolean saveOpp = false;

            //get specific event for stuff
            Events__x e = getEvent(events, o);

            System.debug('e = ' + e);

            //determine event revenue
            if (e != null && e.EventID__C != null) {
                System.debug('e.EventID__C = ' + e.EventID__C);
                eventRevenue = getTotalRevenue(e.EventID__C.toUpperCase());
                System.debug('eventRevenue = ' + eventRevenue);
            }
            else {
                eventRevenue = '0';
                System.debug('eventRevenue = ' + eventRevenue);
            }

            System.debug('o.Revenue__c = ' + o.Revenue__c);
            System.debug('decimal.valueOf(eventRevenue) = ' + decimal.valueOf(eventRevenue));

            if (o.Revenue__c != decimal.valueOf(eventRevenue)) {
                //updating the event revenue is save worthy
                o.Revenue__c = decimal.valueOf(eventRevenue);
                saveOpp = true;
            }

            system.debug('so in case we forgot:');
            system.debug('list of available segments: ' + segments);
            System.debug('o.id' + o.Id);
            system.debug('o.StageName ' + o.StageName);

            //loop through all available child campaigns, see if any of their criteria is valid
            for (Campaign c : segments) {

                if(c == null) {
                    System.debug('Child campaign is null');
                    break;
                }
                
                //check for stage name
                if (String.isBlank(c.SegStageName__c)) {
                    System.debug('Child campaign ' + c.Id + ' missing Seg Stage Name');
                    System.debug(c);
                    invalidCamps.add(c.Id);
                    break;
                }

                //check for Allow Pre Stages
                if (String.isBlank(c.AllowPreStages__c)) {
                    System.debug('Child campaign ' + c.Id + ' missing Allow Pre Stages');
                    System.debug(c);
                    invalidCamps.add(c.Id);
                    break;
                }

                //check for Days From Event
                if (c.SegDaysFromEvent__c == null) {
                    System.debug('Child campaign ' + c.Id + ' missing Days From Event');
                    System.debug(c);
                    invalidCamps.add(c.Id);
                    break;
                }

                //check for Seg Hours To Wait
                if (c.SegHrsToWait__c == null) {
                    System.debug('Child campaign ' + c.Id + ' missing Seg Hours To Wait');
                    System.debug(c);
                    invalidCamps.add(c.Id);
                    break;
                }

                //get the current child's minimum probability, which keeps the Opp from moving backwards
                Double minProb = oppProbs.get(c.SegStageName__c);

                //describe the campaign, which helps troubleshoot configuration issues
                System.debug('c.Id ' + c.Id);
                System.debug('c.SegStageName__c = ' + c.SegStageName__c);
                System.debug('c.AllowPreStages__c = ' + c.AllowPreStages__c);
                System.debug('c.SegDaysFromEvent__c = ' + Integer.valueOf(c.SegDaysFromEvent__c));

                System.debug('DateTime.now() = ' + DateTime.now());
                System.debug('e.StartDate__c = ' + e.StartDate__c);

                System.debug('minProb = ' + minProb);
                System.debug('o.Probability = ' + o.Probability);

                if (o.Revenue__c == null) o.Revenue__c = 0;

                System.debug('c.SegFiltRev__c ' + c.SegFiltRev__c);
                System.debug('o.Revenue__c ' + o.Revenue__c);

                Boolean sendKitChecked = (e != null && e.SendKit__c == true);
                System.debug('sendKitChecked ' + sendKitChecked);

                //if today's date is before the event start date
                if (DateTime.now() <= e.StartDate__c && Integer.valueOf(c.SegDaysFromEvent__c) < 0) {
                    //this...this ridiculous thing...what even
                    if (
                        //does child require revenue
                        (
                            c.SegFiltRev__c == null || 
                            (o.Revenue__c > c.SegFiltRev__c)
                        )
                        //does child send kits
                        && (
                            c.IsSegSendKit__c != true || (
                                c.IsSegSendKit__c == true && 
                                sendKitChecked
                            )
                        )
                        //is the probability of child greater than opp
                        && o.Probability < minProb
                        //is child in allowed stages
                        && IsInList(c.AllowPreStages__c, o.StageName)
                        //has the opp waited long enough
                        && o.StageChanged__c.addHours((Integer) c.SegHrsToWait__c) < DateTime.now()
                        //check date stuff
                        && (
                            //either nothing is set, which is weird, or
                            c.SegDaysFromEvent__c == null || 
                            e.StartDate__c == null || 
                            (
                                //things are set, and
                                e.StartDate__c != null && 
                                c.SegDaysFromEvent__c != null && 
                                (
                                    //event hasn't happened, and child ranges are still negative (ex. days from event: -90)
                                    (
                                        DateTime.now() < e.StartDate__c && 
                                        DateTime.now() > e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))
                                    ) ||
                                    //event has happened, and child ranges are no longer negative (ex. days from event: 90)
                                    (
                                        DateTime.now() > e.StartDate__c &&
                                        DateTime.now() < e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))
                                    )
                                )
                            )
                        )
                    ) {
                        system.debug('Found a match!');
                        system.debug('Pre Event date Stages');

                        //update opportunity with child campaign's info
                        o.StageName = c.SegStageName__c;
                        o.Probability = minProb;
                        o.StageChanged__c = DateTime.now();

                        System.debug('Opportunity ' + o.Id + ' set to ' + c.SegStageName__c);

                        //create new campaign member on lead for child campaign
                        campMems.add(new CampaignMember(
                            LeadId = leadMap.get(o.Event_Organizer__c).Id
                            , CampaignId = c.Id
                        ));
                   //update the old leadskill records for that Lead to Remove if they are either Ready or Checked out                         
                    if(oldrecords.size()>0){
                       for( LeadSkill__c lc:oldrecords){
                           if(oppMap.containsKey(lc.Opportunity__c)){
                               if(lc.Dialerstatus__c == 'Checked Out'){
                                 lc.Dialerstatus__c = 'Remove'; 
                                 oldls.add(lc);
                               }
                               else {
                                   lc.Dialerstatus__c = 'Ignore';
                                   oldls.add(lc);
                               }
                           }                       
                       }                   
                    }
                    //create new leadskill record for the above campaign member
                    ls.add(new LeadSkill__c(
                            Lead__c = leadMap.get(o.Event_Organizer__c).Id,
                            Campaign__c = c.Id,
                            Opportunity__c = o.Id,
                            Dialerstatus__c = 'Ready'));

                    //add lead to the list that needs CMs removed
                    campMemsRemove.add(leadMap.get(o.Event_Organizer__c).Id);

                    //increment batch
                    IncrementCount(c.Name);

                    //opp is definately worth saving
                    saveOpp = true;
                    break;
                    }
                }
                 //if today's date is after the event start date
                else if (DateTime.now() > e.StartDate__c && Integer.valueOf(c.SegDaysFromEvent__c) > 0) {
                    //evil twin of the other ridiculous thing...evil-er twin
                    if (
                        //does child require revenue
                        (
                            c.SegFiltRev__c == null || 
                            (o.Revenue__c > c.SegFiltRev__c)
                        )
                        //does child send kits
                        && (
                            c.IsSegSendKit__c != true || 
                            (
                                c.IsSegSendKit__c == true && 
                                sendKitChecked
                            )
                        )
                        //is the probability of child greater than opp
                        && o.Probability < minProb
                        //is child in allowed stages
                        && IsInList(c.AllowPreStages__c, o.StageName)
                        //has the opp waited long enough
                        && o.StageChanged__c.addHours((Integer) c.SegHrsToWait__c) < DateTime.now()
                        //check date stuff
                        && (
                            //either nothing is set, which is weird, or
                            c.SegDaysFromEvent__c == null || 
                            e.StartDate__c == null ||
                            (
                                //things are set, and
                                e.StartDate__c != null && 
                                c.SegDaysFromEvent__c != null &&
                                (
                                    //event hasn't happened, and child ranges are still negative (ex. days from event: -90)
                                    (
                                        DateTime.now() < e.StartDate__c &&
                                        DateTime.now() > e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))
                                    ) ||
                                    //event has happened, and child ranges are still negative (ex. days from event: -90)
                                    (
                                        DateTime.now() > e.StartDate__c &&
                                        DateTime.now() < e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))
                                    )
                                )
                            )
                        )
                    ) {
                        system.debug('Found a match!');
                        system.debug('Post Event date Stages');

                        //update opportunity with child campaign's info
                        o.StageName = c.SegStageName__c;
                        o.Probability = minProb;
                        o.StageChanged__c = DateTime.now();

                        System.debug('Opportunity ' + o.Id + ' set to ' + c.SegStageName__c);

                        //create new campaign member on lead for child campaign
                        campMems.add(new CampaignMember(
                            LeadId = leadMap.get(o.Event_Organizer__c).Id
                            , CampaignId = c.Id
                        ));
                        
           //update the old leadskill records for that Lead to Remove if they are either Ready or Checked out                    
            if(oldrecords.size()>0){
               for( LeadSkill__c lc:oldrecords){
                   if(oppMap.containsKey(lc.Opportunity__c)){
                       if(lc.Dialerstatus__c == 'Checked Out'){
                         lc.Dialerstatus__c = 'Remove'; 
                         oldls.add(lc);
                       }
                       else {
                           lc.Dialerstatus__c = 'Ignore';
                           oldls.add(lc);
                       } 
                   }
               }
               
            }
                               
                //create new leadskill record for the above campaign member
                ls.add(new LeadSkill__c(
                        Lead__c = leadMap.get(o.Event_Organizer__c).Id,
                        Campaign__c = c.Id,
                        Opportunity__c = o.Id,
                        Dialerstatus__c = 'Ready'));
                        
                //add lead to the list that needs CMs removed
                campMemsRemove.add(leadMap.get(o.Event_Organizer__c).Id);

                //increment batch
                IncrementCount(c.Name);

                //opp is definately worth saving
                saveOpp = true;
                break;
            }
        }
                //date is not either one, or an error happened
                else {
                    system.debug('error');
                    system.debug(
                        '\no.StageName: ' + o.StageName +
                        '\no.Probability: ' + o.Probability
                    );
                }

                //opp found a home, break out of child campaign loop
                if (saveOpp) {
                    break;
                }
            }

            //if the opp found a home, add it to be saved
            if (saveOpp) {
                oppSave.add(o);
            }
            else {
                IncrementCount('noChangeCount');
            }
            IncrementCount('Total Processed');
        }
    
        //if there are any leads that need CMs removed
        System.debug('campMemsRemove.size() ' + campMemsRemove.size());
        if (campMemsRemove.size() > 0) {
            //find any CMs that are a child of the current support campaign, but no longer needed
            List<CampaignMember> del = [
                select id
                from CampaignMember
                where
                LeadId in :campMemsRemove
                and CampaignId != :cParent.Id
                and CampaignId in (
                    select id
                    from Campaign
                    where ParentId = :cParent.Id
                )           
            ];

            //if we found any to delete, do so
            if(del.size() > 0) {
                //with extreme prejudice
                delete del;
            }
        }
        
        if(oppSave.size()>0){
           upsert oppSave;
        }
        if(campMems.size()>0){
          upsert campMems;
        }
        if(ls.size()>0){
          insert ls;
        }
        if(oldls.size()>0){
            update oldls;
        }   
    }
    
    //batch finish - send email reporting
    global void finish(Database.BatchableContext BC) {
        Messaging.SingleEmailMessage mail = GetEnvelope();

        mail.setSubject(cParent.Name + ' Segmentation Completed (' + UserInfo.getOrganizationId() + ')');
        String body = cParent.Name + ' Segmentation';
        for (String key : segCounts.keySet()) {
            body += '\n\n' + key + ': ' + segCounts.get(key);
        }
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    //helper methods
    //-------------------------------------------------------------------------------------

    //method for sending exception emails
    @TestVisible private static void sendErrorEmail(String error, String campaignId) {
        //get mail settings
        Messaging.SingleEmailMessage mail = GetEnvelope();
        mail.setSubject(campaignId + ' Segmentation Exception (' + UserInfo.getOrganizationId() + ')');
        mail.setPlainTextBody(error);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    //get 'envelope', which is all the mail settings
    global static Messaging.SingleEmailMessage GetEnvelope() {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        //get recipient address from custom settings
        EmailSettings__c email = [
            SELECT
            Email__c
            from
            EmailSettings__c
            where
            Name = 'Heroes Segmentation'
        ];

        mail.setToAddresses(new String[] { email.Email__c });
        mail.setReplyTo(fromEmail);
        mail.setSenderDisplayName(fromName);

        return mail;
    }

    public Boolean IsInList(String listVals, String val) {
        Boolean retInListVals = false;

        if (String.isBlank(listVals) || listVals == '*') {
            retInListVals = true;
        }
        else {
            String[] listValsList = listVals.split('[|]');
            system.debug('listvalslist:' + listValsList.size());
            system.debug('string value of list:' + listVals);
            system.debug('val:' + val);
            for (String thisVal : listValsList) {
                if (thisVal == val) {
                    retInListVals = true;
                    break;
                }
            }
        }
        System.debug('retInListVals = ' + retInListVals);
        return retInListVals;
    }

    //move batch forward
    private void IncrementCount(String countName) {
        if (segCounts.containsKey(countName)) {
            segCounts.put(countName, segCounts.get(countName) + 1);
        }
        else {
            segCounts.put(countName, 1);
        }
    }

    //get an event using Opp
    private Events__x getEvent(List<Events__x> events, Opportunity o) {
        Events__x retEvent = null;
        for (Events__x ev : events) {
            System.debug('ev.EventID__c.toUpperCase(): ' + ev.EventID__c.toUpperCase());
            System.debug('o.EventID__c.toUpperCase(): ' + o.EventID__c.toUpperCase());
            if (ev.EventID__c.toUpperCase() == o.EventID__c.toUpperCase()) {
                retEvent = ev;
                break;
            }
        }
        return retEvent;
    }

    //get revenue of event
    public string getTotalRevenue(String eventId) {
        System.debug('eventId in getTotalRevenue = ' + eventId);
        EventRevenues__x evtRev = OdataExtension.GetEventRevenueById(eventId);
        System.debug('evtRev in getTotalRevenue = ' + evtRev);
        if (evtRev != null && evtRev.Amount__c != null) {
            return String.ValueOf(evtRev.Amount__c.setScale(2));
        } else {
            return '0';
        }
    }
    
}