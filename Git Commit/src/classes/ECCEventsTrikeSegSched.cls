global class ECCEventsTrikeSegSched implements Schedulable {
	global void execute(SchedulableContext sc) {	
		List<Campaign> camplst =[
			select 
			Id, EventId__c, EndDate, name 
			from Campaign  
			//where SegType__c = 'ECC Event Trike'
			where SegType__c = 'Seg Test'
			and (EndDate = null or EndDate > TODAY)];
		for (Campaign c : camplst) {
			System.debug('c.id = ' + c.id);
			ECCEventsCoreSegBat b = new ECCEventsCoreSegBat(c.id);
			database.executebatch(b, 15);
		}
	}
}