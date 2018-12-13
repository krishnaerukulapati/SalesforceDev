global class ECCHeroesAltSegBat implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;
	global Boolean errorOnInit;

	global Campaign cParent;
	global Account aDef;
	global RecordType rType;
	
	//hard codes
	global static final String rTypeName;
	global static final String welStage;
	global static final String fromEmail = 'Josh.Rozier@stjude.org';
	global static final String fromName = 'Josh.Rozier@stjude.org';
	global String defaultStage = 'Staged';
	
	global List<Campaign> segments;
	global Map<String, Double> oppProbs;
	global Map<String, Integer> segCounts = new Map<String, Integer>();

	global ECCHeroesAltSegBat(String parentCampId) {
		errorOnInit = true;
		system.debug('init');
		//get the parent campaign to start from based on name
		
		List<Campaign> parents = [select Id, EventId__c, EndDate, OppRecordType__c, OppAcc__r.id,Name from Campaign where Id = :parentCampId];

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
							Id, Name, SegFiltRev__c, SegFiltReg__c, SegFiltPart__c, 
							SegStageName__c, SegHrsToWait__c, AllowPreStages__c, SegTeamCaptain__c, 
							SegDaysFromEvent__c
						from 
							Campaign 
						where 
							ParentId = :cParent.Id 
							and IsSeg__c = true
						order by SegAppOrder__c
						];
						system.debug('segments = ' + segments);
						List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage];
						oppProbs = new Map<String, Double>();
						for(OpportunityStage os : oppStages) {
							oppProbs.put(os.MasterLabel, os.DefaultProbability);
						}

						system.debug('found ' + segments.size() + ' children');
						query = 'select Id, TR_ID__c, Name, XREF__c, (select Id, StageName, Probability, StageChanged__c, Revenue__c from Opportunities__r) from Lead where id in ' + 
								'(select LeadId from CampaignMember where CampaignId = \'' + cParent.Id + '\') ' +
								' and TR_ID__c != null';
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
				sendErrorEmail('Missing record type, developer name \'' + rTypeName + '\' was missing', parentCampId);
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
		if (errorOnInit) {
			System.abortJob(BC.getJobId());
		}

		system.debug('execute');
					
		List<Opportunity> oppSave = new List<Opportunity>();
		List<CampaignMember> campMems = new List<CampaignMember>();
                //leadskills to be created
        List<LeadSkill__c> ls = new List<LeadSkill__c> ();
		List<Id> campMemsRemove = new List<Id>();
		List<Lead> leads = new List<Lead>(); //for the second loop to avoud re-casting
		List<Decimal> consIds = new List<Decimal>();
		List<Decimal> eventIds = new List<Decimal>();
		Lead leadCol;
		//loop 1 to get the revenue info for the leads
		for(sObject o : scope) {
			leadCol = (Lead)o;
			consIds.add(Decimal.valueOf(leadCol.TR_ID__c));

			eventIds.add(getEventIdFromXref(leadCol.XREF__c));
			leads.add(leadCol);
		}

		system.debug('leads = ' + leads);
		system.debug('consIds = ' + consIds);
		system.debug('eventIds = ' + eventIds);

		//go get the event registrations for this set of leads
		List<TREventRegistrationDetails__x> trEventRegs = 
			OdataExtension.GetEventRegDetailsByEventIdCons(eventIds, consIds);

		System.debug('trEventRegs = ' + trEventRegs);	
		for(Lead l : leads) {
			System.debug('leads= ' + l);
			Opportunity o;
			Boolean saveOpp = false;
			TREventRegistrationDetails__x reg = getReg(trEventRegs, l); //get this registration
			system.debug(' registration = ' + reg);
			if (reg != null) {
				//do we need to create an opportunity?
				if (NeedsOpp(l)) {
					//create the opportunity
					DateTime endDate = cParent.EndDate;
					if (endDate == null) endDate = DateTime.now().addMonths(1);
					if(reg.Birthdate__c > DateTime.now().addYears(-16)){
						defaultStage = 'BAD Record';
					}else{
						defaultStage = 'Staged';
					}
					System.debug('defaultStage = ' + defaultStage);
					Opportunity newOpp = new Opportunity(
						Name = cParent.Name + ' - ' + l.Name
						, Event_Organizer__c = l.Id
						, StageName = defaultStage // need to dea with this
						, AccountId = aDef.Id
						, Revenue__c = reg.Current_Event_Revenue__c
						, StageChanged__c = DateTime.now().addMonths(-1)
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
					o = l.Opportunities__r.get(0);
					if (o.Revenue__c != reg.Current_Event_Revenue__c) {
						o.Revenue__c = reg.Current_Event_Revenue__c;
						saveOpp = true;
						o.Revenue__c = reg.Current_Event_Revenue__c;
					}
				}
				if (o.Revenue__c == null) o.Revenue__c = 0;
				if (o.Probability == null) o.Probability = 0;
				system.debug('segments before for ' + segments);

				//is ready for.  this gone change
				for (Campaign c : segments) {
					Double minProb = oppProbs.get(c.SegStageName__c);
					if ((c.SegFiltRev__c == null || o.Revenue__c >= c.SegFiltRev__c)
						&& IsInList(c.SegFiltReg__c, reg.Region__c)
						&& IsInList(c.SegFiltPart__c, reg.Participation_Type_Fundrasing_Level__c)
						&& o.StageChanged__c.addHours((Integer)c.SegHrsToWait__c) < DateTime.now()
						&& o.Probability < minProb
						&& IsInList(c.AllowPreStages__c, o.StageName)
						//get team captain by selection
						&& ((c.SegTeamCaptain__c == 'Y' && reg.Is_Team_Captain__c =='Y') ||
						   (c.SegTeamCaptain__c == 'N' && reg.Is_Team_Captain__c =='N') ||
						   (c.SegTeamCaptain__c == null))
						&& (reg.Birthdate__c == null || reg.Birthdate__c < DateTime.now().addYears(-16))
						&& (c.SegDaysFromEvent__c == null || reg.EventDate__c == null || //days or date not set
							(reg.EventDate__c != null && c.SegDaysFromEvent__c != null && //days and date both set
								((DateTime.now() < reg.EventDate__c && //negative number - before event
								  DateTime.now() > reg.EventDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c))) ||
								 (DateTime.now() > reg.EventDate__c && //positive number - after event
								  DateTime.now() < reg.EventDate__c.addDays(Integer.valueOf(c.SegDaysFromEvent__c)))
								)))
						) {
						system.debug('SegTeamCaptain__c =' + c.SegTeamCaptain__c);
						o.StageName = c.SegStageName__c;
						o.Probability = minProb;
						o.StageChanged__c =  DateTime.now();
						campMems.add(new CampaignMember(
								LeadId = l.Id
								, CampaignId = c.Id
							));
                            
             //update the old leadskill records for that Lead to Remove if they are either Ready or Checked out                    

           List<LeadSkill__c> oldrecords = [select id, Dialerstatus__c from LeadSkill__c where Lead__c  = :l.Id] ;
            if(oldrecords.size()>0){
               for( LeadSkill__c lc:oldrecords){
                   if(lc.Dialerstatus__c == 'Checked Out'){
                     lc.Dialerstatus__c = 'Remove'; 
                   }
                   else {
                       lc.Dialerstatus__c = 'Ignore';
                   }
                    
               }
               
            }
                               
                        //create new leadskill record for the above campaign member
                        ls.add(new LeadSkill__c(
                                Lead__c = l.Id,
                                Campaign__c = c.Id,
                                Opportunity__c = o.Id,
                                Dialerstatus__c = 'Ready'));
                            
						campMemsRemove.add(l.Id);
						IncrementCount(c.Name);
						saveOpp = true;
						break;
					} 
					else {
						//write error to lead??  or maybe opportunity?
						system.debug(
							'o.Revenue__c: ' + o.Revenue__c +
							'\no.StageName: ' + o.StageName + 
							'\no.StageChanged__c.addHours(c.SegHrsToWait__c): ' + o.StageChanged__c.addHours((Integer)c.SegHrsToWait__c) +
							'\no.Probability: ' + o.Probability +
							'\nreg.Participation_Type_Fundrasing_Level__c: ' + reg.Participation_Type_Fundrasing_Level__c 
							);
					}
				}
				if (saveOpp) oppSave.add(o);
				IncrementCount('Total Processed');
			}else{
				System.debug('Reg is null');
			}
		}

		//delete existing campaign memberships
		if (campMemsRemove.size() > 0) {
			system.debug('cParent.Id: ' + cParent.Id);
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
        insert ls;
	}
	
	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = ECCHeroesSegBat.GetEnvelope();

		mail.setSubject(cParent.Name + ' Segmentation Completed (' + UserInfo.getOrganizationId() + ')');
		String body = cParent.Name + ' Segmentation';
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

	private Decimal getEventIdFromXref(String xref) {
		String[] arrXrefval = xref.split('[|]');
		return Decimal.valueOf(arrXrefval[0]);
	}

	private TREventRegistrationDetails__x getReg(List<TREventRegistrationDetails__x> trEventRegs, Lead l) {
		TREventRegistrationDetails__x retEventReg = null;
		for (TREventRegistrationDetails__x reg : trEventRegs) {
			if (reg.P2P_ID__c == Decimal.valueOf(l.TR_ID__c) && reg.EventId__c == getEventIdFromXref(l.XREF__c)) {
				retEventReg = reg;
				break;
			}
		}
		return retEventReg;
	}

	private Boolean IsInList(String listVals, String val) {
		Boolean retInListVals = false;

		if(String.isBlank(listVals) || listVals == '*') {
			retInListVals = true;
		}
		else {
			String[] listValsList = listVals.split('[|]');
			system.debug('listvalslist:' + listValsList.size());
			system.debug('string value of list:' + listVals);
			for (String thisVal : listValsList) {
				if (thisVal == val) {
					retInListVals = true;
					break;
				}
			}
		}

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

}