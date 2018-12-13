public with sharing class FODetailInterestController {

    public domainSoapStjudeOrg.Interest[] ints {get; set;}
    public string relId {get; private set;}
    public EVMUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
    private string name;
    public string contId {get; set;}
    private List<ConstituentInformation__c> consIds;
    public String consId {get; set;}
    
    public FODetailInterestController(ApexPages.StandardController controller) {
        init();
    }
    
    public FODetailInterestController() {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug(relId);
        ci = EVMUtil.getConsInfo(relId);

        system.debug('consId: ' + ci.consId);
        if (ci.consId == null) {
            isUUIDSet = false;
        }
        else {
            isUUIDSet = true;
            //consIds = FOUtil.getConstituentIds(currCase.ConstituentUUID__c);
            ints = FOUtil.getInterests(ci.consId);
            consId = ci.consId;
            
            consIds = EVMUtil.getConstituentInformationByConsInfo(ci);

            //get them from the constituent infos now - gonna write a wrapper in another util
            system.debug('FODetailController.FODetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
            //consId = consIds.get(0).ConstituentId__c;
        }
    }
    
    public void changeCons() {
        ints = FOUtil.getInterests(consId);
    }
    
    public LIST<SelectOption> getItems() {
        return EVMUtil.getConstituentIdsForSelect(consIds);
    }

    public PageReference RemoveInterest() {
        String remContId = contId; //ApexPages.currentPage().getParameters().get('DetailContId');
        system.debug('remContId: ' + remContId + ', consId: ' + consId + ', contId: ' + contId);

        FOUtil.removeInterest(consId, remContId);        
        ints = FOUtil.getInterests(consId);
        
        EVMUtil.createTask(ci, 'Interest Removed', 'Completed', consId, 
            new String[] {'Interest: ' + remContId}, 
            new String[] {''});

        return null;
    }

    public PageReference NewInterest() {
        PageReference newItem = Page.FOConstituentInterestEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        return newItem;
    }
}