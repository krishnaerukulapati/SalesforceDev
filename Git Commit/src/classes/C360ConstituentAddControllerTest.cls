@isTest
global class C360ConstituentAddControllerTest {

    @isTest static void SaveWithValidationAndRel() {
        Case c = new Case();
        insert c;    
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAdd;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());
        System.debug(' c.id = ' + c.id);
        ApexPages.currentPage().getParameters().put('relId', c.id);
        ApexPages.currentPage().getParameters().put('relConsId', 'relConsType');
        ApexPages.currentPage().getParameters().put('relConsType', 'INDIVIDUAL');
        ApexPages.currentPage().getParameters().put('isRecruitmentCampaign', 'false');

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));

        cac.cancel();
        cac.save();
        cac.changeCountry();


        cac.street1 = 'test';
        cac.phStatus = 'test';
        cac.eStatus = 'test';

        cac.save();

        cac.firstName = 'test';
        cac.lastName = 'test';

        cac.city = 'test';
        cac.state = 'test';
        cac.country = 'test';
        cac.zipCode = 'test';
        cac.zipExtension = 'test';
        cac.addressTypeCode = 'test';
        cac.addStatus = 'test';

        cac.phoneNumber = '1231231234';
        cac.phoneTypeCode = 'test';

        //Email
        cac.email = 'test@test.com';
        cac.emailTypeCode = 'test';
        cac.save();

        Test.stopTest();
    }

    @isTest static void SaveWithValidationAndRelH() {
        Case c = new Case();
        insert c;    
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAdd;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());
        ApexPages.currentPage().getParameters().put('relId', c.id);
        ApexPages.currentPage().getParameters().put('relConsId', 'relConsType');
        ApexPages.currentPage().getParameters().put('relConsType', 'HOUSEHOLD');
        ApexPages.currentPage().getParameters().put('isRecruitmentCampaign', 'false');

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));


        cac.street1 = 'test';
        cac.phStatus = 'test';
        cac.eStatus = 'test';
        cac.scope = 'HOUSEHOLD';

        cac.firstName = 'test';
        cac.lastName = 'test';

        cac.city = 'test';
        cac.state = 'test';
        cac.country = 'test';
        cac.zipCode = 'test';
        cac.zipExtension = 'test';
        cac.addressTypeCode = 'test';
        cac.addStatus = 'test';

        cac.phoneNumber = '1231231234';
        cac.phoneTypeCode = 'test';

        //Email
        cac.email = 'test@test.com';
        cac.emailTypeCode = 'test';
        cac.save();

        Test.stopTest();
    }

    @isTest static void SaveWithValidationAndRelO() {
        Case c = new Case();
        insert c;    
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAdd;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());
        ApexPages.currentPage().getParameters().put('relId', c.id);
        ApexPages.currentPage().getParameters().put('relConsId', 'relConsType');
        ApexPages.currentPage().getParameters().put('relConsType', 'ORGANIZATION');
        ApexPages.currentPage().getParameters().put('isRecruitmentCampaign', 'false');

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));


        cac.street1 = 'test';
        cac.phStatus = 'test';
        cac.eStatus = 'test';
        cac.scope = 'ORGANIZATION';

        cac.firstName = 'test';
        cac.lastName = 'test';

        cac.city = 'test';
        cac.state = 'test';
        cac.country = 'test';
        cac.zipCode = 'test';
        cac.zipExtension = 'test';
        cac.addressTypeCode = 'test';
        cac.addStatus = 'test';

        cac.phoneNumber = '1231231234';
        cac.phoneTypeCode = 'test';

        //Email
        cac.email = 'test@test.com';
        cac.emailTypeCode = 'test';
        cac.save();

        Test.stopTest();
    }

    @isTest static void SaveNoRel() {
        Case c = new Case();
        c.SuppliedEmail = 'test@test.com';
        insert c;    
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAdd;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());
        ApexPages.currentPage().getParameters().put('relId', c.id);
        ApexPages.currentPage().getParameters().put('isRecruitmentCampaign', 'false');

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));

        cac.street1 = 'test';
        cac.phStatus = 'test';
        cac.eStatus = 'test';

        cac.firstName = 'test';
        cac.lastName = 'test';

        cac.city = 'test';
        cac.state = 'test';
        cac.country = 'test';
        cac.zipCode = 'test';
        cac.zipExtension = 'test';
        cac.addressTypeCode = 'test';
        cac.addStatus = 'test';

        cac.phoneNumber = '1231231234';
        cac.phoneTypeCode = 'test';

        //Email
        cac.email = 'test@test.com';
        cac.emailTypeCode = 'test';
        cac.save();

        Test.stopTest();
    }

    @isTest static void SaveNoCase() {
        Case c = new Case();
        c.SuppliedEmail = 'test@test.com';
        insert c;
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAdd;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());
        ApexPages.currentPage().getParameters().put('relId', c.id);
        ApexPages.currentPage().getParameters().put('isRecruitmentCampaign', 'false');

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));

        cac.street1 = 'test';
        cac.phStatus = 'test';
        cac.eStatus = 'test';

        cac.firstName = 'test';
        cac.lastName = 'test';

        cac.city = 'test';
        cac.state = 'test';
        cac.country = 'test';
        cac.zipCode = 'test';
        cac.zipExtension = 'test';
        cac.addressTypeCode = 'test';
        cac.addStatus = 'test';

        cac.phoneNumber = '1231231234';
        cac.phoneTypeCode = 'test';

        //Email
        cac.email = 'test@test.com';
        cac.emailTypeCode = 'test';
        cac.save();

        Test.stopTest();
    }

     @isTest static void SaveNoCaseOne() {
        Case c = new Case();
        c.SuppliedEmail = 'test@test.com';
        insert c;
        //relConsId = ApexPages.currentPage().getParameters().get('relConsId');
        //relConsType = ApexPages.currentPage().getParameters().get('relConsType');

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        PageReference pageRef = Page.C360ConstituentAdd;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());
        ApexPages.currentPage().getParameters().put('isRecruitmentCampaign', 'true');

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));

        cac.street1 = 'test';
        cac.phStatus = 'test';
        cac.eStatus = 'test';

        cac.firstName = 'test';
        cac.lastName = 'test';

        cac.city = 'test';
        cac.state = 'test';
        cac.country = 'test';
        cac.zipCode = 'test';
        cac.zipExtension = 'test';
        cac.addressTypeCode = 'test';
        cac.addStatus = 'test';

        cac.phoneNumber = '1231231234';
        cac.phoneTypeCode = 'test';

        //Email
        cac.email = 'test@test.com';
        cac.emailTypeCode = 'test';
        cac.save();

        Test.stopTest();
    }

    @isTest static void GetSelectLists() {
        Case c = new Case();
        insert c;

        C360ConstituentAddController cac = new C360ConstituentAddController(new ApexPages.StandardController(c));

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Test.startTest();
        Test.setMock(WebServiceMock.class, new C360ConstituentAddControllerMock());

        cac.getAddrTypes();
        cac.getCountries();
        cac.country = 'USA';
        cac.getStates();
        cac.getSuffixes();
        cac.getTitles();
        cac.getAddrTypes();
        cac.getEmailTypes();
        cac.getPhoneTypes();
        cac.getStatusTypes();

        Test.stopTest();
    }

    global class C360ConstituentAddControllerMock implements WebServiceMock {
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