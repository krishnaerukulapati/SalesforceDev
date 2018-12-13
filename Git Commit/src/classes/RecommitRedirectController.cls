public with sharing class RecommitRedirectController {
	public String trConsId {get; private set;}
	public String eventId {get; private set;}
	public RecommitRedirectController() {	
		trConsId = EncodingUtil.base64Decode(System.currentPageReference().getParameters().get('trConsId')).toString();
		eventId = EncodingUtil.base64Decode(System.currentPageReference().getParameters().get('eventid')).toString();
		System.debug('ConsId: ' + trConsId);
		System.debug('EventId: ' + eventId);
	}
}