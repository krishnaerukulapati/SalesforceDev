global class ECCEventsSegBat implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	global final String query;
	global Boolean errorOnInit;

	global Campaign cParent;
	global Campaign cCancelled;
	global Campaign cCompleted;
	global Account aDef;
	global RecordType rType;
	global static final String fromEmail = 'rakesh.boeana@stjude.org';
	global static final String fromName = 'rakesh.boeana@stjude.org';
	global String defaultStage = 'Staged';

	global List<Campaign> segments;
	global Map<String, Double> oppProbs;
	global Map<String, Integer> segCounts = new Map<String, Integer> ();

	//how long before jobs
	global final Integer challHoursToWait;
	global final String cancelled = '59311144-A18E-4F50-9E74-AE3DD6B4C096';
	global final String systemCancelled = '19DC3506-66F7-48BE-8ADD-5343E3F34EFE';

	global ECCEventsSegBat(String parentCampId) {
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

		List<Campaign> parents = [select Id, EventId__c, EndDate, OppRecordType__c, OppAcc__r.id, Name from Campaign where Id = :parentCampId];

		if (parents.size() == 1) {
			cParent = parents.get(0);
			system.debug('found parent campaign');

			List<RecordType> rTypes = [select Id from RecordType where sObjectType = 'Opportunity' and DeveloperName = :cParent.OppRecordType__c];
			if (rTypes.size() == 1) {
				rType = rTypes.get(0);
				if (cParent.OppAcc__r != null) {
					//good
					//store the parent for later
					system.debug('found account');

					aDef = cParent.OppAcc__r;
					//get the children
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
					system.debug('segments = ' + segments);
					system.debug('found ' + segments.size() + ' children');

					query = 'select Id, CoordinatorID__c, TR_ID__c, Name, XREF__c, (select Id, StageName, Probability, StageChanged__c, Revenue__c,EventID__c from Opportunities__r) from Lead where id in ' +
					'(select LeadId from CampaignMember where CampaignId = \'' + cParent.Id + '\') '; // +
					//' and TR_ID__c != null';
					List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage];
					oppProbs = new Map<String, Double> ();

					for (OpportunityStage os : oppStages) {
						oppProbs.put(os.MasterLabel, os.DefaultProbability);
					}
					system.debug(query);
					errorOnInit = false;

				}
				else {
					//error - malconfigured account
					sendErrorEmail('Account not set on parent campaign', parentCampId);
				}
			}
			else {
				//error - missing record type
				sendErrorEmail('Missing record type, developer name \'' + cParent.OppRecordType__c + '\' was missing', parentCampId);
			}
		}
		else {
			//error - malconfigured campaign
			sendErrorEmail('Malconfigured campaign, campaign \'' + parentCampId + '\' was missing', parentCampId);
		}
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

		List<Opportunity> oppSave = new List<Opportunity> ();
		List<CampaignMember> campMems = new List<CampaignMember> ();
		List<Id> campMemsRemove = new List<Id> ();
		List<Lead> leads = new List<Lead> (); //for the second loop to avoud re-casting
		List<Decimal> consIds = new List<Decimal> ();
		List<Decimal> eventIds = new List<Decimal> ();
		Set<String> eventSIds = new Set<String> ();
		Lead leadCol;
		Set<String> eventCodes = new Set<String> ();
		Opportunity opp;
		List<LeadOpp> los = new List<LeadOpp> ();
		List<Id> opps = new List<Id> ();
		Map<Id, List<Task>> oppTasks = new Map<Id, List<Task>> ();
		List<Email__c> lstEmailSaves = new List<Email__c> ();
		List<Task> taskSave = new List<Task> ();
		Set<String> evmEventsCancelled = new Set<String> ();

		system.debug('scope.size(): ' + scope.size());
		for (sObject o : scope) {
			system.debug('ll.CoordinatorID__c');
			//  counts[procCount]++;
			system.debug('counts');
			Lead ll = (Lead) o;
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

		for (Events__x e : events) {
			eventCodes.add(e.EventCode__c);
			system.debug('eventCodes = ' + eventCodes);

			//get events from EVM which has status = Cancelled or SystemCancelled
			system.debug('e.StatusID__c ' + e.StatusID__c);
			if (e.StatusID__c == 'cancelled' || e.StatusID__c == 'systemCancelled') {
				evmEventsCancelled.add(e.EventID__c);
			}
		}

		system.debug('number of evmEventsCancelled' + evmEventsCancelled.size());
		system.debug('leads = ' + leads);
		system.debug('consIds = ' + consIds);
		system.debug('eventIds = ' + eventIds);
		system.debug('eventSIds = ' + eventSIds);
		system.debug('los = ' + los.size());
		String eventRevenue = '';
		for (LeadOpp lo : los) {
			//for(Lead l : leads) {
			System.debug('leads= ' + lo.loLead);
			Opportunity o;
			Boolean saveOpp = false;
			//GetEvents
			Events__x e = getEvent(events, lo);
			System.debug('e = ' + e);


			if (e != null && e.EventID__C != null) {
				System.debug('e.EventID__C = ' + e.EventID__C);
				eventRevenue = getTotalRevenue(e.EventID__C.toUpperCase());
				System.debug('eventRevenue = ' + eventRevenue);
			}
			else {
				eventRevenue = '0';
				System.debug('eventRevenue = ' + eventRevenue);
			}

			//do we need to create an opportunity?
			if (NeedsOpp(lo.loLead)) {
				//create the opportunity
				DateTime endDate = cParent.EndDate;
				if (endDate == null) endDate = DateTime.now().addMonths(1);
				System.debug('defaultStage = ' + defaultStage);
				Opportunity newOpp = new Opportunity(
				                                     Name = cParent.Name + ' - ' + lo.loLead.Name
				                                     , Event_Organizer__c = lo.loLead.Id
				                                     , StageName = defaultStage // need to dea with this
				                                     , AccountId = aDef.Id
				                                     , Revenue__c = decimal.valueOf(eventRevenue)
				                                     , StageChanged__c = DateTime.now().addMonths(- 1)
				                                     , CloseDate = endDate.date()
				                                     , RecordTypeId = rType.Id
				                                     , CampaignId = cParent.Id
				                                     , Probability = 5
				);
				o = newOpp;
				IncrementCount('New Opportunities');
				saveOpp = true;
			}
			else {
				o = lo.loLead.Opportunities__r.get(0);
				System.debug('o.Revenue__c = ' + o.Revenue__c);
				System.debug('decimal.valueOf(eventRevenue) = ' + decimal.valueOf(eventRevenue));
				if (o.Revenue__c != decimal.valueOf(eventRevenue)) {
					o.Revenue__c = decimal.valueOf(eventRevenue);
					saveOpp = true;
				}
			}

			system.debug('segments before for ' + segments);
			system.debug('o.StageName ' + o.StageName);
			system.debug('lo.loLead.Id ' + lo.loLead.Id);

			//get cancelled and completed campaign segments
			for (Campaign c : segments) {
				if (c.SegStageName__c == 'Cancelled') {
					cCancelled = c;
				}
				if (c.SegStageName__c == 'Completed') {
					cCompleted = c;
				}
			}

			//is ready for.  this gone change
			for (Campaign c : segments) {

				/*
				  if(isCancelled(o.EventID__C, evmEventsCancelled)){
				 
				  Campaign cSet;
				 
				  //Do somethig with opportunity
				  if(o.Revenue__c <= 0 || o.Revenue__c == null) {
				  cSet = cCancelled;
				 
				  o.StageName = cSet.SegStageName__c;
				  o.StageChanged__c =  DateTime.now();
				  saveOpp = true;
				  }
				  else if (o.Revenue__c > 0) {
				  cSet = cCompleted;
				 
				  o.StageName = cSet.SegStageName__c;
				  o.StageChanged__c =  DateTime.now();
				  saveOpp = true;
				  }
				 
				  if(lo.loLead.DialerStatus__c == 'CheckedOut'){
				  //set dialer status to Remove
				  lo.loLead.DialerStatus__c = 'Remove';
				  } else {
				  if(lo.loLead.DialerStatus__c == 'Removed'){
				  //adding cm to cancel campaign
				  campMems.add(new CampaignMember(
				  LeadId = lo.loLead.Id
				  , CampaignId = cSet.Id;
				  ));
				  //Removing cm from existing  campaign
				  campMemsRemove.add(lo.loLead.Id);
				 
				  IncrementCount(c.Name);
				 
				  break; 
				  }
				  }
				 
				  } 
				  else {*/
				System.debug('c.Id ' + c.Id);
				System.debug('c.SegStageName__c = ' + c.SegStageName__c);
				System.debug('c.AllowPreStages__c = ' + c.AllowPreStages__c);
				Double minProb = oppProbs.get(c.SegStageName__c);
				System.debug('minProb = ' + minProb);
				System.debug('c.AllowPreStages__c = ' + c.AllowPreStages__c);
				System.debug('o.StageName = ' + o.StageName);

				System.debug('o.Probability = ' + o.Probability);

				if (c.SegFiltRev__c == null) {
					System.debug('test ');
				}
				if (o.Probability<minProb) {
					System.debug('test 0');
				}
				if (c.SegFiltRev__c == null) {
					System.debug('test 1');
				}
				if (IsInList(c.AllowPreStages__c, o.StageName)) {
					System.debug('test 2');
				}
				System.debug('after test 2');
				System.debug('c.SegDaysFromEvent__c = ' + c.SegDaysFromEvent__c);
				System.debug('e = ' + e);
				System.debug('e.StartDate__c = ' + e.StartDate__c);
				if (c.SegDaysFromEvent__c == null || e.StartDate__c == null) {
					System.debug('test 3');
				}
				System.debug('after test 3');
				if (e.StartDate__c != null) {
					System.debug('test 4');
				}
				System.debug('after test 4');
				if (c.SegDaysFromEvent__c != null) {
					System.debug('test 5');
				}
				System.debug('after test 5');
				if (DateTime.now() <e.StartDate__c) {
					System.debug('test 6');
				}
				System.debug('after test 6');
				if (DateTime.now()> e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))) {
					System.debug('test 7');
				}
				System.debug('after test 7');
				if (DateTime.now() > e.StartDate__c) {
					System.debug('test 8');
				}
				System.debug('test 8');
				System.debug('DateTime.now()  ' + DateTime.now());
				System.debug('e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c)) ' + e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c)));
				if (DateTime.now() < e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))) {
					System.debug('test 9');
				}

				System.debug('Integer.valueOf(c.SegDaysFromEvent__c) ' + Integer.valueOf(c.SegDaysFromEvent__c));
				System.debug('o.StageChanged__c ' + o.StageChanged__c);
				System.debug('c.SegHrsToWait__c ' + c.SegHrsToWait__c);
				System.debug('o.StageChanged__c.addHours((Integer)c.SegHrsToWait__c) ' + o.StageChanged__c.addHours((Integer) c.SegHrsToWait__c));

				if (o.Revenue__c == null) o.Revenue__c = 0;


				System.debug('c.SegFiltRev__c ' + c.SegFiltRev__c);
				System.debug('o.Revenue__c ' + o.Revenue__c);

				//CONMG-1197: jak 10/30/17
				Boolean sendKitChecked = e != null && e.SendKit__c == true;

				if (DateTime.now() < e.StartDate__c && Integer.valueOf(c.SegDaysFromEvent__c) < 0) {

					//if ((c.SegFiltRev__c == null || (o.Revenue__c >= c.SegFiltRev__c  && c.SegFiltRev__c > 0))
					if ((c.SegFiltRev__c == null || (o.Revenue__c > c.SegFiltRev__c))
					    && (c.IsSegSendKit__c != true || (c.IsSegSendKit__c == true && sendKitChecked)) //CONMG-1197: jak 10/30/17
					    && o.Probability<minProb
					    && IsInList(c.AllowPreStages__c, o.StageName)
					    && o.StageChanged__c.addHours((Integer) c.SegHrsToWait__c) <DateTime.now()
					    && (c.SegDaysFromEvent__c == null || e.StartDate__c == null || //days or date not set
					(e.StartDate__c != null && c.SegDaysFromEvent__c != null && //days and date both set
					((DateTime.now() <e.StartDate__c && //negative number - before event
					  DateTime.now()> e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))) ||
					(DateTime.now() > e.StartDate__c && //positive number - after event
					 DateTime.now() < e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c)))
					)))) {

						system.debug('Pre Event date Stages');
						o.StageName = c.SegStageName__c;
						o.Probability = minProb;
						o.StageChanged__c = DateTime.now();
						campMems.add(new CampaignMember(
						                                LeadId = lo.loLead.Id
						                                , CampaignId = c.Id
						));
						campMemsRemove.add(lo.loLead.Id);
						IncrementCount(c.Name);
						saveOpp = true;
						break;
					}

				}
				else if (DateTime.now() > e.StartDate__c && Integer.valueOf(c.SegDaysFromEvent__c) > 0) {
					//if ((c.SegFiltRev__c == null || (o.Revenue__c >= c.SegFiltRev__c  && c.SegFiltRev__c > 0))
					if ((c.SegFiltRev__c == null || (o.Revenue__c > c.SegFiltRev__c))
					    && (c.IsSegSendKit__c != true || (c.IsSegSendKit__c == true && sendKitChecked)) //CONMG-1197: jak 10/30/17
					    && o.Probability<minProb
					    && IsInList(c.AllowPreStages__c, o.StageName)
					    && o.StageChanged__c.addHours((Integer) c.SegHrsToWait__c) <DateTime.now()
					    && (c.SegDaysFromEvent__c == null || e.StartDate__c == null || //days or date not set
					(e.StartDate__c != null && c.SegDaysFromEvent__c != null && //days and date both set
					((DateTime.now() <e.StartDate__c && //negative number - before event
					  DateTime.now()> e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))) ||
					(DateTime.now() > e.StartDate__c && //positive number - after event
					 DateTime.now() > e.StartDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c)))
					)))) {

						system.debug('Post Event date Stages');
						o.StageName = c.SegStageName__c;
						o.Probability = minProb;
						o.StageChanged__c = DateTime.now();
						campMems.add(new CampaignMember(
						                                LeadId = lo.loLead.Id
						                                , CampaignId = c.Id
						));
						campMemsRemove.add(lo.loLead.Id);
						IncrementCount(c.Name);
						saveOpp = true;
						break;
					}
				}
				else {
					//write error to lead??  or maybe opportunity?
					system.debug('error');
					system.debug(
					             '\no.StageName: ' + o.StageName +
					             '\no.Probability: ' + o.Probability
					);
				}
				//}

				if (saveOpp) {
					break;
				}
			}
			if (saveOpp) {
				oppSave.add(o);
			}
			else {
				IncrementCount('noChangeCount');
			}
			IncrementCount('Total Processed');
			//}else{
			//  System.debug('Reg is null');
			//}
		}

		//delete existing campaign memberships
		System.debug('campMemsRemove.size() ' + campMemsRemove.size());
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
	}

	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = ECCHeroesSegBat.GetEnvelope();

		mail.setSubject(cParent.Name + ' Segmentation Completed (' + UserInfo.getOrganizationId() + ')');
		String body = cParent.Name + ' Segmentation';
		for (String key : segCounts.keySet()) {
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

	private void IncrementCount(String countName) {
		if (segCounts.containsKey(countName)) {
			segCounts.put(countName, segCounts.get(countName) + 1);
		}
		else {
			segCounts.put(countName, 1);
		}
	}

	private Boolean NeedsOpp(Lead l) {
		Boolean bNeeds = false;

		system.debug('l.Opportunities__r: ' + l.Opportunities__r);
		if (l.Opportunities__r == null || l.Opportunities__r.size() == 0) {
			bNeeds = true;
		}

		system.debug('bNeeds: ' + bNeeds);
		return bNeeds;
	}

	private class LeadOpp {
		public Lead loLead;
		public Opportunity loOpp;

		public LeadOpp(Lead l, Opportunity opp) {
			loLead = l;
			loOpp = opp;
		}
	}

	private Boolean isCancelled(String eventId, Set<String> eventIds) {
		System.debug('eventId = ' + eventId);
		Boolean bNeeds = false;
		for (String id : eventIds) {
			if (eventId.toUpperCase() == id.toUpperCase()) {
				bNeeds = true;
				break;
			}
		}
		return bNeeds;
	}

	private Opportunity GetOpp(Lead l) {
		Opportunity opp = null;
		if (l.Opportunities__r != null && l.Opportunities__r.size() > 0) {
			opp = l.Opportunities__r.get(0);
		}

		system.debug('opp == null: ' + opp == null);
		return opp;
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