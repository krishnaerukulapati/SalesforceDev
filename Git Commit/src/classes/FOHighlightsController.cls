public with sharing class FOHighlightsController {
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
    public String bbecId {get; private set;}
    public String taAccount {get; private set;}
    public String relHousehold {get; private set;}
    public String relType {get; private set;}
    public String relName {get; private set;}
    public String relPref {get; private set;}
    public Integer totalResults {get; private set;}
    public Integer shortResults;
    //public String tmsId {get; private set;}
    public String[] Constituencies {get; private set;}
    public String pledgeId {get; private Set;}
    public domainSoapStjudeOrg.SystemXRef[] Xrefs {get; private set;}
    public domainSoapStjudeOrg.FinancialProfile fp {get; private set;}
    public domainSoapStjudeOrg.Preference[] prefs {get; private Set;}
    public domainSoapStjudeOrg.Relationship[] rels {get; set;}
    public String[] ConstToWatch = new string[] {'VIP_YES', 'BOARD_CURRENT', 'BOARD_PAST', 'St Jude Parent YES',
        'St. Jude Parent - Deceased',
        'St. Jude Parent - Live',
        'STJFAMILY_DECEASED',
        'STJFAMILY_LIVING',
        'STJFAMILY_YES',
        'STJPATIENT_ACTIVE',
        'STJPATIENT_REMISSION'
    };
    public boolean isUUIDSet {get; private set;}
    public Boolean hasWarnings {get; private Set;}
    public String warnings {get; private Set;}
    public boolean isVIP {get; private Set;}
    public boolean isCaseSet {get; private Set;}
    public boolean foError {get; private set;}
    public boolean odataLoad { get; private set; }
    public String consId {get; private set;}
    public Case currCase { get; private set; }
    public string testBlank {get; set;}
    public boolean isResearchCase { get; private set; }     // is this a Research case?
    public boolean reload {get; set;}
    public boolean isConsLoaded { get; private set; } 
    
    public Decimal recognitionTotal {get; set;}
    
    public FOHighlightsController(ApexPages.StandardController controller) {
        reLoad();
    }

    public PageReference changeCons() {
        caseId = System.currentPageReference().getParameters().get('id');
        
        EVMUtil.clearCons(caseId);
        
        PageReference pr = Page.FOHighlights;
        pr.setRedirect(true);
        pr.getParameters().put('id', caseId);
        return pr;
    }

    public string getNonceES() {
        return EVMUtil.getToken('this is the events nonce key and the events nonce key is this');
    }

    public string getNonce() {
        return EVMUtil.getToken();
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
    
    public PageReference reLoad() {
        system.debug('start: ' + Datetime.now());
        totalResults = 0;
        relPref = 'None';
        caseId = System.currentPageReference().getParameters().get('id');
        string rel = System.currentPageReference().getParameters().get('reload');
        if (String.isNotBlank(rel)) reload = Boolean.valueOf(rel);
        system.debug(caseId);

        system.debug('start get case: ' + Datetime.now());
        List<Case> cases = EVMUtil.getCurrCase(caseId);
        system.debug('finish get case: ' + Datetime.now());
        
        isVIP = false;
        odataLoad = false;

        if (cases.size() > 0) {
            currCase = cases.get(0);
            isCaseSet = true;
        
            // see if this is a research case
            Id researchTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Research').RecordTypeId;
            isResearchCase = false;
           // if ( currCase.recordTypeId == researchTypeId ) {
              //  isResearchCase = true;               
           // }

            system.debug(currCase.ConstituentID__c);
            //system.debug(currCase.Constituent_Name__c);
            
            if (currCase.ConstituentID__c != null) {
                isUUIDSet = true;
                Constituencies = new List<string>();
                domainSoapStjudeOrg.Constituent con;

                try {
                    system.debug('start get constituent: ' + Datetime.now());
                    try {
                        //Trying GetConstituent without masterSystem specified first
                        con = FOUtil.getConstituent(null, currCase.ConstituentID__c, 
                            null, null, new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 
                                'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES'}, 'ALL');
                        //con = FOUtil.getConstituent(null, currCase.ConstituentID__c, 
                        //    new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 
                        //        'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES'}, 
                        //        currCase.ConstituentType__c);
                    }
                    catch(Exception e) {
                        //try without transactions
                        con = FOUtil.getConstituent(null, currCase.ConstituentID__c, 
                            new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'PREFERENCES'}, 
                                currCase.ConstituentType__c);
                    }
                    system.debug('finish get constituent: ' + Datetime.now());            
                    foError = false;
                }
                catch(Exception e) {
                    system.debug(e.getMessage() + ' at ' + e.getLineNumber() + ', trace: ' + e.getStackTraceString());
                    system.debug('finish get constituent: ' + Datetime.now());
                    foError = true;
                    try {
                        List<PreferredConstituentInfos__x> pis = [select 
                                consType__c,
                                constituent_id__c,
                                title__c,
                                first_name__c,
                                middle_name__c,
                                last_name__c,
                                suffix__c,
                                name__c,
                                address__c,
                                extra_line_1__c,
                                extra_line_2__c,
                                city__c,
                                state__c,
                                country__c,
                                zip__c,
                                zip_ext__c,
                                addressType__c,
                                email_address__c,
                                emailType__c,
                                phone_number__c,
                                phoneType__c
                            from
                                PreferredConstituentInfos__x
                            where
                                constituent_id__c = :currCase.ConstituentID__c];
                        if (pis.size() == 1) {
                            PreferredConstituentInfos__x pi = pis.get(0);
                            Address = 
                                (string.isNotBlank(pi.address__c) ? pi.address__c + '\n' : '') +
                                (string.isNotBlank(pi.extra_line_1__c) ? pi.extra_line_1__c + '\n' : '') +
                                (string.isNotBlank(pi.extra_line_2__c) ? pi.extra_line_2__c + '\n' : '') +
                                (string.isNotBlank(pi.city__c) ? pi.city__c + ', ' : '') +
                                (string.isNotBlank(pi.state__c) ? pi.state__c + ' ' : '') +
                                (string.isNotBlank(pi.zip__c) ? pi.zip__c : '');
                            Title = pi.title__c;
                            FirstName = pi.first_name__c;
                            LastName = pi.last_name__c;
                            LongName = pi.name__c;
                            if (String.isEmpty(LongName)) {
                                LongName = FirstName + ' ' + LastName;
                            }
                            Email = pi.email_address__c;
                            EmailType = pi.emailType__c;
                            Phone = pi.phone_number__c;
                            PhoneType = pi.phoneType__c;
                            ConsType = pi.consType__c;
                            system.debug('pi.address__c = ' + pi.address__c 
                                + '\npi.extra_line_1__c = ' + pi.extra_line_1__c
                                + '\npi.extra_line_2__c = ' + pi.extra_line_2__c
                                + '\npi.city__c = ' + pi.city__c
                                + '\npi.state__c = ' + pi.state__c
                                + '\npi.zip__c = ' + pi.zip__c
                                + '\npi.title__c = ' + pi.title__c
                                + '\npi.email_address__c = ' + pi.email_address__c
                                + '\npi.phone_number__c = ' + pi.phone_number__c);
                        }
                        odataLoad = true;
                    }
                    catch(Exception exc) {
                        //eat it ;/
                    }

                }
        //            domainSoapStjudeOrg.Constituent con = FOUtil.getConstituent(currCase.ConstituentUUID__c, null, new string[] {'PROFILE', 'PROPERTIES', 'FINANCIAL_PROFILE', 'PREFERENCES'});
                if (con != null) {
                    consId = con.ConstituentId;
                    isConsLoaded = true; //this is to trigger the interaction warnings modal
                    system.debug('start');
                    system.debug('con.Type_x.Code: ' + con.Type_x.Code);
                    ConsType = con.Type_x.Code;
                    system.debug('con.Status: ' + con.Status);
                    ConStatus = con.Status;
                    if (currCase.ConstituentType__c == 'INDIVIDUAL') {
                        FirstName = con.FirstName;
                        LastName = con.LastName;
                        Preferred = (con.Preferred != null && con.Preferred);
                        if (String.isBlank(con.LongName)) LongName = FirstName + ' ' + LastName;
                        else LongName = con.LongName;
                        system.debug('Long Name: ' + LongName + ', con.LongName: ' + con.LongName);
                        if (con.RelatedHousehold != null && String.isNotBlank(con.RelatedHousehold.Name)) {
                            system.debug('con.RelatedHousehold.Name: ' + con.RelatedHousehold.Name);
                            relHousehold = con.RelatedHousehold.Name;
                        } 
                                           
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
                                (string.isNotBlank(a.Street1) ? a.Street1 + '\n' : '') +
                                (string.isNotBlank(a.Street2) ? a.Street2 + '\n' : '') +
                                (string.isNotBlank(a.Street3) ? a.Street3 + '\n' : '') +
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
                    system.debug('Staff');   
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
                    system.debug('Relationships');

                    soapStjudeOrg.GetRelationshipsResponse_element resp = FOUtil.getRelationships(consId, 0, 100);
                    if (resp.TotalResults == null) {
                        totalResults = 0;
                        rels = new domainSoapStjudeOrg.Relationship[] {};
                    }
                    else {
                        if (totalResults == 0) totalResults = resp.TotalResults;
                        rels = resp.Relationships;
                    }

                    if (resp.TotalResults > 0) {
                        totalResults = resp.TotalResults;
                        if (totalResults > 10) {
                            shortResults = 10;
                        }
                        else {
                            shortResults = totalResults;
                        }
                        system.debug('Total relationships: ' + totalResults);   
                        for (Integer i = 0; i < shortResults; i++) {
                            domainSoapStjudeOrg.Constituent relCon = FOUtil.getConstituent(null, resp.Relationships[i].RelatedConstituent.ConstituentID, 
                                new string[] {'PROFILE'});                                      
                            if (relCon.Type_x.Code == 'INDIVIDUAL') {
                                relType = relCon.Type_x.Code;
                                if (String.isBlank(relCon.LongName)) {
                                    relName = relCon.FirstName + ' ' + relCon.LastName;
                                } 
                                else {
                                    relName = relCon.LongName;
                                }                                
                            }
                            if (relCon.Type_x.Code == 'ORGANIZATION') {
                                relType = relCon.Type_x.Code;
                                if (String.isBlank(relCon.Name)) {
                                    if (String.isBlank(relCon.LongName)) {
                                        relName = relCon.FirstName + ' ' + relCon.LastName;
                                    }
                                    else {
                                        relName = relCon.LongName;                                 
                                    }                                
                                }
                                else {
                                    relName = relCon.Name;
                                }
                            }
                            system.debug('Related Constituent: ' + relName);
                            system.debug('Related Constituent is primary: ' + relCon.Preferred);
                            if (relCon.Preferred == true) {
                                system.debug('Related Constituent ' + relName + 'is primary');
                                relPref = relName;
                            }
                        }                      
                    }
                    /*
                    system.debug('Total Relationships: ' + resp.TotalResults);
                    for (Integer i = 0; i < resp.Relationships.size(); i++) {
                        system.debug('House/Org Constituent Type: ' + resp.Relationships[i].RelatedConstituent.Type_x.Code); //relationship of related cons to house/org
                        system.debug('House/Org Constituent Name: ' + resp.Relationships[i].RelatedConstituent.Name + 
                                   ', First Name: ' + resp.Relationships[i].RelatedConstituent.FirstName + 
                                   ', Last Name: ' + resp.Relationships[i].RelatedConstituent.LastName +
                                   ', Long Name: ' + resp.Relationships[i].RelatedConstituent.LongName); //name of related house/org
                        system.debug('Relationship Type: ' + resp.Relationships[i].Type_x.Code); //type of relationship with house/org
                    //New relationship request for house/org
                        soapStjudeOrg.GetRelationshipsResponse_element related = FOUtil.getRelationships(resp.Relationships[i].RelatedConstituent.ConstituentID, 0, 10);
                        system.debug('Total Relationships: ' + related.TotalResults);
                        for (Integer j = 0; j < related.Relationships.size(); j++) {
                            system.debug('Related Constituent Type: ' + related.Relationships[j].RelatedConstituent.Type_x.Code); //relationship of related cons to con
                            system.debug('Related Constituent Name: ' + related.Relationships[j].RelatedConstituent.Name + 
                                       ', First Name: ' + related.Relationships[j].RelatedConstituent.FirstName + 
                                       ', Last Name: ' + related.Relationships[j].RelatedConstituent.LastName + 
                                       ', Long Name: ' + related.Relationships[j].RelatedConstituent.LongName); //name of related cons
                            system.debug('Relationship Type: ' + related.Relationships[j].Type_x.Code); //type of relationship with related cons
                        }
                    }                   
                    */
                    system.debug('Constituencies');
                    
                    system.debug('start get getConstituentXRefs: ' + Datetime.now());
                    List<domainSoapStjudeOrg.SystemXRef> conXref = FOUtil.getConstituentXRefs(consId, '');
                    system.debug('finish get getConstituentXRefs: ' + Datetime.now());
                    Xrefs = new List<domainSoapStjudeOrg.SystemXRef>();
                    domainSoapStjudeOrg.SystemXRef[] dmsXrefs = new List<domainSoapStjudeOrg.SystemXRef>();
                    for(domainSoapStjudeOrg.SystemXRef xrCon : conXref) {
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
                    system.debug('Xrefs');
                    
                    //domainSoapStjudeOrg.SystemXRef[] dmsXrefs = FOUtil.getConstituentXRefs(consId, 'DMS');
                    if(dmsXrefs != null && dmsXrefs.size() > 0) bbecId = dmsXrefs.get(0).XRefKey;
                    system.debug('dmsXrefs');
                    
                    //pledgeId = FOUtil.getPledgeId(consId);
                    pledgeId = '';
                    system.debug('pledgeId');
                    
                    if (con.Interactions != null && con.Interactions.size() > 0) {
                        warnings = '';
                        hasWarnings = true;
                        System.debug('has interactions/warnings');
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
        }
        else isCaseSet = false;
        system.debug('finish: ' + Datetime.now());
        return null;
    }
    
    public string getBbecURL() {
        return BbecSettings__c.getInstance('Master').BbecURL__c;
    }

    public string getEventsMasteringURL() {
        EnvironmentSettings__c es = [SELECT EventsMastering__c FROM EnvironmentSettings__c];
        return es.EventsMastering__c;
    }
    
   /* public string getTmsURL() {
        return TributesManagement__c.getInstance('Master').TMS_URL__c;
    }*/
}