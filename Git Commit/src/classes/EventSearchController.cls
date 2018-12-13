public with sharing class EventSearchController {
    public String eventName {get; set;}
    public list<selectOption> eventType {get; set;}
    public String eventCode {get; set;}
    public String startDate {get; set;}
    public String EndDate {get; set;}
    public String selectedEventType {get; set;}
    public boolean resultsFound {get; set;}
    public integer totalPages{get; set;}
    public string sortOrder{get; set;}
    public boolean pageLoad {get; set;}
    
    public map<string, string> eventTypeNamesById {get; set;}
    
    public list<Events__x> searchResults{
        get{
        system.debug(' in list preparation');
        list<Events__x> tmp = new list<Events__x>();
        
        if(stdcon != null){
            resultsFound = true;
            for (Events__x ev : (List<Events__x>)stdcon.getRecords()){
                tmp.add(ev);
            }
        }else{
            resultsFound = false;
        }
        
        
        return tmp;
        }set;
    }

    private list<EventTypes__x> eventList;
    private list<Events__x> queriedEvents;
    private EnvironmentSettings__c es;
    public EventSearchController(){
        intiateSearch = false;
        eventType = new list<selectOption>();
        eventList = new list<EventTypes__x>();
        pageLoad = true;
        queriedEvents = new list<Events__x>();
        totalPages = 0;
        eventTypeNamesById = new map<string, string>();
        eventList = OdataExtension.GetAllEventTypes();
        
        es = EnvironmentSettings__c.getInstance();
        for(EventTypes__x ev : eventList){
            if(es.EVMActiveStatusID__c != null && es.EVMActiveStatusID__c != ev.StatusID__c){
                 eventType.add(new selectoption(ev.EventTypeID__c, ev.EventTypeName__c));
            }
           
            eventTypeNamesById.put(ev.EventTypeID__c, ev.EventTypeName__c);
        }
    }
    
    private boolean intiateSearch;
     public ApexPages.StandardSetController stdcon {
        get {
            if(intiateSearch == true) {
                stdcon = null;
                intiateSearch = false;
                string qry = queryString();
                List<Events__x> queriedEvents = new List<Events__x>();
                if(validate()){
                    queriedEvents = OdataExtension.eventsByQuery(qry,sd,ed);
                }
                
                
                if(queriedEvents.size() > 0){
                    totalPages = Math.mod(queriedEvents.size(),10) > 0? queriedEvents.size()/10  + 1: queriedEvents.size()/10 ;
                }else{
                    totalPages = 0;
                }
                
                stdcon = new ApexPages.StandardSetController(queriedEvents);
                stdcon.setPageSize(10);
            }
            return stdcon;
        }
        set;
    } 
    
    public boolean validate(){
    
        if((eventName != null && eventName != '')|| (selectedEventType != null && selectedEventType != '') || (eventCode != null && eventCode != '')){
            return true;
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error,'Please enter Event Name/Event Type/Event Code '));
            return false;
        }
        
    }
    
    public void search(){
        system.debug('validate '+validate());
        pageLoad = false;
        intiateSearch = true; 
        system.debug('  searchResults'+searchResults);
    }
    
    public void prevPage(){
        stdCon.previous();
    }
    
    public void nextPage(){
        stdCon.next();
    }
    
    public void changeSort(){
        search();
    }
    
    public Integer currPage {
        get {
            if(searchResults.size() > 0){
                return stdCon.getPageNumber();
            }else{
                return 0;
            } 
            
            
        }
        set;
    }
    
    public Boolean hasNext {
        get {
            if(stdCon != null){
                return stdCon.getHasNext();
            }else{
                return false;
            } 
        }
        set;
    }

    public Boolean hasPrevious {
        get {
            if(stdCon != null){
                return stdCon.getHasPrevious();
            }else{
                return false;
            } 
        }
        set;
    }
    
    dateTime sd;
    dateTime ed;
    public string queryString(){
        string qry;
        qry = 'select EventID__c, EventCode__c, EventName__c,StatusID__r.Status1__c, StartDate__c, EndDate__c, EventTypeID__c from Events__x where StatusID__c!='+'\''+es.EVMActiveStatusID__c+'\'';
        
        
        if(eventName != null && eventName != ''){
            string eventNameTmp = '\'%'+eventName+'%\'';
            qry = qry +' and EventName__c like '+ eventNameTmp + ' and EventName__c != null';
        }
        
        if(StartDate != null && StartDate != ''){
            list<String> str = StartDate.split('/');
            if(str != null && str.size() > 0){
                sd =  Datetime.newInstance(Integer.valueOf(str[2]),Integer.valueOf(str[0]),Integer.valueOf(str[1]));
                qry = qry +' and StartDate__c>=:sd';
            }
            
        }
        
        if(selectedEventType != null && selectedEventType != ''){
            qry = qry +' and EventTypeID__c=\''+selectedEventType+'\'';
        }
        
        if(endDate != null && endDate != ''){
            list<String> str = endDate.split('/');
            if(str != null && str.size() > 0){
                ed =  Datetime.newInstance(Integer.valueOf(str[2]),Integer.valueOf(str[0]),Integer.valueOf(str[1]));
                qry = qry +' and EndDate__c<=:ed';
            }
        }
        
        if(eventCode != null && eventCode != ''){
            string eventCodeTmp = '\'%'+eventCode+'%\'';
            qry = qry + ' and EventCode__c like ' + eventCodeTmp + ' and EventCode__c != null';
        }
        
        if(sortOrder != null){
            string sortField;
            
            if(sortOrder.contains('ASC')){
                sortField = sortOrder.replace('_ASC','');
                qry = qry + ' Order BY '+sortField +' ASC';
            }else{
                sortField = sortOrder.replace('_DESC','');
                qry = qry + ' Order BY '+sortField +' DESC';
            }
        
        }
        system.debug(' qry   '+qry);
        return qry;
    }
    
}