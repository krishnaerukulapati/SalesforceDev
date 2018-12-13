global class ECCHeroesSegBat implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;
	global Boolean errorOnInit;

	global Campaign cParent;
	global Campaign cWel;
	global Campaign cAct;
	global Campaign cAct2;
	global Campaign cCult;
	global Campaign cCult2;
	global Campaign cVWel;
	global Campaign cVAct;
	global Campaign cVAct2;
	global Campaign cVCult;
	global Campaign cVCult2;
	global Account aDef;
	global RecordType rType;
	global Integer newWelCount = 0;
	global Integer newActCount = 0;
	global Integer newAct2Count = 0;
	global Integer newCultCount = 0;
	global Integer newCult2Count = 0;
	global Integer newVWelCount = 0;
	global Integer newVActCount = 0;
	global Integer newVAct2Count = 0;
	global Integer newVCultCount = 0;
	global Integer newVCult2Count = 0;
	global Integer newOppCount = 0;
	global Integer procCount = 0;

	//hard codes
	global static final String parentCampName = 'Heroes Nashville FY16';
	global static final String welCampName = 'Heroes Nashville Welcome';
	global static final String actCampName = 'Heroes Nashville Activation';
	global static final String act2CampName = 'Heroes Nashville Activation 2';
	global static final String cultCampName = 'Heroes Nashville Cultivation';
	global static final String cult2CampName = 'Heroes Nashville Cultivation 2';
	global static final String welVCampName = 'Heroes Nashville VWelcome';
	global static final String actVCampName = 'Heroes Nashville VActivation';
	global static final String act2VCampName = 'Heroes Nashville VActivation 2';
	global static final String cultVCampName = 'Heroes Nashville VCultivation';
	global static final String cult2VCampName = 'Heroes Nashville VCultivation 2';
	global static final String accountName = 'ALSAC Heroes';
	global static final String rTypeName = 'Heroes';
	global static final String welStage = 'Welcome';
	global static final String welCompStage = 'Welcome - Complete';
	global static final String actStage = 'Activation';
	global static final String actCompStage = 'Activation - Complete';
	global static final String act2Stage = 'Activation 2';
	global static final String act2CompStage = 'Activation 2 - Complete';
	global static final String cultStage = 'Cultivation';
	global static final String cultCompStage = 'Cultivation - Complete';
	global static final String cult2Stage = 'Cultivation 2';
	global static final String cult2CompStage = 'Cultivation 2 - Complete';
	global static final String prosStage = 'BAD Record';
	global static final String unVIP = 'Classic Hero level';
	global static final String fromEmail = 'Josh.Rozier@stjude.org';
	global static final String fromName = 'Josh.Rozier@stjude.org';
	global final Integer actHoursToWait;
	global final Integer act2HoursToWait;
	global final Integer cultHoursToWait;
	global final Integer cult2HoursToWait;

	global ECCHeroesSegBat() {
		errorOnInit = true;
		system.debug('init');
		//get the parent campaign to start from based on name

		EnvironmentSettings__c es = [
            SELECT 
                ActHoursToWait__c
                , Act2HoursToWait__c
                , CultHoursToWait__c
                , Cult2HoursToWait__c
            from
				EnvironmentSettings__c 
            where
				SetupOwnerId = :UserInfo.getOrganizationId()];

        actHoursToWait = Integer.valueOf(es.ActHoursToWait__c);
        act2HoursToWait = Integer.valueOf(es.Act2HoursToWait__c);
        cultHoursToWait = Integer.valueOf(es.CultHoursToWait__c);
        cult2HoursToWait = Integer.valueOf(es.Cult2HoursToWait__c);

		List<Account> accounts = [select Id from Account where Name = :accountName];
		List<Campaign> parents = [select Id, EventId__c, EndDate from Campaign where Name = :parentCampName];
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
					//get the children
					List<Campaign> children = [select Id, Name from Campaign where ParentId = :cParent.Id];
					if (children.size() == 10) {
						//good
						//find the children and store them
						system.debug('found 10 children');
						for (Campaign c : children) {
							if (c.Name == welCampName) cWel = c;
							else if (c.Name == actCampName) cAct = c;
							else if (c.Name == act2CampName) cAct2 = c;
							else if (c.Name == cultCampName) cCult = c;
							else if (c.Name == cult2CampName) cCult2 = c;
							else if (c.Name == welVCampName) cVWel = c;
							else if (c.Name == actVCampName) cVAct = c;
							else if (c.Name == act2VCampName) cVAct2 = c;
							else if (c.Name == cultVCampName) cVCult = c;
							else if (c.Name == cult2VCampName) cVCult2 = c;
							else {
								system.debug(c.Name);
							} //error - malconfigured campaign
						}
						if (cWel != null && cAct != null && cAct2 != null && cCult != null && cCult2 != null &&
							cVWel != null && cVAct != null && cVAct2 != null && cVCult != null && cVCult2 != null) {
							system.debug('found correct 10 children');
							query = 'select Id, TR_ID__c, Name, (select Id, StageName, Probability, StageChanged__c, Revenue__c from Opportunities__r) from Lead where id in ' + 
								'(select LeadId from CampaignMember where CampaignId = \'' + cParent.Id + '\') ' +
								' and TR_ID__c != null';
							system.debug(query);
							List<Lead> querySize = [select Id, TR_ID__c, Name, (select Id, StageName, Probability, StageChanged__c, Revenue__c from Opportunities__r) from Lead where id in 
								(select LeadId from CampaignMember where CampaignId = :cParent.Id) 
								 and TR_ID__c != null] ;
								system.debug('querySize = ' + querySize.size());
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
					//error - malconfigured account
					sendErrorEmail('Malconfigured account, account \'' + accountName + '\' was missing');
				}
			}
			else {
				//error - malconfigured campaign
				sendErrorEmail('Malconfigured campaign, campaign \'' + parentCampName + '\' was missing');
			}
		}
		else {
			//error - missing record type
			sendErrorEmail('Missing record type, developer name \'' + rTypeName + '\' was missing');
		}

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('start');
		system.debug('query = ' + query);
		system.debug('Database.getQueryLocator(query) = ' + Database.getQueryLocator(query));
		return Database.getQueryLocator(query);
	}

	//scope should be about 15
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		system.debug('execute');
   		system.debug('errorOnInit = ' + errorOnInit);
   		if (errorOnInit) {
   			System.abortJob(BC.getJobId());
   		}

   		List<Opportunity> oppSave = new List<Opportunity>();
   		List<CampaignMember> campMems = new List<CampaignMember>();
   		List<Id> campMemsRemove = new List<Id>();
   		List<Lead> leads = new List<Lead>(); //for the second loop to avoud re-casting
		List<Decimal> consIds = new List<Decimal>();
   		
   		//loop 1 to get the revenue info for the leads
		for(sObject o : scope) {
			Lead l = (Lead)o;
			consIds.add(Decimal.valueOf(l.TR_ID__c));
			leads.add(l);
		}

		//go get the event registrations for this set of leads
		List<TREventRegistrationDetails__x> trEventRegs = 
			OdataExtension.GetEventRegDetailsByEventIdCons(cParent.EventId__c, consIds);
   		
		for(Lead l : leads) {
			Opportunity o;
			Boolean saveOpp = false;
			TREventRegistrationDetails__x reg = getReg(trEventRegs, l); //get this registration
			if (reg != null) {
				//do we need to create an opportunity?
				if (NeedsOpp(l)) {
					//create the opportunity
					DateTime endDate = cParent.EndDate;
					if (endDate == null) endDate = DateTime.now().addMonths(1);
					Opportunity newOpp = new Opportunity(
						Name = parentCampName + ' - ' + l.Name
						, Event_Organizer__c = l.Id
						, StageName = prosStage
						, AccountId = aDef.Id
						, Revenue__c = reg.Current_Event_Revenue__c
						, StageChanged__c = DateTime.now().addHours((cultHoursToWait + 1) * -1)
						, CloseDate = endDate.date()
						, RecordTypeId = rType.Id
						, CampaignId = cParent.Id
					);
					o = newOpp;
					newOppCount++;
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
				Boolean bIsVIP = isVipParticiationType(reg.Participation_Type_Fundrasing_Level__c);
				if (ReadyForWelcome(o)) {
					o.StageName = welStage;
					o.StageChanged__c =  DateTime.now();
					if (!bIsVIP) {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cVWel.Id
						));
						newWelCount++;
					}
					else {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cWel.Id
						));
						newVWelCount++;
					}
					campMemsRemove.add(l.Id);
					saveOpp = true;
				}
				else if (ReadyForAct(o)) {
					o.StageName = actStage;
					o.StageChanged__c =  DateTime.now();
					if (!bIsVIP) {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cAct.Id
						));
						newActCount++;
					}
					else {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cVAct.Id
						));
						newVActCount++;
					}
					campMemsRemove.add(l.Id);
					saveOpp = true;
				}
				else if (ReadyForAct2(o)) {
					o.StageName = act2Stage;
					o.StageChanged__c =  DateTime.now();
					if (!bIsVIP) {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cAct2.Id
						));
						newAct2Count++;
					}
					else {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cVAct2.Id
						));
						newVAct2Count++;
					}
					campMemsRemove.add(l.Id);
					saveOpp = true;
				}
				else if (ReadyForCult(o)) {
					o.StageName = cultStage;
					o.StageChanged__c =  DateTime.now();
					if (!bIsVIP) {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cCult.Id
						));
						newCultCount++;
					}
					else {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cVCult.Id
						));
						newVCultCount++;
					}
					campMemsRemove.add(l.Id);
					saveOpp = true;
				}
				else if (ReadyForCult2(o)) {
					o.StageName = cult2Stage;
					o.StageChanged__c =  DateTime.now();
					if (!bIsVIP) {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cCult2.Id
						));
						newCult2Count++;
					}
					else {
						campMems.add(new CampaignMember(
							LeadId = l.Id
							, CampaignId = cVCult2.Id
						));
						newVCult2Count++;
					}
					campMemsRemove.add(l.Id);
					saveOpp = true;
				}
				else {
					system.debug(
						'o.Revenue__c: ' + o.Revenue__c +
						'\no.StageName: ' + o.StageName + 
						'\no.StageChanged__c.addHours(act2HoursToWait): ' + o.StageChanged__c.addHours(act2HoursToWait) +
						'\no.Probability: ' + o.Probability +
						'\nreg.Participation_Type_Fundrasing_Level__c: ' + reg.Participation_Type_Fundrasing_Level__c
						);
				}
				if (saveOpp) oppSave.add(o);
				procCount++;
			}
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
	}
	
	global void finish(Database.BatchableContext BC) {
		system.debug('finish');
		Messaging.SingleEmailMessage mail = ECCHeroesSegBat.GetEnvelope();

		mail.setSubject('Heroes Segmentation Completed (' + UserInfo.getOrganizationId() + ')');
		mail.setPlainTextBody('Heroes Segmentation ' + 
			'\nprocessed: ' + procCount + 
			',\nnew opps: ' + newOppCount + 
			',\nnew welcome: ' + newWelCount + 
			',\nnew activation: ' + newActCount +
			',\nnew activation 2: ' + newAct2Count +
			',\nnew cultivation: ' + newCultCount +
			',\nnew cultivation 2: ' + newCult2Count +
			',\nnew vwelcome: ' + newVWelCount + 
			',\nnew vactivation: ' + newVActCount +
			',\nnew vactivation 2: ' + newVAct2Count +
			',\nnew vcultivation: ' + newVCultCount +
			',\nnew vcultivation 2: ' + newVCult2Count 
			);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	@TestVisible private static void sendErrorEmail(String error) {
		system.debug('sendErrorEmail');
		Messaging.SingleEmailMessage mail = GetEnvelope();
		mail.setSubject('Heroes Segmentation Exception (' + UserInfo.getOrganizationId() + ')');
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
		mail.setReplyTo(fromEmail);
		mail.setSenderDisplayName(fromName);

		return mail;
	}

	private TREventRegistrationDetails__x getReg(List<TREventRegistrationDetails__x> trEventRegs, Lead l) {
		TREventRegistrationDetails__x retEventReg = null;
		for (TREventRegistrationDetails__x reg : trEventRegs) {
			if (reg.P2P_ID__c == Decimal.valueOf(l.TR_ID__c)) {
				retEventReg = reg;
				break;
			}
		}
		return retEventReg;
	}

	private Boolean ReadyForWelcome(Opportunity o) {
		Boolean bReady = false;

		if (o.StageName == prosStage && o.Revenue__c == 0 ) {
			bReady = true;
		}

		return bReady;
	}

	private Boolean ReadyForAct(Opportunity o) {
		Boolean bReady = false;

		if (((o.StageName == welCompStage && o.StageChanged__c.addHours(actHoursToWait) < DateTime.now()) ||
			 (o.Revenue__c > 0 && (o.Probability == null || o.Probability < 45)))
		   ) {
			bReady = true;
		}

		return bReady;
	}

	private Boolean ReadyForAct2(Opportunity o) {
		Boolean bReady = false;

		if (o.StageName == actCompStage &&
			o.StageChanged__c.addHours(act2HoursToWait) < DateTime.now()) {
			bReady = true;
		}

		return bReady;
	}

	private Boolean ReadyForCult(Opportunity o) {
		Boolean bReady = false;

		if (o.Revenue__c != 0 && 
			o.StageName == act2CompStage &&
			o.StageChanged__c.addHours(act2HoursToWait) < DateTime.now())  {
			bReady = true;
		}

		return bReady;
	}

	private Boolean ReadyForCult2(Opportunity o) {
		Boolean bReady = false;

		if (o.Revenue__c != 0 && 
			o.Probability != 100 &&
			o.Probability != 0 &&
			o.StageName == cultCompStage &&
			o.StageChanged__c.addHours(cult2HoursToWait) < DateTime.now()) {
			bReady = true;
		}

		return bReady;
	}

	private Boolean isVipParticiationType(String partType) {
		if (partType != 'Classic Hero level') {
			return true;
		}
		else {
			return false;
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