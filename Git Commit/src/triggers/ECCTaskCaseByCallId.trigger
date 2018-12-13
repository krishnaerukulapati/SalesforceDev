trigger ECCTaskCaseByCallId on Task (before insert) {
	List<string> callObjects = new List<string>();

	//get the call object for this task
	for(Task tsk : trigger.new) {
		if (String.isNotEmpty(tsk.CallObject)) {
			callObjects.add(tsk.CallObject);
		}
	}

	system.debug('num calls: ' + callObjects.size());
	//get cases for the call objects
	List<Case> cases = [
		select 
			id,
			CallObject__c
		from 
			Case 
		where
			CallObject__c in :callObjects ];

	//associate the case to the task
	for(Case c : cases) {
		for(Task tsk : trigger.new) {
			if (tsk.CallObject == c.CallObject__c) {
				tsk.WhatId = c.Id;
				system.debug(tsk.WhatId + ' = ' + c.Id);
				break;
			}
		}
	}
}