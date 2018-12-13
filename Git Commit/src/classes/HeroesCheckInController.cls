public class HeroesCheckInController{
    private String relId = '';
    private String consId = '';
    private String campId = '';

    public Lead led { get; set; }
    public Boolean isConsIdSet { get; private set; }
    public ECCUtil.SSLeads currLead { get; private set; }
    public List<IncentiveInfos__x> iis { get; set; }
    public TREventRegistrationDetails__x eventDetails { get; set; }
    public SingletOrders__x so { get; set; }
    public MarathonRecommits__x mr { get; set; }
    public Boolean needsRecommit { get; private set; }

    public HeroesCheckInController(){
        init();
    }

    public Boolean getShowIncentiveLink() {
        String participationLevel = eventDetails.Participation_Type_Fundrasing_Level__c;
        Double amountRaised = eventDetails.Current_Event_Revenue__c;
        system.debug('participationLevel: ' + participationLevel + ', amountRaised: ' + amountRaised);
        return participationLevel.toLowerCase().contains('gold') ||
               participationLevel.toLowerCase().contains('silver') ||
               participationLevel.toLowerCase().contains('bronze') ||
               amountRaised >= 500;
    }

    public String getIncentiveURL () {
        CustomSettings__c cs = [select id, name, Value__c from CustomSettings__c where name = 'DGGIncentiveURL'];
        String incentiveLevel;
        String participationLevel = eventDetails.Participation_Type_Fundrasing_Level__c;
        Double amountRaised = eventDetails.Current_Event_Revenue__c;
        if (participationLevel.toLowerCase().contains('gold')) incentiveLevel = 'Gold';
        else if (participationLevel.toLowerCase().contains('silver')) incentiveLevel = 'Silver';
        else if (participationLevel.toLowerCase().contains('bronze')) incentiveLevel = 'Bronze';
        else if (amountRaised >= 1000) incentiveLevel = 'Dinner/VIP';
        else if (amountRaised >= 500) incentiveLevel = 'Dinner';

        return cs.Value__c + '?campaignId=' + campId + '&p2pId=' + consId + '&incentiveLevel=' + incentiveLevel;
    }

    private void init() {        
        relId = System.currentPageReference().getParameters().get('relId');
        system.debug(relId);

        currLead = ECCUtil.getCurrLead(relId);

        consId = currLead.SSLead.TR_ID__c;
        led = currLead.SSLead;

        iis = new List<IncentiveInfos__x>();

        system.debug('consId: ' + consId);
        if (String.isBlank(consId)) {
            isConsIdSet = true;
        }
        else {
            isConsIdSet = true;
            GetPage();
        }
    }
    
    private void GetPage(){
    	campId = currLead.SSLead.CurrentCampaign__r.EvaluatedDGGCampaignId__c;
    	String eventId = currLead.SSLead.CurrentCampaign__r.Evaluated_EventID__c;
    	system.debug('campId: ' + campId);
    	system.debug('consId: ' + consId);
    	system.debug('eventId: ' + eventId);
        eventDetails = OdataExtension.GetTREventRegDetailByConsEvent(Decimal.valueOf(consId), Decimal.valueOf(eventId));
        so = OdataExtension.GetSingletOrdersByEvent(Decimal.valueOf(eventId), Decimal.valueOf(consId));
        mr = OdataExtension.GetMarathonRecommits(Decimal.valueOf(eventId), consId);
        if (so == null) {
        	so = new SingletOrders__x();
        	so.SingletOrdered__c = 'N';
        }
        if (eventDetails == null) System.debug('GetTREventRegDetailByConsEvent returned null');
        if (eventDetails.MinimumGoal__c == null) eventDetails.MinimumGoal__c = 0;
        if (eventDetails.Current_Event_Revenue__c == null)eventDetails.Current_Event_Revenue__c = 0;
        needsRecommit = false;
        if (eventDetails.MinimumGoal__c > eventDetails.Current_Event_Revenue__c && mr == null) needsRecommit = true;
    	iis = OdataExtension.GetIncentiveInfosByCampCons(campId, consId);
    }  

    public void CheckIn() {
    	update led;
    }

    public void ccDonate() {
    	//update led;
    }
}