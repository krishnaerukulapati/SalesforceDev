/*******************************************************************
* Author        :  Harshit Jain 
* Name          :  IntranetDashboardController
* Date          :  December 03,2012
* Description   :  Used to update current user Information                 
*******************************************************************/
global with sharing class EdgeForceIntranetDashboardController {
        //hold current user information
    public User userInformation {get; set;}
    
    public EdgeForceIntranetDashboardController() {
        //populate current user information
        if(Userinfo.getUserId() != null) {
            userInformation = [Select u.TimeZoneSidKey, u.Phone, u.LastName, u.UserName, 
                               u.LanguageLocaleKey, u.FirstName, u.Email,u.Id,
                               u.Location__c, u.Filter_by_Location__c,u.LocaleSidKey,u.User_Business_Function__c
                               From User u 
                               WHERE Id =: Userinfo.getUserId()];
        }
    }
    
    //method updated current user information.
    //Notify current user via pagemessage
    public pageReference updateUserInformation() {
      if(userInformation.Id != null){
        userInformation.External_ID__c = userInformation.Id;
      }else{
        userInformation.External_ID__c =  userInformation.Name;
      }
      update userInformation;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Information has been updated. Email will be send to your new email id for confirmation if you updated your email.'));
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Information has been updated.'));
        return new pagereference('/apex/EF_UserProfile');    
    }
    
    //Fetch list of all tags
    @RemoteAction
    global static List<Tags__c> fetchListOfTags(){
        List<Tags__c> listOfTags =  new List<Tags__c>();
        for(Tags__c tg : [SELECT Id, Tag__c FROM Tags__c LIMIT 1000]){
            listOfTags.add(tg);
        }
        return listOfTags;
    }
    
    //Function to generate map of Tags and its Id
    public static Map<String, Id> mapTags {
        get{
            if(mapTags == null){
                mapTags = new Map<String, Id>();
                for(Tags__c tg : [SELECT Id, Tag__c FROM Tags__c]){
                    mapTags.put(tg.Tag__c, tg.Id);
                }
            }
            return mapTags;
        }
        private set;
    }
    
   //Fetch list of all tags for logged in user
    public List<Users_Tags__c> getLstUserTag(){
        List<Users_Tags__c> lstUserTag =  new List<Users_Tags__c>();
        for(Users_Tags__c tg : [SELECT Id, Tags__r.Tag__c, Tags__r.Id 
                                           FROM Users_Tags__c 
                                           WHERE User__c = :Userinfo.getUserId()]){
            lstUserTag.add(tg);
        }
        return lstUserTag;
    }
    
    @RemoteAction
    global static Boolean addTags(String tagString){
        List<Users_Tags__c> lstUserTags = new List<Users_Tags__c>();
        
        for(Users_Tags__c uTags :  [SELECT Id FROM Users_Tags__c WHERE User__c = :Userinfo.getUserId()]){
            lstUserTags.add(uTags);
        }
        
        //Delete all tags
        Database.delete(lstUserTags);
        
        List<Tags__c> lstNewTags = new List<Tags__c>();
        
        lstUserTags = new List<Users_Tags__c>();
        for(String s : tagString.split(',')){
            if(mapTags.containsKey(s)){
                lstUserTags.add(new Users_Tags__c(Tags__c = mapTags.get(s), User__c = Userinfo.getUserId()));
            }else{
                if(String.isNotBlank(s)){
                    Tags__c newTag = new Tags__c(Tag__c = s);
                    lstNewTags.add(newTag);    
                }
                
            }
        }
        
        //Insert new tags
        if(lstNewTags != null && !lstNewTags.isEmpty()){
            Database.insert(lstNewTags);
        }
        
        for(Tags__c tg : lstNewTags){
            lstUserTags.add(new Users_Tags__c(Tags__c = tg.Id, User__c = Userinfo.getUserId()));
        }
        
        if(lstUserTags != null && !lstUserTags.isEmpty()){
            Database.insert(lstUserTags);
        }
        
        return true;
    }
}