@isTest
private class EmailSendSegSchedTest {
	
	@isTest static void testExecute() {
		Test.startTest();
		EmailSendSegSched ess = new EmailSendSegSched();
		ess.execute(null);
		Test.stopTest();
	}
}