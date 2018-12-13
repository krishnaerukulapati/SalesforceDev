trigger CreateInteraction on Task (
    after insert, 
    after update ) {

    String completed = 'Completed';

    system.debug('in the trigger');
    for(Task t : Trigger.new) {
        boolean bNewlyCompleted = false;

        if (Trigger.isUpdate) {
            Task tOld = Trigger.oldMap.get(t.Id);
            if (t.Status == completed && tOld.Status != completed) {
                bNewlyCompleted = true;
            }
        }
        else if (t.Status == completed) {
            bNewlyCompleted = true;
        }

        system.debug('newly completed = ' + bNewlyCompleted);

        if (bNewlyCompleted) {
            List<Lead> lList = [select id, constituentid__c from lead where id = :t.WhoId];
            if(lList.size() > 0) {
                Lead l = lList.get(0);
                if (l != null) {
                    String consId = l.ConstituentID__c;

                    C360Util.createInteractionFuture(consId, l.Id, 'IE', 'EMAIL', null, null, null, null, null, null);
                }
            }
        }
    }

}