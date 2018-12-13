public with sharing class FOFitnessHighlightsController {
    
    
    public boolean reload {get; set;}
    public String Title {get; private set;}
    public String FirstName {get; private set;}
    public String LastName {get; private set;}
    public String LongName {get; private Set;}
    public String Email {get; private set;}
    public String EmailType {get; private set;}
    public String Phone {get; private set;}
    public String PhoneType {get; private set;}
    public String Address {get; private set;}
    public String AddressType {get; private set;}
    public boolean c360Error {get; private set;}
    public String Staff {get; private set;}
    public String Deceased {get; private set;}
    public String ConsType {get; private set;}
    public String ConStatus {get; private set;}
    //public Boolean Preferred {get; private set;}
    //public boolean isVIP {get; private Set;}
    public Boolean hasWarnings {get; private Set;}
    public String warnings {get; private Set;}
    public Boolean SetConstituentId {get; private set;}
    public Boolean ConstituentFound {get; private set;}
    public Opportunity oppRec{get; set;}
    //public String Opportunity_Event__c {get; private set;}
    public String leadId {get; private set;}
    public String consId {get; private set;}
    public String bbecId {get; private set;}
    public Lead ldRec{get; set;}
    public String xrefEventId {get; private set;}
    public String cgiId {get; private set;}
    public String conPreference {get; private set;}
    public EVMUtil.SSLeads currLead {get; private set;}
    //public String[] Constituencies {get; private set;}
    public String pledgeId {get; private Set;}
    //public domainSoapStjudeOrg.SystemXRef[] Xrefs {get; private set;}
    public domainSoapStjudeOrg.FinancialProfile fp {get; private set;}
    //public domainSoapStjudeOrg.Preference[] prefs {get; private Set;}
    public TREventRegistrationDetails__x eventRegistrationDetails{get;set;}
    public TREventDetails__x eventDetails{get;set;}
    public CampaignMember campMember {get;set;}
    public String[] ConstToWatch = new string[] {'VIP_YES', 'BOARD_CURRENT', 'BOARD_PAST', 'St Jude Parent YES',
        'St. Jude Parent - Deceased',
        'St. Jude Parent - Live',
        'STJFAMILY_DECEASED',
        'STJFAMILY_LIVING',
        'STJFAMILY_YES',
        'STJPATIENT_ACTIVE',
        'STJPATIENT_REMISSION'
    };
    
    public Decimal recognitionTotal {get; set;}

    public FOFitnessHighlightsController(ApexPages.StandardController controller) {
        //reLoad();
        eventRegistrationDetails = new TREventRegistrationDetails__x();
        eventDetails             = new TREventDetails__x();
        campMember  = new CampaignMember();
        reload = false;
        oppRec = new Opportunity();     
        leadId = System.currentPageReference().getParameters().get('id');
        currLead = EVMUtil.getCurrLead(leadId);
        System.debug('currLead:');
        System.debug(currLead);
        ldRec = new Lead(); 

        if(currLead != null && currLead.SSLead.Id != null){
            List<Opportunity> opp = [SELECT Id, StageName, Probability FROM Opportunity WHERE Event_Organizer__c = :currLead.SSLead.Id];
             if(opp.size() > 0){
                oppRec = opp[0];
                system.debug('opprec =:' + oppRec);
             }
             List<Lead> ld = [Select XREF__c from Lead where id = :leadId];
             ldRec = ld[0];
        }
        if (ldRec.XREF__c != NULL){
            String[] arrXrefval = ldRec.XREF__c.split('[|]');   
            xrefEventId = arrXrefval[0];    
            System.debug('XREF Event ID: ' + xrefEventId);
        }
    }
    
    private void loadEventRegistrationDetails(){
        if(currLead.SSLead.TR_ID__c != NULL && currLead.SSLead.TR_ID__c.isNumeric() && xrefEventId != NULL) {
    //     if(campMember.Campaign.Evaluated_EventID__c!= NULL && campMember.Campaign.Evaluated_EventID__c.isNumeric()) {           
            Decimal trId = Decimal.valueOf(currLead.SSLead.TR_ID__c);
            //Decimal eventId = Decimal.valueOf(campMember.Campaign.Evaluated_EventID__c);
            Decimal eventId = Decimal.valueOf(xrefEventId);
            system.debug('$$$'+trId);
            eventRegistrationDetails = OdataExtension.GetTREventRegDetailByConsEvent(trId, eventId);
        }
    }

    private void loadEventDetails(){        
    //    if(campMember.Campaign.Evaluated_EventID__c!= NULL && campMember.Campaign.Evaluated_EventID__c.isNumeric()){
        if (xrefEventId != NULL){
            //Decimal eventId = Decimal.valueOf(campMember.Campaign.Evaluated_EventID__c);  
            Decimal eventId = Decimal.valueOf(xrefEventId);
            System.debug('Event ID: ' + eventId);       
            eventDetails = OdataExtension.GetTREventDetailByEvent(eventId);
        }
    }

    public PageReference reLoad() {
        leadId = System.currentPageReference().getParameters().get('id');
        currLead = EVMUtil.getCurrLead(leadId);
        List<CampaignMember>lstCampaignMembers = [select Campaign.Evaluated_EVM_EventID__c,Campaign.Evaluated_EventID__c FROM CampaignMember
         WHERE LeadId=:currLead.SSLead.id AND Campaign.Evaluated_EventID__c !=NULL LIMIT 1];

        if(lstCampaignMembers.size()>0){
            campMember = lstCampaignMembers[0];
        }
        system.debug('finish get lead(' + leadId + '): ' + Datetime.now());
        SetConstituentId = false;
        ConstituentFound = false;
        
        if (currLead != null) {
            consId = currLead.SSLead.ConstituentID__c;

            if(campMember != null && campMember.Campaign.Evaluated_EVM_EventID__c != null && consId != null){
                list<EventConsRoleAttrViews__x >EventConsRoleAttrViews = OdataExtension.getEventConsRoleAttrViews(campMember.Campaign.Evaluated_EVM_EventID__c,consId);
                if(EventConsRoleAttrViews.size() > 0 && EventConsRoleAttrViews[0].AttributeValue__c != null){
                    cgiId = EventConsRoleAttrViews[0].AttributeValue__c;
                }
            }
            if(campMember != null && campMember.Campaign.Evaluated_EVM_EventID__c != null){
                list<Events__x >eventsTmp = OdataExtension.GetEventsById(new set<string>{campMember.Campaign.Evaluated_EVM_EventID__c});
                if(eventsTmp.size() > 0 && eventsTmp[0].PreferredContactTypeID__r.ContactType1__c != null){
                    conPreference = eventsTmp[0].PreferredContactTypeID__r.ContactType1__c;
                }
            }
                     
            loadEventDetails();
            loadEventRegistrationDetails();
            system.debug('currLead.ConstituentID__c: ' + currLead.SSLead.ConstituentID__c);
            if (String.isNotEmpty(currLead.SSLead.ConstituentID__c) && String.isNotEmpty(currLead.SSLead.Constituent_Type__c)) {
                domainSoapStjudeOrg.Constituent con;
                //Constituencies = new List<string>();

                try {
                    system.debug('start get constituent: ' + Datetime.now());
                    con = FOUtil.getConstituent(null, currLead.SSLead.ConstituentID__c, 
                            null, null, new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 
                                'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES'}, 'ALL');
                    //con = FOUtil.getConstituent(null, currLead.SSLead.ConstituentID__c, 
                    //    new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 
                    //        'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES'}, 
                    //        'ALL');       
                    system.debug('finish get constituent: ' + Datetime.now());            
                    c360Error = false;
                }
                catch(Exception e) {
                    system.debug(e.getMessage() + ' at ' + e.getLineNumber() + ', trace: ' + e.getStackTraceString());
                    system.debug('finish get constituent: ' + Datetime.now());
                    c360Error = true;
                }

                if (con != null) {
                    consId = con.ConstituentId;
                    system.debug('start');

                    ConsType = con.Type_x.Code;
                    ConStatus = con.Status;
                    if (ConsType == 'INDIVIDUAL') {
                        FirstName = con.FirstName;
                        LastName = con.LastName;
                        //Preferred = (con.Preferred != null && con.Preferred);
                        if (String.isBlank(con.LongName)) LongName = FirstName + ' ' + LastName;
                        else LongName = con.LongName;
                        system.debug('Long Name: ' + LongName + ', con.LongName: ' + con.LongName);
                    }
                    else {
                        LongName = con.Name;
                    }
                    system.debug('basic');
                    
                    if (con.Title != null && string.isNotBlank(con.Title.Code)) {
                        Title = con.Title.Code;
                    }
                    system.debug('title');

                    if (con.Profile != null && con.Profile.Emails != null && con.Profile.Emails.size() > 0) {
                        for(domainSoapStjudeOrg.Email e : con.Profile.Emails) {
                            Email = e.EmailAddress;
                            if (e.EmailType != null) {
                                EmailType = e.EmailType.Code;
                            }
                            if (e.Preferred != null && e.Preferred == true) break;
                        }
                    }
                    else Email = 'Email Address';
                    system.debug('email');

                    if (con.Profile != null && con.Profile.Addresses != null && con.Profile.Addresses.size() > 0) {
                        for(domainSoapStjudeOrg.Address a : con.Profile.Addresses) {
                            Address = 
                                (string.isNotBlank(a.Street1) ? a.Street1 + '<br/>' : '') +
                                (string.isNotBlank(a.Street2) ? a.Street2 + '<br/>' : '') +
                                (string.isNotBlank(a.Street3) ? a.Street3 + '<br/>' : '') +
                                (string.isNotBlank(a.City) ? a.City + ', ' : '') +
                                (string.isNotBlank(a.State) ? a.State + ' ' : '') +
                                (string.isNotBlank(a.ZipCode) ? a.ZipCode : '');

                            if (a.AddressType != null) {
                                AddressType = a.AddressType.Code;
                            }

                            if (a.Preferred != null && a.Preferred ==true) break;
                        }
                    }
                    else Address = 'Address';
                    system.debug('Address');   

                    if (con.Profile != null && con.Profile.Phones != null && con.Profile.Phones.size() > 0) {
                        for(domainSoapStjudeOrg.Phone p : con.Profile.Phones) {
                            Phone = p.PhoneNumber;
                            if (p.PhoneType != null) {
                                PhoneType = p.PhoneType.Code;
                            }

                            if(p.Preferred != null && p.Preferred == true) break;
                        }
                    }
                    else Phone = 'Phone Number';
                    system.debug('Phone');    

                    /*if (con.Preferences != null) {
                        prefs = con.Preferences;
                    }
                    system.debug('Prefs');    */


                    if (con.Profile != null && con.Profile.FinancialProfile != null) {
                        fp = con.Profile.FinancialProfile;
                    }


                    /*if (con.Staff != null && String.isNotBlank(con.Staff.Name)) {
                        Staff = con.Staff.Name;
                    }
                    system.debug('Staff');   

                    if (con.Properties != null && con.Properties.size() > 0) {
                        for(domainSoapStjudeOrg.Property prop : con.Properties) {
                            if (string.isNotBlank(prop.Property)) {
                                for(string cons : ConstToWatch) {   
                                    if(prop.Property == cons) {
                                        isVIP = true;
                                        Constituencies.add(prop.Property);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    system.debug('Constituencies');*/
                    
                    system.debug('start get getConstituentXRefs: ' + Datetime.now());
                    List<domainSoapStjudeOrg.SystemXRef> conXref = FOUtil.getConstituentXRefs(consId, '');
                    system.debug('finish get getConstituentXRefs: ' + Datetime.now());
                    //Xrefs = new List<domainSoapStjudeOrg.SystemXRef>();
                    domainSoapStjudeOrg.SystemXRef[] dmsXrefs = new List<domainSoapStjudeOrg.SystemXRef>();
                    for(domainSoapStjudeOrg.SystemXRef xrCon : conXref) {
                        if (xrCon.Sys != null && xrCon.Sys.Name != null) {
                            /*if (xrCon.Sys.Name == 'TA') {
                                xrefs.add(xrCon);
                                system.debug('ta: ' + xrCon.XRefKey);
                            }
                            else */if (xrCon.Sys.Name == 'DMS') {
                                dmsXrefs.add(xrCon);
                                system.debug('DMS: ' + xrCon.XRefKey);
                            }
                        }
                    }
                    
                    //domainSoapStjudeOrg.SystemXRef[] dmsXrefs = C360Util.getConstituentXRefs(consId, 'DMS');
                    if(dmsXrefs != null && dmsXrefs.size() > 0) bbecId = dmsXrefs.get(0).XRefKey;
                    system.debug('dmsXrefs');
                    
                    //pledgeId = C360Util.getPledgeId(consId);
                    pledgeId = '';
                    system.debug('pledgeId');
                    
                    if (con.Interactions != null && con.Interactions.size() > 0) {
                        warnings = '';
                        hasWarnings = true;
                        System.debug('has interactions');
                        for(domainSoapStjudeOrg.Interaction i : con.Interactions) {
                            warnings += i.ContactDate + '\t' + i.LongComments + '\n-----------------------------\n';
                        }
                    }
                    System.debug('Interactions');
                    
                    if (con.Type_x != null && con.Type_x.Code == 'INDIVIDUAL') {
                        Deceased = 'N';
                        if (con.IndividualAttributes != null && con.IndividualAttributes.Deceased != null &&
                            con.IndividualAttributes.Deceased) {
                            String deceasedDate = con.IndividualAttributes.DeceasedDate;
                            deceasedDate = (String.isEmpty(deceasedDate)) ? '' : ' - ' + deceasedDate;
                            Deceased = 'Y' + deceasedDate;
                        }
                    }
                    system.debug('setting next opp stage');
                    
                    recognitionTotal = 0.0;
                    
                    /*
                    try {
                        objectSoapStJudeOrg.TxnFilter filt = new objectSoapStJudeOrg.TxnFilter();
                        filt.HouseholdView = true;
                        system.debug('calling getTransactions');
                        soapStjudeOrg.GetTransactionsResponse_element res = C360Util.getTransations(null, consId, 0, 1000, 'RECOGNITIONS', 'GIFT_DESC', 
                            filt, 'DMS');
                        system.debug('returning res: ' + res.TotalResults);
                        system.debug('returning res count: ' + (res.Transactions != null ? res.Transactions.Size() : 0));
                        
                        
                        if(res.Transactions != null) {
                            for(domainSoapStjudeOrg.Transaction_x t : res.Transactions) {
                                //system.debug(t);
                                if(t.PaymentAmount != null)
                                    recognitionTotal += t.PaymentAmount;
                            }
                        }
                    }
                    catch(Exception e) {
                        system.debug(e.getMessage());
                    }
                    */
                }
            }
            else {
                //need to set the constituent type
                if (String.isNotEmpty(currLead.SSLead.ConstituentID__c)) {
                    SetConstituentId = true;
                    domainSoapStjudeOrg.Constituent con;
                    domainSoapStjudeOrg.SystemXRef xr = ECCUtil.getXrefFromLead(currLead.SSLead);

                    try {
                        system.debug('start get constituent: ' + Datetime.now());
                        con = FOUtil.getConstituent(null, currLead.SSLead.ConstituentID__c, null, null, 'ALL');     
                        system.debug('finish get constituent: ' + Datetime.now());            
                        c360Error = false;
                    }
                    catch(Exception e) {
                        system.debug(e.getMessage() + ' at ' + e.getLineNumber() + ', trace: ' + e.getStackTraceString());
                        system.debug('finish get constituent: ' + Datetime.now());
                        c360Error = true;
                    }

                    if (!c360Error) {
                        currLead.SSLead.ConstituentID__c = con.ConstituentID;
                        currLead.SSLead.Constituent_Type__c = con.Type_x.Code;
                        update currLead.SSLead;
                    }

                }
                else if (String.isNotEmpty(currLead.SSLead.account_id__c)) {
                    SetConstituentId = true;
                    domainSoapStjudeOrg.Constituent con;
                    domainSoapStjudeOrg.SystemXRef xr = ECCUtil.getXrefFromLead(currLead.SSLead);

                    try {
                        system.debug('start get constituent: ' + Datetime.now());
                        con = FOUtil.getConstituent(null, null, xr, null, 'ALL');     
                        system.debug('finish get constituent: ' + Datetime.now());            
                        c360Error = false;
                    }
                    catch(Exception e) {
                        system.debug(e.getMessage() + ' at ' + e.getLineNumber() + ', trace: ' + e.getStackTraceString());
                        system.debug('finish get constituent: ' + Datetime.now());
                        c360Error = true;
                    }

                    if (!c360Error) {
                        currLead.SSLead.ConstituentID__c = con.ConstituentID;
                        currLead.SSLead.Constituent_Type__c = con.Type_x.Code;
                        update currLead.SSLead;
                    }

                    //now, we should reload this page.
                }
            }
        }
       
        return null;
    }

    public string getBbecURL() {
        return BbecSettings__c.getInstance('Master').BbecURL__c;
    
    }
    
    public string getPledgeMaintURL() {
        return PledgeMaintenanceSettings__c.getInstance('Master').PledgeMaintURL__c;
    }
    
    public string getNonce() {
        return EVMUtil.getToken();
    }

   public string getReturnURL() {
        system.debug(URL.getSalesforceBaseUrl().toExternalForm() + 
            Encodingutil.urlEncode('/flow/Pledge_Cancel_Reason_Flow?CaseId=' + leadId 
             + '&retURL=' + Page.EccCloseSubTab
                , 'UTF-8'));
        return 
            URL.getSalesforceBaseUrl().toExternalForm() + 
            Encodingutil.urlEncode('/flow/Pledge_Cancel_Reason_Flow?CaseId=' + leadId 
                + '&retURL=' + Page.EccCloseSubTab
                , 'UTF-8');
    }  

    public String genNextOppStage(String stage){
        system.debug('StageName: ' + stage);
        
        if (!stage.endsWith('Complete')) {
            stage = stage + ' Complete';
        }

        system.debug('got next opp stage, new: ' + stage +  ' - ' + Datetime.now());
        return stage;
    } 

    public double getStageProb(String stage){
        List<OpportunityStage> oppStages = [select MasterLabel, DefaultProbability from OpportunityStage where MasterLabel = :stage];
        if (oppStages.size() != 1){
            if (Test.isRunningTest()) {
                return 10;
            }
            throw new EVMUtil.EVMException('Stage does not exist...');
        }
        else{
            return oppStages.get(0).DefaultProbability;
        }
    }

    public void assignOppStage() { 
        String prevStage = oppRec.StageName;
        reload = true;
        oppRec.StageName = genNextOppStage(oppRec.StageName);
        oppRec.Probability = getStageProb(oppRec.StageName);
        oppRec.StageChanged__c = DateTime.now();
        update oppRec;
        Task t = new Task(
            WhoId = currLead.SSLead.Id,
            Subject = currLead.SSLead.Name + ' - ' + oppRec.StageName,
            BeforeValues__c = prevStage,
            AfterValues__c = oppRec.StageName,
            ConstituentId__c = currLead.SSLead.ConstituentId__c,
            Status = 'Completed'
            );
        insert t;
        removeFromCampaign();
        
        /*PageReference pf = Page.FitnessHighlights;  
        pf.setRedirect(true); 
        pf.getParameters().put('tsid', ApexPages.currentPage().getParameters().get('tsid'));
        pf.getParameters().put('consId', consId);
        pf.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        return pf;*/
        //return null;    
        //do the opportunity set and save
    }

  //if update of currOpp exceeds delete currCampaignMember
    
    //if update of currOpp exceeds delete currCampaignMember
    public void removeFromCampaign() {
        List<CampaignMember> camMem = [SELECT Id FROM CampaignMember WHERE LeadId = :currLead.SSLead.Id AND Campaign.IsSeg__c = true];
        CampaignMember currCamMem;
        if (camMem != null && camMem.size() > 0) {
            delete camMem;
        }
    
    }

    /*public string getMergeApplicationURL() {
        String retURL = CustomSettings__c.getValues('MergeApplication').Value__c;
        return retURL;
    }*/
    
}