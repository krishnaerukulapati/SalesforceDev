@isTest
private class ECCChallengeSchedTest {
	
	@isTest static void testExecute() {

		Test.startTest();

		ECCChallengeSched cac = new ECCChallengeSched();

		cac.execute(null);

		Test.stopTest();
	}
}