/**
  * Apex Class: EdgeForceCloneWizardControllerTest 
  * Description: test class for EdgeForceIntranetCloneWizardController
  * Created By: 
  * Created Date: 
  * Modified By : Sumit tanwar 12th Sept, 2014 Ref - T-318410
*/
@isTest
public with sharing class EdgeForceCloneWizardControllerTest {
  public static testMethod void EdgeForceCloneWizardControllerTestmet(){
        Id recType = getRecordTypeId('Intranet_Content__c','Intranet Article');
        Id recType1 = getRecordTypeId('Intranet_Content__c','Config - Portal');
        
        Intranet_Content__c article = new Intranet_Content__c();
        article.Type__c = 'News';
        article.Start_Date__c = Datetime.now();
        article.End_Date__c = Datetime.now().addDays(5);
        article.RecordTypeId = recType1;
        article.Name = userinfo.getLanguage();
        article.Value__c = userinfo.getLanguage();
        insert article;
        
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article1.RecordTypeId = recType;
        article1.Name = 'TestArt1';
        insert article1;
        
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        article2.parent__c = article1.id;
        //article1.Pages__c = 'Brand';
        insert article2;
        
        Intranet_Content__c article3 = new Intranet_Content__c();
        article3.Type__c = 'News';
        article3.Start_Date__c = Datetime.now();
        article3.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        insert article3;
          
        Intranet_Content__c article4 = new Intranet_Content__c();
        article4.Type__c = 'News';
        article4.Start_Date__c = Datetime.now();
        article4.End_Date__c = Datetime.now().addDays(4);
        article4.parent__c = article3.Id;
        insert article4;
        
        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Language__c = 'English';
        intraContVer1.name = 'testTitle';
        intraContVer1.description__c = 'testDescription';
        
        insert intraContVer1;
        
        Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article1.Id;
        intraContVer2.Language__c = 'English';
        intraContVer2.name = 'testTitle1';
        intraContVer2.description__c = 'testDescription1';
        
        insert intraContVer2;
        
        Tags__c tag = new Tags__c(
          tag__c = 'TestArt1'
        );
        insert tag;
        
       
        
        Intranet_Content_Tags__c iTag = new Intranet_Content_Tags__c();
        iTag.Tags__c = tag.Id;
        iTag.Intranet_Content__c = article1.Id;
        insert iTag;
        
        PageReference pageRef = Page.EF_CMSPages;
        Test.setCurrentPage(pageRef);
        ApexPages.CurrentPage().getParameters().put('id',article1.Id); 
        
        EdgeForceIntranetCloneWizardController ctrl = new EdgeForceIntranetCloneWizardController();
        ctrl.processContentClone();
        ctrl.processQuickLinksClone();
        
        ctrl.processChildContentsClone(article1.id);
        
        ctrl.newPageName= 'testPageName';
        ctrl.processCloning();
  }
  
  public static Id getRecordTypeId(String objectAPIName, String recordTypeName) {
        if(String.isBlank(objectAPIName) || String.isBlank(recordTypeName)){
            return null;
        }

        Map<String, Schema.SObjectType> sobjectSchemaMap;
        if(sobjectSchemaMap == null) {
            sobjectSchemaMap = Schema.getGlobalDescribe();
        }

        Schema.SObjectType sObjType = sobjectSchemaMap.get(objectAPIName) ;
        Schema.DescribeSObjectResult cfrSchema = sObjType.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id recordTypeId = RecordTypeInfo.get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }
}