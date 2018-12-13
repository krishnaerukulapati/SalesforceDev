public with sharing class C360ConstituentBasicEditController{
	public String titleCode {get; Set;}
	public String firstName {get; Set;}
	public String lastName {get; Set;}
	public String middleName {get; Set;}
	public String suffixCode {Get; Set;}
	public String conStatus {Get; Set;}
	public Boolean preferred {Get; Set;}
	public Boolean deceased {Get; Set;}
	public String deceasedDate {Get; Set;}
	public Boolean origDeceased {Get; Set;}
	public String origDeceasedDate {Get; Set;}
	public String birthDate {Get; Set;}
	public String origBirthDate {Get; Set;}
	public String name {get; set;}
	public Boolean noMail {get; set;}
	public String contId {get; private set;}
	public String consId {get; set;}
	public String relId {get; private set;}
    public ECCutil.consInfo ci {get; private set;}
	public String consType {get; private set;}
	public List<String> before = new List<String>();
	public List<String> after = new List<String>();
	private List<ConstituentInformation__c> consIds;
	public domainSoapStjudeOrg.Constituent con;

	public C360ConstituentBasicEditController(ApexPages.StandardController controller) {
		init();
	} 

	public C360ConstituentBasicEditController() {
		init();
	} 

	private void init() {
		relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId);
        consType = ci.consType;
        system.debug('consId: ' + ci.consId);

        if (ci.consId != null) {
            con = C360Util.getConstituent(null, ci.consId, null, consType);
			consId = con.ConstituentID;

			consIds = ECCUtil.getConstituentInformationByConsInfo(ci);

         	if (con != null) {
         		LoadBasic(con);
         	}
        }
	}
 
	public boolean getIsIndiv() {
		return consType == 'INDIVIDUAL';
	}
	
	public LIST<SelectOption> getItems() {
		return ECCUtil.getConstituentIdsForSelect(consIds);
	}
	
	public void changeCons() {
		con = C360Util.getConstituent(null, consId, null, consType);
		before = new List<String>();
		LoadBasic(con);
	}
	
	@TestVisible private void LoadBasic(domainSoapStjudeOrg.Constituent con) {
		System.debug('consType = ' + consType);
		if (consType == 'INDIVIDUAL') {
			titleCode = (con.Title != null && con.Title.Code != null ? con.Title.Code : '');
			firstName = con.FirstName;
			lastName = con.LastName;
			middleName = con.MiddleName;
			suffixCode = (con.Suffix != null && con.Suffix.Code != null ? con.Suffix.Code : '');
			deceased = false;
			origDeceased = false;
			preferred = con.Preferred;
			System.debug('con.IndividualAttributes = ' + con.IndividualAttributes);
			if (con.IndividualAttributes != null) {
				system.debug('con.IndividualAttributes.Deceased: ' + con.IndividualAttributes.Deceased + '\n' +
					'con.IndividualAttributes.DeceasedDate: ' + con.IndividualAttributes.DeceasedDate);
				System.debug('con.IndividualAttributes.Deceased = ' + con.IndividualAttributes.Deceased);
				deceased = con.IndividualAttributes.Deceased;
				System.debug('origDeceased = ' + con.IndividualAttributes.Deceased);
				origDeceased = con.IndividualAttributes.Deceased;
				System.debug('deceasedDate = ' + con.IndividualAttributes.DeceasedDate);
				deceasedDate = con.IndividualAttributes.DeceasedDate;
				System.debug('origDeceasedDate = ' + con.IndividualAttributes.DeceasedDate);
				origDeceasedDate = con.IndividualAttributes.DeceasedDate;
				System.debug('birthDate = ' + con.IndividualAttributes.BirthDate);
				birthDate = con.IndividualAttributes.BirthDate;
				System.debug('origBirthDate = ' + con.IndividualAttributes.BirthDate);
				origBirthDate = con.IndividualAttributes.BirthDate;
			}
		}
		else {
			name = con.Name;
		}
		conStatus = con.Status;
		listValuesForCompare(before);
	}
	
	public PageReference cancel() {
		return Page.ECCCloseSubTab;
	}

	public PageReference save() {
		PageReference pr;
		String newName;
		System.debug('consType before validateForm = ' + consType);
		System.debug('validForm = ' + validateForm());
		if (validateForm()) {
			pr = Page.ECCCloseSubTab;
			String res = '';

			if (consType == 'INDIVIDUAL') {
				domainSoapStjudeOrg.Individual i = new domainSoapStjudeOrg.Individual();
				domainSoapStjudeOrg.TypeAttribute title = new domainSoapStjudeOrg.TypeAttribute();
				domainSoapStjudeOrg.TypeAttribute suffix = new domainSoapStjudeOrg.TypeAttribute();
				domainSoapStjudeOrg.IndividualAttributes ia = new domainSoapStjudeOrg.IndividualAttributes();
				
				i.ConstituentID = consId;
				i.FirstName = firstName;
				i.LastName = lastName;
				i.MiddleName = middleName;
				i.Status = conStatus;
				i.Preferred = preferred;
				system.debug('status: ' + i.Status + ', preferred: ' + i.Preferred);
				newName = firstName + ' ' + lastName;

				suffix = new domainSoapStjudeOrg.TypeAttribute();
				if(titleCode != 'NT') 
					title.Code = titleCode;
				else
					title.Code = '';
				i.Title = title;
				
				if(String.isNotEmpty(suffixCode)) suffix.Code = suffixCode;
				i.Suffix = suffix;

				system.debug('deceased: ' + deceased + '\n' +
                            'origDeceased: ' + origDeceased);
				if(origDeceased != deceased) {
					ia.Deceased = deceased;
					
					if (!origDeceased) {
						//new deceased
						ECCUtil.createDeceasedPrefs(consId, noMail, ci.technique, firstName + ' ' + lastName);
					}
					else {
						ECCUtil.createInt(consId, ci.technique, 'AU', 'LIVING', 'Donor marked as deceased in error');
					}
					i.IndividualAttributes = ia;
				}

				if(origDeceasedDate != deceasedDate) {
					ia.DeceasedDate = deceasedDate;
					i.IndividualAttributes = ia;
				}

				if(origBirthDate != birthDate) {
					ia.BirthDate = birthDate;
					i.IndividualAttributes = ia;
				}

				System.debug(i);
				
				res = C360Util.EditConstituent(i, null, null, ci.technique);
			}
			else if (consType == 'HOUSEHOLD') {
				domainSoapStjudeOrg.Household h = new domainSoapStjudeOrg.Household();
				h.ConstituentID = consId;
				h.Name = name;

				newName = name;
				res = C360Util.EditConstituent(null, h, null, ci.technique);
			}
			else {
				domainSoapStjudeOrg.Organization o = new domainSoapStjudeOrg.Organization();
				o.ConstituentID = consId;
				o.Name = name;

				newName = name;
				res = C360Util.EditConstituent(null, null, o, ci.technique);
			}
			
			System.debug(res);
			
			listValuesForCompare(after);
			system.debug('before: ' + before.size() + ', after: ' + after.size());

			if (ci.objectType == 'Case') {
	        	Case currCase = ECCUtil.getCurrCase(relId).get(0);
	        	currCase.Constituent_Name__c = newName;
	        	update currCase;
	        }
	        else {
	        	//lead
	        	ECCUtil.SSLeads currLead = ECCUtil.getCurrLead(relId);
	        	if (consType == 'INDIVIDUAL') {
		        	currLead.SSLead.FirstName = firstName; 
		        	currLead.SSLead.LastName = lastName;	
	        	}
	        	else {
		        	currLead.SSLead.FirstName = ''; 
		        	currLead.SSLead.LastName = newName;	        		
	        	}
	        	update currLead.SSLead;
	        }
			ECCUtil.createTask(ci, 'Basic Edit', 'Completed', contId, before, after);

			pr.getParameters().put('id', relId);
		}
		return pr;
	}
	
	public LIST<SelectOption> getTitles() {
		return ECCUtil.getSelectFromC360Att(C360Util.getData('TITLES')); 
	}
	
	public LIST<SelectOption> getSuffixes() {
		return ECCUtil.getSelectFromC360Att(C360Util.getData('SUFFIXES')); 
	}

    public LIST<SelectOption> getStatusTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('STATUS_TYPES')); 
    }

	private boolean validateForm() {
		boolean valid = true;
		System.debug('consType while in validateForm = ' + consType);
		if (consType == 'INDIVIDUAL') {
			System.debug('firstName check = ' + firstName);
			if(String.isBlank(firstName)) {
				ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'First Name is required.'));
			    valid = false;
			}
			System.debug('valid after firstName check = ' + valid);
			System.debug('lastName check = ' + lastName);
			if(String.isBlank(lastName)) {
				ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Last Name is required.'));
			    valid = false;
			}
			System.debug('valid after lastName check = ' + valid);
			System.debug('conStatus check = ' + conStatus);
			if(String.isBlank(conStatus)) {
				ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
			    valid = false;
			}
			System.debug('valid after conStatus check = ' + valid);
			/*if(String.isNotBlank(birthDate)) {
                boolean validDate = false;
                try {
                    DateTime d = ECCUtil.JavaDateStringToDate(birthDate);
                    if (d != null) {
                        validDate = true;
                    }
                }
                catch(Exception e) {
                    //not valid
                }
                if (!validDate) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Birth date must be a valid date.'));
                    valid = false;
                }
			}*/
		}
		else {
			if(String.isBlank(name)) {
				ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Name is required.'));
			    valid = false;
			}
		}
		return valid;
	}

	public void listValuesForCompare(List<String> vals) {
		vals.add(String.format('{0} = {1}', new String[] {'First Name', firstName == null ? '' : firstName}));
		vals.add(String.format('{0} = {1}', new String[] {'Middle Name', middleName == null ? '' : middleName}));
		vals.add(String.format('{0} = {1}', new String[] {'Last Name', lastName == null ? '' : lastName}));
		vals.add(String.format('{0} = {1}', new String[] {'Title', titleCode == null ? '' : titleCode}));
		vals.add(String.format('{0} = {1}', new String[] {'Suffix', suffixCode == null ? '' : suffixCode}));
		vals.add(String.format('{0} = {1}', new String[] {'Name', name == null ? '' : name}));
		vals.add(String.format('{0} = {1}', new String[] {'Deceased', String.valueOf(deceased)}));
		vals.add(String.format('{0} = {1}', new String[] {'DeceasedDate', deceasedDate == null ? '' : deceasedDate}));
	}
}