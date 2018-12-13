public with sharing class FODetailPropController {
    public domainSoapStjudeOrg.Property[] props {get; set;}
    public string relId {get; private set;}
    public EVMUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
    private string name;
    public string contId {get; set;}
    private List<ConstituentInformation__c> consIds;
    public String consId {get; set;}
    
    public FODetailPropController(ApexPages.StandardController controller) {
        init();
    }

    public FODetailPropController() {
        init();
    }

    public void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug('relId: ' + relId);

        ci = EVMUtil.getConsInfo(relId);

        system.debug('consId: ' + ci.consId);
        if (ci.consId == null) {
            isUUIDSet = false;
        }
        else {
            isUUIDSet = true;
            //consIds = FOUtil.getConstituentIds(currCase.ConstituentUUID__c);
            props = FOUtil.getProperties(ci.consId);
            if (props != null){

                for(domainSoapStjudeOrg.Property p : props) {
                    TimeZone tz = TimeZone.getTimeZone('America/Chicago');

                    if (p.startDate != null) {
                        system.debug('startDate: ' + p.startDate);
                        Integer offSet = tz.getOffset(p.startDate) / 1000;
                        system.debug('offset: ' + offSet);
                        p.startDate = p.startDate.addSeconds(offSet);
                    }
                    if (p.endDate != null) {
                        system.debug('endDate: ' + p.endDate);
                        Integer offSet = tz.getOffset(p.endDate) / 1000;
                        system.debug('offset: ' + offSet);
                        p.endDate = p.endDate.addSeconds(offSet);
                    }
                }
            }
            consId = ci.consId;
            
            consIds = EVMUtil.getConstituentInformationByConsInfo(ci);

            //get them from the constituent infos now - gonna write a wrapper in another util
            system.debug('FODetailController.FODetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
            //consId = consIds.get(0).ConstituentId__c;
        }
    }
    
    public void changeCons() {
        props = FOUtil.getProperties(consId);
    }
    
    public LIST<SelectOption> getItems() {
        return EVMUtil.getConstituentIdsForSelect(consIds);
    }

    public PageReference RemoveProperty() {
        String remContId = contId; //ApexPages.currentPage().getParameters().get('DetailContId');
        system.debug('remContId: ' + remContId + ', consId: ' + consId + ', contId: ' + contId);

        FOUtil.removeProperty(consId, remContId);        
        props = FOUtil.getProperties(consId);
        
        EVMUtil.createTask(ci, 'Property Removed', 'Completed', consId, 
            new String[] {'Property: ' + remContId}, 
            new String[] {''});

        return null;
    }

    public PageReference NewProperty() {
        PageReference newItem = Page.FOConstituentPropertyEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        return newItem;
    }
}