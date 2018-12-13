public with sharing class C360ConstituentAddressEditController {
    public String streetNumber {get; set;}
    public String streetName {get; set;}
    public String street1 {get; set;}
    public String street2 {get; set;}
    public String street3 {get; set;}
    public String city {get; set;}
    public String state {get; set;}
    public String country {get; set;}
    public String zipCode {get; set;}
    public String zipExtension {get; set;}
    public boolean preferred {get; set;}
    public String status {get; set;}
    public String comments {get; set;}
    public String addressTypeCode {Get; Set;}
    public String contId {get; private set;}
    public String consId {get; private set;}
    public String relId {get; private set;}
    public String leadType {get; private set;}
    public ECCutil.consInfo ci {get; private set;}
    public String contactType {get; private Set;}
    public String firstName {get; private Set;}
    public String lastName {get; private Set;}
    public boolean foundAddress {get; private set;}
    public boolean bNew {get; private set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();
    
    public C360ConstituentAddressEditController(ApexPages.StandardController controller) {
        init();   
    }

    public C360ConstituentAddressEditController() {
        init();   
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        leadType = System.currentPageReference().getParameters().get('leadType');
        if (String.isBlank(leadType)) leadType = 'ORG';
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId, leadType);

        system.debug('constituent id: ' + ci.consId);
        bNew = true;
        if (ci.consId != null) {
            contId = System.currentPageReference().getParameters().get('contId');
            consId = System.currentPageReference().getParameters().get('consId');

            system.debug('consId: ' + consId);

            domainSoapStjudeOrg.Constituent con = C360Util.getConstituent(null, consId, new string[] {'PROFILE'}, 'ALL');
            firstName = con.firstName;
            lastName = con.lastName;
            
            if (String.isNotBlank(contId)) {
                if (con != null && con.Profile != null && con.Profile.Addresses != null && con.Profile.Addresses.size() > 0) {
                    for (domainSoapStjudeOrg.Address a : con.Profile.Addresses) {
                        if (a.ContactID == contId) {
                            LoadAddress(a);
                        }
                    }
                }
            }
            else {
                country = 'USA';
            }
        }
        else {
            country = 'USA';
        }
    }
    
    private void LoadAddress(domainSoapStjudeOrg.Address a) {
        streetNumber = a.streetNumber;
        streetName = a.streetName;
        street1 = a.street1;
        street2 = a.street2;
        street3 = a.street3;
        city = a.city;
        state = a.state;
        country = a.country;
        zipCode = a.zipCode;
        zipExtension = a.zipExtension;
        preferred = a.preferred;
        status = a.status;
        comments = a.comments;
        addressTypeCode = a.AddressType.Code;
        contactType = a.ContactType;
        foundAddress = true;
        bNew = false;
        listValuesForCompare(before);
    }
    
    public PageReference cancel() {
        PageReference pr = Page.C360AddressDetail;
        pr.getParameters().put('id', relId);
        pr.getParameters().put('leadType', leadType);
        return pr;
    }
    
    public PageReference save() {
        PageReference pr;
        if (validateForm()) {
            pr = Page.C360AddressDetail;
            domainSoapStjudeOrg.Individual i = new domainSoapStjudeOrg.Individual();
            domainSoapStjudeOrg.Profile p = new domainSoapStjudeOrg.Profile();
            domainSoapStjudeOrg.Address a = new domainSoapStjudeOrg.Address();
            domainSoapStjudeOrg.TypeAttribute at = new domainSoapStjudeOrg.TypeAttribute();
            
            String res = '';
            
            i.ConstituentID = consId;
            i.FirstName = firstName;
            i.LastName = lastName;
            at.Code = addressTypeCode;
            if (String.isNotEmpty(contId)) {
                a.ContactId = contId;
                a.ContactType = contactType;
            }
            
            a.street1 = street1;
            a.street2 = street2;
            a.street3 = street3;
            a.city = city;
            a.state = state;
            system.debug('state: ' + state + ', a.state: ' + a.state);
            a.country = country;
            a.zipCode = zipCode;
            a.zipExtension = zipExtension;
            a.preferred = preferred;
            a.status = status;
            a.comments = comments;
            
            a.AddressType = at;
            p.Addresses = new domainSoapStjudeOrg.Address[] {a};
            i.Profile = p;
            
            System.debug(i);
            
            res = C360Util.EditConstituent(i, null, null, ci.technique);
            
            System.debug(res);
            
            listValuesForCompare(after);

            ECCUtil.createTask(ci, bNew ? 'Address Add' : 'Address Edit', 'Completed', contId, before, after);
            
            pr.getParameters().put('id', relId);
            pr.getParameters().put('leadType', leadType);
        }
        return pr;
    }

    private boolean validateForm() {
        boolean valid = true;

        if(String.isBlank(addressTypeCode)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Type is required.'));
            valid = false;
        }
        if(String.isBlank(status)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
            valid = false;
        }
        if(String.isBlank(street1)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Street1 is required.'));
            valid = false;
        }
        if(String.isBlank(city)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'City is required.'));
            valid = false;
        }
        if(String.isBlank(state)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'State is required.'));
            valid = false;
        }
        if(String.isBlank(zipCode)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Zip Code is required.'));
            valid = false;
        }
        if(String.isBlank(country)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Country is required.'));
            valid = false;
        }
        return valid;
    }

    public LIST<SelectOption> getAddrTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('ADDRESS_TYPES')); 
    }

    public LIST<SelectOption> getCountries() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('COUNTRIES')); 
    }

    public LIST<SelectOption> getStates() {
        if(String.isNotBlank(country))
            return ECCUtil.getSelectFromC360Att(C360Util.getData('STATES', country), false); 
        else 
            return null;
    }

    public LIST<SelectOption> getStatusTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('STATUS_TYPES')); 
    }

    public void listValuesForCompare(List<String> vals) {
        vals.add(String.format('{0} = {1}', new String[] {'Street Number', streetNumber == null ? '' : streetNumber}));
        vals.add(String.format('{0} = {1}', new String[] {'street Name', streetName == null ? '' : streetName}));
        vals.add(String.format('{0} = {1}', new String[] {'Street1', street1 == null ? '' : street1}));
        vals.add(String.format('{0} = {1}', new String[] {'Street2', street2 == null ? '' : street2}));
        vals.add(String.format('{0} = {1}', new String[] {'Street3', street3 == null ? '' : street3}));
        vals.add(String.format('{0} = {1}', new String[] {'City', city == null ? '' : city}));
        vals.add(String.format('{0} = {1}', new String[] {'State', state == null ? '' : state}));
        vals.add(String.format('{0} = {1}', new String[] {'Country', country == null ? '' : country}));
        vals.add(String.format('{0} = {1}', new String[] {'Zip Code', zipCode == null ? '' : zipCode}));
        vals.add(String.format('{0} = {1}', new String[] {'Zip Extension', zipExtension == null ? '' : zipExtension}));
        vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
        vals.add(String.format('{0} = {1}', new String[] {'Comments', comments == null ? '' : comments}));
        vals.add(String.format('{0} = {1}', new String[] {'Address Type', addressTypeCode == null ? '' : addressTypeCode}));
        vals.add(String.format('{0} = {1}', new String[] {'Preferred', string.valueOf(preferred)}));
    }

    public void changeCountry() {
        
    }
}