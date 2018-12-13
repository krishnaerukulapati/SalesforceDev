@isTest
global class ECCUtilTest {
    @isTest static void CanGetCampaignById()
    {
        Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        insert c;

        Test.startTest();

        Campaign result = ECCUtil.GetCampaignById(c.Id);
        system.assert(result != null);
        system.assert(result.Name == 'Test Campaign');

        Test.stopTest();
    }

    @isTest static void CanGetCampaignsInProgressAndPlanned()
    {
        Campaign c = new Campaign();
        c.Name = 'Test Campaign';
        c.Status = 'Planned';
       insert c;

        Campaign c2 = new Campaign();
        c2.Name = 'Test Campaign';
        c2.Status = 'In Progress';
        insert c2;

        Test.startTest();

        List<Campaign> result = ECCUtil.GetCampaignsInProgressAndPlanned();
        system.assert(result != null);
        system.assert(result.size() == 0);

        Test.stopTest();
    }

    @isTest static void mostECCUtil() {

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
        Test.setMock(WebServiceMock.class, new ECCUtilMock());

        ECCUtil.createConstituentInfos('String uuId', c.id, 'String prefConsId');
        ECCUtil.JavaDateStringToDate('2009-01-01');
        ECCUtil.JavaDateStringToDateTime('2009-01-01');
        ECCUtil.getCurrCase(c.id);
        ECCUtil.createTask(c.id, 'test', 'test', 'test', new String[] {'a', 'b'}, new String[] {'a', 'b'});
        
        ECCUtil.getSelectFromC360Att(atts);
        ECCUtil.getToken();
        ECCUtil.deFormatPhone('1231231234');
        ECCUtil.formatPhone('1231231234');
        ECCUtil.getConstituentInformationByCase('test', 'test');
        ECCUtil.clearCons(c.Id);
        //ECCUtil.resetCaseConstituent(c, 'test', 'test', 'test', 'test');
        
        ECCUtil.consInfo ci = new ECCUtil.consInfo();
        ci.consId = 'test';
        ci.objectId = 'test';
        
        ECCUtil.getConstituentInformationByConsInfo(ci);

        Test.stopTest();
    }

    @isTest static void ECCDeceasedUtil() {

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
        Test.setMock(WebServiceMock.class, new ECCUtilMock());
        ECCUtil.createDeceasedPrefs('test', true, 'test', 'test');

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
        ECCUtil.GetUserIdsFromGroup(g.Id);
        Test.stopTest();
    }
    
    @isTest static void  testResetCaseConstituent(){
        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;      
        ECCUtil.getTypeById(c.id);
        ECCUtil.getConsInfo(c.id);
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new ECCUtilMock());
        ECCUtil.ResetCaseConstituent(c, null, 'consname', c.ConstituentType__c, c.ConstituentID__c);
        Test.stopTest();
    }
    
    @isTest static void testgetConstituentIdsForSelect(){
        ConstituentInformation__c conInfo = new ConstituentInformation__c(ConstituentID__c='test');
        ECCUtil.getConstituentIdsForSelect(new ConstituentInformation__c[]{coninfo});
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
        ECCUtil.getXRefFromLead(l);
        
        ECCUtil.consInfo ci = new ECCUtil.consInfo();
        ci.objectId = l.id;
        ci.objecttype='Lead';
        ECCUtil.createTask(ci, 'test', 'test', 'test', new String[] {'a', 'b'}, new String[] {'a', 'b'}); 
        Test.startTest();
        Test.setMock(WebServiceMock.class, new ECCUtilMock());
        ECCUtil.GetConsInfo(l.id);
        
    }
    @isTest static void testReplaceCoordinator(){
      EnvironmentSettings__c ensett = new EnvironmentSettings__c(setupOwnerId = UserInfo.getOrganizationId(),
                                                                 EVMCoordinatorRoleID__c='xxxx', EVMActiveStatusID__c='yyy', 
                                                                 EVMDeletedStatusID__c='status');
      insert ensett;
      try{  
          
       
        ECCUtil.ReplaceCoordinator('test','test');  
      }catch(Exception e){
          
      }
    }

    @isTest static void testProcessInteraction(){
        Lead ld = new Lead();
        Task tsk = new Task();
        CampaignDispConfig__c dispConfig = new CampaignDispConfig__c();

        Test.startTest();
        ECCUtil.processInteraction(ld, tsk, dispConfig);
        dispConfig.SourceCode__c = 'test';
        ECCUtil.processInteraction(ld, tsk, dispConfig);
        Test.stopTest();
    }

    @isTest static void testGetSourceCode(){
        ECCUtil.getSourceCode('notblank', 'longerThanNine');
    }

    @isTest static void testSSLeads(){
        ECCUtil.SSLeads SSLeads_inst = new ECCUtil.SSLeads();
        SSLeads_inst.EventTypeId = 'test';
        SSLeads_inst.EventRoleId = 'test';
    }

    @isTest static void testProcessCaseEmailUpdate(){
        Case c = new Case();
        insert c;

        Test.startTest();
        ECCUtil.processCaseEmailUpdate(c, 'Email Address');
        ECCUtil.processCaseEmailUpdate(c, 'NotEmailAddress');
        Test.stopTest();
    }

    @isTest static void testProcessLeadEmailPhoneUpdate(){
        ECCUtil.SSLeads currLead = new ECCUtil.SSLeads();
        Lead lead = new Lead();
        lead.Email = 'notEqualToEmail';
        lead.Phone = 'notEqualToPhone';
        currLead.SSLead = lead;

        Test.startTest();
        ECCUtil.processLeadEmailPhoneUpdate(currLead, 'Email Address', 'Phone Number');
        ECCUtil.processLeadEmailPhoneUpdate(currLead, 'NotEmailAddress', 'NotPhoneNumber');
        Test.stopTest();
    }

    @isTest static void testHasCustomPermissions(){
        Test.startTest();
        ECCUtil.hasCustomPermissions('ViewLongComments');
        Test.stopTest();
    }

    @isTest static void testGetUserProfileId(){
        Test.startTest();
        ECCUtil.getUserProfileId();
        Test.stopTest();
    }

    @isTest static void testHasProperties(){
        domainSoapStjudeOrg.Constituent p = new domainSoapStjudeOrg.Constituent();
        domainSoapStjudeOrg.Property properties = new domainSoapStjudeOrg.Property();
        properties.Property = 'VIP_YES';
        properties.Status = 'ACTIVE';
        p.Properties = new domainSoapStjudeOrg.Property[] { properties };
        String[] propertyNames = new string[] {'VIP_YES'};
        Boolean anyProp = true;

        Test.startTest();
        ECCUtil.hasProperty(p, propertyNames, anyProp);
        Test.stopTest();
    }

    @isTest static void testHasPreferences(){
        domainSoapStjudeOrg.Constituent p = new domainSoapStjudeOrg.Constituent();
        domainSoapStjudeOrg.Preference preferences = new domainSoapStjudeOrg.Preference();
        preferences.Preference = 'GPFDN';
        preferences.PreferenceValue = 'Y';
        preferences.Status = 'ACTIVE';
        p.Preferences = new domainSoapStjudeOrg.Preference[] { preferences };
        List<List<String>> preferenceMatches = new List<List<String>>{
            new String[]{'GPFDN', 'Y'},
            new String[]{'GPLEGACY', 'Y'}
        };
        Boolean anyPref = true;

        Test.startTest();
        ECCUtil.hasPreference(p, preferenceMatches, anyPref);
        Test.stopTest();
    }
    
    global class ECCUtilMock implements WebServiceMock {
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