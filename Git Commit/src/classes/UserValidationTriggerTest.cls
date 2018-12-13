@isTest
private class UserValidationTriggerTest {
	
	@isTest static void insertNewUser() {

		Profile p = [SELECT Id FROM Profile LIMIT 1];

		User u = new User();
		u.Username = 'UserValidationTriggerTest@test.com';
		u.LastName = 'testLastName';
		u.Email = 'test@email.com';
		u.Alias = 'testAlia';
		u.CommunityNickname = 'testCommunityNickname';
		u.TimeZoneSidKey = 'America/Chicago';
		u.LocaleSidKey = 'en_US';
		u.EmailEncodingKey = 'UTF-8';
		u.ProfileId = p.Id;
		u.LanguageLocaleKey = 'en_US';
		insert u;

		CallCenter c = [SELECT Id FROM CallCenter LIMIT 1];
		try{
			u.CallCenterId = c.Id;
			update u;	
		}
		catch(Exception e){
			Boolean expectedExceptionThrown = e.getMessage().contains('User must have AgentId when assigned Call Center') ? true : false;
			System.assertEquals(expectedExceptionThrown, true);
		}
	}
}