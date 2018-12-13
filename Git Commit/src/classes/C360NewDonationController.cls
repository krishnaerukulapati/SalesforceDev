public with sharing class C360NewDonationController {
  public C360NewDonationController() {
  }
  
  public PageReference NewDonation() {
    PageReference ret = null;
    String leadId = System.currentPageReference().getParameters().get('id');
    String isDonate = System.currentPageReference().getParameters().get('isDonate');
    EVMUtil.SSLeads currLead = EVMUtil.getCurrLead(leadId);
    
    String leadTRIdParm = '';
    String leadConsIdParm = '';
    String eventIdParm = '&eventid=' + CustomSettings__c.getInstance('ccDonateECCDonation').Value__c;

    string destination = '';

    system.debug(currLead);

    if (currLead != null) {

      if(isDonate != null) {
        if(isDonate.toLowerCase() == 'true') {
          system.debug('New General Donation');

          leadConsIdParm = '&c360ConsId=' + currLead.SSLead.ConstituentId__c;
          eventIdParm = '&eventid=' + currLead.SSLead.CurrentCampaign__r.CCDonate_Gift_ID__c;

          //test event
          //eventIDParm = '&eventid=29';
        }
        else {
          system.debug('Recommit Donation');
          leadTRIdParm = '&trConsId=' + currLead.SSLead.TR_ID__c;

          if(currLead.SSLead.CurrentCampaign__r.CCDonate_Recommit_ID__c == null) {
            eventIdParm = '&eventid=' + CustomSettings__c.getInstance('ccDonateRecommitDonation').Value__c;
          }
          else {
            eventIdParm = '&eventid=' + currLead.SSLead.CurrentCampaign__r.CCDonate_Recommit_ID__c;
          }

              system.debug('currLead.SSLead.TR_ID__c: ' + currLead.SSLead.TR_ID__c);
          }
      }
      else {
        system.debug('Recommit Donation');
        leadTRIdParm = '&trConsId=' + currLead.SSLead.TR_ID__c;

        if(currLead.SSLead.CurrentCampaign__r.CCDonate_Recommit_ID__c == null) {
          eventIdParm = '&eventid=' + CustomSettings__c.getInstance('ccDonateRecommitDonation').Value__c;
        }
        else {
          eventIdParm = '&eventid=' + currLead.SSLead.CurrentCampaign__r.CCDonate_Recommit_ID__c;
        }
        
            system.debug('currLead.SSLead.TR_ID__c: ' + currLead.SSLead.TR_ID__c);
        }
    }
    
    destination = ccDonateSettings__c.getInstance('Master').ccDonateSettingsURL__c
    + eventIdParm
    + '&user=' + User.Username
    + '&token=' + EVMUtil.getToken()
    + leadConsIdParm
    + leadTRIdParm
    + '&showHeader=false'
    + '&returnURL=' + Encodingutil.urlEncode(
      URL.getSalesforceBaseUrl().toExternalForm() + Page.C360NewDonationComplete.getURL() + '?id=' + leadId, 'UTF-8')
    + '&cancelURL=' + Encodingutil.urlEncode(
      URL.getSalesforceBaseUrl().toExternalForm() + Page.C360CloseRefresh.getURL(), 'UTF-8');      
        
    system.debug(destination);
    ret = new PageReference(destination) ;
        
        return ret;
  }

  public void NewDonationComplete() {
    String leadId = System.currentPageReference().getParameters().get('id');
    String donationId = System.currentPageReference().getParameters().get('donationId');
    String confNum = System.currentPageReference().getParameters().get('confNum');
    String donationAmount = System.currentPageReference().getParameters().get('donationAmount');
    ECCUtil.consInfo ci = ECCUtil.getConsInfo(leadId);

    ECCUtil.createTask(ci, 'Created New Recommitment', 'Completed', ci.consId, 
      new String[] {'', ''}, new String[] {'donationId: ' + donationId, 
        'confNum: ' + confNum, 
        'donationAmount: ' + donationAmount});

  }
}