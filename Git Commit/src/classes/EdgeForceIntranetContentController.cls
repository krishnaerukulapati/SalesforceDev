/**
  * Apex Class: IntranetContentController
  * Description: This class is used to display Content 
  * Created By: Virendra (Appirio Off)
  * Created Date: 23rd Nov 2012.
  * Updated Date : December 6, 2012
  * Related To : T-102188 - Add standard chatter component to IntranetArticle 
  * LastUpdatedBy : Harshit Jain
  * LastUpdatedDate : December 11, 2012
  * Related To : Used this class to show IntranetArticle data on IntranetContent Page.
  ******************************************************************************************
  *Modified by   : Sil
  *Modified date : 10-March-2014
  *purpose       : Content was not displaying based on tag specific as tag code was commented.
  *changeid      : c001 
   ******************************************************************************************
  */
global class EdgeForceIntranetContentController {
  DateTime todayDate = DateTime.now();
  public list<Attachment> galleryAttachmentList{get;set;}
  public String categoryType {get;set;}
  public String tabName {get;set;}  
  //public String cmsPageId {get;set;}
  // It will use to render the attachments on content page
  public boolean renderAttachment {get;set;}
  // It will use to get the attachment
  public ContentVersionWrapper cmsPage{get;set;}
  // It will use to show article description on page 
  public ContentVersionWrapper articleDetail{get;set;}
  public String contentIdinParameter{get;set;}
  public String pageName {get; set;}

  
  //Sil:Different REcordTypes of Content
    public  static String RECORDTYPE_INTERNET_BANNER   = 'Intranet Banner';
    public  static String RECORDTYPE_INTERNET_ARTICLE  = 'Intranet Article';
    public  static String RECORDTYPE_INTERNET_LINK     = 'Intranet Link';

   
  /*
  * Default constructor create data based on category parameter of url
  * weather it is Intranet content or Intranet Articles.
  */
  public EdgeForceIntranetContentController() {
     renderAttachment = false; 
     galleryAttachmentList = new list<Attachment>();
     tabName = 'Home';
     contentIdinParameter = '';
     
     if(ApexPages.currentPage().getParameters().get('tabName') != null && ApexPages.currentPage().getParameters().get('tabName') <> '') {
        tabName = ApexPages.currentPage().getParameters().get('tabName');
     }    
       categoryType = ApexPages.currentPage().getParameters().get('category');
       contentIdinParameter = ApexPages.currentPage().getParameters().get('Id');
       if(ApexPages.currentPage().getParameters().get('Name') != null && ApexPages.currentPage().getParameters().get('Name') <> '') {
         pageName = ApexPages.currentPage().getParameters().get('Name');
       }else{
         pageName = 'Home';
       }
       
    // It will prevent rendering attachments on IntranetContent page.
    
     if(contentIdinParameter != null && contentIdinParameter <>'' && categoryType <> null && categoryType <> '') {
          contentIdinParameter = ApexPages.currentPage().getParameters().get('Id');       
          processContentAndVersionforDetailpage(contentIdinParameter,categoryType);
     }
        /*if(categoryType == 'News' || categoryType == ''Executive Blog'' || categoryType == 'Leadership Corner' || categoryType == 'Announcements & Newsletters'
           || categoryType == 'Global Alert') {
            createArticleData(ApexPages.currentPage().getParameters().get('Id'));
        }else if(categoryType == 'Content') {
            createContentData(ApexPages.currentPage().getParameters().get('Id'));
        }   */                  
  }
    
     
/*  public void createContentData(String contentId) {
    // Fetch Intranet CMS content details  
    for(Intranet_CMS_Page__c cmsPageObj : [Select Template__c, SystemModstamp, Status__c,
                                                     (SELECT Id, Name 
                                                        FROM Attachments order by createdDate  ) 
                                                        Id, Parent_page__r.name,Name, Description__c,
                                                      Video__c, Video_Type__c, Video_Caption__c
                                            From Intranet_CMS_Page__c Where Id =:contentId ]) {
            //Prepare attachement images list                                               
        for(Attachment attachedImage : cmsPageObj.Attachments) {
           galleryAttachmentList.add(attachedImage);                      
      }
      cmsPage = cmsPageObj;
    }   
  }  
  
  public void createArticleData(String articleId) {
    for(Intranet_Article__c intranetArticle : [Select i.URL__c, i.Summary__c, i.Name,
                                               i.Id, i.Description__c, i.Article_Type__c,
                                              (Select Id, Name From Attachments)
                                              From Intranet_Article__c i where Id=: articleId]) {
            //Prepare attachement images list                                                                                               
        for(Attachment attachment : intranetArticle.Attachments) {
        galleryAttachmentList.add(attachment);
      }
      articleDetail = intranetArticle;
    }       
  }*/
  
  public void processContentAndVersionforDetailpage(String contentId,String categoryType) {
  System.Debug('CAtest contentId = '+contentId +' categoryType = ' + categoryType);
         renderAttachment = false;
         List<ContentVersionWrapper> listofvontentversionWrapper = new  List<ContentVersionWrapper>();
         String queryString =  'Select URL__c, Template__c, SystemModstamp,Target__c, (SELECT Id, Name  FROM Attachments),(Select Tags__r.Tag__c From Intranet_Content_Tags__r) From Intranet_Content__c  WHERE  id=\''+contentId+'\'';                          
         listofvontentversionWrapper = processContentAndVersion(queryString);
         if(listofvontentversionWrapper.size()>0){
            if(categoryType == 'News' || categoryType == 'Executive Blog' || categoryType == 'Leadership Corner' || categoryType == 'Announcements & Newsletters' || categoryType == 'Global Alert' || categoryType == 'Training'){
                renderAttachment = true;    
                articleDetail = listofvontentversionWrapper[0];
                System.Debug('CATEST*** '+ listofvontentversionWrapper[0]);
            }else if(categoryType == 'Content' ){
                renderAttachment = true;       
                cmsPage = listofvontentversionWrapper[0];
            }
            if(listofvontentversionWrapper[0].content <> null && listofvontentversionWrapper[0].content.Attachments <> null && listofvontentversionWrapper[0].content.Attachments.size()>0){
                galleryAttachmentList.addall(listofvontentversionWrapper[0].content.Attachments);
            }
         }
  
  }
  
  /*
     *Wrapper to Store all content Details in same place[Assuming There can be list of contenct and each content can have list of versions]
     *author Debadyuti Sil
    */
    
    global Class ContentVersionWrapper{
        public Intranet_Content__c                  content                     {get;set;}      {content = new Intranet_Content__c();}
        public Intranet_Content_Version__c          contentVersionforDisplay    {get;set;}      {contentVersionforDisplay = new Intranet_Content_Version__c();}//this will be used if filtered version need to be displayed on page(on load)
        
        public ContentVersionWrapper(Intranet_Content__c localContent ,Intranet_Content_Version__c localContentVersionforDisplay){
            this.content = localContent ;           
            this.contentVersionforDisplay = localContentVersionforDisplay;
        }       
    }
    
  
   /**
     *Process Different type of Contenct and return list of wrapper
     *author Debadyuti Sil
    */
  
  public  List<ContentVersionWrapper> processContentAndVersion(String query){
        
        List<ContentVersionWrapper>                 listofContentandVersionWrapper      = new List<ContentVersionWrapper>();
        Map<String,Intranet_Content__c>             mapofContentIdAndContent            = new Map<String,Intranet_Content__c>();
        Map<String,Set<String>>                     mapofContentIdAndSetofVesrsionsIds  = new Map<String,Set<String>>();
        Map<String,Intranet_Content_Version__c>     mapofVersionIdIdAndVersion          = new Map<String,Intranet_Content_Version__c>();
        Set<String>                                 setofContentVersions;
        String                                      userLocalLanguage;
        Set<String>                                 setofLanguages                      = new Set<String>(); 
        
        userLocalLanguage = '';         
        //user local language from setting
        for(Intranet_content__c intranetConfig : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal' AND name =: userinfo.getLanguage()]){
            if(intranetConfig <> null && intranetConfig.value__c <> null){
                userLocalLanguage = intranetConfig.value__c;
                for(String language : userLocalLanguage.split(';')){    
                    language = language.toUpperCase();      
                    setofLanguages.add(language);
                }
            }
        }
        for(Intranet_Content__c localContent :  Database.query(query)){ 
                                                    
             if(localContent <> null){
                if(categoryType != 'Content'){
                  for(Intranet_Content_Tags__c contTag: localContent.Intranet_Content_Tags__r){
                        //c001
                       if(contTag.Tags__r.Tag__c == pageName){
                            mapofContentIdAndContent.put(localContent.Id,localContent);
                        }
                  }
                }else{
                    mapofContentIdAndContent.put(localContent.Id,localContent);
                }
             }
         }
         System.debug('**********query********'+query);
         system.debug('**mapofContentIdAndContent***'+mapofContentIdAndContent);
         
         for(Intranet_Content_Version__c localContentVersion : [Select isPublished__c, Video_Caption__c, Summary__c, Primary_Record__c, Name, Language__c, Intranet_Content__c, Id, Header__c, Description__c, Button_Label__c,
                                                                Video_Type__c, Video_ID__c,Header_Color__c, Summary_Color__c, Button_Location__c, Position__c
                                                                FROM Intranet_Content_Version__c 
                                                                WHERE Intranet_Content__c IN: mapofcontentIdAndContent.keySet()                                                         
                                                                order by Intranet_Content__c ]){
                                                                    
                                                                if(localContentVersion  <> null){
                                                                    mapofVersionIdIdAndVersion.put(localContentVersion.Id,localContentVersion);
                                                                    if(mapofContentIdAndSetofVesrsionsIds.containsKey(localContentVersion.Intranet_Content__c)){
                                                                        setofContentVersions = new  Set<String>();
                                                                        setofContentVersions.addall(mapofContentIdAndSetofVesrsionsIds.get(localContentVersion.Intranet_Content__c));
                                                                        setofContentVersions.add(localContentVersion.Id);   
                                                                        mapofContentIdAndSetofVesrsionsIds.put(localContentVersion.Intranet_Content__c,setofContentVersions);                                                                           
                                                                    }else{
                                                                        Set<String> setofNewVersionIds = new Set<String>();
                                                                        setofNewVersionIds.add(localContentVersion.Id);
                                                                        mapofContentIdAndSetofVesrsionsIds.put(localContentVersion.Intranet_Content__c,setofNewVersionIds);
                                                                    }
                                                                }                       
         }
         
          system.debug('**mapofContentIdAndSetofVesrsionsIds***'+mapofContentIdAndSetofVesrsionsIds);
          
         if(mapofContentIdAndSetofVesrsionsIds.keySet() <> null){
             for(String contentId : mapofContentIdAndContent.keySet()){    
                Intranet_Content_Version__c contentVersiontoLoad = new Intranet_Content_Version__c();
                 boolean isContentFound = false;
                 String primaryVersionid = '';
                    if(mapofContentIdAndSetofVesrsionsIds.containsKey(contentId)){                                          
                        for(String  versionId : mapofContentIdAndSetofVesrsionsIds.get(contentId)){                         
                            if(mapofVersionIdIdAndVersion.get(versionId).Primary_Record__c  == true){
                                    primaryVersionid = versionId;
                            }     
                            //if local language available                       
                            if(userLocalLanguage <> null && setofLanguages.size()>0 &&  mapofVersionIdIdAndVersion.get(versionId).Language__c <> null && setofLanguages.contains(mapofVersionIdIdAndVersion.get(versionId).Language__c.trim().toUpperCase()) && mapofVersionIdIdAndVersion.get(versionId).isPublished__c==true ){
                                contentVersiontoLoad = mapofVersionIdIdAndVersion.get(versionId);
                                isContentFound = true;                                                  
                            }
                        }
                        
                    }
                 
                    //go for primary version
                     if(isContentFound == false && primaryVersionid <> ''){                       
                            contentVersiontoLoad = mapofVersionIdIdAndVersion.get(primaryVersionid);
                     }
                 listofContentandVersionWrapper.add(new ContentVersionWrapper(mapofContentIdAndContent.get(contentId),contentVersiontoLoad));
             }
            
             
         }
          system.debug('**listofContentandVersionWrapper***'+listofContentandVersionWrapper);
        return listofContentandVersionWrapper;

  }
  
    public  List<ContentVersionWrapper> processContentAndVersionMenu(String query){
        
        List<ContentVersionWrapper>                 listofContentandVersionWrapper      = new List<ContentVersionWrapper>();
        Map<String,Intranet_Content__c>             mapofContentIdAndContent            = new Map<String,Intranet_Content__c>();
        Map<String,Set<String>>                     mapofContentIdAndSetofVesrsionsIds  = new Map<String,Set<String>>();
        Map<String,Intranet_Content_Version__c>     mapofVersionIdIdAndVersion          = new Map<String,Intranet_Content_Version__c>();
        Set<String>                                 setofContentVersions;
        String                                      userLocalLanguage;
        Set<String>                                 setofLanguages                      = new Set<String>(); 
        
        userLocalLanguage = '';         
        //user local language from setting
        
        for(Intranet_content__c intranetConfig : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal' AND name =: userinfo.getLanguage()]){
            if(intranetConfig <> null && intranetConfig.value__c <> null){
                userLocalLanguage = intranetConfig.value__c;
                for(String language : userLocalLanguage.split(';')){    
                    language = language.toUpperCase();      
                    setofLanguages.add(language);
                }
            }
        }
        
        for(Intranet_Content__c localContent :  Database.query(query)){ 
                                                    
             if(localContent <> null){ 
                    mapofContentIdAndContent.put(localContent.Id,localContent);
             }
         }
         System.debug('**********query********'+query);
         system.debug('**mapofContentIdAndContent***'+mapofContentIdAndContent);
         
         for(Intranet_Content_Version__c localContentVersion : [Select isPublished__c, Video_Caption__c, Summary__c, Primary_Record__c, Name, Language__c, Intranet_Content__c, Id, Header__c, Description__c, Button_Label__c,
                                                                Video_Type__c, Video_ID__c,Header_Color__c, Summary_Color__c, Button_Location__c, Position__c
                                                                FROM Intranet_Content_Version__c 
                                                                WHERE Intranet_Content__c IN: mapofcontentIdAndContent.keySet()                                                         
                                                                order by Intranet_Content__c ]){
                                                                    
                                                                if(localContentVersion  <> null){
                                                                    mapofVersionIdIdAndVersion.put(localContentVersion.Id,localContentVersion);
                                                                    if(mapofContentIdAndSetofVesrsionsIds.containsKey(localContentVersion.Intranet_Content__c)){
                                                                        setofContentVersions = new  Set<String>();
                                                                        setofContentVersions.addall(mapofContentIdAndSetofVesrsionsIds.get(localContentVersion.Intranet_Content__c));
                                                                        setofContentVersions.add(localContentVersion.Id);   
                                                                        mapofContentIdAndSetofVesrsionsIds.put(localContentVersion.Intranet_Content__c,setofContentVersions);                                                                           
                                                                    }else{
                                                                        Set<String> setofNewVersionIds = new Set<String>();
                                                                        setofNewVersionIds.add(localContentVersion.Id);
                                                                        mapofContentIdAndSetofVesrsionsIds.put(localContentVersion.Intranet_Content__c,setofNewVersionIds);
                                                                    }
                                                                }                       
         }
         
          system.debug('**mapofContentIdAndSetofVesrsionsIds***'+mapofContentIdAndSetofVesrsionsIds);
          
         if(mapofContentIdAndSetofVesrsionsIds.keySet() <> null){
             for(String contentId : mapofContentIdAndContent.keySet()){    
                Intranet_Content_Version__c contentVersiontoLoad = new Intranet_Content_Version__c();
                 boolean isContentFound = false;
                 String primaryVersionid = '';
                    if(mapofContentIdAndSetofVesrsionsIds.containsKey(contentId)){                                          
                        for(String  versionId : mapofContentIdAndSetofVesrsionsIds.get(contentId)){                         
                            if(mapofVersionIdIdAndVersion.get(versionId).Primary_Record__c  == true){
                                    primaryVersionid = versionId;
                            }     
                            //if local language available                       
                            if(userLocalLanguage <> null && setofLanguages.size()>0 &&  mapofVersionIdIdAndVersion.get(versionId).Language__c <> null && setofLanguages.contains(mapofVersionIdIdAndVersion.get(versionId).Language__c.trim().toUpperCase()) && mapofVersionIdIdAndVersion.get(versionId).isPublished__c==true ){
                                contentVersiontoLoad = mapofVersionIdIdAndVersion.get(versionId);
                                isContentFound = true;                                                  
                            }
                        }
                        
                    }
                 
                    //go for primary version
                     if(isContentFound == false && primaryVersionid <> ''){                       
                            contentVersiontoLoad = mapofVersionIdIdAndVersion.get(primaryVersionid);
                     }
                 listofContentandVersionWrapper.add(new ContentVersionWrapper(mapofContentIdAndContent.get(contentId),contentVersiontoLoad));
             }
            
             
         }
          system.debug('**listofContentandVersionWrapper***'+listofContentandVersionWrapper);
        return listofContentandVersionWrapper;

  }
  
}