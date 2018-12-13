/**
  * Apex Class: IntranetContentNewController_Test
  * Description: Test class for IntranetContentNewController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 11th,2013
*/
@isTest
private class EdgeForceIntranetContentNewContTest {
    
    private static testmethod void contentNewControllerTest(){
        Map<String, Schema.Recordtypeinfo> recordTypeMap = 
        Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName();
        
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Article');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Article').getRecordTypeId());
        
        EdgeForceIntranetContentNewController controller = new EdgeForceIntranetContentNewController();
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Banner');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Banner').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Link');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController();
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Dynamice Component');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        
        controller = new EdgeForceIntranetContentNewController();
        controller.fetchObjectFields();
        controller.save();
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Search');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Portal');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Language');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentNewController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet CMS Pages');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet CMS Pages').getRecordTypeId());
        
        controller = new EdgeForceIntranetContentNewController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Chatter' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Team' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Employee Directory' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Search' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentNewController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'News' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        //Assert test for cancel
        System.assert(controller.cancel() <> null);
    }
}