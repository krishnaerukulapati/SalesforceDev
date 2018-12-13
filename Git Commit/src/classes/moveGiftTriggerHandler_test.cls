@istest
public class moveGiftTriggerHandler_test{
    public static testmethod void dotesting(){
        test.starttest();
        Case c = new Case();
        c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;
        Move_Gift__c mg = new Move_Gift__c();
        mg.Wrong_account__c = '21344';
        mg.payment_gift_amount__c =2;
        mg.case_related__c =c.id;
        insert mg;
        test.stoptest();
    }
     public static testmethod void doupdatetesting(){
         test.starttest();
        Case c = new Case();
        c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;
        Move_Gift__c mg = new Move_Gift__c();
        //mg.Wrong_account__c = 21344;
        mg.payment_gift_amount__c =2;
        mg.case_related__c =c.id;
        insert mg;
        mg.Wrong_account__c = '21344';
        update mg;
        test.stoptest();
    }
}