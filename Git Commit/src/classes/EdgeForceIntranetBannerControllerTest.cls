/**
  * Apex Class: IntranetBannerControllertest
  * Description: test class for IntranetBannerController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest(seeAllData=true)
private class EdgeForceIntranetBannerControllerTest {
    
    private static testmethod void bannerSectionTest(){
        
       RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Intranet_Content__c' and DeveloperName = 'Config_Portal'];
       
        Intranet_content__c  IC = new Intranet_content__c (Name =userinfo.getLanguage(),value__c = 'English',recordTypeId = RecType.id);
        insert IC;
        Intranet_Content__c intranetConfing = new Intranet_Content__c(Name='Banner_Rotating_Speed', Value__c = '20000', recordtypeid = RecType.id ); 
        insert intranetConfing ;

        //TestUtil.createIntranetBanner(true);
        EdgeForceIntranetBannerController conObj = new EdgeForceIntranetBannerController();
        conObj.currentPageName = 'Brand';
        
        //assert valid banner list size
        system.assert(conObj.banners != null);
        system.assertEquals(conObj.banner_Roating_Speed,20000);
    }

}