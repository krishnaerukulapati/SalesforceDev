public with sharing class C360ConstituentPropertyEditController {
    public String property {get; set;}
    public String startDate {get; set;}
    public String endDate {get; set;}
    public String status {get; set;}
    public String comments {get; set;}
    public String contId {get; private set;}
    public String relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public String consId {get; private set;}
    public String contactType {get; private Set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();

    public C360ConstituentPropertyEditController(ApexPages.StandardController controller) {
        init();
    }

    public C360ConstituentPropertyEditController() {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId);
        system.debug(ci.consId);
        if (ci.consId != null) {
            consId = System.currentPageReference().getParameters().get('consId');
            system.debug('consId: ' + consId);
        }
    }
    
    public PageReference cancel() {
            PageReference pr = Page.C360PropertyDetail;
            pr.getParameters().put('id', relId);
            return pr;
    }
    
    public PageReference save() {
        Try {
            PageReference pr;
            if (validateForm()) {
                    pr = Page.C360PropertyDetail;
                    
                    String res = '';
                    system.debug('consId: ' + consId + ', property: ' + property +
                            ', startDate: ' + startDate + ', endDate: ' + endDate +
                            ', comments: ' + comments + ', status: ' + status);
                            
                    TimeZone tz = TimeZone.getTimeZone('America/Chicago');
                            
                    DateTime SDate =  ECCUtil.JavaDateStringToDate(startDate);

                    if (SDate == null) SDate = Datetime.now().date();
                    Integer offSet = tz.getOffset(SDate);
                    SDate = SDate.addSeconds(-1*offSet/1000);
                

                    DateTime EDate =  ECCUtil.JavaDateStringToDate(endDate);
                    
                    if (EDate != null) {
                        offSet = tz.getOffset(EDate);
                        EDate = EDate.addSeconds(-1*offSet/1000);
                    }
                       
                    system.debug('SDate: '+SDate);    
                    system.debug('EDate: '+EDate);    

                    res = C360Util.SetProperty(consId, property, status, 
                            SDate , EDate);

                    System.debug(res);
                    
                    listValuesForCompare(after);
                    ECCUtil.createTask(ci, 'Property Added', 'Completed', contId, before, after);
                    
                    pr.getParameters().put('id', relId);
            }
            return pr;
        }
        catch(exception ex) {
            Apexpages.addmessage(new apexpages.message(apexpages.severity.error,'You attempted to add duplicate Property Type'));
    
            return null;        
        }

        return null; 
    }
    
    public LIST<SelectOption> getStatusTypes() {
            return ECCUtil.getSelectFromC360Att(C360Util.getData('STATUS_TYPES')); 
    }
    
    private boolean validateForm() {
            boolean valid = true;

            if(String.isBlank(property)) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Property is required.'));
                valid = false;
            }
            if(String.isBlank(status)) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
                valid = false;
            }
            return valid;
    }

    public void listValuesForCompare(List<String> vals) {
            vals.add(String.format('{0} = {1}', new String[] {'Property', property == null ? '' : property}));
            vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
            vals.add(String.format('{0} = {1}', new String[] {'Start Date', startDate == null ? '' : startDate}));
            vals.add(String.format('{0} = {1}', new String[] {'End Date', endDate == null ? '' : endDate}));
            vals.add(String.format('{0} = {1}', new String[] {'Comments', comments == null ? '' : comments}));
    }
}