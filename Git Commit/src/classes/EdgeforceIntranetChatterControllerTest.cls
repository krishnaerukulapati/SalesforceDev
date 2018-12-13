/**
  * Apex Class: IntranetChatterControllerTest
  * Description: Test class for IntranetChatterController
  * Created By: Ashish Sharma (JDC)
  * Created Date: December 26th, 2013.
*/
@isTest
private class EdgeforceIntranetChatterControllerTest {

    static testMethod void chatterControllerTest() {
      //Insert test user
        User user = IntranetTestUtility.createUser(Integer.valueOf(Math.random()), true);

        System.runAs(user){
          CollaborationGroup testGroup = IntranetTestUtility.createGroup(true);
      EdgeforceIntranetChatterController controller = new EdgeforceIntranetChatterController ();
      controller.showPeople();
      //Assert test for chatterUsers
      System.assert(controller.chatterUsers <> null);

      controller.showfeed();
      //Assert test for isFeed, isPeople and isGroup
      System.assert(controller.isFeed && !controller.isPeople && !controller.isGroup);

      controller.showGroup();
      controller.createNewGroup();
      controller.isPeople = true;
      controller.showMorePeople();
      //Asser test for userGroups
      System.assert(controller.userGroups <> null);

        }
    }
}