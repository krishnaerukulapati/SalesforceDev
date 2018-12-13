public with sharing class SSHighlightsController {
    /*public String Title {get; private set;}
    public String FirstName {get; private set;}
    public String LastName {get; private set;}
    public String LongName {get; private Set;}
    public String Email {get; private set;}
    public String EmailType {get; private set;}
    public String Phone {get; private set;}
    public String PhoneType {get; private set;}
    public String Address {get; private set;}
    public String AddressType {get; private set;}*/
    public boolean c360Error {get; private set;}
    public String Staff {get; private set;}
    public String Deceased {get; private set;}
    public String ConsType {get; private set;}
    public String ConStatus {get; private set;}
    public Boolean Preferred {get; private set;}
    public boolean isVIP {get; private Set;}
    public Boolean hasWarnings {get; private Set;}
    public String warnings {get; private Set;}
    public Boolean SetConstituentId {get; private set;}
    public Boolean ConstituentFound {get; private set;}

    public String leadId {get; private set;}
    public String consId {get; private set;}
    public String bbecId {get; private set;}
    public String AgentId {get; private set;}
    
    public boolean isConsLoaded { get; private set; }
     public String taAccount {get; private set;}

    public String ContactId {get; private set;}
    
    public ECCUtil.SSLeads currLead {get; private set;}
    public String[] Constituencies {get; private set;}
    public String pledgeId {get; private Set;}
    public domainSoapStjudeOrg.SystemXRef[] Xrefs {get; private set;}
    public domainSoapStjudeOrg.FinancialProfile fp {get; private set;}
    public domainSoapStjudeOrg.Preference[] prefs {get; private Set;}
    public String[] ConstToWatch = new string[] {'VIP_YES', 'BOARD_CURRENT', 'BOARD_PAST', 'St Jude Parent YES',
        'St. Jude Parent - Deceased',
        'St. Jude Parent - Live',
        'STJFAMILY_DECEASED',
        'STJFAMILY_LIVING',
        'STJFAMILY_YES',
        'STJPATIENT_ACTIVE',
        'STJPATIENT_REMISSION'
    };
    public boolean hasRevNotes {get; set;}

    Integer TIMEOUT_INT_SECS = 60;
    AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture xrefResponse;

    //Changes for code refactor
    public HighlightsViewModel viewModel {get; private set;}

    public SSHighlightsController(ApexPages.StandardController controller) {
        isConsLoaded = false;
        System.debug('in constructor');
        viewModel = new HighlightsViewModel();
        viewModel.Lead = ECCUtil.getCurrLead(System.currentPageReference().getParameters().get('id')).SSLead;
        ContactId = viewModel.Lead.callObject__c;

        //CONVIO refactor 
        viewModel.currLead = ECCUtil.getCurrLead(viewModel.Lead.Id);

    }

    //initialize
    public Continuation reload(){

        leadId = System.currentPageReference().getParameters().get('id');
        //currLead = ECCUtil.getCurrLead(leadId);
        System.debug('in reload');
        Long startMs = Datetime.now().getTime();
        System.debug('startMs =' + startMs);


       // viewModel.Opportunity = ECCEventHelper.GetDIYOppFromLead(viewModel.Lead.Id, viewModel.Opportunity);
        System.debug('viewModel.TIMEOUT_INT_SECS = ' + viewModel.TIMEOUT_INT_SECS);
        Continuation continuation = new Continuation(viewModel.TIMEOUT_INT_SECS);
        continuation.continuationMethod = 'gotConstituent';
        isConsLoaded = false;
        System.debug('about to getConstituent');
        System.debug('viewModel.Lead.ConstituentID__c = ' + viewModel.Lead.ConstituentID__c);
        if (viewModel.Lead.ConstituentID__c != null){
            viewModel.OrganizerResponse = AsyncC360Util.getConstituent(continuation, 
                                                        null, 
                                                        viewModel.Lead.ConstituentID__c,
                                                        null,
                                                        'DMS', 
                                                        new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES','REVENUE_NOTES'}, 
                                                        'ALL');
        }
        System.debug('sent the request');
        //output
        system.debug('lead=' + viewModel.Lead);
        ECCUtil.processLeadEmailPhoneUpdate(viewModel.currLead, viewModel.OrganizerEmail, viewModel.OrganizerPhone);
        Long endMs = DateTime.now().getTime();
        system.debug('================== Reload() RUNTIME ================== ' + (endMs - startMs) + ' ms');
        return continuation;
    }

    public Object gotConstituent() {
        System.debug('gotConstituent: ' + Datetime.now());
        System.debug('viewModel.Lead.ConstituentID__c = ' + viewModel.Lead.ConstituentID__c);
        Continuation cont = null;
        Constituencies = new List<string>();
       // isVIP = false;
        System.debug('360' + viewModel.OrganizerResponse);
        if (viewModel.Lead.ConstituentID__c != null && viewModel.OrganizerResponse != null) {
        System.debug('362 ' + viewModel.OrganizerResponse.getValue().Constituent);
        domainSoapStjudeOrg.Constituent con = viewModel.OrganizerResponse.getValue().Constituent;
        System.debug('364');
            if (con != null) {
                

                System.debug('con.Transactions = ' + con.Transactions);
                consId = con.ConstituentId;
                ConsType = con.Type_x.Code;
                ConStatus = con.Status;

                if (viewModel.Lead.ConstituentID__c != null && viewModel.OrganizerResponse != null) {
                    viewModel.Organizer = viewModel.OrganizerResponse.getValue().Constituent;
                    
                    System.debug('viewModel.Organizer.Transactions = ' + viewModel.Organizer.Transactions);
                    if (viewModel.Organizer.Transactions != null){
                        viewModel.HasRevNotes = viewModel.Organizer.Transactions.size() > 0;
                        System.debug('viewModel.HasRevNotes = ' + viewModel.HasRevNotes);
                    }

                    if (viewModel.Organizer.Profile != null && viewModel.Organizer.Profile.FinancialProfile != null) {
                        viewModel.FinancialProfile = viewModel.Organizer.Profile.FinancialProfile;
                    }
                    
                    
                    viewModel.OrganizerName = ECCEventHelper.GetConstituentName(viewModel.Organizer);
                    viewModel.OrganizerEmail = ECCEventHelper.GetConstituentEmail(viewModel.Organizer);
                    viewModel.OrganizerPhone = ECCEventHelper.GetConstituentPhone(viewModel.Organizer);  
                    viewModel.IsOrganizerLoaded = true;

                    
                    if (con.Staff != null && String.isNotBlank(con.Staff.Name)) {
                    Staff = con.Staff.Name;
                    }
                    
                    if (con.Properties != null && con.Properties.size() > 0) {
                    for(domainSoapStjudeOrg.Property prop : con.Properties) {
                        if (string.isNotBlank(prop.Property)) {
                            for(string cons : ConstToWatch) {   
                                if(prop.Property == cons) {
                                    if (prop.Status.toUpperCase() == 'ACTIVE') {
                                        if (prop.StartDate == null || DateTime.now() >= prop.StartDate) {
                                            if (prop.EndDate == null || DateTime.now() <= prop.EndDate) {
                                                isVIP = true;
                                                System.debug('isVIP = ' + isVIP);
                                                Constituencies.add(prop.Property);
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                system.debug('Constituencies');
                System.debug('403');
                if (con.Preferences != null) {
                    prefs = con.Preferences;
                }

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

                    /*if(con.ConstituentType__c == 'INDIVIDUAL') {
                    Preferred = (con.Preferred != null && con.Preferred);
                    }*/



                //xref continuation
                cont = new Continuation(TIMEOUT_INT_SECS);
                cont.continuationMethod = 'gotConstituentXRefs';
                isConsLoaded = false;
                system.debug('start get getConstituentXRefs: ' + Datetime.now());
                xrefResponse = AsyncC360Util.getConstituentXRefs(cont, consId, false);


                }
            }
        }

        return cont;
    }


    public Object gotConstituentXRefs() {
            system.debug('finish get getConstituentXRefs: ' + Datetime.now());
            system.debug('gotConstituentXRefs: ' + Datetime.now());  
            System.debug('451');
            System.debug('452' + xrefResponse.getValue());
            domainSoapStjudeOrg.Constituent360XRef conXref = xrefResponse.getValue();
            System.debug('452');
            Xrefs = new domainSoapStjudeOrg.SystemXRef[] {};
            domainSoapStjudeOrg.SystemXRef[] dmsXrefs = new List<domainSoapStjudeOrg.SystemXRef>();
            
            if (conXref != null && conXref.Constituents != null) {
                for(domainSoapStjudeOrg.ConstituentBase con : conXref.Constituents) {
                    if (con.SystemXRef != null) {
                        domainSoapStjudeOrg.SystemXRef xrCon = con.SystemXRef;
                        if (xrCon.Sys != null && xrCon.Sys.Name != null) {
                            if (xrCon.Sys.Name == 'TA') {
                                xrefs.add(xrCon);
                                taAccount = xrCon.XRefKey;
                                system.debug('ta: ' + xrCon.XRefKey);
                            }
                            else if (xrCon.Sys.Name == 'DMS') {
                                dmsXrefs.add(xrCon);
                                system.debug('DMS: ' + xrCon.XRefKey);
                            }
                        }
                    }
                }
            }
            system.debug('Xrefs complete');
            
            //domainSoapStjudeOrg.SystemXRef[] dmsXrefs = C360Util.getConstituentXRefs(consId, 'DMS');
            if(dmsXrefs != null && dmsXrefs.size() > 0) bbecId = dmsXrefs.get(0).XRefKey;
            system.debug('dmsXrefs');
            
            isConsLoaded = true;

            return null;
    }

    public string getOrganizerAddress() {
        String retval = ECCEventHelper.GetDisplayAddress(viewModel.Organizer);
        system.debug('getOrganizerAddress= ' + retval);
        return retval;
    } 

    
    public Class HighlightsViewModel{
        public HighlightsViewModel(){
        }

     //salesforce objects
//    public Opportunity Opportunity {get; private set;}
    public Lead Lead {get; private set;}

    public ECCUtil.SSLeads currLead {get; private set;}

        //organizer 
    public domainSoapStjudeOrg.Constituent Organizer {get; private Set;}
    public String OrganizerName  {get; private Set;}
    public String OrganizerPhone {get; private set;}
    public String OrganizerEmail {get; private set;}
    public boolean IsOrganizerLoaded { get; private set; }
   

    public domainSoapStjudeOrg.FinancialProfile FinancialProfile {get; private set;}
    public boolean isConsLoaded { get; private set; }


    public boolean HasRevNotes {get; set;}

    //event
    public EventHighlights__x EventHighLights {get; set;}
    AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture OrganizerResponse;
    Integer TIMEOUT_INT_SECS = 60;

    AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture consResponse;

    public String bbecURL {get; set;}
//    AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture xrefResponse;


    }

    public string getBbecURL() {
        return BbecSettings__c.getInstance('Master').BbecURL__c;
    
    }
    
    public string getPledgeMaintURL() {
        return PledgeMaintenanceSettings__c.getInstance('Master').PledgeMaintURL__c;
    }
    
    public string getNonce() {
        return ECCUtil.getToken();
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

    /*public string getMergeApplicationURL() {
        String retURL = CustomSettings__c.getValues('MergeApplication').Value__c;
        return retURL;
    }*/
}