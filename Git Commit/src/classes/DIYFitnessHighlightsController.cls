public with sharing class DIYFitnessHighlightsController {
    public HighlightsViewModel viewModel {get; private set;}
    public Boolean hasError { get { return ApexPages.hasMessages(); } }

    /**
    * @description 
    * @param controller 
    */ 
    public DIYFitnessHighlightsController(ApexPages.StandardController controller) {
        viewModel = new HighlightsViewModel();

        viewModel.Lead = ECCUtil.getCurrLead(System.currentPageReference().getParameters().get('id')).SSLead;
        viewModel.OrganizerIdToLoad = null;
        viewModel.CoordinatorIdToLoad = null;
        system.debug('leadid: ' + viewModel.Lead.id); 
    }

    //initialize
    public Continuation reload(){
        Long startMs = DateTime.now().getTime();

        viewModel.Opportunity = ECCEventHelper.GetDIYOppFromLead(viewModel.Lead.Id, viewModel.Opportunity);
        system.debug('viewModel.Opportunity: ' + viewModel.Opportunity); 

        viewModel.IsCoordParticipant = String.ValueOf(viewModel.Lead.CurrentCampaign__r.CoordinatorIsparticipant__c);
        viewModel.IsAutoSendKit = String.ValueOf(viewModel.Lead.CurrentCampaign__r.AutoSendKit__c);
        system.debug('IsAutoSendKit: ' + viewModel.IsAutoSendKit);  

        //events
        viewModel.EventHighLights = ECCEventHelper.GetHighlightByLeadId(String.ValueOf(viewModel.Lead.Id), viewModel.Opportunity);
        system.debug('viewModel.EventHighLights: ' + viewModel.EventHighLights); 

        if (viewModel.EventHighLights != null)
        {
            viewModel.TrEventid = viewModel.EventHighLights.TeamRaiserId__c;
            viewModel.TrChallengeLink = getFitnessApplicationURL();

            if (viewModel.EventHighLights.StartDate__c != null)
                viewModel.EventDate = String.valueOf(viewModel.EventHighLights.StartDate__c.dateGMT());

            //viewModel.EventDate = string.valueOf(viewModel.EventHighLights.StartDate__c.month()) + '/' + string.valueOf(viewModel.EventHighLights.StartDate__c.day()) + '/' + string.valueOf(viewModel.EventHighLights.StartDate__c.year());

           //get opportunity's current campaign
            //Opportunity opp = [select Id, CampaignId,LastModifiedDate,StageName from Opportunity where id = :viewModel.Opportunity.Id AND (Stagename!='Completed' AND Stagename!='Cancelled') Order By LastModifiedDate DESC LIMIT 1];
            Opportunity opp = [select Id, CampaignId,LastModifiedDate,StageName from Opportunity where id = :viewModel.Opportunity.Id Order By LastModifiedDate DESC LIMIT 1];
            if(opp != null) {
                if(opp.CampaignId != null) {
                    Campaign camp = [select Id, Name,LastModifiedDate from Campaign where Id = :opp.CampaignId Order BY LastModifiedDate DESC LIMIT 1];
                    if(camp != null) {
                        viewModel.CampaignName = camp.Name;
                        viewModel.CampaignId = camp.Id;
                    }   
                }               
            }                   
        }

        //CONMG-1409 - Load constituent from event if one exists, otherwise, use lead's information
        viewModel.OrganizerIdToLoad = viewModel.EventHighlights != null && viewModel.EventHighlights.OrganizerId__c != null 
                                    ? viewModel.EventHighlights.OrganizerId__c
                                    : viewModel.Lead.ConstituentID__c;

        viewModel.CoordinatorIdToLoad = viewModel.EventHighlights != null && viewModel.EventHighlights.CoordinatorId__c != null 
                                    ? viewModel.EventHighlights.CoordinatorId__c
                                    : viewModel.Lead.CoordinatorID__c;


        system.debug('viewModel.OrganizerIdToLoad=' + viewModel.OrganizerIdToLoad);
        system.debug('viewModel.CoordinatorIdToLoad=' + viewModel.CoordinatorIdToLoad);
        Continuation continuation = new Continuation(viewModel.TIMEOUT_INT_SECS);
        continuation.continuationMethod = 'gotConstituent';

        if (viewModel.OrganizerIdToLoad != null)
        {
            viewModel.OrganizerResponse = AsyncC360Util.getConstituent(continuation, 
                                                        null, 
                                                        viewModel.OrganizerIdToLoad,
                                                        null,
                                                        'DMS',
                                                        new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'}, 
                                                        'ALL');
        }

        if (viewModel.CoordinatorIdToLoad != null)
        {
            viewModel.CoordinatorResponse = AsyncC360Util.getConstituent(continuation, 
                                                        null, 
                                                        viewModel.CoordinatorIdToLoad, 
                                                        new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES'}, 
                                                        'ALL');
        }

        //output
        system.debug('lead=' + viewModel.Lead);
        Long endMs = DateTime.now().getTime();
        system.debug('================== Reload() RUNTIME ================== ' + (endMs - startMs) + ' ms');
        return continuation;
    }

    public Object gotConstituent() {
        system.debug('gotConstituent: ' + Datetime.now());  

        try {
            if (viewModel.OrganizerIdToLoad != null && viewModel.OrganizerResponse != null) {
                viewModel.Organizer = viewModel.OrganizerResponse.getValue().Constituent;

                if (viewModel.Organizer.Transactions != null){
                viewModel.HasRevNotes = viewModel.Organizer.Transactions.size() > 0;
                }

                if (viewModel.Organizer.Profile != null && viewModel.Organizer.Profile.FinancialProfile != null) {
                    viewModel.FinancialProfile = viewModel.Organizer.Profile.FinancialProfile;
                }
                
                viewModel.OrganizerName = ECCEventHelper.GetConstituentName(viewModel.Organizer);
                viewModel.OrganizerEmail = ECCEventHelper.GetConstituentEmail(viewModel.Organizer);
                viewModel.OrganizerPhone = ECCEventHelper.GetConstituentPhone(viewModel.Organizer);
                viewModel.IsOrganizerVIP = viewModel.OrganizerResponse.getValue().VIP;  //ECCEventHelper.IsVIP(viewModel.Organizer);  
                viewModel.IsOrganizerLoaded = true;
                system.debug('IsOrganizerVIP = ' + viewModel.IsOrganizerVIP);

                system.debug('Organizer is = ' + viewModel.Organizer);
                //system.debug('viewModel.CoordinatorResponse.getValue().Constituent = ' + viewModel.CoordinatorResponse.getValue().Constituent);
            }

            
            system.debug('viewModel.CoordinatorIdToLoad = ' + viewModel.CoordinatorIdToLoad);
            system.debug('viewModel.CoordinatorResponse = ' + viewModel.CoordinatorResponse);
            if (viewModel.CoordinatorIdToLoad != null && viewModel.CoordinatorResponse != null) {
                system.debug('we are in the thing');
                viewModel.Coordinator = viewModel.CoordinatorResponse.getValue().Constituent;
                system.debug('we are after the constituent');
                viewModel.CoordinatorName = ECCEventHelper.GetConstituentName(viewModel.Coordinator);
                viewModel.CoordinatorEmail = ECCEventHelper.GetConstituentEmail(viewModel.Coordinator);
                viewModel.CoordinatorPhone = ECCEventHelper.GetConstituentPhone(viewModel.Coordinator);  
                viewModel.IsCoordinatorVIP = viewModel.CoordinatorResponse.getValue().VIP;
                viewModel.IsCoordinatorLoaded = true;
                system.debug('Coordinator is = ' + viewModel.Coordinator);
            }
        }
        catch(Exception ex) {
            //something went wrong, show the exception
            system.debug('error message: ' + ex.getMessage());
            system.debug('stack trace: ' + ex.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'C360 failed to return a constituent.  Your organization has been notified of this error.  Please reload the page in a few minutes.'));
            return null;
        }
        return null;
    }

    public string getCoodinatorAddress() {
        String retval = ECCEventHelper.GetDisplayAddress(viewModel.Coordinator);
        system.debug('getCoodinatorAddress= ' + retval);
        return retval;
    } 
    //newcode: display mailing address
    public string getMailingAddress() {
        String retval = ECCEventHelper.GetDisplayMailingAddress(viewModel.Opportunity);
        system.debug('@@@:getMailingAddress= ' + retval);
        return retval;
    }
    public string getOrganizerAddress() {
        String retval = ECCEventHelper.GetDisplayAddress(viewModel.Organizer);
        system.debug('getOrganizerAddress= ' + retval);
        return retval;
    } 

    public string getTotalRevenue(){
        if (viewModel.EventHighLights != null) {
            EventRevenues__x evtRev = OdataExtension.GetEventRevenueById(viewModel.EventHighLights.EventID__c);
            if (evtRev != null && evtRev.Amount__c != null)
                return '$' + String.ValueOf(evtRev.Amount__c.setScale(2));
        }

        return '$0.00';
    }


    public void assignOppStage() { 
        String prevStage = viewModel.Opportunity.StageName;
        system.debug('Previous Stage == '+prevStage);
        viewModel.Opportunity.StageName = genNextOppStage(viewModel.Opportunity.StageName);
        system.debug('Next stage =='+viewModel.Opportunity.StageName);
        viewModel.Opportunity.StageChanged__c = DateTime.now();
        viewModel.Opportunity.Probability = viewModel.OppProbs.get(viewModel.Opportunity.StageName);
        system.debug('Opportunity Stage % is =' + viewModel.Opportunity.Probability);
        update viewModel.Opportunity;
        Task t = new Task(
            WhoId = viewModel.Lead.Id,
            Subject = viewModel.Lead.Name + ' - ' + viewModel.Opportunity.StageName,
            BeforeValues__c = prevStage,
            AfterValues__c = viewModel.Opportunity.StageName,
            ConstituentId__c = viewModel.OrganizerIdToLoad,
            Status = 'Completed'
            );
        insert t;
        ECCEventHelper.RemoveFromCampaign(viewModel.Lead.Id);
    }

    public string getBbecURL() {
        return BbecSettings__c.getInstance('Master').BbecURL__c;
    }

    public string getNonce() {
        return ECCUtil.getToken('this is the events nonce key and the events nonce key is this');
    }

    public string getChallengeRecruitURL() {
        return CustomSettings__c.getValues('EventsRecruitment').Value__c;
    }

    public string getFitnessApplicationURL() {
        String retURL = CustomSettings__c.getValues('FundRaiserLink').Value__c;
        retURL += 'site/TR/Events/Events?pg=entry&fr_id=' + viewModel.TrEventid;
        return retURL;
    }   

    /// Private Functions
    @TestVisible
    private String genNextOppStage(String stage){
        if (!stage.endsWith('Complete')) 
            stage = stage + ' Complete';

        system.debug('got next opp stage, new: ' + stage +  ' - ' + Datetime.now());
        return stage;
    } 

  public Class HighlightsViewModel{
    public HighlightsViewModel(){
        IsOrganizerLoaded = false;
        IsCoordinatorLoaded = false;
        IsOrganizerVIP = false;

    
    List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage];
        OppProbs = new Map<String, Double>();
        for(OpportunityStage os : oppStages) {
            OppProbs.put(os.MasterLabel, os.DefaultProbability);
            //system.debug('oppProbs for loop =='+oppProbs);
        }
    }
    //salesforce objects
    public Opportunity Opportunity {get; private set;}
    public Lead Lead {get; private set;}

    //internal
    public String IsCoordParticipant {get; set;}
    public String IsAutoSendKit {get; set;}
    public String TrEventid {get; set;}
    public String TrChallengeLink { get; set; }
    public Map<String, Double> OppProbs = new Map<String, Double>();
    
    public boolean HasRevNotes {get; set;}
    
    //organizer 
    public domainSoapStjudeOrg.Constituent Organizer {get; private Set;}
    public String OrganizerIdToLoad { get; private set;}
    public String OrganizerName  {get; private Set;}
    public String OrganizerPhone {get; private set;}
    public String OrganizerEmail {get; private set;}
    public boolean IsOrganizerLoaded { get; private set; }
    public boolean IsOrganizerVIP {get; private Set;}
    public domainSoapStjudeOrg.FinancialProfile FinancialProfile {get; private set;}

    //coordinator
    public domainSoapStjudeOrg.Constituent Coordinator {get; private Set;}
    public String CoordinatorIdToLoad { get; private set;}
    public String CoordinatorName  {get; private Set;}
    public String CoordinatorPhone {get; private set;}
    public String CoordinatorEmail {get; private set;}
    public boolean IsCoordinatorVIP { get; private set; }
    public boolean IsCoordinatorLoaded { get; private set; }

    //event
    public EventHighlights__x EventHighLights {get; set;}
    public String EventDate {get;set;}
    AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture OrganizerResponse;
    AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture CoordinatorResponse;
    Integer TIMEOUT_INT_SECS = 60;
    public string CampaignId {get; set;}
    public string CampaignName {get;set;}
  }
}