public class FOHeroesCheckInController{
    private String relId = '';
    private String consId = '';
    private String campId = '';
    private String eventId = '';
    private String giftId = '';
    private String tRConsId = '';
    private String recommitLanding = '';

    public Lead led { get; set; }
    public Lead ldRec { get; set; }
    public Boolean isConsIdSet { get; private set; }
    public EVMUtil.SSLeads currLead { get; private set; }
    public List<IncentiveInfos__x> iis { get; set; }
    public TREventRegistrationDetails__x eventDetails { get; set; }
    public SingletOrders__x so { get; set; }
    public MarathonRecommits__x mr { get; set; }
    public Boolean needsRecommit { get; private set; }
    public String recommitLink {get; private set;}

    public FOHeroesCheckInController() {
        init();
    }

    public String getEventId() {
        return eventId;
    }

    public String getConsId() {
        return consId;
    }

    public String getCampId() {
        return campId;
    }

    public String getGiftId() {
        return giftId;
    }

    public String getTRConsId() {
        return tRConsId;
    }

    public String getRecommitLanding() {
        return recommitLanding;
    }

    public Boolean getShowIncentiveLink() {
        String participationLevel = eventDetails.Participation_Type_Fundrasing_Level__c;
        if(participationLevel == null) participationLevel = '';
        Double amountRaised = eventDetails.Current_Event_Revenue__c;
        system.debug('participationLevel: ' + participationLevel + ', amountRaised: ' + amountRaised);
        return participationLevel.toLowerCase().contains('platinum') ||
               participationLevel.toLowerCase().contains('gold') ||
               participationLevel.toLowerCase().contains('silver') ||
               participationLevel.toLowerCase().contains('bronze') ||
               amountRaised >= 500;
    }

    public String getIncentiveURL () {
        CustomSettings__c cs = [select id, name, Value__c from CustomSettings__c where name = 'DGGIncentiveURL'];
        String incentiveLevel;
        String participationLevel = eventDetails.Participation_Type_Fundrasing_Level__c;
        if(participationLevel == null) participationLevel = '';
        Double amountRaised = eventDetails.Current_Event_Revenue__c;
        if (participationLevel.toLowerCase().contains('platinum')) incentiveLevel = 'Platinum';
        else if (participationLevel.toLowerCase().contains('gold')) incentiveLevel = 'Gold';
        else if (participationLevel.toLowerCase().contains('silver')) incentiveLevel = 'Silver';
        else if (participationLevel.toLowerCase().contains('bronze')) incentiveLevel = 'Bronze';
        else if (amountRaised >= 1000) incentiveLevel = 'Dinner/VIP';
        else if (amountRaised >= 500) incentiveLevel = 'Dinner';

        system.debug('campaignId: ' + campId + ', p2pId: ' + consId + ',incentiveLevel: ' + incentiveLevel);
        return cs.Value__c + '?campaignId=' + campId + '&p2pId=' + consId + '&incentiveLevel=' + incentiveLevel;
    }

    private void init() {
        CustomSettings__c cs = [select Value__c from CustomSettings__c where name = 'recommitURL'];
        recommitLink = cs.Value__c;
        relId = System.currentPageReference().getParameters().get('relId');
        system.debug(relId);

        currLead = EVMUtil.getCurrLead(relId);
        system.debug(currLead);    
        
        led = currLead.SSLead;

        iis = new List<IncentiveInfos__x>();

        if(currLead.SSLead.CurrentCampaign__r.EvaluatedDGGCampaignId__c == null) {
            campId = currLead.SSLead.CurrentCampaign__r.Id;           
        }
        else {
            campId = currLead.SSLead.CurrentCampaign__r.EvaluatedDGGCampaignId__c;
        } 


        tRConsId = currLead.SSLead.TR_ID__c;
        system.debug(tRConsId);
        String sfCampId = currLead.SSLead.CurrentCampaign__r.Id;
        Campaign[] campR = [Select Recommit_Landing_Page__c from Campaign where id = :sfCampId];
        //Campaign[] campR = [Select Recommit_Landing_Page__c from Campaign where id = :campId];
        if (campR.size() > 0){
            recommitLanding = campR[0].Recommit_Landing_Page__c;
        }     
        system.debug(recommitLanding);

        system.debug('Camp ID: ' + campId);

        ldRec = new Lead(); 

        if(currLead != null && currLead.SSLead.Id != null) {           
            List<Lead> ld = [Select XREF__c from Lead where id = :currLead.SSLead.Id];
            ldRec = ld[0];
        }

        if (ldRec.XREF__c != NULL) {
            String[] arrXrefval = ldRec.XREF__c.split('[|]');   
            eventId = arrXrefval[0];
            system.debug('XREF Event ID: ' + eventId);

            if(consId == null || consId == '') {
                consId = arrXrefval[1];
                system.debug('XREF Cons ID: ' + consId);
            }
        }
        else {
            eventId = currLead.SSLead.CurrentCampaign__r.Evaluated_EventID__c;
            system.debug('Event ID: ' + eventId);
            consId = currLead.SSLead.TR_ID__c;
            system.debug('Cons ID: ' + consId);
        }

        if(consId != null) {
            if (String.isBlank(consId)) {
                isConsIdSet = false;
            }
            else {
                isConsIdSet = true;
                GetPage();
            }
        }
        else {
            isConsIdSet = false;
            GetPage();
        }
    }
    
    private void GetPage(){
        system.debug('Get Page');

        //**campId = currLead.SSLead.CurrentCampaign__r.EvaluatedDGGCampaignId__c;
        //campId = currLead.SSLead.CurrentCampaign__r.Id;
        //system.debug('Camp ID: ' + campId);

        //**String eventId = currLead.SSLead.CurrentCampaign__r.Evaluated_EventID__c;
        /*String eventId = '';

        ldRec = new Lead(); 

        if(currLead != null && currLead.SSLead.Id != null) {
            List<Lead> ld = [Select XREF__c from Lead where id = :currLead.SSLead.Id];
            ldRec = ld[0];
            system.debug('Lead: ' + ldRec);
        }

        if (ldRec.XREF__c != NULL) {
            String[] arrXrefval = ldRec.XREF__c.split('[|]');   
            eventId = arrXrefval[0];
            system.debug('Event ID: ' + eventId);

            if(consId == null || consId == '') {
                consId = arrXrefval[1];
                system.debug('Cons ID: ' + consId);
            }
        }
        else {
            eventId = currLead.SSLead.CurrentCampaign__r.Evaluated_EventID__c;
        }*/
        
        system.debug('campId: ' + campId);
        system.debug('consId: ' + consId);
        system.debug('eventId: ' + eventId);

        //check for bad event ID
        if(eventId != null) {
            try {
                Decimal convertedEvent = Decimal.valueOf(eventId);
            }
            catch (exception e) {
                system.debug('Event ID is not numeric.');
                eventId = '0';
            }
        }
        else {
            system.debug('Event ID is null.');
            eventId = '0';
        }
        
        //check for bad cons ID
        if(consId != null) {
            try {
                Decimal convertedCons = Decimal.valueOf(consId);
            }
            catch (exception e) {
                system.debug('Cons ID is not numeric.');
                consId = '0';
            }
        }
        else {
            system.debug('Cons ID is null.');
            consId = '0';
        }

        //check for bad camp ID
        if(campId == null) {
            system.debug('Camp ID is null.');
            campId = '0';
        }
        
        if(eventID != '0' && consId != '0' && campId != '0') {

            System.debug('Event Details:');
            eventDetails = OdataExtension.GetTREventRegDetailByConsEvent(Decimal.valueOf(consId), Decimal.valueOf(eventId));

            if(eventDetails == null) {
                eventDetails = new TREventRegistrationDetails__x();
                System.debug('No TR Event Details Found - EventID: ' + eventId + ', ConsId: ' + consId);
                eventID = '0';
            }
            else {
                System.debug(eventDetails);
            }
            

            System.debug('Singlet Orders:');
            so = OdataExtension.GetSingletOrdersByEvent(Decimal.valueOf(eventId), Decimal.valueOf(consId));

            if (so == null) {
                so = new SingletOrders__x();
                so.SingletOrdered__c = 'N';
                System.debug('No Singlet Orders Found - EventID: ' + eventId + ', ConsId: ' + consId);
            }
            else {
                System.debug(so);
            }
            

            System.debug('Marathin Recommits:');
            mr = OdataExtension.GetMarathonRecommits(Decimal.valueOf(eventId), consId);

            if(mr == null) {
                System.debug('No Marathon Recommits Found - EventID: ' + eventId + ', ConsId: ' + consId);
            }
            else {
                System.debug(mr);
            }


            if (eventDetails.MinimumGoal__c == null) eventDetails.MinimumGoal__c = 0;
            if (eventDetails.Current_Event_Revenue__c == null)eventDetails.Current_Event_Revenue__c = 0;

            needsRecommit = false;
            if (eventDetails.MinimumGoal__c > eventDetails.Current_Event_Revenue__c && mr == null) needsRecommit = true;


            //demo call
            //iis = OdataExtension.GetIncentiveInfosByCampCons('701J0000001qTvnIAE', '3030');

            //actual call
            iis = OdataExtension.GetIncentiveInfosByCampCons(campId, consId);
            if(iis == null) {
                iis = new List<IncentiveInfos__x>();
                System.debug('No Incentives - CampaignID: ' + campId + ', ConsId: ' + consId);
            }
        }
        else {
            //set defaults
            eventDetails = new TREventRegistrationDetails__x();
            so = new SingletOrders__x();
            iis = new List<IncentiveInfos__x>();
        }
    }  

    public void CheckIn() {
        update led;
    }

    public void ccDonate() {
        //update led;
    }
}