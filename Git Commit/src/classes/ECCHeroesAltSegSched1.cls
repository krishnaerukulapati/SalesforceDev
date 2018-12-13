global class ECCHeroesAltSegSched1 implements Schedulable {
	global void execute(SchedulableContext sc) {	
		List<Campaign> camplst =[
			select 
			Id, EventId__c, EndDate, name 
			from Campaign  
			where SegType__c = 'Alternate Heroes 1'
			and (EndDate = null or EndDate > TODAY)];
		for (Campaign c : camplst) {
			System.debug('c.id = ' + c.id);
			ECCHeroesAltSegBat b = new ECCHeroesAltSegBat(c.id);
			database.executebatch(b, 15);
		}
	}
}