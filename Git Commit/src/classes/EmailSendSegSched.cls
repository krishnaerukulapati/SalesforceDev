global class EmailSendSegSched implements Schedulable {
	global void execute(SchedulableContext sc) {		
 		EmailSendSegBat b = new EmailSendSegBat();
		database.executebatch(b, 10);
	}
}