global with sharing class C360TransactionDetailController{
    public String relId {get; private set;}
    public String relIdType {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public boolean isUUIDSet {get; set;}
    public String consId {get; set;}
    public Integer currPage {get; private Set;}
    public Integer totalPages {get; private Set;}
    public String loadedMethod { get; set;}
    public soapStjudeOrg.GetTransactionsResponse_element trans {get; private set;}
    public String transList {get; private set;}
    
    private Integer pageSize = 15;
    private LIST<ConstituentInformation__c> consIds;
    public domainSoapStjudeOrg.Constituent constituent {get; private set;}
    //If lead
    public Lead currLead {get; private set;}
    //If case
    public Case currCase {get; private set;}
    
    public C360TransactionDetailController() {
        init();
    }

    public C360TransactionDetailController(ApexPages.StandardController controller) {
        init();
    }

    private void init() {
        relId = System.currentPageReference().getParameters().get('id');
        System.debug('relId = ' + relId);

        ci = new ECCUtil.consInfo();
        if (relId != null){
            currPage = 1;
            totalPages = 0;  
            relIdType = ECCUtil.getTypeById(relId);         
            System.debug('relIdType = ' + relIdType);
            if (relIdType == 'Case'){
                currCase = ECCUtil.getCurrCase(relId).get(0);
                consId = currCase.ConstituentID__c;
            }
            else if (relIdType == 'Lead'){
                currLead = ECCUtil.getCurrLead(relId).SSLead;
                consId = currLead.ConstituentID__c;
            }
        }
        System.debug('about to getConstituent with : ' + consId);
        constituent = C360Util.getConstituent(null, 
                                            consId, 
                                            null, 
                                            'DMS', 
                                            new string[] {'PROFILE', 'PROPERTIES', 'INTERACTIONS', 'FINANCIAL_PROFILE_ROLLUP', 'PREFERENCES', 'REVENUE_NOTES'},
                                            'ALL');
        System.debug('gotConstituent');
        if (constituent != null){
            isUUIDSet = true;
            ci.objectId = relId;
            ci.objectType = relIdType;
            ci.consId = constituent.ConstituentID;
            ci.consType = constituent.Type_x.Code;
            if (ci.objectType == 'Lead'){
                ci.technique = currLead.Technique_Method__c;
            }
            else if (ci.objectType == 'Case'){
                ci.technique = currCase.Technique_Method__c;
            }
            transList = parseTransIds(constituent);
        }
        else{
            isUUIDSet = false;
        }

        System.debug(ci);
        consIds = ECCUtil.getConstituentInformationByConsInfo(ci);
        
        System.debug('C360TransactionDetailController(), loadedMethod: ' + loadedMethod);
    }

    public String parseTransIds(domainSoapStjudeOrg.Constituent trans){
        List<String> revNotes = new List<String>();
        String s;

        if (trans.Transactions != null && trans.Transactions.size() > 0){
            for (domainSoapStjudeOrg.Transaction_x t : trans.Transactions){
                revNotes.add(t.FinancialTransactionId);
            }
        }
        else{
            revNotes.add('No Transactions with REVENUE_NOTES');
        }
        System.debug('Transactions with revNotes are: ' + revNotes);
        s = JSON.serialize(revNotes);
        System.debug('converted to JSON : ' + s);
        return s;
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
    global static String addSoftCreditItems(String jsonDeets, String sfcReason, String softCreditRequest, String relId, String consId, String objectType) {
        List<domainSoapStjudeOrg.Transaction_x> trans = (List<domainSoapStjudeOrg.Transaction_x>)System.JSON.deserialize(jsonDeets, List<domainSoapStjudeOrg.Transaction_x>.class);
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
    global static String addMoveGifts(String jsonDeets, String crtAccount, String moveGift, String relId, String amt, String objectType) {
        System.debug('addMoveGifts ');
        List<domainSoapStjudeOrg.Transaction_x> trans = (List<domainSoapStjudeOrg.Transaction_x>)System.JSON.deserialize(jsonDeets, List<domainSoapStjudeOrg.Transaction_x>.class);
        System.debug('trans = ' + trans);
        Move_Gift__c mgft ;
        List<Move_Gift_Detail__c> mgftds = new List<Move_Gift_Detail__c>();

        String wrngAccount = '';

        if (string.isBlank(moveGift)) mgft = new Move_Gift__c(
                case_related__c = (objectType == 'Case' ? relId : null),         
                Correct_account__c = crtAccount,
                Request_Status__c = 'Unsubmitted',
                related_lead__c = (objectType == 'Case' ? null : relId), 
                Wrong_account__c = wrngAccount);
                        
        system.debug('******trans'+trans);
        if (trans != null && trans.size() > 0) {
            system.debug('size: ' + trans.size());

            for(domainSoapStjudeOrg.Transaction_x t : trans) {
                DateTime gd = t.GiftDate; //ECCUtil.JavaDateStringToDate(t.GiftDate);
                Move_Gift_Detail__c mgfd = new Move_Gift_Detail__c(
                           Gift_Type__c = t.GiftType,
                           Gift_Kind__c = t.TransactionType,
                            Payment_Amount__c = t.PaymentAmount,
                            Pledge_Amount__c = t.TotalPledgeAmount,
                            Source_Code__c = t.TransactionSource != null ? t.TransactionSource.Code : null,
                            Transaction_Date__c = gd != null ? 
                                date.newinstance(gd.year(), gd.month(), gd.day()) :
                                null,
                            Payment_Method__c = t.PaymentDetail != null ? t.PaymentDetail.PaymentMethod : null,
                            Unique_Transaction_Identifier__c = t.TransactionXRef.TxnXRefKey
                    );

                system.debug('******Transaction'+mgfd);
                mgftds.add(mgfd);
                
                 //Add Soft Credit in Soft Credit request from selected single transaction
                 mgft.payment_gift_amount__c = t.PaymentAmount != null ? t.PaymentAmount : null;
                 mgft.Gift_amount__c = t.PaymentAmount != null ? t.PaymentAmount : null;
            }
        }
    
        if (mgft != null) insert mgft;

        for (Move_Gift_Detail__c mgfd : mgftds) {
            mgfd.Related_Move_Gift__c = mgft != null ? mgft.id : moveGift;
        }
        insert mgftds; 

        return mgft != null ? mgft.id : moveGift;
    } 

    @RemoteAction
    global static soapStjudeOrg.GetTransactionsResponse_element getTransactionPage(string consId, integer startRow, integer endRow) {
        try {
            objectSoapStJudeOrg.TxnFilter filt = new objectSoapStJudeOrg.TxnFilter();
            filt.HouseholdView = true;
            system.debug('calling getTransactions');
            soapStjudeOrg.GetTransactionsResponse_element res = C360Util.getTransations(null, consId, startRow, endRow, null, 'GIFT_DESC', filt, 'TA'); 
            //soapStjudeOrg.GetTransactionsResponse_element res = C360Util.getTransations(null, consId, startRow, endRow, 'DIRECT_ALL', 'GIFT_DESC', filt, 'TA'); 
            //soapStjudeOrg.GetTransactionsResponse_element res = C360Util.getTransations(null, consId, startRow, endRow, 'RECOGNITIONS', 'GIFT_DESC', filt, 'TA'); 
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
    }  // New Code Added 
    
       @RemoteAction

global static List<Move_Gift_Detail__c> getMoveGift(String relId) {
        return [
            select 
                id, Unique_Transaction_Identifier__c,Related_Move_Gift__r.Request_status__c
            from 
                Move_Gift_Detail__c
            where
                (Related_Move_Gift__r.case_related__c = :relId
                or Related_Move_Gift__r.related_lead__c = :relId)
            and Related_Move_Gift__r.Request_Status__c != 'Unsubmitted'
                and Unique_Transaction_Identifier__c != null
            ];
    }     


    public string getMavro() {
        return C360Settings__c.getInstance('Mavro').C360SettingsURL__c;
    }
}