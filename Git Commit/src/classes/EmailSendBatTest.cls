@isTest
public class EmailSendBatTest {
    @TestSetup
    static void prepareData(){
      
   		EmailTemplate et = new EmailTemplate(
	    	Name = 'templatefortesting'
	    	, Subject = 'templatefortesting'
	    	, Body = 'test not really binding n stuff'
	    	, DeveloperName  = 'templatefortesting'
	    	, FolderId = UserInfo.getUserId()
	    	, TemplateType= 'Text'
	    	, IsActive = true);
	    insert et;

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
			, RecipientEmails__c = 'recipientemail@email.com'
			, Template__c = 'templatefortesting' 
			, Hasbody__c = 'Y'
			, Subject__c = 'test subject'
			, Body__c = 'Test Body');
	    insert e;
	    
	    Contact c =  new Contact(
	    	LastName = 'contact LN'
	    	,FirstName = 'contact fn'
	    	,Email = 'contact@email.com');
	    insert c;

	 	Test.startTest();
	    DataBase.executeBatch(new EmailSendSegBat());
	    Test.stopTest();
	}
}