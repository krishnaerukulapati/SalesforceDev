/**
  * Apex Class: IntranetLeadershipCornerController
  * Description: T-178858 : Intranet - Create new "Leadership Corner" component
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: August 30th, 2013.
  */
public with sharing class EdgeForceIntranetLdrshipCornerController {
    DateTime todayDate = DateTime.now();
    // page id, this will decide that for which page we are going to 
    // show Leadership Corner and can be used to fetch Leadership Corner article 
    // according to page ids.
    public String pageId {get; set;}{pageId = 'Home';}
    //Value comes form custom setting, used to define banner rotating speed on intranet pages. 
    public Integer banner_Roating_Speed {get;set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> leadershipCornerList{get;set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> leadershipCornerList1{get;set;}
    public EdgeForceIntranetLdrshipCornerController() {
        leadershipCornerList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        leadershipCornerList1 = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        //Initialise default with 6 sec
        banner_Roating_Speed = 7000;
        //Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
        for(Intranet_Content__c qLinks : [Select Name, value__c From Intranet_Content__c where Name = 'Banner_Rotating_Speed' AND recordType.Name = 'Config - Portal' ]) {
            banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);                                
        }   
        leadershipCornerList1 = getAllArticleDetails();
        
        
        //By Sachin Kadian to show only banner's whose tags are same as user's User Business Function
       Schema.DescribeFieldResult userBusiness = user.User_Business_Function__c.getDescribe();
       List<Schema.PicklistEntry> userBusinessValues = userBusiness.getPicklistValues();
       List<String> listOfuserBusinessValues         = new List<String>();
       
       String userBusinessFun = [select id,User_Business_Function__c from User where id=: userInfo.getUserId()].User_Business_Function__c;
       for(Schema.PicklistEntry entry : userBusinessValues){
           if(userBusinessFun!=null && userBusinessFun!='' && entry.value == userBusinessFun){}
           else{
               listOfuserBusinessValues.add(entry.Value);
           }
       }
       system.debug('***listOfuserBusinessValues****'+listOfuserBusinessValues);
       List<String> tagId = new List<String>();
       
       for(tags__c tag : [select id from tags__c where tag__c IN:listOfuserBusinessValues ]){
           tagId.add(tag.id);
       }
       //tagId  = [select id from tags__c where tag__c=:userBusinessFun Limit 1].id;
       system.debug('***tagId****'+tagId);
       List<Id> ICID          = new List<Id>();
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : leadershipCornerList1){
           ICID.add(wrapper.content.id);
       }
       Set<Id> ICTagId = new Set<Id>();
       if(tagId !=null && tagId.size()>0 && ICID.size()>0){
           for(Intranet_Content_Tags__c ICTag : [select id,Intranet_Content__c from Intranet_Content_Tags__c where Intranet_Content__c IN :ICID AND Tags__c IN : tagId]){
               ICTagId.add(ICTag.Intranet_Content__c);
           }
       }
       system.debug('***ICTagId****'+ICTagId);
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : leadershipCornerList1){
           If(!(ICTagId.contains(wrapper.content.id))){
                leadershipCornerList.add(wrapper);
           }
       }
        System.debug('**********leadership Corner List is *******'+leadershipCornerList );
    }   
        
    /*
     * Get Leadership Corner article list along with their attached images to show on page. 
     */
    /*public List<Intranet_Article__c> leadershipCornerList {
        get {
            return [SELECT Id, URL__c, Summary__c, Start_Date__c, Pages__c, 
                       Name, End_Date__c, Description__c, CreatedDate, 
                       Article_Type__c,
                       (SELECT Id 
                        FROM Attachments LIMIT 1)
                  FROM Intranet_Article__c 
                  Where Start_Date__c <= :system.now()
                        and End_Date__c >= :system.now() 
                        and Pages__c includes (:pageId)
                        and Article_Type__c = 'News' 
                 order by Start_Date__c DESC
                limit 5];
        } 
        set;
    }*/
    
    
     /*
     *Method to process all details
     *author Debadyuti Sil
    */
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllArticleDetails(){
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        String queryString = 'SELECT Id, URL__c, Start_Date__c, Name, End_Date__c,CreatedDate,Type__c,(SELECT Id  FROM Attachments LIMIT 1),(Select Tags__r.Tag__c From Intranet_Content_Tags__r)  FROM Intranet_Content__c Where Start_Date__c <=: todayDate and End_Date__c >=: todayDate and Type__c =\'News\' and recordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE+'\' and Status__c = \'Published\' order by Sequence__c';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
        System.debug('*********tempListofLocalContentVersionWrapper*********'+tempListofLocalContentVersionWrapper);
        
        for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                           Where Start_Date__c <=: todayDate
                                           AND End_Date__c >=: todayDate
                                           AND Type__c = 'News' 
                                           AND Status__c = 'Published'
                                           AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE
                                           order by Sequence__c]){
            System.debug('************Intranet Content********'+content);
            for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper) {
                if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                    listofLocalContentVersionWrapper.add(wrapper);
                }
            }   
        } 
        System.debug('&&&&&&&&&&listofLocalContentVersionWrapper&&&&&& '+listofLocalContentVersionWrapper);                                                      
        return listofLocalContentVersionWrapper;
    }
}