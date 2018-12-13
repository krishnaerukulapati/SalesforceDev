global class AutoArchiveLeadsSched implements Schedulable {
	global void execute(SchedulableContext sc) {
		//Need this to execute until there are no Archiveable Leads left
		//Maybe insert a query that finds Archiveable Leads and runs the flow until List is empty?
		Map<String, Object> params = new Map<String, Object>();
		Flow.Interview.AutoArchiveLeads myFlow = new Flow.Interview.AutoArchiveLeads(params);

		myFlow.start();
	}
}