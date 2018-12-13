public with sharing class C360DetailInterestController {

    public domainSoapStjudeOrg.Interest[] ints {get; set;}
    public string relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
    private string name;
    public string contId {get; set;}
    private List<ConstituentInformation__c> consIds;
    public String consId {get; set;}
    
    public C360DetailInterestController(ApexPages.StandardController controller) {
        init();
    }
    
    public C360DetailInterestController() {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);
        ci = ECCUtil.getConsInfo(relId);

        system.debug('consId: ' + ci.consId);
        if (ci.consId == null) {
            isUUIDSet = false;
        }
        else {
            isUUIDSet = true;
            //consIds = C360Util.getConstituentIds(currCase.ConstituentUUID__c);
            ints = C360Util.getInterests(ci.consId);
            consId = ci.consId;
            
            consIds = ECCUtil.getConstituentInformationByConsInfo(ci);

            //get them from the constituent infos now - gonna write a wrapper in another util
            system.debug('C360DetailController.C360DetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
            //consId = consIds.get(0).ConstituentId__c;
        }
    }
    
    public void changeCons() {
        ints = C360Util.getInterests(consId);
    }
    
    public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
    }

    public PageReference RemoveInterest() {
        String remContId = contId; //ApexPages.currentPage().getParameters().get('DetailContId');
        system.debug('remContId: ' + remContId + ', consId: ' + consId + ', contId: ' + contId);

        C360Util.removeInterest(consId, remContId);        
        ints = C360Util.getInterests(consId);
        
        ECCUtil.createTask(ci, 'Interest Removed', 'Completed', consId, 
            new String[] {'Interest: ' + remContId}, 
            new String[] {''});

        return null;
    }

    public PageReference NewInterest() {
        PageReference newItem = Page.C360ConstituentInterestEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        return newItem;
    }
}