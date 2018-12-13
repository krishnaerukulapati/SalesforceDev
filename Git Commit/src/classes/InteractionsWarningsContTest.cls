@isTest
global class InteractionsWarningsContTest {

	@TestSetup static void c360Setup(){
		C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
	}
	
	@isTest static void reload_with_success_response() {

		Test.startTest();
		Test.setMock(WebServiceMock.class, new InteractionWarningsContMock());

		InteractionWarningsController iwc = new InteractionWarningsController();
		iwc.modConsId = 'test';

		Continuation cont;
		cont = reLoadWarnings(cont, iwc, true);

		System.assertEquals(null, cont);

		cont = iwc.reLoadWarnings();

		Test.stopTest();
	}

	@isTest static void reload_can_handle_calloutException() {

		Test.startTest();
		Test.setMock(WebServiceMock.class, new InteractionWarningsContMock());

		InteractionWarningsController iwc = new InteractionWarningsController();
		iwc.modConsId = 'test';

		Continuation cont;
		cont = reLoadWarnings(cont, iwc, false);

		cont = iwc.reLoadWarnings();

		Test.stopTest();
	}

	
	private static Continuation reLoadWarnings(Continuation cont, InteractionWarningsController iwc, Boolean success) {
		cont = iwc.reLoadWarnings();
		Map<String, HttpRequest> requests = cont.getRequests();
		System.assertEquals(requests.size(), 1);

		HttpResponse response = new HttpResponse();
		if (success){
			response.setBody(GetInteractionsWithWarning());	
		}
		else{
			response.setBody(GetInteractionsWithCalloutException());		
		}

		String requestLabel = requests.keySet().iterator().next();
		Test.setContinuationResponse(requestLabel, response);

		cont = (Continuation)Test.invokeContinuationMethod(iwc, cont);
		return cont;
	}

	private static String GetInteractionsWithWarning(){
		return
			'<S:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">' +
   			'<env:Header/>' +
   			'<S:Body>' +
      		'<GetInteractionsResponse xmlns="urn:soap.stjude.org" xmlns:ns0="urn:fault.soap.stjude.org" xmlns:ns2="urn:object.soap.stjude.org" xmlns:ns1="urn:domain.soap.stjude.org">' +
         	'<TotalResults>1</TotalResults>' +
         	'<Interactions>' +
            '<ns1:ContactDate>2014-08-26</ns1:ContactDate>' +
            '<ns1:LongComments>WARNING: GP Assigned DONOR: Please forward calls and mail to Gift Planning Stewardship Team. Do not change staff assignment or classification without first speaking with Gift Planning Management Team.</ns1:LongComments>' +
            '<ns1:Warning>Y</ns1:Warning>' +
         	'</Interactions>' +
      		'</GetInteractionsResponse>' +
   			'</S:Body>' +
			'</S:Envelope>';
	}

	private static String GetInteractionsWithOutWarning(){
		return 
			'<S:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">' +
   			'<env:Header/>' +
   			'<S:Body>' +
      		'<GetInteractionsResponse xmlns="urn:soap.stjude.org" xmlns:ns0="urn:fault.soap.stjude.org" xmlns:ns2="urn:object.soap.stjude.org" xmlns:ns1="urn:domain.soap.stjude.org">' +
         	'<TotalResults>0</TotalResults>' +
      		'</GetInteractionsResponse>' +
   			'</S:Body>' +
			'</S:Envelope>';
	}

	private static String GetInteractionsWithCalloutException(){
		return 
			'<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">' +
   			'<S:Body>' +
      		'<ns0:Fault xmlns:ns1="http://www.w3.org/2003/05/soap-envelope" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/">' +
        	'<faultcode>ns0:Server</faultcode>' +
        	'<faultstring>Service Exception</faultstring>' +
        	'<detail>' +
        	'<ns0:ServiceFault xmlns:ns0="urn:fault.soap.stjude.org" xmlns="urn:soap.stjude.org" xmlns:ns1="urn:domain.soap.stjude.org" xmlns:ns2="urn:object.soap.stjude.org">' +
        	'<ns0:Message>Failed to get cross reference key</ns0:Message>' +
        	'</ns0:ServiceFault>' +
        	'</detail>' +
      		'</ns0:Fault>' +
   			'</S:Body>' +
			'</S:Envelope>';
	}

	global class InteractionWarningsContMock implements WebServiceMock {
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
            System.debug('requestName = ' + requestName);
            //don't do anything anymore. have to actually provide fake xml responses
            // :(   <---------- sadness
        }    
    }
	
}