@isTest
public class EdgeForceIntranetCMSController_Test {
    static testMethod void EdgeForceIntranetCMSControllerTest(){
        RecordType rt =  [SELECT Id, Name 
                          FROM RecordType 
                          WHERE SObjectType = 'Intranet_Content__c'
                          AND DeveloperName = 'Intranet_CMS_Pages'];
        Intranet_Content__c IC = new Intranet_Content__c();
        IC.RecordTypeId = rt.id;
        IC.Name = 'TestIC';
        IC.Template__c = 'Team';
        Insert IC;
        
        Intranet_Content__c IC2 = new Intranet_Content__c();
        IC2.RecordTypeId = rt.id;
        IC2.Name = 'TestIC';
        IC2.Template__c = 'Team';
        IC2.Parent__c = IC.id;
        Insert IC2;
        
        Intranet_Content_Version__c ICV = new Intranet_Content_Version__c();
        ICV.Name = 'testICV';
        ICV.Language__c = 'English';
        ICV.Intranet_Content__c = IC2.id;
        ICV.isPublished__c = true;
        insert ICV;
        
        ICV.Name = ICV.Name+String.valueOF(System.now());
        update ICV;
        
        Intranet_Content_Version__c ICV2 = new Intranet_Content_Version__c();
        ICV2.Name = 'testICV';
        ICV2.Language__c = 'English';
        ICV2.Intranet_Content__c = IC.id;
        ICV2.isPublished__c = true;
        insert ICV2;
        
        EdgeForceIntranetCMSController controller = new EdgeForceIntranetCMSController();
        //controller.getAllCMSPages();
        controller.ICID = IC.id;
        controller.SelectedICVID = ICV.id;
        controller.showICV();
        controller.publishICV();
        controller.deleteICV();
    }
}