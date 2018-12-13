/**
  * Apex Class: EdgeForceIntranetContentControllerTest
  * Description: Test class for EdgeForceIntranetContentController
  * Created By: Ryan Marquardt
  * Created Date: October 1st, 2014
  * Last Modified By : Priyanka Kumar 06 Oct, 2014 Ref - T-324424
*/
@isTest//(SeeAllData=true)
private class EdgeForceIntranetContentControllerTest {
    
    private static testmethod void contentNewControllerTest(){

		Map<String, Schema.Recordtypeinfo> recordTypeMap = 
        Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName();
        
        Intranet_Content__c ic = new Intranet_Content__c();
        ic.Name=userinfo.getLanguage();
        ic.Type__c='News';
        //ic.RecordTypeId = recordTypeMap.get('Intranet Article').getRecordTypeId();
        ic.RecordTypeId = recordTypeMap.get('Config - Portal').getRecordTypeId();
		ic.Start_Date__c = System.today();
		ic.End_Date__c = System.today().addDays(365); 
		ic.value__c = 'English';
        insert ic;
        
        Intranet_Content_Version__c icv = new Intranet_Content_Version__c();
        icv.Name = 'ALSAC Culture Pillars';
        icv.Intranet_Content__c = ic.Id;
        icv.isPublished__c = true;
        insert icv;
        
        Tags__c testTag = new Tags__c();
        testTag.Tag__c = 'Home';
        insert testTag;
        
        Intranet_Content_Tags__c contentTag = new Intranet_Content_Tags__c();
        contentTag.Intranet_Content__c = ic.Id;
        contentTag.Tags__c = testTag.Id;
        insert contentTag;

        PageReference pageRef = Page.EF_Content;
        
		Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Article');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Article').getRecordTypeId());
        Apexpages.currentPage().getParameters().put('Name', 'Home');
        Apexpages.currentPage().getParameters().put('tabName', 'Home');
        Apexpages.currentPage().getParameters().put('id', ic.Id);
        Apexpages.currentPage().getParameters().put('category', 'News');
        

        EdgeForceIntranetContentController controller = new EdgeForceIntranetContentController();
        // Set the current page
        Test.setCurrentPage(pageRef);
        
        controller.processContentAndVersionforDetailpage(ic.Id, 'Content');
        
		String testQuery = 'Select URL__c, Template__c, SystemModstamp,Target__c, (SELECT Id, Name  FROM Attachments),(Select Tags__r.Tag__c From Intranet_Content_Tags__r) From Intranet_Content__c  WHERE  id=\''+ic.Id+'\'';
		List<Intranet_content__c> icc = database.query(testQuery);
		system.debug('test query --->'+icc.size());
 		List<EdgeForceIntranetContentController.ContentVersionWrapper> listofcontentversionWrapper = controller.processContentAndVersion(testQuery);
 		
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
        article1.Site__c = 'Portal';
        article1.Sequence__c = '1';
        insert article1;
        
        Intranet_Content_Version__c icvTest = new Intranet_Content_Version__c();
        icvTest.Name = 'ALSAC Culture Pillars';
        icvTest.Intranet_Content__c = article1.Id;
        icvTest.isPublished__c = true;
        insert icvTest;
        
        String userType = 'Portal';
        
        
 		String queryString =  'SELECT Id, Parent__c,URL__c, Parent__r.Name,Skip_Menu_Link__c, Name,Template__c, Sequence__c,Target__c,(Select Tags__r.Tag__c From Intranet_Content_Tags__r)  FROM Intranet_Content__c  WHERE Status__c = \'Published\' AND RecordType.Name = \'Intranet CMS Pages\' AND Show_In_Header_Menu__c = true AND Site__c=\''+userType+'\' order by Parent__c,Sequence__c '; 
 		List<EdgeForceIntranetContentController.ContentVersionWrapper> processMenu = controller.processContentAndVersionMenu(queryString);
 		test.startTest();
 		system.assert(listofcontentversionWrapper.size() >  0);
 		system.assert(processMenu.size() > 0);
 		test.stopTest();
 		
 		
 				
        /*
        Apexpages.currentPage().getParameters().put('id', 'a08L0000006qV02IAE');
        Apexpages.currentPage().getParameters().put('category', 'Executive Blog');
        Apexpages.currentPage().getParameters().put('tabName', 'Home');
        */
        
        //controller2.contentNewControllerTest();
        
        //EdgeForceIntranetContentController controller = new EdgeForceIntranetContentController();
                //controller.fetchObjectFields();
        //controller.save();
        /*
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Banner');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Banner').getRecordTypeId());
        controller = new EdgeForceIntranetContentController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet Link');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentController();
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Dynamice Component');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        
        controller = new EdgeForceIntranetContentController();
        controller.fetchObjectFields();
        controller.save();
        
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Search');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Portal');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Config - Language');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet Link').getRecordTypeId());
        controller = new EdgeForceIntranetContentController();
         
        Apexpages.currentPage().getParameters().put('RecordTypeName', 'Intranet CMS Pages');
        Apexpages.currentPage().getParameters().put('RecordTypeId', recordTypeMap.get('Intranet CMS Pages').getRecordTypeId());
        */
        
        /*
        controller = new EdgeForceIntranetContentController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Chatter' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Team' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Employee Directory' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'Search' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        controller = new EdgeForceIntranetContentController();
        controller.intranetContent.Start_Date__c = Date.today();
        controller.intranetContent.End_Date__c = Date.today().addDays(5);
        controller.intranetContent.Type__c = 'Global Alert';
        controller.intranetContent.Create_Chatter_Group__c = True;
        controller.intranetContent.Template__c = 'News' ;
        //Assert test for Pagereference
        System.assert(controller.save() <> null);
        
        //Assert test for cancel
        System.assert(controller.cancel() <> null);
*/
    }
}