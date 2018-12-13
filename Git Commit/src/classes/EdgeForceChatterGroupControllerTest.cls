/**
  * Apex Class: EdgeForceChatterGroupControllerTest
  * Description: Test class for EdgeForceChatterGroupController
  * Created By: Ashish Sharma (JDC)
  * Created Date: December 27th, 2013.
*/
@isTest
private class EdgeForceChatterGroupControllerTest {

    static testMethod void chatterGroupTest() {
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random()), true);

        System.runAs(user){
            User user1 = IntranetTestUtility.createUser(Integer.valueOf(Math.random() +5), true);

            CollaborationGroup testGroup = TestUtil.createGroup(true);
            CollaborationGroupMember testGroupMember =  IntranetTestUtility.createGroupMember(user1.Id, testGroup.Id, true);

            ApexPages.currentPage().getParameters().put('g', testGroup.Id);
            EdgeForceChatterGroupController controller = new EdgeForceChatterGroupController();
            controller.showAllUsers();
            
            controller.searchText='';
            controller.searchUser();
            
            controller.searchText=userinfo.getName();

            controller.searchUser();
            //Asser test for userList
            System.assert(controller.userList != null);
        }
    }
}