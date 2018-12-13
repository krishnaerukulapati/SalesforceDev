@isTest
global class AddLeadFromCaseToCampaignContTest {
		public static String consId ;
		public static String selCampaignId;
	    public static String consType;
	    public static String consName ;
	    public static String phoneNum ;
	    public static String campAddReferral ;
	    public static RecordType rt ;
	    public static  Boolean bDuplicate;

	@isTest static void saveLeadWithRecordTypeisNull() {
		

		Campaign cmp = new Campaign();
	    cmp.Name = 'testCampaign';
	    cmp.LeadRecType__c = null ;
	    insert cmp;

	    System.debug('cmp = ' + cmp.Id);

	    C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;


	    cmp = [select LeadRecType__c from Campaign where Id = :cmp.Id];
	     
	    Test.startTest();
	    PageReference pageRef = Page.AddLeadFromCaseToCampaign;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new AddLeadFromCaseToCampaignContMock());

        AddLeadFromCaseToCampaignController cac = new AddLeadFromCaseToCampaignController();
        /*List<Lead> lconId = new List<Lead>();
        lconId = [select ConstituentID__c from lead limit 1];
        cac.consId = String.valueOf(lconId[0]);*/
        cac.consId = Guid.createGuid();
        cac.consType = 'INDIVIDUAL';
        cac.consName = 'TestName';
        cac.phoneNum = '1234561234';
        cac.campAddReferral = cmp.Id;

	    system.debug('campAddReferral == ' + cmp.Id);
	    //cac.campAddReferral = cmp.Id;
	    system.debug('cmp.LeadRecType__c == ' + cmp.LeadRecType__c);

	    if(cmp.LeadRecType__c == null){
        rt = [select Id from RecordType where DeveloperName = 'St_Jude_Challenge' and sObjectType = 'Lead'];
        }
        System.debug('rt = ' + rt.id);

        List<Lead> dupLead = [select id from lead where RecordTypeId = :rt.Id and (ConstituentID__c = :consId or CoordinatorID__c = :consId) and CurrentCampaign__c = :cmp.Id];

	   system.debug('dupLead.size(): ' + dupLead.size());

	   system.debug('phoneNum: ' + phoneNum);
       Id id = ECCUtil.CreateLeadReferral(cac.campAddReferral, cac.consId, cac.consType, cac.consName, rt.Id, cac.phoneNum);
       Test.stopTest();
       cac.saveLead();
	}

	@isTest static void saveLeadWithRecordTypeisNotNull() {

		Campaign cmp = new Campaign();
	    cmp.Name = 'testCampaign';
	    cmp.LeadRecType__c = 'St_Jude_Challenge';
	    insert cmp;

	    System.debug('cmp = ' + cmp.Id);

	    C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;


	    cmp = [select LeadRecType__c from Campaign where Id = :cmp.Id];
	     
	    Test.startTest();
	    PageReference pageRef = Page.AddLeadFromCaseToCampaign;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new AddLeadFromCaseToCampaignContMock());

        AddLeadFromCaseToCampaignController cac = new AddLeadFromCaseToCampaignController();
        /*List<Lead> lconId = new List<Lead>();
        lconId = [select ConstituentID__c from lead limit 1];
        cac.consId = String.valueOf(lconId[0]);*/
        cac.consId = Guid.createGuid();
        cac.consType = 'INDIVIDUAL';
        cac.consName = 'TestName';
        cac.phoneNum = '1234561234';
        cac.campAddReferral = cmp.Id;

	    system.debug('campAddReferral == ' + cmp.Id);
	    //cac.campAddReferral = cmp.Id;
	    system.debug('cmp.LeadRecType__c == ' + cmp.LeadRecType__c);

	    if(cmp.LeadRecType__c != null){
        rt = [select Id from RecordType where DeveloperName = :cmp.LeadRecType__c and sObjectType = 'Lead'];
        }
        System.debug('rt = ' + rt.id);

        List<Lead> dupLead = [select id from lead where RecordTypeId = :rt.Id and (ConstituentID__c = :consId or CoordinatorID__c = :consId) and CurrentCampaign__c = :cmp.Id];

	   system.debug('dupLead.size(): ' + dupLead.size());

	   system.debug('phoneNum: ' + phoneNum);
       Id id = ECCUtil.CreateLeadReferral(cac.campAddReferral, cac.consId, cac.consType, cac.consName, rt.Id, cac.phoneNum);
       Test.stopTest();
       cac.saveLead();
	}

	/*@isTest static void saveLeadWithRecordTypeisNotNullAndDulplucate() {

		Campaign cmp = new Campaign();
	    cmp.Name = 'testCampaign';
	    cmp.LeadRecType__c = 'St_Jude_Challenge';
	    insert cmp;

	    consId = Guid.createGuid();
	    rt = [select Id from RecordType where DeveloperName = :cmp.LeadRecType__c and sObjectType = 'Lead'];

	    Lead l = new Lead(
            LastName = 'TestLead',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            TR_ID__c = '321654',
            CurrentCampaign__c = cmp.Id,
            XREF__c = 'test|one',
            RecordTypeId = rt.Id,
            ConstituentID__c = consId
            );
      
        insert l;

        Lead ll = new Lead(
            LastName = 'TestLead',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            TR_ID__c = '321654',
            CurrentCampaign__c = cmp.Id,
            XREF__c = 'test|one',
            RecordTypeId = rt.Id,
            ConstituentID__c = consId
            );
      
        insert ll;

	    System.debug('cmp = ' + cmp.Id);

	    C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;


	    cmp = [select LeadRecType__c from Campaign where Id = :cmp.Id];
	     
	    Test.startTest();
	    PageReference pageRef = Page.AddLeadFromCaseToCampaign;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new AddLeadFromCaseToCampaignContMock());

        AddLeadFromCaseToCampaignController cac = new AddLeadFromCaseToCampaignController();
        cac.consType = 'INDIVIDUAL';
        cac.consName = 'TestName';
        cac.phoneNum = '1234561234';
        cac.campAddReferral = cmp.Id;

	    system.debug('campAddReferral == ' + cmp.Id);
	    system.debug('cmp.LeadRecType__c == ' + cmp.LeadRecType__c);

        System.debug('rt = ' + rt.id);

        List<Lead> dupLead = [select id from lead where RecordTypeId = :rt.Id and (ConstituentID__c = :consId or CoordinatorID__c = :consId) and CurrentCampaign__c = :cmp.Id];
        
        if (dupLead.size() > 0) {
            bDuplicate = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This lead already exists.'));
        }
	   system.debug('dupLead.size() === ' + dupLead.size());

	   system.debug('phoneNum: ' + phoneNum);
       Id id = ECCUtil.CreateLeadReferral(cac.campAddReferral, cac.consId, cac.consType, cac.consName, rt.Id, cac.phoneNum);
       Test.stopTest();
       cac.saveLead();
	}*/

	@isTest static void getPhoneTypes() {
		Campaign cmp = new Campaign();
	    cmp.Name = 'testCampaign';
	    cmp.LeadRecType__c = 'St_Jude_Challenge';
	    insert cmp;

	    System.debug('cmp = ' + cmp.Id);

	    C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;


	    cmp = [select LeadRecType__c from Campaign where Id = :cmp.Id];
	     
	    Test.startTest();
	    PageReference pageRef = Page.AddLeadFromCaseToCampaign;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new AddLeadFromCaseToCampaignContMock());

        AddLeadFromCaseToCampaignController cac = new AddLeadFromCaseToCampaignController();
        cac.getPhoneTypes();
	}


	@isTest static void  getRecruitmentCampaignsList(){
		Campaign cmp = new Campaign();
	    cmp.Name = 'testCampaign';
	    cmp.LeadRecType__c = 'St_Jude_Challenge';
	    cmp.IsRecruited__c = true;
	    insert cmp;

	    System.debug('cmp = ' + cmp.Id);

	    C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;


	    cmp = [select LeadRecType__c from Campaign where Id = :cmp.Id];
	     
	    Test.startTest();
	    PageReference pageRef = Page.AddLeadFromCaseToCampaign;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new AddLeadFromCaseToCampaignContMock());

        AddLeadFromCaseToCampaignController cac = new AddLeadFromCaseToCampaignController();
        cac.getRecruitmentCampaignsList();
       // dict.put(getCampList.Id, getCampList.name);
	}

	global class AddLeadFromCaseToCampaignContMock implements WebServiceMock {
        global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            // Create response element from the autogenerated class.
            // Populate response element.
            // Add response element to the response parameter, as follows:
            if (requestName == 'DataRequest') {
                soapStjudeOrg.DataResponse_element de = new soapStjudeOrg.DataResponse_element();
                objectSoapStjudeOrg.Attribute att = new objectSoapStjudeOrg.Attribute();

                att.Desc_x = 'xyz';
                att.ID = 'abc';
                att.Name = 'name';

                objectSoapStjudeOrg.Attribute[] atts = new objectSoapStjudeOrg.Attribute[] 
                { att };

                de.Result = atts;
                response.put('response_x', de);
            }
            else if(requestName == 'SearchConstituents360Request') {
                soapStjudeOrg.SearchConstituents360Response_element gcre = new soapStjudeOrg.SearchConstituents360Response_element();
                gcre.TotalResults = 9;
                objectSoapStjudeOrg.SearchResponse con = new objectSoapStjudeOrg.SearchResponse();

                domainSoapStjudeOrg.Sys sys = new domainSoapStjudeOrg.Sys();

                sys.Name = 'DMS';

                domainSoapStjudeOrg.SystemXRef xref = new domainSoapStjudeOrg.SystemXRef();

                xref.Sys = sys;
                xref.XRefKey = 'test';
                xref.AlternateXRefKey = 'test';

                domainSoapStjudeOrg.SystemXRefs xrefs = new domainSoapStjudeOrg.SystemXRefs();

                xrefs.SystemXRef = new domainSoapStjudeOrg.SystemXRef[] { xref };

                con.SystemXRefs = xrefs;

            gcre.Constituents = new objectSoapStjudeOrg.SearchResponse[] { con };
            gcre.TotalResults = 50;
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetConstituentRequest') {
                soapStjudeOrg.GetConstituentResponse_element gcre = new soapStjudeOrg.GetConstituentResponse_element();
                gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                gcre.Constituent.ConstituentId = 'notaguid';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.lastName = 'test';
                gcre.Constituent.Type_x = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Type_x.Code = 'INDIVIDUAL';
                gcre.Constituent.Profile = new domainSoapStjudeOrg.Profile();
                domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
                ph.ContactID = 'doesnt';
                ph.PhoneNumber = '1231231234';
                ph.PhoneType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Phones = new domainSoapStjudeOrg.Phone[] { ph };
                
                response.put('response_x', gcre); 
            }
            
            else if(requestName == 'GetConstituentXRefsRequest') {
                soapStjudeOrg.GetConstituentXRefsResponse_element gcre = new soapStjudeOrg.GetConstituentXRefsResponse_element();
                gcre.Constituent360XRef = new  domainSoapStjudeOrg.Constituent360XRef();
                domainSoapStjudeOrg.Constituent con = new domainSoapStjudeOrg.Constituent();
                con.ConstituentId = 'test';

                domainSoapStjudeOrg.Sys sys = new domainSoapStjudeOrg.Sys();

                sys.Name = 'DMS';

                domainSoapStjudeOrg.SystemXRef xref = new domainSoapStjudeOrg.SystemXRef();

                xref.Sys = sys;
                xref.XRefKey = 'test';
                xref.AlternateXRefKey = 'test';

                con.SystemXRef = xref;
                //con.SystemXRef.Sys.Name = 'DMS';
                

                gcre.Constituent360XRef.Constituents = new domainSoapStjudeOrg.Constituent[] {con};

                response.put('response_x', gcre); 
            }
            else {
                soapStjudeOrg.CreateConstituentResponse_element ccre = new soapStjudeOrg.CreateConstituentResponse_element();
                ccre.CreatedConstituent = new domainSoapStjudeOrg.Constituent();
                ccre.CreatedConstituent.ConstituentId = 'notaguid';
                response.put('response_x', ccre); 
            }
        }
    }


	
}