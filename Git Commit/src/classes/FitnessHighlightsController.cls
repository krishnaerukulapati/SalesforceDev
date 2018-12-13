public with sharing class FitnessHighlightsController {
    public HighlightsViewModel viewModel {get; private set;}
    
    public FitnessHighlightsController(ApexPages.StandardController controller){
        System.debug('in constructor');
        viewModel = new HighlightsViewModel(); 
        viewModel.Lead = ECCUtil.getCurrLead(System.currentPageReference().getParameters().get('id')).SSLead;

        //CONMG-1458
        viewModel.AgentId = ECCUtil.GetAgentIdByUserId(UserInfo.getUserId());
        viewModel.CallObject = ECCUtil.GetCallObjectByLeadId(viewModel.Lead.Id);

        //CONVIO refactor 
        viewModel.currLead = ECCUtil.getCurrLead(viewModel.Lead.Id);
        getxrefEventId();
        getCampMemberInfo(viewModel.currLead);
        viewModel.trHeroesLink = getFundRaiserApplicationURL();
        viewModel.bbecURL = getBbecURL();
        System.debug('about to loadEventDetails');
        loadEventDetails();
        System.debug('about to loadEventRegDetails');
        loadEventRegistrationDetails();
    }

    //initialize
    public Continuation reload(){
        System.debug('in reload');
        Long startMs = Datetime.now().getTime();

        viewModel.Opportunity = ECCEventHelper.GetDIYOppFromLead(viewModel.Lead.Id, viewModel.Opportunity);
        Continuation continuation = new Continuation(viewModel.TIMEOUT_INT_SECS);
        continuation.continuationMethod = 'gotConstituent';
        System.debug('about to getConstituent');
        System.debug('viewModel.Lead.ConstituentID__c = ' + viewModel.Lead.ConstituentID__c);
        if (viewModel.Lead.ConstituentID__c != null)
            viewModel.OrganizerResponse = AsyncC360Util.getConstituent(continuation, 
                                                        null, 
                                                        viewModel.Lead.ConstituentID__c,
                                                        null,
                                                        'DMS', 
                                                        new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'}, 
                                                        'ALL');
        System.debug('sent the request');
        //output
        system.debug('lead=' + viewModel.Lead);
        Long endMs = DateTime.now().getTime();
        system.debug('================== Reload() RUNTIME ================== ' + (endMs - startMs) + ' ms');
        return continuation;
    }

    public Object gotConstituent() {
        System.debug('gotConstituent: ' + Datetime.now());
        System.debug('viewModel.Lead.ConstituentID__c = ' + viewModel.Lead.ConstituentID__c);

        if (viewModel.Lead.ConstituentID__c != null && viewModel.OrganizerResponse != null) {
            viewModel.Organizer = viewModel.OrganizerResponse.getValue().Constituent;
            System.debug('constituent = ' + viewModel.Organizer);
            
            if (viewModel.Organizer.Transactions != null){
                viewModel.HasRevNotes = viewModel.Organizer.Transactions.size() > 0;
            }

            if (viewModel.Organizer.Profile != null && viewModel.Organizer.Profile.FinancialProfile != null) {
                viewModel.FinancialProfile = viewModel.Organizer.Profile.FinancialProfile;
            }
            
            viewModel.OrganizerName = ECCEventHelper.GetConstituentName(viewModel.Organizer);
            viewModel.OrganizerEmail = ECCEventHelper.GetConstituentEmail(viewModel.Organizer);
            viewModel.OrganizerPhone = ECCEventHelper.GetConstituentPhone(viewModel.Organizer);  
            viewModel.IsOrganizerLoaded = true;
            system.debug('Organizer is = ' + viewModel.Organizer);

        }

        return null;
    }

    public string getOrganizerAddress() {
        String retval = ECCEventHelper.GetDisplayAddress(viewModel.Organizer);
        system.debug('getOrganizerAddress= ' + retval);
        return retval;
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
            ConstituentId__c = viewModel.Lead.ConstituentId__c,
            Status = 'Completed'
            );
        insert t;
        ECCEventHelper.RemoveFromCampaign(viewModel.Lead.Id);
    }

   public string getReturnURL() {
        system.debug(URL.getSalesforceBaseUrl().toExternalForm() + Encodingutil.urlEncode('/flow/Pledge_Cancel_Reason_Flow?CaseId=' + viewModel.Lead.Id + '&retURL=' + Page.EccCloseSubTab, 'UTF-8'));
        return URL.getSalesforceBaseUrl().toExternalForm() + Encodingutil.urlEncode('/flow/Pledge_Cancel_Reason_Flow?CaseId=' + viewModel.Lead.Id + '&retURL=' + Page.EccCloseSubTab, 'UTF-8');
    }  

    //////////////////////////////////////
    //This is for ODATA CONVIO calls - refactor once CONVIO is in EVTSQL
    private void getxrefEventId(){
        System.debug('inside getxrefEventId');
        if(viewModel.currLead != null && viewModel.currLead.SSLead.Id != null){
            List<Opportunity> opp = [SELECT Id, StageName, Probability FROM Opportunity WHERE Event_Organizer__c = :viewModel.currLead.SSLead.Id];
             if(opp.size() > 0){
                viewModel.Opportunity = opp[0];
                system.debug('viewModel.Opportunity =:' + viewModel.Opportunity);
             }
             List<Lead> ld = [Select XREF__c from Lead where id = :viewModel.currLead.SSLead.Id];
             viewModel.ldRec = ld[0];
        }
        if (viewModel.ldRec.XREF__c != NULL){
            String[] arrXrefval = viewModel.ldRec.XREF__c.split('[|]');   
            viewModel.xrefEventId = arrXrefval[0];    
        }
    }

    private void getCampMemberInfo(ECCUtil.SSLeads currLead){
        System.debug('inside getCampMemberInfo');
        List<CampaignMember>lstCampaignMembers = [select Campaign.Evaluated_EVM_EventID__c,Campaign.Evaluated_EventID__c FROM CampaignMember
         WHERE LeadId=:currLead.SSLead.id AND Campaign.Evaluated_EventID__c !=NULL LIMIT 1];
        System.debug('lstCampaignMembers = ' + lstCampaignMembers);

        if(lstCampaignMembers.size()>0){
            viewModel.campMember = lstCampaignMembers[0];
        }
        System.debug('viewModel.campMember = ' + viewModel.campMember);
        System.debug('viewModel.campMember.Campaign.Evaluated_EVM_EventID__c = ' + viewModel.campMember.Campaign.Evaluated_EVM_EventID__c);
        System.debug('viewModel.Lead.ConstituentId__c = ' + viewModel.Lead.ConstituentId__c);
        if(viewModel.campMember != null && viewModel.campMember.Campaign.Evaluated_EVM_EventID__c != null && viewModel.Lead.ConstituentId__c != null){
                list<EventConsRoleAttrViews__x >EventConsRoleAttrViews = OdataExtension.getEventConsRoleAttrViews(viewModel.campMember.Campaign.Evaluated_EVM_EventID__c,
                     viewModel.Lead.ConstituentId__c);
                if(EventConsRoleAttrViews.size() > 0 && EventConsRoleAttrViews[0].AttributeValue__c != null){
                    viewModel.cgiId = EventConsRoleAttrViews[0].AttributeValue__c;
                }
            }
        if(viewModel.campMember != null && viewModel.campMember.Campaign.Evaluated_EVM_EventID__c != null){
            list<Events__x >eventsTmp = OdataExtension.GetEventsById(new set<string>{viewModel.campMember.Campaign.Evaluated_EVM_EventID__c});
            if(eventsTmp.size() > 0 && eventsTmp[0].PreferredContactTypeID__r.ContactType1__c != null){
                viewModel.conPreference = eventsTmp[0].PreferredContactTypeID__r.ContactType1__c;
            }
        }
    }

    private void loadEventRegistrationDetails(){
        System.debug('viewModel.currLead.SSLead.TR_ID__c : ' + viewModel.currLead.SSLead.TR_ID__c);
        System.debug('viewModel.xrefEventId = ' + viewModel.xrefEventId);
        if(viewModel.currLead.SSLead.TR_ID__c != NULL && viewModel.currLead.SSLead.TR_ID__c.isNumeric() && viewModel.xrefEventId != NULL) {     
            Decimal trId = Decimal.valueOf(viewModel.currLead.SSLead.TR_ID__c);
            Decimal eventId = Decimal.valueOf(viewModel.xrefEventId);
            system.debug('$$$'+trId);
            viewModel.eventRegistrationDetails = OdataExtension.GetTREventRegDetailByConsEvent(trId, eventId);
            System.debug('viewModel.eventRegristrationDetails = ' + viewModel.eventRegistrationDetails);
        }
    }

    private void loadEventDetails(){
        if (viewModel.xrefEventId != NULL){
            Decimal eventId = Decimal.valueOf(viewModel.xrefEventId);       
            viewModel.eventDetails = OdataExtension.GetTREventDetailByEvent(eventId);
            System.debug('viewModel.eventDetails = ' + viewModel.eventDetails);
        }
    }

    public string getFundRaiserApplicationURL() {
        System.debug('inside getFundRaiserApplicationURL');
        System.debug('viewModel.currLead.SSLead.TR_ID__c = ' + viewModel.currLead.SSLead.TR_ID__c );
        String retURL = CustomSettings__c.getValues('FundRaiserLink').Value__c;
        retURL += 'site/TR/Heroes/Heroes?px=' + viewModel.currLead.SSLead.TR_ID__c + '&pg=personal&fr_id=' + viewModel.xrefEventId;
        System.debug('retURL FundRaiserLink = ' + retURL);
        return retURL;
    }  
    //END of CONVIO stuff
    //////////////////////////////////////

    /// Private Functions
    //CONMG-1458
    public string getNonce() {
        return ECCUtil.getToken();
    }

    public string getPledgeMaintURL() {
        return PledgeMaintenanceSettings__c.getInstance('Master').PledgeMaintURL__c;
    }

    public string getBbecURL() {
        return BbecSettings__c.getInstance('Master').BbecURL__c;
    }

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
        }

    //salesforce objects
    public Opportunity Opportunity {get; private set;}
    public Lead Lead {get; private set;}
    //CONMG-1458
    public String AgentId {get; private set;}
    public String CallObject {get; private set;}

    //internal
    //public String IsCoordParticipant {get; set;}
    public String IsAutoSendKit {get; set;}
    public String TrEventid {get; set;}
    public String TrChallengeLink { get; set; }
    public Map<String, Double> OppProbs = new Map<String, Double>();
    //public boolean c360Error {get; private set;}
    public boolean HasRevNotes {get; set;}
    
    //organizer 
    public domainSoapStjudeOrg.Constituent Organizer {get; private Set;}
    public String OrganizerName  {get; private Set;}
    public String OrganizerPhone {get; private set;}
    public String OrganizerEmail {get; private set;}
    public boolean IsOrganizerLoaded { get; private set; }
    public domainSoapStjudeOrg.FinancialProfile FinancialProfile {get; private set;}

    //event
    public EventHighlights__x EventHighLights {get; set;}
    AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture OrganizerResponse;
    Integer TIMEOUT_INT_SECS = 60;

    //CONVIO data from ODS (Consider refactoring)
    public Lead ldRec{get; set;}
    public ECCUtil.SSLeads currLead {get; private set;}
    public String trHeroesLink {get; set;}
    public String xrefEventId {get; private set;}
    public CampaignMember campMember {get; private set;}
    public String cgiId {get; private set;}
    public String conPreference {get; private set;}
    public TREventRegistrationDetails__x eventRegistrationDetails{get;set;}
    public TREventDetails__x eventDetails{get;set;}
    public String bbecURL {get; set;}
  }

}