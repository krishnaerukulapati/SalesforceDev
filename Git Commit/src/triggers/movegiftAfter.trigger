trigger movegiftAfter on Move_Gift__c (After Insert, After update) {
    if(trigger.isAfter &&(trigger.isinsert || trigger.isupdate))
        moveGiftTriggerHandler.setDAPcaseOwnerqueue(trigger.new, trigger.oldmap);
}