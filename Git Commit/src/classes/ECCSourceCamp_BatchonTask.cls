//Author : Adarsha Reddy
//Purpose : Update the source Campaign in Task from DispositionInfo based on the Lead 
global class ECCSourceCamp_BatchonTask implements Database.Batchable<sObject>, Database.Stateful {
    private String query = null;
    global List<String> eventMessages = new List<String>();
    
    public ECCSourceCamp_BatchonTask() 
    {
        getQuery();
      // query += 'LeadId__c!=NULL ';
    }   
    
        
    public void getQuery()
    {
        query = 'select Id, Name, ContactId__c, SourceName__c, LeadId__c from DispositionInfo__c';// WHERE';

    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<DispositionInfo__c> scope)
    {
        Map<Id,DispositionInfo__c> dispMap=new Map<Id,DispositionInfo__c>();
        for(DispositionInfo__c disp : scope){
            if(disp.LeadId__c!=null){
               dispMap.put(disp.LeadId__c,disp);
            }
        }

        System.debug('----dispMap----'+dispMap);
        List<Task> tslist=new List<Task>();
        if(dispMap.size()>0){
          for(Task ts : [SELECT id, Subject, WhoId, WhatId,Source_Campaign__c FROM Task WHERE WhoId=:dispMap.keySet()]){
              if(dispMap.containsKey(ts.WhoId)){
                 ts.Source_Campaign__c=dispMap.get(ts.WhoId).SourceName__c;
                 tslist.add(ts);
              }
          }
        }
        System.debug('----tslist----'+tslist);
        System.debug('----tslist size----'+tslist.size());

        if(tslist.size()>0){
           update tslist;
        }   
    }
    
    global void finish(Database.BatchableContext BC){
    
       
    }
}