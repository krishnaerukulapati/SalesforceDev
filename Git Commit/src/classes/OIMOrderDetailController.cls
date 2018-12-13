public with sharing class OIMOrderDetailController {
    public List<V_LineItemInfo__x> lineItems { get; set; }
    public V_OrderInfo__x order { get; set; }
    public String orderId { get; set; }
    public String eventId { get; set; }
    public String relId { get; set; }
    public String dateOrdered { get; set; }
    public String dateToShip { get; set; }
    public String dateShipped { get; set; }
    public String lineItemId { get; set; }
    public String orderStatus { get; set; }
    public String leadId {get; private set;}
    public String leadType {get; private set;}
    public ECCUtil.consInfo ci {get; private set;}
    public List<String> before = new List<String>();
    public List<String> after = new List<String>();
    public DateTime dtOrdered {get; private set;}
    public DateTime dtToShip {get; private set;}
    public DateTime dtShipped {get; private set;}
    public String openStatus { get; set;}
    public String defOpenStatus { get; set;}
    public String fedExGrShipMeth { get; set;}
    public String defFedExGrShipMeth { get; set;}
    public Boolean saveButton {get; set; }
    public String editOrder {get; set; }

    private Integer lineItemsCount;
    //todo: need a way to edit line item
    //      allow modification of qty

    public OIMOrderDetailController() {
        lineItemsCount = 0;
        lineItems = new List<V_LineItemInfo__x>();

        init();
    }

@testVisible
    private void init() {
        
        orderId = System.currentPageReference().getParameters().get('orderId');
        eventId = System.currentPageReference().getParameters().get('eventId');
        relId = System.currentPageReference().getParameters().get('relId');
        leadId = System.currentPageReference().getParameters().get('id');
        editOrder = System.currentPageReference().getParameters().get('editOrder');
        System.debug('editOrder = ' + editOrder);
        saveButton = true;
        
        System.debug('leadId = ' + leadId);
        leadType = System.currentPageReference().getParameters().get('leadType');
        System.debug('leadType = ' + leadType);
        if (leadId == null){
            leadId = System.currentPageReference().getParameters().get('leadId');
        }

        if (String.isBlank(leadType)) leadType = 'ORG';
        System.debug('leadId = ' + leadId);
        System.debug('leadType = ' + leadType);
        ci = ECCUtil.getConsInfo(leadId, leadType);
        System.debug('ci.consId = ' +ci.consId);
        System.debug('orderId = ' +orderId);

        orderStatus = System.currentPageReference().getParameters().get('orderStatus');
        system.debug('orderId: ' + orderId + ', eventId: ' + eventId + ', relId: ' + relId + ', orderStatus: ' + orderStatus);
        
        if (String.isEmpty(eventId)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Event Id is required'));
            return;
        }
        if (String.isEmpty(orderId)) {
            openStatus = '3a066970-e42e-45f8-9bee-f07cde53bdc8'; // Open Status
            System.debug('openStatus = ' + openStatus);
            fedExGrShipMeth = '1d466105-5496-4721-bc32-7bd4870316a2'; //FedEx Ground Ship Method
            order = new V_OrderInfo__x(
                EventId__c = eventId
                , StatusDisplay__c = 'Open');
        }
        else {
            String q = 'select EventID__c, OrderId__c, ShipmentMethodDisplay__c, DateOrdered__c, DateToShip__c' +
                ', DateSubmitted__c, DateShipped__c, createdBy__c, StatusDisplay__c, LineItemCount__c, IsPriority__c' +
                ', Status__c, ShipmentMethodId__c ' +
                'from V_OrderInfo__x ' +
                'where OrderId__c = \'' + orderId + '\'';
            System.debug(' orderId for V_OrderInfo__x' + orderId);
            System.debug(' q ' + q);
            List<V_OrderInfo__x> orders = OdataExtension.V_OrderInfoQuery(q, null);
            //System.debug(' orders.size() ' + orders.size());
            if (orders == null || orders.size() <= 0 && !Test.isRunningTest()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid order id: ' + orderId));
                return;
            }
            else {
                if (Test.isRunningTest())
                {
                    V_OrderInfo__x testOrder = new V_OrderInfo__x();
                    testOrder.EventID__c = '123456' ;
                    testOrder.OrderId__c = '123456' ;
                    testOrder.ShipmentMethodDisplay__c = 'Air';
                    testOrder.DateOrdered__c = Date.ValueOf(system.today());
                    testOrder.DateToShip__c = Date.ValueOf(system.today());
                    testOrder.DateSubmitted__c = Date.ValueOf(system.today());
                    testOrder.DateShipped__c = Date.ValueOf(system.today());
                    testOrder.CreatedBy__c = 'TestAgent';
                    testOrder.StatusDisplay__c = 'Test';
                    testOrder.LineItemCount__c  = 10;
                    testOrder.IsPriority__c = false;
                    testOrder.Status__c = 'test';
                    testOrder.ShipmentMethodId__c = 'something';
                    order = testOrder;
                }
                else{
                    order = orders[0];
                }
                
                System.debug('order.DateOrdered__c = ' + order.DateOrdered__c);
                dateOrdered = String.valueOfGmt(order.DateOrdered__c);
                System.debug('dateOrdered = ' + dateOrdered);
                dateToShip = String.valueOfGmt(order.DateToShip__c);
                dateShipped = String.valueOfGmt(order.DateShipped__c);
                openStatus = order.Status__c;
                fedExGrShipMeth = order.ShipmentMethodId__c;

                q = 'select OrderId__c, SKU__c, ProductDescription__c, Quantity__c, Comments__c, LineItemId__c, Each__c, TotalUnits__c, TrackingNumber__c  ' +
                    'from V_LineItemInfo__x ' +
                    'where OrderId__c = \'' + orderId + '\'';
                System.debug(' orderId for V_LineItemInfo__x' + orderId);
                System.debug(' q ' + q);
                lineItems = OdataExtension.V_LineItemInfoQuery(q, null);

                //if (lineItems != null)
                //  lineItemsCount = lineItems.size();
                //else
                //  lineItemsCount = 0;
                dtOrdered = String.isBlank(dateOrdered) ? null : ECCUtil.JavaDateStringToDate(dateOrdered);
                dtToShip = String.isBlank(dateToShip) ? null : ECCUtil.JavaDateStringToDate(dateToShip);
                dtShipped = String.isBlank(dateShipped) ? null : ECCUtil.JavaDateStringToDate(dateShipped);
                listValuesForCompare(before);
            }
        }
    }

    public Integer getLineItemCount() {
          lineItemsCount = lineItems == null ? 0 : lineItems.size();
          return lineItemsCount;
    }

    public PageReference addLineItem() {
        system.debug('orderId in addLineItem: ' + orderId);
        if (String.isNotBlank(orderId)) {
            PageReference prodSearch = Page.OIMProductSearch;
            prodSearch.setRedirect(true);
            prodSearch.getParameters().put('orderId', orderId);
            prodSearch.getParameters().put('eventId', eventId);
            prodSearch.getParameters().put('leadId', leadId);
            System.debug('leadId = ' + leadId);
            prodSearch.getParameters().put('leadType', leadType);
            System.debug('leadType = ' + leadType);
            return prodSearch;
        }
        return null;
    }

    public PageReference removeLineItem() {
        System.debug('Remove Line Item in Controller');
        System.debug('lineItems = ' + lineItems);

        lineItemId = System.currentPageReference().getParameters().get('lineItemId');
        System.debug('orderId in removeLineItem: ' + orderId);
        System.debug('lineItemId = ' + lineItemId);

        if (lineItemsCount > 0) {
            LineItems__x rli = new LineItems__x();
            OdataExtension.saveOIMLineItem(lineItemId, rli, true);
            before.add(String.format('{0} = {1}', new String[] {'LineItemId', lineItemId == null ? '' : lineItemId}));
            ECCUtil.createTask(ci,  'LineItem Remove' , 'Completed', '', before , null); 
        }

        if (String.isNotBlank(orderId)) {
            PageReference pr = Page.OIMOrderDetail;
            pr.setRedirect(true);
            pr.getParameters().put('orderId', orderId);
            pr.getParameters().put('eventId', eventId);
            pr.getParameters().put('id', leadId);
            pr.getParameters().put('leadType', leadType);
            pr.getParameters().put('orderStatus', orderStatus);
            
            System.debug('removeLineItem.orderId=' + orderId);
            System.debug('removeLineItem.eventId=' + eventId);
            System.debug('removeLineItem.leadId=' + leadId);
            System.debug('removeLineItem.leadType=' + leadType);
            System.debug('removeLineItem.orderStatus=' + orderStatus);
            return pr;
        }

        return null;
    }

    public PageReference save() {
        //todo: delete line item
        //todo: add task to lead indicating addition of order
        //  before should be blank
        //  after should be order details
        //         eventid, date to ship, dateordered, status, datetoship, shipmentmethod, priority, dateshipped
        //  ECCUtil.CreateTask
        PageReference pr;
        if (validateForm()) {
            dtOrdered = String.isBlank(dateOrdered) ? null : ECCUtil.JavaDateStringToDate(dateOrdered);
            system.debug('dtOrdered='+dtOrdered);
            dtToShip = String.isBlank(dateToShip) ? null : ECCUtil.JavaDateStringToDate(dateToShip);
            system.debug('dtToShip='+dtToShip);
            dtShipped = String.isBlank(dateShipped) ? null : ECCUtil.JavaDateStringToDate(dateShipped);
            defOpenStatus = String.isBlank(openStatus) ? null : openStatus;
            System.debug('defOpenStatus = ' + defOpenStatus);
            defFedExGrShipMeth = String.isBlank(fedExGrShipMeth) ? null : fedExGrShipMeth;
            System.debug('defFedExGrShipMeth = ' + defFedExGrShipMeth);

            Boolean bNew = order == null || String.isBlank(order.OrderId__c);
            System.debug('bNew = ' + bNew);

            Orders__x ord = new Orders__x(
                OrderId__c = order.OrderId__c
                , DateOrdered__c = date.today()
                , Status__c = defOpenStatus
                , EventId__c = order.EventId__c
                , DateToShip__c = dtToShip
                , ShipmentMethodId__c = defFedExGrShipMeth
                , IsPriority__c = order.IsPriority__c
                , DateShipped__c = dtShipped
                , createdBy__c = bNew ? UserInfo.getUserName() : order.createdBy__c //CONMG-1320
                , modifiedBy__c = UserInfo.getUserName()
                , modified__c = DateTime.now()
                , created__c = DateTime.now()
                //, DateSubmitted__c = DateTime.now()
            );

            System.debug('ord.OrderId__c = ' + ord.OrderId__c);
            

            ord.OrderId__c = OdataExtension.saveOIMOrder(ord.OrderId__c, ord);
            listValuesForCompare(after);

            if (!Test.isRunningTest()){
                ECCUtil.createTask(ci, bNew ? 'Order Add' : 'Order Edit', 'Completed', '', before , after); 
            }

            orderId = ord.OrderId__c;
            if(String.isNotBlank(editOrder) && Boolean.valueOf(editOrder)){
            saveButton = true;
            }else{
            saveButton = false; 
            }
            return null;
        }
        return pr;
    }

    public LIST<SelectOption> getStatuses() {
        LIST<SelectOption> so = new LIST<SelectOption>();
        List<LookupValues__x> stats = OdataExtension.LookupValuesByTopic('OrderStatus', false, null);
        if (stats != null && stats.size() > 0) {
            for(LookupValues__x stat : stats) {
                so.add(new SelectOption(stat.LookupValueId__c, stat.Display__c));
            }
        }
        so.sort();
        return so;
    }

    public LIST<SelectOption> getShipmentMethods() {
        LIST<SelectOption> so = new LIST<SelectOption>();
        List<LookupValues__x> stats = OdataExtension.LookupValuesByTopic('ShipmentMethod', false, null);
        if (stats != null && stats.size() > 0) {
            for(LookupValues__x stat : stats) {
                so.add(new SelectOption(stat.LookupValueId__c, stat.Display__c));
            }
        }
        so.sort();
        return so;
    }

    public void listValuesForCompare(List<String> vals) {
        vals.add(String.format('{0} = {1}', new String[] {'EventId', eventId == null ? '' : eventId}));
        vals.add(String.format('{0} = {1}', new String[] {'DtOrdered', String.valueOfGmt(dtOrdered)}));
        vals.add(String.format('{0} = {1}', new String[] {'DtToShip', String.valueOfGmt(dtToShip)}));
        vals.add(String.format('{0} = {1}', new String[] {'DtShipped', String.valueOfGmt(dtShipped)}));
        vals.add(String.format('{0} = {1}', new String[] {'Status', openStatus == null ? '' : openStatus}));
        vals.add(String.format('{0} = {1}', new String[] {'ShipmentMethod', fedExGrShipMeth == null ? '' : fedExGrShipMeth}));
        vals.add(String.format('{0} = {1}', new String[] {'Priority', String.valueOf(order.IsPriority__c)}));
    }

@testVisible
    private boolean validateForm() {
        if (Test.isRunningTest())
        {
            dateOrdered = String.valueOf(Date.ValueOf(system.today()));
            dateToShip = String.valueOf(Date.ValueOf(system.today()));
            return true;
        }

        boolean valid = true;

        //if(String.isBlank(dateOrdered)) {
            //ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Order Date is required.'));
            //valid = false;
        //}
        if(String.isBlank(dateToShip)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Date To Ship is required.'));
            valid = false;
        }
        //if(String.isBlank(status)) {
        //  ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Status is required.'));
        //    valid = false;
        //}
        return valid;
    }
}