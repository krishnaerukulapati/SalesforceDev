public without sharing class FOSearchMobileController {
	public String phone {get; set;}
	public String address1 {get; set;}
	public String address2 {get; set;}
	public String name {get; set;}
	public String firstName {get; set;}
	public String lastName {get; set;}
	public String zip {get; set;}
	public String city {get; set;}
	public String state {get; set;}
	public String donorId {get; set;}
	public String p2pId {get; set;}
	public String pledgeId {get; set;}
	public String dmsId {get; set;}
	public String altId {get; set;}
	public String searchScope {get; set;}
	public String email {get; Set;}
	public Boolean isChat {get; private set;}
	public String cid {get; private Set;}
	public String relConsId {get; private set;}
	public String relConsType {get; private set;}
	public String sortOrder {get; set;}
	public String callId {get; private set;}
	public String leadChangeCoord {get; private set;}
	public String campAddReferral {get; private set;}
	public String LongName {get; private set;}
	public String ConsAddress {get; private set;}
	public String ConsPhone {get; private set;}
	public String ConsEmail {get; private set;}
	public String selectConsId {get; set;}
	public String taAccount {get; private set;}
	public Boolean hasTaAccount {get; private set;}
	public domainSoapStjudeOrg.Constituent selCon {get; private set;}
	//public String appl {get; private set;}
	public String mode {get; private set;}
	public domainSoapStjudeOrg.SystemXRef[] Xrefs {get; private set;}
	public Integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	private Integer pageSize = 20;
	private Integer PHONE_IDX = 0, ADD1_IDX = 1, ADD2_IDX = 2, NAME_IDX = 3,
	LNAME_IDX = 4, FNAME_IDX = 5, ZIP_IDX = 6, CITY_IDX = 7, STATE_IDX = 8,
	DON_IDX = 9, PLEDGE_IDX = 10, ALT_IDX = 11, EMAIL_IDX = 12, SCOPE_IDX = 13, P2PID_IDX = 14;
	
	private Case emailCase;
	public List<objectSoapStjudeOrg.SearchResponse> sr = new List<objectSoapStjudeOrg.SearchResponse>();

	public String getDMSId(String consId) {
		List<domainSoapStjudeOrg.SystemXRef> conXref = new List<domainSoapStjudeOrg.SystemXRef>();
		conXref = FOUtil.getConstituentXRefs(consId, 'DMS');
		if (!conXref.isEmpty()) {
			if (conXref[0].Sys != null && conXref[0].Sys.Name != null) {
				return conXref[0].AlternateXRefKey;
			}
			else {
				return 'N/A';
			}
		}
		else {
			return 'N/A';
		}		
	}   	
	
	public Boolean getFirstPage() {
		return currPage == 1;
	}
	
	public Boolean getLastPage() {
		return currPage == totalPages;
	}
	
	public Boolean getResultsFound() {
		return (sr.size() > 0);
	}

	public Boolean getConsSelected() {
		return (selCon != null);
	}
	
	public List<objectSoapStjudeOrg.SearchResponse> getSr() {
		return sr;
	}

	private void setSr(soapStjudeOrg.SearchConstituents360Response_element newSr) {
		if (newSr.Constituents != null && newSr.Constituents.size() > 0) {
			system.debug('Total returned constituents: ' + newSr.Constituents.size());
			sr = newSr.Constituents;
			//If system is DMS, replace MDM ID with DMS lookupID
			for (Integer i = 0; i < sr.size(); i++) {
				for (Integer j = 0; j < sr[i].SystemXRefs.SystemXRef.size(); j++) {
					if (sr[i].SystemXRefs.SystemXRef[j].Sys.Name == 'DMS'){
						System.debug(' calling getDMSId(' +sr[i].ConstituentID + ')');
						dmsId = getDMSId(sr[i].ConstituentID);
						System.debug('DMS ID: ' + dmsId);
						if (String.isNotEmpty(dmsId)) sr[i].SystemXRefs.SystemXRef[j].XRefKey = dmsId;
					}
					if (sr[i].SystemXRefs.SystemXRef[j].Sys.Name == 'TA'){
						taAccount = sr[i].SystemXRefs.SystemXRef[j].XRefKey;
					}
				}
			}

			if (totalPages == 0)
			totalPages = integer.valueOf(string.valueOf(Math.ceil(newSr.TotalResults / Double.ValueOf(pageSize))));
			
			System.debug('TotalResults' + String.valueOf(newSr.TotalResults));
		}
		else {
			currPage = 1;
			totalPages = 0;
			sr = new List<objectSoapStjudeOrg.SearchResponse>();
		}
	}

	public FOSearchMobileController() {
		phone = ApexPages.currentPage().getParameters().get('ani');
		cid = ApexPages.currentPage().getParameters().get('cid');
		callId = ApexPages.currentPage().getParameters().get('callid');
		mode = ApexPages.currentPage().getParameters().get('mode');

		//appl = ApexPages.currentPage().getParameters().get('appl');
		relConsId = ApexPages.currentPage().getParameters().get('relConsId');
		relConsType = ApexPages.currentPage().getParameters().get('relConsType');
		String isAChat = System.currentPageReference().getParameters().get('chat');
		leadChangeCoord = ApexPages.currentPage().getParameters().get('leadChangeCoord');
		campAddReferral = ApexPages.currentPage().getParameters().get('campAddReferral');
		system.debug('callid: ' + callId);
		isChat = false;
		if (String.isNotBlank(isAChat) && isAChat.toLowerCase() == 'true') {
			isChat = true;
		}
		system.debug('isChat: ' + isChat);
		searchScope = 'INDIVIDUAL';

		system.debug('FOSearchController - cid: ' + cid + ', relConsId: ' + relConsId + ', relConsType: ' + relConsType);

		if (String.isNotEmpty(cid)) {
			Case c = [select Id, SuppliedEmail, SearchTerms__c, Origin from Case where Id = :cid];
			emailCase = c;
			try {
				getSearchValues(c.SearchTerms__c, c.Origin);
			}
			catch(Exception e) {
				//don't want to break if we can't load the search terms
				system.debug('exception: ' + e.getMessage());
			}
			if (email == '') {
				email = c.SuppliedEmail;
			}
		}

		if (string.isNotBlank(phone) || string.isNotBlank(address1) || string.isNotBlank(address2) || 
			string.isNotBlank(name) || string.isNotBlank(firstName) || string.isNotBlank(lastName) || 
			string.isNotBlank(zip) || string.isNotBlank(city) || string.isNotBlank(state) || 
			string.isNotBlank(donorId) || string.isNotBlank(pledgeid) || string.isNotBlank(altId) || 
			string.isNotBlank(p2pId) || string.isNotBlank(email)) {
			currPage = 1;
			totalPages = 0;
			try {
				getPage();
			}
			catch(Exception e) {
				system.debug('exception: ' + e.getMessage());
			}
		}
	}

	private void getSearchValues(string SearchTerms, string Origin) {
		system.debug('search terms: ' + SearchTerms);
		if (string.isNotBlank(SearchTerms)) {
			if (string.isNotBlank(Origin) && Origin.toLowerCase() == 'research'	) {
				Blob SearchTermsblob = EncodingUtil.base64Decode(SearchTerms); //EVMM-179
				SearchTerms	= SearchTermsblob.toString();
			}
			String[] terms = SearchTerms.split('\\|', -1);
			system.debug('search terms: ' + terms.size());

			phone = terms[PHONE_IDX];
			address1 = terms[ADD1_IDX];
			address2 = terms[ADD2_IDX];
			name = terms[NAME_IDX];
			firstName = terms[FNAME_IDX];
			lastName = terms[LNAME_IDX];
			zip = terms[ZIP_IDX];
			city = terms[CITY_IDX];
			state = terms[STATE_IDX];
			donorId = terms[DON_IDX];
			pledgeId = terms[PLEDGE_IDX];
			altId = terms[ALT_IDX];
			email = terms[EMAIL_IDX];
			if (terms.size() > EMAIL_IDX) {
				searchScope = terms[SCOPE_IDX];
				if (String.isNotBlank(searchScope)) searchScope = 'INDIVIDUAL';
			}
			if (terms.size() > P2PID_IDX) {
				p2pId = terms[P2PID_IDX];
			}
		}
	}
	
	public PageReference changeSort() {
		currPage = 1;
		totalPages = 0;
		getPage();
		return null;		
	}
	
	public PageReference nextPage() {
		System.debug('nextPage');
		System.debug('currPage: ' + string.valueOf(currPage));
		System.debug('totalPages: ' + string.valueOf(totalPages));
		if (currPage < totalPages) {
			currPage++;
			getPage();
		}
		return null;		
	}
	
	public PageReference prevPage() {
		System.debug('prevPage');
		System.debug('currPage: ' + string.valueOf(currPage));
		System.debug('totalPages: ' + string.valueOf(totalPages));
		if (currPage > 1) {
			currPage--;
			getPage();
		}
		return null;
	}
	
	private void getPage() {
		System.debug('getPage');
		System.debug('currPage: ' + string.valueOf(currPage));
		System.debug('totalPages: ' + string.valueOf(totalPages));
		//name = lastName;

		System.debug('searchScope:' + searchScope + ', phone:' + phone + ', address1:' + address1 +
			', address2:' + address2 + ', name:' + name + ', lastName:' + lastName +
			', firstName:' + firstName + ', zip:' + zip + ', city:' + city +
			', state:' + state + ', donorId:' + donorId + ', pledgeId:' + pledgeId +
			', altId:' + altId + ', start:' + ((currPage - 1) * pageSize) + 1 + ', end:' + currPage * pageSize +
			', sort:' + sortOrder);
		if (String.isBlank(campAddReferral) && String.isBlank(leadChangeCoord)) {
			searchScope = 'ALL';
		}

		if (String.isNotEmpty(phone)) phone = phone.trim();
		if (String.isNotEmpty(address1)) address1 = address1.trim();
		if (String.isNotEmpty(address2)) address2 = address2.trim();
		if (String.isNotEmpty(name)) name = name.trim();
		if (String.isNotEmpty(lastName)) lastName = lastName.trim();
		if (String.isNotEmpty(firstName)) firstName = firstName.trim();
		if (String.isNotEmpty(zip)) zip = zip.trim();
		if (String.isNotEmpty(city)) city = city.trim();
		if (String.isNotEmpty(state)) state = state.trim();
		if (String.isNotEmpty(donorId)) donorId = donorId.trim();
		if (String.isNotEmpty(pledgeId)) pledgeId = pledgeId.trim();
		if (String.isNotEmpty(altId)) altId = altId.trim();
		if (String.isNotEmpty(email)) email = email.trim();
		if (String.isNotEmpty(p2pId)) p2pId = p2pId.trim();


		system.debug('searchScope: ' + searchScope);
		setSr(FOUtil.searchFO(searchScope, phone,  address1,  address2,  name, 
			lastName, firstName, zip,  city,  state,  donorId,  pledgeId,  altId, 
			email, ((currPage - 1) * pageSize) + 1, currPage * pageSize, sortOrder, p2pId));
	}
	
	public PageReference search() {
		if (validateForm()) {
			system.debug(phone);
			currPage = 1;
			totalPages = 0;
			getPage();
			System.debug(sr.size());
		}
		else {
			sr = new List<objectSoapStjudeOrg.SearchResponse>();
		}
		return null;
	}

	public PageReference newCons() {
    	system.debug('new constituent - cid: ' + cid + ', relConsId: ' + relConsId + ', relConsType: ' + relConsType);
    	PageReference pr = Page.FOConstituentAdd;
		pr.getParameters().put('relId', cid);
		pr.getParameters().put('relConsId', relConsId);
		pr.getParameters().put('relConsType', relConsType);
		pr.getParameters().put('leadChangeCoord', leadChangeCoord);
		pr.getParameters().put('campAddReferral', campAddReferral);
		pr.getParameters().put('mode', mode);
		pr.setRedirect(true);

    	return pr;
    }

	public void ViewDetail() {
		hasTaAccount = false;
		//String destination = '/';
		System.debug(ApexPages.currentPage().getParameters().get('SelectUUID'));
		System.debug(ApexPages.currentPage().getParameters().get('SelectName'));
		System.debug(ApexPages.currentPage().getParameters().get('SelectConType'));
		String consName = ApexPages.currentPage().getParameters().get('SelectName');
		String consType = ApexPages.currentPage().getParameters().get('SelectConType');
		String relConsId = ApexPages.currentPage().getParameters().get('RelConsId');
		String selectUUID = ApexPages.currentPage().getParameters().get('SelectUUID');
		selectConsId = ApexPages.currentPage().getParameters().get('SelectConsId');
		Case c;
		Boolean isEmailCase = false;


		if (String.isEmpty(selectUUID)) {
			try {
				selCon = FOUtil.getConstituent(null, RelConsId, new string[] {'PROFILE'});
				selectConsId = selCon.ConstituentID;
			}
			catch(Exception e) {
				//eat it :/
			}
		} 
		else {
			try {
				selCon = FOUtil.getConstituent(null, selectConsId, new string[] {'PROFILE'});
			}
			catch(Exception e) {
				//eat it :/
			}
		}	

		if (selCon.Type_x.Code == 'INDIVIDUAL') {
			FirstName = selCon.FirstName;
			LastName = selCon.LastName;
			if (String.isBlank(selCon.LongName)) LongName = FirstName + ' ' + LastName;
			else LongName = selCon.LongName;
		}
		else {
			LongName = selCon.Name;

		}
		system.debug('LongName: ' + LongName);

		if (selCon.Profile != null && selCon.Profile.Addresses != null && selCon.Profile.Addresses.size() > 0) {
			for(domainSoapStjudeOrg.Address a : selCon.Profile.Addresses) {
				ConsAddress = 
				(string.isNotBlank(a.Street1) ? a.Street1 + '\n' : '') +
				(string.isNotBlank(a.Street2) ? a.Street2 + '\n' : '') +
				(string.isNotBlank(a.Street3) ? a.Street3 + '\n' : '') +
				(string.isNotBlank(a.City) ? a.City + ', ' : '') +
				(string.isNotBlank(a.State) ? a.State + ' ' : '') +
				(string.isNotBlank(a.ZipCode) ? a.ZipCode : '');

				if (a.Preferred != null && a.Preferred ==true) break;
			}
		}
		else ConsAddress = 'Address';
		system.debug('Address: ' + ConsAddress );                
		if (selCon.Profile != null && selCon.Profile.Phones != null && selCon.Profile.Phones.size() > 0) {
			for(domainSoapStjudeOrg.Phone p : selCon.Profile.Phones) {
				ConsPhone = p.PhoneNumber;

				if(p.Preferred != null && p.Preferred == true) break;
			}
		}
		else ConsPhone = 'Phone Number';
		system.debug('Phone: ' + ConsPhone);

		if (selCon.Profile != null && selCon.Profile.Emails != null && selCon.Profile.Emails.size() > 0) {
			for(domainSoapStjudeOrg.Email e : selCon.Profile.Emails) {
				ConsEmail = e.EmailAddress;

				if (e.Preferred != null && e.Preferred == true) break;
			}
		}
		else ConsEmail = 'Email Address';
		system.debug('email: ' + ConsEmail);

		system.debug('start get getConstituentXRefs: ' + Datetime.now());
        List<domainSoapStjudeOrg.SystemXRef> conXref = FOUtil.getConstituentXRefs(selCon.ConstituentID, '');
        system.debug('finish get getConstituentXRefs: ' + Datetime.now());
        Xrefs = new List<domainSoapStjudeOrg.SystemXRef>();
        domainSoapStjudeOrg.SystemXRef[] dmsXrefs = new List<domainSoapStjudeOrg.SystemXRef>();
        for(domainSoapStjudeOrg.SystemXRef xrCon : conXref) {
            if (xrCon.Sys != null && xrCon.Sys.Name != null) {
                if (xrCon.Sys.Name == 'TA') {
                    xrefs.add(xrCon);
                    if(String.isNotEmpty(xrCon.XRefKey)) hasTaAccount = true;
                    system.debug('hasTaAccount: ' + hasTaAccount);
                }
                else if (xrCon.Sys.Name == 'DMS') {
                    dmsXrefs.add(xrCon);
                    system.debug('DMS: ' + xrCon.XRefKey);
                }
            }
        }
        system.debug('Xrefs');

		// check for 'Research mode'
		if (String.isNotEmpty(mode) && mode.toLowerCase() == 'research') {
			c = new Case();
			c.Origin = 'Research';
			c.Status = 'Closed';
			
			//c.CallCampaign__c = appl;
			c.Subject = 'Research - ' + UserInfo.getName();
			List<RecordType> rts = [select id from recordType 
			where sObjectType = 'Case' and developerName = 'Research'];
			if ( rts.size() == 1 ) {
				c.recordTypeId = rts[0].id;

				} else {
					throw new EVMUtil.EVMException('Research type is not configured!');
				}
				system.debug('mode: '+mode);

			}
			else if (String.isNotEmpty(leadChangeCoord)) {
				system.debug('changing the event coordinator!');
				EVMUtil.SSLeads currLead = EVMUtil.getCurrLead(leadChangeCoord);
				EVMUtil.ReplaceCoordinator(currLead, selectConsId);
				isEmailCase = true;
			}
			else if (emailCase == null && !isChat) {
				c = new Case();
				c.Origin = 'Phone';
			//c.CallCampaign__c = appl;
			c.CallObject__c = callId;
			c.Subject = 'Inbound Call - ' + consName;
			system.debug('emailCase == null && !isChat, callid: ' + callId);
		}
		else if (!isChat) {
			c = emailCase;
			isEmailCase = true;
			system.debug('!isChat, callid: ' + callId);
		}
		else {
			c = new Case();
			c.Origin = 'Web';
			c.Subject = 'Inbound Chat - ' + consName;
			system.debug('else, callid: ' + callId);
		}

		c.SearchTerms__c = (string.isNotBlank(phone) ? phone : '') + '|' + 
		(string.isNotBlank(address1) ? address1 : '') + '|' + 
		(string.isNotBlank(address2) ? address2 : '') + '|' + 
		(string.isNotBlank(name) ? name : '') + '|' + 
		(string.isNotBlank(lastName) ? lastName : '') + '|' + 
		(string.isNotBlank(firstName) ? firstName : '') + '|' + 
		(string.isNotBlank(zip) ? zip : '') + '|' + 
		(string.isNotBlank(city) ? city : '') + '|' + 
		(string.isNotBlank(state) ? state : '') + '|' + 
		(string.isNotBlank(donorId) ? donorId : '') + '|' + 
		(string.isNotBlank(pledgeId) ? pledgeId : '') + '|' + 
		(string.isNotBlank(altId) ? altId : '') + '|' + 
		(string.isNotBlank(email) ? email : '');

		if (string.isNotBlank(c.Origin) && c.Origin.toLowerCase() == 'research') {
			c.SearchTerms__c = EncodingUtil.base64Encode(Blob.valueof(c.SearchTerms__c));
		}

		EVMUtil.setCaseConstituent(c, selectUUID, consName, consType, relConsId, selectConsId);

		cid = c.id;

		System.debug(c.id);
	}

	private boolean validateForm() {
		boolean valid = true;
		String nameVal = searchScope == 'INDIVIDUAL' ? lastName : name;
		if (String.isBlank(email) && String.isBlank(phone) && String.isBlank(donorId) && String.isBlank(pledgeid) &&
			String.isBlank(lastName) && String.isBlank(address1) && String.isBlank(name) && String.isBlank(p2pId)) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
				'One of Last Name, Name, Address 1, Phone, Email, Donor Id, P2P Id or Pledge Id is required.'));
			valid = false;
		}
		return valid;
	}
}