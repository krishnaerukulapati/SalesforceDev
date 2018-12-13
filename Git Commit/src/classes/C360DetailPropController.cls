public with sharing class C360DetailPropController {
    public domainSoapStjudeOrg.Property[] props {get; set;}
    public string relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
    private string name;
    public string contId {get; set;}
    private List<ConstituentInformation__c> consIds;
    public String consId {get; set;}
    public boolean bShowInactive {get; set;}
    
    public C360DetailPropController(ApexPages.StandardController controller) {
        init();
    }

    public C360DetailPropController() {
        init();
    }

    public void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug('relId: ' + relId);

        ci = ECCUtil.getConsInfo(relId);

        system.debug('consId: ' + ci.consId);
        if (ci.consId == null) {
            isUUIDSet = false;
        }
        else {
            isUUIDSet = true;
            //consIds = C360Util.getConstituentIds(currCase.ConstituentUUID__c);
            props = C360Util.getProperties(ci.consId);
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
            
            consIds = ECCUtil.getConstituentInformationByConsInfo(ci);

            //get them from the constituent infos now - gonna write a wrapper in another util
            system.debug('C360DetailController.C360DetailController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
            //consId = consIds.get(0).ConstituentId__c;
        }
    }
    
    public void changeCons() {
        props = C360Util.getProperties(consId);
    }
    
    public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
    }

    public PageReference RemoveProperty() {
        String remContId = contId; //ApexPages.currentPage().getParameters().get('DetailContId');
        system.debug('remContId: ' + remContId + ', consId: ' + consId + ', contId: ' + contId);

        C360Util.removeProperty(consId, remContId);        
        props = C360Util.getProperties(consId);
        
        ECCUtil.createTask(ci, 'Property Removed', 'Completed', consId, 
            new String[] {'Property: ' + remContId}, 
            new String[] {''});

        return null;
    }

    public PageReference NewProperty() {
        PageReference newItem = Page.C360ConstituentPropertyEdit; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('id', System.currentPageReference().getParameters().get('id'));
        newItem.getParameters().put('consId', consId);
        return newItem;
    }
}