/*
*@purpose : Controller for IntranetChatterFileSearch
*/
public  class EdgeForceIntranetChtFileSearchController {
  public String searchString{get;set;}
    public List<contentVersion> listoffiles{get;set;}
    public  String searchInputinController{get;set;}
    public  set<String> setoffileId{get;set;}
    public  Integer resultLimit;
    
    public EdgeForceIntranetChtFileSearchController () {
       listoffiles = new  List<contentVersion>();
        //SearchResultSetting__c searchSetting = SearchResultSetting__c.getInstance('EbaySearchfileSetting');
        //resultLimit = Integer.valueof(searchSetting.PeopleSearchResultLimit__c);
        resultLimit  = 7;
    }
    
    public void clear(){
         listoffiles = new  List<contentVersion>();
         setoffileId = new  Set<String>();
    }
    
    public void processfileSearch(){
         listoffiles = new  List<contentVersion>();
         setoffileId = new  Set<String>();
        if(apexpages.currentPage().getParameters().get('searchInput') <> null && apexpages.currentPage().getParameters().get('searchInput') <> ''){
            searchString = apexpages.currentPage().getParameters().get('searchInput');
             system.debug('searchString'+searchString);
              if(searchString.length()>=2){
                String fileSearchInput = searchString+'%';
                String query = 'SELECT title,createdDate,createdBy.firstName,createdBy.lastName,fileType,id  FROM contentVersion Where title LIKE : fileSearchInput limit '+resultLimit ;
                for(contentVersion chatterfiles :database.query(query)){
                    
                                            if(chatterfiles <> null){
                                                listoffiles.add(chatterfiles);
                                                setoffileId.add(chatterfiles.id);
                                           }
                                  
                }        
              }else{
                clear();
              }
         }
         system.debug('listoffiles'+listoffiles);
    }   
    
    public void processfilesSearchMore(){
        
            if(searchString <> null && searchString <> ''){
             system.debug('searchString'+searchString);
              if(searchString.length()>=2){
                String fileSearchInput = searchString+'%';
                String query = 'SELECT title,createdDate,createdBy.firstName,createdBy.lastName,fileType,id  FROM ContentVersion Where (title LIKE : fileSearchInput ) And Id NOT IN :setoffileId limit '+resultLimit ;
                for(ContentVersion chatterfiles :database.query(query)){
                    
                                            if(chatterfiles <> null){
                                                listoffiles.add(chatterfiles);
                                                setoffileId.add(chatterfiles.id);
                                           }
                                  
                 }        
               }else{
                 clear();
               }
             }
    }
}