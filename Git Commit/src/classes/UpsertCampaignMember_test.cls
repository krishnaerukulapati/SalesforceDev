@istest
public class UpsertCampaignMember_test {
    static testMethod void myUnitTest() {
    	Campaign c = new Campaign(Name='Test Campaign');
        upsert c;
        List<Lead> l = new List<Lead>();
            l.add(new Lead(CurrentCampaign__c = c.id, LastName = 'test', Company = 'required?'));
            l.add(new Lead(CurrentCampaign__c = c.id, LastName = 'test1', Company = 'required?'));
    	Test.startTest();
        upsert l;
        upsert l;
    	Test.stopTest(); 
    }
}