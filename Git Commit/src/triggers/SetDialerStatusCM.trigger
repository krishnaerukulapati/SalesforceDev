trigger SetDialerStatusCM on CampaignMember (after insert) {
    Map<String, List<String>> leadToCIds = new Map<String, List<String>>(); //LeadId to Campaign ids map
    List<Lead> leadsToUpdate = new List<Lead>();
    String readyStatus = 'Ready';
    List<Opportunity> opps = new List<Opportunity>();
    Boolean isActive = false;
    
    for(CampaignMember cm : Trigger.new) {//for all of the campaign members
        if(String.isNotBlank(cm.LeadId)) { //if the campaign member has a lead

            Campaign camp = [select id, name, parentId from Campaign where id = :cm.CampaignId];

            //check that an active Opp exists on the lead for the campaign member's campaign
            opps = [
                select id
                    , name
                    , Event_Organizer__c
                    , CampaignId 
                from Opportunity 
                where Event_Organizer__c = :cm.LeadId 
                and CampaignId = :camp.parentId
                and (Stagename != 'Completed' and Stagename != 'Cancelled' and Stagename != 'System Cancelled' and Stagename != 'Cancelled Complete')
                order by CreatedDate limit 1];

            //if active Opp exists, set to active
            if(opps.size() > 0) {
                isActive = true;
            }

            //add the campaign id of the campaign member to the lead's campaign id list map
            if(isActive) {
                if (leadToCIds.containsKey(cm.LeadId)) { 
                    leadToCIds.get(cm.LeadId).add(cm.CampaignId);
                }
                else {
                    leadToCIds.put(cm.LeadId, new String[] { cm.CampaignId });
                }
            }            
        }
    }
    
    //Get all the impacted leads
   List<Lead> leads = [select id, CurrentCampaign__c, DialerStatus__c,Event_Status__c,Phone from Lead where id in :leadToCIds.keySet()];
    for(Lead lead : leads) { //for all of the leads
        if (lead.DialerStatus__c != readyStatus) {
            Boolean setReady = true; //do we need to change the ready status        
            List<String> cIds = leadToCIds.get(lead.id); //get the list of campaign ids
            
            for (String cId : cIds) { 
                //if the lead is being added to it's current campaign, this work has 
                    //already been done and doesn't need to be done again
                if(lead.CurrentCampaign__c == cId) {
                    setReady = false;
                    break;
                }
            }
            
            if (setReady) { //if we need to set the dialer status
                //if we get here, the trigger will modify that action, set trigger last modified date
                lead.Trigger_Modified_Date__c = System.now();
                lead.Phone = ECCEventHelper.RemoveNonNumericData(lead.Phone);
                if(lead.DialerStatus__c != 'CheckedOut') {
                    lead.DialerStatus__c = Validation.IsValidPhoneNumber(lead.Phone) ? 'Ready' : 'Bad Phone';
                }
                leadsToUpdate.add(lead);
            }
        }
    }
    
    update leadsToUpdate;
}