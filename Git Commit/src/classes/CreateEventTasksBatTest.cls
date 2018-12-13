@isTest
public class CreateEventTasksBatTest {
  
    @TestSetup
    static void prepareData(){
        EmailSettings__c emailSet = new EmailSettings__c(name = 'CreateEventTasks', DeliminatedEmail__c= 'CreateEventTasks@test.com');
        upsert emailSet;
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.ActHoursToWait__c = 22;
        es.Act2HoursToWait__c = 22;
        es.CultHoursToWait__c = 22;
        es.Cult2HoursToWait__c = 22;
        upsert es;

    }

    @isTest static void runBat() {
    //create test data before testing the class
    //the first method is CreateEventTasksBat which two queries
    //require alsacevent and eventtask data
    
    //INSERT DGG AND CGI PROGRAM INTO ALSACEVENT
        String ALSACDGGEventId;
        ALSACEvent__c eDGG = new ALSACEvent__c();
        eDGG.Name = 'DGG Test Event';
        eDGG.Program__c = 'DGG';
        eDGG.Region__c = 'Region 1';
        eDGG.LeadStaff__c = [SELECT id FROM User WHERE Name = 'Lucy Ren' LIMIT 1].Id; 
        eDGG.StartDate__c = datetime.newInstance(2016, 9, 15, 00, 00, 0);
        insert eDGG;
        ALSACDGGEventId = eDGG.id;
        
               String ALSACCGIEventId;
        ALSACEvent__c eCGI = new ALSACEvent__c();
        eCGI.Name = 'CGI Test Event';
        eCGI.Program__c = 'CGI';
        eCGI.Region__c = 'Region 12';
        eCGI.LeadStaff__c = [SELECT id FROM User WHERE Name = 'Lucy Ren' LIMIT 1].Id; 
        eCGI.StartDate__c = datetime.newInstance(2016, 11, 15, 00, 00, 0);
        insert eCGI;
        ALSACCGIEventId = eCGI.id;
        
        
    //INSERT DGG and CGI TASKS      
        EventTask__c etDGG1 = new EventTask__c();   
        etDGG1.Assignee__c = NULL;
        etDGG1.DueInDays__c = 30;
        etDGG1.EventTask__c ='Secure Audio Visual -- start contract';
        etDGG1.EventTaskProgram__c ='DGG';
        etDGG1.EventTaskfunction__c='Registration';
        etDGG1.EventTaskSubfunction__c ='Contracts';
        etDGG1.EventTaskType__c ='Contracts';
        etDGG1.EventOppRTy__c ='DGG - Tasks';
        insert etDGG1;
        
        EventTask__c etDGG2 = new EventTask__c();   
        etDGG2.Assignee__c = [SELECT id FROM User WHERE Name = 'Paul Hill' LIMIT 1].Id; 
        etDGG2.Assignee__c = NULL;
        etDGG2.DueInDays__c = 30;
        etDGG2.EventTask__c ='Secure Audio Visual -- start contract';
        etDGG2.EventTaskProgram__c ='DGG';
        etDGG2.EventTaskfunction__c='Registration';
        etDGG2.EventTaskSubfunction__c ='Contracts';
        etDGG2.EventTaskType__c ='Contracts';
        etDGG2.EventOppRTy__c ='DGG - Tasks';
        insert etDGG2;
            
        Test.startTest();
       // DataBase.executeBatch(new CreateEventTasksBat());
        CreateEventTasksBat b = new CreateEventTasksBat();
		b.query = 'select id, Name, LeadStaff__c, LeadStaff__r.Id, Program__c, Region__c, StartDate__c, TasksCreated__c, ' + 
		'Radio_Type__c, Radio_Format__c, Has_Alcohol__c, Has_Raffle__c, Need_Auctioneer__c, Need_ITS_Support__c, Program_Representative__c, Program_Representative__r.Id ' +
			    'from ALSACEvent__c ' +
			    'where TasksCreated__c = false AND LeadStaff__c != null LIMIT 10';
        //ID batchId = DataBase.executeBatch(b, 10);
		DataBase.executeBatch(b, 10);
        //System.abortJob(batchId);
       // CreateEventTasksBat.sendErrorEmail('error', 'ALSACCGIEventId');
       // CreateEventTasksBat.sendErrorEmail('error', 'ALSADGGIEventId');
        Test.stopTest();
    }

}