global class RemEmailsSentSched implements Schedulable {
	global void execute(SchedulableContext sc) {	
		RemEmailsSentBat b = new RemEmailsSentBat();
		database.executebatch(b, 1000);
	}
}