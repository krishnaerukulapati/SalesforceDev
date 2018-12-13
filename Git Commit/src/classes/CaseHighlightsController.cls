public with sharing class CaseHighlightsController {
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
    public String Staff {get; private set;}
    public String Deceased {get; private set;}
    public String ConsType {get; private set;}
    public String ConStatus {get; private set;}
    public Boolean Preferred {get; private set;}
    public String caseId {get; private set;}
    public String leadId {get; private set;}
    public String bbecId {get; private set;}
    public String taAccount {get; private set;}
    public String AgentId {get; private set;}

    //public String tmsId {get; private set;}
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
        'STJPATIENT_REMISSION',
        'FFSJ1 - Unknown',
        'FFSJ1 - Active',
        'FFSJ1 - Remission',
        'FFSJ2 - Unknown',
        'FFSJ2 - Living',
        'FFSJ2 - Deceased',
        'FFSJ3 - Unknown',
        'FFSJ3 - Living',
        'FFSJ3 - Deceased',
        'FFSJ4 - Unknown',
        'FFSJ4 - Active',
        'FFSJ4 - Remission',
        'FFSJ5 - Unknown',
        'FFSJ5 - Living',
        'FFSJ5 - Deceased',
        'FFSJ6 - Unknown',
        'FFSJ6 - Living',
        'FFSJ6 - Deceased'
    };
    
    public Boolean hasWarnings {get; private Set;}
    public String warnings {get; private Set;}
    public boolean isVIP {get; private Set;}
    public boolean c360Error {get; private set;}
    public String consId {get; private set;}
    public Case currCase { get; private set; }
    public String testBlank {get; set;}
    public boolean reload {get; set;}
    public boolean hasRevNotes {get; set;}

    public boolean isCaseSet {get; private Set;}
    public boolean isUUIDSet {get; private set;}
    public boolean isResearchCase { get; private set; }     // is this a Research case?
    public boolean isConsLoaded { get; private set; }

    Integer TIMEOUT_INT_SECS = 60;

    AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture consResponse;
    AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture xrefResponse;

    public CaseHighlightsController(ApexPages.StandardController controller) { 
        isConsLoaded = false;
        isUUIDSet = false;
        caseId = System.currentPageReference().getParameters().get('id');
        string rel = System.currentPageReference().getParameters().get('reload');
        if (String.isNotBlank(rel)) reload = Boolean.valueOf(rel);

        system.debug('start get case: ' + Datetime.now());
        List<Case> cases = ECCUtil.getCurrCase(caseId);
        system.debug('finish get case: ' + Datetime.now());
        system.debug('cases: ' + cases);

        if (cases != null && cases.size() >0) {
            isCaseSet = true;   
            currCase = cases.get(0);
        }
        else{
            isCaseSet = false;
        }

        isUUIDSet = currCase != null && currCase.ConstituentID__c != null ? true : false;
        AgentId = ECCUtil.GetAgentIdByUserId(UserInfo.getUserId());
        system.debug('isCaseSet: ' + isCaseSet);
        system.debug('isUUIDSet: ' + isUUIDSet);
    }

    public PageReference changeCons() {
        caseId = System.currentPageReference().getParameters().get('id');

        ECCUtil.clearCons(caseId);
        
        PageReference pr = Page.CaseHighlights;
        pr.setRedirect(true);
        pr.getParameters().put('id', caseId);
        return pr;
    }

    public string getNonce() {
        return ECCUtil.getToken();
    }

    public string getReturnURL() {
        system.debug(URL.getSalesforceBaseUrl().toExternalForm() + 
            Encodingutil.urlEncode('/flow/Pledge_Cancel_Reason_Flow?CaseId=' + caseId
                , 'UTF-8'));
        return 
            URL.getSalesforceBaseUrl().toExternalForm() + 
            Encodingutil.urlEncode('/flow/Pledge_Cancel_Reason_Flow?CaseId=' + caseId
                + '&retURL=' + Page.EccCloseSubTab
                , 'UTF-8');
    }

    public string getFulfillURL() {
        system.debug('/flow/Fullfillment_Request?CaseId=' + caseId
                + '&retURL=' + Page.EccCloseSubTab);
        return '/flow/Fullfillment_Request?CaseId=' + caseId
                + '&retURL=' + Encodingutil.urlEncode(Page.EccCloseSubTab.getURL(), 'UTF-8');
    }
    
    public string getInteractURL() {
        system.debug('/flow/Interactions_Flow?CaseId=' + caseId
                + '&retURL=' + Page.EccCloseSubTab);
        return '/flow/Interactions_Flow?CaseId=' + caseId
                + '&retURL=' + Encodingutil.urlEncode(Page.EccCloseSubTab.getURL(), 'UTF-8');
    }

    public string getPledgeMaintURL() {
        return PledgeMaintenanceSettings__c.getInstance('Master').PledgeMaintURL__c;
    }

    public string getMergeApplicationURL() {
        String retURL = CustomSettings__c.getValues('MergeApplication').Value__c;
        System.debug('retURL MergeApplication = ' + retURL);
        return retURL;
    }
    
    public Continuation reLoad() {
        Continuation cont = null;
        system.debug('start: ' + Datetime.now());

        
        system.debug('userId: ' + UserInfo.getUserId());
        system.debug('caseId: ' + caseId);
        system.debug('agentId: ' + AgentId);        
        system.debug('caseId  = ' + caseId);
       
        isVIP = false;

        if (isCaseSet) {
            System.debug(' currCase = ' + currCase);
            isCaseSet = true;
      
            // see if this is a research case
            Id researchTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Research').RecordTypeId;
            isResearchCase = false;
            System.debug('currCase.recordTypeId = ' + currCase.recordTypeId);
            System.debug('researchTypeId = ' + researchTypeId);
            if ( currCase.recordTypeId == researchTypeId ) {
                isResearchCase = true;
            }

            system.debug('currCase.ConstituentID__c ' + currCase.ConstituentID__c);
            if (currCase.ConstituentID__c != null) {
                isUUIDSet = true;
                Constituencies = new List<string>();

                system.debug('start get constituent: ' + Datetime.now());
                
                cont = new Continuation(TIMEOUT_INT_SECS);
                cont.continuationMethod = 'gotConstituent';
                isConsLoaded = false;

                consResponse = AsyncC360Util.getConstituent(cont, 
                                                            null, 
                                                            currCase.ConstituentID__c, 
                                                            null, 
                                                            'DMS',
                                                            new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'}, 
                                                            currCase.ConstituentType__c);
            }
            system.debug('call processCaseEmailUpdate method');
            ECCUtil.processCaseEmailUpdate(currCase, Email);
        }

        system.debug('finish: ' + Datetime.now());
        return cont;
    }

    public Object gotConstituent() {
        System.debug('gotConstituent: ' + Datetime.now());  
        System.debug('consResponse = ' + consResponse);
        domainSoapStjudeOrg.Constituent con = consResponse.getValue().Constituent;
        Continuation cont = null;

        System.debug(' con in try = ' + con);

        system.debug('finish get constituent: ' + Datetime.now());            
        c360Error = false;

        if (con != null) {

            if (con.Transactions != null){
                hasRevNotes = con.Transactions.size() > 0;
                System.debug('hasRevNotes = ' + hasRevNotes);
            }

            System.debug('con.Transactions = ' + con.Transactions);
            consId = con.ConstituentId;
            system.debug('start');
            ConsType = con.Type_x.Code;
            ConStatus = con.Status;
            if (currCase.ConstituentType__c == 'INDIVIDUAL') {
                FirstName = con.FirstName;
                LastName = con.LastName;
                Preferred = (con.Preferred != null && con.Preferred);
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
                    if (e.Preferred != null && e.Preferred == true)
                    break;
                }
            }
            else Email = 'Email Address';
            system.debug('email = ' + Email );

            Address = ECCEventHelper.GetDisplayAddress(con);

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
            if (con.Profile != null && con.Profile.FinancialProfile != null) {
                fp = con.Profile.FinancialProfile;
            }
            system.debug('Phone');    

            if (con.Preferences != null) {
                prefs = con.Preferences;
            }
            system.debug('Prefs');    

            if (con.Staff != null && String.isNotBlank(con.Staff.Name)) {
                Staff = con.Staff.Name;
             
            }
            system.debug('Staff = ' + Staff);   
            if (con.Properties != null && con.Properties.size() > 0) {
                for(domainSoapStjudeOrg.Property prop : con.Properties) {
                    if (string.isNotBlank(prop.Property)) {
                        for(string cons : ConstToWatch) {   
                            if(prop.Property == cons) {
                                if (prop.Status.toUpperCase() == 'ACTIVE') {
                                    if (prop.StartDate == null || DateTime.now() >= prop.StartDate) {
                                        if (prop.EndDate == null || DateTime.now() <= prop.EndDate) {
                                            isVIP = true;
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

            //pledgeId = C360Util.getPledgeId(consId);
            pledgeId = '';
            system.debug('pledgeId');

            System.debug('con.Interactions:' + con.Interactions);            
            if (con.Interactions != null && con.Interactions.size() > 0) {
                warnings = '';
                hasWarnings = true;
                System.debug('has interactions');
                for(domainSoapStjudeOrg.Interaction i : con.Interactions) {
                    warnings += i.ContactDate + '\t' + i.LongComments + '\n-----------------------------\n';
                }
            }
            System.debug('warnings: ' + warnings);
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

            //xref continuation
            cont = new Continuation(TIMEOUT_INT_SECS);
            cont.continuationMethod = 'gotConstituentXRefs';
            isConsLoaded = false;
            system.debug('start get getConstituentXRefs: ' + Datetime.now());
            xrefResponse = AsyncC360Util.getConstituentXRefs(cont, consId, false);
        }  
        return cont;
    }

    public Object gotConstituentXRefs() {
        system.debug('finish get getConstituentXRefs: ' + Datetime.now());
        system.debug('gotConstituentXRefs: ' + Datetime.now());  
        domainSoapStjudeOrg.Constituent360XRef conXref = xrefResponse.getValue();
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
    
    public string getBbecURL() {
        return BbecSettings__c.getInstance('Master').BbecURL__c;
    }
}