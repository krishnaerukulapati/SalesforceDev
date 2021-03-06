@isTest
global class FOTransactionDetailContTest {
	
	@isTest static void ViewTransactions() {
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
        PageReference pageRef = Page.FOInteraction;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOTransactionDetailContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        FOTransactionDetailController ccac = new FOTransactionDetailController(new ApexPages.StandardController(c));

        FOTransactionDetailController.getRefunds(c.Id);
        FOTransactionDetailController.getTransactionPage('test', 1, 2);
        ccac.changeCons();
        FOTransactionDetailController.addRefundRequestItems(getJsonTran(), 'test', null, c.id, 'test', 'Case');
        FOTransactionDetailController.addSourceCodeChangeItems(getJsonTran(), 'test', null, c.id, 'test', 'Case');
        FOTransactionDetailController.addSoftCreditItems(getJsonTran(), 'test', null, c.id, 'test', 'Case');
       	ccac.getItems();
	
		Test.stopTest();
	}
	
    global class FOTransactionDetailContMock implements WebServiceMock {
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