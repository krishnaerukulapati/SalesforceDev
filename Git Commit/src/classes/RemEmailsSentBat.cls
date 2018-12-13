global class RemEmailsSentBat implements Database.Batchable<sObject>, Database.Stateful {
	
	global final String query;

	//delete email__c where emails are send and created = last week
	global RemEmailsSentBat() {
		
		query = 'select Id, EmailSent__c from email__c WHERE EmailSent__c = \'Y\' and createddate <= last_week';
		system.debug('query: ' + query);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	//scope should be about 1000
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		system.debug('scope: ' + scope);
        delete scope;
    }

	global void finish(Database.BatchableContext BC) {
	}
}