/* Author        :  John Kirkpatrick
* Name          :  OutboundPopController
* Date          :  July 25th,2017
* Description   :  Used to update lead Information                 
*******************************************************************/
public with sharing class OutboundPopController {
    public String leadId {get; private set;}
    public String contactId {get; private set;}
    public String leadskillId {get; private set;}
    
    public OutboundPopController() {   
      System.debug('OutboundPopController constructor start');
        leadskillId = System.currentPageReference().getParameters().get('relId');
        contactId = System.currentPageReference().getParameters().get('_c');
        System.debug('OutboundPopController received leadskill Id/relId: ' + leadskillId);
        System.debug('OutboundPopController received contactId: ' + contactId);
        If(leadskillId!=null){
           LeadSkill__c ls=[select id, Dialerstatus__c,Lead__c,Opportunity__c from LeadSkill__c where Id  = :leadskillId]; 
           leadId=ls.Lead__c;
        }
        System.debug('OutboundPopController lead Id: ' + leadId);
    }

    public PageReference updateAndRedirect()
    {
        updateLead(leadId, contactId);
        return redirectToLeadById(leadId);
    }

    private Boolean updateLead(String leadId, String contactId) {
      Boolean success = false;
        if (String.isNotEmpty(leadId)) {
            Lead l = [select id, CallObject__c from lead where id = :leadId limit 1];
            System.debug('Updating lead id=' + leadId + ', setting CallObject__c from ' + l.CallObject__c + ' to ' + contactId);
            l.CallObject__c = contactId;

           try {
               update l;
               success = true;
           }
           catch(Exception exc) {
              System.debug('OutboundPopController.updateLead exception: ' + exc.getMessage());
           }

            return success;
        }
        else{
          System.debug('OutboundPopController.updateLead received empty string for leadId');
        }

        return false;
    }

  private PageReference redirectToLeadById(string leadId) {
        PageReference pr = new PageReference('/apex/C360OpenConsole?cid=' + leadId);
        pr.setRedirect(true);
        system.debug(pr.getUrl());
        return pr;
  }

}