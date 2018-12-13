global class EmailSendSegBat implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	String templateid;
	global static final String fromEmail = 'belinda.tinsley@stjude.org';
	global static final String fromName = 'belinda.tinsley@stjude.org';
	
	global EmailSendSegBat() {
		system.debug('init');
		query = 'select emailsent__c, bindfield1__c,  bindfield2__c,  bindfield3__c, bindfield4__c, '+
		'bindfield5__c, bindfield6__c,  bindfield7__c, bindfield8__c,  bindfield9__c,  bindfield10__c, ' +
		'recipientemails__c, template__c, Body__c from Email__c where emailsent__c != \'Y\'';	

		system.debug('query =' + query);	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Email__c> scope) {
   		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
   		system.debug('execute');
   		system.debug('scope.size(): ' + scope.size());

		for(Email__c ets : scope) {
			system.debug('ets.template__c  =' + ets.template__c);  
			system.debug('ets.bindfield1__c  =' + ets.bindfield1__c); 
			system.debug('ets.bindfield2__c  =' + ets.bindfield2__c); 
			system.debug('ets.bindfield3__c  =' + ets.bindfield3__c);  
			system.debug('ets.bindfield4__c  =' + ets.bindfield4__c); 
			system.debug('ets.id  =' + ets.id);
			templateid = [Select id from emailtemplate where name = :ets.template__c LIMIT 1].id;
			system.debug('templateid =' + templateid);
	        String[] listContactsList = ets.recipientemails__c.split('[,]');
			system.debug('string value of list:' + listContactsList);
			// Pick a dummy Contact
			Contact c = [select id, Email from Contact where email <> null limit 1];

			for (String thisContact : listContactsList) {
				system.debug('sendEmail(thisContact)  =' + thisContact); 				
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTemplateId(templateId);
             	mail.setTargetObjectId(c.id);
             	mail.setWhatId(ets.id);
             	//mail.setToAddresses(new String[] { thisContact });
             	mailList.add(mail);     	

				Savepoint sp = Database.setSavepoint();
            	Messaging.SendEmail(mailList); // body is rendered here 
            	Database.rollback(sp);
        		system.debug('after savepoint mailList =' + mailList);

        		for (Messaging.SingleEmailMessage email : mailList) {
		        	ets.Body__c = email.getHTMLBody();
		        	ets.Subject__c = email.getSubject();
		        	ets.HasBody__c = 'Y';
		        	system.debug('ets.Body__c: ' + ets.Body__c);
		            upsert ets;
		        }
			}
		}
		system.debug('mailList.size=' + mailList.size());
	}
	
	global void finish(Database.BatchableContext BC) {
		if ( Test.isRunningTest() ) {
			//dont do this in test.  we have a separate class for testing emailexecsegbat
			return;
		}

		//Do the HTTP request to send emails and then delete them
		Database.ExecuteBatch(new EmailExecSegBat(), 15);
	}
	
}