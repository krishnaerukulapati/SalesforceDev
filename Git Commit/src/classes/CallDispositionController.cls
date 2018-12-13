public with sharing class CallDispositionController {

    public String relId {get; set;}
    public String relIdType {get; private set;}
    public List<CallDisposition__c> dispoList {get; private set;}

    public Case currCase {get; private set;}
    public ECCUtil.SSLeads currLead {get; private set;}
    public String currCampaign {get; private set;}
    public String callerId {get; private set;}
    public Boolean hasDispos {get; private set;}

    public CallDispositionController(){
        init();
    }

    public void init(){
        System.debug('init!');
        hasDispos = true;
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

        dispoList = getCallDispositionsById(relId);
    }

    public List<CallDisposition__c> getCallDispositionsById(string relId){
        List<CallDisposition__c> cd = new List<CallDisposition__c>();
        cd = [SELECT Id, CallDate__c, CallerId__c, DispositionCampaignId__c,
                DispositionComments__c, DispositionType__c, DispositionValue__c, WhoId__c
                FROM CallDisposition__c
                WHERE WhoId__c = :relId];
        return cd;
    }
    
}