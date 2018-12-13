/**
  * Apex Class: IntranetNewsFeedComponentController
  * Description: This class is used to show intranet news feeds (T-97451)
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: Nov 23rd, 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain IntranetList as per the selected current page.
  */
public with sharing class EdgeForceIntranetNewsFeedCompController {
    DateTime todayDate = DateTime.now();
    // page id, this will decide that for which page we are going to 
    // show news feed and can be used to fetch news feed according to
    // page ids.
        public String pageId {get{
            if(ApexPages.currentPage().getParameters().get('name') != null) {
                return ApexPages.currentPage().getParameters().get('name');
            }else{
                return 'Home';
            }
        }
         set;}
         
        public String tabName {get{
            if(ApexPages.currentPage().getParameters().get('tabName') != null){
                return ApexPages.currentPage().getParameters().get('tabName');
            }else{
                return 'Home';
            }
          }
        
         set;}
         
        DateTime startDate = system.Now();
        DateTime endDate = system.Now();
    //Value comes form custom setting, used to define banner rotating speed on intranet pages. 
        public Integer banner_Roating_Speed {get;set;}
        public  List<EdgeForceIntranetContentController.ContentVersionWrapper> newsList {get;set;}
        public EdgeForceIntranetNewsFeedCompController() {
            //Initialise default with 6 sec
        banner_Roating_Speed = 7000;
        //Retrieve Banner rotating speed configured from the Custom setting by Sys Admin
        for(Intranet_Content__c qLinks : [Select Name, value__c From Intranet_Content__c where Name = 'Banner_Rotating_Speed' AND recordType.Name = 'Config - Portal']) {
                    banner_Roating_Speed = Integer.valueOf(qLinks.Value__c);                                
        }   
           newsList = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
           newsList = getAllArticleDetails();
           system.debug('**newsList***'+newsList);
        }       
      /*
     * Get news list along with their attached images to show on page. 
    */
  /*    public List<Intranet_Article__c> newsList {
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
                        and Article_Type__c != 'Leadership Corner' 
                        and Article_Type__c != 'Announcements & Newsletters'
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
        String queryString = 'SELECT Id, URL__c, Start_Date__c, Name, End_Date__c,CreatedDate,Type__c,(SELECT Id  FROM Attachments LIMIT 1),(Select Tags__r.Tag__c From Intranet_Content_Tags__r) FROM Intranet_Content__c Where Start_Date__c <=: todayDate and End_Date__c >=: todayDate and Type__c = \'News\' and recordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE+'\' order by Sequence__c';
        EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
        tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
        
        for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                           Where Start_Date__c <=: todayDate
                                           AND End_Date__c >=: todayDate
                                           AND Type__c = 'News' 
                                           AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_ARTICLE
                                           order by Sequence__c]){
            for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)    {
                if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                    listofLocalContentVersionWrapper.add(wrapper);
                }
            }   
        }                                                                       
        return listofLocalContentVersionWrapper;
    }
}