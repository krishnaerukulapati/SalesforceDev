global class ECCSourceCamp_ScheduleBatchonTask implements Schedulable {
    
    global void execute(SchedulableContext sc)
    {
        ECCSourceCamp_BatchonTask batch = new ECCSourceCamp_BatchonTask();
        Database.executebatch(batch);
    }
    
}