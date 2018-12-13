trigger TriggeronVersionUpdate on Intranet_Content_Version__c (after update) {
     if(trigger.isAfter && trigger.isUpdate){
        EdgeforceVersionUpdateTrigger.createNewVersion(trigger.oldmap,trigger.newMap);
     }
}