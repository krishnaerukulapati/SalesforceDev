@isTest
public class UpdateOppStageChangedTriggerTest{
    public static testmethod void UpdateOppStageChanged(){
        Account acc=new Account();
        acc.Name='TestName';
        acc.BillingCountry='USA';
        insert acc;
        
        Contact con=new Contact();
        con.LastName='testcontact';
        con.Phone='56789347890';
        con.Email='test@ggg.com';
        con.Fax='3456789';
        con.Title='Mr.';
        con.AccountId=acc.id;
        con.MailingCountry='USA';
        con.MailingState ='New York';        
        insert con;
        
        Opportunity opp=new Opportunity();
        opp.Name='test opportunity';
        opp.AccountId=acc.Id;
        opp.StageName='15 day Confirmation Call';
        opp.CloseDate=Date.Today()+5;        
        insert opp;
        
        test.startTest();
          opp.StageName='30 day Confirmation Call';
          opp.StageChanged__c =System.Now();
          opp.Stage_Update_time__c=Date.Today();
          update opp;
        test.stopTest();  
    }
}