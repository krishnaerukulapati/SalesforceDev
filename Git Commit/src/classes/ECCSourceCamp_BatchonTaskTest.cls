@isTest
Public class ECCSourceCamp_BatchonTaskTest{

    static testmethod void SourceCamp_BatchonTask(){
        
        Account a = new Account(Name = 'ALSAC Challenge');
        insert a;

    //Id rtId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('ECC Campaign').getRecordTypeId();

        String parCampId;
        Campaign c = new Campaign(
            Name = 'Test parent PCampaign'
            , EventId__c = '1234'
            , OppRecordType__c = 'St_Jude_Challenge'
            , OppAcc__c = a.Id);
        insert c;
        parCampId = c.Id;

       Lead l = new Lead(
            LastName = 'TestLead',
            Status = 'Open',
            Company = 'Test',
            TransSourceCode__c = '12345678910',
            Account_id__c = '123456',
            CurrentCampaign__c = parCampId
            );
      
        insert l;
        
        DispositionInfo__c disp=new DispositionInfo__c ();
        disp.Name='tetsdispinfo';
        disp.SourceName__c=c.Name;
        disp.LeadId__c =l.Id;
        insert disp;
        
        Test.startTest();
        ECCSourceCamp_BatchonTask batch = new ECCSourceCamp_BatchonTask();
        database.executeBatch(batch);
        test.stopTest();

    }       

}