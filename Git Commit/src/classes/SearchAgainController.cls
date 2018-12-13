public with sharing class SearchAgainController {
    public String caseId {get; private set;}

    public SearchAgainController(ApexPages.StandardController controller) {
        init();
    }

    public SearchAgainController() {
        init();
    }

    private void init () {
    	//caseId = $CurrentPage.parameters.cid;
    	caseId = ApexPages.currentPage().getParameters().get('cid');
    	ECCUtil.clearCons(caseId);
    }

    public PageReference changeCons() {
        
        ECCUtil.clearCons(caseId);
        
        PageReference pr = Page.C360Search;
        pr.setRedirect(true);
        pr.getParameters().put('cid', caseId);
        return pr;
    }


}