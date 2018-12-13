public without sharing class ReportUtil{
    public static List<DialerStatusModel> GetDialerStatusReportData()
    {
        List<DialerStatusModel> retList = new List<DialerStatusModel>();
        List<Campaign> cList = ECCUtil.GetCampaignsInProgressAndPlanned();

        for(Campaign c : cList)
        {   
            DialerStatusModel model = new DialerStatusModel(c.Id);

            if (model.TotalCount > 0)
            {
                model.CurrentCampaignId = c.Id;
                system.debug('campaignId' + model.CurrentCampaignId);
                retList.Add(model);
            }
        }

        return retList;
    }


  public Class DialerStatusModel{
        public DialerStatusModel(String campaignId)
        {
            Campaign c = ECCUtil.GetCampaignById(campaignId);
            ReadyCount = 0;
            NotReadyCount = 0;
            BadPhoneCount = 0;
            FailCount = 0;
            CheckedInCount = 0;
            CheckedOutCount = 0;

            system.debug('campaign c=' + c);
            CampaignName = c.Name;
            CurrentCampaignId = campaignId;

            List<Lead> cmList = [select Id, DialerStatus__c from Lead where id in (Select LeadId from CampaignMember where CampaignId =: campaignId)];

            TotalCount = cmList.size();
            system.debug('cmList.size()=' + cmList.size());
            //system.debug('cmList=' + cmList);

            if (TotalCount > 0)
            {
                for(Lead l : cmList)
                {
                    if (l.DialerStatus__c == 'Ready')
                    {
                        ReadyCount++;
                    }
                    else if (l.DialerStatus__c == 'Bad Phone' || l.DialerStatus__c == 'BadPhone')
                    {
                        BadPhoneCount++;
                    }
                    else if (l.DialerStatus__c == 'Failed')
                    {
                        FailCount++;
                    }
                    else if (l.DialerStatus__c == 'CheckedIn')
                    {
                        CheckedInCount++;
                    }
                    else if (l.DialerStatus__c == 'CheckedOut')
                    {
                        CheckedOutCount++;
                    }
                    else{
                        NotReadyCount++;
                    }
                }
            }
        }

        public String CampaignName {get; set;}
        public String CurrentCampaignId {get;set;}
        public Integer ReadyCount {get; private set;}
        public Integer NotReadyCount {get; private set;}
        public Integer BadPhoneCount {get; private set;}
        public Integer FailCount {get; private set;}
        public Integer CheckedInCount {get; private set;}
        public Integer CheckedOutCount {get; private set;}
        public Integer TotalCount {get; private set;}
        public String CampaignUrl { 
            get{
                return System.Url.getSalesforceBaseURL().toExternalForm() + '/' + CurrentCampaignId;
            }
        }
    }
}