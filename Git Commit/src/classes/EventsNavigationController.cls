public class EventsNavigationController {
    private EnvironmentSettings__c es;  // this holds the environment settings
    public String imageURL { get; set; } //are you still using this?

    //FOLinks.page also uses this controller to get link URLs

    public EventsNavigationController(ApexPages.StandardController controller) {
        init();
    }

    public EventsNavigationController() {
        init();
    }

    private void init() {
        es = [
            SELECT 
                EventsOrg__c
                , SourceCodes__c
                , DMSOrg__c
                , FieldOpsReporting__c
                , EventInventory__c 
                , WholesaleMerch__c 
                , StaffRegURL__c
                , GuestAppURL__c
                , ORAURL__c 
                , EventDayURL__c 
                , FOSalesforceReports__c
                , ALSACEmail__c
                , FieldOpsSharepoint__c
                , TaskManagement__c
                , TeamRaiserEMC__c
                , TimesheetEntry__c
                , Arc__c
                , Concur__c
                , Magna__c
                , ProgramCommunity__c
                , ProgramCreate__c
                , ProgramDGG__c
                , ProgramDreamHome__c
                , ProgramFitness__c
                , ProgramPromotions__c
                , ProgramRadio__c
                , ProgramSearch__c
                , ProgramVolunteer__c
                , ProgramYouth__c
                , ConsManagementGuide__c
                , InteractionsManagementGuide__c
                , InstallingSalesforceOneGuide__c
                , PreferenceGuide__c
                , EventCreationGuide__c
                , ManageAccountGuide__c
                , EventDemoDashboard__c
                , EventDemoDashboardYoY__c
                , FileCabinet__c
                , FO_i360_Overview__c
                , FO_ConsMgmt_Trng_Crs__c
                , FO_Int_Mgmt_Trng_Crs__c
                , FO_i360_Mobile_Trng_Crs__c
                , Reg_Event_Financials__c
                , Event_Demographics__c
                , Event_Revenue__c
                , YoY_Event_Demographics__c
                , DGGRadioReport__c
                , FO_Tableau_Site__c
            from
                EnvironmentSettings__c 
            where
                SetupOwnerId = :UserInfo.getOrganizationId()];

        system.debug('EventsOrg__c: ' + es.EventsOrg__c);
        system.debug('SourceCodes__c: ' + es.SourceCodes__c);
        system.debug('DMSOrg__c: ' + es.DMSOrg__c);
        system.debug('FieldOpsReporting__c: ' + es.FieldOpsReporting__c);
        system.debug('StaffRegURL__c: ' + es.StaffRegURL__c);
        system.debug('GuestAppURL__c: ' + es.GuestAppURL__c);
        system.debug('ORAURL__c: ' + es.ORAURL__c);
        system.debug('EventDayURL__c: ' + es.EventDayURL__c);
        system.debug('FOSalesforceReports__c:' + es.FOSalesforceReports__c);
        system.debug('ALSACEmail__c:' + es.ALSACEmail__c);
        system.debug('FieldOpsSharepoint__c:' + es.FieldOpsSharepoint__c);
        system.debug('TaskManagement__c:' + es.TaskManagement__c);
        system.debug('TeamRaiserEMC__c:' + es.TeamRaiserEMC__c);
        system.debug('TimesheetEntry__c:' + es.TimesheetEntry__c);

    }

    //this will return the environment settings to the vf page like so:
    // {!envSett.EventsOrg__c}
    // {!envSett.SourceCodes__c}
    // {!envSett.DMSOrg__c}
    // {!envSett.FieldOpsReporting__c}
    // {!envSett.i360ContactDS__c}
    // {!envSett.i360ContactPS__c}
    // {!envSett.i360Events__c}
    // {!envSett.StaffRegURL__c}
    // {!envSett.GuestAppURL__c}
    // {!envSett.ORAURL__c}
    // {!envSett.EventDayURL__c}
    // {!envSett.FOSalesforceReports__c}
    public EnvironmentSettings__c  getEnvSett() {
        return es;
    }
    
    public String getSearchURL() {
        AppMenuItem eccApp = [
            select 
                id, Name, ApplicationId, Label 
            from 
                AppMenuItem 
            where 
                Name = 'FO'];
        return URL.getSalesforceBaseUrl().toExternalForm() + '/console?tsid=' + eccApp.ApplicationId;
    }

    public String getEventSearchURL() {
        AppMenuItem eccApp = [
            select 
                id, Name, ApplicationId, Label 
            from 
                AppMenuItem 
            where 
                Name = 'i360_Events'];
        if (getContextUserUiTheme() == 'Theme4d') {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/?tsid=' + eccApp.ApplicationId;          
        }
        else {
            return URL.getSalesforceBaseUrl().toExternalForm() + '/home/home.jsp?tsid=' + eccApp.ApplicationId;
        }       
    }

        public String getContactSearchURL() {
        AppMenuItem eccApp = [
            select 
                id, Name, ApplicationId, Label 
            from 
                AppMenuItem 
            where 
                Name = 'ECC'];
        return URL.getSalesforceBaseUrl().toExternalForm() + '/console?tsid=' + eccApp.ApplicationId;
    }

    
    public Account account { get; private set; } //are you still using this?

    public String getContextUserUiTheme() {
        //Theme1—Obsolete Salesforce theme
        //Theme2—Salesforce Classic 2005 user interface theme
        //Theme3—Salesforce Classic 2010 user interface theme
        //Theme4d—Modern “Lightning Experience” Salesforce theme
        //Theme4t—Salesforce1 mobile Salesforce theme
        //PortalDefault—Salesforce Customer Portal theme
        //Webstore—Salesforce AppExchange theme
        system.debug('UI Theme: ' + UserInfo.getUiTheme());
        return UserInfo.getUiTheme();
    }    
}