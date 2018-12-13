/**
  * Apex Class: EdgeForceIntranetContentRTSelControllerTest
  * Description: Test class for IntranetContentRTSelectionController
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 11th, 2013.
*/
@isTest
private class EdgeForceIntranetContentRTSelCnrlTest {
    
    private static testmethod void rtSelectionControllerTest(){
        Intranet_Content__c testContent = new Intranet_Content__c();
        Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(testContent);
        EdgeForceIntranetContentRTSelController controller = 
                                    new EdgeForceIntranetContentRTSelController(stdController);
                                    
        //Assert test for intranetContentRecordTypes size 
        System.assert(controller.intranetContentRecordTypes.size() != 0);  
        
        //Assert test for Pagereference
        System.assert(controller.selectRecordType() <> null);
        
        //Assert test for cancel
        System.assert(controller.cancel() <> null);
    }
}