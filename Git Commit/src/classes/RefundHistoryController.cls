public with sharing class RefundHistoryController {
    public List<Refund_Request__c> refHist = new List<Refund_Request__c>();
    public integer currPage {get; private Set;}
    public Integer totalPages {get; private Set;}
    public Boolean hasRefHistory {get; private Set;}

    private Case currCase;
    private String caseId = '';
    private Boolean isConsIdSet = false;

    private Integer pageSize = 5;
    
    public List<Refund_Request__c> getRefHist() {
        return refHist;
    }
    
    public RefundHistoryController(ApexPages.StandardController controller) {
        currPage = 1;
        totalPages = 0;
        hasRefHistory = false;
        
        caseId = System.currentPageReference().getParameters().get('id');
        system.debug(caseId);
        currCase = ECCUtil.getCurrCase(caseId).get(0);
        system.debug(currCase.ConstituentID__c);
        if (currCase.ConstituentID__c == null) {
            isConsIdSet = false;
        }
        else {
            isConsIdSet = true;
            GetPage();
        }
    }
    
    public PageReference nextPage() {
        if (currPage < totalPages) {
            currPage++;
            GetPage();
        }
        return null;        
    }
    
    public PageReference prevPage() {
        if (currPage > 1) {
            currPage--;
            GetPage();
        }
        return null;
    }
    
    public void GetPage() {
        System.debug('GetPage()');
        System.debug('currcase consId: ' + currCase.ConstituentID__c);
        System.debug('caseId: ' + caseId);
        
        LIST<Refund_Request__c> allRefHist = [
            select 
                Id,
                Name, 
                TotalRefundAmount__c, 
                DonorName__c, 
                Request_Age__c, 
                RefundStatus__c
            from Refund_Request__c 
            where 
                ConstituentID__c = :currCase.ConstituentID__c
            order by CreatedDate desc];
        
        System.debug('items: ' + allRefHist.size());
        System.debug('totalPages: ' + totalPages);
        System.debug('pageSize: ' + pageSize);
        
        if (allRefHist.size() > 0) {
            hasRefHistory = true;
            totalPages =  integer.valueOf(string.valueOf(Math.ceil(allRefHist.size() / pageSize)));
            
            Integer i;
            refHist = new List<Refund_Request__c>();
            for(i = (currPage - 1) * pageSize; i < currPage * pageSize && i < allRefHist.size(); i++) {
                System.debug(i);
                refHist.add(allRefHist.get(i));
            }
            System.debug('GetPage() exit');
        }
    }
}