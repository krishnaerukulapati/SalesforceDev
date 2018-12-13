public with sharing class FOConsAddLeadController {
    public String selectedRecordType {get; set;}
    public String caseId {get; private set;}
    public String consId {get; private set;}
    public String FirstName {get; set;}
    public String LastName {get; set;}
    public String MiddleName {get; set;}
    public String LongName {get; set;}
    public String Email {get; set;}
    public String EmailType {get; set;}
    public String Phone {get; set;}
    public String PhoneType {get; set;}
    public String consType {get; set;}
    public String ConStatus {get; set;}
    public Boolean Preferred {get; set;}
    public String relHousehold {get; set;}
    public String Address {get; set;}
    public String City {get; set;}
    public String State {get; set;}
    public String Zip {get; set;}
    public String AddressType {get; set;}
    public boolean foError {get; set;}
    public boolean odataLoad { get; set;}
    public Case currCase { get; set; }
    public domainSoapStjudeOrg.Constituent con {get; set;}
    public boolean isCaseSet {get; set;}
    public boolean isResearchCase { get; set;}
    public boolean isUUIDSet {get; set;}
    public String[] Constituencies {get; private set;}
    public ApexPages.StandardController sController;
    private final Lead l;
    public String TR_Id {get;set;}

    public FOConsAddLeadController(ApexPages.StandardController controller) {
        sController = controller;
        l = (Lead)controller.getRecord();
        caseId = System.currentPageReference().getParameters().get('caseId');
        consId = System.currentPageReference().getParameters().get('consId');
        getConstituent();


    }

    public List<selectOption> getRecordTypes() {
        Set<String> availableLeadTypes = new Set<String>(GetAvailableRecordTypesForProfile(Lead.SObjectType));
        system.debug('Record Types Accessible to Profile: ' + availableLeadTypes);
        List<selectOption> options = new List<selectOption>();
        for (Recordtype record : [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Lead']) {
            system.debug('Lead Record Types: ' + record);
            if (availableLeadTypes.contains(record.Name)) {
                options.add(new selectOption(record.Id, record.Name));
            }        
        }
        return options;
    }

    public static List<String> GetAvailableRecordTypesForProfile(Schema.SObjectType objType) {
        List<String> names = new List<String>();
        List<RecordTypeInfo> infos = objType.getDescribe().getRecordTypeInfos();
        if (infos.size() > 1) {
            for (RecordTypeInfo i : infos) {
                if (i.isAvailable() 
                // Ignore the Master Record Type, whose Id always ends with 'AAA'.
                && !String.valueOf(i.getRecordTypeId()).endsWith('AAA'))
                    names.add(i.getName());
            }
        } 
        else names.add(infos[0].getName());
        return names;
    }

    public void getConstituent() {
        odataLoad = false;
        system.debug('start get case: ' + Datetime.now());
        List<Case> cases = EVMUtil.getCurrCase(caseId);
        system.debug('finish get case: ' + Datetime.now());

        if (cases.size() > 0) {
            currCase = cases.get(0);
            isCaseSet = true;
        
            // see if this is a research case
            Id researchTypeId = Schema.SObjectType.Case.RecordTypeInfosByName.get('Research').RecordTypeId;
            isResearchCase = false;
            if ( currCase.recordTypeId == researchTypeId ) {
                isResearchCase = true;
            }

            system.debug(currCase.ConstituentID__c);
            if (currCase.ConstituentID__c != null) {
                isUUIDSet = true;
                Constituencies = new List<string>();
                domainSoapStjudeOrg.Constituent con;

                try {
                    system.debug('start get constituent: ' + Datetime.now());
                    con = FOUtil.getConstituent(null, currCase.ConstituentID__c, 
                        new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'PREFERENCES'}, 
                            currCase.ConstituentType__c);

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
                            FirstName = pi.first_name__c;
                            LastName = pi.last_name__c;
                            MiddleName = pi.middle_name__c;
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
                if (con != null) {
                    consId = con.ConstituentId;
                    system.debug('start');
                    system.debug('con.Type_x.Code: ' + con.Type_x.Code);
                    ConsType = con.Type_x.Code;
                    system.debug('con.Status: ' + con.Status);
                    ConStatus = con.Status;
                    if (currCase.ConstituentType__c == 'INDIVIDUAL') {
                        FirstName = con.FirstName;
                        LastName = con.LastName;
                        MiddleName = con.MiddleName;
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
                                (string.isNotBlank(a.Street3) ? a.Street3 + '\n' : '');

                            City = (string.isNotBlank(a.City) ? a.City : '');
                            State = (string.isNotBlank(a.State) ? a.State : '');
                            Zip = (string.isNotBlank(a.ZipCode) ? a.ZipCode : '');

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

                    //search constituent info for P2PId if it exists
                    system.debug('start get getConstituentXRefs: ' + Datetime.now());
                    List<domainSoapStjudeOrg.SystemXRef> conXref = FOUtil.getConstituentXRefs(consId, '');
                    system.debug('finish get getConstituentXRefs: ' + Datetime.now());

                    for(domainSoapStjudeOrg.SystemXRef xrCon : conXref) {
                        if (xrCon.Sys != null && xrCon.Sys.Name != null) {
                            if (xrCon.Sys.Name == 'Luminate') {
                                TR_Id = xrCon.XRefKey;
                                system.debug('P2PId: ' + xrCon.XRefKey);
                            }
                        }
                    }
                }
            }
        }
        else isCaseSet = false;
        system.debug('finish: ' + Datetime.now());
    }

    public PageReference prepopulateValues() {
        System.debug('RecordTypeID: ' + selectedRecordType);

        //Lead l = new Lead();      

        if (consType == 'INDIVIDUAL') {
            l.Company = 'NA';//Company name, required
            
        }
        else if (consType == 'HOUSEHOLD') {
            l.LastName = LongName;
            l.Company = 'NA';//Company name, required
        }
        else {
            l.Company = LongName;//required
            l.LastName = LongName;
        }

        l.ConstituentID__c = consId;
        if (LastName != null && String.isNotEmpty(LastName)) l.LastName = LastName;         //required
        if (FirstName != null && String.isNotEmpty(FirstName)) l.FirstName = FirstName;
        if (MiddleName != null && String.isNotEmpty(MiddleName)) l.MiddleName = MiddleName;
        if (Phone != null && String.isNotEmpty(Phone)) l.Phone = Phone;
        if (PhoneType != null && String.isNotEmpty(PhoneType)) l.Pref_phone_type__c = PhoneType.substring(0, 1);
        if (Address != null && String.isNotEmpty(Address)) l.MailingAddress1__c = Address;
        if (City != null && String.isNotEmpty(City)) l.MailingZip__c = City;
        if (State != null && String.isNotEmpty(State)) l.MailingState__c = State;
        if (Zip != null && String.isNotEmpty(Zip)) l.MailingZip__c = Zip;
        if (consType != null && String.isNotEmpty(consType)) l.Constituent_Type__c = consType;
        l.RecordTypeId = selectedRecordType;

        //add P2PId to Lead
        if (TR_Id != null && String.isNotEmpty(TR_Id)) l.TR_ID__c = TR_Id;

        selectedRecordType = '';
        sController.save();        
        PageReference pr = sController.edit();
        System.debug('Lead ID: ' + l.Id);
        System.debug(pr);

        return pr;
    }
}