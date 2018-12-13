global class ArticleTaggingController {

    public ArticleTaggingController(ApexPages.StandardController controller) {
        articleID = controller.getId();
    }


    public String articleID {get; set;}
    
    /* constructor */
    public ArticleTaggingController(){
        //articleID = ApexPages.currentPage().getParameters().get('id');
    }
    
    public static Map<String, Id> mapOfTagNameAndId {
        get{
            if(mapOfTagNameAndId == null){
                mapOfTagNameAndId = new Map<String, Id>();
                for(Tags__c tg : [SELECT Id, Tag__c FROM Tags__c]){
                    mapOfTagNameAndId.put(tg.Tag__c, tg.Id);
                }
            }
            return mapOfTagNameAndId;
        }
        private set;
    }
    
    /**
    @author Manish
    @purpose get the list of all the tags from in Tags__c object
    */
    @RemoteAction
    global static List<Tags__c> fetchListOfTags(){
        List<Tags__c> listOfTags =  new List<Tags__c>();
        for(Tags__c tg : [SELECT Id, Tag__c FROM Tags__c LIMIT 1000]){
            if(String.isNotBlank(tg.Tag__c)){
                listOfTags.add(tg);
             }
        }
        return listOfTags;
    }
    
    @RemoteAction
    global static Boolean addTags(String tagString, String artID){
        List<Intranet_Content_Tags__c> listOfArticleTags = new List<Intranet_Content_Tags__c>();
        
        for(Intranet_Content_Tags__c artTags :  [SELECT Id FROM Intranet_Content_Tags__c WHERE Intranet_Content__c = :artID]){
            listOfArticleTags.add(artTags);
        }
        
        Database.delete(listOfArticleTags);
        
        List<Tags__c> listOfNewTags = new List<Tags__c>();
        
        listOfArticleTags = new List<Intranet_Content_Tags__c>();
        for(String s : tagString.split(',')){
            if(String.isNotBlank(s)){
                if(mapOfTagNameAndId.containsKey(s)){
                    listOfArticleTags.add(new Intranet_Content_Tags__c(Tags__c = mapOfTagNameAndId.get(s), Intranet_Content__c = artID));
                }else{
                    Tags__c newTag = new Tags__c(Tag__c = s);
                    listOfNewTags.add(newTag);
                }
            }
        }
        
        Database.insert(listOfNewTags);
        
        for(Tags__c tg : listOfNewTags){
            listOfArticleTags.add(new Intranet_Content_Tags__c(Tags__c = tg.Id, Intranet_Content__c = artID));
        }
        
        Database.insert(listOfArticleTags);
        
        return true;
    }
    
    /**
    @author Manish
    @purpose get the list of all the tags associated with this Article from in Intranet_Content_Tags__c object
    */
    public List<Intranet_Content_Tags__c> getListOfArticleTags(){
        List<Intranet_Content_Tags__c> listOfArticelTags =  new List<Intranet_Content_Tags__c>();
        if(String.isNotBlank(articleID)){
            for(Intranet_Content_Tags__c tg : [SELECT Id, Name, Tags__r.Tag__c, Tags__r.Id 
                                               FROM Intranet_Content_Tags__c 
                                               WHERE Intranet_Content__c = :articleID]){
                listOfArticelTags.add(tg);
            }
        }
        return listOfArticelTags;
    }
    
}