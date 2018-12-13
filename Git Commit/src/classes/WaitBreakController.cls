public with sharing class WaitBreakController {

	public WaitBreakController(ApexPages.StandardController controller) {
		init();
	}

	public void init(){
		buildHttpRequestLoop();
	}

	private static void buildHttpRequestLoop(){
		HttpRequest req = new HttpRequest();
		req.setEndpoint('https://servicesdev.qa.stjude.org/odata/api/WaitBreak/'); //This will change from dev to QA
		req.setMethod('GET');
		req.setTimeout(120000);

		String username = 'alsacnt\\eventmasterqa';
		String password = 'a1evt$QA';

		Blob headerValue = Blob.valueOf(username + ':' + password);
		String authorizationHeader = 'BASIC ' +
		EncodingUtil.base64Encode(headerValue);
		System.debug('authorizationHeader = ' + authorizationHeader);
		req.setHeader('Authorization', authorizationHeader);
		System.debug('request = ' + req);

		Http http = new Http();
		HttpResponse res = http.send(req);
		System.debug('start of body = ' + res.getBody());
	}

}