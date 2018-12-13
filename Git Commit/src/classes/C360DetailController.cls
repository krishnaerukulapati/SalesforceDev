public with sharing class C360DetailController {
    public domainSoapStjudeOrg.Constituent con {get; set;}
    public string relId {get; private set;}
    public string leadType {get; private set;}
    public boolean isUUIDSet {get; set;}
    private string name;
    public string contId {get; set;}
    private List<ConstituentInformation__c> consIds;
    public String consId {get; set;}
    public String consType {get; set;}
    
    public C360DetailController(ApexPages.StandardController controller) {
        init();
    }

    public C360DetailController() {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        leadType = System.currentPageReference().getParameters().get('leadType');
        if (String.isBlank(leadType)) leadType = 'ORG';
        system.debug(relId);
        ECCUtil.consInfo ci = ECCUtil.getConsInfo(relId, leadType);
        system.debug(ci.consId);
        if (String.isEmpty(ci.consId)) {
            isUUIDSet = false;
        }
        else {
            isUUIDSet = true;
            //consIds = C360Util.getConstituentIds(currCase.ConstituentUUID__c);
            con = C360Util.getConstituent(null, ci.consId, new string[] {'PROFILE', 'PREFERENCES'}, 'ALL');
            consId = con.ConstituentID;
            consType = con.Type_x.Code;
            
            consIds = ECCUtil.getConstituentInformationByConsInfo(ci);

            //get them from the constituent infos now - gonna write a wrapper in another util
            system.debug('C360DetailController.C360DetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
            //consId = consIds.get(0).ConstituentId__c;
        }
    }
    
    public void changeCons() {
        con = C360Util.getConstituent(null, consId, new string[] {'PROFILE'}, consType);
    }
    
    public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
    }
    
    public string getName() {
        return con.LastName + ', ' + con.FirstName;
    }
    
    public PageReference EditAddress() {
        PageReference edit = Page.C360ConstituentAddressEdit; 
        system.debug('contId: ' + contId);
        edit.setRedirect(true);
        edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
        edit.getParameters().put('consId', consId);
        edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        edit.getParameters().put('leadType', leadType);
        return edit;
    }

    public PageReference NewAddress() {
        PageReference newItem = Page.C360ConstituentAddressEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        newItem.getParameters().put('leadType', leadType);
        return newItem;
    }

    public PageReference EditPhone() {
        PageReference edit = Page.C360ConstituentPhoneEdit; 
        system.debug('contId: ' + contId);
        edit.setRedirect(true);
        edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
        edit.getParameters().put('consId', consId);
        edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        edit.getParameters().put('leadType', leadType);
        return edit;
    }

    public PageReference NewPhone() {
        PageReference newItem = Page.C360ConstituentPhoneEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        newItem.getParameters().put('leadType', leadType);
        return newItem;
    }

    public PageReference EditEmail() {
        PageReference edit = Page.C360ConstituentEmailEdit; 
        system.debug('contId: ' + contId);
        system.debug('consId: ' + consId);
        edit.setRedirect(true);
        edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
        edit.getParameters().put('consId', consId);
        edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        edit.getParameters().put('leadType', leadType);
        return edit;
    }

    public PageReference NewEmail() {
        PageReference newItem = Page.C360ConstituentEmailEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        newItem.getParameters().put('leadType', leadType);
        return newItem;
    }

    public PageReference EditPreference() {
        PageReference edit = Page.C360ConstituentPreferenceEdit; 
        system.debug('contId: ' + contId);
        edit.setRedirect(true);
        edit.getParameters().put('contId', ApexPages.currentPage().getParameters().get('DetailContId'));
        edit.getParameters().put('consId', consId);
        edit.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        edit.getParameters().put('leadType', leadType);
        return edit;
    }

    public PageReference NewPreference() {
        PageReference newItem = Page.C360ConstituentPreferenceEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        newItem.getParameters().put('leadType', leadType);
        return newItem;
    }

}