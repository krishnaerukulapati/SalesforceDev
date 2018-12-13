/**
  * Apex Class: IntranetBannerController
  * Description: This class is used to fetch the Banner records and used to build the Banner section dynamically
  *              (T-97451).
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 26th Nov 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain banners list as per the selected current page. 
*/
public with sharing class EdgeForceIntranetBannerController {
     DateTime todayDate = DateTime.now();
     public String currentPageName {get; set;}{currentPageName = 'Home';}
     //Value comes form custom setting, used to define banner rotating speed on intranet pages. 
     public List<EdgeForceIntranetContentController.ContentVersionWrapper> banners{get;set;} 
     public List<EdgeForceIntranetContentController.ContentVersionWrapper> banners1{get;set;} 
     public Integer banner_Roating_Speed {get;set;}
    // public String CONTENT_LANGUAGE{get;set;} {CONTENT_LANGUAGE = '';} 
     
    /*
     * here we all the valid banner records will be retrieved and to be used on Intranet Banner
       to show the dynamic banner 
    */
    
    public EdgeForceIntranetBannerController() {
        
        
      //Initialise default with 6 sec
      banner_Roating_Speed = 7000;
      //Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
      for(Intranet_Content__c qLinks : [Select Name, value__c From Intranet_Content__c where Name = 'Banner_Rotating_Speed' AND recordType.Name = 'Config - Portal' ]) {
                banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);                                
      } 
      
      //Initialize all properties
       banners = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
       banners1 = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
       banners1 = getAllBannerDetails();
       
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
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : banners1){
           ICID.add(wrapper.content.id);
       }
       Set<Id> ICTagId = new Set<Id>();
       if(tagId !=null && tagId.size()>0 && ICID.size()>0){
           for(Intranet_Content_Tags__c ICTag : [select id,Intranet_Content__c from Intranet_Content_Tags__c where Intranet_Content__c IN :ICID AND Tags__c IN : tagId]){
               ICTagId.add(ICTag.Intranet_Content__c);
           }
       }
       system.debug('***ICTagId****'+ICTagId);
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : banners1){
           If(!(ICTagId.contains(wrapper.content.id))){
                banners.add(wrapper);
           }
       }
       system.debug('***banners****'+banners);
    }
    
    
    
   
    /*
     *Method to process all details
     *author Debadyuti Sil
    */
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllBannerDetails(){
    
     List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     String queryString =  'Select URL__c,Target__c, (SELECT Id, Name  FROM Attachments limit 1), (Select Tags__r.Tag__c From Intranet_Content_Tags__r)  From Intranet_Content__c  WHERE  Start_Date__c <=: todayDate  AND  End_Date__c >=: todayDate AND RecordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER+'\'order by Sequence__c';
     
     EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
     tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
        
     for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                        Where Start_Date__c <=: todayDate
                                        AND End_Date__c >=: todayDate
                                        AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_BANNER
                                        order by Sequence__c]){
         for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)   {
             if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                    listofLocalContentVersionWrapper.add(wrapper);
             }
            }   
     }                                    
     return listofLocalContentVersionWrapper;
    }
}