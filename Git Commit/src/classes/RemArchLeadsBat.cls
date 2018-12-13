global class RemArchLeadsBat implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;
	global Integer IncrementCount = 0;
	global static final String fromEmail = 'belinda.tinsley@stjude.org';
	global static final String fromName = 'belinda.tinsley@stjude.org';
	global Map<String, Integer> segCounts = new Map<String, Integer>();

	//remove campaign members where the status of the lerad is archived and the campign status is not archived
	global RemArchLeadsBat() {
		system.debug('init');
		query = 'select Id from CampaignMember WHERE lead.status = \'Archived\' and campaign.status != \'Archived\' ';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	//scope should be about 200
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		IncrementCount += scope.size();
        delete scope;
    }

	global void finish(Database.BatchableContext BC) {
		Messaging.SingleEmailMessage mail = RemArchLeadsBat.GetEnvelope();

		mail.setSubject(' Removal of archived leads Completed (' + UserInfo.getOrganizationId() + ')');
		String body = 'Leads archived: ';
		body += String.valueOf(IncrementCount);

		mail.setPlainTextBody(body);
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
			Name = 'Remove Archived CampMem'];

		mail.setToAddresses(new String[] { email.Email__c });
		mail.setReplyTo(fromEmail);
		mail.setSenderDisplayName(fromName);

		return mail;
	}
}