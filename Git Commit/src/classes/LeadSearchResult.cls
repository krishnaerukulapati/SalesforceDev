global class LeadSearchResult{
    global List<cls_results> results;
    global boolean success;
    public LeadSearchResult(){
            results= new List<cls_results >();
    }
    global class cls_results {
        global String accountName;  //blakiej
        global String name; //John Blakie
        
    }
    global static LeadSearchResult parse(String json){
        return (LeadSearchResult) System.JSON.deserialize(json, LeadSearchResult.class);
    }

    
}