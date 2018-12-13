@isTest
global class OIMOrderDetailContTest {
	
	@isTest static void orderDetailsWithOrder() {

        String leadId = setupOrder();

        Test.startTest();
        
        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);

        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());
        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

		OIMOrderDetailController odc = new OIMOrderDetailController();
		string tst;
        tst = odc.OrderId;
        tst = odc.RelId;
        tst = odc.DateOrdered;
        tst = odc.DateToShip;
        tst = odc.DateShipped;
        tst = odc.LineItemId;
        tst = odc.OrderStatus;
        tst = odc.LeadId;
        tst = odc.LeadType;

        odc.addLineItem();

        Test.stopTest();
	}

 

	@isTest static void orderDetailsWithOutOrder() {

		Lead c = new Lead();
        c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        c.TR_ID__c = '123456';
        c.EventID__c = '123456';
        
        
        if(Schema.SObjectType.Lead.RecordTypeInfosByName.get('St Jude Challenge') != NULL)
            c.RecordTypeId=Schema.SObjectType.Lead.RecordTypeInfosByName.get('St Jude Challenge').RecordTypeId;
        insert c;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        V_OrderInfo__x orderInfo = new V_OrderInfo__x();
        orderInfo.EventID__c = '123456' ;
        orderInfo.OrderId__c = '123456' ;
        Database.insertAsync(orderInfo);

        Test.startTest();
        
        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);

        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('leadId', c.id);
        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

		OIMOrderDetailController odc = new OIMOrderDetailController();
		string tst;
        tst = odc.OrderId;
        tst = odc.RelId;
        tst = odc.DateOrdered;
        tst = odc.DateToShip;
        tst = odc.DateShipped;
        tst = odc.LineItemId;
        tst = odc.OrderStatus;
        tst = odc.LeadId;
        tst = odc.LeadType;


        odc.addLineItem();

        Test.stopTest();
	}

    @isTest static void lineItemsCanBeEmpty() {
        String leadId = setupOrder();

        List<V_LineItemInfo__x> lineItems = null;

        Test.startTest();
        
        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

        OIMOrderDetailController odc = new OIMOrderDetailController();
        
        odc.lineItems = new List<V_LineItemInfo__x>();
        odc.init();

        Integer lineItemCount = odc.getLineItemCount();
        System.assertEquals(lineItemCount, 0);

        Test.stopTest();
    }

    @isTest static void canGetStatuses(){
        String leadId = setupOrder();
        Test.startTest();

        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

        OIMOrderDetailController odc = new OIMOrderDetailController();
        LIST<SelectOption> options = odc.getStatuses();
        system.Assert(options != null);
        system.Assert(options.size() > 0);
        Test.stopTest();
    }

    @isTest static void canValidateForm()
    {
        String leadId = setupOrder();
        Test.startTest();

        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

        OIMOrderDetailController odc = new OIMOrderDetailController();
        Boolean isValid = odc.validateForm();
        system.Assert(isValid == true);
        Test.stopTest();
    }

    @isTest static void cangetShipmentMethods()
    {
        String leadId = setupOrder();
        Test.startTest();

        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

        OIMOrderDetailController odc = new OIMOrderDetailController();
        LIST<SelectOption> options = odc.getShipmentMethods();
        system.Assert(options != null);
        system.Assert(options.size() > 0);
        Test.stopTest();
    }

    @isTest static void lineItemsCanBeNull() {
        String leadId = setupOrder();

        List<V_LineItemInfo__x> lineItems = null;

        Test.startTest();
        
        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

        OIMOrderDetailController odc = new OIMOrderDetailController();

        odc.lineItems = null;
        odc.init();

        Integer lineItemCount = odc.getLineItemCount();

        System.assertEquals(lineItemCount, 0);
        Test.stopTest();
    }

    @isTest static void canSave() {
        String leadId = setupOrder();

        Test.startTest();
        
        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');
        ApexPages.currentPage().getParameters().put('editOrder', 'true');

        OIMOrderDetailController odc = new OIMOrderDetailController();

        odc.init();
        //odc.dateOrdered = String.valueOf(Date.ValueOf(system.today()));
        odc.defOpenStatus = 'Open';
        odc.defFedExGrShipMeth = 'Ground';
        PageReference nextPage = odc.save();

        System.assertEquals(null, nextPage);

        Test.stopTest();
    }

    @isTest static void canRemoveLineItem() {
        String leadId = setupOrder();

        Test.startTest();
        
        PageReference pageRef = Page.OIMOrderDetail;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new OIMOrderDetailContMock());

        ApexPages.currentPage().getParameters().put('orderId', '123456');
        ApexPages.currentPage().getParameters().put('leadId', leadId);
        ApexPages.currentPage().getParameters().put('id', leadId);
        ApexPages.currentPage().getParameters().put('leadType', 'Test');
        ApexPages.currentPage().getParameters().put('eventId', 'notaguid');

        OIMOrderDetailController odc = new OIMOrderDetailController();

        odc.init();
        odc.defOpenStatus = 'Open';
        odc.defFedExGrShipMeth = 'Ground';
        String nextPage = odc.removeLineItem().getUrl();
        system.Assert(nextPage.contains('/apex/oimorderdetail')==true);

        Test.stopTest();
    }
    
   static String setupOrder()
    {
        Lead c = new Lead();
        c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        c.TR_ID__c = '123456';
        c.EventID__c = '123456';
        
        if(Schema.SObjectType.Lead.RecordTypeInfosByName.get('St Jude Challenge') != NULL)
            c.RecordTypeId=Schema.SObjectType.Lead.RecordTypeInfosByName.get('St Jude Challenge').RecordTypeId;
        insert c;


        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        V_OrderInfo__x orderInfo = new V_OrderInfo__x();
        orderInfo.EventID__c = '123456' ;
        orderInfo.OrderId__c = '123456' ;
        orderInfo.ShipmentMethodDisplay__c = 'Air';
        orderInfo.DateOrdered__c = Date.ValueOf(system.today());
        orderInfo.DateToShip__c = Date.ValueOf(system.today());
        orderInfo.DateSubmitted__c = Date.ValueOf(system.today());
        orderInfo.DateShipped__c = Date.ValueOf(system.today());
        orderInfo.CreatedBy__c = 'TestAgent';
        orderInfo.StatusDisplay__c = 'Test';
        orderInfo.LineItemCount__c  = 10;
        orderInfo.IsPriority__c = false;
        orderInfo.Status__c = 'test';
        orderInfo.ShipmentMethodId__c = 'something';
        Database.insertAsync(orderInfo);

        return c.id;
    }

	global class OIMOrderDetailContMock implements WebServiceMock {
         global void doInvoke(
            Object stub,
            Object request,
            Map<String, Object> response,
            String endpoint,
            String soapAction,
            String requestName,
            String responseNS,
            String responseName,
            String responseType) {

            // Create response element from the autogenerated class.
            // Populate response element.
            // Add response element to the response parameter, as follows:
            if (requestName == 'DataRequest') {
                soapStjudeOrg.DataResponse_element de = new soapStjudeOrg.DataResponse_element();
                objectSoapStjudeOrg.Attribute att = new objectSoapStjudeOrg.Attribute();

                att.Desc_x = 'xyz';
                att.ID = 'abc';
                att.Name = 'name';

                objectSoapStjudeOrg.Attribute[] atts = new objectSoapStjudeOrg.Attribute[] 
                { att };

                de.Result = atts;
                response.put('response_x', de);
            }
            else if(requestName == 'GetConstituentXRefsRequest') {
                soapStjudeOrg.GetConstituentXRefsResponse_element gcre = new soapStjudeOrg.GetConstituentXRefsResponse_element();
  
          gcre.Constituent360XRef = new domainSoapStjudeOrg.Constituent360XRef();
          gcre.Constituent360XRef.Constituents = new domainSoapStjudeOrg.ConstituentBase[] {
            new domainSoapStjudeOrg.ConstituentBase()
          };
          gcre.Constituent360XRef.Constituents.get(0).SystemXRef = new domainSoapStjudeOrg.SystemXRef();
          gcre.Constituent360XRef.Constituents.get(0).SystemXRef.Sys = new domainSoapStjudeOrg.Sys();
          gcre.Constituent360XRef.Constituents.get(0).SystemXRef.XRefKey = 'xrefkey';
                gcre.Constituent360XRef.Constituents.get(0).SystemXRef.Sys.Name = 'name';

                response.put('response_x', gcre); 
            }
            else if(requestName == 'RemovePropertyRequest') {
                soapStjudeOrg.RemovePropertyResponse_element gcre = new soapStjudeOrg.RemovePropertyResponse_element();
  
            gcre.Result = 'yep';
                                
                response.put('response_x', gcre); 
            }
           else if(requestName == 'GetConstituentRequest') {
                soapStjudeOrg.GetConstituentResponse_element gcre = new soapStjudeOrg.GetConstituentResponse_element();
                gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                gcre.Constituent.ConstituentId = 'notaguid';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.lastName = 'test';
                gcre.Constituent.Title = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Title.Code = 'test';
                gcre.Constituent.Profile = new domainSoapStjudeOrg.Profile();
                domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
                ph.ContactID = 'doesnt';
                ph.PhoneNumber = '1231231234';
                ph.PhoneType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Phones = new domainSoapStjudeOrg.Phone[] { ph };

                domainSoapStjudeOrg.Email email = new domainSoapStjudeOrg.Email();
                email.EmailAddress = 'test@test.com';
                email.EmailType = new domainSoapStjudeOrg.TypeAttribute();
        gcre.Constituent.Profile.Emails = new domainSoapStjudeOrg.Email[] { email };

                domainSoapStjudeOrg.Address addr = new domainSoapStjudeOrg.Address();
                addr.street1 = 'test';
                addr.AddressType = new domainSoapStjudeOrg.TypeAttribute();
        gcre.Constituent.Profile.Addresses = new domainSoapStjudeOrg.Address[] { addr };

        domainSoapStjudeOrg.Property p = new domainSoapStjudeOrg.Property();
        p.Property = 'VIP_YES';
        gcre.Constituent.Properties = new domainSoapStjudeOrg.Property[] { p };

        domainSoapStjudeOrg.Preference pref = new domainSoapStjudeOrg.Preference();
        gcre.Constituent.Preferences = new domainSoapStjudeOrg.Preference[] {pref};

        domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();
        gcre.Constituent.Interactions = new domainSoapStjudeOrg.Interaction[] {i};

                domainSoapStjudeOrg.Staff stf = new domainSoapStjudeOrg.Staff();
                stf.Name = 'blah';
                gcre.Constituent.Staff = stf;

                domainSoapStjudeOrg.TypeAttribute typ = new domainSoapStjudeOrg.TypeAttribute();
                typ.Code = 'Individual';
                gcre.Constituent.Type_x = typ;

        gcre.Constituent.Profile.FinancialProfile = new domainSoapStjudeOrg.FinancialProfile();

                response.put('response_x', gcre); 
            }
            else {
                soapStjudeOrg.CreateConstituentResponse_element ccre = new soapStjudeOrg.CreateConstituentResponse_element();
                ccre.CreatedConstituent = new domainSoapStjudeOrg.Constituent();
                ccre.CreatedConstituent.ConstituentId = 'notaguid';
                
                response.put('response_x', ccre);
            }
        }
    }
 
	
	
}