global class EmailExecSegBat implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	String templateid;
	
	global EmailExecSegBat() {
		system.debug('emailexec init');
		query = 'select emailsent__c, bindfield1__c,  bindfield2__c,  bindfield3__c, bindfield4__c, '+
		'bindfield5__c, bindfield6__c,  bindfield7__c, bindfield8__c,  bindfield9__c,  bindfield10__c, ' +
		'recipientemails__c, template__c, Body__c, Id, Subject__c from Email__c  where emailsent__c != \'Y\' and HasBody__c = \'Y\'';	

		system.debug('emailexec query =' + query);	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Email__c> scope) {
   		system.debug('emailexec scope.size(): ' + scope.size());
   		String sts;
   		List<Email__c> lstEmailOK = new List<Email__c>();

   		//loop through to email 
		for(Email__c ets : scope) {
            system.debug('emailexec ets =' + ets);
            sts = SendMailUtilities.sendEmailObjectFromExternalServer(ets.Body__c, 
            	ets.Id, 
            	ets.RecipientEmails__c, 
            	ets.Subject__c, 
            	'stjudeevents@stjude.org');

            if (sts == 'OK'){
            	ets.EmailSent__c = 'Y';
	    		lstEmailOK.add(ets);
        	}
        }
        if (lstEmailOK.size() > 0) {
			upsert lstEmailOK;
        }
        //loop through to delete email objects
        //}	
        //for(Email__c ets : scope) {
        //    ets.EmailSent__c = 'Y';
        //    upsert ets;
        //}	
	}	
	global void finish(Database.BatchableContext BC) {
	}
	
}