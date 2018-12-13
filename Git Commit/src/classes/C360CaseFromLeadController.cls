public with sharing class C360CaseFromLeadController {
    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    Case c { get; set; }
    Lead leadToCase { get; set; }
    String consId { get; set; }
    boolean inConsole { get; set; }
    String relId {get; private set;}

    public C360CaseFromLeadController(ApexPages.StandardController stdController) {
        init();
    }

    public C360CaseFromLeadController() {
        init();
    }

    public void init() {

        system.debug('type: ' + System.currentPageReference().getParameters().get('leadid'));
        ECCUtil.SSLeads sl = ECCUtil.getCurrLead(System.currentPageReference().getParameters().get('leadid'));
        if (sl != null) {
            leadToCase = sl.SSLead;
        }

        relId = System.currentPageReference().getParameters().get('relId');
        consID = System.currentPageReference().getParameters().get('consId');
    }

    public PageReference OpenConsole() {
        PageReference pr = null;
        domainSoapStjudeOrg.Constituent con;
        boolean bError = false;

        //use the now impropertly named lead to case lead to see if we can get the constituent
        if (leadToCase != null) {
            leadToCase = ECCUtil.getCurrLead(leadToCase.Id).SSLead;
            //leadToCase = [select id, account_id__c, ConstituentId__c from Lead where id = :leadToCase.Id];

            //if we already know the constituent, then get it based on that
            if (String.isNotEmpty(leadToCase.ConstituentID__c)) {
                con = C360Util.getConstituent(null, leadToCase.ConstituentID__c, null, null, 'ALL');
                consId = con.ConstituentID;
            }
            //otherwise get the the constituent based on the acccoun / name_id combo
            else if (String.isNotEmpty(leadToCase.account_id__c)) {
                domainSoapStjudeOrg.SystemXRef xr = ECCUtil.getXrefFromLead(leadToCase);
                system.debug('xref key: ' + leadToCase.account_id__c + '|0');
                con = C360Util.getConstituent(null, null, xr, null, 'ALL');
                consId = con.ConstituentID;
            }
            else {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'This lead cannot be used to open a case.'));
                bError = true;
            }
        }
        //no lead?  try the constituent id
        else {
            if (String.isNotEmpty(consId)) {
                con = C360Util.getConstituent(null, consId, null, null, 'ALL');
            }
            else {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'No Lead or Constituent selected.'));
                bError = true;
            }
        }

        //did we get a constituent?
        if (!bError) {
            system.debug('cons type: ' + con.Type_x.Code);
            c = new Case();
            c.Origin = 'Phone (Outbound)';

            //CONMG-1196
            system.debug('relId=' + relId);
            ECCUtil.SSLeads currLead = ECCUtil.getCurrLead(relId);
            if (currLead != null) {
                system.debug('currLead.SSLead.CallObject__c=' + currLead.SSLead.CallObject__c);
                c.CallObject__c = currLead.SSLead.CallObject__c;
            }

            ECCUtil.setCaseConstituent(c, con.UUID, con.Name, con.Type_x.Code, null, consId);
            List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
            AppMenuItem eccApp = [select id, Name, ApplicationId, Label from AppMenuItem where Name = 'ECC']; //'02uL00000008dGX#%2F';
            boolean selected = false;

            // Iterate through each tab set describe for each app and display the info
            for(Schema.DescribeTabSetResult tsr : tabSetDesc) {
                system.debug('tsr.getLabel: ' + tsr.getLabel() + ' == ' + eccApp.Label);
                if (tsr.getLabel() == eccApp.Label) {
                    selected = tsr.isSelected();
                    break;   
                }           
            }       
            String partUrl;

            if (selected) {
                system.debug('selected, C360OpenConsole');
                partUrl = '/Apex/C360OpenConsole?cid=' + c.id;
                //partUrl = '/' + c.id;
            }
            else {
                system.debug('not selected, open sf console');
                partUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/console?tsid=' + eccApp.ApplicationId + '#%2F' + c.id;
            }

            system.debug(partUrl);
            pr = New PageReference(partUrl);
            pr.setRedirect(true);
            //pr.getParameters().put('id', c.Id);
        }

        return pr;
    }
}