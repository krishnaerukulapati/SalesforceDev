@isTest
public class RemArchLeadsBatTest {

    @TestSetup
    static void prepareData(){
        EmailSettings__c emailSet = new EmailSettings__c(name = 'Remove Archived CampMem',Email__c= 'HeroesSegmentation@test.com');
        insert emailSet;
   		Lead c = new Lead();
		    c.LastName = 'test';
	       	c.ConstituentID__c = 'notaquid';
	        c.Constituent_Type__c = 'INDIVIDUAL';
	        c.Company = 'fake';
	        c.TR_ID__c = '123456';
	        c.EventID__c = '123456';
	        c.Status = 'Open';

        insert c;
        
        Campaign camp = new Campaign(
    		Name = 'test'
    		, EventID__c = '123456'
    		, EVM_EventID__c = '123456'
    		, Status = 'Archived');
        insert camp;
              
        CampaignMember cm = new CampaignMember(CampaignId=camp.id,LeadId=c.id);
        insert cm;

        c = new Lead();
		    c.LastName = 'test2';
	       	c.ConstituentID__c = 'notaquid';
	        c.Constituent_Type__c = 'INDIVIDUAL';
	        c.Company = 'fake2';
	        c.TR_ID__c = '1234562';
	        c.EventID__c = '1234562';
	        c.Status = 'Archived';

        insert c;
        
        camp = new Campaign(
    		Name = 'test2'
    		, EventID__c = '1234562'
    		, EVM_EventID__c = '1234562'
    		, Status = 'In Progress');
        insert camp;
              
        cm = new CampaignMember(CampaignId=camp.id,LeadId=c.id);
        insert cm;
    }

    static testMethod void leadWithOpp(){
        
        Test.startTest();
        DataBase.executeBatch(new RemArchLeadsBat());
        
        Test.stopTest();
        
    }
    
  }