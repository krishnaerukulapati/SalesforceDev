@isTest
global class C360TransactionDetailContTest {

    @isTest static void c360TransTestForCase(){
        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        insert c;

        CustomSettings__c cst = new CustomSettings__c(
            Name = 'FundRaiserLink'
            , Value__c = '1234'
            );
        insert cst;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360Interactions;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360TransactionDetailContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        C360TransactionDetailController ccac = new C360TransactionDetailController(new ApexPages.StandardController(c));

        C360TransactionDetailController.getRefunds(c.Id);
        C360TransactionDetailController.getTransactionPage('test', 1, 2);
        ccac.changeCons();
        C360TransactionDetailController.addRefundRequestItems(getJsonTran(), 'test', null, c.id, 'test', 'Case');
        C360TransactionDetailController.addSourceCodeChangeItems(getJsonTran(), 'test', null, c.id, 'test', 'Case');
        C360TransactionDetailController.addSoftCreditItems(getJsonTran(), 'test', null, c.id, 'test', 'Case');
        C360TransactionDetailController.addMoveGifts(getJsonTran(), 'test', null, c.id, 'test', 'Case');
        ccac.getItems();

        Test.stopTest();
    }

    @isTest static void c360TransTestForLead(){
        Lead l = new Lead();
        l.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
        l.Constituent_Type__c = 'INDIVIDUAL';
        l.Company = 'fake';
        l.LastName = 'test';
        l.TR_ID__c = '123456';
        l.EventID__c = '123456';
        l.XREF__c = '123456|TEST';
        insert l;

        CustomSettings__c cst = new CustomSettings__c(
            Name = 'FundRaiserLink'
            , Value__c = '1234'
            );
        insert cst;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360TransactionDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360TransactionDetailContMock());

        ApexPages.currentPage().getParameters().put('id', l.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        C360TransactionDetailController ccac = new C360TransactionDetailController(new ApexPages.StandardController(l));

        Test.stopTest();
    }
	
    global class C360TransactionDetailContMock implements WebServiceMock {
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
            if (requestName == 'GetTransactionsRequest') {
                soapStjudeOrg.GetTransactionsResponse_element de = new soapStjudeOrg.GetTransactionsResponse_element();
                de.TotalResults = 50;

                response.put('response_x', de);
            }
            else if(requestName == 'GetConstituentRequest') {
                soapStjudeOrg.GetConstituentResponse_element gcre = new soapStjudeOrg.GetConstituentResponse_element();
                gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                gcre.Constituent.ConstituentId = 'notaguid';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.lastName = 'test';
                gcre.Constituent.Title = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Title.Code = 'test';
                gcre.Constituent.Profile = new domainSoapStjudeOrg.Profile();
                domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
                ph.ContactID = 'doesnt';
                ph.PhoneNumber = '1231231234';
                ph.PhoneType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Phones = new domainSoapStjudeOrg.Phone[] { ph };

                domainSoapStjudeOrg.Email email = new domainSoapStjudeOrg.Email();
                email.EmailAddress = 'test@test.com';
                email.EmailType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Emails = new domainSoapStjudeOrg.Email[] { email };

                domainSoapStjudeOrg.Address addr = new domainSoapStjudeOrg.Address();
                addr.street1 = 'test';
                addr.AddressType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Addresses = new domainSoapStjudeOrg.Address[] { addr };

                domainSoapStjudeOrg.Property p = new domainSoapStjudeOrg.Property();
                p.Property = 'VIP_YES';
                gcre.Constituent.Properties = new domainSoapStjudeOrg.Property[] { p };

                domainSoapStjudeOrg.Preference pref = new domainSoapStjudeOrg.Preference();
                gcre.Constituent.Preferences = new domainSoapStjudeOrg.Preference[] {pref};

                domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();
                gcre.Constituent.Interactions = new domainSoapStjudeOrg.Interaction[] {i};

                domainSoapStjudeOrg.Staff stf = new domainSoapStjudeOrg.Staff();
                stf.Name = 'blah';
                gcre.Constituent.Staff = stf;

                domainSoapStjudeOrg.TypeAttribute typ = new domainSoapStjudeOrg.TypeAttribute();
                typ.Code = 'Individual';
                gcre.Constituent.Type_x = typ;

                gcre.Constituent.Profile.FinancialProfile = new domainSoapStjudeOrg.FinancialProfile();

                domainSoapStjudeOrg.Transaction_x trans = new domainSoapStjudeOrg.Transaction_x();
                trans.FinancialTransactionId = 'numbers';
                gcre.Constituent.Transactions = new domainSoapStjudeOrg.Transaction_x[] {trans};

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

    private static String getJsonTran() {
    	String json = '[{"apex_schema_type_info":["urn:domain.soap.stjude.org",' +
'"true",' +
'"false"],' +
'"ConstituentBase_type_info":["ConstituentBase",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"Currency_x":"USD",' +
'"Currency_x_type_info":["Currency",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"DateInserted":"2013-11-12T22:50:44.000-06:00",' +
'"DateInserted_type_info":["DateInserted",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"field_order_type_info":["TransactionXRef",' +
'"TransactionID",' +
'"SourceTransactionKey",' +
'"ConstituentBase",' +
'"TransactionType",' +
'"TransactionDesc",' +
'"GiftType",' +
'"GiftDate",' +
'"DateInserted",' +
'"GiftApplyMMYY",' +
'"PullDay",' +
'"PullMonth",' +
'"Frequency",' +
'"PledgeStatus",' +
'"Currency_x",' +
'"TotalPledgeAmount",' +
'"TotalPaidAmount",' +
'"PaymentAmount",' +
'"HoldFromDate",' +
'"HoldEndDate",' +
'"TransactionSource",' +
'"PaymentDetail",' +
'"TransactionHistory",' +
'"OpenBills"],' +
'"Frequency_type_info":["Frequency",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"GiftApplyMMYY_type_info":["GiftApplyMMYY",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"GiftDate":"2013-11-06T00:00:00.000-06:00",' +
'"GiftDate_type_info":["GiftDate",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"GiftType":"OnePayment",' +
'"GiftType_type_info":["GiftType",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"HoldEndDate_type_info":["HoldEndDate",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"HoldFromDate_type_info":["HoldFromDate",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"OpenBills_type_info":["OpenBills",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"-1",' +
'"false"],' +
'"PaymentAmount":30,' +
'"PaymentAmount_type_info":["PaymentAmount",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PaymentDetail":{"Alias_type_info":["Alias",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"apex_schema_type_info":["urn:domain.soap.stjude.org",' +
'"true",' +
'"false"],' +
'"CCExpirationDate_type_info":["CCExpirationDate",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"CCLast4":"1111",' +
'"CCLast4_type_info":["CCLast4",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"field_order_type_info":["PaymentMethod",' +
'"PaymentFName",' +
'"PaymentMName",' +
'"PaymentLName",' +
'"CCLast4",' +
'"CCExpirationDate",' +
'"Alias",' +
'"MerchantID",' +
'"MerchantRefCode",' +
'"RequestID",' +
'"RequestToken",' +
'"ReconciliationID"],' +
'"MerchantID_type_info":["MerchantID",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"MerchantRefCode_type_info":["MerchantRefCode",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PaymentFName_type_info":["PaymentFName",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PaymentLName_type_info":["PaymentLName",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PaymentMethod_type_info":["PaymentMethod",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PaymentMName_type_info":["PaymentMName",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"ReconciliationID_type_info":["ReconciliationID",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"RequestID_type_info":["RequestID",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"RequestToken_type_info":["RequestToken",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"]},' +
'"PaymentDetail_type_info":["PaymentDetail",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PledgeStatus_type_info":["PledgeStatus",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PullDay_type_info":["PullDay",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"PullMonth_type_info":["PullMonth",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"SourceTransactionKey_type_info":["SourceTransactionKey",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TotalPaidAmount":30,' +
'"TotalPaidAmount_type_info":["TotalPaidAmount",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TotalPledgeAmount":30,' +
'"TotalPledgeAmount_type_info":["TotalPledgeAmount",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TransactionDesc":"Donation",' +
'"TransactionDesc_type_info":["TransactionDesc",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TransactionHistory_type_info":["TransactionHistory",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"-1",' +
'"false"],' +
'"TransactionID_type_info":["TransactionID",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TransactionSource_type_info":["TransactionSource",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TransactionType":"Gift",' +
'"TransactionType_type_info":["TransactionType",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TransactionXRef":{"apex_schema_type_info":["urn:domain.soap.stjude.org",' +
'"true",' +
'"false"],' +
'"field_order_type_info":["Sys",' +
'"TxnXRefKey"],' +
'"Sys":{"apex_schema_type_info":["urn:domain.soap.stjude.org",' +
'"true",' +
'"false"],' +
'"field_order_type_info":["ID",' +
'"Name"],' +
'"ID_type_info":["ID",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"Name":"TA",' +
'"Name_type_info":["Name",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"]},' +
'"Sys_type_info":["Sys",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"],' +
'"TxnXRefKey":"12375808|11062013|1|1",' +
'"TxnXRefKey_type_info":["TxnXRefKey",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"]},' +
'"TransactionXRef_type_info":["TransactionXRef",' +
'"urn:domain.soap.stjude.org",' +
'"0",' +
'"1",' +
'"false"]}]';
    	return json;
    }
}