public with sharing class C360Util {
    private static integer timeOutMS = 30000;
    private static integer longTimeout = 60000;
    public static objectSoapStjudeOrg.Signature getSignature() {
        return getSignature(null);
    }

    public static objectSoapStjudeOrg.Signature getSignature(String contactMethod) {
        objectSoapStjudeOrg.Signature sig = new objectSoapStjudeOrg.Signature();
        sig.channel = 'ECC';
        sig.user_x = UserInfo.getUserName();
        if (String.isNotBlank(contactMethod)) {
            system.debug('contactMethod: ' + contactMethod);
            sig.contactMethod = contactMethod;
        }

        return sig;
    }

    public static soapStjudeOrg.SearchConstituents360Response_element searchC360(string scope, string phone, 
        string address1, string address2, string name, string lastName, string firstName, string zip, 
        string city, string state, string donorId, string pledgeId, string altId, String email, 
        Integer startRow, Integer endRow) { 
        return searchC360(scope, phone, address1, address2, name, lastName, firstName, zip, city, state, donorId, 
            pledgeId, altId, email, startRow, endRow, null, null);
    }

    public static soapStjudeOrg.SearchConstituents360Response_element searchC360(string scope, string phone, 
        string address1, string address2, string name, string lastName, string firstName, string zip, 
        string city, string state, string donorId, string pledgeId, string altId, String email, 
        Integer startRow, Integer endRow, string sortOrder) { 
        return searchC360(scope, phone, address1, address2, name, lastName, firstName, zip, city, state, donorId, 
            pledgeId, altId, email, startRow, endRow, sortOrder, null);
    }

    public static soapStjudeOrg.SearchConstituents360Response_element searchC360(string scope, string phone, 
        string address1, string address2, string name, string lastName, string firstName, string zip, 
        string city, string state, string donorId, string pledgeId, string altId, String email, Integer startRow, 
        Integer endRow, string sortOrder, string p2pId) { 
        
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        List<objectSoapStjudeOrg.SearchResponse> sr = new List<objectSoapStjudeOrg.SearchResponse>();
        List<domainSoapStjudeOrg.Constituent> res = new List<domainSoapStjudeOrg.Constituent>();

        cp.timeout_x = timeOutMS;
        objectSoapStjudeOrg.SearchParameters sp = new objectSoapStjudeOrg.SearchParameters();
        objectSoapStjudeOrg.Paginator pag = new objectSoapStjudeOrg.Paginator();
        
        pag.LowerBound = startRow;
        pag.UpperBound = endRow;
        sp.EnhancedMatching = true;
        if (String.isNotEmpty(phone)) sp.Phone = ECCUtil.formatPhone(phone); 
        if (String.isNotEmpty(email)) sp.EmailAddress = email;
        if (String.isNotEmpty(pledgeId)) sp.PledgeNumber = pledgeId;
        if (String.isNotEmpty(name)) sp.Name = name;
        if (String.isNotEmpty(lastName)) sp.LastName = lastName;
        if (String.isNotEmpty(firstName)) sp.FirstName = firstName;
        if (String.isNotEmpty(address1)) sp.Street1 = address1;
        if (String.isNotEmpty(address2)) sp.Street2 = address2;
        if (String.isNotEmpty(city)) sp.City = city;
        if (String.isNotEmpty(state)) sp.StateCode = state;
        if (String.isNotEmpty(zip)) sp.ZipCode = zip;

        system.debug(
            'Phone = ' + sp.Phone  + '\n' + 
            'EmailAddress = ' + sp.EmailAddress  + '\n' + 
            'PledgeNumber = ' + sp.PledgeNumber  + '\n' + 
            'Name = ' + sp.Name  + '\n' + 
            'LastName = ' + sp.LastName  + '\n' + 
            'FirstName = ' + sp.FirstName  + '\n' + 
            'Street1 = ' + sp.Street1  + '\n' + 
            'Street2 = ' + sp.Street2  + '\n' + 
            'City = ' + sp.City  + '\n' + 
            'StateCode = ' + sp.StateCode  + '\n' + 
            'ZipCode = ' + sp.ZipCode  + '\n' + 
            'DonorId = ' + donorId  + '\n' + 
            'P2pId = ' + p2pId  + '\n' + 
            'Scope = ' + scope
        );
            
        if (String.isNotEmpty(donorId)) {
            system.debug('donorId in C360Util : ' + donorId);
            sp.SystemXRef = new domainSoapStjudeOrg.SystemXRef();
            sp.SystemXRef.Sys = new domainSoapStjudeOrg.Sys();
            sp.SystemXRef.XRefKey = donorId;
            if(donorId.contains('8-')){
                sp.SystemXRef.Sys.Name = 'DMS';
                system.debug('DMS ');
            }
            else{
                 sp.SystemXRef.Sys.Name = 'TA';
                 system.debug('TA' );
            }
            
        }
            
        if (String.isNotEmpty(p2pId)) {
            sp.SystemXRef = new domainSoapStjudeOrg.SystemXRef();
            sp.SystemXRef.Sys = new domainSoapStjudeOrg.Sys();
            sp.SystemXRef.Sys.Name = 'Luminate';
            sp.SystemXRef.XRefKey = p2pId;
        }

        soapStjudeOrg.SearchConstituents360Response_element resp = cp.SearchConstituents360(scope, 'DETAIL', 'DMS', sp, sortOrder, pag, getSignature());
        
        return resp;
    }
    
    public static domainSoapStjudeOrg.Constituent getConstituent(string UUID, string consId, string[] Facet) {
        system.debug('string UUID = ' + UUID);
        system.debug('string consId = ' + consId);
        system.debug('string Facet = ' + Facet);
        system.debug('getConstituent(string UUID, string consId, string[] Facet)');
        return getConstituent(UUID, consId, null, Facet, 'ALL');
    }

    public static domainSoapStjudeOrg.Constituent getConstituent(string UUID, string consId, string[] Facet, String scope) {
        system.debug('getConstituent(string UUID, string consId, string[] Facet, String scope)');
        return getConstituent(UUID, consId, null, Facet, 'ALL');
    }
    
    public static domainSoapStjudeOrg.Constituent getConstituent(string UUID, string consId, 
        domainSoapStjudeOrg.SystemXRef SystemXRef, string[] Facet, String scope) {
        return getConstituent(UUID, consId, SystemXRef, 'DMS', Facet, scope);
    }

    public static domainSoapStjudeOrg.Constituent getConstituent(string UUID, string consId, 
        domainSoapStjudeOrg.SystemXRef SystemXRef, String MasterSystem, string[] Facet, String scope) {
        system.debug('string UUID = ' + UUID);
        system.debug('string consId = ' + consId);
        system.debug('domainSoapStjudeOrg.SystemXRef SystemXRef = ' + SystemXRef);
        system.debug('string Facet = ' + Facet);
        system.debug('string scope = ' + scope);
        system.debug('string MasterSystem = ' + MasterSystem);
        system.debug('getConstituent(string UUID, string consId, domainSoapStjudeOrg.SystemXRef SystemXRef, string[] Facet, String scope');
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        List<domainSoapStjudeOrg.Constituent> cons = new List<domainSoapStjudeOrg.Constituent>();
        system.debug('UUID: ' + UUID + ', consId: ' + consId + ', scope: ' + scope);
        
        cp.timeout_x = timeOutMS;
        
        return cp.GetConstituent(UUID, consId, SystemXRef, null, MasterSystem, 
            scope, Facet, null, null, getSignature(), null).Constituent;
    }
    
    public static String getPledgeId(String consId) {
        String ret = '';

        soapStjudeOrg.GetTransactionsResponse_element gtr = getTransations(null, consId, 1, 1, 'SUMMARY_PL', 'GIFT_DESC');
        
        System.debug(consId);
        if (gtr != null && gtr.Transactions != null && gtr.Transactions.size() > 0) {
            ret = gtr.Transactions.get(0).TransactionId;
        }
        
        return ret;
    }
    
    public static soapStjudeOrg.GetTransactionsResponse_element getTransations(String UUID, String consId,
        integer startRow, Integer endRow, String facet, String sortOrder) {
            system.debug('UUID: ' + UUID + ', consId: '+ consId + ', masterSystem: ' + 'TA');

        return getTransations(UUID, consId, startRow, endRow, facet, sortOrder, null, 'TA');
    }

    public static soapStjudeOrg.GetTransactionsResponse_element getRevenueNotes(String consId, String transId, Integer startRow, 
        Integer endRow,  String sortOrder) {

        objectSoapStjudeOrg.TxnFilter tf = new objectSoapStjudeOrg.TxnFilter();
        tf.FinancialTxnID = transId;

        return getTransations(null, consId, startRow, endRow, 'REVENUE_NOTES', sortOrder, tf, 'TA');
    }
    
    public static soapStjudeOrg.GetTransactionsResponse_element getTransations(String UUID, String consId,
        integer startRow, Integer endRow, String facet, String sortOrder, objectSoapStjudeOrg.TxnFilter filt, String masterSystem) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        objectSoapStjudeOrg.Paginator pag = new objectSoapStjudeOrg.Paginator();
        soapStjudeOrg.GetTransactionsResponse_element gtr;
        
        cp.timeout_x = timeOutMS;
        pag.LowerBound = startRow;
        pag.UpperBound = endRow;
        try {
            system.debug('UUID: ' + UUID + ', consId: '+ consId + ', masterSystem: ' + masterSystem);
            gtr = cp.GetTransactions(UUID, consId , null, masterSystem, facet, sortOrder, filt,
                pag, getSignature());
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        return gtr;
    }
    
    public static List<String> getConstituentIds(String id) {
        return getConstituentIds(id, false);
    }
    public static List<String> getConstituentIds(String id, boolean uuid) {
        domainSoapStjudeOrg.Constituent360XRef conXref = getConstituentXRefs(id, uuid);
        set<String> ids = new set<String>();
        
        for(domainSoapStjudeOrg.ConstituentBase con : conXref.Constituents) {
            if (!ids.contains(con.ConstituentId)) ids.add(con.ConstituentId);
        }
        
        return new List<String>(ids);
    }
    
    public static domainSoapStjudeOrg.SystemXRef[] getConstituentXRefs(string consId, String sysName) {
        domainSoapStjudeOrg.Constituent360XRef conXref = getConstituentXRefs(consId, false);
        domainSoapStjudeOrg.SystemXRef[] xrefs = new domainSoapStjudeOrg.SystemXRef[] {};
        
        if (conXref != null && conXref.Constituents != null) {
            for(domainSoapStjudeOrg.ConstituentBase con : conXref.Constituents) {
                if (con.SystemXRef != null && con.SystemXRef.Sys != null 
                    && con.SystemXRef.Sys.Name != null && (sysName == null || sysName == '' || con.SystemXref.Sys.Name == sysName)) {
                    
                    xrefs.add(con.SystemXRef);
                }
            }
        }
        
        return xrefs;
    }
    
    private static domainSoapStjudeOrg.Constituent360XRef getConstituentXRefs(String id, boolean uuid) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        
        cp.timeout_x = timeOutMS;
        
        //system.debug();
        return cp.GetConstituentXRefs(uuid ? id : null, uuid ? null : id, null, getSignature());
    }
    
    public static string editConstituent(domainSoapStjudeOrg.Individual i, 
        domainSoapStjudeOrg.Household h, domainSoapStjudeOrg.Organization o) {

        return editConstituent(i, h, o, null);
    }
    
    public static string editConstituent(domainSoapStjudeOrg.Individual i, 
        domainSoapStjudeOrg.Household h, domainSoapStjudeOrg.Organization o, String contactMethod) {

        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        soapStjudeOrg.EditConstituentResponse_element res;

        cp.timeout_x = timeOutMS;
        res = cp.EditConstituent(i, h, o, getSignature(contactMethod), null, null);
        return res.Result;
    }
    
    public static string editConstituent(domainSoapStjudeOrg.Individual i) {
        return editConstituent(i, null, null, null);
    }
    
    public static string editConstituent(domainSoapStjudeOrg.Individual i, domainSoapStjudeOrg.Household h) {
        return editConstituent(i, h, null, null);
    }

    public static domainSoapStjudeOrg.Constituent createConstituent(domainSoapStjudeOrg.Individual i) {
        return createConstituent(i, null, null);
    }
    
    public static domainSoapStjudeOrg.Constituent createConstituent(domainSoapStjudeOrg.Individual i,
        domainSoapStjudeOrg.Household h, domainSoapStjudeOrg.Organization o) {
        return createConstituent(i, null, null, null);
    }

    public static domainSoapStjudeOrg.Constituent createConstituent(domainSoapStjudeOrg.Individual i,
        domainSoapStjudeOrg.Household h, domainSoapStjudeOrg.Organization o, String contactMethod) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        soapStjudeOrg.CreateConstituentResponse_element res; 
        cp.timeout_x = longTimeout; 
        res = cp.CreateConstituent(i, h, o, getSignature(contactMethod), null, null, null);
        return res.CreatedConstituent;
    }
    
    public static soapStjudeOrg.GetInteractionsResponse_element getInteractions(String consId, String interactionFacet, integer startRow, integer endRow) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        soapStjudeOrg.GetInteractionsResponse_element resp = new soapStjudeOrg.GetInteractionsResponse_element();
        objectSoapStjudeOrg.InteractionFilter filt = new objectSoapStjudeOrg.InteractionFilter();
        objectSoapStjudeOrg.Paginator pag = new objectSoapStjudeOrg.Paginator();
        
        pag.lowerBound = startRow;
        pag.upperBound = endRow;

        filt.HouseholdView = true;

        cp.timeout_x = timeOutMS;
        resp = cp.GetInteractions(null, consId, null, null, interactionFacet, 
            new objectSoapStjudeOrg.InteractionFilter[] { filt }, pag, getSignature());
        System.debug('getinteractionsResponse: ' + resp);
        return resp;
    }

    public static objectSoapStJudeOrg.Attribute[] getData(String scope) {
        return getData(scope, null);
    }

    public static objectSoapStjudeOrg.Attribute[] getData(String scope, String filterName) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        objectSoapStjudeOrg.DataFilter df;
        system.debug('getData(' + scope + ', ' + filterName + ')');
        if (String.isNotBlank(filterName)) {
            df = new objectSoapStjudeOrg.DataFilter();
            df.FilterName = filterName;
        }

        cp.timeout_x = timeOutMS;
        objectSoapStjudeOrg.Attribute[] res = cp.getData(scope, df, getSignature());
        return res;
    }

    public static domainSoapStjudeOrg.Preference[] getPreferences(String consId) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();

        cp.timeout_x = timeOutMS;
        return cp.GetPreferences(null, consId, null, null, null, getSignature());
    }

    public static String editPreference(
            String consId, String prefId, String pref, String prefVal,
            String prefType, String progType, DateTime startDate, DateTime endDate, String comments,
            String status) {

        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        String ret;

        cp.timeout_x = timeOutMS;
        if (String.isNotBlank(prefId)) {
            system.debug('editPreference: edit');
            ret = cp.EditPreference(consId, null, null, prefId, pref, prefVal, prefType, 
                progType, startDate, endDate, comments, status, getSignature());
        }
        else {
            system.debug('editPreference: add');
            ret = cp.CreatePreference(consId, null, null, pref, prefVal, prefType, progType, startDate,
                endDate, comments, status, getSignature());
        }

        return ret;
    }

    public static domainSoapStjudeOrg.Property[] getProperties(String consId) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();

        cp.timeout_x = timeOutMS;
        return cp.GetProperties(null, consId, null, null, getSignature());
    }

    public static String removeProperty(String consId, String property) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        domainSoapStjudeOrg.Property p = new domainSoapStjudeOrg.Property();
        p.Property = property;

        cp.timeout_x = timeOutMS;
        return cp.RemoveProperty(consId, null, null, p, getSignature());
    }

    public static String setProperty(String consId, String property,
        String status, DateTime startDate, DateTime endDate) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        domainSoapStjudeOrg.Property p = new domainSoapStjudeOrg.Property();
        p.Property = String.isNotBlank(property) ? property : null;
        p.Status = String.isNotBlank(status) ? status : null;
        p.StartDate = StartDate ;
        p.EndDate = endDate;

        system.debug('start date: ' + startdate);
        system.debug('end date: ' + endDate);

        cp.timeout_x = timeOutMS;
        return cp.SetProperty(consId, null, null, p, getSignature());
    }

    public static domainSoapStjudeOrg.Interest[] getInterests(String consId) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();

        cp.timeout_x = timeOutMS;
        return cp.GetInterests(null, consId, null, null, getSignature());
    }

    public static String removeInterest(String consId, String interest) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        domainSoapStjudeOrg.Interest i = new domainSoapStjudeOrg.Interest();
        i.Interest = interest;

        cp.timeout_x = timeOutMS;
        return cp.RemoveInterest(consId, null, null, i, getSignature());
    }

    public static String setInterest(String consId, String interest,
        String status, String progType) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        domainSoapStjudeOrg.Interest i = new domainSoapStjudeOrg.Interest();
        i.Interest = String.isNotBlank(interest) ? interest : null;
        i.Status = String.isNotBlank(status) ? status : null;
        i.ProgramType = String.isNotBlank(progType) ? progType : null;

        system.debug('interest: ' + interest);
        system.debug('progType: ' + progType);

        cp.timeout_x = timeOutMS;
        return cp.SetInterest(consId, null, null, i, getSignature());
    }

    public static soapStjudeOrg.GetRelationshipsResponse_element getRelationships(String consId, integer startRow, Integer endRow) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        objectSoapStjudeOrg.Paginator pag = new objectSoapStjudeOrg.Paginator();
        
        pag.LowerBound = startRow;
        pag.UpperBound = endRow;
        
        cp.timeout_x = timeOutMS;
        soapStjudeOrg.GetRelationshipsResponse_element resp =  cp.GetRelationships(null, consId, null, pag, getSignature());
        return resp;
    }

     public static void createInteraction(String consId, String leadId, String contactCategory, String contactType, 
            String technique, String responseCategory, String responseType, String warning, String warningExpirationDate, 
            String longComments, String sourceCode) {
        createInteraction(consId, leadId, contactCategory, contactType, technique, responseCategory, responseType,warning,
            warningExpirationDate, longComments, sourceCode, false);
    }

    public static void createInteraction(String consId, String leadId, String contactCategory, String contactType, 
            String technique, String responseCategory, String responseType, String warning, String warningExpirationDate, 
            String longComments, String sourceCode, Boolean responseDate) {
        domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();

        if (String.isEmpty(consId)) {
            Lead l = [select id, constituentid__c, name_id__c, account_id__c from lead where id = :leadId];
            domainSoapStjudeOrg.SystemXRef xr =  ECCUtil.getXrefFromLead(l);
            domainSoapStjudeOrg.Constituent c =  C360Util.getConstituent(null, null, xr, null, 'ALL');
            consId = c.ConstituentID;
        }

        i.ContactDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        if (responseDate) {
            i.ResponseDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        }
        i.Page_x = 1;
        i.ContactCategory = contactCategory;
        i.ContactType = contactType;

        i.ResponseCategory = responseCategory;
        i.ResponseType = responseType;
        i.Warning = warning;
        i.WarningExpirationDate = warningExpirationDate;
        i.LongComments = longComments;
        if (String.isNotEmpty(technique) || String.isNotEmpty(sourceCode)) {
            i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
            i.TransactionSource.Technique = technique;
            i.TransactionSource.Code = sourceCode;
        }

        createInteraction(consId, i);
    }

    public static void createInteraction(String consId, String leadId, String contactCategory, String contactType, 
        String technique, String responseCategory, String responseType, String warning, String warningExpirationDate, String longComments){
        createInteraction(consId, leadId, contactCategory, contactType, technique, responseCategory, responseType, warning, warningExpirationDate, longComments, null, false);
    }
    
    @future(callout=true)
    public static void createInteractionFuture(String consId, String leadId, String contactCategory, String contactType, 
            String technique, String responseCategory, String responseType, String warning, String warningExpirationDate, String longComments) {
        createInteraction(consId, leadId, contactCategory, contactType, technique, responseCategory, responseType, warning, warningExpirationDate, longComments, null, false);
    }

    public static String createInteraction(String consId, domainSoapStjudeOrg.Interaction i) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        soapStjudeOrg.CreateInteractionResponse_element res;
        
        cp.timeout_x = timeOutMS;
        System.debug('CreateInteraction TA' + consId);
        res = cp.CreateInteraction(consId, null, null, null, i, getSignature());
        System.debug('res.Result = ' + res.Result);
        return res.Result;
    }

    public static String createInteractionDMS(String consId, domainSoapStjudeOrg.Interaction i) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        soapStjudeOrg.CreateInteractionResponse_element res;
        
        cp.timeout_x = timeOutMS;
        System.debug('CreateInteraction DMS' + consId);
        res = cp.CreateInteraction(consId, null, null, 'DMS', i, getSignature());
        return res.Result;
    }
    
    public static void editInteraction(String consId, String contactDate, Integer contactSeq, Integer page, String contactCategory, String contactType, 
            String technique, String responseCategory, String responseType, String sourceCode) {
        editInteraction(consId, contactDate, contactSeq, page, contactCategory, contactType, technique,
            responseCategory, responseType, sourceCode, false);
    }
    
    public static void editInteraction(String consId, String contactDate, Integer contactSeq, Integer page, String contactCategory, String contactType, 
            String technique, String responseCategory, String responseType, String sourceCode, Boolean responseDate) {
        domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();

        i.ContactDate = contactDate;
        if (responseDate) {
            System.debug('Resp Date Flag: '+responseDate);
            i.ResponseDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        }
        i.ContactSeq = contactSeq;
        i.Page_x = page;

        i.ContactCategory = contactCategory;
        i.ContactType = contactType;
        i.ResponseCategory = responseCategory;
        i.ResponseType = responseType;

        if (String.isNotEmpty(technique) || String.isNotEmpty(sourceCode)) {
            i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
            i.TransactionSource.Technique = technique;
            i.TransactionSource.Code = sourceCode;
        }

        system.debug('editInteraction consId: ' + consId);
        system.debug('editInteraction i.contactDate: ' + i.contactDate + ', Contact seq ' + i.contactSeq  + ', contCat: ' + i.contactCategory
            + ', ContType: ' + i.contactType + ', technique: ' + i.TransactionSource == null ? '' : i.TransactionSource.Technique 
            + ', respCat: ' + i.ResponseCategory + ', res type : ' + i.ResponseType
            + ', source code: ' + i.TransactionSource == null ? '' : i.TransactionSource.Code );
        editInteraction(consId, i);
    }

    public static String editInteraction(String consId, domainSoapStjudeOrg.Interaction i) {
        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        soapStjudeOrg.EditInteractionResponse_element res;
        System.debug('cp = ' + cp);
        cp.timeout_x = timeOutMS;
        res = cp.EditInteraction(consId, null, null, null, i, getSignature());
        return res.Result;
    }
}