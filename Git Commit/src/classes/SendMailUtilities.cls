public with sharing class SendMailUtilities {
	public static String GetNonce (String username, String password) {
		// use the user/pwd to create a time-sensative nonce
		// DEFAULT uname/pwd to custom settings
		
		String md5Coded    = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(password)));
		String currentTime = string.valueOf(DateTime.Now().getTime());
		String hash        = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(currentTime + ':'
			+ username + ':' + md5Coded)));

		return EncodingUtil.base64Encode(Blob.valueOf(CurrentTime + ':' + username + ':' + hash));
	}

	public static String sendEmailObjectFromExternalServer
		(String emailbody, Id etsId, String recipemail, String subject, String fromEmail) 
	{
    	String pass;
		String user;
		String endPoint;

		List<CustomSettings__c> cs = [SELECT value__c, name from CustomSettings__c ];
		for(CustomSettings__c a : cs) {
			system.debug('a.name =' + a.name);

			if (a.name == 'EmailPass') {
				pass = a.value__c;
			}
			else if (a.name == 'EmailUser') {
				user = a.value__c;
			}
			else if (a.name == 'EmailServiceEndPoint') {
				endPoint = a.value__c;
			}
		}

		String sts;
        String nonce = GetNonce(user, pass);
        List<String>lstReqBody = new List<String>();

        String reqBody = 'recipientAddress=' + recipemail + '&subject=' + EncodingUtil.urlEncode(subject , 'UTF-8')
        	+'&payload=' + EncodingUtil.urlEncode(emailBody , 'UTF-8') + '&recipientExternalId=' + etsId;       

        reqBody +='&senderAddress='+ fromEmail;
        system.debug('reqBody =' + reqBody);
        if (system.isFuture() || system.isBatch()) {
            httprequest request = SendMailUtilities.PrepareHttpRequest('POST', reqBody,endPoint, nonce) ;
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
            //SendMailUtilities.makeEmailHTTPCall(request, respSts);
        	Http message = new Http();
			HttpResponse response = new HttpResponse();
			if (Test.isRunningTest()) {
				return 'OK';
			}
			response =  message.send(request);
			System.debug('response.getStatus()'+ response.getStatus());
			sts = response.getStatus();
        }
        else {
            lstReqBody.add(reqBody);                
        }
        return sts;   
   	}

	//private static void makeEmailHTTPCall(httprequest request, String respSts) {
	//	Http message = new Http();
	//	HttpResponse response = new HttpResponse();
	//	if (Test.isRunningTest()) {
	//		return;
	//	}
	//	response =  message.send(request);
	//	System.debug('rest response'+ response.getBody());
	//	respSts = response.getStatus();
	//	System.debug('respSts makeEmailHTTPCall: '+ respSts);
	//}

	public static httprequest PrepareHttpRequest(String method, String body, String endPoint, String Nonce) {
		// create an httprequest to send to external system
		HttpRequest request = new HttpRequest();
		request.setMethod(method);
		request.setHeader('Authorization', 'Digest ' + Nonce); 
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', 'application/json');
		request.setTimeout(20000); //this should be from custom setting

		if ( String.isNotEmpty(body) ) { 
			request.setBody(body); 
		}
		request.setEndpoint(endPoint);
		return request;          
	}
}