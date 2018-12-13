//
// (c) 2014 Appirio, Inc.
//
// Intranet - Create new "Blog" component
//
// September 24th, 2014   Sumit Tanwar Original (Ref. T-321629)
//
public with sharing class EdgeForceIntranetBlogController {
   DateTime todayDate = DateTime.now();
    // page id, this will decide that for which page we are going to 
    // show Leadership Corner and can be used to fetch Blog article 
    // according to page ids.
    public String pageId {get; set;}{pageId = 'Home';}
    //Value comes form custom setting, used to define banner rotating speed on intranet pages. 
    public Integer banner_Roating_Speed {get;set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> leadershipBlogList{get;set;}
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> leadershipBlogListOne{get;set;}
    public static String RECTYPENAME = 'Config - Portal';
   
    public EdgeForceIntranetBlogController() {
        leadershipBlogList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        leadershipBlogListOne = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        //Initialise default with 6 sec
        banner_Roating_Speed = 7000;
        //Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
        for(Intranet_Content__c qLinks : [Select Name, value__c From Intranet_Content__c where Name = 'Banner_Rotating_Speed' AND recordType.Name =: RECTYPENAME ]) {
            banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);                                
        }   
        leadershipBlogListOne = getAllArticleDetails();
        
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
       List<String> tagId = new List<String>();
       
       for(tags__c tag : [select id from tags__c where tag__c IN:listOfuserBusinessValues ]){
           tagId.add(tag.id);
       }
       //tagId  = [select id from tags__c where tag__c=:userBusinessFun Limit 1].id;
       List<Id> ICID          = new List<Id>();
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : leadershipBlogListOne){
           ICID.add(wrapper.content.id);
       }
       Set<Id> ICTagId = new Set<Id>();
       if(tagId !=null && tagId.size()>0 && ICID.size()>0){
           for(Intranet_Content_Tags__c ICTag : [select id,Intranet_Content__c from Intranet_Content_Tags__c where Intranet_Content__c IN :ICID AND Tags__c IN : tagId]){
               ICTagId.add(ICTag.Intranet_Content__c);
           }
       }
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : leadershipBlogListOne){
           If(!(ICTagId.contains(wrapper.content.id))){
                leadershipBlogList.add(wrapper);
           }
       }
    }   
        
   
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllArticleDetails(){
        
        List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
        String queryString = 'SELECT Id, URL__c, Start_Date__c, Name, End_Date__c,CreatedDate,Type__c,(SELECT Id  FROM Attachments LIMIT 1),(Select Tags__r.Tag__c From Intranet_Content_Tags__r)  FROM Intranet_Content__c Where Start_Date__c <=: todayDate and End_Date__c >=: todayDate and Type__c =\'Executive Blog\' and recordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE+'\' and Status__c = \'Published\' order by Sequence__c';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
        
        for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                           Where Start_Date__c <=: todayDate
                                           AND End_Date__c >=: todayDate
                                           AND Type__c = 'Executive Blog' 
                                           AND Status__c = 'Published'
                                           AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE
                                           order by Sequence__c]){
            for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper) {
                if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                    listofLocalContentVersionWrapper.add(wrapper);
                }
            }   
        } 
        return listofLocalContentVersionWrapper;
    }
}