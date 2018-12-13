/**
  * Apex Class: IntranetLinkComponentController
  * Description: This class is used to fetch Intranet links and thier attachments (T-97451)
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 23rd Nov 2012.
  * LastModifiedBy : Harshit Jain
  * LastModifiedDate : December 12,2012
  * RelatedTo : Maintain IntranetList as per the selected current page. 
*/
public with sharing class EdgeForceIntranetLinkComponentController {
        DateTime todayDate = DateTime.now();
        public String pageId {get;set;}{pageId='Home';}
        public Integer no_Of_Link {get;set;}
        public List<EdgeForceIntranetContentController.ContentVersionWrapper> intranetList{get;set;}
        public List<EdgeForceIntranetContentController.ContentVersionWrapper> intranetList1{get;set;}

    /*
    * Default Constructor, this will initialize the intranet list and fetch
    * intranet link lists.
    */
    
    public EdgeForceIntranetLinkComponentController() {
        
      intranetList = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      intranetList1 = new List<EdgeForceIntranetContentController.ContentVersionWrapper>();
      //Initialise default with 6
      no_Of_Link = 6;
      //Retrieve No of Links configured from the Custom setting by Sys Admin
      
      for(Intranet_content__c qLinks : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal' AND Name = 'NO_OF_LINKS']) {
                    no_Of_Link = Integer.valueOf(qLinks.Value__c);                              
      }
      intranetList1 = getAllLinksDetails();
      
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
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : intranetList1){
           ICID.add(wrapper.content.id);
       }
       Set<Id> ICTagId = new Set<Id>();
       if(tagId !=null && tagId.size()>0 && ICID.size()>0){
           for(Intranet_Content_Tags__c ICTag : [select id,Intranet_Content__c from Intranet_Content_Tags__c where Intranet_Content__c IN :ICID AND Tags__c IN : tagId]){
               ICTagId.add(ICTag.Intranet_Content__c);
           }
       }
       system.debug('***ICTagId****'+ICTagId);
       for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : intranetList1){
           If(!(ICTagId.contains(wrapper.content.id))){
                intranetList.add(wrapper);
           }
       }
    }
      
    
      // intranet links list used to show links on pages.
        /*public List<Intranet_Content__c> intranetList {
            get {
            // query for links and their attachments
            return [SELECT URL__c, Name,Target__c, (SELECT Id FROM Attachments LIMIT 1)
                    FROM Intranet_Content__c   
                    WHERE  Start_Date__c<= :system.now()
                    AND  End_Date__c >= :system.now() 
                    AND pages__c includes (:pageId) 
                    AND recordtype.Name=:IntranetContentController.RECORDTYPE_INTERNET_LINK
                    ORDER BY Sequence__c 
                    LIMIT :no_Of_Link];
            }
            set;
        }*/
        
    /*
     *Method to process all details
     *author Debadyuti Sil
    */
    public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllLinksDetails(){
    
     List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     String queryString =  'Select URL__c,Target__c, (SELECT Id, Name  FROM Attachments limit 1), (Select Tags__r.Tag__c From Intranet_Content_Tags__r)  From Intranet_Content__c  WHERE  Start_Date__c <=: todayDate  AND  End_Date__c >=: todayDate AND Type__c =\'Quick Link\'   AND RecordType.Name =\''+EdgeForceIntranetContentController.RECORDTYPE_INTERNET_LINK+'\' order by Sequence__c ';                                            
     EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
     tempListofLocalContentVersionWrapper = contentController.processContentAndVersion(queryString);
     
     Integer recordCount = 0;
     for(Intranet_Content__c content : [SELECT Id FROM Intranet_Content__c
                                        Where Start_Date__c <=: todayDate
                                        AND End_Date__c >=: todayDate
                                        AND Type__c = 'Quick Link' 
                                        AND recordType.Name =: EdgeForceIntranetContentController.RECORDTYPE_INTERNET_LINK
                                        order by Sequence__c]){
         for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)   {
            if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
                    listofLocalContentVersionWrapper.add(wrapper);
                    recordCount= recordCount + 1;
            }
         }  
         //check if number of records reached at max limit of records
         if(recordCount == no_Of_Link){
            break;
         }
     }          
     return listofLocalContentVersionWrapper;
    }
  
}