public class EventHistorySummaryController{
    public String relId {get; private set;}
    public String constituentId {get; set;}
    public List<EventViewModel> events {get; private set;}
    public Integer currPage {get; Set;}
    public Integer totalPages {get; Set;}
    public Integer pageSize = 10;
    public Integer totalRecordCount {get; private set;}
    public Integer startIndex {get;set;}
    public Integer endIndex {get;set;}
    public Boolean sortingAscended {get; set;}
    public String sortedByColumnName {get;set;}
    public List<EventHistorySummaries__x> allRecords {get; private set;}
    private String CacheKey {get; private set;}
    public String eventIdToLoad { get; set;}
    public decimal totalOnlineRevenue {get; private set;}
    public decimal totalOfflineRevenue {get; private set;}
    public decimal totalAmount {get; private set;}
    public integer completedEvents {get; private set;}

    public EventHistorySummaryController(){
        relId = System.currentPageReference().getParameters().get('id');

       // String pageNum = System.currentPageReference().getParameters().get('page');

        //set currentpage == page if it arrives in the query string
        currPage = currPage != null ? currPage : 1;

        system.debug('currPage=' + currPage);
        events = new List<EventViewModel>();
        system.debug(relId);
        sortingAscended = true;

        constituentId = ECCUtil.GetConstituentId(relId, System.currentPageReference().getParameters().get('leadRelType'));
        system.debug('constituentId=' + constituentId);
        sortedByColumnName = 'StartDate__c';


        if (constituentId != null) 
        {
            system.debug('clearCache.constituentId=' + constituentId);
            if (!String.isEmpty(constituentId)){
                CacheKey = getCacheKey(constituentId);
                system.debug('CacheKey=' + CacheKey);
                if (Cache.Session.contains(CacheKey))
                {
                    system.debug('clearing cache');
                    Cache.Session.remove(CacheKey);
                }
                else{
                    system.debug('using cache');
                }
            }
            renderPage();
        }
    }
    
    private void renderPage(){
        CacheKey = getCacheKey(constituentId);

        //don't reload ecv unless you need to
        if (Cache.Session.contains(CacheKey) && !Test.isRunningTest()){
             allRecords = (List<EventHistorySummaries__x>)Cache.Session.get(CacheKey);
             system.debug('cache used');
        }
        else{
            system.debug('cache not used');
            allRecords = OdataExtension.GetEventHistorySummaryByQuery(GetQuery(constituentId,sortedByColumnName));
            Cache.Session.put(CacheKey, allRecords);
        }
        //allRecords = OdataExtension.GetEventHistorySummaryByQuery(GetQuery(constituentId,sortedByColumnName));

        totalRecordCount = allRecords == null ? 0 : allRecords.size();
        System.debug('totalRecordCount = ' + totalRecordCount);
        totalPages = allRecords == null ? 1 : integer.valueOf(string.valueOf(Math.ceil(allRecords.size() / Double.ValueOf(pageSize))));
        Map<String, EventHistorySummaries__x> ecvShow = new Map<String, EventHistorySummaries__x>();

        //get the event codes so we can collect revenue from DMS
        Set<String> eventIds = new Set<String>();    
        startIndex = currPage == 1 ? 0 : ((currPage - 1) * pageSize);
        endIndex = startIndex + pageSize;

        System.debug('currPage = ' + currPage);

        if (endIndex > totalRecordCount)
            endIndex = totalRecordCount;

        System.debug('startIndex = ' + startIndex);
        System.debug('endIndex = ' + endIndex);
        if(allRecords.size() > 0){
            for(Integer i=startIndex; i<endIndex; i++){
                EventHistorySummaries__x er = allRecords[i];
                system.debug('er.EventId__c' + er.EventId__c + ' index=' + i);

                if (!eventIds.contains(er.EventId__c)) {
                    eventIds.add(er.EventId__c);
                    ecvShow.put(er.EventId__c, er);
                }
            }
        }

        System.debug('ecvShow.size() = ' + ecvShow.size());
        Map<String, EventRevenues__x> recruitEventMap = fetchEventRevenuesByEventIds(eventIds);
        //Map<String, TeamRaiserRevenueBreakdown__x> recruitEventMap = fetchEventRevenuesByEventIds(eventIds); 

        events = new List<EventViewModel>(); //reset the list
        for(EventHistorySummaries__x er : ecvShow.values()) {
            System.debug('ecvShow.values = ' + ecvShow.values());
            events.add(new EventViewModel(recruitEventMap.get(er.EventId__c), er));
        }
        
        //Calculates total revenues
        if(currPage == totalPages) {
            totalOfflineRevenue = 0.00;
            totalOnlineRevenue = 0.00;
            totalAmount = 0.00;
            completedEvents = 0; 

            system.debug('allRecords.size() = ' + allRecords.size());
           calculateTotalRevenues(allRecords);
        }
    }

    private String getCacheKey(String consId)
    {
        return 'ehsAllRecords' + consId.replace('-', '');
    }
    
    public List<Integer> getPageList()
    {
        List<Integer> pageList = new List<Integer>();

        for(Integer i=1;i<=totalPages;i++)
        {
            pageList.add(i);
        }

        return pageList;
    }

    public PageReference nextPage() {
        if (currPage < totalPages) {
            currPage++;

            if (!Test.isRunningTest())
                renderPage();
        }
        return null;        
    }
    
    public PageReference prevPage() {
        if (currPage > 1) {
            currPage--;

            if (!Test.isRunningTest())
                renderPage();
        }
        return null;
    }

    public PageReference loadPage()
    {
        system.debug('currPage=' + currPage);
        //currPage = 1;
        renderPage();
        return null;
    }

    //public PageReference clearCache()
    //{
    //    system.debug('clearCache.constituentId=' + constituentId);
    //    if (!String.isEmpty(constituentId)){
    //        CacheKey = getCacheKey(constituentId);
    //        system.debug('CacheKey=' + CacheKey);
    //        if (Cache.Session.contains(CacheKey))
    //        {
    //            system.debug('clearing cache');
    //            Cache.Session.remove(CacheKey);
    //        }
    //        else{
    //            system.debug('using cache');
    //        }
    //    }

    //    return null;
    //}

    //public static Map<String, TeamRaiserRevenueBreakdown__x> fetchEventRevenuesByEventIds(Set<String> eventIds){
    //    Map<String, TeamRaiserRevenueBreakdown__x> eventMap = new Map<String, TeamRaiserRevenueBreakdown__x>();
    //    List<TeamRaiserRevenueBreakdown__x> lstRecruitedEvents = new List<TeamRaiserRevenueBreakdown__x>();
    //    system.debug('eventIds=' + eventIds);
    //    system.debug('eventIds.size()=' + eventIds.size());
    //    if (eventIds.size() > 0) {
    //        lstRecruitedEvents = OdataExtension.GetTeamRaiserEventRevenueBreakdownByEventIds(eventIds);
    //        system.debug('lstRecruitedEvents.size()=' + lstRecruitedEvents.size());
    //        for(TeamRaiserRevenueBreakdown__x recEvent :lstRecruitedEvents){
    //            eventMap.put(recEvent.EventId__c, recEvent);
    //        }
    //    }

    //    return eventMap;
    //}

    // Fetch RecruitedEvents__x records according to Event Code that match SOURCECODE__c in RecruitedEvents__x 
    // For revenue
    public static Map<String, EventRevenues__x> fetchEventRevenuesByEventIds(Set<String> eventIds){
        Map<String, EventRevenues__x> eventMap = new Map<String, EventRevenues__x>();
        List<EventRevenues__x> lstRecruitedEvents = new List<EventRevenues__x>();
        system.debug('eventIds=' + eventIds);
        system.debug('eventIds.size()=' + eventIds.size());
        if (eventIds.size() > 0) {
            lstRecruitedEvents = OdataExtension.GetEventRevenuesByEventIds(eventIds);
            system.debug('lstRecruitedEvents.size()=' + lstRecruitedEvents.size());
            for(EventRevenues__x recEvent :lstRecruitedEvents){
                eventMap.put(recEvent.EventId__c, recEvent);
            }
        }

        return eventMap;
    }

    private void calculateTotalRevenues(List<EventHistorySummaries__x> allRecords){
        Set<String> allEventIds = new Set<String>(); 

        if(allRecords.size() > 0){
            //store all eventIDs for this lead
            for(Integer i=0; i<allRecords.size(); i++){
                system.debug('allRecords['+i+'] = ' + allRecords[i].EventId__c);
                allEventIds.add(allRecords[i].EventId__c);
            }

            //get revenues for all events
            Map<String, EventRevenues__x> revenues = fetchEventRevenuesByEventIds(allEventIds);

            for(EventHistorySummaries__x es: allRecords){

                EventViewModel evm = new EventViewModel(revenues.get(es.EventId__c), es);
                    
                system.debug('evm = ' + evm);

                //calculating total revenues
                if(evm != null) {
                    totalOnlineRevenue += evm.EventRevenue.OnlineAmount__c;
                    totalOfflineRevenue += evm.EventRevenue.OfflineAmount__c;
                    totalAmount += evm.EventRevenue.Amount__c;
                    completedEvents += evm.Summary.Status__c == 'Completed' ? 1 : 0;
                }
            }

            System.debug('totalOfflineRevenue = ' + totalOfflineRevenue);
            System.debug('totalOnlineRevenue = ' + totalOnlineRevenue);
            System.debug('totalAmount = ' + totalAmount);
            System.debug('completedEvents = ' + completedEvents);
        }
    }

    public string getEventsMasteringURL() {
        return CustomSettings__c.getValues('EventsRecruitment').Value__c;
    }
    
    public string getNonce() {
        return ECCUtil.getToken('this is the events nonce key and the events nonce key is this');
    }

    public string GetQuery(String consId, String sortedBy)
    {
        String qry = 'select EventID__c, EventName__c, EventDescription__c, StartDate__c, EndDate__c, EventCode__c, EventTypeName__c, EventMasterName__c, Status__c, EventTypeID__c, SystemOfOrigin__c, IsEccRecruited__c, Roles__c from EventHistorySummaries__x where ConstituentID__c ='+'\''+consId+'\'';

        if (String.isEmpty(sortedBy))
            qry += ' order by StartDate__c';
        else
        {
            qry += ' order by ' + sortedBy;
        }

        qry += sortingAscended ? ' ASC' : ' DESC';
        system.debug('qry=' + qry);
       return qry;
    }

    //public Class EventViewModel{
    //    public TeamRaiserRevenueBreakdown__x EventRevenue {get; set;}
    //    public EventHistorySummaries__x  Summary {get; set;}
    //    public Boolean isEccRecruited {get; set;}
    //    public String LeadId {get; set;}

    //    public EventViewModel(TeamRaiserRevenueBreakdown__x er, EventHistorySummaries__x inSummary) {
    //        //initialize
            
    //        isEccRecruited = false;
    //        EventRevenue = er != null ? er : new TeamRaiserRevenueBreakdown__x();
    //        Summary = inSummary != null ? inSummary : new EventHistorySummaries__x();
    //        System.debug('Summary = ' + Summary);
    //        //set system of origin
    //        if(Summary.SystemOfOrigin__c != null){
    //            if(Summary.SystemOfOrigin__c.contains('EventsSJInt'))
    //                Summary.SystemOfOrigin__c = 'ECC Recruited';
    //            else if(Summary.SystemOfOrigin__c.contains('EventsSJExt'))
    //                Summary.SystemOfOrigin__c = 'External Recruited';
    //        }
    //        else Summary.SystemOfOrigin__c = 'N/A';

    //        isEccRecruited = Summary.IsEccRecruited__c;

    //        if (Summary.EventID__c != null)
    //            LeadId = ECCEventHelper.GetLeadIdByEventId(Summary.EventID__c);
    //        else {
    //            LeadId = null;
    //        }

    //        EventRevenue.TotalAmount__c = EventRevenue.TotalAmount__c == null ? 0.00 : EventRevenue.TotalAmount__c;
    //        EventRevenue.OfflineAmount__c = EventRevenue.OfflineAmount__c == null ? 0.00 : EventRevenue.OfflineAmount__c;
    //        EventRevenue.OnlineAmount__c = EventRevenue.OnlineAmount__c == null ? 0.00 : EventRevenue.OnlineAmount__c;
    //    }
    //}

    public Class EventViewModel{
        public EventRevenues__x EventRevenue {get; set;}
        public EventHistorySummaries__x  Summary {get; set;}
        public Boolean isEccRecruited {get; set;}
        public String LeadId {get; set;}

        public EventViewModel(EventRevenues__x er, EventHistorySummaries__x inSummary) {
            //initialize
            
            isEccRecruited = false;
            EventRevenue = er != null ? er : new EventRevenues__x();
            Summary = inSummary != null ? inSummary : new EventHistorySummaries__x();
            System.debug('Summary = ' + Summary);
            //set system of origin
            if(Summary.SystemOfOrigin__c != null){
                if(Summary.SystemOfOrigin__c.contains('EventsSJInt'))
                    Summary.SystemOfOrigin__c = 'ECC Recruited';
                else if(Summary.SystemOfOrigin__c.contains('EventsSJExt'))
                    Summary.SystemOfOrigin__c = 'External Recruited';
            }
            else Summary.SystemOfOrigin__c = 'N/A';

            isEccRecruited = Summary.IsEccRecruited__c;

            if (Summary.EventID__c != null)
                LeadId = ECCEventHelper.GetLeadIdByEventId(Summary.EventID__c);
            else {
                LeadId = null;
            }

            EventRevenue.Amount__c = EventRevenue.Amount__c == null ? 0.00 : EventRevenue.Amount__c;
            EventRevenue.OfflineAmount__c = EventRevenue.OfflineAmount__c == null ? 0.00 : EventRevenue.OfflineAmount__c;
            EventRevenue.OnlineAmount__c = EventRevenue.OnlineAmount__c == null ? 0.00 : EventRevenue.OnlineAmount__c;
        }
    }
}



    //public List<EventHistorySummaries__x> SortEventsByColumnName(List<EventHistorySummaries__x> summaries, String colName)
    //{
    //    Map<String, EventHistorySummaries__x> summaryMap = new Map<String, EventHistorySummaries__x>();
    //    List<String> sortThis = new List<String>();

    //    for(EventHistorySummaries__x s : summaries)
    //    {
    //        if (colName == 'EventName__c')
    //        {
    //           summaryMap.put(s.EventName__c, s); 
    //           sortThis.add(s.EventName__c);
    //        }
    //        else if (colName == 'EventCode__c')
    //        {
    //           summaryMap.put(s.EventCode__c, s);
    //           sortThis.add(s.EventCode__c);
    //        }
    //        else{
    //           summaryMap.put(String.valueOf(s.StartDate__c), s);
    //           sortThis.add(String.valueOf(s.StartDate__c));

    //        }
    //    }
    //    system.debug('sortThis.size()=' + sortThis.size());
    //    sortThis.sort(); 

    //    system.debug('sortThis=' + sortThis);
    //    List<EventHistorySummaries__x> sortedList = new List<EventHistorySummaries__x>();

    //    for(String s : sortThis)
    //    {
    //       sortedList.add(summaryMap.get(s));
    //    }
    //    system.debug('sortedList.size=' + sortedList.size());
    //    return sortedList;
    //}


    //public void doSort()
    //{
    //    string colName = Apexpages.currentPage().getParameters().get('colName');
    //    if (colName != null && colName != ''){
    //        system.debug('sortedByColumnName=' + sortedByColumnName);
    //        system.debug('colName=' + colName);
    //        sortedByColumnName = colName;

    //        getPage();
    //    }
    //    //return null;
    //}