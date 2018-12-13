global class ArchiveLeadsBat implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
	
	global final String query;
	global Boolean errorOnInit;

	private Campaign currCampaign;
	private Lead currLead;
	private CampaignMember cm;

	global static final String fromEmail = 'kristopher.karolchyk.contractor@stjude.org';
  	global static final String fromName = 'kristopher.karolchyk.contractor@stjude.org';
	global Map<String, Integer> processCounts = new Map<String, Integer>();

	global ArchiveLeadsBat(){
	}
	
	global ArchiveLeadsBat(Campaign currCamp) {
		//Mostly for validation purposes
		errorOnInit = true;
		System.debug('init: ArchiveLeadsBat(' + currCamp + ')');

		if (isCampaignValid(currCamp)) {
			currCampaign = currCamp;
			errorOnInit = false;
			//removed Lead.DialerStatus__c (don't need dialer from there anymore)
			query = 'SELECT Id, LeadId, Lead.CurrentCampaign__c, CampaignId FROM CampaignMember WHERE CampaignId = \'' + currCamp.Id + '\' AND CreatedDate < LAST_N_DAYS:55';
		}
		else {
			sendErrorEmail('Campaign is not valid: ' + currCamp.Id + '. (' + currCamp.Name + ')', currCamp.Id);
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		//Actual flow of process
   		System.debug('Inside execute: ErrorOnInit = ' + errorOnInit);
   		if (errorOnInit){
   			System.abortJob(BC.getJobId());
   		}

		System.debug('ArchiveLeadsBat starting: currentCampaign: ' + currCampaign.Id);
		//Getting required info
		for(sObject s : scope){
			CampaignMember cm = (CampaignMember)s;
			System.debug('current campaign member: ' + cm);

			currLead = assignLeadFromCampM(cm);
			System.debug('current Lead: ' + currLead);


			//Set all LeadSkills to Remove if currently 'CheckedOut' || 'Ready'
			checkLeadSkillsAndRemove(currLead, currCampaign);
			IncrementCount('LeadSkillsSetToRemove');

			//Is the currentLead in same campaign as the CampaignMember?
			if(isLeadInSameCampaign(cm, currLead)){
				//Move lead to Archive campaign and delete campaignMember
				moveLeadToArchive(currLead, currCampaign);
				IncrementCount('LeadsMovedToArchive');
				deleteCampaignMember(cm);
				IncrementCount('CampaignMembersDeleted');
			}
			else{
				System.debug('Campaign Member and Lead are in different campaigns: Deleting CampaignMember');
				deleteCampaignMember(cm);
				IncrementCount('CampaignMembersDeleted');
			}
		}		
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('we are in the finish');

		//send email, might need to refactor this out
		Messaging.SingleEmailMessage mail = GetEnvelope();
		
		mail.setSubject(currCampaign.Name + ' Archival Completed (' + UserInfo.getOrganizationId() + ')');
		String body = currCampaign.Name + ': Archival Process';
		if(processCounts.isEmpty()){
			body += '\n\nNo Leads altered';
		}
		else{
			for(String key : processCounts.keySet()) {
				System.debug('current key in processCounts: ' + key);
				body += '\n\n' + key + ': ' + processCounts.get(key);
			}	
		}
		mail.setPlainTextBody(body);

		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		//end of email portion
	}

  	@TestVisible global static Messaging.SingleEmailMessage GetEnvelope() {
	  	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	  	    EmailSettings__c email = [
	  	    	SELECT 
	  	    	    Email__c, DeliminatedEmail__c
	  	    	FROM
	  	    	    EmailSettings__c 
	  	    	WHERE
	  	    	  Name = 'ArchiveLeads'];

		System.debug('email =' + email);
	  	String [] emailList = email.DeliminatedEmail__c.split(';');
	  	mail.setToAddresses(emailList);
	  	mail.setSenderDisplayName(email.Email__c);
	  	
  	  	return mail;
  	}

  	@TestVisible private void IncrementCount(String countName) {
  		System.debug('processCounts: ' + processCounts);
    	if (processCounts.containsKey(countName)) {
      		processCounts.put(countName, processCounts.get(countName) + 1);
    	}
    	else {
      		processCounts.put(countName, 1);
    	}
  	}

  	@TestVisible private static void sendErrorEmail(String error, String campaignId){
		Messaging.SingleEmailMessage mail = GetEnvelope();
    	mail.setSubject(campaignId + ' Archival Process Exception (' + UserInfo.getOrganizationId() + ')');
    	mail.setPlainTextBody(error);
    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

  	/// <summary>
	/// Method validates Campaign as valid archive campaign
	/// </summary>
	/// <param name="camp">Campaign to check isArchivable__c = true and ArchiveDestination__c != null
	@TestVisible private Boolean isCampaignValid(Campaign camp) {
		Boolean isValid = false;
		if (camp.isArchivable__c == true && camp.ArchiveDestination__c != null){
			isValid = true;
		}
		System.debug('isCampaignValid?: ' + isValid);
		return isValid;
	}

	///Starting query for this batch returns CampaignMember object
	///This method is to pull Lead out of that into its own object
	@TestVisible private Lead assignLeadFromCampM(CampaignMember cm) {
		System.debug('Pulling lead out of campaignMember');
		Lead l = new Lead();
		l.Id = cm.LeadId;
		l.Currentcampaign__c = cm.Lead.CurrentCampaign__c;
		return l;
	}

	/// <summary>
	/// Finds all LeadSkills Lead+Campaign have.  Finds all that are in danger of going to Dialer (CheckedOut || Ready) and Removes them
	/// </summary>
	@TestVisible private void checkLeadSkillsAndRemove(Lead l, Campaign c) {
		System.debug('Find all the LeadSkills');
		List<LeadSkill__c> leadSkills = [
			SELECT Id
			FROM LeadSkill__c
			WHERE Lead__c = :l.Id
			AND Campaign__c = :c.Id
			AND DialerStatus__c IN ('CheckedOut', 'Ready')
		];
		//For each LeadSkill for this Lead+Campaign set to Remove
		for(LeadSkill__c ls : leadSkills){
			ls.DialerStatus__c = 'Remove';
			update ls;
		}
	}

	//Validates that campaignmember and lead we are working with are in the same campaign
	@TestVisible private Boolean isLeadInSameCampaign(CampaignMember cm, Lead l) {
		Boolean matchingCampaigns = false;
		System.debug('Does (cm.CampaignId: ' + cm.CampaignId + ') = (l.CurrentCampaign__c: ' + l.CurrentCampaign__c);
		if (cm.CampaignId == l.CurrentCampaign__c){
			matchingCampaigns = true;
		}
		System.debug('Is CampaignMem and Lead in matching Campaigns?: ' + matchingCampaigns);
		return matchingCampaigns;
	}

	//Method will move Lead to Campaign.ArchiveDestination__c
	@TestVisible private void moveLeadToArchive(Lead l, Campaign c) {
		System.debug('Moving Lead to Archive campaign:');
		l.CurrentCampaign__c = c.ArchiveDestination__c;
		update l;
	}

	@TestVisible private void deleteCampaignMember(CampaignMember cm) {
		delete cm;
	}

	
}