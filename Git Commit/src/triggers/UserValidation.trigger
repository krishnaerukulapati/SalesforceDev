trigger UserValidation on User (before insert, before update) {
	for(User u:trigger.new) {
		if(u.CallCenterId != null && u.InContactAgentId__c == null){
			u.IncontactAgentId__c.addError('User must have AgentId when assigned Call Center');	
		}
	}
}