/**
  * Apex Class: IntranetMenuMobileController_Test 
  * Description: test class for IntranetMenuMobileController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: October 3rd,2013
  * Modified By : Sumit tanwar 12th Sept, 2014 Ref - T-318410
*/
@isTest
private class EdgeForceIntranetMenuMobileContTest {
    
    private static testmethod void MenuControllerTest(){
        //Insert Intranet_CMS_Page__c records
        
        
        
        
        String recordTypeId = Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName().get('Intranet CMS Pages').getRecordTypeId();
        //Insert new Intranet_Article__c records
        Intranet_Content__c article1 = new Intranet_Content__c();
        article1.Name = 'Test';
        article1.Start_Date__c = Datetime.now();
        article1.End_Date__c = Datetime.now().addDays(5);
        //article1.Pages__c = 'Brand';
        article1.RecordTypeId = recordTypeId;
        article1.Status__c = 'Published';
        article1.Show_In_Header_Menu__c = true;
        article1.Template__c = 'Home';
        article1.Sequence__c = '1';
        insert article1;
        
        Intranet_Content__c article2 = new Intranet_Content__c();
        article2.Name = 'Test';
        article2.Start_Date__c = Datetime.now();
        article2.End_Date__c = Datetime.now().addDays(5);
        //article2.Pages__c = 'Brand';
        article2.Status__c = 'Published';
        article2.RecordTypeId = recordTypeId;
        article2.Show_In_Header_Menu__c = true;
        article2.Template__c = 'Interior Home';
        article1.Sequence__c = '1';
        insert article2;
        
        Intranet_Content__c article3 = new Intranet_Content__c();
        article3.Name = 'Test';
        article3.Start_Date__c = Datetime.now();
        article3.End_Date__c = Datetime.now().addDays(5);
        //article3.Pages__c = 'Brand';
        article3.RecordTypeId = recordTypeId;
        article3.Status__c = 'Published';
        article3.Show_In_Header_Menu__c = true;
        article3.Template__c = 'Search';
        article1.Sequence__c = '2';
        insert article3;
        
        Intranet_Content__c article4 = new Intranet_Content__c();
        article4.Name = 'Test';
        article4.Start_Date__c = Datetime.now();
        article4.End_Date__c = Datetime.now().addDays(5);
        //article4.Pages__c = 'Brand';
        article4.Status__c = 'Published';
        article4.RecordTypeId = recordTypeId;
        article4.Show_In_Header_Menu__c = true;
        article4.Template__c = 'Employee Directory';
        article1.Sequence__c = '1';
        insert article4;
        
        Intranet_Content_Version__c intraContVer1 = new Intranet_Content_Version__c();
        intraContVer1.Intranet_Content__c = article1.Id;
        intraContVer1.Name = 'Article 1';
        intraContVer1.Language__c = 'English';
        insert intraContVer1;
        
        Intranet_Content_Version__c intraContVer2 = new Intranet_Content_Version__c();
        intraContVer2.Intranet_Content__c = article2.Id;
        intraContVer2.Name = 'Article 2';
        intraContVer2.Language__c = 'English';
        insert intraContVer2;
        
        RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
        Intranet_Content__c intranetConfing = new Intranet_Content__c(Name='Android_Marketplace_URL', Value__c = 'www.verginamerica.com', recordtypeid = RecType.id ); 
        //insert intranetConfing ;
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;
        
        Intranet_Content__c intranetConfing1 = new Intranet_Content__c(Name='IOS_Marketplace_URL', Value__c = 'www.verginamerica.com', recordtypeid = RecType.id ); 
        //insert intranetConfing1 ;
        
        list<Intranet_Content__c> listConfig = new list<Intranet_Content__c>{intranetConfing,intranetConfing1};
        insert listConfig;
        Test.startTest();
        EdgeForceIntranetMenuMobileController conObj = new EdgeForceIntranetMenuMobileController();
        //Assert controller's ulString propety is not null
        system.assert(conObj.ulString != null);
        Test.StopTest();
    }
}