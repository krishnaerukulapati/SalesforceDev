global with sharing class C360TransDetailCont {
	public TransactionViewModel viewModel {get; private set;}

	public C360TransDetailCont(){
		System.debug('in constructor');
		viewModel = new TransactionViewModel();
		viewModel.relId = System.currentPageReference().getParameters().get('id');
		System.debug('viewModel.relId = ' + viewModel.relId);
	}

	public Continuation reLoad(){
		System.debug('in reLoad');
		Long startMs = Datetime.now().getTime();
		String consId;

		Continuation continuation = new Continuation(viewModel.TIMEOUT_INT_SECS);
        continuation.continuationMethod = 'gotConstituent';

        viewModel.relIdType = ECCUtil.getTypeById(viewModel.relId);
		System.debug('viewModel.relIdType = ' + viewModel.relIdType);
		if (viewModel.relIdType == 'Case'){
			viewModel.currCase = ECCUtil.getCurrCase(viewModel.relId).get(0);
			consId = viewModel.currCase.ConstituentID__c;
		}
		else if (viewModel.relIdType == 'Lead'){
			viewModel.currLead = ECCUtil.getCurrLead(viewModel.relId).SSLead;
			consId = viewModel.currLead.ConstituentID__c;
		}

		if (consId != null) {
			viewModel.ConstituentResponse = AsyncC360Util.getConstituent(continuation, 
                                                        null, 
                                                        consId,
                                                        null,
                                                        'DMS', 
                                                        new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'}, 
                                                        'ALL');
		}
		System.debug('sent the request');
		//output
		Long endMs = DateTime.now().getTime();
		system.debug('================== Reload() RUNTIME ================== ' + (endMs - startMs) + ' ms');
        return continuation;
	}

	public Object gotConstituent(){
		//put things that require constituent info only
		System.debug('gotConstituent: ' + DateTime.now());

		if (viewModel.relId != null && viewModel.ConstituentResponse != null){
			//Pull Constituent out of response
			viewModel.Constituent = viewModel.ConstituentResponse.getValue().Constituent;
			System.debug('viewModel.Constituent = ' + viewModel.Constituent);
			//Manipulate Constituent results into useable data
			viewModel.ci = assignConsToCi();
			System.debug('viewModel.ci = ' + viewModel.ci);
			viewModel.consIds = getConsIds(viewModel.ci);
			System.debug('viewModel.consIds = ' + viewModel.consIds);

			viewModel.IsConstituentLoaded = true;
		}
		return null;
	}

 	private ECCUtil.consInfo assignConsToCi(){
 		ECCUtil.consInfo consInfo = new ECCUtil.consInfo();
 		consInfo.objectId = viewModel.relId;
		consInfo.objectType = viewModel.relIdType;
		consInfo.consId = viewModel.Constituent.ConstituentID;
		consInfo.consType = viewModel.Constituent.Type_x.Code;

		if (consInfo.objectType == 'Lead'){
			consInfo.technique = viewModel.currLead.Technique_Method__c;
		}
		else if (consInfo.objectType == 'Case'){
			consInfo.technique = viewModel.currCase.Technique_Method__c;
		}
		return consInfo;
 	}

 	private LIST<ConstituentInformation__c> getConsIds(ECCUtil.consInfo ci){
 		List<ConstituentInformation__c> coninfo = new List<ConstituentInformation__c>();
 		coninfo = ECCUtil.getConstituentInformationByConsInfo(ci);
 		return coninfo;
 	}

 	public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(viewModel.consIds);
    }

    //Beginning of copy pasted code

    public string getSourceURL() {
        return C360Settings__c.getInstance('SOURCE').C360SettingsURL__c;
    }

     @RemoteAction
    global static String addRefundRequestItems(String jsonDeets, String reason, String refundRequestId, 
        String relId, String consId, String objectType) {
        List<domainSoapStjudeOrg.Transaction_x> trans = 
            (List<domainSoapStjudeOrg.Transaction_x>)System.JSON.deserialize(
                jsonDeets, List<domainSoapStjudeOrg.Transaction_x>.class);
        Refund_Request__c rr;
        List<Refund_Detail__c> rds = new List<Refund_Detail__c>();

        if (string.isBlank(refundRequestId)) rr = new Refund_Request__c(
                        ReasonForRefund__c = reason,
                        Case__c = (objectType == 'Case' ? relId : null),
                        Lead__c = (objectType == 'Case' ? null : relId),  
                        ConstituentID__c = consId);

        if (trans != null && trans.size() > 0) {
            domainSoapStjudeOrg.Transaction_x tran0 = trans.get(0);
            if (tran0.PaymentDetail != null && tran0.PaymentDetail.CCLast4 != null) {
                system.debug('cclast4: ' + tran0.PaymentDetail.CCLast4);
                rr.RefundType__c = 'Credit Card';
                rr.Last4DigitsOfCC__c = tran0.PaymentDetail.CCLast4;
            }

            system.debug('size: ' + trans.size());
            for(domainSoapStjudeOrg.Transaction_x t : trans) {
                DateTime gd = t.GiftDate; //ECCUtil.JavaDateStringToDate(t.GiftDate);
                Refund_Detail__c rd = new Refund_Detail__c(
                            Gift_Type__c = t.GiftType,
                            Payment_Amount__c  = t.PaymentAmount,
                            Payment_Method__c = t.PaymentDetail != null ? t.PaymentDetail.PaymentMethod : null,
                            Pledge_Amount__c = t.TotalPledgeAmount,
                            Source_Code__c = t.TransactionSource != null ? t.TransactionSource.Code : null,
                            Transaction_Date__c = gd != null ? 
                                date.newinstance(gd.year(), gd.month(), gd.day()) :
                                null,
                            Unique_Transaction_Identifier__c = t.TransactionXRef.TxnXRefKey
                    );

                rds.add(rd);
                system.debug(rd.Pledge_Amount__c);
            }
        }
            
        if (rr != null) insert rr;

        for (Refund_Detail__c rd : rds) {
            rd.Refund_Request_ID__c = rr != null ? rr.id : refundRequestId;
        }
        insert rds;

        return rr != null ? rr.id : refundRequestId;
    }
    
    @RemoteAction
    global static String addSourceCodeChangeItems(String jsonDeets, String scReason, String sourceCodeChangeRequestId, 
        String relId, String consId, String objectType) {
        List<domainSoapStjudeOrg.Transaction_x> trans = 
            (List<domainSoapStjudeOrg.Transaction_x>)System.JSON.deserialize(
                jsonDeets, List<domainSoapStjudeOrg.Transaction_x>.class);
        Source_Code_Change_Request__c sc;
        List<Source_Code_Detail__c> scds = new List<Source_Code_Detail__c>();

        if (string.isBlank(sourceCodeChangeRequestId)) sc = new Source_Code_Change_Request__c(
                        Reason_for_Request__c = scReason,
                        Related_Case__c = (objectType == 'Case' ? relId : null),                  
                        Lead__c = (objectType == 'Case' ? null : relId),                
                        Request_Status__c = 'Unsubmitted',
                        Constituent_ID__c = consId);
                        
        system.debug('******trans'+trans);
        if (trans != null && trans.size() > 0) {
            system.debug('size: ' + trans.size());
            for(domainSoapStjudeOrg.Transaction_x t : trans) {
                DateTime gd = t.GiftDate; //ECCUtil.JavaDateStringToDate(t.GiftDate);
                Source_Code_Detail__c scd = new Source_Code_Detail__c(
                            Gift_Type__c = t.GiftType,
                            Gift_Kind__c = t.TransactionType,
                            Payment_Amount__c = t.PaymentAmount,
                            Payment_Method__c = t.PaymentDetail != null ? t.PaymentDetail.PaymentMethod : null,
                            Pledge_Amount__c = t.TotalPledgeAmount,
                            Source_Code__c = t.TransactionSource != null ? t.TransactionSource.Code : null,
                            Transaction_Date__c = gd != null ? date.newinstance(gd.year(), gd.month(), gd.day()) : null,
                            Unique_Transaction_Identifier__c = t.TransactionXRef.TxnXRefKey
                    );

                system.debug('******Transaction'+scd);
                scds.add(scd);
                
                //Add Source Code in Source code change request from selected single transaction
                sc.Detail_Existing_Code__c = t.TransactionSource != null ? t.TransactionSource.Code : null;
               // system.debug(rd.Pledge_Amount__c);
            }
        }
    
        if (sc != null) insert sc;

        for (Source_Code_Detail__c sd : scds) {
            sd.Source_Code_Change_Request_ID__c = sc != null ? sc.id : sourceCodeChangeRequestId;
        }
        insert scds;

        return sc != null ? sc.id : sourceCodeChangeRequestId;
    }    

    @RemoteAction
    global static String addSoftCreditItems(String jsonDeets, String sfcReason, String softCreditRequest, 
        String relId, String consId, String objectType) {
        List<domainSoapStjudeOrg.Transaction_x> trans = 
            (List<domainSoapStjudeOrg.Transaction_x>)System.JSON.deserialize(
                jsonDeets, List<domainSoapStjudeOrg.Transaction_x>.class);
        Soft_Credit_Request__c sfc;
        List<Soft_Credit_Detail__c> sfcds = new List<Soft_Credit_Detail__c>();

        if (string.isBlank(softCreditRequest)) sfc = new Soft_Credit_Request__c(
                        Reason_for_Request__c = sfcReason,
                        Related_Case__c = (objectType == 'Case' ? relId : null),                      
                        Lead__c = (objectType == 'Case' ? null : relId),                      
                        Request_Status__c = 'Unsubmitted',
                        Constituent_ID__c = consId);
                        
        system.debug('******trans'+trans);
        if (trans != null && trans.size() > 0) {
            system.debug('size: ' + trans.size());

            for(domainSoapStjudeOrg.Transaction_x t : trans) {
                DateTime gd = t.GiftDate; //ECCUtil.JavaDateStringToDate(t.GiftDate);
                Soft_Credit_Detail__c sfd = new Soft_Credit_Detail__c(
                            Gift_Type__c = t.GiftType,
                            Gift_Kind__c = t.TransactionType,
                            Payment_Amount__c = t.PaymentAmount,
                            Payment_Method__c = t.PaymentDetail != null ? t.PaymentDetail.PaymentMethod : null,
                            Unique_Transaction_Identifier__c = t.TransactionXRef.TxnXRefKey
                    );

                system.debug('******Transaction'+sfd);
                sfcds.add(sfd);
                
                 //Add Soft Credit in Soft Credit request from selected single transaction
                 sfc.Payment_Amount__c = t.PaymentAmount != null ? t.PaymentAmount : null;
                 sfc.Amount_to_Apply__c = t.PaymentAmount != null ? t.PaymentAmount : null;
            }
        }
    
        if (sfc != null) insert sfc;

        for (Soft_Credit_Detail__c sfd : sfcds) {
            sfd.Related_Soft_Credit_Request__c = sfc != null ? sfc.id : softCreditRequest;
        }
        insert sfcds; 

        return sfc != null ? sfc.id : softCreditRequest;
    }   

    @RemoteAction
    global static soapStjudeOrg.GetTransactionsResponse_element getTransactionPage(string consId, integer startRow, integer endRow) {
        try {
            objectSoapStJudeOrg.TxnFilter filt = new objectSoapStJudeOrg.TxnFilter();
            filt.HouseholdView = true;
            system.debug('calling getTransactions');
            soapStjudeOrg.GetTransactionsResponse_element res = C360Util.getTransations(null, consId, startRow, endRow, 'DIRECT_ALL', 'GIFT_DESC', 
                filt, 'TA'); 
            system.debug('returning res: ' + res.TotalResults);
            system.debug('returning res count: ' + (res.Transactions != null ? res.Transactions.Size() : 0));
            return res;
        }
        catch(Exception e) {
            system.debug(e.getMessage());
            return new soapStjudeOrg.GetTransactionsResponse_element();
        }
    }

    @RemoteAction
    global static List<ConstituentRevenueNotes__x> getRevenueNotesPage(string consId, integer startRow) {
        try {
            System.debug('Inside getRevenueNotesPage');
            system.debug('getRevenueNotesPage, consid: ' + consid + ', startrow: ' + startRow);
            return OdataExtension.GetRevenueNotes(consId, startRow, 1000);
        }
        catch(Exception e) {
            system.debug(e.getMessage());
            return new List<ConstituentRevenueNotes__x>();
        }
    }

    @RemoteAction
    global static List<Refund_Detail__c> getRefunds(String relId) {
        System.debug('Inside getRefunds');
        return [
            select 
                id, Unique_Transaction_Identifier__c, Refund_Request_ID__r.RefundStatus__c
            from 
                Refund_Detail__c 
            where
                (Refund_Request_ID__r.Case__c = :relId
                or Refund_Request_ID__r.Lead__c = :relId)
                and Refund_Request_ID__r.RefundStatus__c != 'Rejected'
                and Unique_Transaction_Identifier__c != null];
    }
    
    @RemoteAction
    global static List<Source_Code_Detail__c> getSource(String relId) {
        return [
            select 
                id, Unique_Transaction_Identifier__c, Source_Code_Change_Request_ID__r.Request_Status__c
            from 
                Source_Code_Detail__c
            where
                (Source_Code_Change_Request_ID__r.Related_Case__c= :relId
                or Source_Code_Change_Request_ID__r.Lead__c = :relId)
                and Source_Code_Change_Request_ID__r.Request_Status__c!= 'Unsubmitted'
                and Unique_Transaction_Identifier__c != null
            ];
    } 

    @RemoteAction
    global static List<Soft_Credit_Detail__c> getSoftCredit(String relId) {
        return [
            select 
                id, Unique_Transaction_Identifier__c,Related_Soft_Credit_Request__r.Request_Status__c
            from 
                Soft_Credit_Detail__c
            where
                (Related_Soft_Credit_Request__r.Related_Case__c = :relId
                or Related_Soft_Credit_Request__r.Lead__c = :relId)
                and Related_Soft_Credit_Request__r.Request_Status__c != 'Unsubmitted'
                and Unique_Transaction_Identifier__c != null
            ];
    }   // New Code Added 

    public string getMavro() {
        return C360Settings__c.getInstance('Mavro').C360SettingsURL__c;
    }

    //ViewModel

	public Class TransactionViewModel{
	
		//Constituent Information
    	AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture ConstituentResponse;
    	public boolean IsConstituentLoaded { get; private set; }
		public domainSoapStjudeorg.Constituent Constituent {get; private set;}
		public ECCUtil.consInfo ci {get; private set;}
    	public String consId {get; set;}
    	private LIST<ConstituentInformation__c> consIds;

    	public String relId {get; set;}
   		public String relIdType {get; set;}

    	public boolean isUUIDSet {get; set;}

    	public Integer currPage {get; private Set;}
    	public Integer totalPages {get; private Set;}
    	public String loadedMethod { get; set;}
    	public soapStjudeOrg.GetTransactionsResponse_element trans {get; private set;}

    	private Integer pageSize = 15;
    	Integer TIMEOUT_INT_SECS = 60;
    	//If Lead
    	public Lead currLead {get; private set;}
    	//If Case
    	public Case currCase {get; private set;}
	}
}