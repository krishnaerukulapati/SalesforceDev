public with sharing class OIMOrderListController {
    public List<V_OrderInfo__x> orders { get; set; }
    public String eventId { get; set; }
    public String relId { get; set; }
    public String leadId {get; private set;}
    public String leadType {get; private set;}
    public static final String fedexTracking = 'https://www.fedex.com/apps/fedextrack/?tracknumbers=';
    public static final String upsTracking = 'https://wwwapps.ups.com/WebTracking/track?trackNums=';
    public String orderTracking { get; set; }
    
	
	public OIMOrderListController() {
		init();
	}

	private void init() {
		eventId = System.currentPageReference().getParameters().get('eventId');
		relId = System.currentPageReference().getParameters().get('relId');
		leadId = System.currentPageReference().getParameters().get('id');
		System.debug('leadId = ' + leadId);
        leadType = System.currentPageReference().getParameters().get('leadType');
        System.debug('leadType = ' + leadType);
		system.debug(' eventId = ' + eventId + ' relId = ' + relId);
		String q = 'select EventID__c, OrderId__c, ShipmentMethodDisplay__c, DateOrdered__c, DateToShip__c' +
			', DateSubmitted__c, DateShipped__c, createdBy__c, StatusDisplay__c, LineItemCount__c' + 
            ', IsPriority__c, Status__c, ShipmentMethodId__c, ExternalOrderKey__c, TrackingNumber__c  ' + 
            'from V_OrderInfo__x ' + 
            'where EventID__c = \'' + eventId + '\'';
		orders = OdataExtension.V_OrderInfoQuery(q, null);
	}
}