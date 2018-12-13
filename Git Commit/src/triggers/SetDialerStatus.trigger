trigger SetDialerStatus on Lead (before insert, before update) {
    if (trigger.isInsert) {
        for(Lead l : Trigger.new) {
            if(String.isNotBlank(l.CurrentCampaign__c)) {
                //if we get here, the trigger will modify that action, set trigger last modified date
                l.Trigger_Modified_Date__c = System.now();
                l.Phone = ECCEventHelper.RemoveNonNumericData(l.phone);
                //set dialer status to Ready or Bad Phone depending on the state of the phone number
                if(l.DialerStatus__c != 'CheckedOut' && l.Event_Status__c!='Cancelled') {
                    l.DialerStatus__c = Validation.IsValidPhoneNumber(l.Phone) ? 'Ready' : 'Bad Phone';
                }               
            }
        }
    }
    else {
        for(Lead l : Trigger.new) {
            Lead oldLead = Trigger.oldMap.get(l.Id);

            if(oldLead.CurrentCampaign__c != l.CurrentCampaign__c) {
                //if we get here, the trigger will modify that action, set trigger last modified date
                l.Trigger_Modified_Date__c = System.now();

                l.Phone = ECCEventHelper.RemoveNonNumericData(l.phone);
                //set dialer status to Ready or Bad Phone depending on the state of the phone number
                if(l.DialerStatus__c != 'CheckedOut' && l.Event_Status__c!='Cancelled') {
                    l.DialerStatus__c = Validation.IsValidPhoneNumber(l.Phone) ? 'Ready' : 'Bad Phone';
                }
            }
        }
    }
}