public with sharing class FOConstituentAddController {
    //Basic
    public String titleCode {get; Set;}
    public String scope {get; Set;}
    public String firstName {get; Set;}
    public String lastName {get; Set;}
    public String middleName {get; Set;}
    public String suffixCode {Get; Set;}
    public String name {get; Set;}
    public String birthDate {get; Set;}
    public Boolean preferred {Get; Set;}

    //address
    public String street1 {get; set;}
    public String street2 {get; set;}
    public String street3 {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String country {get; set;}
    public String zipCode {get; set;}
    public String zipExtension {get; set;}
    public String addStatus {get; set;}
    public String addComments {get; set;}
    public String addressTypeCode {Get; Set;}

    //Phone
    public String phoneNumber {get; Set;}
    public String phStatus {get; set;}
    public String phComments {get; set;}
    public String phoneTypeCode {Get; Set;}

    //Email
    public String email {get; Set;}
    public String eStatus {get; set;}
    public String eComments {get; set;}
    public String emailTypeCode {get; set;}

    public String uUID {get; private set;}
    public String contId {get; private set;}
    public String consId {get; private set;}
    public String relId {get; private set;}
    public EVMUtil.consInfo ci {get; private set;}
    public String relConsId {get; private set;}
    public String relConsType {get; private set;}
    public String leadChangeCoord {get; private set;}
    public String campAddReferral {get; private set;}
    public String mode {get; private set;}

    public LIST<SelectOption> AddrTypes;
    public LIST<SelectOption> Countries;
    public LIST<SelectOption> StatusTypes;
    public LIST<SelectOption> PhoneTypes;
    public LIST<SelectOption> Titles;
    public LIST<SelectOption> Suffixes;
    public LIST<SelectOption> EmailTypes;

    private boolean addSet = false;
    private boolean eSet = false;
    private boolean pSet = false;
    private boolean rSet = false;

    private Case emailCase;
    
    public FOConstituentAddController(ApexPages.StandardController controller) {
        system.debug('FOConstituentAddController(ApexPages.StandardController controller');
        init();
    }

    public FOConstituentAddController() {
        system.debug('FOConstituentAddController()...');
        init();
    }

    public void init() {
        relId = ApexPages.currentPage().getParameters().get('relId');
        relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        relConsType = ApexPages.currentPage().getParameters().get('relConsType');
        leadChangeCoord = ApexPages.currentPage().getParameters().get('leadChangeCoord');
        campAddReferral = ApexPages.currentPage().getParameters().get('campAddReferral');
        mode = ApexPages.currentPage().getParameters().get('mode');

        system.debug('FOConstituentAddController in init, relId: ' + relId + ', relConsId: ' + relConsId
            + 'relConsType: ' + relConsType );
        
        if (String.isNotEmpty(relId)) {
            ci = EVMUtil.getConsInfo(relId);
            system.debug('after getConsInfo, relId: ' + relId + ', technique' + ci.technique + ', object type' + ci.objectType);
            if (ci.objectType == 'Case') {
                emailCase = EVMUtil.getCurrCase(relId).get(0);
                if(String.isNotBlank(emailCase.SuppliedEmail)) {
                    email = emailCase.SuppliedEmail;
                }
            }
        }
        country = 'USA';
        scope = 'INDIVIDUAL';
    }
    
    public PageReference cancel() {
        PageReference pr = Page.FOSearch;

        if (String.isNotBlank(relConsId)) {
            pr = Page.FORelationshipDetail;
        }
        pr.getParameters().put('mode', 'rEsEaRcH');
        pr.getParameters().put('id', relId);
        return pr;
    }
    
    public PageReference save() {
        PageReference pr;
        if (validateForm()) {
            pr = Page.FOAddressDetail;
            domainSoapStjudeOrg.Individual i;
            domainSoapStjudeOrg.Household h;
            domainSoapStjudeOrg.Organization o;
            domainSoapStjudeOrg.Profile p = new domainSoapStjudeOrg.Profile();
            domainSoapStjudeOrg.Address a = new domainSoapStjudeOrg.Address();
            domainSoapStjudeOrg.TypeAttribute at = new domainSoapStjudeOrg.TypeAttribute();
            domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
            domainSoapStjudeOrg.Email e = new domainSoapStjudeOrg.Email();
            domainSoapStjudeOrg.TypeAttribute title = new domainSoapStjudeOrg.TypeAttribute();
            domainSoapStjudeOrg.TypeAttribute suffix = new domainSoapStjudeOrg.TypeAttribute();
            domainSoapStjudeOrg.TypeAttribute et = new domainSoapStjudeOrg.TypeAttribute();
            domainSoapStjudeOrg.TypeAttribute pt = new domainSoapStjudeOrg.TypeAttribute();

            domainSoapStjudeOrg.Constituent res;
            
            system.debug('scope in save:' + scope);
            if (scope.toUpperCase() == 'INDIVIDUAL') {
                i = new domainSoapStjudeOrg.Individual();
            }
            if (scope.toUpperCase() == 'HOUSEHOLD') {
                h = new domainSoapStjudeOrg.Household();
            } 
            if (scope.toUpperCase() == 'ORGANIZATION') {
                o = new domainSoapStjudeOrg.Organization();
            }

            //basic
            if (scope.toUpperCase() == 'INDIVIDUAL') {
                i.FirstName = firstName;
                i.LastName = lastName;
                i.MiddleName = middleName;
                i.Preferred = preferred;

                if (birthDate != '') {
                    domainSoapStjudeOrg.IndividualAttributes ia = new domainSoapStjudeOrg.IndividualAttributes();
                    ia.BirthDate = birthDate;
                    i.IndividualAttributes = ia;
                }

                title.Code = titleCode;
                if(titleCode != 'NT') 
                    title.Code = titleCode;
                else
                    title.Code = '';
                    
                i.Title = title;

                suffix = new domainSoapStjudeOrg.TypeAttribute();
                if(String.isNotEmpty(suffixCode)) suffix.Code = suffixCode;
                i.Suffix = suffix;
                i.Type_x = new domainSoapStjudeOrg.TypeAttribute();
                i.Type_x.Code = 'INDIVIDUAL';
            }
            else if (scope.toUpperCase() == 'HOUSEHOLD') {
                h.Name = name;
                h.Type_x = new domainSoapStjudeOrg.TypeAttribute();
                h.Type_x.Code = 'HOUSEHOLD';
            }
            else if (scope.toUpperCase() == 'ORGANIZATION') {
                o.Name = name;
                o.Type_x = new domainSoapStjudeOrg.TypeAttribute();
                o.Type_x.Code = 'ORGANIZATION';
            }

            //address
            if (addSet) {
                system.debug('address set: ' + addSet);
                at.Code = addressTypeCode;
                
                a.street1 = street1;
                a.street2 = street2;
                a.street3 = street3;
                a.city = city;
                a.state = state;
                a.country = country;
                a.zipCode = zipCode;
                a.zipExtension = zipExtension;
                a.preferred = true;
                a.status = addStatus;
                a.comments = addComments;
                
                a.AddressType = at;
                p.Addresses = new domainSoapStjudeOrg.Address[] {a};
            }

            //Email
            if (eSet) {
                system.debug('email set: ' + eSet);
                e.Preferred = true;
                e.ContactType = 'E';
                et.Code = emailTypeCode;

                e.EmailAddress = email;
                e.status = eStatus;
                e.comments = eComments;
                
                e.EmailType = et;
                p.Emails = new domainSoapStjudeOrg.Email[] {e};
            }

            //Phone
            if (pSet) {
                system.debug('phone set: ' + pSet);
                pt.Code = phoneTypeCode;
                ph.ContactType = 'P';
                ph.Preferred = true;
                ph.PhoneNumber = EVMUtil.formatPhone(phoneNumber);
                ph.status = phStatus;
                ph.comments = phComments;
                
                ph.PhoneType = pt;
                p.Phones = new domainSoapStjudeOrg.Phone[] {ph};
            }

            //Relationship
            if (String.isNotBlank(relConsId) && scope.toUpperCase() == 'INDIVIDUAL' && relConsType == 'HOUSEHOLD') {
                rSet = true;
                addRelationship(i);
            }
            EVMUtil.SSLeads currLead;
            String technique;

            if (String.isNotBlank(leadChangeCoord)) {
                currLead = EVMUtil.getCurrLead(leadChangeCoord);
                technique = currLead.SSLead.Technique_Method__c;
            }
            else if (ci != null) {
                technique = ci.technique;
            }
            else {
                technique = 'CF';
            }

            if (scope.toUpperCase() == 'INDIVIDUAL') {
                i.Profile = p;
                res = FOUtil.CreateConstituent(i, null, null, technique);

                /*temporary awfulness.  Currently preferred isn't being property set on create
                // to be fixed in the next release of FO.  Until then, we have to edit the constituent
                // to set the preferred status ugh, lame, ugh :(
                */
                if (rSet) {
                    String lName = i.LastName;
                    i = new domainSoapStjudeOrg.Individual();
                    i.ConstituentID = res.ConstituentID;
                    i.LastName = lName;
                    i.Preferred = preferred;
                    FOUtil.editConstituent(i, null, null, technique);
                }
            }
            else if (scope.toUpperCase() == 'HOUSEHOLD') {
                h.Profile = p;
                res = FOUtil.CreateConstituent(null, h, null, technique);
            }
            else if (scope.toUpperCase() == 'ORGANIZATION') {
                o.Profile = p;
                res = FOUtil.CreateConstituent(null, null, o, technique);
            }
            
            System.debug(i);
            
            //res should be the new constituent id
            System.debug(res.ConstituentId);
            if (String.isNotBlank(leadChangeCoord)) {
                currLead = EVMUtil.getCurrLead(leadChangeCoord);
                EVMUtil.ReplaceCoordinator(currLead, res.ConstituentId);
                pr = new PageReference('/Apex/RecruitEvent?id=' + leadChangeCoord);
                pr.setRedirect(true);
                system.debug(pr.getUrl());
            }
            else if (String.isNotEmpty(campAddReferral)) {
                system.debug('adding lead referral!');
                pr = Page.ECCAddLeadToCampaign;
                String consName = name;
                if (scope.toUpperCase() == 'Individual') {
                    consName = firstName + ' ' + middleName + ' ' + lastName;
                }
                pr.getParameters().put('consId', res.ConstituentId);
                pr.getParameters().put('campAddReferral', campAddReferral);
                pr.getParameters().put('consType', scope);
                pr.getParameters().put('consName', consName);
                return pr;
            }
            else if (ci != null) {
                if (ci.objectType == 'Case') {
                    pr = openCase(res); //.getParameters().put('id', relId);
                }
                else {
                    EVMUtil.createTask(ci, 'Relationship Add', 'Completed', relConsId, null, null);
                    pr = cancel();
                }
            }
            else { //assume new case constituent
                pr = openCase(res);
            }
        }
        return pr;
    }

    PageReference openCase(domainSoapStjudeOrg.Constituent con) {
        String destination = '';
        String consName = FirstName + ' ' + LastName;
        Case c;
        Boolean isEmailCase = false; //get this
        if (rSet) {
            system.debug('adding relationship - new: ' + con.ConstituentID + ', existing: ' + relConsId);
            EVMUtil.createTask(relId, 'Relationship Add', 'Completed', relConsId, null, null);
            isEmailCase = false;
            c = emailCase;
            destination = '/Apex/FORelationshipDetail?id=';
        }
        else {
            if (emailCase == null) {
                c = new Case();
                if (String.isNotEmpty(mode) && mode.toLowerCase() == 'research') {
                    c.Origin = 'Research';
                    c.Status = 'Closed';
                    c.Subject = 'Research - ' + UserInfo.getName();
                }
                else {
                    c.Origin = 'Phone';
                    c.Subject = 'Inbound Call - ' + consName;
                }
                destination = '/Apex/FOOpenConsole?cid=';
            }
            else {
                c = emailCase;
                isEmailCase = true;
                destination = '/Apex/FOCloseRefresh';
            }
            c.ConstituentID__c = con.ConstituentID;
            c.Constituent_Name__c = consName;
            c.ConstituentType__c = scope.toUpperCase();

            //get the constituent ids
            LIST<String> consIds = new List<String> {c.ConstituentID__c};
            //FOUtil.getConstituentIds(c.ConstituentUUID__c); 

            //domainSoapStjudeOrg.Constituent con = FOUtil.getConstituent(c.ConstituentUUID__c , null, null);
            
            //temporary - set the ConstituentUUID = the preferred constituent id
            //c.ConstituentUUID__c = con.ConstituentID;
            
            upsert c;
            EVMUtil.createTask(c.Id, 'Constituent Add', 'Completed', con.ConstituentID, null, null);

            //create the constituent informations to house the constituent ids for this uuid upon selection
            EVMUtil.createConstituentInfos(consIds, null, c.Id, con.ConstituentID);
        }

        System.debug(c.id);
        system.debug('destination: ' + destination + (isEmailCase ? '' : c.Id));
        PageReference detail = new PageReference(destination + (isEmailCase ? '' : c.Id)); // new ApexPages.StandardController(c).view();
        detail.setRedirect(true);
        return detail;
    }

    private void addRelationship(domainSoapStjudeOrg.Individual i) {
        system.debug('addRelationship - consId: ' + consId);
        domainSoapStjudeOrg.Relationship rel = new domainSoapStjudeOrg.Relationship();
        domainSoapStJudeOrg.Constituent h = new domainSoapStjudeOrg.Constituent();
        
        h.ConstituentID = relConsId;
        
        rel.Type_x = new domainSoapStjudeOrg.TypeAttribute();
        rel.Type_x.Code = 'Individual'; //only allowed to add individuals to households
        rel.ReciprocalType = new domainSoapStjudeOrg.TypeAttribute();
        rel.ReciprocalType.Code = 'Household'; //only allowed to add individuals to households
        rel.RelatedConstituent = h;
        i.Relationships = new domainSoapStjudeOrg.Relationship[] { rel };
        i.RelatedHousehold = new domainSoapStjudeOrg.RelatedHousehold();
        i.RelatedHousehold.ConstituentId = relConsId;
    }

    private boolean validateForm() {
        boolean valid = true;
        eSet = false;
        addSet = false;
        pSet = false;
        Pattern emailPattern = Pattern.Compile('^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,6})$');
        Pattern isnumbers = Pattern.Compile('^[0-9]{10}$');

        if (String.isNotBlank(addressTypeCode) || String.isNotBlank(addStatus) || String.isNotBlank(street1) ||
            String.isNotBlank(city) || String.isNotBlank(state) || String.isNotBlank(zipCode) ||
            String.isNotBlank(street2) || String.isNotBlank(street3) ||
            String.isNotBlank(zipExtension) || String.isNotBlank(addComments))
            addSet = true;

        if (String.isNotBlank(phoneNumber) || String.isNotBlank(phStatus) || String.isNotBlank(phoneTypeCode) ||
            String.isNotBlank(phComments))
            pSet = true;    

        if (String.isNotBlank(email) || String.isNotBlank(eStatus) || String.isNotBlank(emailTypeCode) ||
            String.isNotBlank(eComments))
            eSet = true;    

        //basic
        if (scope == 'INDIVIDUAL') {
            if(String.isBlank(firstName)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'First Name is required.'));
                valid = false;
            }
            if(String.isBlank(lastName)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last Name is required.'));
                valid = false;
            }
        }
        else {
        system.debug('scope==='+scope);
            if(String.isBlank(name)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name is required.'));
                valid = false;
            }
        }

        //address
        if (addSet) {
            if(String.isBlank(addressTypeCode)) { 
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, Type is required.'));
                valid = false;
            }
            if(String.isBlank(addStatus)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, Status is required.'));
                valid = false;
            }
            if(String.isBlank(street1)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, Street1 is required.'));
                valid = false;
            }
            if(String.isBlank(city)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, City is required.'));
                valid = false;
            }
            if(String.isBlank(state)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, State is required.'));
                valid = false;
            }
            if(String.isBlank(zipCode)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, Zip Code is required.'));
                valid = false;
            }
            if(String.isBlank(country)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Address provided, Country is required.'));
                valid = false;
            }
        }

        if(eSet) {
            if( String.isBlank(email) || (String.isNotBlank(email) && !emailPattern.matcher(email).Matches())) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Email provided, Email must be a valid email address.'));
                valid = false;
            }
            if(String.isBlank(emailTypeCode)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Email provided, Type is required.'));
                valid = false;
            }
            if(String.isBlank(eStatus)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Email provided, Status is required.'));
                valid = false;
            }
        }

        if (pSet) {
            if(String.isNotBlank(phoneNumber) && !isnumbers.matcher(EVMUtil.deFormatPhone(phoneNumber)).Matches()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Phone Number must be 10 digits and numeric.'));
                valid = false;
            }
            if(String.isBlank(phoneTypeCode)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Phone Number provided, Type is required.'));
                valid = false;
            }
            if(String.isBlank(phStatus)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'If Phone Number provided, Status is required.'));
                valid = false;
            }
        }

        if (!addSet && ! eSet && ! pSet) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'First Name, Last Name and one of Address, Phone or Email must be provided.'));
            valid = false;
        }

        system.debug('valid: ' + valid + ', addSet: ' + addSet + ', eSet: ' + eSet + ', pSet: ' + pSet);
        return valid;
    }

    public LIST<SelectOption> getAddrTypes() {
        if (AddrTypes == null) AddrTypes = EVMUtil.getSelectFromFOAtt(FOUtil.getData('ADDRESS_TYPES')); 
        return AddrTypes;
    }

    public LIST<SelectOption> getCountries() {
        if (Countries == null) Countries = EVMUtil.getSelectFromFOAtt(FOUtil.getData('COUNTRIES')); 
        return Countries;
    }

    public LIST<SelectOption> getStatusTypes() {
        if (StatusTypes == null) StatusTypes = EVMUtil.getSelectFromFOAtt(FOUtil.getData('STATUS_TYPES')); 
        return StatusTypes;
    }

    public LIST<SelectOption> getPhoneTypes() {
        if (PhoneTypes == null) PhoneTypes = EVMUtil.getSelectFromFOAtt(FOUtil.getData('PHONE_TYPES')); 
        return PhoneTypes;
    }
    
    public LIST<SelectOption> getTitles() {
        if (Titles == null) Titles = EVMUtil.getSelectFromFOAtt(FOUtil.getData('TITLES')); 
        return Titles;
    }
    
    public LIST<SelectOption> getSuffixes() {
        if (Suffixes == null) Suffixes = EVMUtil.getSelectFromFOAtt(FOUtil.getData('SUFFIXES')); 
        return Suffixes;
    }
    
    public LIST<SelectOption> getEmailTypes() {
        if (EmailTypes == null) EmailTypes = EVMUtil.getSelectFromFOAtt(FOUtil.getData('EMAIL_TYPES')); 
        return EmailTypes;
    }

    public LIST<SelectOption> getStates() {
        return EVMUtil.getSelectFromFOAtt(FOUtil.getData('STATES', country), false); 
    }

    public void changeCountry() {
        
    }
}