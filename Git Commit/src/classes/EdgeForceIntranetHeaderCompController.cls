/**
  * Apex Class: IntranetHeaderComponentController
  * Description: This class is used to get current logged in user information.
  *               (T-97451)  
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 23rd Nov 2012.
*/
public with sharing class EdgeForceIntranetHeaderCompController {
    public User currentUser {get; set;}
    public String pageId {get;set;}
    public Integer unreadCounts {get;set;}
    
    /*
     * Default Constructor, it will fetch the details of logged in user.
    */
    public EdgeForceIntranetHeaderCompController () {
        currentUser = [SELECT Id, SmallPhotoUrl, Name FROM User WHERE Id = :UserInfo.getUserId()];
        unreadCounts = 0;
        for(Intranet_Notification__c  ee:[SELECT Id FROM Intranet_Notification__c 
                                          WHERE  User__c =:Userinfo.getUserId() 
                                          AND Is_Viewed__c = false]){
           unreadCounts	++;
        }
    }

}