@isTest(SeeAllData=true)
private class ECCCaseAfterUpdateTest {
    
    @isTest static void ChangeOwner() {
        
        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        c.OwnerId = [SELECT Id FROM User WHERE ISActive = true LIMIT 1].Id;
        insert c;

        c.OwnerId = [select QueueId from QueueSobject limit 1].QueueId;
        update c;

        c.OwnerId = [SELECT Id FROM User WHERE ISActive = true LIMIT 1].Id;
        update c;
    }
    
}