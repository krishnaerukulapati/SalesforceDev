@isTest
global class EVMUtilTest {
    
    @isTest static void mostEVMUtil() {

        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        objectSoapStjudeOrg.Attribute att = new objectSoapStjudeOrg.Attribute();

        att.Desc_x = 'xyz';
        att.ID = 'abc';
        att.Name = 'name';

        objectSoapStjudeOrg.Attribute[] atts = new objectSoapStjudeOrg.Attribute[] {att};

        Test.startTest();
        Test.setMock(WebServiceMock.class, new EVMUtilMock());

        EVMUtil.createConstituentInfos('String uuId', c.id, 'String prefConsId');
        EVMUtil.JavaDateStringToDate('2009-01-01');
        EVMUtil.JavaDateStringToDateTime('2009-01-01');
        EVMUtil.getCurrCase(c.id);
        EVMUtil.createTask(c.id, 'test', 'test', 'test', new String[] {'a', 'b'}, new String[] {'a', 'b'});
        
        EVMUtil.getSelectFromFOAtt(atts);
        EVMUtil.getToken();
        EVMUtil.deFormatPhone('1231231234');
        EVMUtil.formatPhone('1231231234');
        EVMUtil.getConstituentInformationByCase('test', 'test');
        EVMUtil.clearCons(c.Id);
        //EVMUtil.resetCaseConstituent(c, 'test', 'test', 'test', 'test');
        
        EVMUtil.consInfo ci = new EVMUtil.consInfo();
        ci.consId = 'test';
        ci.objectId = 'test';
        
        EVMUtil.getConstituentInformationByConsInfo(ci);

        Test.stopTest();
    }

    @isTest static void EVMDeceasedUtil() {

        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        objectSoapStjudeOrg.Attribute att = new objectSoapStjudeOrg.Attribute();

        att.Desc_x = 'xyz';
        att.ID = 'abc';
        att.Name = 'name';

        objectSoapStjudeOrg.Attribute[] atts = new objectSoapStjudeOrg.Attribute[] {att};

        Test.startTest();
        Test.setMock(WebServiceMock.class, new EVMUtilMock());
        EVMUtil.createDeceasedPrefs('test', true, 'test', 'test');

        Test.stopTest();
    }


    @isTest static void groupStuff() {

        User u = [select id, TimeZoneSidKey from user limit 1];

        Group g = new Group();
        g.Name = 'test';
        insert g;
        GroupMember gm = new GroupMember();
        gm.GroupId = g.id;
        gm.UserOrGroupId = u.id;
        insert gm;

        Test.startTest();
        EVMUtil.GetUserIdsFromGroup(g.Id);
        Test.stopTest();
    }
    
    @isTest static void  testResetCaseConstituent(){
        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;      
        EVMUtil.getTypeById(c.id);
        EVMUtil.getConsInfo(c.id);
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new EVMUtilMock());
        EVMUtil.ResetCaseConstituent(c, null, 'consname', c.ConstituentType__c, c.ConstituentID__c);
        Test.stopTest();
    }

	@isTest static void testCreateTaskOpp() {
		Opportunity opp = new Opportunity(
            Name = 'test',
            StageChanged__c = System.today(),
            Probability = 0.0,
            Stagename = 'Staged', 
            CloseDate=System.today());
        insert opp;

		Test.startTest();
		Task t = new Task();

		t = EVMUtil.createTask(opp, 'subject', 'status', 'aftervalue', 'coordId');
		Test.stopTest();
	}

	@isTest static void testGetToken() {
		Test.startTest();

		string t = EVMUtil.getToken('test');
		Test.stopTest();
	}

	@isTest static void testCreateLeadReferral() {
		Account a = new Account(Name = 'ALSAC Challenge');
        insert a;

		Campaign c = new Campaign(
            Name = 'Test parent PCampaign'
            , EventId__c = '1234'
            , OppRecordType__c = 'ECC Campaign'
            , OppAcc__c = a.Id);
        insert c;

		RecordType rt = [select id from RecordType where DeveloperName = 'St_Jude_Challenge' and SObjectType = 'Lead'];
		
		Test.startTest();

		Id t1 = EVMUtil.CreateLeadReferral(c.Id, 'consId', 'Individual', 'test', rt.Id, 'phone');
		Id t2 = EVMUtil.CreateLeadReferral(c.Id, 'consId', 'Organization', 'test', rt.Id, 'phone');

		try {
			Id t3 = EVMUtil.CreateLeadReferral(c.Id, 'consId', 'None', 'test', rt.Id, 'phone');
		}
		catch(exception ex) {
			string e = ex.getMessage();
		}
		
		Test.stopTest();
	}
	
    @isTest static void testgetConstituentIdsForSelect(){
        ConstituentInformation__c conInfo = new ConstituentInformation__c(ConstituentID__c='test');
        EVMUtil.getConstituentIdsForSelect(new ConstituentInformation__c[]{coninfo});
    }
    
    @isTest static void testGetConsInfo(){
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Lead l = new Lead();
        l.LastName = 'hello';
        l.Company = 'company';
        l.account_id__c = '123456';
        upsert l;
        EVMUtil.getXRefFromLead(l);
        
        EVMUtil.consInfo ci = new EVMUtil.consInfo();
        ci.objectId = l.id;
        ci.objecttype='Lead';
        EVMUtil.createTask(ci, 'test', 'test', 'test', new String[] {'a', 'b'}, new String[] {'a', 'b'}); 
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EVMUtilMock());
        EVMUtil.GetConsInfo(l.id);
        
    }
    @isTest static void testReplaceCoordinator(){
      EnvironmentSettings__c ensett = new EnvironmentSettings__c(setupOwnerId = UserInfo.getOrganizationId(),
                                                                 EVMCoordinatorRoleID__c='xxxx', EVMActiveStatusID__c='yyy', 
                                                                 EVMDeletedStatusID__c='status');
      insert ensett;
      try{  
          
       
       	EVMUtil.ReplaceCoordinator('test','test');  
      }catch(Exception e){
          
      }
    }
    
    global class EVMUtilMock implements WebServiceMock {
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
            system.debug('\n\n requestName @@@@@@@@@@@@@@@@: ' + requestName);    
            // Create response element from the autogenerated class.
            // Populate response element.
            // Add response element to the response parameter, as follows:
            if(requestName == 'GetConstituentXRefsRequest') {
                soapStjudeOrg.GetConstituentXRefsResponse_element gcre = new soapStjudeOrg.GetConstituentXRefsResponse_element();
                gcre.Constituent360XRef = new  domainSoapStjudeOrg.Constituent360XRef();
                domainSoapStjudeOrg.Constituent con = new domainSoapStjudeOrg.Constituent();
                con.ConstituentId = 'test';

                gcre.Constituent360XRef.Constituents = new domainSoapStjudeOrg.Constituent[] {con};

                response.put('response_x', gcre); 
            }
            else if (requestName == 'CreateInteractionRequest') {
                soapStjudeOrg.CreateInteractionResponse_element cire = new soapStjudeOrg.CreateInteractionResponse_element();
                cire.Result = 'result';

                response.put('response_x', cire);
            }
            else if(requestName == 'GetPreferencesRequest') {
                soapStjudeOrg.GetPreferencesResponse_element ecre = new soapStjudeOrg.GetPreferencesResponse_element();
                domainSoapStjudeOrg.Preference p = new domainSoapStjudeOrg.Preference();
                p.ConstituentPreferenceID = 'doesnt';
                ecre.Preferences = new domainSoapStjudeOrg.Preference[] { p };
                response.put('response_x', ecre); 
            }
            else if(requestName == 'EditPreferenceRequest') {
                soapStjudeOrg.EditPreferenceResponse_element ecre = new soapStjudeOrg.EditPreferenceResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'CreatePreferenceRequest') {
                soapStjudeOrg.CreatePreferenceResponse_element ecre = new soapStjudeOrg.CreatePreferenceResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }else if(requestName == 'GetConstituentRequest'){
                
                soapStjudeOrg.GetConstituentResponse_element getConst = new soapStjudeOrg.GetConstituentResponse_element();
                getConst.Constituent = new domainSoapStjudeOrg.Constituent();
                domainSoapStjudeOrg.TypeAttribute type_x = new domainSoapStjudeOrg.TypeAttribute();
                type_x.code='code';
                getConst.Constituent.type_x = type_x;
                getConst.Constituent.uuid='uuid';
                response.put('response_x', getConst);
            }
        }
    }
}