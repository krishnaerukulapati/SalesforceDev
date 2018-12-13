public without sharing class C360DetailRelController {
    public domainSoapStjudeOrg.Relationship[] rels {get; set;}
    public string relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public string consType {get; private set;}
    public boolean isUUIDSet {get; set;}
    public string contId {get; set;}
    private List<ConstituentInformation__c> consIds;
    public String consId {get; set;}
    public String household { get; set; }
    
	public Integer startRow {get; private Set;}
	public Integer endRow {get; private Set;}
    public Integer totalResults {get; private Set;}
    public domainSoapStjudeOrg.Constituent con {get; private set;}
	private Integer pageSize = 10;
    
	public Boolean getFirstPage() {
		return startRow == 1;
	}
	
	public Boolean getLastPage() {
		return endRow >= totalResults;
	}
    
    public Integer getCurrPage() {
        return (startRow + pageSize - 1) / pageSize;
    }
    
    public Integer getTotalPages() {
        return integer.valueOf(string.valueOf(Math.ceil(totalResults / Double.ValueOf(pageSize))));
    }
    
    public C360DetailRelController(ApexPages.StandardController controller) {
        init();
    }
    
    public C360DetailRelController() {
        init();
    }

    public void init() {
        relId = System.currentPageReference().getParameters().get('id');
        system.debug('relId = ' + relId);

        ci = ECCUtil.getConsInfo(relId);
        system.debug('currcase: ' + ci.consId);
        if (ci.consId == null) {
            isUUIDSet = false;
        }
        else {
            isUUIDSet = true;
            //consIds = C360Util.getConstituentIds(currCase.ConstituentUUID__c);
            consId = ci.consId;
            consType = ci.consType;
            con = C360Util.getConstituent(null, consId, null, consType);
            if (consType == 'INDIVIDUAL') {
                if (con.RelatedHousehold != null && con.RelatedHousehold.ConstituentId != null && 
                    con.RelatedHousehold.ConstituentId != '') {
                    consId = con.RelatedHousehold.ConstituentId;
                }
            }

            consIds = ECCUtil.getConstituentInformationByConsInfo(ci);
            changeCons();

            //get them from the constituent infos now - gonna write a wrapper in another util
            system.debug('C360DetailRelController.C360DetailRelController consIds.get(0).ConstituentId__c' + consIds.get(0).ConstituentId__c);
            //consId = consIds.get(0).ConstituentId__c;
        }
    }
    
    public void prevPage() {
        startRow -= pageSize;
        endRow = startRow + pageSize - 1;
        getPage();
    }
    
    public void nextPage() {
        startRow += pageSize;
        endRow = startRow + pageSize - 1;
        getPage();
    }
    
	private void getPage() {
		System.debug('getPage startRow: ' + startRow + ', endRow: ' + endRow);
        
        soapStjudeOrg.GetRelationshipsResponse_element resp = C360Util.getRelationships(consId, startRow, endRow);
        if (resp.TotalResults == null) {
            totalResults = 0;
            rels = new domainSoapStjudeOrg.Relationship[] {};
        }
        else {
            if (totalResults == 0) totalResults = resp.TotalResults;
            rels = resp.Relationships;
        }
	}
    
    public void changeCons() {
        startRow = 1;
        endRow = startRow + pageSize - 1;
        totalResults = 0;
        getPage();
    }
    
    public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
    }

    public PageReference SelectConstituent() {
        if (ci.objectType == 'Case') {
            System.debug('SelectUUID: ' + ApexPages.currentPage().getParameters().get('SelectUUID') +
                         ', SelectRelConsID: ' + ApexPages.currentPage().getParameters().get('SelectRelConsID') +
                         ', SelectName: ' + ApexPages.currentPage().getParameters().get('SelectName') +
                         ', SelectConType: ' + ApexPages.currentPage().getParameters().get('SelectConType'));

            String consName = ApexPages.currentPage().getParameters().get('SelectName');
            String consType = ApexPages.currentPage().getParameters().get('SelectConType');
            String selectUUID = ApexPages.currentPage().getParameters().get('SelectUUID');
            String selectRelConsID = ApexPages.currentPage().getParameters().get('SelectRelConsID');
            String selectConsId = ApexPages.currentPage().getParameters().get('SelectConsId');
            
            ECCUtil.setCaseConstituent(ECCUtil.getCurrCase(relId).get(0), selectUUID, consName, consType, selectRelConsID, selectConsId);

            return Page.C360CloseRefresh;
        }
        else return null;
    }

    /*public PageReference DeactivateRelationship() {
        //edit status of relationship
        return null;
    }*/

    public PageReference NewRelationship() {
        //going to load search and send the related constituent id
        //  search and create constituent will add the related contact when selecting or creating
        //  the constituent
        PageReference newItem = Page.C360ConstituentAdd; 
        system.debug('id: ' + relId);
        newItem.setRedirect(true);
        newItem.getParameters().put('relId', relid);
        newItem.getParameters().put('relConsId', consId);
        newItem.getParameters().put('relConsType', consType);
        newItem.setRedirect(true);
        return newItem;
    }
}