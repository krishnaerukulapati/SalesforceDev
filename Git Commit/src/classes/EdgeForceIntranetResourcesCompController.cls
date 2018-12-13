/**
  * Apex Class: IntranetResourcesComponentController
  * Description: This class is used to get Intranet chatter information. (T-97451) 
  * Created By: Dheeraj Kumar (Appirio Off)
  * Created Date: 26th Nov 2012.
*/

public with sharing class EdgeForceIntranetResourcesCompController {
    
    public map<String,List<ContentVersion>> libraries{get;set;}
    private static final list<String> NOT_INCLUDED_LIBRARIES = new List<String>{'*Teva Master'};
    public static final string NAME_PRAM = 'name';
    public User currentUser {get; set;}
    public string selectedLib {get; set;}
    public String resourceIdInController{get;set;}
    public ContentVersion versionDataforUI{get;set;}
    public Map<String,ContentVersion> mapofversionIdandVersion ;
    Public Boolean contentFlag {get;set;}
    /*
    * Default Contstructor, this will fetch the library contents that will
    * we used in pages which use resource component.
    */
    public EdgeForceIntranetResourcesCompController() {
       contentFlag = True;
       libraries = new map<String,List<ContentVersion>>();       
       Set<Id> contentDocIds = new Set<Id>();
       selectedLib = ApexPages.currentPage().getParameters().get(NAME_PRAM);    
       //Fetch current user   
       for(User u :[Select Id, UserPermissionsSFContentUser From User 
                    where Id  =:UserInfo.getUserId()]){
         currentUser = u;               
       }
       //Return if current user has no permission for access of contents
       if(currentUser.UserPermissionsSFContentUser == false){
         return;
       }     
       
       for(ContentWorkspaceDoc cWDoc :[Select ContentDocumentId 
                                       From ContentWorkspaceDoc
                                       Where ContentWorkspace.Name =: selectedLib]){
           contentDocIds.add(cWDoc.ContentDocumentId);
       }    
         
         mapofversionIdandVersion = new Map<String,ContentVersion>();
          // Fetch library contents.
        for(ContentVersion content : [Select OwnerId, ContentUrl, Title ,IsLatest, ContentDocument.ParentId, TagCsv ,
                                      ContentDocumentId, Id, Team_Category__c,FileType
                                      From ContentVersion 
                                      Where ContentDocument.Id IN :contentDocIds 
                                      And IsLatest = true
                                      AND Team__c includes(: selectedLib)  
                                      ORDER BY CreatedDate DESC]) {
                //manage document by team category                                              
         if(content.Team_Category__c != null){
              mapofversionIdandVersion.put(content.Id,content);
             if(libraries.containsKey(content.Team_Category__c)){
                libraries.get(content.Team_Category__c).add(content);
             }else{
                List<ContentVersion> conVersions = new List<ContentVersion>(); 
                conVersions.add(content);
                libraries.put(content.Team_Category__c,conVersions);
             }
         }      
        } 
        
        if(libraries.size()==0)
            contentFlag = False;
        System.debug('$$$$$'+libraries);
    }
    
    
    
    public void processContent(){
        String contentId = '';
        if(apexpages.currentPage().getParameters().get('resourceIdParam') <> null){
            contentId = apexpages.currentPage().getParameters().get('resourceIdParam');
        }
        versionDataforUI = new ContentVersion();
        if(mapofversionIdandVersion.containsKey(contentId)){
          versionDataforUI = mapofversionIdandVersion.get(contentId);
        }
    }
    
}