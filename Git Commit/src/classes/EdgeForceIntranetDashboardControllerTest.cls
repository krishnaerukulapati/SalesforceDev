/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetDashboardControllerTest
* Date          :  December 03,2012
* Related Task  :  T-101364
* Description   :  Verify functionality of EdgeForceIntranetDashboardControllerclass.                 
*******************************************************************/
@isTest
private class EdgeForceIntranetDashboardControllerTest {

    static testMethod void testUserinformationUpdate() {
        EdgeForceIntranetDashboardController controller = new EdgeForceIntranetDashboardController();
        //loginUser information should not be null
        system.assert(controller.userInformation != null);
        
        //Update user information with correct data 
        controller.userInformation.Phone = '123878342';
        controller.userInformation.Email = 'TestSystemUser@virginamerica.com';
        controller.userInformation.External_ID__c = 'Test';
        controller.updateUserInformation();
        User updatedUser1 = getUser(userInfo.getUserId());
        system.assert(updatedUser1 != null);
        system.assertEquals(updatedUser1.Phone , '123878342');
        
        //Update user last name information
        controller.userInformation.LastName = 'TestLastname';
        controller.userInformation.External_ID__c = 'Test';
        controller.updateUserInformation();
        User updatedUser2 = getUser(userInfo.getUserId());
        system.assert(updatedUser2 != null);
        system.assertEquals(updatedUser2.LastName , 'TestLastname');
        
        Tags__c testTag = new Tags__c();
        testTag.Tag__c = 'Test Tag';
        insert testTag;
        
        Users_Tags__c userTag = new Users_Tags__c();
        userTag.User__c = Userinfo.getUserId();
        userTag.Tags__c = testTag.Id;
        insert userTag;
        controller.getLstUserTag();
        List<Tags__c> listOfTags = EdgeForceIntranetDashboardController.fetchListOfTags();
        //Assert test for listOfTags
        System.assertNotEquals(null, listOfTags);
        
        Map<String, Id> tagMap = EdgeForceIntranetDashboardController.mapTags;
        //Assert test for tagMap
        System.assertNotEquals(null, tagMap);
        
        EdgeForceIntranetDashboardController.addTags('Test Tag');
        //Assert test for user tags
        System.assertNotEquals(null, [SELECT ID FROM Users_Tags__c 
                                      WHERE User__c =: Userinfo.getUserId()]);
        
    }
    
   //get User Information
   private static User getUser(Id userId) {
    return [Select u.TimeZoneSidKey, u.Phone, u.LastName, 
                                     u.LanguageLocaleKey, u.FirstName, u.Email 
                            From User u 
                         where Id =: userId];
   }
}