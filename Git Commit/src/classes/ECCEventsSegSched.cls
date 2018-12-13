global class ECCEventsSegSched implements Schedulable {
	global void execute(SchedulableContext sc) {	
		List<Campaign> camplst =[
			select 
			Id, EventId__c, EndDate, name 
			from Campaign  
			where SegType__c = 'ECC Event'
			and (EndDate = null or EndDate > TODAY)];
		for (Campaign c : camplst) {
			System.debug('c.id = ' + c.id);
			ECCEventsSegBat b = new ECCEventsSegBat(c.id);
			database.executebatch(b, 15);
		}
	}
}