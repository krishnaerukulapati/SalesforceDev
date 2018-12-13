public with sharing class ECCEventsSegHelper {
	public ECCEventsSegHelper() {
		
	}

	 public static String getTotalRevenue(String eventId){
        System.debug('eventId in getTotalRevenue = ' + eventId);
        EventRevenues__x evtRev = OdataExtension.GetEventRevenueById(eventId);
         System.debug('evtRev in getTotalRevenue = ' + evtRev);
        if (evtRev != null && evtRev.Amount__c != null){
            return String.ValueOf(evtRev.Amount__c.setScale(2));
      }else{
       return '0';
      } 
    }
}