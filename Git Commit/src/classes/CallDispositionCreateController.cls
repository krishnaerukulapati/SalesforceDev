public with sharing class CallDispositionCreateController {
    
    public List<SelectOption> dispositionTypes {get; private set;}
    public String dispositionType { get; set;}
    public List<SelectOption> dispositionValues {get; private set;}
    public String dispositionValue { get; set;}
    private DateTime CDate;
    public String callComments {get; set;}
    @testVisible public ECCUtil.consInfo ci {get; private set;}
    @testVisible public ECCUtil.SSLeads currLead {get; private set;}
    public String taskDisposition {get; set;}

    //refactoring Disposition
    //relId is either caseId or leadId
    public String relId {get; set;}
    public String relIdType {get; private set;}
    public Case currCase {get; private set;}
    public String currCampaign {get; private set;}
    public String callerId {get; private set;}

    public CallDispositionCreateController() {
        init();
    }

    public void init(){
    	System.debug('init!');
        relId = System.currentPageReference().getParameters().get('id');
        System.debug('relId: ' + relId);
        relIdType = ECCUtil.getTypeById(relId);
        
        if(relIdType == 'Lead'){
            currLead = ECCUtil.getCurrLead(relId);
            currCampaign = currLead.SSLead.CurrentCampaign__r.Id;
            callerId = currLead.SSLead.CallerId__c;
        }
        else if (relIdType == 'Case') {
            currCase = ECCUtil.getCurrCase(relId).get(0);
            currCampaign = 'Case';
            callerId = currCase.CallObject__c;
        }
        //dispositionTypes = ECCUtil.getDispositionTypesByCampaign(currCampaign);
    }

    public void changeDispoType(){
        dispositionValue = '';
        //dispositionValues = ECCUtil.getDispositionValuesByType(currCampaign, dispositionType);
        System.debug('dispositionValues = ' + dispositionValues);
    }

    public void gatherInfoForSave(){
        if (relId != null){
            ci = getConsInfoFromECCUtil(relId);
            System.debug('ci: ' + ci);
        }
        save(ci, ci.consId);
    }

    public void save(ECCUtil.consInfo ci, string consId){
        CDate = Datetime.now();

        taskDisposition = concateTaskDispo(dispositionType, dispositionValue);
        System.debug('taskDisposition = ' + taskDisposition);

        try {
            System.debug('Trying to save...');
            if (validateForm()) {
                System.debug('callerId = ' + callerId);

                sendDispositionInfo(ci, currCampaign, dispositionType, dispositionValue, 
                                    callerId, callComments, CDate);

                sendTaskInfo(ci, consId, taskDisposition);
            }
        }
        catch(Exception e){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'You have attemped to create a duplicate task.'));
        }
        resetDispo();
    }

    @testVisible private boolean validateForm(){
        boolean valid = true;
        if(String.isBlank(dispositionType)) {
            System.debug('dispositionType is null! = ' + dispositionType);
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Type is required.'));
            valid = false;
        }
        System.debug('validateForm determined modal was = ' + valid);
        return valid;
    }

    public void resetDispo(){
        dispositionType = null;
        dispositionValue = null;
        callComments = null;
        taskDisposition = null;
    }

    @testVisible private ECCUtil.consInfo getConsInfoFromECCUtil(string relId){
        return ECCUtil.getConsInfo(relId);
    }

    @testVisible private string concateTaskDispo(string dispoType, string dispoVal){
        String concateDispo = null;

        if (String.isEmpty(dispoVal)){
            concateDispo = dispositionType; 
            System.debug('Since blank dispoVal just returning = ' + concateDispo);
        }
        else{ 
            concateDispo = (dispoType + ' - ' + dispoVal);
            System.debug('dispoType + dispoVal = ' + concateDispo);
        }
        return concateDispo;
    }

    @testVisible private void sendDispositionInfo(ECCUtil.consInfo ci, string campId, string dispoType, string dispoValue, string callid, 
                                string dispoComments, DateTime callD){
        //ECCUtil.addDisposition(ci, campId, dispoType, dispoValue, callid, dispoComments, callD);
        System.debug('Returning from ECCUtil.addDisposition()');
    }

    @testVisible private void sendTaskInfo(ECCUtil.consInfo ci, string contId, string callDisposition){
        ECCUtil.createTask(ci, 'Disposition', 'Completed', contId, callDisposition, true, null, null);
        System.debug('Returning from ECCUtil.createTask()');
    }

}