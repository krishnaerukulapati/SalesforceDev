/* Sherlock Salesforce Gloabl Search Utility Controller
Description: Sherlock is a Salesforce search replacment utility that can perform full text searches against any searchable object, including
             searching the content of uploaded content documents and chatter posts. The interface is provided via a jQuery plugin on a visualforce page.
Author: Daniel Llewellyn/Kenji776 (@Kenji776)
Date: 12/05/2012
*/

global class EdgeforceIntranetSearchController {
    //wrapper object to standardize search results. The search program expects to receivea list of these. 
    //all the data found from the original sObject is included as well in the objectData property
    global class searchResult
    {
        string thumbnail = '';
        string title = '';
        string description = '';
        string link = '';
        integer size = 0;
        string type = '';
        id recordId;
        sObject objectData;
        String startDate = '';
    }
    
        //By this field Tab would be selected on intranetPages 
    global static String tabName {get; set;}
    //This map is used to identified top level parent of CMS pages.
    global static map<String, String> parentTabMap {get;set;}
    //By this field category limit will be decided on each object. 
    global static final Integer categoryLimit {get;set;}
    //By this field no of records will be decided to show on Search page 
    global static final Integer paginationLimit {get; set;}
    //Key prefix of Intranet_Article__c object
    private static final String IntranetArticleKeyPrefix {get; set;}
    static Map<String, String> contentNameTitleMap;
    static Map<String, String> parentTabNameMap;
    static Map<SObject, Intranet_Content__c> versionContentMap = new Map<SObject, Intranet_Content__c>();
    static {
            //Initialize final varibles to decide search configuration
            for(Intranet_content__c searchConfig : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal']) {
            if(searchConfig.Name == 'Search Limit') {
                categoryLimit = Integer.valueOf(searchConfig.value__c);
            }
            if(searchConfig.Name == 'Search Pagination') {
                paginationLimit = Integer.valueOf(searchConfig.value__c);
            }           
        }
        IntranetArticleKeyPrefix = Schema.getGlobalDescribe().get('Intranet_Content_Version__c').getDescribe().getKeyPrefix();
    }
     
    /*remote method to be accessed via javascript for performing a search.
      arguments
          searchTerm: a string at least two characters long (not including wildcards) to search for
          objectList: a list/array of sObject names which to query for
          objectLabels: a map/javascript object of sObject names to a friendly label to use in the result. Multiple sObjects can have the same label and will be returned in the same group.
          typeLimit: a maxmimum amount of each kind of object to find. This is per sObject type, not per label or for the total search.  
    */ 
    @RemoteAction
    global static map<string,list<searchResult>> globalSearch(string searchTerm,boolean isMobile,list<string>objectList,map<string,string> objectLabels, integer typeLimit)
    {
        //map to hold the results. The results will have the objectLabels or names (if no label for that object type is provided) and a list of search results for it.
        map<string,list<searchResult>> results = new  map<string,list<searchResult>>();
        map<String, boolean> isIncludedInSearchMap = new map<String,Boolean>();
        parentTabMap = new map<String,String>();
        try
        { 
            //string to hold the SOSL querystring.
            string customObjectQuery = '';
            objectLabels = new map<string,string>();
            //Custom setting that decide wheather object included in search or not.
            for(Intranet_Content__c searchConfig : [Select name,Object_Name__c,Display_In_Search__c From Intranet_Content__c Where RecordType.Name='Config - Search']) {
                isIncludedInSearchMap.put(searchConfig.Object_Name__c, searchConfig.Display_In_Search__c);
                objectLabels.put(searchConfig.Object_Name__c, searchConfig.Name);
            }
            
            String userLang = '';
            for(Intranet_content__c searchConfig : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal' AND name =: userinfo.getLanguage()]){
                if(searchConfig  != null){
                  userLang = searchConfig.Value__c;
                }
            }
            //for each object passed in, build a querystring addition that should be safe in all circumstances
            for(string obj : objectList)
            {
                if(obj == 'Intranet_Content_Version__c' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += 'Intranet_Content_Version__c' +'(Name,Id,Primary_Record__c,Language__c,Intranet_Content__c,Summary__c WHERE Language__c = \'' + userLang + '\' OR Primary_Record__c = true order by Primary_Record__c LIMIT '+typeLimit+'),';
                }/*else if(obj == 'Intranet_CMS_Page__c' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += 'Intranet_Content_Version__c'+'(Name,Id,Intranet_Content__c,Intranet_Content__r.Template__c,Intranet_Content__r.Skip_Menu_Link__c,Intranet_Content__r.URL__c,Intranet_Content__r.createdById,Intranet_Content__r.CreatedDate WHERE Intranet_Content__r.Status__c = \'Published\' AND Intranet_Content__r.RecordType.Name = \'Intranet CMS Pages\' order by Name LIMIT '+typeLimit+'),';
                }*/else if(obj == 'FeedItem' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(id, title, body, InsertedBy.Name, InsertedById, CreatedDate, ParentId order by CreatedDate DESC LIMIT '+typeLimit+'),';
                }else if(obj == 'ContentVersion' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(ContentDocumentId,ContentSize,ContentUrl,Description,IsLatest,PublishStatus,TagCsv,Title,FileType,Id order by RatingCount DESC LIMIT '+typeLimit+'),';
                }else if(obj == 'User' && isIncludedInSearchMap.get(obj) == true) {
                    customObjectQuery += obj+'(id, name, SmallPhotoUrl, email order by Name LIMIT '+typeLimit+'),';
                }else if(isIncludedInSearchMap.get(obj) == true){
                    customObjectQuery += obj+'(Name,Id,createdById,CreatedDate LIMIT '+typeLimit+'),';                
                }
            }
            //append the last of the information we need to our querystring, including stuff for finding documents, feed items and users.
            string objectsQuery = 'FIND \''+searchTerm+'\' IN ALL FIELDS RETURNING '+customObjectQuery.subString(0, customObjectQuery.length()-1);
            
            //find all objects where the name matches the search term.
            List<List<SObject>> tempSearchList = search.query(objectsQuery);
            string objType = '';
            string objLabel = '';
            
            Map<ID,SObject>  contentVersionMap;
            List<List<SObject>> searchList = new List<List<SObject>>();
            List<SObject> sobjList;
            Set<ID> contentIdSet;
            boolean isContent;
            for(List<sObject> thisObjList : tempSearchList){
                sobjList= new List<SObject>();
                contentVersionMap = new Map<ID, SObject>();
                contentIdSet = new Set<ID>();
                isContent = false;
                for(sObject thisObj : thisObjList){
                  if(string.valueOf(thisObj.getsObjectType()) == 'Intranet_Content_Version__c'){
                     isContent = true;
                     if((string)thisObj.get('Language__c') == userLang){
                         sobjList.add(thisObj);
                         contentIdSet.add((string)thisObj.get('Intranet_Content__c'));
                      }else{
                        if((boolean)thisObj.get('Primary_Record__c') == false){
                          continue;
                        }else{
                          contentVersionMap.put((string)thisObj.get('Intranet_Content__c'), thisObj);
                        }
                      }
                  }else{
                    sobjList.add(thisObj);
                  }
                }
                if(isContent){
                    for(String contentId : contentVersionMap.keyset()){
                      if(!contentIdSet.contains(contentId)){
                         sobjList.add(contentVersionMap.get(contentId));
                      }
                    }
                }
                searchList.add(sobjList);
            }
            Map<SObject, Id> versionContentIdMap = new Map<SObject, Id>();
            for(List<SObject> thisObjList : searchList){
                for(SObject sobj : thisObjList){
                    if(string.valueOf(sobj.getsObjectType()) == 'Intranet_Content_Version__c'){
                        versionContentIdMap.put(sobj, (id)sobj.get('Intranet_Content__c'));
                    }
                }
            }
            if(objectsQuery.contains('Intranet_Content_Version__c')) {
                //Populate child parent relationship map if Intranet_Article__c object included in search
                    contentNameTitleMap = new map<String, String>();
                    parentTabNameMap =  new map<String, String>();
                    for(Intranet_Content__c CMSPage : [Select Id, Parent__c,URL__c, Parent__r.Name,
                                                   Skip_Menu_Link__c, Name,Template__c, Sequence__c,Target__c,
                                                   RecordType.Name 
                                              from Intranet_Content__c
                                             where Status__c = 'Published' 
                                             AND RecordType.Name = 'Intranet CMS Pages'
                                          order by Parent__c,Sequence__c ]) {
                            parentTabNameMap.put(CMSPage.Name, CMSPage.Parent__r.Name);
                            for(SObject innerSobj : versionContentIdMap.keySet()){
                                if(versionContentIdMap.get(innerSobj) == CMSPage.Id){
                                    contentNameTitleMap.put(CMSPage.Name, (string)innerSobj.get('name')); 
                                }
                            }
                        }
                    for(String childName : parentTabNameMap.keySet()){
                        parentTabMap.put(contentNameTitleMap.get(childName), 
                                          parentTabNameMap.get(childName));
                    }  
            }
            SObject primaryVersion;
            for(Intranet_Content__c sobj : [SELECT Id,URL__c,Type__c,createdById,CreatedDate,
                                Start_Date__c,Template__c,Skip_Menu_Link__c,
                                RecordType.Name 
                                FROM Intranet_Content__c
                                WHERE ((Start_Date__c <= : DateTime.now() AND 
                                End_Date__c >= : DateTime.now()) OR
                                Status__c = 'Published')
                                AND ID IN : versionContentIdMap.values() 
                                order by Start_Date__c]){
                 for(SObject innerSobj : versionContentIdMap.keySet()){
                    if(versionContentIdMap.get(innerSobj) == sobj.Id){
                            versionContentMap.put(innerSobj, sobj);
                    }
                 }
            }
            Set<ID> searchObjectIds = new Set<ID>();
            for(List<SObject> thisObjList : searchList){
                 for(sObject thisObj : thisObjList){
                    objType = string.valueOf(thisObj.getsObjectType());
                    if(objType == 'Intranet_Content_Version__c'){
                        searchObjectIds.add(thisObj.Id);
                    }
                 }
            }
            String userLocalLanguage = '';
            //user local language from setting
            for(Intranet_content__c searchConfig1 : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal' AND name =: userinfo.getLanguage()]){
                if(searchConfig1 <> null && searchConfig1.value__c <> null){
                    userLocalLanguage = searchConfig1.value__c;
                }
            }
            //iterate over all the search results so we can build searchResult items from them.
            //the search result is broken in a list of sObjects, each of which contain a list of results. 
            //similar to how we want to evenetually return the data, but we gotta do some formatting to it first.
            for(List<sObject> thisObjList : searchList){
                for(sObject thisObj : thisObjList)
                {   
                    //create a new search result object.
                    searchResult thisResult = new searchResult();
                    
                    //find the sObject type of this object.
                    objType = string.valueOf(thisObj.getsObjectType());
                    objLabel = objType;
                    //set some default information that all returned objects should have.
                    thisResult.type = objType;
                    thisResult.recordid = (id) thisObj.get('Id');
                    thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/' + (string) thisObj.get('Id');
                    thisResult.objectData = thisObj;
                    //if a label for this object type was provided set it now. Otherwise the name of the object is also the label.
                    if(objectLabels.containsKey(objType))
                    {
                        objLabel = objectLabels.get(objType);
                    }
                    
                    //if this result is a content version object then set its properties accordingly.            
                    if(objType == 'ContentVersion')
                    {
                        thisResult.title = (string) thisObj.get('Title');
                        thisResult.description = (string) thisObj.get('Description');
                        thisResult.link = ((string) thisObj.get('FileType') == 'LINK') ? (string) thisObj.get('ContentUrl') : (isMobile == true ? '/sfc/servlet.shepherd/version/download/'+(string) thisObj.get('Id')+'?asPdf=false&amp;operationContext=CHATTER' : URL.getSalesforceBaseUrl().toExternalForm() + '/' +(string) thisObj.get('ContentDocumentId'));
                        thisResult.recordid = (id) thisObj.get('ContentDocumentId');
                        thisResult.size = (integer) thisObj.get('ContentSize');
                    }
                    
                    //if this result is a user object then set its properties accordingly, including setting the photo
                    else if(objType == 'User')
                    {
                        thisResult.thumbnail = (string) thisObj.get('SmallPhotoUrl');
                        thisResult.title = (string) thisObj.get('name');  
                        thisResult.link = (isMobile == true)? 'javascript:void(0);' : thisResult.link;                                   
                    }
                    
                    //if this result is a content version object then set its properties accordingly, including getting the posting users name to 
                    //use for the title.  
                    else if(objType == 'FeedItem')
                    {    
                        //do not considered Intranet article feed.
                        if(((String) thisObj.get('ParentId')).startsWith(IntranetArticleKeyPrefix)) {
                            continue;
                        }else {
                            sObject postingUser = thisObj.getsObject('insertedBy');                      
                            thisResult.title = (String) postingUser.get('Name');
                            thisResult.description = (((string) thisObj.get('body')) != null && ((string) thisObj.get('body')).endsWith('.')) ? (string) thisObj.get('body') : (string) thisObj.get('body') + '.';
                            thisResult.startDate =  'Posted on ' + ((DateTime) thisObj.get('CreatedDate')).format('MMMM d, yyyy hh:mm:ss a', 'PST');
                            thisResult.link = (isMobile == true)? 'javascript:void(0);' : thisResult.link;
                        }
                    }
                    
                    //if this result is a Intranet Article object then set its properties accordingly, including getting the link 
                    //where it is landing
                    else if(versionContentMap.get(thisObj) != null && objType == 'Intranet_Content_Version__c' && versionContentMap.get(thisObj).RecordType.Name == 'Intranet Article'){
                            objLabel = 'Articles';
                            thisResult.title = (string)thisObj.get('Name');
                            thisResult.description = (string)thisObj.get('Summary__c');
                            thisResult.startDate = versionContentMap.get(thisObj).Start_Date__c.format('MMMM d, yyyy hh:mm:ss a', 'PST');
                            if(versionContentMap.get(thisObj).URL__c != '' && versionContentMap.get(thisObj).URL__c != null) {
                              if(!versionContentMap.get(thisObj).URL__c.contains('http') && !versionContentMap.get(thisObj).URL__c.contains('https')){
                      versionContentMap.get(thisObj).URL__c = 'https://' + versionContentMap.get(thisObj).URL__c;
                    }
                                thisResult.link = versionContentMap.get(thisObj).URL__c;
                            } else {
                                thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/EF_Content?id=' + (string) versionContentMap.get(thisObj).Id + '&category=News&tabName=Home';
                            }
                    }
                    //if this result is a Intranet CMS Pages object then set its properties accordingly, including getting the link 
                    //where it is landing
                    
                    else if(versionContentMap.get(thisObj) != null && objType == 'Intranet_Content_Version__c' && versionContentMap.get(thisObj).RecordType.Name == 'Intranet CMS Pages')
                    {   
                        objLabel = 'Site Pages';
                        thisResult.title = (string) thisObj.get('Name');
                        if(versionContentMap.get(thisObj).Skip_Menu_Link__c != true) {
                                    if(versionContentMap.get(thisObj).URL__c != null) {
                                      if(!versionContentMap.get(thisObj).URL__c.contains('http') && !versionContentMap.get(thisObj).URL__c.contains('https')){
                          versionContentMap.get(thisObj).URL__c = 'https://' + versionContentMap.get(thisObj).URL__c;
                        }
                                        thisResult.link = versionContentMap.get(thisObj).URL__c;
                                    }else {
                                        if(versionContentMap.get(thisObj).Template__c == 'Home') {
                                            thisResult.link = '/apex/EF_Home';
                                        }else if(versionContentMap.get(thisObj).Template__c  == 'Interior Home') {
                                            thisResult.link = '/apex/EF_Home?tabName='+EncodingUtil.urlEncode((string) thisObj.get('Name'), 'UTF-8');
                                        }else if(versionContentMap.get(thisObj).Template__c  == 'Team') {
                                                    getParentpageName((string) thisObj.get('Name'));
                                            thisResult.link = '/apex/EF_Team?&name='+EncodingUtil.urlEncode((string) thisObj.get('Name'), 'UTF-8')+'&tabName='+tabName;
                                        }else if(versionContentMap.get(thisObj).Template__c  == 'Content') {
                                                getParentpageName((string) thisObj.get('Name'));
                                            thisResult.link = '/apex/EF_Content?Id=' + versionContentMap.get(thisObj).Id + '&category=Content&tabName='+tabName;
                                        }
                                        }
                                    }else {
                                        thisResult.link = 'javascript:void(0);';    
                                    }
                    }else if(versionContentMap.get(thisObj) != null && objType == 'Intranet_Content_Version__c' && versionContentMap.get(thisObj).RecordType.Name == 'Learning Center'){
                      objLabel = 'Learning Center';
                        thisResult.title = (string)thisObj.get('Name');
                        thisResult.description = (string)thisObj.get('Summary__c');
                        thisResult.startDate = versionContentMap.get(thisObj).Start_Date__c.format('MMMM d, yyyy hh:mm:ss a', 'PST');
                        if(versionContentMap.get(thisObj).URL__c != '' && versionContentMap.get(thisObj).URL__c != null) {
                          if(!versionContentMap.get(thisObj).URL__c.contains('http') && !versionContentMap.get(thisObj).URL__c.contains('https')){
                    versionContentMap.get(thisObj).URL__c = 'https://' + versionContentMap.get(thisObj).URL__c;
                  }
                            thisResult.link = versionContentMap.get(thisObj).URL__c;
                        } else {
                            thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/EF_Content?id=' + (string) versionContentMap.get(thisObj).Id + '&category=News&tabName=Home';
                        }
                    }else if(versionContentMap.get(thisObj) != null && objType == 'Intranet_Content_Version__c' && versionContentMap.get(thisObj).RecordType.Name == 'Intranet Link'){
                      objLabel = 'Links';
                        thisResult.title = (string)thisObj.get('Name');
                        thisResult.description = (string)thisObj.get('Summary__c');
                        thisResult.startDate = versionContentMap.get(thisObj).Start_Date__c.format('MMMM d, yyyy hh:mm:ss a', 'PST');
                        if(versionContentMap.get(thisObj).URL__c != '' && versionContentMap.get(thisObj).URL__c != null) {
                            if(!versionContentMap.get(thisObj).URL__c.contains('http') && !versionContentMap.get(thisObj).URL__c.contains('https')){
                    versionContentMap.get(thisObj).URL__c = 'https://' + versionContentMap.get(thisObj).URL__c;
                  }
                            thisResult.link = versionContentMap.get(thisObj).URL__c;
                        } else {
                            thisResult.link = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/EF_Content?id=' + (string) versionContentMap.get(thisObj).Id + '&category=News&tabName=Home';
                        }
                    }else{
                      continue;
                    }
                    
                    //if it is any other object type, then just grab the name and set it as the title. You could also set some kind of description here, maybe
                    //including the created date or something.
                    
                    //append this search result to the proper list using the object label as the key to find the right list.
                    if(!results.containsKey(objLabel))
                    {  
                        results.put(objLabel,new list<searchResult>());
                    }
                        results.get(objLabel).add(thisResult);
                }
            }                          
        }
        catch(Exception e)
        {
        }
        
        return results;
    }
    
    /*  
        method is used to find Top level parent of Selected CMS Page
        Argument:
            PageName : a CMS page name for which top level parent required.
    */
    private static void getParentpageName(String pageName) {
        tabName = pageName;
        if(parentTabMap.get(pageName) != null) {
            getParentpageName(parentTabMap.get(pageName));
        }
    }
    
    //function for finding all the objects in this org that can be searched for. This includes custom objects
    //returns them as a map of the object label to the object name. Meant to be invoked via the interface at runtime.
    @remoteAction
    global static map<string,string> getSearchableObjects()
    {
        //list of object labels and names to return
        map<string,string> searchableObjects = new map<string,string>();
        
        //global describe of all objects in the org.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        
        //iterate over all objects
        for(string objType : gd.keySet())
        {
            //only add this object type if it is searchable, since this list will be used to create an interface
            //where the user can select which objects to search. No sense in including non searchable objects eh?
            if(gd.get(objType).getDescribe().isSearchable())
            {
                searchableObjects.put(gd.get(objType).getDescribe().getLabel(),objType);
            }
        }
        return searchableObjects;
    }
}