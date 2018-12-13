global class ECCEventsCoreOpportunity {
    global String query;
    global Boolean errorOnInit;
    global Campaign cParent;
    global Account cAccount;
    global RecordType cRecordType;
    global static final String fromEmail = 'josh.hovey@stjude.org';
    global static final String fromName = 'Hovey';
    global String defaultStage = 'Staged';
    Map<String, Double> oppProbs;
    global List<Campaign> segments;
    global Map<String, Integer> segCounts = new Map<String, Integer> ();
    global final String cancelled = '59311144-A18E-4F50-9E74-AE3DD6B4C096';
    global final String systemCancelled = '19DC3506-66F7-48BE-8ADD-5343E3F34EFE';
    
    public void oppData(Opportunity o) {
        //get opportunity campaign
        List<Campaign> oppCampaigns = [select Id, Name, ParentId from Campaign where Id = :o.CampaignId];
        
        //opp has campaign assigned
        if(oppCampaigns.size() == 1) {
            Campaign oppCamp = oppCampaigns.get(0);
        
            //get list of parent campaigns by Id; ideally there would only be 1
            List<Campaign> parents = [select Id, EventId__c, EndDate, OppRecordType__c, OppAcc__r.id, Name from Campaign where Id = :oppCamp.ParentId];
            
            //make sure there's only 1
            if (parents.size() == 1) {
                //get parent from list
                cParent = parents.get(0);
    
                system.debug('found parent campaign');
    
                //get parent's record type
                //List<RecordType> rTypes = [select Id from RecordType where sObjectType = 'Opportunity' and DeveloperName = :cParent.OppRecordType__c];
    
                //make sure there's only 1
                //if (rTypes.size() == 1) {
                    //get parent campaign record type from list
                    //cRecordType = rTypes.get(0);
    
                    //make sure parent has account set
                    if (cParent.OppAcc__c != null) {
    
                        system.debug('found account');
    
                        //get parent campaign account
                        cAccount = cParent.OppAcc__r;
    
                        //get the child campaigns from support parent
                        segments = [
                            select
                            Id, Name, SegName__c, SegFiltRev__c, SegFiltReg__c, SegFiltPart__c,
                            SegStageName__c, SegHrsToWait__c, AllowPreStages__c, SegTeamCaptain__c,
                            SegDaysFromEvent__c, IsSegSendKit__c
                            from
                            Campaign
                            where
                            ParentId = :cParent.Id
                            and IsSeg__c = true
                            order by SegAppOrder__c
                        ];
    
                        system.debug('child campaigns = ' + segments);
                        system.debug('found ' + segments.size() + ' children');
    
                        //get opportunity stage probabilities
                        List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage];
                        oppProbs = new Map<String, Double> ();
    
                        //load stage probabilities for use
                        for (OpportunityStage os : oppStages) {
                            oppProbs.put(os.MasterLabel, os.DefaultProbability);
                        }
    
                        //new query, looks at Opps instead of Leads
                        query = 'select id, name, eventid__c, event_organizer__c, stagename, accountid, revenue__c, stagechanged__c, Recruited_Date__c, recruited_fy__c, recordtypeid, campaignid, support_campaign__c, probability from Opportunity where (CampaignId = \'' + cParent.Id + '\' or Support_Campaign__c = \'' + cParent.Id + '\')';
    
                        system.debug(query);
    
                        //the worst didn't happen
                        errorOnInit = false;
                    }
                    else {
                        //error - malconfigured account
                        //sendErrorEmail('Account not set on parent campaign', parentCampId);
                        
                        system.debug('Account not set on parent campaign');
                    }
                //}
                //else {
                //  //error - missing record type
                //  sendErrorEmail('Missing record type, developer name \'' + cParent.OppRecordType__c + '\' was missing', parentCampId);
                //}
            }
            
        }
        else {
            system.debug('Opp has no Campaign Id');
        }
    }
}