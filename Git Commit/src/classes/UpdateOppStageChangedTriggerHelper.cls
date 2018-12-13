public class UpdateOppStageChangedTriggerHelper {

    public static boolean isExecuting = false;

    public static void updateValues(object[] newTrigger){

        if( isExecuting ){
            return;
        }

        isExecuting = true; 
        
        Opportunity[] opportunities = new Opportunity[]{};
      
        List<OpportunityFieldHistory> hist = new List<OpportunityFieldHistory>();
        Datetime changed = Datetime.now();
        
        List<Opportunity> newassets = (List<Opportunity>) newTrigger;

        Long startingTime = System.now().getTime(); // Num milliseconds since Jan 1 1970
        Integer delayInMilliseconds = 1000; // One-second delay
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
            // Do nothing until desired delay has passed
        }

        for(Opportunity opp : newassets) {
            hist = [select OpportunityId, CreatedDate from OpportunityFieldHistory where Field = 'StageName' and OpportunityId = :opp.Id order by CreatedDate desc limit 1];
            
            system.debug(hist);

            if(hist.size() > 0) {
                OpportunityFieldHistory history = hist.get(0);

                changed = history.CreatedDate;

                Opportunity o = new Opportunity(Id = opp.Id);

                o.StageChanged__c = changed;
                o.Stage_Update_time__c = date.newinstance(changed.year(), changed.month(), changed.day());

                opportunities.add(o);
            }
        }

        update opportunities;

    }

}