public with sharing class C360ConstituentPreferenceEditController {
    public String conPreferenceID {get; set;}
    public String preference {get; set;}
    public String preferenceValue {get; set;}
    public String preferenceType {get; set;}
    public String preferenceTypeDesc {get; set;}
    public String startDate {get; set;}
    public String endDate {get; set;}
    public String status {get; set;}
    public String programType {get; set;}
    public String comments {get; set;}
    public String contId {get; private set;}
    public String relId {get; private set;}
    public String leadType {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public String consId {get; private set;}
    public String contactType {get; private Set;}
    public String firstName {get; private Set;}
    public String lastName {get; private Set;}
    public boolean foundPreference {get; private set;}
    public boolean bNew {get; private set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();
    private DateTime EDate;
    private DateTime SDate;

    public C360ConstituentPreferenceEditController(ApexPages.StandardController controller) {
        init();
    }

    public C360ConstituentPreferenceEditController() {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        leadType = System.currentPageReference().getParameters().get('leadType');
        if (String.isBlank(leadType)) leadType = 'ORG';
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId, leadType);
        
        system.debug(ci.consId);
        bNew = true;
        status = 'Active';
        if (ci.consId != null) {
            contId = System.currentPageReference().getParameters().get('contId');
            consId = System.currentPageReference().getParameters().get('consId');
            system.debug('contId: ' + contId + ', consId: ' + consId);
            domainSoapStjudeOrg.Constituent con = C360Util.getConstituent(null, consId, null, ci.consId);
            domainSoapStjudeOrg.Preference[] prefs = C360Util.getPreferences(consId);
            firstName = con.firstName;
            lastName = con.lastName;
            
            if (contId != null && contId.length() > 0) {
                if (prefs != null && prefs.size() > 0) {
                    for (domainSoapStjudeOrg.Preference p : prefs) {
                        if (p.ConstituentPreferenceID == contId) {
                            LoadPreference(p);
                        }
                    }
                }
            }
        }
    }
    
    private void LoadPreference(domainSoapStjudeOrg.Preference p) {
        conPreferenceID = p.ConstituentPreferenceID;
        preference = p.preference;
        preferenceValue = p.preferenceValue;
        preferenceType = p.preferenceType;
        preferenceTypeDesc = p.preferenceTypeDesc;
        programType = p.programType;
        startDate = string.valueOf(p.startDate);
        endDate = string.valueOf(p.endDate);
        status = p.status;
        foundPreference = true;
        bNew = false;
        listValuesForCompare(before);
    }
    
    public PageReference cancel() {
        PageReference pr = Page.C360PreferenceDetail;
        pr.getParameters().put('id', relId);
        return pr;
    }
    
    public PageReference save() {
        PageReference pr;

        TimeZone tz = TimeZone.getTimeZone('America/Chicago');
                
        SDate =  ECCUtil.JavaDateStringToDate(startDate);

        if (SDate == null) SDate = Datetime.now().date();
        Integer offSet = tz.getOffset(SDate);
        SDate = SDate.addSeconds(-1*offSet/1000);
    

        EDate =  ECCUtil.JavaDateStringToDate(endDate);
        
        if (EDate != null) {
            offSet = tz.getOffset(EDate);
            EDate = EDate.addSeconds(-1*offSet/1000);
        }

        try {
            if (validateForm()) {
                pr = Page.C360PreferenceDetail;
                domainSoapStjudeOrg.Preference p = new domainSoapStjudeOrg.Preference();
                
                String res = '';
                system.debug('consId: ' + consId + ', contId: ' + contId + ', preference: ' + preference +
                    ', preferenceValue: ' + preferenceValue + ', preferenceType: ' + preferenceType +
                    ', programType: ' + programType + ', startDate: ' + startDate + ', enddDate: ' + endDate +
                    ', comments: ' + comments + ', status: ' + status);

                if (String.isBlank(startDate)) startDate = String.valueOf(DateTime.now());


                res = C360Util.editPreference(consId, contId, preference, preferenceValue, 
                        preferenceType, programType, SDate, EDate, comments, status);

                System.debug(res);
                
                listValuesForCompare(after);
                ECCUtil.createTask(ci, bNew ? 'Preference Add' : 'Preference Edit', 'Completed', contId, before, after);
                
                pr.getParameters().put('id', relId);
                pr.getParameters().put('leadType', leadType);
                return pr;  
            }
        }
        catch(Exception e) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have attemped to create a duplicate preference.'));
        }

        return null; 
    }
    
    public LIST<SelectOption> getStatusTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('STATUS_TYPES')); 
    }
    
    public LIST<SelectOption> getPreferenceTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('PREF_TYPES')); 
    }

    public LIST<SelectOption> getPreferences() {
        LIST<SelectOption> so;
        if (String.isNotBlank(preferenceType))
            so = ECCUtil.getSelectFromC360Att(C360Util.getData('PREFS', preferenceType)); 
        return so;
    }

    public LIST<SelectOption> getPreferenceValues() {
        LIST<SelectOption> so;
        if (String.isNotBlank(preference))
            so = ECCUtil.getSelectFromC360Att(C360Util.getData('PREF_VALUES_BY_PREFS', preference)); 
        return so;
    }

    public void changePref() {
        preferenceValue = '';
    }

    public void changePrefType() {
        preference = '';
        preferenceValue = '';
    }

    private boolean validateForm() {
        boolean valid = true;

        if(String.isBlank(preference)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Preference is required.'));
            valid = false;
        }
        if(String.isBlank(preferenceValue)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Preference Value is required.'));
            valid = false;
        }
        if(String.isBlank(preferenceType)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Preference Type is required.'));
            valid = false;
        }
        if(String.isBlank(status)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status Type is required.'));
            valid = false;
        }
        if(SDate != null && EDate != null & EDate <= SDate) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'End Date must be after Start Date.'));
            valid = false;
        }
        return valid;
    }

    public void listValuesForCompare(List<String> vals) {
        vals.add(String.format('{0} = {1}', new String[] {'Preference', preference == null ? '' : preference}));
        vals.add(String.format('{0} = {1}', new String[] {'Preference Value', preferenceValue == null ? '' : preferenceValue}));
        vals.add(String.format('{0} = {1}', new String[] {'Preference Type', preferenceType == null ? '' : preferenceType}));
        vals.add(String.format('{0} = {1}', new String[] {'Start Date', startDate == null ? '' : startDate}));
        vals.add(String.format('{0} = {1}', new String[] {'End Date', endDate == null ? '' : endDate}));
        vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
    }
}