global class ECCChallengeSched implements Schedulable{
	global void execute(SchedulableContext sc) {
		List<Campaign> children =[
			select 
			Id, EventId__c, EndDate, name 
			from Campaign 
			where SegType__c = 'DIY'];
		for (Campaign c : children) {
			ECCChallengeSegBat b = new ECCChallengeSegBat(c.id);
			database.executebatch(b, 15);
		}
	}
}