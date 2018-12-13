public with sharing class C360ConstituentInterestEditController {
    public String interest {get; set;}
    public String programType {get; set;}
    public String status {get; set;}
    public String comments {get; set;}
    public String intId {get; private set;}
    public String relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public String consId {get; private set;}
    public String contactType {get; private Set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();

    public C360ConstituentInterestEditController(ApexPages.StandardController controller) {
        init();
    }
    
    public C360ConstituentInterestEditController() {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId);
        system.debug('consId: ' + ci.consId);

        if (ci.consId != null) {
            consId = System.currentPageReference().getParameters().get('consId');
            system.debug('consId: ' + consId);
        }
    }
    
    public PageReference cancel() {
        PageReference pr = Page.C360InterestDetail;
        pr.getParameters().put('id', relId);
        return pr;
    }
    
    public PageReference save() {
        Try {
            PageReference pr;
            if (validateForm()) {
                pr = Page.C360InterestDetail;
                
                String res = '';
                system.debug('consId: ' + consId + ', interest: ' + interest +
                        ', programType: ' + programType +
                        ', comments: ' + comments + ', status: ' + status);  

                res = C360Util.setInterest(consId, interest, status, 
                        programType);

                System.debug(res);
                
                listValuesForCompare(after);
                ECCUtil.createTask(ci, 'Interest Added', 'Completed', intId, before, after);
                
                pr.getParameters().put('id', relId);
            }
            return pr;
        }
        catch(exception ex) {
            Apexpages.addmessage(new apexpages.message(apexpages.severity.error,'You attempted to add a duplicate Interest'));
    
            return null;        
        }

        return null; 
    }
    
    public LIST<SelectOption> getStatusTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('STATUS_TYPES')); 
    }
    
    public LIST<SelectOption> getInterestTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('INTERESTS')); 
    }
    
    public LIST<SelectOption> getProgramTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('PROGRAM_TYPES')); 
    }
    
    private boolean validateForm() {
        boolean valid = true;

        if(String.isBlank(interest)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Interest is required.'));
            valid = false;
        }
        if(String.isBlank(status)) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
            valid = false;
        }
        return valid;
    }

    public void listValuesForCompare(List<String> vals) {
            vals.add(String.format('{0} = {1}', new String[] {'Interest', interest == null ? '' : interest}));
            vals.add(String.format('{0} = {1}', new String[] {'Status', status == null ? '' : status}));
            vals.add(String.format('{0} = {1}', new String[] {'Program Type', programType == null ? '' : programType}));
            vals.add(String.format('{0} = {1}', new String[] {'Comments', comments == null ? '' : comments}));
    }
}