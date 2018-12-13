/**
  * Apex Class: IntranetLeadershipCornerController_Test
  * Description: Test class for IntranetLeadershipCornerController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: August 30th, 2013.
*/
@isTest 
private class EdgeForceIntranetLdrshipCornerContTest {
    
    private static testmethod void newsFeedComponentControllerTest(){
        //Insert 'Intranet_Config__c' custom setting
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;
        
        Intranet_Content__c intranetConfing = new Intranet_Content__c(Name='Banner_Rotating_Speed', Value__c = '20000', recordtypeid = RecType.id ); 
        insert intranetConfing ;
        
        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet Article').getRecordTypeId();
        
        //Insert new Intranet_Article__c records
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Type__c = 'News';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article1.RecordTypeId = recordTypeId;
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Type__c = 'News';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article2.Pages__c = 'Brand';
        article2.RecordTypeId = recordTypeId;
        list<Intranet_Content__c> listArticle = new list<Intranet_Content__c>{article1,article2};
        insert listArticle;
        
        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Language__c = 'English';
        
        Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article2.Id;
        intraContVer2.Language__c = 'English';
        list<Intranet_Content_Version__c> listContentVer = new list<Intranet_Content_Version__c>{intraContVer1,intraContVer2};
        insert listContentVer;
        
        EdgeForceIntranetLdrshipCornerController conObj = new EdgeForceIntranetLdrshipCornerController();
        //set PageIds according to which Intranet_Article__c records have to be retrieved
        conObj.pageId = 'Brand';
        
        //Assert leadershipCornerList list has articles of Leadership Corner type
       // system.assertNotEquals(null, conObj.leadershipCornerList.size());
        //system.assertEquals(20000, conObj.banner_Roating_Speed);
    }
}