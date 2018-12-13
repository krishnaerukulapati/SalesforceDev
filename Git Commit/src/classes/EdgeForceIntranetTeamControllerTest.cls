/**
  * Apex Class: IntranetTeamControllerTest
  * Description: test class for IntranetTeamController
  * Created By: Dipika Gupta (Appirio Off)
  * Created Date: 17 Dec,2012
*/
@isTest (seeAllData=false)
private class EdgeForceIntranetTeamControllerTest {
    
    private static testmethod void TeamControllerTest(){
        //Insert new Collaboration Group
        //CollaborationGroup collaborationGroup = TestUtil.createGroup(true);
        
        //Set IntranetTeam as current page
        PageReference pageRef = Page.EF_Team;
        Test.setCurrentPage(pageRef);
        
        //Pass parameteres to current page
        ApexPages.currentPage().getParameters().put('name', 'testGroup');
        
        EdgeForceIntranetTeamController conObj = new EdgeForceIntranetTeamController();
        
        //assert controller's property 'groupId' value has been changed to collaborationGroup
        //system.assertEquals(conObj.groupId,collaborationGroup.Id);
    }
}