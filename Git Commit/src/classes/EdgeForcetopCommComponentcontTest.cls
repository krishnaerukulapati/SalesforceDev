/**
  * Apex Class: EdgeForcetopCommComponentcontTest
  * Description: Test class for EdgeForcetopCommComponentcont
  * Created By: Ashish Sharma (JDC)
  * Created Date: November 18th, 2013. 
*/
@isTest
private class EdgeForcetopCommComponentcontTest {

    static testMethod void topCommunityControllerTest() {
               
        //Insert test user
        Profile profile = [SELECT Id FROM Profile
                           WHERE Name = 'System Administrator'
                           limit 1];
        
        
        User user = new User(ProfileId = profile.id, username = 'testUser283@gmail.com', email = 'test@gmail.com', 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US',
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                           alias='test', lastname='lastname');
        insert user;
        System.runAs(user){
            Test.startTest();
            CollaborationGroup testGroup1 = new CollaborationGroup();
        testGroup1.Name = 'Collaboration Group 1 for testing';
        testGroup1.CollaborationType = 'Public';
        insert testGroup1;
        
        CollaborationGroup testGroup2 = new CollaborationGroup();
        testGroup2.Name = 'Collaboration Group 2 for testing';
        testGroup2.CollaborationType = 'Public';
        insert testGroup2;
        
        CollaborationGroup testGroup3 = new CollaborationGroup();
        testGroup3.Name = 'Collaboration Group 3 for testing';
        testGroup3.CollaborationType = 'Public';
        insert testGroup3;
        
        FeedItem testFeed1 = new FeedItem(Body='Test Feed 1 Post', ParentId = testGroup1.Id, Type='TextPost');
        insert testFeed1;
        
        FeedItem testFeed2 = new FeedItem(Body='Test Feed 2 Post', ParentId = testGroup2.Id, Type='TextPost');
        insert testFeed2;
            EdgeForcetopCommComponentcont controller = new EdgeForcetopCommComponentcont();
            controller.grpId = testGroup3.Id;
            controller.follownewGroup();
            controller.unFollowGroup();
            
            //Assert test for userGroups
            System.assert(controller.userGroups <> null);
            Test.stopTest();
        }
    }
}