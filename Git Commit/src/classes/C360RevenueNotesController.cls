global with sharing class C360RevenueNotesController{
	public List<domainSoapStjudeOrg.RevenueNote> revNotesList  {get; set;}
    public string consId {get; private set;}
    public string transId {get; private set;}
    public integer currPage {get; private Set;}
	public Integer totalPages {get; private Set;}
	private Integer pageSize = 5;
    public soapStjudeOrg.GetTransactionsResponse_element con {get; set;} 
    private Integer totalItems = 0;
    private LIST<ConstituentInformation__c> consIds;
    public boolean isRevenueNotes {get; set;}
    private Boolean isConsIdSet = false;
    
    public C360RevenueNotesController.C360RevenueNotesController() {
        init();
    }

    public C360RevenueNotesController(ApexPages.StandardController controller) {
        init();
    }

	public List<domainSoapStjudeOrg.RevenueNote> getRevenueNotesList() {
		return revNotesList;
	}

    private void init() {
    	currPage = 1;
		totalPages = 0;
        consId = System.currentPageReference().getParameters().get('consId');
        system.debug('consId = ' + consId);
        transId = System.currentPageReference().getParameters().get('transId');
        system.debug('transId = ' + transId);
        integer startRow = 1;
        integer endRow = 100;  //Check with Josh
        String sortOrder = 'GIFT_DESC';
     // con = C360Util.getRevenueNotes('72D5CCB2-3B65-4ADD-9FD0-01286F48DC77', '9EB6B204-2F9B-4E02-A96C-000059DA4938' , startRow, endRow, sortOrder );
        con = C360Util.getRevenueNotes(consId, transId , startRow, endRow, sortOrder );
        system.debug('con rev = ' + con);

        // check null and size
        if(con.Transactions != null && con.Transactions.size() > 0 ){
             system.debug('con.Transactions[0] =');
            if (con.Transactions[0].RevenueNotes == null) { 
                    isRevenueNotes = false;
                }
                else { 
                    isRevenueNotes = true;  
                    GetPage();
                }
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
    		  if(con.Transactions != null && con.Transactions.size() > 0 ){
                System.debug('GetPage()');  
                System.debug('items: ' + con.Transactions[0].RevenueNotes.size());
                System.debug('pageSize: ' + pageSize);
                if (con.Transactions[0].RevenueNotes.size() > 0) {
                totalPages =  integer.valueOf(string.valueOf(Math.ceil(double.valueOf(con.Transactions[0].RevenueNotes.size()) / double.valueOf(pageSize))));
                System.debug('totalPages: ' + totalPages);
                Integer i;
                revNotesList = new List<domainSoapStjudeOrg.RevenueNote>();
                for(i = (currPage - 1) * pageSize; i < currPage * pageSize && i < con.Transactions[0].RevenueNotes.size(); i++) {
                    System.debug('i =' + i);
                    revNotesList.add(con.Transactions[0].RevenueNotes.get(i));
                    system.debug('revNotesList = ' + revNotesList);
                }
                System.debug('GetPage() exit');
            }
         }
		
	
}

 @RemoteAction
    global static soapStjudeOrg.GetTransactionsResponse_element getTransactionPage(string consIdt, string transIdt, integer startRow, integer endRow) {
        try {
            objectSoapStjudeOrg.TxnFilter filt = new objectSoapStjudeOrg.TxnFilter();
        	filt.FinancialTxnID = transIdt;
        	system.debug('calling getTransactions');
            soapStjudeOrg.GetTransactionsResponse_element res = C360Util.getTransations(null, consIdt, startRow, endRow, 'REVENUE_NOTES', 'GIFT_DESC', filt, 'DMS'); 
            system.debug('returning res: ' + res.TotalResults);
            system.debug('returning res count: ' + (res.Transactions != null ? res.Transactions.Size() : 0));
            return res;
        }
        catch(Exception e) {
            system.debug(e.getMessage());
            return new soapStjudeOrg.GetTransactionsResponse_element();
        }
    }
}