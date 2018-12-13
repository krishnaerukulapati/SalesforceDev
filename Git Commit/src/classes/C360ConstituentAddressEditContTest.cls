@isTest
global class C360ConstituentAddressEditContTest {
	
	@isTest static void AddressEdit() {
		Case c = new Case();
		c.ConstituentID__c = 'notaquid';
        insert c;    
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAddressEdit;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddressEditContMock());
        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        C360ConstituentAddressEditController ccac = new C360ConstituentAddressEditController(new ApexPages.StandardController(c));
        ccac.cancel();
        ccac.changeCountry();

        ccac.country = 'USA';
		ccac.getAddrTypes(); 
		ccac.getCountries(); 
		ccac.getStates();
		ccac.getStatusTypes();

		ccac.save();
		ccac.addressTypeCode = 'test';
		ccac.streetNumber = 'test';
		ccac.streetName = 'test';
		ccac.street1 = 'test';
		ccac.street2 = 'test';
		ccac.street3 = 'test';
		ccac.city = 'test';
		ccac.state = 'test';
		ccac.country = 'test';
		ccac.zipCode = 'test';
		ccac.zipExtension = 'test';
		ccac.preferred = true;
		ccac.status = 'test';

		ccac.save();
		Test.stopTest();

	}


    global class C360ConstituentAddressEditContMock implements WebServiceMock {
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
            else if(requestName == 'GetConstituentRequest') {
                soapStjudeOrg.GetConstituentResponse_element gcre = new soapStjudeOrg.GetConstituentResponse_element();
                gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                gcre.Constituent.ConstituentId = 'notaguid';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.lastName = 'test';
                gcre.Constituent.Profile = new domainSoapStjudeOrg.Profile();
                domainSoapStjudeOrg.Address add = new domainSoapStjudeOrg.Address();
                add.ContactID = 'doesnt';
                add.AddressType = new domainSoapStjudeOrg.TypeAttribute();
                gcre.Constituent.Profile.Addresses = new domainSoapStjudeOrg.Address[] { add };
                

                response.put('response_x', gcre); 
            }
            else if(requestName == 'EditConstituentRequest') {
                soapStjudeOrg.EditConstituentResponse_element ecre = new soapStjudeOrg.EditConstituentResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
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