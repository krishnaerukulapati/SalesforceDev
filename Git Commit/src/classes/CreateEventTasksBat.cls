global class CreateEventTasksBat implements Database.Batchable<sObject>, Database.Stateful {
	global String query;
	global Boolean errorOnInit;
	global String eventName;
	global String eventID;

	global static final String fromEmail = 'ALSACTaskCreation@stjude.org';
	global static final String fromName = 'ALSACTaskCreation@stjude.org';

	global Id GetGroupToAssign(String role, String region, String program, String format) {
		String regionRole = region + ' ' + program + ' ' + role;
		String formatRole = format + ' ' + role;
		System.debug(formatRole + ' ' + regionRole);
		List<Group> grp = [SELECT Id FROM Group where Name = :role and Type = 'Regular'];
		if (grp.isEmpty()){
			grp = [SELECT Id FROM Group where Name = :regionRole];
			if (grp.isEmpty()){
				grp = [SELECT Id FROM Group where Name = :formatRole];
			}
			
		}
		if (!grp.isEmpty()) {
			system.debug('Public group found for : ' + role + ', ' + region + ', ' + program + ', ' + format + ',' + grp[0].Id);
			return grp[0].Id;
		}
		else {
			system.debug('No public group found for: ' + role + ', ' + region + ', ' + program + ', ' + format);
			return null;
		}
	}

	global CreateEventTasksBat() {
		errorOnInit = true;
		system.debug('start query');
		query = 'select id, Name, LeadStaff__c, LeadStaff__r.Id, Program__c, Region__c, StartDate__c, TasksCreated__c, ' + 
		'Radio_Type__c, Radio_Format__c, Has_Alcohol__c, Has_Raffle__c, Need_Auctioneer__c, Need_ITS_Support__c, Program_Representative__c, Program_Representative__r.Id ' +
			    'from ALSACEvent__c ' +
			    'where TasksCreated__c = false AND LeadStaff__c != null';
		system.debug(query);
		errorOnInit = false;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		system.debug('execute');
		if (errorOnInit) {
			System.abortJob(BC.getJobId());
		}
		//do the stuffs!!
		
		for(sObject s : scope) {
			ALSACEvent__c e = (ALSACEvent__c)s;
			eventName = e.Name;
			eventID = e.Id;
			//validate that we don't have campaigns for this event
			//to-do: make way more complex
			List<Campaign> c = [select id from Campaign where ALSACEvent__c = :e.id];
			if (c.size() == 0) {
				//no campaigns, let's do this!
                List<EventTask__c> ets = [
                    select 
                        Assignee__c
                        , Assignee__r.Id
                        , DueInWeeks__c
                        , DueInDays__c
                        , Recurring__c
                        , Responsible_Role__c
                        , EventTask__c
                        , EventTaskFunction__c
                        , EventTaskProgram__c
                        , EventTaskSubfunction__c
                        , EventTaskType__c
                        , EventOppRTy__c
                        , EventOppStage__c
                        , Radio_Type__c
                    from
                        EventTask__c
                    where
                        EventTaskProgram__c = :e.Program__c
                    order by
                        EventTaskFunction__c
                        , EventTaskSubfunction__c
                        , EventTaskType__c
                        , EventTask__c];

				if (ets.size() > 0) {
					system.debug('Creating campaigns, opps, and tasks');
					//we have tasks to create, let's do this too!
					Id grp = GetGroupToAssign('Representative', e.Region__c, e.Program__c, e.Radio_Format__c);
					if (grp != null){
						Id rep = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :grp LIMIT 1].UserOrGroupId;
						system.debug('Assigning ' + rep + ' as ' + e.Region__c + ' ' + e.Program__c + ' Representative');
                    	e.Program_Representative__c = rep;
                	}					
					Map<String, Campaign> camps = CreateCampaigns(e, ets);
					Map<String, Opportunity> opps = CreateOpportunities(e, ets, camps);
					CreateTasks(e, ets, camps, opps);
					System.debug(e);
					e.TasksCreated__c = true;
					update e;

					/*List<EventTask__c> ts = [select EventTasksCreated__c from EventTask__c where EventTasksCreated__c = false and EventTaskProgram__c = :e.Program__c ];
					for(EventTask__c task :ts){
   						 task.EventTasksCreated__c = true;
					}
					update ts;*/									
				}
			}
		}
	}

	//creates the campaigns for this event
	global Map<String, Campaign> CreateCampaigns(ALSACEvent__c e, List<EventTask__c> ets) {
		system.debug('Creating campaigns');
		String currFunction = ''; //current function (campaign)
		List<Campaign> cs = new List<Campaign>(); //to hold newly created campaigns
		Map<String, Campaign> funcCamp = new Map<String, Campaign>(); // to return a map of function to campaign for opps

		for (EventTask__c et : ets) {
			if (currFunction != et.EventTaskFunction__c) {
				//create the camkpmaign
				Campaign newCampaign = new Campaign(
					ALSACEvent__c = e.Id //related to the current scope event
					//, Name = e.Name + ' - ' + et.EventTaskFunction__c //event name - function
					, Name = et.EventTaskFunction__c //event name - function
					, StartDate = Date.valueOf(e.StartDate__c) //set campaign start date to event startdate
					, IsActive = true //activate the campaign
					, OwnerID = e.LeadStaff__r.Id
					);

				currFunction = et.EventTaskFunction__c; //for the loops!
				cs.add(newCampaign); //for the saves!
				funcCamp.put(currFunction, newCampaign); //for the opportunities!
			}
		}

		insert cs;
		return funcCamp;
	}

	//creates the opportunities for this event
	//these are unique at the Function+Subfunction level
	global Map<String, Opportunity> CreateOpportunities(ALSACEvent__c e, List<EventTask__c> ets, Map<String, Campaign> camps) {
		system.debug('Creating opportunity');
		String currFunctionSub = ''; //current sub function (opportunity)
		List<Opportunity> opps = new List<Opportunity>(); //to hold newly created opportunity
		Map<String, Opportunity> funcOpp = new Map<String, Opportunity>(); // to return a map of  function to campaign for opps

		for (EventTask__c et : ets) {
			if (currFunctionSub != et.EventTaskFunction__c + '|' + et.EventTaskSubfunction__c) {
			//if (currFunctionSub != et.EventTaskSubfunction__c) {
				if ((e.Radio_Type__c != 'National' && et.Radio_Type__c != 'National') 
							|| (e.Radio_Type__c == 'National' && et.Radio_Type__c == 'National')
							|| (e.Radio_Type__c == 'National' && et.Radio_Type__c != 'National')) {
					Opportunity newOpp = new Opportunity(
						CampaignId = camps.get(et.EventTaskFunction__c).Id //related to the appropriate campaign
						//, Name = e.Name + ' - ' + et.EventTaskFunction__c + ' - ' + et.EventTaskSubfunction__c 
						, Name = et.EventTaskSubfunction__c 
							//event name - function - subfunction
						, CloseDate = Date.valueOf(e.StartDate__c.addDays(14)) //set opportunity close date to 2 weeks after event date
						//, StageName = et.OppStage__c
						,StageName ='Open'
						,RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(et.EventOppRTy__c).getRecordTypeId()
						,Event_Start_Date__c = Date.valueOf(e.StartDate__c)
                        ,Lead_Staff__c   =  e.LeadStaff__r.Id
                        ,OwnerID = e.LeadStaff__r.Id
                    );

					currFunctionSub = et.EventTaskFunction__c + '|' + et.EventTaskSubfunction__c; //for the loops!
					//currFunctionSub = et.EventTaskSubfunction__c; //for the loops!
					opps.add(newOpp); //for the saves!
					funcOpp.put(currFunctionSub, newOpp); //for the opportunities!
				}
			}
		}
		insert opps;
		return funcOpp;
	}

	//creates the tasks for this event
	//these are unique at the Function+Subfunction+TaskName (subject) level, but we shouldn't have to care
	global void CreateTasks(ALSACEvent__c e, List<EventTask__c> ets, Map<String, Campaign> camps, Map<String, Opportunity> opps) {
		system.debug('Creating tasks');
		List<Task> tsks = new List<Task>(); //to hold newly created tasks		
		Boolean createTasks = true;
		
		for (EventTask__c et : ets) {
			//create the task
			System.debug('Start of task for loop');
			Set<String> assignTo = new Set<String>();
			List<Id> owners = new List<Id>();

			Date actDate = Date.valueOf(e.StartDate__c.addDays(Integer.valueOf(-1 * et.DueInDays__c)));		

			if (String.isNotEmpty(et.Responsible_Role__c)){
				assignTo.addAll(et.Responsible_Role__c.split('\\;'));
			}

			for (String a : assignTo){
				Id grp = GetGroupToAssign(a, e.Region__c, e.Program__c, e.Radio_Format__c);
				if (grp != null){
					List<GroupMember> grpMbr = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :grp];                 
					for (GroupMember gm : grpMbr){
                        owners.add(gm.UserOrGroupId);
                    }
                }                       
            }

			for (Id i : owners) {
				System.debug('Users from public group list: ' + i);
			}		
	
			//Lead Staff
			if (assignTo.contains('Lead Staff') || owners.isEmpty()) {
				owners.add(e.LeadStaff__r.Id);
			}

			for (Id i : owners) {
				System.debug('Final Owner list: ' + i);
			}
			do {			
				createTasks = false;
				if (actDate > Date.today()) { //don't create historical tasks					
					//Create a task for each owner in owners
					for (Id i : owners) {
						if ((e.Radio_Type__c != 'National' && et.Radio_Type__c != 'National') 
							|| (e.Radio_Type__c == 'National' && et.Radio_Type__c == 'National')
							|| (e.Radio_Type__c == 'National' && et.Radio_Type__c != 'National')) {
							system.debug('creating task '+ et.EventTask__c + ' for ' + i + ' with activity date ' + actDate);
							Task newTsk = new Task(				
								WhatId = opps.get(et.EventTaskFunction__c + '|' + et.EventTaskSubfunction__c).Id
								//WhatId = opps.get(et.EventTaskSubfunction__c).Id
									//related to the appropriate opportunity
								, Subject = et.EventTask__c
									//EventTask__c
								, OwnerID = i
								, ActivityDate = actDate
									//set activity date to number of days from event date
								, Priority = 'Normal'
								, Status = 'Not Started'
								, EventTaskType__c = et.EventTaskType__c
								, EventTaskOppStage__c = et.EventOppStage__c
							);
							tsks.add(newTsk); //for the saves!	
						}
					}									

					if (et.Recurring__c == true) {
						actDate = Date.valueOf(actDate.addDays(Integer.valueOf(-1 * et.DueInDays__c)));
						system.debug('Recurring event, setting acitivity date to: ' + actDate);
						createTasks = true;
					}
				}

			} while (createTasks == true);			
		}

		insert tsks;
	}

	global void finish(Database.BatchableContext BC) {
		//system.debug('Sending email');
		//String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
		//Messaging.SingleEmailMessage mail = CreateEventTasksBat.GetEnvelope();

		//mail.setSubject('ALSAC Event Creation');
		//String body = 'Tasks, opportunities, and campaigns have been generated for event ' + eventName + ' in ECC Salesforce: ' + sfdcBaseURL + '/' + eventID;
		//mail.setPlainTextBody(body);
		//Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

	global static Messaging.SingleEmailMessage GetEnvelope() {
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	               EmailSettings__c email = [
			SELECT 
			    DeliminatedEmail__c
			from
			    EmailSettings__c 
			where
				Name = 'CreateEventTasks'];

		mail.setToAddresses(email.DeliminatedEmail__c.split('\\;'));
		mail.setReplyTo(fromEmail);
		mail.setSenderDisplayName(fromName);

		return mail;
	}

}