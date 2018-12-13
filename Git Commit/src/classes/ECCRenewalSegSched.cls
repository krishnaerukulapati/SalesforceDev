global class ECCRenewalSegSched implements Schedulable {
	global void execute(SchedulableContext sc) {	
		List<Campaign> camplst =[
			select 
			Id, EventId__c, EventTypeID__c, EndDate, name 
			from Campaign  
			where SegType__c = 'Renewal Event'
			and (EndDate = null or EndDate > TODAY)];
		for (Campaign c : camplst) {
			System.debug('c.id = ' + c.id);
			ECCRenewalSegBat b = new ECCRenewalSegBat(c.id, c.EventTypeID__c);
			database.executebatch(b, 15);
		}
	}
}