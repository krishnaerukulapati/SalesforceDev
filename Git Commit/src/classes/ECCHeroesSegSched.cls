global class ECCHeroesSegSched implements Schedulable {
	global void execute(SchedulableContext sc) {
		ECCHeroesSegBat b = new ECCHeroesSegBat();
		database.executebatch(b, 15);
	}
}