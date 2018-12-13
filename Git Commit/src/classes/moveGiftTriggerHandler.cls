public class moveGiftTriggerHandler{
    public static void setDAPcaseOwnerqueue(List<Move_Gift__c> newListGift, map<id, Move_Gift__c> oldgiftmap){
        map<id, Move_Gift__c> casemap = new map<id, Move_Gift__c>();
        for(Move_Gift__c mg: newListGift){
            if(string.isnotblank(mg.Wrong_account__c) || (oldgiftmap <> null && oldgiftmap.get(mg.id).Wrong_account__c <> mg.Wrong_account__c && string.isnotblank(mg.Wrong_account__c))){ 
                if(string.isnotblank(mg.case_related__c) && string.isnotBlank(string.valueOf(mg.payment_gift_amount__c)) && mg.payment_gift_amount__c >0)
                    casemap.put(mg.case_related__c, mg);
            }
        }
        List<case> caseList = new list<case>();
        if(casemap <> null && !casemap.isEmpty()){
            id queueId;
            for(Group queue:[SELECT Id,Name,DeveloperName from Group where Type='Queue']){
                if(queue.DeveloperName.equalsignoreCase(Label.Mover_Gift_Queue_Label)){
                    queueId = queue.id;
                    break;
                }    
            }
            if(string.isnotblank(queueId)){
                for(id caseid: casemap.keyset()){
                    case cs = new case(id=caseid);
                    cs.ownerId=queueId;
                    caseList.add(cs);
                }
            }
        }
        if(caseList <> null && !caseList.isEmpty()){
            update caseList;
        }
    }
}