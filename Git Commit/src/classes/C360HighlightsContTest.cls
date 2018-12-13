@isTest
global class C360HighlightsContTest {
	
	@isTest static void ViewHighlights() {
		/*Case c = new Case();
		c.ConstituentID__c = 'notaquid';
		c.ConstituentType__c = 'INDIVIDUAL';
        insert c;*/

        Case c = new Case();
        c.ConstituentID__c = 'notaquid';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;

        ConstituentInformation__c ci = new ConstituentInformation__c();
        ci.ConstituentId__c = 'notaguid';
        ci.CaseId__c = c.id;
        ci.Preferred__c = true;
        insert ci;

        List<PreferredConstituentInfos__x> pis = new List<PreferredConstituentInfos__x>();
        pis.add(new PreferredConstituentInfos__x(
                    consType__c = 'test'
                    , constituent_id__c = 'notaguid'
                    , title__c = 'Mr.'
                    , first_name__c = 'John'
                    , middle_name__c = 'Test'
                    , last_name__c = 'Test'
                    , suffix__c = 'Jr'
                    , name__c = 'John Test'
                    , address__c = '123 Road'
                    , extra_line_1__c = 'test'
                    , extra_line_2__c = 'test'
                    , city__c = 'Testville'
                    , state__c = 'New Test'
                    , country__c = 'TestCountry'
                    , zip__c = '12345'
                    , zip_ext__c = '123'
                    , addressType__c = 'house'
                    , email_address__c = 'test@123.com'
                    , emailType__c = 'email'
                    , phone_number__c = '123-456-7890'
                    , phoneType__c = 'cell'
                    ));
        System.debug('pis = ' + pis);

        //pis.consType__c = 'test';
        //pis.constituent_id__c = 'test101';
        //pis.title__c = 'Mr.';
        //pis.first_name__c = 'John';
        //pis.middle_name__c = 'Test';
        //pis.last_name__c = 'Test';
        //pis.suffix__c = 'Jr';
        //pis.name__c = 'John Test';
        //pis.address__c = '123 Road';
        //pis.extra_line_1__c = 'test';
        //pis.extra_line_2__c = 'test';
        //pis.city__c = 'Testville';
        //pis.state__c = 'New Test';
        //pis.country__c = 'TestCountry';
        //pis.zip__c = '12345';
        //pis.zip_ext__c = '123';
        //pis.addressType__c = 'house';
        //pis.email_address__c = 'test@123.com';
        //pis.emailType__c = 'email';
        //pis.phone_number__c = '123-456-7890';
        //pis.phoneType__c = 'cell';
        //insert pis;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        CustomSettings__c cst = new CustomSettings__c(
                Name = 'MergeApplication'
                , Value__c = '1234'
                );
        insert cst;

        PledgeMaintenanceSettings__c pm = new PledgeMaintenanceSettings__c();
        pm.Name = 'Master';
        pm.PledgeMaintURL__c = 'dummy';
        insert pm;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentPhoneEdit;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360HighlightsContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');
     //   ApexPages.currentPage().getParameters().put('currCase.ConstituentID__c', c.ConstituentID__c);

        C360HighlightsController ccac = new C360HighlightsController(new ApexPages.StandardController(c));
        
        boolean boo;
        string tst;
        tst = ccac.Title;
        tst = ccac.FirstName;
        tst = ccac.LastName;
        tst = ccac.LongName;
        tst = ccac.Email;
        tst = ccac.EmailType;
        tst = ccac.Phone;
        tst = ccac.PhoneType;
        tst = ccac.Address;
        tst = ccac.AddressType;
        tst = ccac.Staff;
        tst = ccac.Deceased;
        tst = ccac.ConsType;
        tst = ccac.ConStatus;
        tst = ccac.leadId;
        tst = ccac.bbecId;
        tst = ccac.taAccount;
        tst = ccac.ConStatus;
        tst = ccac.leadId;
        tst = ccac.bbecId;
        tst = ccac.taAccount;
        tst = ccac.pledgeId;
        tst = ccac.warnings;
        tst = ccac.consId;
        tst = ccac.testBlank;
        boo = ccac.isResearchCase;
        boo = ccac.Preferred;
        boo = ccac.isUUIDSet;
        boo = ccac.hasWarnings;
        boo = ccac.c360Error;
        boo = ccac.reload;
        boo = ccac.hasRevNotes;

        ccac.changeCons();
        ccac.getNonce();
        ccac.getReturnURL();
        ccac.getFulfillURL();
        ccac.getInteractURL();
        ccac.getPledgeMaintURL();
        ccac.getMergeApplicationURL();

        ccac.reLoad();

        c.ConstituentID__c = 'notaguid';
        c.ConstituentType__c = 'INDIVIDUAL';
        update c;
        ccac.reLoad();

		Test.stopTest();
	}

    	
    global class C360HighlightsContMock implements WebServiceMock {
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
            System.debug('requestName = ' + requestName);
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
                System.debug('requestName = ' + requestName);
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
        /*global void doInvoke(
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
                email.EmailAddress = 'test';
                email.EmailType = new domainSoapStjudeOrg.TypeAttribute();
				gcre.Constituent.Profile.Emails = new domainSoapStjudeOrg.Email[] { email };

                domainSoapStjudeOrg.Address addr = new domainSoapStjudeOrg.Address();
                addr.street1 = 'test';
                addr.AddressType = new domainSoapStjudeOrg.TypeAttribute();
				gcre.Constituent.Profile.Addresses = new domainSoapStjudeOrg.Address[] { addr };

				domainSoapStjudeOrg.Property p = new domainSoapStjudeOrg.Property();
				p.Property = 'VIP_YES';
                p.Status = 'Active';
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
        }*/
    }
}