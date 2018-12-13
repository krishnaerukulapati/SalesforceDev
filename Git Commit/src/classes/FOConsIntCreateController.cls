public with sharing class FOConsIntCreateController {
    public domainSoapStjudeOrg.Interaction i {get; set;}
    public boolean warning {get; set;}
    public String action {get; set;}
    public boolean isEdit {get; private set;}
    public String relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public String consId {get; private set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();

    public FOConsIntCreateController(ApexPages.StandardController controller) {
        init();
    }

    public FOConsIntCreateController() {
        init();
    }

    private void init() {
        isEdit = false;
        i = new domainSoapStjudeOrg.Interaction();
        i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
        warning = false;
        relId = System.currentPageReference().getParameters().get('id');
        consId = System.currentPageReference().getParameters().get('consId');
        i.ContactDate = System.currentPageReference().getParameters().get('contDate');
        action = System.currentPageReference().getParameters().get('action');

        ci = ECCUtil.getConsInfo(relId);

        if(String.isNotBlank(i.ContactDate)) {
            isEdit = true;
            String cs = System.currentPageReference().getParameters().get('contSeq');
            String p = System.currentPageReference().getParameters().get('contPage');

            if (String.isNotBlank(cs) && cs.isNumeric()) i.ContactSeq = Integer.valueOf(cs);
            if (String.isNotBlank(p) && p.isNumeric()) i.Page_x = Integer.valueOf(p);
            i.ContactCategory = System.currentPageReference().getParameters().get('contCat');
            i.ContactType = System.currentPageReference().getParameters().get('contType');
            i.ResponseType = System.currentPageReference().getParameters().get('respType');
            i.ResponseCategory = System.currentPageReference().getParameters().get('respCat');
            i.TransactionSource.Technique = System.currentPageReference().getParameters().get('tech');
            i.LongComments = System.currentPageReference().getParameters().get('comments');
            i.Summary = System.currentPageReference().getParameters().get('summary');
            warning = System.currentPageReference().getParameters().get('warn') == 'Y';
            i.WarningExpirationDate = System.currentPageReference().getParameters().get('warnExp');
        }

        listValuesForCompare(before);

        system.debug('FOConsIntCreateController.FOConsIntCreateController: relId: ' + relId + ', consId: ' + consId +
            ', ContactDate: ' + i.ContactDate + ', ContactCategory: ' + i.ContactCategory);
    }

    public PageReference save() {
        PageReference pr;
        if (validateForm()) {
            if (!isEdit) {
                i.ContactDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
                i.Page_x = 1;
            }
            else {
                if(!i.ContactDate.endsWith(' 00:00:00'))
                    i.ContactDate += ' 00:00:00';
            }

            i.Warning = warning ? 'Y' : 'N';
            if (String.isNotBlank(i.WarningExpirationDate)) {
                system.debug('warnexp before: ' + i.WarningExpirationDate);
                i.WarningExpirationDate = ECCUtil.JavaDateStringToDate(i.WarningExpirationDate).formatGmt('yyyy-MM-dd');
                system.debug('warnexp after: ' + i.WarningExpirationDate);
            }
            
            listValuesForCompare(after);

            system.debug('FOConsIntCreateController.save: relId: ' 
                + relId + ', consId: ' + consId + ', ContactDate: ' + i.ContactDate
                + ', ContactSeq: ' + i.ContactSeq + ', Page_x: ' + i.Page_x);
            if (isEdit) {
                system.debug('editing');
                try {
                    FOUtil.editInteraction(consId, i);
                }
                catch(Exception e) {
                    System.debug('FOConsIntCreateController.save: editInteraction exception: ' + e.getMessage());
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving your interaction.'));
                    return null;
                }

                ECCUtil.createTask(ci, 'Interaction Edited', 'Completed', consId, 
                    before, 
                    after);
            }
            else {
                system.debug('creating');
                try {
                    FOUtil.createInteraction(consId, i);
                }
                catch(Exception e) {
                    system.debug('FOConsIntCreateController.save: createInteraction exception: ' + e.getMessage());
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving your interaction.'));
                    return null;
                }

                ECCUtil.createTask(ci, 'Interaction Created', 'Completed', consId, 
                    before, 
                    after);
            }

            pr = new PageReference('/Apex/FOInteraction');
            pr.getParameters().put('id', relId);
        }
        return pr;
    }

    private boolean validateForm() {
        boolean valid = true;

        //if(String.isBlank(i.ContactDate)) {
        //    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Date is required.'));
        //}

        if(String.isBlank(i.ContactCategory)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Category is required.'));
            valid = false;
        }
        if(String.isBlank(i.ContactType)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Type is required.'));
            valid = false;
        }
        if(String.isBlank(i.ResponseType) && String.isNotBlank(i.ResponseCategory)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Response Type is required if Response Category is provided.'));
            valid = false;
        }
        if(String.isBlank(i.ResponseCategory) && String.isNotBlank(i.ResponseType)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Response Category is required if Response Type is provided.'));
            valid = false;
        }
        if(String.isBlank(i.TransactionSource.Technique)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact method is required.'));
            valid = false;
        }
        if(warning && String.isBlank(i.LongComments)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comments are required on a warning.'));
            valid = false;
        }
        if(warning && String.isBlank(i.Summary)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Summary is required.'));
            valid = false;
        }
        return valid;
    }

    public void listValuesForCompare(List<String> vals) {
        vals.add(String.format('{0} = {1}', new String[] {'ContactDate', i.ContactDate == null ? '' : i.ContactDate}));
        vals.add(String.format('{0} = {1}', new String[] {'Page', i.Page_x == null ? '' : String.valueOf(i.Page_x)}));
        vals.add(String.format('{0} = {1}', new String[] {'Contact Category', i.ContactCategory == null ? '' : i.ContactCategory}));
        vals.add(String.format('{0} = {1}', new String[] {'Contact Type', i.ContactType == null ? '' : i.ContactType}));
        vals.add(String.format('{0} = {1}', new String[] {'Contact Method', i.TransactionSource.Technique == null ? '' : i.TransactionSource.Technique}));
        vals.add(String.format('{0} = {1}', new String[] {'Response Category', i.ResponseCategory == null ? '' : i.ResponseCategory}));
        vals.add(String.format('{0} = {1}', new String[] {'Response Type', i.ResponseType == null ? '' : i.ResponseType}));
        vals.add(String.format('{0} = {1}', new String[] {'Warning', i.Warning == null ? '' : i.Warning}));
        vals.add(String.format('{0} = {1}', new String[] {'Warning Expiration Date', i.WarningExpirationDate == null ? '' : i.WarningExpirationDate}));
    }
}