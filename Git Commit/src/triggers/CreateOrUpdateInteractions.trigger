trigger CreateOrUpdateInteractions on Task (
    after insert) {
    
   
    Set<String> dispositions = new Set<String>();
    Set<String> whoIds = new Set<String>();
    Set<String> taskIds = new Set<String>();

    for(Task tsk : Trigger.new){
        if(tsk.isDisposition__c == true){
        dispositions.add(tsk.CallDisposition); 
        whoIds.add(tsk.WhoId); 
        taskIds.add(tsk.Id);
        }
    }

    if (!System.isFuture() && !System.isBatch()) {
        ECCUtil.processInteractionsFuture(dispositions, whoIds, taskIds);  
    }
    else {
        ECCUtil.processInteractions(dispositions, whoIds, taskIds);  
    }
}