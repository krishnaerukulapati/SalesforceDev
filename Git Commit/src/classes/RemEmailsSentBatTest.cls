@isTest
public class RemEmailsSentBatTest 
{
    @isTest
    static void runBat()
    {
 		Email__c e = new Email__c(
	        EmailSent__c = 'Y'
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

	    Datetime lastweek = Datetime.now().addDays(-10);
        Test.setCreatedDate(e.id, lastweek);
        Test.startTest();
        DataBase.executeBatch(new RemEmailsSentBat());  
        Test.stopTest();       
    }   
 }