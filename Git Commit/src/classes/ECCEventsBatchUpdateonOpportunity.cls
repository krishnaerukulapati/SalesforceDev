global class  ECCEventsBatchUpdateonOpportunity implements Database.Batchable<sObject>, Database.Stateful {
    
    global String query = null;
    global List<String> eventMessages = new List<String>();
    
    global ECCEventsBatchUpdateonOpportunity() 
    {
        getQuery();
        query += 'EventID__c!=null';
    }
    
        
    global void getQuery()
    {
        query = 'SELECT Id, DateInserted__c, EventDescription__c,EventID__c,EventMasterID__c,EventName__c,FiscalYear__c,ShipToAddress__c,ShipToAddress2__c,';
        query+= 'ShipToCity__c,ShipToZipCode__c,ZipCode__c,ShipToStateID__r.StateCode__c,ContactAddress__c,ContactAddress2__c,ContactCity__c,DateUpdated__c, EndDate__c,';
        query+= 'EventCode__c,StatusID__r.Status1__c, StartDate__c,ContactEmail__c,ContactPhone__c,ContactStateID__c,';
        query+= 'ContactZipCode__c,CountryID__c,Address__c,Address2__c FROM Events__x WHERE ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        system.debug(query);
        return Database.getQueryLocator(query);
    }
       
    global void execute(Database.BatchableContext BC, List<Events__x> scope)
    {
        Map<String,Events__x> EventcodeMap=new Map<String,Events__x>();
        for(Events__x ev : scope){
            if(ev.EventID__c!=null){
                EventcodeMap.put(ev.EventID__c,ev);
            }   
        }
        
        List<Opportunity> opplist=new List<Opportunity>();
        if(EventcodeMap.size()>0){
            for(Opportunity opp : [SELECT Id,Name,Event_Description__c,Event_Code__c,Event_End_Date__c,EventID__c,Event_Name__c,Event_Organizer__c,
                                   Event_Start_Date__c,Fiscal_Year__c,Mailing_address__c,Mailing_address_2__c,Mailing_city__c,Mailing_state__c,
                                   Mailing_zipcode__c,Shipping_address__c,Shipping_Address_2__c,Shipping_City__c,Shipping_State__c,Shipping_zipcode__c,
                                   core_event_start_date__c,Start_Date_ext__c,Contact_Email_ID__c,Contact_Phone__c,StageName FROM Opportunity WHERE EventID__c=:EventcodeMap.keySet()]){
                if(EventcodeMap.containsKey(opp.EventID__c)){
                    opp.Event_Description__c=EventcodeMap.get(opp.EventID__c).EventDescription__c;
                    opp.Event_End_Date__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).EndDate__c);
                   // opp.Event_Name__c=EventcodeMap.get(opp.EventID__c).EventName__c;
                    opp.Event_Start_Date__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).StartDate__c);
                    opp.Fiscal_Year__c=String.Valueof(EventcodeMap.get(opp.EventID__c).FiscalYear__c).left(4);
                    opp.Mailing_address__c=EventcodeMap.get(opp.EventID__c).ContactAddress__c;
                    opp.Mailing_address_2__c=EventcodeMap.get(opp.EventID__c).ContactAddress2__c;
                    opp.Mailing_city__c=EventcodeMap.get(opp.EventID__c).ContactCity__c;
                    opp.Mailing_state__c=EventcodeMap.get(opp.EventID__c).ContactStateID__c;
                    opp.Mailing_zipcode__c=EventcodeMap.get(opp.EventID__c).ContactZipCode__c;
                    opp.Shipping_address__c=EventcodeMap.get(opp.EventID__c).ShipToAddress__c;
                    opp.Shipping_Address_2__c=EventcodeMap.get(opp.EventID__c).ShipToAddress2__c;
                    opp.Shipping_City__c=EventcodeMap.get(opp.EventID__c).ShipToCity__c;
                    opp.Shipping_State__c=EventcodeMap.get(opp.EventID__c).ShipToStateID__r.StateCode__c;
                    opp.Shipping_zipcode__c=EventcodeMap.get(opp.EventID__c).ShipToZipCode__c;
                    opp.core_event_start_date__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).StartDate__c).addDays(-1);
                    opp.Start_Date_ext__c=Date.Valueof(EventcodeMap.get(opp.EventID__c).StartDate__c).addDays(-1); 
                    opp.Contact_Email_ID__c=EventcodeMap.get(opp.EventID__c).ContactEmail__c;
                    opp.Contact_Phone__c=EventcodeMap.get(opp.EventID__c).ContactPhone__c;
                    if(EventcodeMap.get(opp.EventID__c).StatusID__r.Status1__c=='System Cancelled' || EventcodeMap.get(opp.EventID__c).StatusID__r.Status1__c=='Cancelled'){
                      opp.StageName=EventcodeMap.get(opp.EventID__c).StatusID__r.Status1__c;
                    }  
                    opplist.add(opp);
                }   
            }   
        }
        
        System.debug('---opplist---'+opplist);
        if(opplist.size()>0){
         Database.SaveResult[] dbOppList = Database.Update(opplist,false);  
        }           
    }
    
    global void finish(Database.BatchableContext BC){
    
        AsyncApexJob aaj = [Select Id, Status, NumberOfErrors, JobItemsProcessed, MethodName, TotalJobItems, CreatedBy.Email
                from AsyncApexJob where Id = :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {aaj.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Contract Batch Job ' + aaj.Status);
     
     
        String bodyText = 'Number of records processed ' + aaj.TotalJobItems +
          ' with '+ aaj.NumberOfErrors + ' failures.\n';
          
        bodyText += 'Number of messages: ' +  eventMessages.size() + '\n';
        bodyText += String.join(eventMessages, '\n');
        
        mail.setPlainTextBody( bodyText );    
        
        try
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch (Exception ex) 
        {
          system.debug('Unable to send email');
        }
    }
}