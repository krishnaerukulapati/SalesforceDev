@isTest
global class EventHistoryControllerTest{
    static testMethod void testForLeadOrg(){
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        ld.ConstituentID__c = Guid.createGuid();
        insert ld;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        CustomSettings__c cs = new CustomSettings__c();
        cs.Value__c = 'test123';
        cs.Name = 'EventsRecruitment';
        insert cs;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new EventHistorySummaryMock());
        PageReference pf = page.EventHistorySummary;
        test.setCurrentPage(pf);
        pf.getParameters().put('id', ld.Id);
        
        EventHistorySummaryController eObj = new EventHistorySummaryController();
        String output = eObj.getEventsMasteringURL();
        system.assert(output != null);

        output = eObj.getNonce();
        system.assert(output != null);

        test.stopTest();
    }

    static testMethod void canLoadEventModel()
    {
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        ld.ConstituentID__c = Guid.createGuid();
        insert ld;
        RecruitedEvents__x re = new RecruitedEvents__x();
        EventHistorySummaries__x ehs = new EventHistorySummaries__x();

        Test.startTest();
        Test.setMock(WebServiceMock.class, new EventHistorySummaryMock());
        PageReference pf = page.EventHistorySummary;
        test.setCurrentPage(pf);
        pf.getParameters().put('id', ld.Id);
        
        EventHistorySummaryController eObj = new EventHistorySummaryController();
        EventHistorySummaryController.EventViewModel model = new EventHistorySummaryController.EventViewModel(new EventRevenues__x(), new EventHistorySummaries__x());   
        system.assert(model.Summary.SystemOfOrigin__c == 'N/A');
        test.stopTest();
    }

    static testMethod void testForLeadCoord(){
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        ld.Coordinator__c = Guid.createGuid();
        insert ld;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EventHistorySummaryMock());
        PageReference pf = page.EventHistorySummary;
        test.setCurrentPage(pf);
        pf.getParameters().put('id', ld.Id);
        pf.getParameters().put('leadRelType', 'COORDINATOR');

        EventHistorySummaryController eObj = new EventHistorySummaryController();
        
        test.stopTest();
    }
    
    static testMethod void testNextPage()
    {
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        ld.Coordinator__c = Guid.createGuid();
        insert ld;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EventHistorySummaryMock());
        PageReference pf = page.EventHistorySummary;
        test.setCurrentPage(pf);
        pf.getParameters().put('id', ld.Id);
        pf.getParameters().put('leadRelType', 'COORDINATOR');

        EventHistorySummaryController eObj = new EventHistorySummaryController();
        eObj.totalPages = 20;
        Integer pageIndex = eObj.currPage;
        system.debug('pageIndex='+pageIndex);
        PageReference pr = eObj.nextPage();
        system.debug('eObj.currPage='+eObj.currPage);
        system.assert(eObj.currPage==pageIndex+1);
        test.stopTest();
    }

    static testMethod void testPreviousPage()
    {
        Lead ld = new Lead();
        ld.LastNAme = 'lastName';
        ld.status = 'New';
        ld.company  = 'Company';
        ld.Coordinator__c = Guid.createGuid();
        insert ld;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new EventHistorySummaryMock());
        PageReference pf = page.EventHistorySummary;
        test.setCurrentPage(pf);
        pf.getParameters().put('id', ld.Id);
        pf.getParameters().put('leadRelType', 'COORDINATOR');

        EventHistorySummaryController eObj = new EventHistorySummaryController();
        eObj.totalPages = 20;
        eObj.currPage = 5;
        Integer pageIndex = eObj.currPage;
        system.debug('pageIndex='+pageIndex);
        PageReference pr = eObj.prevPage();
        system.debug('eObj.currPage='+eObj.currPage);
        system.assert(eObj.currPage==pageIndex-1);
        test.stopTest();
    }

    static testMethod void testForCase(){
        Case cs = new Case();
        cs.Subject = 'Test Case';
        cs.ConstituentID__c = Guid.createGuid();
        insert cs;
        
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new EventHistorySummaryMock());
        PageReference pf = page.EventHistorySummary;
        test.setCurrentPage(pf);
        pf.getParameters().put('id', cs.Id);
        
        EventHistorySummaryController eObj = new EventHistorySummaryController();
        
        test.stopTest();
    }
    
    global class EventHistorySummaryMock implements WebServiceMock {
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