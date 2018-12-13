public with sharing class EdgeforceDocumentDirectoryController{
  
  public List<ContentVersion> contents {get;set;}
  Public List<String> librariesMap {get;set;}
  Public String libraryName {get;set;}
  
  private static final list<String> NOT_INCLUDED_LIBRARIES = new List<String>{'*Teva Master'};
  public static final string NAME_PRAM = 'name';
  public User currentUser {get; set;}
  public string selectedLib {get; set;}
  public String resourceIdInController{get;set;}
  public ContentVersion versionDataforUI{get;set;}
  public Map<String,ContentVersion> mapofversionIdandVersion ;
  public String allowedPreviewFormats{get; set;}
  /*
  * Default Contstructor, this will fetch the library contents that will
  * we used in pages which use resource component.
  */
    public EdgeforceDocumentDirectoryController() {   
        librariesMap = new List<String>();
        
        //Fetch current user   
        for(User u :[Select Id, UserPermissionsSFContentUser From User 
                          where Id  =:UserInfo.getUserId()]){
            currentUser = u;             
        }
        //Return if current user has no permission for access of contents
        if(currentUser.UserPermissionsSFContentUser == false){
            return;
        }   
        
        allowedPreviewFormats = '';
        for(Intranet_content__c config : [Select Name, value__c 
                                            From Intranet_content__c 
                                            where recordType.Name = 'Config - Portal'
                                                AND Name like 'Allowed Preview Formats']) {
        
            if(allowedPreviewFormats == ''){
                allowedPreviewFormats = config.Value__c;
            }
            else{
                allowedPreviewFormats += ',' + config.Value__c;
            }
        }
        
        for(ContentWorkspace cWD :[Select Id, Name 
                                             From ContentWorkspace
                                             Where Name !='*master'
                                             Order by Name DESC]){
            librariesMap.add(cWD.Name);
        }  
        librariesMap.add(Label.All);
        librariesMap.sort();
        libraryName=Label.All;
        fetchContents();
       
    }
  

    Public void fetchContents(){
        Set<ID> contentIDs = new Set<ID>();
        if(!String.isBlank(ApexPages.currentPage().getParameters().get(NAME_PRAM)))
            libraryName= ApexPages.currentPage().getParameters().get(NAME_PRAM);
            
        String query = 'Select ContentDocumentId, ContentWorkspace.Name '+
                       '      From ContentWorkspaceDoc ';
        if(libraryName!=Label.All) 
            query +=' Where ContentWorkspace.Name=:libraryName ';
        query +='Order by ContentWorkspace.Name ';
        
 
        for(SObject objectR : Database.query(query))
            contentIDs.add(String.valueOf(objectR.get('ContentDocumentId')));
              
        // Fetch library contents.
        contents = [Select Owner.Name, ContentUrl, Title ,ContentSize, Id, FileType,LastModifiedDate
                        From ContentVersion 
                        Where ContentDocument.Id = :contentIDs
                          And IsLatest = true
                        ORDER BY CreatedDate DESC]; 
    }

  
    public void processContent(){
        String contentId = '';
        if(apexpages.currentPage().getParameters().get('resourceIdParam') <> null){
            contentId = apexpages.currentPage().getParameters().get('resourceIdParam');
        }
        
        versionDataforUI = [Select Owner.Name, ContentUrl, Title ,ContentSize, Id, FileType,LastModifiedDate,TagCsv
                                              From ContentVersion 
                                              Where Id = :contentId
                                              Limit 1];
    }
}