global class ECCRenewalSegBat implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	global Campaign cParent;
	global Account aDef;
	global RecordType rType;
	global List<Campaign> camps;
	global List<Campaign> archCamps;
	global final String query;
	global Boolean errorOnInit;
	global Map<String, Double> oppProbs;
	global static final String fromEmail = 'rakesh.boeana@stjude.org';
	global static final String fromName = 'rakesh.boeana@stjude.org';
	global Map<String, Integer> segCounts = new Map<String, Integer>();
	public Campaign eventCamp { get; set; }
	public Campaign eventArchiveCamp { get; set; }
	public EventHighlights__x highlights {get; private set;}
  	public Lead eventLead { get; set; }
  	public String eventId { get; set; }

	global ECCRenewalSegBat(String parentCampId, String eventTypeId) {

		List<Campaign> parents = [select Id, EventId__c, EndDate, OppRecordType__c, OppAcc__r.id,Name from Campaign where Id = :parentCampId];

		if(parents.size() == 1){
			cParent = parents.get(0);
			system.debug('found closed campaign');

			query = 'select Id, CoordinatorID__c, TR_ID__c, Name, XREF__c, (select Id, StageName, Probability, StageChanged__c, Revenue__c,EventID__c from Opportunities__r) from Lead where id in ' + 
					'(select LeadId from CampaignMember where CampaignId = \'' + parentCampId + '\') ' ;// +
			system.debug(query);
			errorOnInit = false;

		}else{
			  sendErrorEmail('Account not set on closed campaign', parentCampId);

		}

		camps = [
        select id, Name, OppRecordType__c, LeadRecType__c, OppAcc__c, EventTypeId__c
        from Campaign 
        where EventTypeId__c = :eventTypeId.ToUpperCase()
        and IsRenewal__c = true
        and IsRecruited__c = true ];

        archCamps = [
        select id, Name, OppRecordType__c, LeadRecType__c, OppAcc__c, EventTypeId__c
        from Campaign 
        where EventTypeId__c = :eventTypeId.ToUpperCase()
        and isArchivable__c = true ];


      if (camps.size() != 1 && archCamps.size() != 1) {
        //if there are too few or too many, we don't know which one to choose. throw an error
        throw new ECCUtil.ECCException('There are ' + camps.size() + ' Renewal or Archive campaigns for event type ' + eventTypeId);
      }
      eventCamp = camps[0]; // should only be one. let's get it.
      eventArchiveCamp = archCamps[0];
    //  accId = eventCamp.OppAcc__c;

	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
    
	}

	//scope should be about 15
	global void execute(Database.BatchableContext BC, List<sObject> scope) {

	System.debug('errorOnInit ' + errorOnInit);
    if (errorOnInit) {
      System.abortJob(BC.getJobId());
    }
    system.debug('execute');
    Opportunity opp ;
    List<LeadOpp> los = new List<LeadOpp>();
    Set<String> eventSIds = new Set<String>();
    List<Id> opps = new List<Id>();
    Set<String> eventCodes = new Set<String>();

    system.debug('scope.size(): ' + scope.size());
    for(sObject o : scope) {
      Lead ll = (Lead)o;
      system.debug('ll.CoordinatorID__c' + ll.CoordinatorID__c);
      if (String.isBlank(ll.CoordinatorID__c)) {
      //  counts[noCoordCount]++;
      //  system.debug('noCoordCount : ' + noCoordCount);
      }
      else {
        System.debug('GetOpp ' + ll);
         opp = GetOpp(ll);
        if (opp != null && String.isNotBlank(opp.EventID__c)) { 
          System.debug('opp.EventID__c = ' + opp.EventID__c);
          los.add(new LeadOpp(ll, opp));
          system.debug('opp.EventID__c = ' + opp.EventID__c); 
          eventSIds.add(opp.EventID__c);
          opps.add(opp.Id);
        }
        else {
          IncrementCount('noOppEventCount');
          //no opp some how some way, throw it out!
        }
      }

    }

    List<Events__x> events = OdataExtension.GetEventsById(eventSIds);

     for(Events__x e : events) {
       eventCodes.add(e.EventCode__c);
       system.debug('eventCodes = ' + eventCodes);
     }

     String eventRevenue = '';
    for(LeadOpp lo : los) {
      System.debug('leads= ' + lo.loLead);
      Opportunity o;
      Boolean saveOpp = false;
      //GetEvents
      Events__x e = getEvent(events, lo);
      System.debug('e = ' + e);

      System.debug('e.EventID__C = ' + e.EventID__C);
      if(e.EventID__C != null){
        eventRevenue = getTotalRevenue(e.EventID__C .toUpperCase());
        System.debug('eventRevenue = ' + eventRevenue);
      }

        o = lo.loLead.Opportunities__r.get(0);
        System.debug('o.Revenue__c = ' + o.Revenue__c);
        System.debug('decimal.valueOf(eventRevenue) = ' + decimal.valueOf(eventRevenue));
        if(o.Revenue__c != decimal.valueOf(eventRevenue) ){
           o.Revenue__c = decimal.valueOf(eventRevenue);
           saveOpp = true;  
        }


      //enable this in QA
      if(o.Revenue__c > 0 && 
   	  (e.StatusID__c == 'C32E1CC8-B034-4D8F-842B-DC22C3A62B64' || e.StatusID__c == 'B8E35971-3693-4664-AFCB-8E247440FE95' ) 
	  )
	  { //more conditions from notepad

      	//this will get the campaign members from close campaigns and move them to
      	// the Renewal campaign for the event type that's been recruited
      	System.debug('e.StatusID__c = ' + e.StatusID__c);
      	highlights = OdataExtension.GetEventHighLightsById(e.EventId__c);

      	if (highlights == null) {
        throw new ECCUtil.ECCException('Event not found for id=' + e.EventId__c);
      	}

      	System.debug(' highlights.OrganizerId__c = ' + highlights.OrganizerId__c);
      	System.debug(' highlights.EventTypeId__c ' + highlights.EventTypeId__c);
      	System.debug(' highlights.EventTypeId__c.ToUpperCase() ' + highlights.EventTypeId__c.ToUpperCase());

      	List<CampaignMember> cms = [
        select 
          Id, LeadId, CampaignId 
        from 
          CampaignMember 
        where
          CampaignId in (select id
            from Campaign 
            where EventTypeId__c = :highlights.EventTypeId__c.ToUpperCase()
              and IsRenewal__c = true)
          and Lead.ConstituentId__c = :highlights.OrganizerId__c.ToUpperCase()]; //Check ConstituentID

          




          system.debug('cms.size(): ' + cms.size());
          if (cms.size() > 0) {//we found a lead! =1 for already recruited check
	        system.debug('existing lead = ' + cms.get(0).LeadId);
	    //    system.debug('eventLead.Recruited_Date__c = ' + eventLead.Recruited_Date__c);
	        eventLead = [select id, LastName, FirstName, Company, CurrentCampaign__c, RecordTypeId, Phone, CoordinatorID__c,Recruited_Date__c from lead where id = :cms.get(0).LeadId];

		      system.debug('Lead.ConstituentId__c = ' + highlights.OrganizerId__c);
	          system.debug('highlights.CoordinatorID__c = ' + highlights.CoordinatorID__c);
	          system.debug('Lead.CurrentCampaign__c = ' + eventLead.CurrentCampaign__c);


	        List<CampaignMember> renCms = [
	        select 
	          Id, LeadId, CampaignId 
	        from 
	          CampaignMember 
	        where
	          CampaignId in (select id
	            from Campaign 
	            where EventTypeId__c = :highlights.EventTypeId__c.ToUpperCase()
	              and IsSupportParent__c = true)
	          and Lead.ConstituentId__c = :highlights.OrganizerId__c
	          and Lead.CoordinatorID__c = :highlights.CoordinatorID__c
	          and Lead.CurrentCampaign__c = :eventLead.CurrentCampaign__c
	          ];

	        List<CampaignMember> exesRenCms = [
	        select 
	          Id, LeadId, CampaignId 
	        from 
	          CampaignMember 
	        where
	          CampaignId in (select id
	            from Campaign 
	            where EventTypeId__c = :highlights.EventTypeId__c.ToUpperCase()
	          and IsRenewal__c = true
        	  and IsRecruited__c = true)
	          and Lead.ConstituentId__c = :highlights.OrganizerId__c
	          and Lead.CoordinatorID__c = :highlights.CoordinatorID__c
	          ];

	          system.debug('renCms.size() = ' + renCms.size());
	          system.debug('exesRenCms.size() = ' + exesRenCms.size());
	          if(renCms.size() <= 1 && exesRenCms.size() == 0){
	          Lead l = new Lead();
	          	//    if(eventLead.Recruited_Date__c < DateTime.now()){
	        if (highlights.CoordinatorId__c != null) {
	          l.CoordinatorID__c = highlights.CoordinatorId__c;
	        }
	        if(highlights.OrganizerId__c != null){
	        	l.ConstituentId__c = highlights.OrganizerId__c;
	        }
	      //  delete cms;
	      //  delete renCms;
	        l.CurrentCampaign__c = eventCamp.Id;
	        l.FirstName = eventLead.FirstName;
	        l.LastName = eventLead.LastName;
	        l.Phone = eventLead.Phone;
	        l.Company = eventLead.Company;
	        l.RecordTypeId = eventLead.RecordTypeId;
	      //  eventLead.XREF__c = null; //eventId + '|' + eventLead.CoordinatorID__c;
	      //  eventLead.Recruited_Date__c = null; // highlights.StartDate__c.date();
	        insert l;

	        delete cms;
            delete renCms;
	        eventLead.CurrentCampaign__c = eventArchiveCamp.Id;
	        update eventLead;

	        system.debug('l.id = ' + l.id);
	        IncrementCount('Total Processed');

	     //   }
	        
	      }else{
	      	IncrementCount('noChangeCount');
	      }
	          }
	    


      }

    }



	}


	
	private Opportunity GetOpp(Lead l) {
			Opportunity opp = null;
			if (l.Opportunities__r != null && l.Opportunities__r.size() > 0) {
				opp = l.Opportunities__r.get(0);
			}

			system.debug('opp == null: ' + opp == null);
			return opp;
		}

	private void IncrementCount(String countName) {
		if (segCounts.containsKey(countName)) {
			segCounts.put(countName, segCounts.get(countName) + 1);
		}
		else {
			segCounts.put(countName, 1);
		}
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

	global void finish(Database.BatchableContext BC) {

		Messaging.SingleEmailMessage mail = ECCHeroesSegBat.GetEnvelope();

		mail.setSubject(cParent.Name + ' Renewal Segmentation Completed (' + UserInfo.getOrganizationId() + ')');
		String body = cParent.Name + ' Renewal Segmentation';
		for(String key : segCounts.keySet()) {
			body += '\n\n' + key + ': ' + segCounts.get(key);
		}
		mail.setPlainTextBody(body);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	@TestVisible private static void sendErrorEmail(String error, String campaignId) {
		Messaging.SingleEmailMessage mail = GetEnvelope();
		mail.setSubject(campaignId + ' Segmentation Exception (' + UserInfo.getOrganizationId() + ')');
		mail.setPlainTextBody(error);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	global static Messaging.SingleEmailMessage GetEnvelope() {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	               EmailSettings__c email = [
			SELECT 
			    Email__c
			from
			    EmailSettings__c 
			where
				Name = 'Heroes Segmentation'];

		mail.setToAddresses(new String[] { email.Email__c });
		//mail.setToAddresses(new String[] { 'rakesh.boeana@stjude.org' });   //TODO
		mail.setReplyTo(fromEmail);
		mail.setSenderDisplayName(fromName);

		return mail;
	}

}