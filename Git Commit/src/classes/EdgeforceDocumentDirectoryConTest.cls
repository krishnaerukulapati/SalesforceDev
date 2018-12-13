@isTest

Public Class EdgeforceDocumentDirectoryConTest{

    
    Static TestMethod void docDirectoryTest(){
        try{
            
            RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
    
            ContentWorkSpace cwMaster = [Select Id from ContentWorkSpace Limit 1]; //where Name like '%Teva Master'];
            ContentVersion doc = new ContentVersion();
            Blob beforeblob = Blob.valueOf('Testing base 64 encode');
            doc.VersionData = beforeblob;
            doc.Title = 'title1';
            doc.PathOnClient = 'xyz';
            doc.FirstPublishLocationId = cwMaster.id;
            insert doc;
            
            Intranet_Content__c searchConfig = new Intranet_Content__c();
            searchConfig.Name = 'Allowed Preview Formats';
            searchConfig.Object_Name__c = 'JPG';
            searchConfig.RecordTypeId = RecType.id;
            insert searchConfig;
        
        Test.startTest();
                
                EdgeforceDocumentDirectoryController docDirectory = new EdgeforceDocumentDirectoryController();
                
                
                apexpages.currentPage().getParameters().put('resourceIdParam',doc.id) ;
                
                docDirectory.processContent();

        Test.stopTest();
        
        }Catch(Exception e){
        
            System.debug(e.getMessage());
        }
    }

}