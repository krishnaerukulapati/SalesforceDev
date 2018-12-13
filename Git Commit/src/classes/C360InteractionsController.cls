global with sharing class C360InteractionsController{
  public string relId {get; private set;}
  public ECCUtil.consInfo ci {get; private set;}
  public integer page {get; private Set;}
  public integer pageTotal {get; private Set;}
  public String consId {get; set;}
  public Boolean showResponseAndSourceCode {get; private Set;} 
  public Boolean vipCheck {get; private set;}
  public Boolean gpCheck {get; private set;}
  //Boolean showResponseAndSourceCode = Boolean.valueOf('false');
  public List<domainSoapStjudeOrg.Interaction> interactions = new List<domainSoapStjudeOrg.Interaction>();
  
  private integer pageSize = 50;
  private Integer totalItems = 0;
  private LIST<ConstituentInformation__c> consIds;
  
  public C360InteractionsController.C360InteractionsController() {
    init();
  }

  public C360InteractionsController(ApexPages.StandardController controller) {
    init();
  }

  private void init() {
    domainSoapStjudeOrg.Constituent con;
    vipCheck = false;
    gpCheck = false;
    relId = System.currentPageReference().getParameters().get('id');
    system.debug('relId = ' + relId);
      system.debug(relId);
      /*List<CampaignDispConfig__c> cdc = [SELECT Id,Show_Response_Date_and_Source__c,Source_Code__c FROM CampaignDispConfig__c limit 1] ;
      if(cdc[0].Show_Response_Date_and_Source__c){
      showResponseAndSourceCode = true;
      }
      showResponseAndSourceCode = true;*/
      if (String.isNotEmpty(relId)) {
          ci = ECCUtil.getConsInfo(relId);
          system.debug('consId: ' + ci.consId);
        if (ci.consId != null) {
          consIds = ECCUtil.getConstituentInformationByConsInfo(ci);
          //consIds = C360Util.getConstituentIds(currCase.ConstituentUUID__c);
          consId = consIds.get(0).ConstituentId__c;
          //Making Properties call here.  Must remain
          con = C360Util.getConstituent(null, consId, new string[] {'PROPERTIES', 'PREFERENCES'});
          System.debug('con =  ' + con);

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
          for(String[]testPref : prefList){
              system.debug('testPref[0]: ' + testPref[0] + ', testPref:[1] ' + testPref[1]);
          }
          System.debug('ECCUtil.hasProperty = ' + con);
          vipCheck = ECCUtil.hasProperty(con, new string[] {'VIP_YES'}, true);
          System.debug('vipCheck = ' + vipCheck);
          gpCheck = ECCUtil.hasPreference(con, prefList, true);
          System.debug('gpCheck = ' + gpCheck);
          Boolean hasViewLongComments = ECCUtil.hasCustomPermissions('ViewLongComments');
          System.debug('hasViewLongComments = ' + hasViewLongComments);
        }
      }
  }

  public string getSourceURL() {
      return C360Settings__c.getInstance('SOURCE').C360SettingsURL__c;
  }
  
  public PageReference changeCons() {
    return null;
  }

  @RemoteAction
  global static soapStjudeOrg.GetInteractionsResponse_element getInteractionPage(string consId, integer startRow, integer endRow) {
    try {
      return C360Util.getInteractions(consId, 'ALL', startRow, endRow);
    }
    catch(Exception e) {
      return new soapStjudeOrg.GetInteractionsResponse_element();
    }
  }
  
  public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
  }
}