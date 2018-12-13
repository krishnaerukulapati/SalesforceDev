@isTest
global class C360InteractionsContTest {

      static Case c; // = new Case();
      static ConstituentInformation__c ci;// = new ConstituentInformation__c();

      static void init(){
        c = new Case();
        ci = new ConstituentInformation__c(); 

        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        insert c;

        ci.ConstituentId__c = 'notaguid';
        ci.CaseId__c = c.id;
        ci.Preferred__c = true;
        insert ci;
      }

     @isTest static void GetInteractions2() {
        init();

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360Interactions;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360InteractionsContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        C360InteractionsController ccac = new C360InteractionsController(new ApexPages.StandardController(c));

        ccac.changeCons();
         C360InteractionsController.getInteractionPage('test', 1, 2);
         ccac.getItems();
  
    Test.stopTest();
  }
    
    @isTest static void GetInteractions() {
        init();

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360Interactions;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360InteractionsContMock());
        System.debug(' c.id =++ ');
        System.debug(' c.id = ' + c.id);
        ApexPages.currentPage().getParameters().put('id', c.id);
        
        System.debug(' c.id = ' + c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        C360InteractionsController ccac = new C360InteractionsController(new ApexPages.StandardController(c));

        ccac.changeCons();
        C360InteractionsController.getInteractionPage('test', 1, 2);
        ccac.getItems();
    
        Test.stopTest();
    }
    
    global class C360InteractionsContMock implements WebServiceMock {
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
            else if(requestName == 'GetInteractionsRequest') {
                soapStjudeOrg.GetInteractionsResponse_element gcre = new soapStjudeOrg.GetInteractionsResponse_element();

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
                email.EmailAddress = 'test';
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