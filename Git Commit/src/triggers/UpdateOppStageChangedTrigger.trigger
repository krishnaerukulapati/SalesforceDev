trigger UpdateOppStageChangedTrigger on Opportunity (before update,after update) {
    List<OpportunityFieldHistory> hist = new List<OpportunityFieldHistory>();
    Datetime changed = Datetime.now();

    for(Opportunity opp : trigger.new) {
        
        String newStage = trigger.newMap.get(opp.Id).StageName;

        String oldStage = trigger.oldMap.get(opp.Id).StageName;

        if(newStage != oldStage) {
            changed = Datetime.now();

            opp.StageChanged__c = changed;
            opp.Stage_Update_time__c = date.newinstance(changed.year(), changed.month(), changed.day());
        }
    }
    if(Trigger.isAfter && Trigger.isUpdate){
    OpportunityHelper.updateOwnerBasedonRegion(Trigger.New,Trigger.OldMap);
    }
}