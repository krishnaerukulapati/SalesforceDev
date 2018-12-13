public without sharing class C360SearchController {
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
	//public String appl {get; private set;}
	public String mode {get; private set;}
	public String isRecruitmentCampaign {get; set;}

	public Boolean bisRecruitmentCampaign {get; set;}

	public Integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	private Integer pageSize = 9;
	private Integer PHONE_IDX = 0, ADD1_IDX = 1, ADD2_IDX = 2, NAME_IDX = 3,
			LNAME_IDX = 4, FNAME_IDX = 5, ZIP_IDX = 6, CITY_IDX = 7, STATE_IDX = 8,
			DON_IDX = 9, PLEDGE_IDX = 10, ALT_IDX = 11, EMAIL_IDX = 12, SCOPE_IDX = 13, P2PID_IDX = 14;
	
	private Case emailCase;
    public List<objectSoapStjudeOrg.SearchResponse> sr = new List<objectSoapStjudeOrg.SearchResponse>();
	
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
	 
	public C360SearchController() {
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
		isRecruitmentCampaign = ApexPages.currentPage().getParameters().get('isRecruitmentCampaign');
		if(isRecruitmentCampaign == null){
			isRecruitmentCampaign = 'false';
		}
		system.debug('isRecruitmentCampaign in C360SearchController: ' + isRecruitmentCampaign);
		isRecruitmentCampaign = isRecruitmentCampaign.toLowerCase();
		bisRecruitmentCampaign = isRecruitmentCampaign == 'true';
		system.debug('callid: ' + callId);
		isChat = false;
		if (String.isNotBlank(isAChat) && isAChat.toLowerCase() == 'true') {
			isChat = true;
		}
		system.debug('isChat: ' + isChat);
		searchScope = 'INDIVIDUAL';

    	system.debug('C360SearchController - cid: ' + cid + ', relConsId: ' + relConsId + ', relConsType: ' + relConsType);

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

		System.debug('searchScope: ' + searchScope + ', phone:' + phone + ', address1:' + address1 +
			', address2: ' + address2 + ', name:' + name + ', lastName:' + lastName +
			', firstName: ' + firstName + ', zip:' + zip + ', city:' + city +
			', state: ' + state + ', donorId:' + donorId + ', pledgeId:' + pledgeId +
			', altId: ' + altId + ', start:' + ((currPage - 1) * pageSize) + 1 + ', end:' + currPage * pageSize +
			', sort: ' + sortOrder);
		System.debug('campAddReferral = ' + campAddReferral + 'leadChangeCoord = ' + leadChangeCoord + 'isChat = ' + isChat);
		if (String.isBlank(campAddReferral) && String.isBlank(leadChangeCoord) && isRecruitmentCampaign.toLowerCase() != 'true') {
			searchScope = 'ALL';
		}else if(isRecruitmentCampaign.toLowerCase() == 'true'){
		//	searchScope = 'INDIVIDUAL';
			isChat = true;
			campAddReferral = '';
			leadChangeCoord = '';
		}
		System.debug('campAddReferral = ' + campAddReferral + 'leadChangeCoord = ' + leadChangeCoord + 'isChat = ' + isChat);
		system.debug('searchScope: ' + searchScope);
		setSr(C360Util.searchC360(searchScope, phone,  address1,  address2,  name, 
			lastName, firstName, zip,  city,  state,  donorId,  pledgeId,  altId, 
			email, ((currPage - 1) * pageSize) + 1, currPage * pageSize, sortOrder, p2pId));
	}
	
	public PageReference search() {
		if (validateForm()) {
			system.debug('search phone :' +phone);
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
    	//isRecruitmentCampaign = ApexPages.currentPage().getParameters().get('isRecruitmentCampaign');
		system.debug('isRecruitmentCampaign in newCons: ' + isRecruitmentCampaign);
    	PageReference pr = Page.C360ConstituentAdd;
    	pr.getParameters().put('isRecruitmentCampaign', isRecruitmentCampaign);
		pr.getParameters().put('relId', cid);
		pr.getParameters().put('relConsId', relConsId);
		pr.getParameters().put('relConsType', relConsType);
		pr.getParameters().put('leadChangeCoord', leadChangeCoord);
		pr.getParameters().put('campAddReferral', campAddReferral);
        pr.getParameters().put('callId', callId);
		pr.getParameters().put('mode', mode);
		pr.setRedirect(true);

    	return pr;
    }
    
    public PageReference ViewDetail() {

    	system.debug('isRecruitmentCampaign in ViewDetail : ' + isRecruitmentCampaign);
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
				con = C360Util.getConstituent(null, RelConsId, new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'});
				selectConsId = con.ConstituentID;
			}
			catch(Exception e) {
				//eat it :/
			}
		} 
		else {
			try {
				con = C360Util.getConstituent(null, selectConsId, new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'});
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

		system.debug('cons=' + con);
		system.debug('consName: ' + consName + ', consType: ' + consType + ', relConsId: ' + relConsId + ', selectUUID: ' + selectUUID);
		/* not allowing relationships on existing peeps
		if (String.isNotBlank(relConsId)) {
			addRelationship();
			isEmailCase = false;
			c = emailCase;
			destination = '/Apex/C360RelationshipDetail?id=';
		}
		else {*/
		// check for 'Research mode'
		//Check for isRecruitmentCampaign.toLowerCase() != 'true'??
		if (String.isNotEmpty(mode) && mode.toLowerCase() == 'research') {
			c = new Case();
			c.Origin = 'Research';
			c.Status = 'Closed';
			
			//c.CallCampaign__c = appl;
			c.Subject = 'Research - ' + UserInfo.getName();
			destination = '/Apex/C360OpenConsole?cid=';
			List<RecordType> rts = [select id from recordType 
									where sObjectType = 'Case' and developerName = 'Research'];
			if ( rts.size() == 1 ) {
				c.recordTypeId = rts[0].id;

			} else {
				throw new ECCUtil.ECCException('Research type is not configured!');
			}
			system.debug('mode: '+mode);

		}
		else if (String.isNotEmpty(leadChangeCoord) && con != null) {
			system.debug('changing the event coordinator!');
		     ECCUtil.SSLeads currLead = ECCUtil.getCurrLead(leadChangeCoord);
		     ECCUtil.ReplaceCoordinator(currLead, selectConsId);
		     isEmailCase = true;
		     destination = '/Apex/C360CloseRefresh';

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
			system.debug('emailCase = ' + emailCase);
			system.debug('isChat = ' + isChat);
			c = new Case();
			c.Origin = 'Phone';
			//c.CallCampaign__c = appl;
			c.CallObject__c = callId;
			c.Subject = 'Inbound Call - ' + consName;
			destination = '/Apex/C360OpenConsole?cid=';
			system.debug('emailCase == null && !isChat, callid: ' + callId);
		}
		else if (!isChat) {
			c = emailCase;
			isEmailCase = true;
			destination = '/Apex/C360CloseRefresh';
			system.debug('!isChat, callid: ' + callId);
		}
		else if(isRecruitmentCampaign.toLowerCase() == 'true'){
			system.debug('isRecruitmentCampaign.toLowerCase() = true else');
			system.debug('leadChangeCoord = ' + leadChangeCoord);
			system.debug('campAddReferral = ' + campAddReferral);
			system.debug('emailCase = ' + emailCase);
			system.debug('isChat = ' + isChat);
	       // con = C360Util.getConstituent(null, selectConsId, new string[] {'PROFILE'}, 'ALL');
			system.debug('Page.AddLeadFromCaseToCampaign');
	        PageReference pr = Page.AddLeadFromCaseToCampaign;
	        pr.getParameters().put('consId', selectConsId);
	        pr.getParameters().put('callId', callId);
	        pr.getParameters().put('consType', consType);
	        pr.getParameters().put('consName', consName);
	        return pr;
		}
		else {
			c = new Case();
			c.Origin = 'Web';
			c.Subject = 'Inbound Chat - ' + consName;
			destination = '/Apex/C360OpenConsole?isChat=true&cid=';
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
        
		ECCUtil.setCaseConstituent(c, selectUUID, consName, consType, relConsId, selectConsId);  //creating case here

		cid = c.id;

		System.debug('c.id : ' + c.id);
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
		else if (String.isNotBlank(pledgeid) &&
				 !pledgeid.isNumeric() && 
				 !Pattern.matches('[a-zA-Z0-9]{8}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{12}', pledgeid)) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
				'Pledge Id must be a number or a GUID (\'00000000-0000-0000-0000-000000000000\')'));
	    	valid = false;
		}
		return valid;
    }

/*not allowing relationships on existing peeps
    private void addRelationship() {
		domainSoapStjudeOrg.Constituent con = C360Util.getConstituent(
			ApexPages.currentPage().getParameters().get('SelectUUID'), null, null, searchScope);
		domainSoapStjudeOrg.Constituent relCon = C360Util.getConstituent(null, relConsId, null, relConsType);
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

		C360Util.editConstituent(null, h, o);
    }*/
}