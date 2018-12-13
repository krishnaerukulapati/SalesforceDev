@isTest
global class ECCRevenuesControllerTest{
    @isTest static void RevenueSearchTest() {
    	string EventId = '18AD1BC7-0671-4A89-922F-36887263E911';
    	integer numRecords = 20;

        for(Integer i=0;i<numRecords;i++) {
			EventRevenueDetails__x rev = new EventRevenueDetails__x();
			rev.EventId__c=EventId;
			rev.FirstName__c='FirstName' + i;
			rev.KeyName__c='KeyName' + i; 
			rev.TransactionAmount__c=10.00;
        	if (math.mod(i, 2) == 0)  {
	            rev.EventId__c = EventId;
	        }
	        else{
	        	rev.EventId__c = '3B9D95C3-DA8E-4E78-906A-C69120739334';
	        }

	        Database.insertAsync(rev);
        }
        
        Test.startTest();
        PageReference pr = Page.ECCRevenues;
         pr.getParameters().put('eventId', EventId);
        Test.setCurrentPage(pr);

        List<EventRevenueDetails__x> revenuesFromService = ECCRevenuesController.getRevenueDetails(EventId);
        System.debug('revenuesFromService: ' + revenuesFromService);
      	System.assertNotEquals(revenuesFromService, null);

      	for (EventRevenueDetails__x i : revenuesFromService) {
		    System.assertEquals(i.EventId__c, EventId);
		}
        Test.stopTest();
    }
}