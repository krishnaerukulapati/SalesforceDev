global class RemArchLeadsSched implements Schedulable {
	global void execute(SchedulableContext sc) {	
		RemArchLeadsBat b = new RemArchLeadsBat();
		database.executebatch(b, 200);
	}
}