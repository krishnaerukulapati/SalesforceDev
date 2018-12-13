public with sharing class C360ConstituentPhoneEditController{
	public String phoneNumber {get; Set;}
	public boolean preferred {get; set;}
	public String status {get; set;}
	public String comments {get; set;}
	public String phoneTypeCode {Get; Set;}
	public String contId {get; private set;}
	public String consId {get; private set;}
	public String relId {get; private set;}
	public String leadType {get; private set;}
	public ECCUtil.consInfo ci {get; private set;}
	public String contactType {get; private Set;}
	public String firstName {get; private Set;}
	public String lastName {get; private Set;}
	public boolean foundPhone {get; private set;}
	public String error {get; set;}
	public boolean bNew {get; private set;}
	public List<String> before = new List<String>();
	public List<String> after = new List<String>();

	public C360ConstituentPhoneEditController (ApexPages.StandardController controller){
		init();
	}

	public C360ConstituentPhoneEditController (){
		init();
	}

	public void init() {
		relId = System.currentPageReference().getParameters().get('id');
        leadType = System.currentPageReference().getParameters().get('leadType');
        if (String.isBlank(leadType)) leadType = 'ORG';
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId, leadType);
        
        system.debug('consId: ' + ci.consId);
        bNew = true;
        if (ci.consId != null) {
        	contId = System.currentPageReference().getParameters().get('contId');
        	consId = System.currentPageReference().getParameters().get('consId');

        	system.debug('consId: ' + consId);

            domainSoapStjudeOrg.Constituent con = C360Util.getConstituent(null, consId, 
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
		phoneNumber = ECCUtil.formatPhone(p.PhoneNumber);
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
		PageReference pr = Page.C360PhoneDetail;
		pr.getParameters().put('id', relId);
		pr.getParameters().put('leadType', leadType);
		return pr;
	}
	
	public PageReference save() {
		PageReference pr;
		if (validateForm()) {
			pr = Page.C360PhoneDetail;
			domainSoapStjudeOrg.Individual i = new domainSoapStjudeOrg.Individual();
			domainSoapStjudeOrg.Profile p = new domainSoapStjudeOrg.Profile();
			domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
			domainSoapStjudeOrg.TypeAttribute pt = new domainSoapStjudeOrg.TypeAttribute();
			
			String res = '';
			
			i.ConstituentID = consId;
			i.FirstName = firstName;
			i.LastName = lastName;
			pt.Code = phoneTypeCode;
			if (String.isNotEmpty(contId)) {			
				ph.ContactId = contId;
				ph.ContactType = contactType;
			}
			else {
				ph.ContactType = 'P';
			}
			ph.Preferred = preferred;
			ph.PhoneNumber = ECCUtil.formatPhone(phoneNumber);
			ph.status = status;
			ph.comments = comments;
			
			ph.PhoneType = pt;
			p.Phones = new domainSoapStjudeOrg.Phone[] {ph};
			i.Profile = p;
			
			System.debug(i);
			
			res = C360Util.EditConstituent(i, null, null, ci.technique);
			
			System.debug(res);
			
			listValuesForCompare(after);
			ECCUtil.createTask(ci, bNew ? 'Phone Add' : 'Phone Edit', 'Completed', contId, before, after);
			
			pr.getParameters().put('id', relId);
            pr.getParameters().put('leadType', leadType);
		}
		return pr;
	}

	private boolean validateForm() {
		boolean valid = true;
		Pattern isnumbers = Pattern.Compile('^[0-9]{10}$');

		if( String.isBlank(phoneNumber) || !isnumbers.matcher(ECCUtil.deFormatPhone(phoneNumber)).Matches()){
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
		return ECCUtil.getSelectFromC360Att(C360Util.getData('PHONE_TYPES')); 
	}

	public LIST<SelectOption> getStatusTypes() {
		return ECCUtil.getSelectFromC360Att(C360Util.getData('STATUS_TYPES')); 
	}

	public void listValuesForCompare(List<String> vals) {
		vals.add(String.format('{0} = {1}', new String[] {'Phone Number', phoneNumber == null ? '' : phoneNumber}));
		vals.add(String.format('{0} = {1}', new String[] {'Preferred', String.valueof(preferred)}));
		vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
		vals.add(String.format('{0} = {1}', new String[] {'Comments', comments == null ? '' : comments}));
		vals.add(String.format('{0} = {1}', new String[] {'Phone Type', phoneTypeCode == null ? '' : phoneTypeCode}));
	}
}