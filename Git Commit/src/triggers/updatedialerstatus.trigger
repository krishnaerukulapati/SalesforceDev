trigger updatedialerstatus on LeadSkill__c (before insert, before update) {

  if (trigger.isInsert) {
        for(LeadSkill__c ls : Trigger.new) {
            if(String.isNotBlank(ls.Campaign__c)) {
                ls.Trigger_modified_time_date__c = System.now();
                if(ls.Dialerstatus__c != 'Checked Out') {
                    ls.Dialerstatus__c = 'Ready';
                }               
            }
        }
    }

}