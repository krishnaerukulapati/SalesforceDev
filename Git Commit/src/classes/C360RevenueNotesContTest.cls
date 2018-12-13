@isTest
global class C360RevenueNotesContTest {
	public string consId {get; private set;}
    public string transId {get; private set;}
    public string FinancialTransactionID {get; private set;}
	
	@isTest static void testC360RevenueNotes() {

		Case c = new Case();
		c.ConstituentID__c = 'notaquid';
		c.ConstituentType__c = 'INDIVIDUAL';
        insert c;

        ConstituentInformation__c ci = new ConstituentInformation__c();
        ci.ConstituentId__c = 'notaguid';
        ci.CaseId__c = c.id;
        ci.Preferred__c = true;
        insert ci;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360RevenueNotes;
        Test.setCurrentPage(pageRef);

        Test.setMock(WebServiceMock.class, new C360RevenueNotesMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('consId', 'consId');
        ApexPages.currentPage().getParameters().put('transId', 'transId'); 
        C360RevenueNotesController.getTransactionPage('test','test', 1, 2);
        C360RevenueNotesController ccac = new C360RevenueNotesController(new ApexPages.StandardController(c));
        ccac.nextPage();
      	ccac.prevPage();
    	ccac.getRevenueNotesList();	
		Test.stopTest();
	}

    global class C360RevenueNotesMock implements WebServiceMock {
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
            system.debug('requestName = ' + requestName);    
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
            }else if (requestName == 'GetTransactionsRequest') { 
                soapStjudeOrg.GetTransactionsResponse_element de = new soapStjudeOrg.GetTransactionsResponse_element();
                de.TotalResults = 50; 

                de.Transactions = new List<domainSoapStjudeOrg.Transaction_x>(); 
                domainsoapstjudeorg.transaction_x var = new domainsoapstjudeorg.transaction_x();
                var.FinancialTransactionID = 'notaguid';
                var.RevenueNotes = new List<domainSoapStjudeOrg.RevenueNote> { new domainSoapStjudeOrg.RevenueNote() };
                de.Transactions.add(var);
                response.put('response_x', de);


            }
        }
    }
}