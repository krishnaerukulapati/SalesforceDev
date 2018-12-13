public with sharing class C360ConsIntCreateController {
    public domainSoapStjudeOrg.Interaction i {get; set;}
    public boolean warning {get; set;}
    public boolean isEdit {get; private set;}
    public String relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public String consId {get; private set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();
    public Boolean vipCheck {get; private set;}
    public Boolean gpCheck {get; private set;} 
    public Boolean hasViewLongComments {get; private set;}
    public List<domainSoapStjudeOrg.Interaction> interactions = new List<domainSoapStjudeOrg.Interaction>();

    public C360ConsIntCreateController(ApexPages.StandardController controller) {
        init();
    }

    public C360ConsIntCreateController() {
        init();
    }

    private void init() {
        isEdit = false;
        vipCheck = false;
        gpCheck = false;
        hasViewLongComments = false;
        domainSoapStjudeOrg.Constituent con;
        i = new domainSoapStjudeOrg.Interaction();
        System.debug('i = ' + i);
        i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
        warning = false;
        relId = System.currentPageReference().getParameters().get('id');
        System.debug('relId = ' + relId);
        consId = System.currentPageReference().getParameters().get('consId');
        System.debug('consId = ' + consId);
        i.ContactDate = System.currentPageReference().getParameters().get('contDate');
        System.debug('i.ContactDate = ' + i.ContactDate);
        ci = ECCUtil.getConsInfo(relId); 

        //Making properties call here must remain.
        con = C360Util.getConstituent(null, consId, new string[] {'PROPERTIES', 'PREFERENCES'});
        System.debug('con =  ' + con);

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

            List<List<String>> prefList = new List<List<String>>{
                new String[]{'GPFDN', 'Y'},
                new String[]{'GPLEGACY', 'Y'},
                new String[]{'GPMAJORGFT', 'Y'},
                new String[]{'GPMULTI', 'Y'},
                new String[]{'GPSPORTS', 'Y'},
                new String[]{'MAJORDONOR', 'Y'},
                new String[]{'MAJORDONOR2', 'Y'},
                new String[]{'MD_CONTROL', 'Y'},
                new String[]{'DTM', 'Y'},
                new String[]{'DTTV', 'Y'},
                new String[]{'DRTV', 'Y'},
                new String[]{'DRTVMD', 'Y'},
                new String[]{'DRTVPIH', 'Y'},
                new String[]{'BUSINESS', 'Y'},
                new String[]{'FIELD', 'Y'},
                new String[]{'PIH2', 'Y'},
                new String[]{'PIH', 'Y'},
                new String[]{'PIH_CONTROL', 'Y'},
                new String[]{'RESP_AREA', 'FOUNDATION'},
                new String[]{'RESP_AREA', 'LEADERPROS'},
                new String[]{'RESP_AREA', 'CORPALL'},
                new String[]{'RESP_AREA', 'GIFTPLAN'},
                new String[]{'TTBUS', 'Y'},
                new String[]{'TTMD', 'Y'},
                new String[]{'TTPIH', 'Y'},
                new String[]{'TTPIH2', 'Y'}
            };

            vipCheck = ECCUtil.hasProperty(con, new string[] {'VIP_YES'}, true);
            System.debug('vipCheck = ' + vipCheck);
            gpCheck = ECCUtil.hasPreference(con, prefList, true);
            System.debug('gpCheck = ' + gpCheck);
            hasViewLongComments = ECCUtil.hasCustomPermissions('ViewLongComments');

            if(vipCheck || gpCheck){
                if(hasViewLongComments){
                    i.LongComments = System.currentPageReference().getParameters().get('comments');
                }
                else{
                    //i.LongComments = null;
                }
            }
            else{
                i.LongComments = System.currentPageReference().getParameters().get('comments');
            }
            System.debug('hasViewLongComments = ' + hasViewLongComments);

            warning = System.currentPageReference().getParameters().get('warn') == 'Y';
            i.WarningExpirationDate = System.currentPageReference().getParameters().get('warnExp');
        }

        listValuesForCompare(before);

        system.debug('C360ConsIntCreateController.C360ConsIntCreateController: relId: ' + relId + ', consId: ' + consId +
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

            system.debug('C360ConsIntCreateController.save: relId: ' 
                + relId + ', consId: ' + consId + ', ContactDate: ' + i.ContactDate
                + ', ContactSeq: ' + i.ContactSeq + ', Page_x: ' + i.Page_x);
            if (isEdit) {
                system.debug('editing');
                try {
                    //adding ability to edit
                    if(vipCheck || gpCheck){
                        if(hasViewLongComments){
                        }
                        else{
                            System.debug('hasViewLongComments = ' + hasViewLongComments);
                            System.debug('vipCheck during save = ' + vipCheck);
                            System.debug('gpCheck during save = ' + gpCheck);
                            System.debug('i.LongComments = ' + i.LongComments);
                            String existingComment = System.currentPageReference().getParameters().get('comments');
                            System.debug('existingComment = ' + existingComment);
                            String addedComment = i.LongComments;
                            System.debug('addedComment = ' + addedComment);
                            i.LongComments = (existingComment + ' ' + addedComment);
                            System.debug('i.LongComments = ' + i.LongComments);
                        }
                    }
                    system.debug('consId = ' + consId);
                    system.debug('i = ' + i);
                    system.debug('i.LongComments = ' + i.LongComments);
                    C360Util.editInteraction(consId, i);
                }
                catch(Exception e) {
                    if(!hasViewLongComments){
                        i.LongComments = null;
                    }
                    system.debug('C360ConsIntCreateController.save: editInteraction exception: ' + e.getMessage());
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving your interaction.'));
                    return null;
                }

                ECCUtil.createTask(ci, 'Interaction Edited', 'Completed', consId, 
                    before, 
                    after);
            }

            else {
                system.debug('creating');
                i.WarningExpirationDate = null;  //forcing null for now.  Any value otherthan null throws a c360 error --Kris K
                system.debug(
                  'i.ContactDate = ' + i.ContactDate + 
                  '\ni.Page_x = ' + i.Page_x + 
                  '\ni.ContactCategory = ' + i.ContactCategory + 
                  '\ni.ContactType = ' + i.ContactType +
                  '\ni.TransactionSource.Technique = ' + i.TransactionSource.Technique + 
                  '\ni.ResponseCategory = ' + i.ResponseCategory + 
                  '\ni.ResponseType = ' + i.ResponseType + 
                  '\ni.Warning = ' + i.Warning + 
                  '\ni.WarningExpirationDate = ' + i.WarningExpirationDate + 
                  '\ni.LongComments = ' + i.LongComments
                );
                try {
                    System.debug('i = ' + i);
                    System.debug('i.Technique = ' + i.Technique);
                    C360Util.createInteraction(consId, i);
                }
                catch(CalloutException e) {
                    C360Util.createInteractionDMS(consId, i);
                }
                catch(Exception e) {
                    system.debug('C360ConsIntCreateController.save: createInteraction exception: ' + e.getMessage());
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving your interaction.'));
                    return null;
                }

                ECCUtil.createTask(ci, 'Interaction Created', 'Completed', consId, 
                    before, 
                    after);
            }

            pr = new PageReference('/Apex/C360Interactions');
            pr.getParameters().put('id', relId);
        }
        return pr;
    }

    private boolean validateForm() {
        boolean valid = true;

        if(String.isBlank(i.ContactCategory)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Category is required.'));
            valid = false;
        }
        if(String.isBlank(i.ContactType)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Type is required.'));
            valid = false;
        }
        if(String.isBlank(i.ResponseType) && String.isNotBlank(i.ResponseCategory)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Response Type is required if Response Category is         vided.'));
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