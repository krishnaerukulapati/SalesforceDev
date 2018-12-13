@isTest
global class FOHeroesCheckInHighlightsContTest {
    @isTest static void ViewHighlightsOrg() {
        Lead c = new Lead(
            LastName = 'test'
            , ConstituentID__c = 'ORGANIZATION' //logic in mock service to return org
            , Constituent_Type__c = 'ORGANIZATION'
            , Company = 'fake'
            , TR_ID__c = '123456'
            , EventID__c = '123456'
            , XREF__c = '123456|TEST');
         
        
        if(Schema.SObjectType.Lead.RecordTypeInfosByName.get('Heroes') != NULL)
            c.RecordTypeId=Schema.SObjectType.Lead.RecordTypeInfosByName.get('Heroes').RecordTypeId;
        insert c;
        
        Campaign camp = new Campaign(Name='test',EventID__c='123456', EVM_EventID__c='123456');
        insert camp;
        
        Opportunity o = new Opportunity(
            Name='test',
            StageChanged__c = System.today(),
            Stagename='Closed', //valid stage name
            CloseDate=System.today(),
            Event_Organizer__c=c.id,
            Probability = 0.0);
        insert o;
        
        CampaignMember cm = new CampaignMember(CampaignId=camp.id,LeadId=c.id);
        insert cm;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        BbecSettings__c bbec = new BbecSettings__c();
        bbec.Name = 'Master';
        bbec.BbecURL__c = 'dummy';
        insert bbec;

        PledgeMaintenanceSettings__c pm = new PledgeMaintenanceSettings__c();
        pm.Name = 'Master';
        pm.PledgeMaintURL__c = 'dummy';
        insert pm;

        Test.startTest();
        
        PageReference pageRef = Page.FOFitnessHighlights;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOHeroesCheckInHighlightsContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);

        FOHeroesCheckInHighlightsController ccac = new FOHeroesCheckInHighlightsController(new ApexPages.StandardController(c));
        ccac.reLoad();
        c.ConstituentID__c = 'test';
        c.Constituent_Type__c = '';
        update c;
        ccac.reLoad();
        c.account_id__c = 'test';
        c.ConstituentID__c = '';
        update c;
        ccac.reLoad();
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
        tst = ccac.warnings;
        ccac.reLoad();
        ccac.getBbecURL();
        ccac.getPledgeMaintURL();
        ccac.getNonce();
        ccac.getReturnURL();
        ccac.genNextOppStage('Welcome');
        ccac.genNextOppStage('Activation');
        ccac.genNextOppStage('Activation 2');
        ccac.genNextOppStage('');
        ccac.genNextOppStage('Cultivation');
        try{
            ccac.assignOppStage();
        }
        Catch(Exception e) {}
        ccac.removeFromCampaign();
        Test.stopTest();
    }

    @isTest static void ViewHighlightsInd() {
        Lead c = new Lead(
            LastName = 'test'
            , ConstituentID__c = 'INDIVIDUAL' //logic in mock service to return IND
            , Constituent_Type__c = 'INDIVIDUAL'
            , Company = 'fake'
            , TR_ID__c = '123456'
            , EventID__c = '123456'
            , XREF__c = '123456|TEST');
         
        
        if(Schema.SObjectType.Lead.RecordTypeInfosByName.get('Heroes') != NULL)
            c.RecordTypeId=Schema.SObjectType.Lead.RecordTypeInfosByName.get('Heroes').RecordTypeId;
        insert c;
        
        Campaign camp = new Campaign(Name='test',EventID__c='123456', EVM_EventID__c='123456');
        insert camp;
        
        Opportunity o = new Opportunity(
            Name='test',
            StageChanged__c = System.today(),
            Stagename='Closed', //valid stage name
            CloseDate=System.today(),
            Event_Organizer__c=c.id,
            Probability = 0.0);
        insert o;
        
        CampaignMember cm = new CampaignMember(CampaignId=camp.id,LeadId=c.id);
        insert cm;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        BbecSettings__c bbec = new BbecSettings__c();
        bbec.Name = 'Master';
        bbec.BbecURL__c = 'dummy';
        insert bbec;

        PledgeMaintenanceSettings__c pm = new PledgeMaintenanceSettings__c();
        pm.Name = 'Master';
        pm.PledgeMaintURL__c = 'dummy';
        insert pm;

        Test.startTest();
        
        PageReference pageRef = Page.FOHeroesCheckInHighlights;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new FOHeroesCheckInHighlightsContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);

        FOHeroesCheckInHighlightsController ccac = new FOHeroesCheckInHighlightsController(new ApexPages.StandardController(c));
        ccac.reLoad();
        c.ConstituentID__c = 'test';
        c.Constituent_Type__c = '';
        update c;
        ccac.reLoad();
        c.account_id__c = 'test';
        c.ConstituentID__c = '';
        update c;
        ccac.reLoad();
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
        tst = ccac.warnings;
        ccac.reLoad();
        ccac.getBbecURL();
        ccac.getPledgeMaintURL();
        ccac.getNonce();
        ccac.getReturnURL();
        ccac.genNextOppStage('Welcome');
        ccac.genNextOppStage('Activation');
        ccac.genNextOppStage('Activation 2');
        ccac.genNextOppStage('');
        ccac.genNextOppStage('Cultivation');
        try{
            ccac.assignOppStage();
        }
        Catch(Exception e) {}
        ccac.removeFromCampaign();
        Test.stopTest();
    }
  
    global class FOHeroesCheckInHighlightsContMock implements WebServiceMock {
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

            system.debug('requestName: ' + requestName);
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
                system.debug('requestName: ' + requestName);
                soapStjudeOrg.GetConstituentRequest_element req = (soapStjudeOrg.GetConstituentRequest_element)request;
                soapStjudeOrg.GetConstituentResponse_element gcre = new soapStjudeOrg.GetConstituentResponse_element();
                gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                gcre.Constituent.ConstituentId = 'notaguid';
                gcre.Constituent.firstName = 'test';
                gcre.Constituent.lastName = 'test';
                gcre.Constituent.Name = 'test test';
                gcre.Constituent.longName = 'test ltest';
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

                domainSoapStjudeOrg.Staff stf = new domainSoapStjudeOrg.Staff();
                stf.Name = 'blah';
                gcre.Constituent.Staff = stf;

                domainSoapStjudeOrg.TypeAttribute typ = new domainSoapStjudeOrg.TypeAttribute();
                if (req.ConstituentID == 'ORGANIZATION') {
                    typ.Code = 'ORGANIZATION';
                }
                else {
                    typ.Code = 'INDIVIDUAL';
                    domainSoapStjudeOrg.IndividualAttributes ia = new domainSoapStjudeOrg.IndividualAttributes();
                    ia.Deceased = true;
                    ia.deceasedDate = (Datetime.now().format('yyyy-MM-dd'));
                    gcre.Constituent.IndividualAttributes = ia;
                }
                gcre.Constituent.Type_x = typ;

                gcre.Constituent.Profile.FinancialProfile = new domainSoapStjudeOrg.FinancialProfile();

                response.put('response_x', gcre); 
            }
            else if (requestName == 'CreateInteractionRequest') {
                soapStjudeOrg.CreateInteractionResponse_element cire = new soapStjudeOrg.CreateInteractionResponse_element();
                cire.Result = 'result';

                response.put('response_x', cire);
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