trigger UpsertCampaignMember on Lead (after insert, after update) {
    Map<String, List<Lead>> cIdLead = new Map<String, List<Lead>>();

    //get the leads by campaign
    for(Lead l : Trigger.new) {
        if(String.isNotBlank(l.CurrentCampaign__c)) {
            if (cIdLead.containsKey(l.CurrentCampaign__c)) {
                ((List<Lead>)cIdLead.get(l.CurrentCampaign__c)).add(l);
            }
            else {
                cIdLead.put(l.CurrentCampaign__c, new Lead[] {l});
            }
        }
    }

    List<CampaignMember> cmsNew = new List<CampaignMember>();
    //for each distinct campaign
    for(string campId : cIdLead.keySet()) {
        //get the leads, and associated campaign members if the exist
        List<Lead> thisCamp = cIdLead.get(campId);
        List<CampaignMember> cmsExist = [select id, LeadId from CampaignMember where CampaignId = :campId and LeadId in :thisCamp ];


        for(Lead l : thisCamp) {
            boolean foundCM = false;
            for(CampaignMember cm : cmsExist) {
                if (cm.LeadId == l.Id) {
                    //perform update if we want to
                    foundCM = true;
                    break;
                }
            }

            if (!foundCM) {
                cmsNew.add(new CampaignMember(CampaignId=l.CurrentCampaign__c, LeadId=l.Id));
            }
        }
    }

    upsert cmsNew;
}