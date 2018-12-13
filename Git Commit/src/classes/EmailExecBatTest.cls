@isTest
public class EmailExecBatTest {
    @TestSetup
    static void prepareData(){
       // EmailSettings__c emailSet = new EmailSettings__c(name = 'Remove Archived CampMem',Email__c= 'HeroesSegmentation@test.com');
       // insert emailSet;
	}

   	@isTest
   	static void runBat() {
		CustomSettings__c cs = new CustomSettings__c(
			 Name = 'EmailPass' 
			, Value__c = 'PassTest');
		insert cs;

		cs = new CustomSettings__c(
			 Name = 'EmailUser' 
			, Value__c = 'PassTest');
		insert cs;

		cs = new CustomSettings__c(
			 Name = 'EmailServiceEndPoint' 
			, Value__c = 'PassTest');
		insert cs;

	    Email__c e = new Email__c(
	        EmailSent__c = 'N'
	        , BindField1__c = 'bind field 1' 
	        , BindField2__c = 'bind field 2'  
	        , BindField3__c = 'bind field 3' 
	        , BindField4__c = 'bind field 4'
			, BindField5__c = 'bind field 5'
			, BindField6__c = 'bind field 6'  
			, BindField7__c = 'bind field 7'
			, BindField8__c = 'bind field 8'  
			, BindField9__c = 'bind field 9'  
			, BindField10__c = 'bind field 10'
			, RecipientEmails__c = 'recipientemaila@email.com'
			, Template__c = 'Test Templatea' 
			, HasBody__c = 'Y'
			, Subject__c = 'test subjecta'
			, Body__c = 'Test Bodya');
	    insert e;

	 	Test.startTest();
	    DataBase.executeBatch(new EmailExecSegBat());
	    Test.stopTest();
	}
}