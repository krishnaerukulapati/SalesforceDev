public with sharing class FOConstituentPhoneEditController{
	public String phoneNumber {get; Set;}
	public boolean preferred {get; set;}
	public String status {get; set;}
	public String comments {get; set;}
	public String phoneTypeCode {Get; Set;}
	public String contId {get; private set;}
	public String consId {get; private set;}
	public String relId {get; private set;}
	public String leadType {get; private set;}
	public EVMUtil.consInfo ci {get; private set;}
	public String contactType {get; private Set;}
	public String firstName {get; private Set;}
	public String lastName {get; private Set;}
	public boolean foundPhone {get; private set;}
	public String error {get; set;}
	public boolean bNew {get; private set;}
	public List<String> before = new List<String>();
	public List<String> after = new List<String>();
	public Boolean isSF1 {get; set;}

	public FOConstituentPhoneEditController (ApexPages.StandardController controller){
		init();
	}

	public FOConstituentPhoneEditController (){
		init();
	}

	public void init() {
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
        
        system.debug('consId: ' + ci.consId);
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
	         	if (con != null && con.Profile != null && con.Profile.Phones != null && con.Profile.Phones.size() > 0) {
	         		for (domainSoapStjudeOrg.Phone p : con.Profile.Phones) {
	         			if (p.ContactID == contId) {
	         				LoadPhone(p);
	         			}
	         		}
	         	}
        	}
        }
	}
	
	private void LoadPhone(domainSoapStjudeOrg.Phone p) {
		phoneNumber = EVMUtil.formatPhone(p.PhoneNumber);
		preferred = p.preferred;
		status = p.status;
		comments = p.comments;
		phoneTypeCode = p.PhoneType.Code;
		contactType = p.ContactType;
		foundPhone = true;
		bNew = false;
		listValuesForCompare(before);
	}
	
	public PageReference cancel() {
		PageReference pr = Page.FOPhoneDetail;
		pr.getParameters().put('id', relId);
		if (isSF1) pr.getParameters().put('SF1', 'true');
		return pr;
	}
	
	public PageReference save() {
		PageReference pr;
		if (validateForm()) {
			pr = Page.FOPhoneDetail;
			domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
			domainSoapStjudeOrg.TypeAttribute pt = new domainSoapStjudeOrg.TypeAttribute();
			
			String res = '';
			
			pt.Code = phoneTypeCode;
			if (String.isNotEmpty(contId)) {			
				ph.ContactId = contId;
				ph.ContactType = contactType;
			}
			else {
				ph.ContactType = 'P';
			}
			ph.Preferred = preferred;
			ph.PhoneNumber = EVMUtil.formatPhone(phoneNumber);
			ph.status = status;
			ph.comments = comments;
			
			ph.PhoneType = pt;
			
			System.debug(ph);
			
			if (String.isNotEmpty(contId)) {			
				res = FOUtil.EditPhone(consId, ph, ci.technique);
			}
			else {
				res = FOUtil.CreatePhone(consId, ph, ci.technique);
			}
			
			System.debug(res);
			
			listValuesForCompare(after);
			EVMUtil.createTask(ci, bNew ? 'Phone Add' : 'Phone Edit', 'Completed', contId, before, after);
			
			pr.getParameters().put('id', relId);
            pr.getParameters().put('leadType', leadType);
            if (isSF1){
                pr = new PageReference('/Apex/FOSearchMobile');
            }
		}
		return pr;
	}

	private boolean validateForm() {
		boolean valid = true;
		Pattern isnumbers = Pattern.Compile('^[0-9]{10}$');

		if( String.isBlank(phoneNumber) || !isnumbers.matcher(EVMUtil.deFormatPhone(phoneNumber)).Matches()){
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Phone Number must be 10 digits and numeric.'));
		    valid = false;
		}
		if(String.isBlank(phoneTypeCode)) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Type is required.'));
		    valid = false;
		}
		if(String.isBlank(status)) {
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
		    valid = false;
		}
		return valid;
	}

	public LIST<SelectOption> getPhoneTypes() {
		return EVMUtil.getSelectFromFOAtt(FOUtil.getData('PHONE_TYPES')); 
	}

	public LIST<SelectOption> getStatusTypes() {
		return EVMUtil.getSelectFromFOAtt(FOUtil.getData('STATUS_TYPES')); 
	}

	public void listValuesForCompare(List<String> vals) {
		vals.add(String.format('{0} = {1}', new String[] {'Phone Number', phoneNumber == null ? '' : phoneNumber}));
		vals.add(String.format('{0} = {1}', new String[] {'Preferred', String.valueof(preferred)}));
		vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
		vals.add(String.format('{0} = {1}', new String[] {'Comments', comments == null ? '' : comments}));
		vals.add(String.format('{0} = {1}', new String[] {'Phone Type', phoneTypeCode == null ? '' : phoneTypeCode}));
	}
}