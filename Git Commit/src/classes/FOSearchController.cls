public without sharing class FOSearchController {
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
	public Boolean bestMatch {get; set;}
	public Boolean allowDupes {get; set;}
    public Boolean isChat {get; private set;}
	public String cid {get; private Set;}
	public String relConsId {get; private set;}
	public String relConsType {get; private set;}
	public String sortOrder {get; set;}
	public String callId {get; private set;}
	public String leadChangeCoord {get; private set;}
	public String campAddReferral {get; private set;}
	//public String appl {get; private set;}
	public String mode {get; private set;}

	public Integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	private Integer pageSize = 9;
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
	
    public List<objectSoapStjudeOrg.SearchResponse> getSr() {
    	return sr;
    }
    
    private void setSr(soapStjudeOrg.SearchConstituents360Response_element newSr) {
		if (newSr.Constituents != null && newSr.Constituents.size() > 0) {
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
	 
	public FOSearchController() {
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

		/*setSr(FOUtil.searchFO(searchScope, phone,  address1,  address2,  name, 
			lastName, firstName, zip,  city,  state,  donorId,  pledgeId,  altId, 
			email, ((currPage - 1) * pageSize) + 1, currPage * pageSize, sortOrder, p2pId, bestMatch, allowDupes));*/
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
    
    public PageReference ViewDetail() {
		//String destination = '/';
		String destination = '';
		System.debug(ApexPages.currentPage().getParameters().get('SelectUUID'));
		System.debug(ApexPages.currentPage().getParameters().get('SelectName'));
		System.debug(ApexPages.currentPage().getParameters().get('SelectConType'));
		String consName = ApexPages.currentPage().getParameters().get('SelectName');
		String consType = ApexPages.currentPage().getParameters().get('SelectConType');
		String relConsId = ApexPages.currentPage().getParameters().get('RelConsId');
		String selectUUID = ApexPages.currentPage().getParameters().get('SelectUUID');
		String selectConsId = ApexPages.currentPage().getParameters().get('SelectConsId');
		Case c;
		Boolean isEmailCase = false;

		domainSoapStjudeOrg.Constituent con;
		if (String.isEmpty(selectUUID)) {
			try {
				con = FOUtil.getConstituent(null, RelConsId, null);
				selectConsId = con.ConstituentID;
			}
			catch(Exception e) {
				//eat it :/
			}
		} 
		else {
			try {
				con = FOUtil.getConstituent(null, selectConsId, null);
			}
			catch(Exception e) {
				//eat it :/
			}
		}
		if (con != null) {
			if (String.isBlank(con.Name)) {
				if (String.isBlank(con.LongName)) {
					consName = (String.isBlank(con.FirstName) ? '' : (con.FirstName + ' ')) + con.LastName;
				}
				else {
					consName = con.LongName;
				}
			}
			else {
				consName = con.Name;
			}
			consType = con.Type_x.Code;
		}		
		system.debug('consName: ' + consName + ', consType: ' + consType + ', relConsId: ' + relConsId + ', selectUUID: ' + selectUUID);
		/* not allowing relationships on existing peeps
		if (String.isNotBlank(relConsId)) {
			addRelationship();
			isEmailCase = false;
			c = emailCase;
			destination = '/Apex/FORelationshipDetail?id=';
		}
		else {*/
		// check for 'Research mode'
		if (String.isNotEmpty(mode) && mode.toLowerCase() == 'research') {
			c = new Case();
			c.Origin = 'Research';
			c.Status = 'Closed';
			
			//c.CallCampaign__c = appl;
			c.Subject = 'Research - ' + UserInfo.getName();
			destination = '/Apex/FOOpenConsole?cid=';
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
			destination = '/Apex/FOCloseRefresh';

			PageReference detail = new PageReference(destination);
			detail.setRedirect(true);
        	system.debug(detail.getUrl());
			return detail;
		}
		else if (String.isNotEmpty(campAddReferral)) {
			system.debug('changing the event coordinator!');
	        PageReference pr = Page.ECCAddLeadToCampaign;
	        pr.getParameters().put('consId', selectConsId);
	        pr.getParameters().put('campAddReferral', campAddReferral);
	        pr.getParameters().put('consType', consType);
	        pr.getParameters().put('consName', consName);
	        return pr;
		}
		else if (emailCase == null && !isChat) {
			c = new Case();
			c.Origin = 'Phone';
			//c.CallCampaign__c = appl;
			c.CallObject__c = callId;
			c.Subject = 'Inbound Call - ' + consName;
			destination = '/Apex/FOOpenConsole?cid=';
			system.debug('emailCase == null && !isChat, callid: ' + callId);
		}
		else if (!isChat) {
			c = emailCase;
			isEmailCase = true;
			destination = '/Apex/FOCloseRefresh';
			system.debug('!isChat, callid: ' + callId);
		}
		else {
			c = new Case();
			c.Origin = 'Web';
			c.Subject = 'Inbound Chat - ' + consName;
			destination = '/Apex/FOOpenConsole?isChat=true&cid=';
			system.debug('else, callid: ' + callId);
		}

		system.debug('destination: ' + destination);

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
    	PageReference detail = new PageReference(destination + (isEmailCase ? '' : cid)); // new ApexPages.StandardController(c).view();
    	detail.setRedirect(true);
        system.debug(detail.getUrl());
		return detail;
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

/*not allowing relationships on existing peeps
    private void addRelationship() {
		domainSoapStjudeOrg.Constituent con = FOUtil.getConstituent(
			ApexPages.currentPage().getParameters().get('SelectUUID'), null, null, searchScope);
		domainSoapStjudeOrg.Constituent relCon = FOUtil.getConstituent(null, relConsId, null, relConsType);
		domainSoapStjudeOrg.Relationship rel = new domainSoapStjudeOrg.Relationship();
		domainSoapStJudeOrg.Household h;
		domainSoapStJudeOrg.Organization o;
        
		system.debug('adding relationship - new: ' + con.ConstituentID + ', existing: ' + relConsId);

		rel.Type_x = new domainSoapStjudeOrg.TypeAttribute();
		rel.Type_x.Code = relConsType; //only allowed to add individuals to households or orgs
		rel.RelatedConstituent = con;

		if (relConsType == 'HOUSEHOLD') {
			h = new domainSoapStjudeOrg.Household();
			h.ConstituentID = relCon.ConstituentID;
			h.Name = relCon.Name;
			h.Relationships = new domainSoapStjudeOrg.Relationship[] { rel };
		}
		else if (relConsType == 'ORGANIZATION') {
			o = new domainSoapStjudeOrg.Organization();
			o.ConstituentID = relCon.ConstituentID;
			o.Name = relCon.Name;
			o.Relationships = new domainSoapStjudeOrg.Relationship[] { rel };
		}

		FOUtil.editConstituent(null, h, o);
    }*/
}