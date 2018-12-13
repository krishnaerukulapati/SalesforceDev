trigger CreateTasks on ALSACEvent__c (after insert, after update) {

	static final String fromEmail = 'ALSACTaskCreation@stjude.org';
	static final String fromName = 'ALSACTaskCreation@stjude.org';

	for (ALSACEvent__c ae : System.Trigger.new) {
		system.debug('Entered trigger');
		//Create tasks, opps, campaigns on ALSAC Event insert or update of LeadStaff
		if(!Test.isRunningTest()){
			if(Trigger.isUpdate){
				ALSACEvent__c oldE = Trigger.oldMap.get(ae.Id);
				if (ae.LeadStaff__c != oldE.LeadStaff__c)
				{
					system.debug('Triggered by updated Lead Staff');
					CreateEventTasksBat b = new CreateEventTasksBat();
					database.executebatch(b,1);
				}
			}
			else{
				if (ae.LeadStaff__c == null) {
					system.debug('Null lead staff, sending email');
					String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
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
					mail.setSubject('Event Missing Lead Staff');
					mail.setPlainTextBody('An event was created from EventMaster where the selected lead staff did not match to a Salesforce user. Please match manually: ' + sfdcBaseURL + '/' + ae.Id + '/e');
					Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
				}
				else {
					system.debug('Triggered by event insert with lead staff populated');
					CreateEventTasksBat b = new CreateEventTasksBat();
					database.executebatch(b,1);
				}
			}			
		}			
	}	
}