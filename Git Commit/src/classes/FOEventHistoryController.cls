public class FOEventHistoryController{
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
    private Boolean isConsIdSet = false;
    public EVMutil.consInfo ci {get; private set;}
    private String leadRelType = '';

    public FOEventHistoryController(){
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        leadRelType = System.currentPageReference().getParameters().get('leadRelType'); //coordinator or organizer
        system.debug(relId);
        sortingAscended = false;
        currPage = currPage != null ? currPage : 1;
        ci = EVMUtil.getConsInfo(relId, leadRelType);
        constituentId = ci.consId;
        sortedByColumnName = 'StartDate__c';
        //ents = new List<EventModel>();

        system.debug('ci.consId: ' + ci.consId);
        if (ci.consId == null) {
            isConsIdSet = false;
        }
        else {
            isConsIdSet = true;
            GetPage();
        }
    }
    
    public void GetPage(){
        allRecords = OdataExtension.GetEventHistorySummaryByQuery(GetQuery(constituentId,sortedByColumnName));
        totalRecordCount = allRecords == null ? 0 : allRecords.size();
        System.debug('totalRecordCount = ' + totalRecordCount);
        totalPages = allRecords == null ? 1 : integer.valueOf(string.valueOf(Math.ceil(allRecords.size() / Double.ValueOf(pageSize))));
        Map<String, EventHistorySummaries__x> ecvShow = new Map<String, EventHistorySummaries__x>();

        Set<String> eventIds = new Set<String>();    
        startIndex = currPage == 1 ? 0 : ((currPage - 1) * pageSize);
        endIndex = startIndex + pageSize;

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
            events.add(new EventViewModel(recruitEventMap.get(er.EventId__c), er));
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
                GetPage();
        }
        return null;        
    }
    
    public PageReference prevPage() {
        if (currPage > 1) {
            currPage--;

            if (!Test.isRunningTest())
                GetPage();
        }
        return null;
    }

    public PageReference loadPage()
    {
        system.debug('currPage=' + currPage);
        //currPage = 1;
        GetPage();
        return null;
    }

    //Fetch RecruitedEvents__x records according to Event Code that match SOURCECODE__c in RecruitedEvents__x 
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
    
      public string getEventsMasteringURL() {
        return CustomSettings__c.getValues('EventsRecruitment').Value__c;
    }
    
    public string getNonce() {
        return ECCUtil.getToken('this is the events nonce key and the events nonce key is this');
    }

    public string GetQuery(String consId, String sortedBy)
    {
        String qry = 'select EventID__c, EventName__c, EventDescription__c, StartDate__c, EndDate__c, EventCode__c, EventTypeName__c, EventMasterName__c, Status__c, EventTypeID__c, SystemOfOrigin__c, IsEccRecruited__c from EventHistorySummaries__x where ConstituentID__c ='+'\''+consId+'\'';

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