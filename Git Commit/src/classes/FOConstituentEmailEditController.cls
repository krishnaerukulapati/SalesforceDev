public with sharing class FOConstituentEmailEditController{
	public String email {get; Set;}
	public boolean preferred {get; set;}
	public String status {get; set;}
	public String comments {get; set;}
	public String emailTypeCode {get; set;}
	public String contId {get; private set;}
	public String consId {get; private set;}
    public String relId {get; private set;}
    public String leadType {get; private set;}
    public EVMutil.consInfo ci {get; private set;}
	public String contactType {get; private Set;}
	public String firstName {get; private Set;}
	public String lastName {get; private Set;}
	public boolean foundEmail {get; private set;}
	public boolean bNew {get; private set;}
	public List<String> before = new List<String>();
	public List<String> after = new List<String>();
	public Boolean isSF1 {get;set;}
	
	public FOConstituentEmailEditController(ApexPages.StandardController controller) {
        init();
	}

	public FOConstituentEmailEditController() {
        init();
	}

	private void init() {
		relId = System.currentPageReference().getParameters().get('id');
        leadType = System.currentPageReference().getParameters().get('leadType');
        if (String.isNotEmpty(System.currentPageReference().getParameters().get('SF1'))) {
            isSF1 = Boolean.valueOf(System.currentPageReference().getParameters().get('SF1'));
        }
        else {
            isSF1 = false;
        }
        if (String.isBlank(leadType)) leadType = 'ORG';
        system.debug(relId);
        ci = EVMUtil.getConsInfo(relId, leadType);

        bNew = true;
        if (ci.consId != null) {
        	contId = System.currentPageReference().getParameters().get('contId');
        	consId = System.currentPageReference().getParameters().get('consId');

        	system.debug('consId: ' + consId);
            system.debug('contId: ' + contId);

            domainSoapStjudeOrg.Constituent con = FOUtil.getConstituent(null, consId, 
            	new string[] {'PROFILE'}, 'ALL');
			firstName = con.firstName;
			lastName = con.lastName;
        	preferred = false;

        	if (contId != null && contId.length() > 0) {
	         	if (con != null && con.Profile != null && con.Profile.Emails != null && con.Profile.Emails.size() > 0) {
	         		for (domainSoapStjudeOrg.Email e : con.Profile.Emails) {
	         			if (e.ContactID == contId) {
	         				LoadEmail(e);
	         			}
	         		}
	         	}
        	}
        }
	}
	
	private void LoadEmail(domainSoapStjudeOrg.Email e) {
		email = e.EmailAddress;
		preferred = e.preferred;
		status = e.status;
		comments = e.comments;
		emailTypeCode = e.EmailType.Code;
		contactType = e.ContactType;
		foundEmail = true;
		bNew = false;
		listValuesForCompare(before);
	}
	
	public PageReference cancel() {
		PageReference pr = Page.FOEmailDetail;
		pr.getParameters().put('id', relId);
		if (isSF1) pr.getParameters().put('SF1', 'true');
		return pr;
	}
	
	public PageReference save() {
		PageReference pr;
		if (validateForm()) {
			pr = Page.FOEmailDetail;
			domainSoapStjudeOrg.Email e = new domainSoapStjudeOrg.Email();
			domainSoapStjudeOrg.TypeAttribute et = new domainSoapStjudeOrg.TypeAttribute();
			
			String res = '';
			
			e.Preferred = preferred;
			et.Code = emailTypeCode;
			system.debug('save: et.Code: ' + et.Code + ', emailTypeCode: ' + emailTypeCode);
			if (String.isNotEmpty(contId)) {
				system.debug('contid: ' + contId);	
				system.debug('contactType: ' + contactType);	
				system.debug('emailTypeCode: ' + emailTypeCode);	
				e.ContactId = contId;
				e.ContactType = contactType;
			}
			if (String.isEmpty(et.Code)) et.Code = 'Home';
			if (String.isEmpty(e.ContactType)) e.ContactType = 'E';

			e.EmailAddress = email;
			e.status = status;
			e.comments = comments;
			
			
			e.EmailType = et;
			
			system.debug('save: e.EmailType.Code: ' + e.EmailType.Code + ', emailTypeCode: ' + emailTypeCode);
			
			System.debug(e);
			
			if (String.isNotEmpty(contId)) {			
				res = FOUtil.EditEmail(consId, e, ci.technique);
			}
			else {
				res = FOUtil.CreateEmail(consId, e, ci.technique);
			}			
			
			System.debug(res);
			
			listValuesForCompare(after);
			EVMUtil.createTask(ci, bNew ? 'Email Add' : 'Email Edit', 'Completed', contId, before, after);
			
			pr.getParameters().put('id', relId);
            pr.getParameters().put('leadType', leadType);
            if (isSF1){
                pr = new PageReference('/Apex/FOSearchMobile');
            }
		}
		return pr;
	}
	
	public LIST<SelectOption> getStatusTypes() {
		return EVMUtil.getSelectFromFOAtt(FOUtil.getData('STATUS_TYPES')); 
	}
	
	public LIST<SelectOption> getEmailTypes() {
		return EVMUtil.getSelectFromFOAtt(FOUtil.getData('EMAIL_TYPES')); 
	}

	private boolean validateForm() {
		boolean valid = true;
		Pattern emailPattern = Pattern.Compile('^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z]{2,6})$');

		if( String.isBlank(email) || !emailPattern.matcher(email).Matches()){
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email must be a valid email address.'));
		    valid = false;
		}
		if(String.isBlank(emailTypeCode)) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Type is required.'));
		    valid = false;
		}
		if(String.isBlank(status)) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
		    valid = false;
		}
		return valid;
	}

	public void listValuesForCompare(List<String> vals) {
		vals.add(String.format('{0} = {1}', new String[] {'Email', email == null ? '' : email}));
		vals.add(String.format('{0} = {1}', new String[] {'Preferred', String.valueOf(preferred)}));
		vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
		vals.add(String.format('{0} = {1}', new String[] {'Comments', comments == null ? '' : comments}));
		vals.add(String.format('{0} = {1}', new String[] {'Email Type', emailTypeCode == null ? '' : emailTypeCode}));
	}
}