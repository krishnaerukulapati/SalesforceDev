global class ECCChallengeSegBat implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
  
  global final String query;
  global Boolean errorOnInit;
  global Boolean saveOpp = false;

  //opportunities
  global Campaign cParent;
  global Campaign chall15;
  global Campaign chall30;
  global Campaign chall500;
  global Campaign chall1000;
  global Campaign chall2000;
  global Campaign challMon;
  global Campaign challMon2;
  global Campaign challCancel;
  global Campaign challClosed;

  //counts for email
  global Integer[] counts;
  global Integer newChall15Count = 0;
  global Integer newChall30Count = 1;
  global Integer newChall500Count = 2;
  global Integer newChall1000Count = 3;
  global Integer newChall2000Count = 4;
  global Integer newChallMonCount = 5;
  global Integer newChallMon2Count = 6;
  global Integer newChallCancelCount = 7;
  global Integer noOppEventCount = 8;
  global Integer noConsIdCount = 9;
  global Integer noTRRegCount = 10;
  global Integer noStartDateCount = 11;
  global Integer noCoordCount = 12;
  global Integer procCount = 13;
  global Integer noChangeCount = 14;
  global Integer newChallCloseWonCount = 15;

  global Map<String, Double> oppProbs;

  //extraneous object for the dependencies
  global Account aDef;
  global RecordType rType;

  //hard codes - campaign names
  //global static final String parentSegName = 'St Jude Challenge FY16';
  global static final String chall15SegName = '15 Day';
  global static final String chall30SegName = '30 Day';
  global static final String chall500SegName = '$500';
  global static final String chall1000SegName = '$1,000';
  global static final String chall2000SegName = '$2,000';
  global static final String challMonSegName = 'Money 1';
  global static final String challMon2SegName = 'Money 2';
  global static final String challCancelSegName = 'Cancelled';
  global static final String challClosedSegName = 'Closed';

  //hard codes - opp stage names
  global static final String chall15Stage = '15 day Confirmation Call';
  global static final String chall15CompStage = '15 day Conf Call Complete';
  global static final String chall30Stage = '30 day Confirmation Call';
  global static final String chall30CompStage = '30 day Conf Call Complete';
  global static final String chall500Stage = '$500 Milestone Call';
  global static final String chall500CompStage = '$500 MS Call Complete';
  global static final String chall1000Stage = '$1,000 Milestone Call';
  global static final String chall1000CompStage = '$1,000 MS Call Complete';
  global static final String chall2000Stage = '$2,000 Milestone Call';
  global static final String chall2000CompStage = '$2,000 MS Call Complete';
  global static final String challMonStage = 'Money Encouragement Call 1';
  global static final String challMonCompStage = 'ME Call 1 Complete';
  global static final String challMon2Stage = 'Money Encouragement Call 2';
  global static final String challMon2CompStage = 'ME Call 2 Complete';
  global static final String challClosedWonStage = 'Closed';
  global static final String challCancelStage = 'Cancelled';
  global static final String prosStage = 'Staged';
  global static final String badRecord = 'BAD Record';

  //extraneous names for the objects for the dependencies
  global static final String accountName = 'ALSAC Challenge';
  global static final String rTypeName = 'St_Jude_Challenge';
  global static final String consIdAttrName = 'TEAMRAISER_CONS_ID';

  //email stuff
  global String welcomeSubject = 'Email: Welcome';
  global String encourageSubject = 'Email: Encouragement';
  global String thanksSubject = 'Email: Thank You';
  global String welcomeTemplate = 'Welcome';
  global String encourageTemplate = 'Encouragement';
  global String thanksTemplate = 'ThankYou';
  //global List<Email__c> lstEmailSaves {get; set;}
  //this guy sure is amazing!
  global static final String fromEmail = 'Josh.Rozier@stjude.org';
  global static final String fromName = 'Josh.Rozier@stjude.org';

  //how long before jobs
  global final Integer challHoursToWait;
  public Events__x Event {get; private set;}

  
  global ECCChallengeSegBat(id Parentid) {
    errorOnInit = true;
    system.debug('init');
    //get the parent campaign to start from based on name

    EnvironmentSettings__c es = [
            SELECT 
                ChallHoursToWait__c
            from
        EnvironmentSettings__c 
            where
        SetupOwnerId = :UserInfo.getOrganizationId()];

        challHoursToWait = Integer.valueOf(es.ChallHoursToWait__c);

    List<Account> accounts = [select Id from Account where Name = :accountName];
    List<Campaign> parents = [select Id, EventId__c, EventTypeID__c, EndDate from Campaign where id = :Parentid];
    List<RecordType> rTypes = [select Id from RecordType where sObjectType = 'Opportunity' and DeveloperName = :rTypeName];
    if (rTypes.size() == 1) {
      rType = rTypes.get(0);
      if (parents.size() == 1) {
        system.debug('found parent campaign');
        if (accounts.size() == 1) {
          //good
          //store the parent for later
          system.debug('found account');
          cParent = parents.get(0);
          aDef = accounts.get(0);
          if (String.isNotBlank(cParent.EventTypeID__c)) {
            //get the children
            List<Campaign> children = [select Id, SegName__c from Campaign where ParentId = :cParent.Id and IsSeg__c = true];
            if (children.size() == 9) {
              //good
              //find the children and store them
              system.debug('found 10 children');
              for (Campaign c : children) {
                if (c.SegName__c == chall15SegName) chall15 = c;
                else if (c.SegName__c == chall30SegName) chall30 = c;
                else if (c.SegName__c == chall500SegName) chall500 = c;
                else if (c.SegName__c == chall1000SegName) chall1000 = c;
                else if (c.SegName__c == chall2000SegName) chall2000 = c;
                else if (c.SegName__c == challMonSegName) challMon = c;
                else if (c.SegName__c == challMon2SegName) challMon2 = c;
                else if (c.SegName__c == challCancelSegName) challCancel = c;
                 else if (c.SegName__c == challClosedSegName) challClosed = c;
                else {
                  system.debug(c.SegName__c);
                } //error - malconfigured campaign
              }
              if (chall15 != null && chall30 != null && chall500 != null && chall1000 != null && chall2000 != null && 
                challMon != null && challMon2 != null && challCancel != null && challClosed != null) {
                system.debug('found correct 8 children');
                query = 'select Id, TR_ID__c, Name, EventID__c, ' +
                  '(select Id, StageName, Probability, StageChanged__c, Revenue__c, EventID__c from Opportunities__r), '+
                  'CoordinatorID__c from Lead where id in ' + 
                  '(select LeadId from CampaignMember where CampaignId = \'' + cParent.Id + '\') ' +
                  ' and Id in (select Event_Organizer__c from Opportunity where Event_Organizer__c != null)' ;
                   /*+
                  ' and Id = \'00Q8A000001iOZ0UAM\' '*/
                List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage];
                oppProbs = new Map<String, Double>();
                for(OpportunityStage os : oppStages) {
                  oppProbs.put(os.MasterLabel, os.DefaultProbability);
                }
                system.debug(query);
                counts = new Integer[] {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
                errorOnInit = false;
              }
              else {
                //error - malconfigured campaign
                sendErrorEmail('Malconfigured campaign: one or more child campaigns were not found');
              }
            }
            else {
              //error - malconfigured campaign
              sendErrorEmail('Malconfigured campaign, incorrect number of child campaigns');
            }
          }
          else {
            //error - malconfigured campaign
            sendErrorEmail('Malconfigured campaign, TR Event Id was missing');
          }
        }
        else {
          //error - malconfigured account
          sendErrorEmail('Malconfigured account, account \'' + accountName + '\' was missing');
        }
      }
      else {
        //error - malconfigured campaign
        sendErrorEmail('Malconfigured campaign, campaign \'' + ParentId + '\' was missing');
      }
    }
    else {
      //error - missing record type
      sendErrorEmail('Missing record type, developer name \'' + rTypeName + '\' was missing');
    }
  }
  
  global Database.QueryLocator start(Database.BatchableContext BC) {
    if (errorOnInit) {
         System.abortJob(BC.getJobId());
         return null;
    }
    return Database.getQueryLocator(query);
  }

     global void execute(Database.BatchableContext BC, List<sObject> scope) {
       system.debug('test');
    if (errorOnInit) {
         System.abortJob(BC.getJobId());
         return;
       }

       List<Opportunity> oppSave = new List<Opportunity>();
       List<Task> taskSave = new List<Task>();
       List<CampaignMember> campMems = new List<CampaignMember>();
       List<Email__c> lstEmailSaves = new List<Email__c>();
       List<Id> campMemsRemove = new List<Id>();
       List<Id> opps = new List<Id>();
       Map<Id, List<Task>> oppTasks = new Map<Id, List<Task>>();
       List<LeadOpp> los = new List<LeadOpp>(); //for the second loop to avoud re-casting
       List<Decimal> trIds = new List<Decimal>(); //tr id list to get revenue which is uber important!
       Opportunity opp ; 
       Set<String> eventIds = new Set<String>();
       Set<String> eventCodes = new Set<String>();

       //loop 1 to get the leads cast as leads and the event ids for to get the tr ids
       // they should have opportunities and event ids as this point
       system.debug('scope.size(): ' + scope.size());
    for(sObject o : scope) {
      counts[procCount]++;
      Lead l = (Lead)o;
      if (String.isBlank(l.CoordinatorID__c)) {
      //  counts[noCoordCount]++;
      //  system.debug('noCoordCount : ' + noCoordCount);
      }
      else {
         opp = GetOpp(l);
        if (opp != null && String.isNotBlank(opp.EventID__c)) { 
          los.add(new LeadOpp(l, opp)); 
          eventIds.add(opp.EventID__c);
          opps.add(opp.Id);
        }
        else {
          counts[noOppEventCount]++;
          //no opp some how some way, throw it out!
        }
      }
    }

    List<Task> tasks = [select subject, WhatId from Task
      where (subject = :thanksSubject or subject = :welcomeSubject or Subject = :encourageSubject)
        and WhatId in :opps];

    for(Task t : tasks) {
      if (oppTasks.containsKey(t.WhatId)) {
        oppTasks.get(t.WhatId).add(t);
      }
      else {
        oppTasks.put(t.WhatId, new Task [] { t });
      }
    }
     
     List<Events__x> events = OdataExtension.GetEventsById(eventIds);
     for(Events__x e : events) {
       eventCodes.add(e.EventCode__c);
     }

     
     

    //to get revenue from RecruitedEvents
    List<RecruitedEvents__x> trEventRevenueFromRE = OdataExtension.GetEventRevenueFromRecruitedEvents(eventCodes); 
    //Event code of the event,  Opp will have eventId get code from there

    //set recruitedEvent Revenue to TREventRegistrationDetails

    system.debug('trEventRevenueFromRE.size(): ' + trEventRevenueFromRE.size());
    system.debug('los = ' + los.size());

    //now we have the revenue, one more loop through the leads!
    for(LeadOpp lo : los) {
        system.debug('lo.loLead.EventID__c = ' + lo.loLead.EventID__c);
      String eventRevenue = '';
      /*if(lo.loLead.EventID__c != null){
        eventRevenue = getTotalRevenue(lo.loLead.EventID__c); //get revenue using new view from ODS
        system.debug('eventRevenue = ' + eventRevenue);
      }*/

      
    //  RecruitedEvents__x reg = setRevenue(trEventRevenueFromRE, lo.loLead); //set Revenue and get this registration
    //  TREventRegistrationDetails__x reg = getReg(trEventRegs, lo.loLead); //get this registration
      Events__x e = getEvent(events, lo);

      if(e != null && e.EventID__c != null){
        System.debug(' e.EventID__c = ' + e.EventID__c.toUpperCase());
         eventRevenue = getTotalRevenue(e.EventID__c.toUpperCase()); //get revenue using new view from ODS
        system.debug('eventRevenue = ' + eventRevenue);

      }

      system.debug('lo.loLead.CoordinatorID__c: ' + lo.loLead.CoordinatorID__c);
      PreferredConstituentInfos__x pci = OdataExtension.GetPreferredConstituentInfos(lo.loLead.CoordinatorID__c);
      String coordEmail = pci.email_address__c;
      domainSoapStjudeOrg.Preference[] prefs = C360Util.getPreferences(lo.loLead.CoordinatorID__c);
      system.debug('prefs = ' + prefs);
      /* select constituent_id__c, email__c from PreferredConstituentInfos__x where constituent_id__c = :consId*/
      Boolean welcomeSent = false, encourageSent = false, thanksSent = false, noMail = false;

      //do the stuffs!
      // create activity if email is sent
        
        //no email??
        if (prefs != null) {
          for(domainSoapStjudeOrg.Preference pref : prefs) {
            if (pref.Preference.toLowerCase() == 'email' && pref.PreferenceValue.toLowerCase() != 'yes/allowed' &&
              (pref.StartDate == null || pref.StartDate < DateTime.now()) && 
              (pref.EndDate == null || pref.EndDate > DateTime.now())) {
              noMail = true;
              break;
            }
          }
      }
        // check if email was sent
        if (oppTasks.containsKey(lo.loOpp.Id)) {
          for(Task t : oppTasks.get(lo.loOpp.Id)) {
            if (t.subject == welcomeSubject) welcomeSent = true;
            if (t.subject == encourageSubject) encourageSent = true;
            if (t.subject == thanksSubject) thanksSent = true;
          }
      }

      if(e != null) {

        if (!welcomeSent && String.isNotBlank(coordEmail) && !noMail && e.StartDate__c > Date.today()) {
          //only if we haven't sent one and we have an e-mail address for the constituent
          //and they don't not want the mails! 
          taskSave.add(ECCUtil.createTask(lo.loOpp, welcomeSubject, 'Completed', 'St Jude Challenge Welcome email sent', coordEmail ));
          emailSaves(coordEmail, welcomeTemplate, pci.first_name__c, e.eventCode__c, 
            e.StartDate__c.format('MMMMM dd, yyyy'), lstEmailSaves);
        }

          // if 60 days before event and no activity with encouragement already found send email and create activity
        if (!encourageSent && String.isNotBlank(coordEmail) && !noMail &&
            e.StartDate__c != null && Date.today().addDays(60) == e.StartDate__c) {    
          taskSave.add(ECCUtil.createTask(lo.loOpp, encourageSubject, 'Completed', 'St Jude Challenge Encouragement email sent', coordEmail ));    
          emailSaves(coordEmail, encourageTemplate, pci.first_name__c, e.eventCode__c, 
            e.StartDate__c.format('MMMMM dd, yyyy'), lstEmailSaves);
        }
        // if 7 days after event and revenue > 0 and no activity with thank you already found send email and create activity
        if (!thanksSent && String.isNotBlank(coordEmail) && !noMail &&
            e.StartDate__c != null && e.StartDate__c.addDays(7) == Date.today() && lo.loOpp.Revenue__c > 0) {
          taskSave.add(ECCUtil.createTask(lo.loOpp, thanksSubject, 'Completed', 'St Jude Challenge Thank You email sent', coordEmail ));
          emailSaves(coordEmail, thanksTemplate, pci.first_name__c, e.eventCode__c, 
            e.StartDate__c.format('MMMMM dd, yyyy'), lstEmailSaves);
        }
        //set new revenue
     }
     
      System.debug(' lo.loOpp.Revenue__c = ' + lo.loOpp.Revenue__c);
      System.debug(' eventRevenue = ' + eventRevenue);

      if (lo.loOpp.Revenue__c != decimal.valueOf(eventRevenue)) {
        lo.loOpp.Revenue__c = decimal.valueOf(eventRevenue);
        saveOpp = true;
      }

      /*if (lo.loOpp.Revenue__c != reg.TOTALREVENUE__c) {
        lo.loOpp.Revenue__c = reg.TOTALREVENUE__c;
        saveOpp = true;
      }*/


      if (lo.loOpp.Revenue__c == null) lo.loOpp.Revenue__c = 0;

      if(e != null) {

        if (ReadyForChall15(lo.loOpp, e)) {
          setStage(lo.loOpp, chall15Stage, newChall15Count, campMems, lo.loLead, campMemsRemove, chall15);
          saveOpp = true;
        }
        else if (ReadyForChall30(lo.loOpp, e)) {
          setStage(lo.loOpp, chall30Stage, newChall30Count, campMems, lo.loLead, campMemsRemove, chall30);
          saveOpp = true;
        }
        else if (ReadyForChall500(lo.loOpp, e)) {
          setStage(lo.loOpp, chall500Stage, newChall500Count, campMems, lo.loLead, campMemsRemove, chall500);
          saveOpp = true;
        }
        else if (ReadyForChall1000(lo.loOpp, e)) {
          setStage(lo.loOpp, chall1000Stage, newChall1000Count, campMems, lo.loLead, campMemsRemove, chall1000);
          saveOpp = true;
        }
        else if (ReadyForChall2000(lo.loOpp, e)) {
          setStage(lo.loOpp, chall2000Stage, newChall2000Count, campMems, lo.loLead, campMemsRemove, chall2000);
          saveOpp = true;
        }
        else if (ReadyForChallMon(lo.loOpp, e)) {
          setStage(lo.loOpp, challMonStage, newChallMonCount, campMems, lo.loLead, campMemsRemove, challMon);
          saveOpp = true;
        }
        else if (ReadyForChallMon2(lo.loOpp, e)) {
          setStage(lo.loOpp, challMon2Stage, newChallMon2Count, campMems, lo.loLead, campMemsRemove, challMon2);
          saveOpp = true;
        }
        else if (ReadyForCloseWon(lo.loOpp, e)) {
          setStage(lo.loOpp, challClosedWonStage, newChallCloseWonCount, campMems, lo.loLead, campMemsRemove, challClosed);
          saveOpp = true;
        }
        else if (ReadyForCancel(lo.loOpp, e)) {
          setStage(lo.loOpp, challCancelStage, newChallCancelCount, campMems, lo.loLead, campMemsRemove, challCancel);
          saveOpp = true;
        }
        else counts[noChangeCount]++;
      }

      if (saveOpp) oppSave.add(lo.loOpp);
    }

    //delete existing campaign memberships
    if (campMemsRemove.size() > 0) {
      List<CampaignMember> del = [
        select
          Id
        from
          CampaignMember
        where
          LeadId in :campMemsRemove
          and CampaignId != :cParent.Id
        ];
      if (del.size() > 0) {
        delete del;
      }
    }
    upsert oppSave;
    upsert campMems;
    insert lstEmailSaves;
    insert taskSave;

    system.debug('counts[procCount]: ' + counts[procCount]);
  }

  public static void emailSaves(String coordEmail, String template, String firstName, String eventCode, String eventDate, List<Email__c> lstEmailSaves){
    Email__c e = new Email__c(
          emailsent__c = 'N'
          , bindfield1__c = eventCode
          , bindfield2__c = eventDate
          , bindfield3__c = firstName
      , recipientemails__c = coordEmail
      , template__c = template);

      lstEmailSaves.add(e);
  }

  global void finish(Database.BatchableContext BC) {
    Messaging.SingleEmailMessage mail = ECCHeroesSegBat.GetEnvelope();

    mail.setSubject('Challenge Segmentation Completed (' + UserInfo.getOrganizationId() + ')');
    mail.setPlainTextBody('Challenge Segmentation ' + 
      '\nprocessed: ' + counts[procCount] + 
      ',\nnew ' + chall15SegName + ': ' + counts[newChall15Count] +  
      ',\nnew ' + chall30SegName + ': ' + counts[newChall30Count] + 
      ',\nnew ' + chall500SegName + ': ' + counts[newChall500Count] + 
      ',\nnew ' + chall1000SegName + ': ' + counts[newChall1000Count] + 
      ',\nnew ' + chall2000SegName + ': ' + counts[newChall2000Count] + 
      ',\nnew ' + challMonSegName + ': ' + counts[newChallMonCount] + 
      ',\nnew ' + challMon2SegName + ': ' + counts[newChallMon2Count] +
      ',\nnew ' + challCancelStage + ': ' + counts[newChallCancelCount] +
      ',\nnew ' + challClosedWonStage + ': ' + counts[newChallCloseWonCount] +
      ',\nNo Coordinator on Lead: ' + counts[noCoordCount] +
      ',\nNo Event on Opp: ' + counts[noOppEventCount] +
      ',\nNo TR Id on Event: ' + counts[noConsIdCount] +
      ',\nNo TR Registration for lead: ' + counts[noTRRegCount] +
      ',\nNo start date on event: ' + counts[noStartDateCount] +
      ',\nNo change: ' + counts[noChangeCount]
      );
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }

  @TestVisible private static void sendErrorEmail(String error) {
    Messaging.SingleEmailMessage mail = GetEnvelope();
    mail.setSubject('Challenge Segmentation Exception (' + UserInfo.getOrganizationId() + ')');
    mail.setPlainTextBody(error);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }

  global static Messaging.SingleEmailMessage GetEnvelope() {
    system.debug('GetEnvelope');
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     EmailSettings__c email = [
      SELECT 
          Email__c
      from
          EmailSettings__c 
      where
        Name = 'Heroes Segmentation'];

    mail.setToAddresses(new String[] { email.Email__c });
    mail.setReplyTo(fromEmail);
    mail.setSenderDisplayName(fromName);

    return mail;
  }

  private void setStage(Opportunity o, String stageName, Integer count, list<CampaignMember> campMems, Lead l,
    List<Id> campMemsRemove, Campaign c) {
    System.debug('stageName in set Stage = ' + stageName);
    o.StageName = stageName;
    o.Probability = oppProbs.get(stageName);
    o.StageChanged__c =  DateTime.now();
    if (campMems != null) {
      campMems.add(new CampaignMember(
        LeadId = l.Id
        , CampaignId = c.Id
      ));
    }
    counts[count]++;
    
    campMemsRemove.add(l.Id);
  }

  private Opportunity GetOpp(Lead l) {
    Opportunity opp = null;
    if (l.Opportunities__r != null && l.Opportunities__r.size() > 0) {
      opp = l.Opportunities__r.get(0);
    }

    system.debug('opp == null: ' + opp == null);
    return opp;
  }

  /*private TREventRegistrationDetails__x getReg(List<TREventRegistrationDetails__x> trEventRegs, Lead l) {
    TREventRegistrationDetails__x retEventReg = null;
    for (TREventRegistrationDetails__x reg : trEventRegs) {
      system.debug('reg.P2P_ID__c: ' + reg.P2P_ID__c);
      system.debug('Decimal.valueOf(l.TR_ID__c): ' + Decimal.valueOf(l.TR_ID__c));
      if (reg.P2P_ID__c == Decimal.valueOf(l.TR_ID__c)) {
        retEventReg = reg;
        break;
      }
    }
    return retEventReg;
  }*/

  private RecruitedEvents__x setRevenue(List<RecruitedEvents__x> trEventRevenueFromRE, Lead l) {
    RecruitedEvents__x retSetEventRevenue = null;
    for (RecruitedEvents__x rev : trEventRevenueFromRE) {
      system.debug('rev.SOURCECODE__c : ' + rev.SOURCECODE__c );
      system.debug('l.EventID__c: ' + l.EventID__c);
       if (rev.SOURCECODE__c == l.EventID__c) {
        retSetEventRevenue = rev;
        break;
        }
    }
    if(retSetEventRevenue == null){
      retSetEventRevenue = new RecruitedEvents__x();
      retSetEventRevenue.TOTALREVENUE__c = 0;
    }
    return retSetEventRevenue;
  }

  private Events__x getEvent(List<Events__x> events, LeadOpp lo) {
    Events__x retEvent = null;
    for (Events__x ev : events) {
      System.debug('ev.EventID__c.toUpperCase(): ' + ev.EventID__c.toUpperCase());
      System.debug('lo.loOpp.EventID__c.toUpperCase(): ' + lo.loOpp.EventID__c.toUpperCase());
      System.debug('lo.loLead.CoordinatorID__c.toUpperCase(): ' + lo.loLead.CoordinatorID__c.toUpperCase());
      if (ev.EventID__c.toUpperCase() == lo.loOpp.EventID__c.toUpperCase()) {
        retEvent = ev;
        break;
      }
    }
    return retEvent;
  }

  /******************************************************************************************************
   *   Ready for the things area
   *****************************************************************************************************/
  private Boolean ReadyForChall15(Opportunity o, Events__x event) {
    if (event.StartDate__c != null && event.StartDate__c > Date.today()) { //event after today
      if (o.Revenue__c == 0) { // no revenue
        if (event.DateInserted__c != null && event.DateInserted__c < Date.today().addDays(15)) { //registered within 15 days
          if (o.StageName == prosStage) { //in the 'unstaged' aread
            return true;
          }
        }
      }
    }
    return false;
  }

  private Boolean ReadyForChall30(Opportunity o, Events__x event) {
    if (o.StageName != chall30Stage) {
      if (event.StartDate__c != null && event.StartDate__c > Date.today()) { //event after today
        if (o.Revenue__c == 0) { // no revenue
          if (event.StartDate__c < Date.today().addDays(30)) { //event date < 30 days away
            if (!o.StageName.endsWith('Complete') || o.StageChanged__c.addHours(challHoursToWait) < DateTime.now()) { //either not 'complete' or completed long enough ago
              return true;
            }
          }
        }
      }      
    }
    return false;
  }

  private Boolean ReadyForChall500(Opportunity o, Events__x event) {
    if (o.StageName != chall500Stage) {
      if (event.StartDate__c != null && event.StartDate__c > Date.today()) { //event after today
        if (o.Revenue__c >= 500 & o.Revenue__c < 1000) { // no revenue
          if (!o.StageName.endsWith('Complete') || o.StageChanged__c.addHours(challHoursToWait) < DateTime.now()) { //either not 'complete' or completed long enough ago
            return true;
          }
        }
      }
    }
    return false;
  }

  private Boolean ReadyForChall1000(Opportunity o, Events__x event) {
    if (o.StageName != chall1000Stage) {
      if (event.StartDate__c != null && event.StartDate__c > Date.today()) { //event after today
        if (o.Revenue__c >= 1000 & o.Revenue__c < 2000) { // no revenue
          if (!o.StageName.endsWith('Complete') || 
            o.StageChanged__c.addHours(challHoursToWait) < DateTime.now()) { //either not 'complete' or completed long enough ago
            return true;
          }
        }
      }
    }
    return false;
  }

  private Boolean ReadyForChall2000(Opportunity o, Events__x event) {
    if (o.StageName != chall2000Stage) {
      if (event.StartDate__c != null && event.StartDate__c > Date.today()) { //event after today
        if (o.Revenue__c >= 2000) { // no revenue
          if (!o.StageName.endsWith('Complete') || o.StageChanged__c.addHours(challHoursToWait) < DateTime.now()) { //either not 'complete' or completed long enough ago
            return true;
          }
        }
      }
    }
    return false;
  }

  private Boolean ReadyForChallMon(Opportunity o, Events__x event) {
    if (o.StageName != challMonStage && o.Probability < 74) {
      if (event.StartDate__c != null && Date.today() >= event.StartDate__c.addDays(10) && 
        Date.today() < event.StartDate__c.addDays(20)) { //event date between 10 and 20 days ago
        if (o.Revenue__c == 0) { // no revenue
          return true;
        }
      }
    }
    return false;
  }

  private Boolean ReadyForChallMon2(Opportunity o, Events__x event) {
    system.debug('event.StartDate__c: ' + event.StartDate__c);
    if (event.StartDate__c != null) {
      system.debug('event.StartDate__c.addDays(20): ' + event.StartDate__c.addDays(20));
      system.debug('event.StartDate__c.addDays(20): ' + event.StartDate__c.addDays(40));
    }
    if (o.StageName != challMon2Stage && o.Probability < 92) {
      if (event.StartDate__c != null && Date.today() >= event.StartDate__c.addDays(20) && Date.today() < event.StartDate__c.addDays(40)) { //event date between 10 and 20 days ago
        if (o.Revenue__c == 0) { // no revenue
          if (!o.StageName.endsWith('Complete') || 
            o.StageChanged__c.addHours(challHoursToWait) < DateTime.now()) { //either not 'complete' or completed long enough ago
            return true;
          }
        }
      }
    }
    return false;
  }

  private Boolean ReadyForCloseWon(Opportunity o, Events__x event) {
    if (o.StageName != challClosedWonStage) {
      if (event.StartDate__c != null && Date.today() >= event.StartDate__c) { //event date passed
        if (o.Revenue__c > 0) { // has revenue
          return true;
        }
      }
    }
    return false;
  }

  private Boolean ReadyForCancel(Opportunity o, Events__x event) {
    if (o.StageName != challCancelStage) {
      if (event.StartDate__c != null && Date.today() > event.StartDate__c.addDays(90)) { //event date 90 days ago
        if (o.Revenue__c == 0) { // no revenue
          return true;
        }
      }
    }
    return false;
  }

  private class LeadOpp {
    public Lead loLead;
    public Opportunity loOpp;

    public LeadOpp(Lead l, Opportunity opp) {
      loLead = l;
      loOpp = opp;
    }
  }

  public string getTotalRevenue(String eventId){
        System.debug('eventId in getTotalRevenue = ' + eventId);
        EventRevenues__x evtRev = OdataExtension.GetEventRevenueById(eventId);
         System.debug('evtRev in getTotalRevenue = ' + evtRev);
        if (evtRev != null && evtRev.Amount__c != null){
            return String.ValueOf(evtRev.Amount__c.setScale(2));
      }else{
       return '0';
      } 
    }

}