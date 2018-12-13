global with sharing class FOTransactionDetailController{
    public String relId {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
    public String consId {get; set;}
    public Integer currPage {get; private Set;}
    public Integer totalPages {get; private Set;}
    public String loadedMethod { get; set;}
    public soapStjudeOrg.GetTransactionsResponse_element trans {get; private set;}
    
    private Integer pageSize = 15;
    private LIST<ConstituentInformation__c> consIds;
    
    public FOTransactionDetailController() {
        init();
    }

    public FOTransactionDetailController(ApexPages.StandardController controller) {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');

        system.debug(relId);
        system.debug('FOTransactionDetailController(), loadedMethod: ' + loadedMethod);

        if (String.isNotEmpty(relId)) {
            ci = ECCutil.getConsInfo(relId);
            system.debug('consId: ' + ci.consId);
            currPage = 1;
            totalPages = 0;
            if (ci.consId == null) {
                isUUIDSet = false;
            }
            else {
                isUUIDSet = true;
                consIds = ECCUtil.getConstituentInformationByConsInfo(ci);
                consId = ci.consId;
            }
        }
    }

    public void changeCons() {
    }

    public LIST<SelectOption> getItems() {
        return ECCUtil.getConstituentIdsForSelect(consIds);
    }

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
               // rr.Current_Refund_Amount__c = t.PaymentAmount != null ? t.PaymentAmount : null;
         
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
                filt, 'DMS'); 
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
    global static List<Refund_Detail__c> getRefunds(String relId) {
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
}