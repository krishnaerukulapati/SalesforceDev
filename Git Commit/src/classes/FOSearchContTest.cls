@isTest
global class FOSearchContTest {
  
  @isTest static void SearchConsNoCase() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.FOSearch;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOSearchContMock());

        //no case
        FOSearchController ccac = new FOSearchController();
        ccac.getFirstPage();
        ccac.getLastPage();
        ccac.getResultsFound();
        ccac.getSr();
        ccac.nextPage();
        ccac.nextPage();
        ccac.prevPage();
        ccac.prevPage();
        ccac.search();
        ccac.newCons();
        ccac.changeSort();

        ccac.email = 'test@test.com';
        ccac.search();

        ApexPages.currentPage().getParameters().put('SelectUUID', 'SelectUUID');
        ApexPages.currentPage().getParameters().put('SelectName', 'SelectName');
        ApexPages.currentPage().getParameters().put('SelectConType', 'Individual');
        ccac.ViewDetail();

     

    Test.stopTest();
  }
  
  @isTest static void SearchConsResearch() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.FOSearch;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOSearchContMock());

        ApexPages.currentPage().getParameters().put('mode', 'research');

        //no case
        FOSearchController ccac = new FOSearchController();
        ccac.getFirstPage();
        ccac.getLastPage();
        ccac.getResultsFound();
        ccac.getSr();
        ccac.nextPage();
        ccac.nextPage();
        ccac.prevPage();
        ccac.prevPage();
        ccac.search();
        ccac.newCons();
        ccac.changeSort();

        ccac.email = 'test@test.com';
        ccac.search();

        ccac.ViewDetail();

     

    Test.stopTest();
  }
  
  @isTest static void SearchLeadChangeCoord() {
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Lead l = new Lead(
            LastName = 'test'
            , Coordinator__c = 'test'
            , Company = 'test'
            );

        insert l;

        Test.startTest();
        PageReference pageRef = Page.FOSearch;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOSearchContMock());

        ApexPages.currentPage().getParameters().put('leadChangeCoord', l.Id);

        //no case
        FOSearchController ccac = new FOSearchController();
        ccac.getFirstPage();
        ccac.getLastPage();
        ccac.getResultsFound();
        ccac.getSr();
        ccac.nextPage();
        ccac.nextPage();
        ccac.prevPage();
        ccac.prevPage();
        ccac.search();
        ccac.newCons();
        ccac.changeSort();

        ccac.email = 'test@test.com';
        ccac.search();

        ccac.ViewDetail();

     

    Test.stopTest();
  }
  
  @isTest static void SearchLeadCampAddRef() {
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.FOSearch;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOSearchContMock());

        ApexPages.currentPage().getParameters().put('campAddReferral', 'dont matter for coverage');

        //no case
        FOSearchController ccac = new FOSearchController();
        ccac.getFirstPage();
        ccac.getLastPage();
        ccac.getResultsFound();
        ccac.getSr();
        ccac.nextPage();
        ccac.nextPage();
        ccac.prevPage();
        ccac.prevPage();
        ccac.search();
        ccac.newCons();
        ccac.changeSort();

        ccac.email = 'test@test.com';
        ccac.search();

        ccac.ViewDetail();

     

    Test.stopTest();
  }

  @isTest static void SearchConsCase() {
    Case c = new Case();
    c.ConstituentID__c = 'notaquid';
    c.SuppliedEmail = 'shutupsalesforce@itsvalid.com';
        c.SearchTerms__c = '9011234567||||||||||||';
        insert c;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentPhoneEdit;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOSearchContMock());

        ApexPages.currentPage().getParameters().put('cid', c.id);
        FOSearchController ccac = new FOSearchController();
    
        ccac.email = 'test@test.com';
        ccac.search();

        ApexPages.currentPage().getParameters().put('SelectUUID', 'SelectUUID');
        ApexPages.currentPage().getParameters().put('SelectName', 'SelectName');
        ApexPages.currentPage().getParameters().put('SelectConType', 'Individual');
        ccac.ViewDetail();

        Test.stopTest();
    }
  
    global class FOSearchContMock implements WebServiceMock {
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
            else if(requestName == 'SearchConstituents360Request') {
                soapStjudeOrg.SearchConstituents360Response_element gcre = new soapStjudeOrg.SearchConstituents360Response_element();
                gcre.TotalResults = 9;
                objectSoapStjudeOrg.SearchResponse con = new objectSoapStjudeOrg.SearchResponse();

                domainSoapStjudeOrg.Sys sys = new domainSoapStjudeOrg.Sys();

                sys.Name = 'DMS';

                domainSoapStjudeOrg.SystemXRef xref = new domainSoapStjudeOrg.SystemXRef();

                xref.Sys = sys;
                xref.XRefKey = 'test';
                xref.AlternateXRefKey = 'test';

                domainSoapStjudeOrg.SystemXRefs xrefs = new domainSoapStjudeOrg.SystemXRefs();

                xrefs.SystemXRef = new domainSoapStjudeOrg.SystemXRef[] { xref };

                con.SystemXRefs = xrefs;

            gcre.Constituents = new objectSoapStjudeOrg.SearchResponse[] { con };
            gcre.TotalResults = 50;
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetConstituentRequest') {
                soapStjudeOrg.GetConstituentResponse_element gcre = new soapStjudeOrg.GetConstituentResponse_element();
                gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                gcre.Constituent.ConstituentId = 'notaguid';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.lastName = 'test';
                gcre.Constituent.Type_x = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Type_x.Code = 'INDIVIDUAL';
                gcre.Constituent.Profile = new domainSoapStjudeOrg.Profile();
                domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
                ph.ContactID = 'doesnt';
                ph.PhoneNumber = '1231231234';
                ph.PhoneType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Phones = new domainSoapStjudeOrg.Phone[] { ph };
                
                response.put('response_x', gcre); 
            }
            
            else if(requestName == 'GetConstituentXRefsRequest') {
                soapStjudeOrg.GetConstituentXRefsResponse_element gcre = new soapStjudeOrg.GetConstituentXRefsResponse_element();
                gcre.Constituent360XRef = new  domainSoapStjudeOrg.Constituent360XRef();
                domainSoapStjudeOrg.Constituent con = new domainSoapStjudeOrg.Constituent();
                con.ConstituentId = 'test';

                domainSoapStjudeOrg.Sys sys = new domainSoapStjudeOrg.Sys();

                sys.Name = 'DMS';

                domainSoapStjudeOrg.SystemXRef xref = new domainSoapStjudeOrg.SystemXRef();

                xref.Sys = sys;
                xref.XRefKey = 'test';
                xref.AlternateXRefKey = 'test';

                con.SystemXRef = xref;
                //con.SystemXRef.Sys.Name = 'DMS';
                

                gcre.Constituent360XRef.Constituents = new domainSoapStjudeOrg.Constituent[] {con};

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