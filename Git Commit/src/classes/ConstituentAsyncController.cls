public with sharing class ConstituentAsyncController {
        public boolean c360Error {get; private set;}
        public boolean isConsLoaded { get; private set; }
        //public boolean hasRevNotes {get; set;}
        public String consId {get; private set;}
        //public Case currCase { get; private set; }
        public String ConStatus {get; private set;}
    	public Boolean Preferred {get; private set;}
      	public String Title {get; private set;}
	    public String FirstName {get; private set;}
	    public String LastName {get; private set;}
	    public String LongName {get; private Set;}
	    public String Phone {get; private set;}
	    public String PhoneType {get; private set;}
	    public String Address {get; private set;}
	    public String AddressType {get; private set;}
	    public String Staff {get; private set;}
        public String Email {get; private set;}
    	public String EmailType {get; private set;}
        public Boolean hasWarnings {get; private Set;}
    	public String warnings {get; private Set;}
        public String Deceased {get; private set;}
        public String ConsType {get; private set;}
        //public String pledgeId {get; private Set;}
        public boolean isVIP {get; private Set;}
        public String[] Constituencies {get; private set;}
        public String caseId {get; private set;}
        public boolean reload {get; set;}
        public boolean isResearchCase { get; private set; } 
        public boolean isCaseSet {get; private Set;}
        public String relId {get; private set;}
    	public boolean isUUIDSet {get; private set;}

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
        Integer TIMEOUT_INT_SECS = 60;
        AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture consResponse;
   		AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture xrefResponse;
    
        public ConstituentAsyncController() { 
	    	isConsLoaded = false;
	        relId = System.currentPageReference().getParameters().get('relId');
	    }

        public Continuation reLoad() {
	        system.debug('start: ' + Datetime.now());
            system.debug('relId: ' + relId);
            system.debug('consId: ' + consId);
        	isConsLoaded = false;
	    	Continuation cont = null;
	        //caseId = System.currentPageReference().getParameters().get('id');
	        //List<Case> cases = ECCUtil.getCurrCase(caseId);
            string rel = System.currentPageReference().getParameters().get('reload');
        	if (String.isNotBlank(rel)) reload = Boolean.valueOf(rel);


            if (consId != null) {
                isUUIDSet = true;
                Constituencies = new List<string>();

                system.debug('start get constituent: ' + Datetime.now());
                
                cont = new Continuation(TIMEOUT_INT_SECS);
                cont.continuationMethod = 'gotConstituent';
                isConsLoaded = false;

                consResponse = AsyncC360Util.getConstituent(cont, null, consId, 
                    new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 
                    'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES'}, 
                    ConsType);
            }


	        system.debug('finish: ' + Datetime.now());
	        return cont;
        }
    
       public Object gotConstituent() {
    	system.debug('gotConstituent: ' + Datetime.now());  
		domainSoapStjudeOrg.Constituent con = consResponse.getValue().Constituent;
    	Continuation cont = null;

        System.debug(' con in try = ' + con);

        system.debug('finish get constituent: ' + Datetime.now());            
        //c360Error = false;

        if (con != null) {
            //List<ConstituentRevenueNotes__x> conRevNotes = OdataExtension.GetRevenueNotes(con.ConstituentID, 0, 1);
            //hasRevNotes = conRevNotes.size() > 0;
            consId = con.ConstituentId;
            system.debug('start');
            ConsType = con.Type_x.Code;
            ConStatus = con.Status;
            if (ConsType == 'INDIVIDUAL') {
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
            system.debug('Constituencies');

            //pledgeId = C360Util.getPledgeId(consId);
            //pledgeId = '';
            //system.debug('pledgeId');
            
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

            isConsLoaded = true;

        }
        return null;
    }
}