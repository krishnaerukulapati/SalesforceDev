@isTest
global class ECCTaskCaseByCallIdTest {
    @isTest static void CreateTask() {
        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.CallObject__c = 'aguid';
        insert c;
        
        Task tsk = new Task();
        tsk.CallObject = 'aguid';
        insert tsk;
    }
}