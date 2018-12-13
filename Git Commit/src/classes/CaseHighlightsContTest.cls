@isTest
global class CaseHighlightsContTest {
	
	@isTest static void ViewHighlights() {
        Case c = new Case();
        c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
        c.ConstituentType__c = 'INDIVIDUAL';
        c.ConstituentUUID__c = 'notaguid';
        insert c;

        System.debug('c.Id: ' + c.Id);
        System.debug('c.ConstituentID__c: ' + c.ConstituentID__c);

        ConstituentInformation__c ci = new ConstituentInformation__c();
        ci.ConstituentId__c = 'notaguid';
        ci.CaseId__c = c.id;
        ci.Preferred__c = true;
        insert ci;

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
        PageReference pageRef = Page.CaseHighlights;
        Test.setCurrentPage(pageRef);
        Test.setMock(WebServiceMock.class, new CaseHighlightsContMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        ApexPages.currentPage().getParameters().put('contId', 'doesnt');
        ApexPages.currentPage().getParameters().put('consId', 'matter');

        CaseHighlightsController chc = new CaseHighlightsController(new ApexPages.StandardController(c));
        
        boolean boo;
        string tst;
        tst = chc.Title;
        tst = chc.FirstName;
        tst = chc.LastName;
        tst = chc.LongName;
        tst = chc.Email;
        tst = chc.EmailType;
        tst = chc.Phone;
        tst = chc.PhoneType;
        tst = chc.Address;
        tst = chc.AddressType;
        tst = chc.Staff;
        tst = chc.Deceased;
        tst = chc.ConsType;
        tst = chc.ConStatus;
        tst = chc.leadId;
        tst = chc.bbecId;
        tst = chc.taAccount;
        tst = chc.ConStatus;
        tst = chc.leadId;
        tst = chc.bbecId;
        tst = chc.taAccount;
        tst = chc.pledgeId;
        tst = chc.warnings;
        tst = chc.consId;
        tst = chc.testBlank;
        boo = chc.isResearchCase;
        boo = chc.Preferred;
        boo = chc.isUUIDSet;
        boo = chc.hasWarnings;
        boo = chc.c360Error;
        boo = chc.reload;
        boo = chc.hasRevNotes;

        chc.getNonce();
        chc.getReturnURL();
        chc.getFulfillURL();
        chc.getInteractURL();
        chc.getPledgeMaintURL();
        chc.getMergeApplicationURL();

        Continuation cont;
        cont = reLoad(cont, chc);
		
        //cont should be null now since continuation chain is complete
        System.assertEquals(null, cont);
        System.assertEquals('56FC02D5-8B2E-4DB8-8F38-886006C7AC2B', chc.consId);
        
        chc.changeCons();
        
        chc = new CaseHighlightsController(new ApexPages.StandardController(c));
        cont = chc.reLoad();
        
        System.assertEquals(null, chc.consId);
        System.assertEquals(null, cont);

		Test.stopTest();
	}
    
    private static Continuation reLoad(Continuation cont, CaseHighlightsController chc) {
        cont = chc.reLoad();
        Map<String, HttpRequest> requests = cont.getRequests();
        System.assertEquals(requests.size(), 1);

		HttpResponse response = new HttpResponse();
        response.setBody(GetConstituentResponse());

        String requestLabel = requests.keyset().iterator().next();
        Test.setContinuationResponse(requestLabel, response);

        cont = (Continuation)Test.invokeContinuationMethod(chc, cont);

        requests = cont.getRequests();
        System.assertEquals(requests.size(), 1);

		response = new HttpResponse();
        response.setBody(GetConstituentXRefResponse());

        requestLabel = requests.keyset().iterator().next();
        Test.setContinuationResponse(requestLabel, response);

        cont = (Continuation)Test.invokeContinuationMethod(chc, cont);
        return cont;
    }

	private static String GetConstituentXRefResponse() {
		return 
			'<S:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">' +
			'<env:Header/>' +
			'<S:Body>' +
			'<GetConstituentXRefsResponse xmlns="urn:soap.stjude.org" xmlns:ns0="urn:fault.soap.stjude.org" xmlns:ns2="urn:object.soap.stjude.org" xmlns:ns1="urn:domain.soap.stjude.org">' +
			'<Constituent360XRef>' +
			'<ns1:UUID>832DB0A5-5EED-4B14-A652-DCF6E9BFFC16</ns1:UUID>' +
			'<ns1:Constituents>' +
			'<ns1:ConstituentID>56FC02D5-8B2E-4DB8-8F38-886006C7AC2B</ns1:ConstituentID>' +
			'<ns1:UUID>832DB0A5-5EED-4B14-A652-DCF6E9BFFC16</ns1:UUID>' +
			'<ns1:SystemXRef>' +
			'<ns1:Sys>' +
			'<ns1:ID>45481716-340B-42E1-8620-36C509557EE1</ns1:ID>' +
			'<ns1:Name>TA</ns1:Name>' +
			'</ns1:Sys>' +
			'<ns1:XRefKey>29325379|1</ns1:XRefKey>' +
			'<ns1:AlternateXRefKey>29325379</ns1:AlternateXRefKey>' +
			'</ns1:SystemXRef>' +
			'<ns1:Type>' +
			'<ns1:Code>Individual</ns1:Code>' +
			'</ns1:Type>' +
			'</ns1:Constituents>' +
			'<ns1:Constituents>' +
			'<ns1:ConstituentID>56FC02D5-8B2E-4DB8-8F38-886006C7AC2B</ns1:ConstituentID>' +
			'<ns1:UUID>832DB0A5-5EED-4B14-A652-DCF6E9BFFC16</ns1:UUID>' +
			'<ns1:SystemXRef>' +
			'<ns1:Sys>' +
			'<ns1:ID>EC2372F7-AE4D-4447-99F6-A55E2E5FF5A6</ns1:ID>' +
			'<ns1:Name>DMS</ns1:Name>' +
			'</ns1:Sys>' +
			'<ns1:XRefKey>56FC02D5-8B2E-4DB8-8F38-886006C7AC2B</ns1:XRefKey>' +
			'<ns1:AlternateXRefKey>8-33111885</ns1:AlternateXRefKey>' +
			'</ns1:SystemXRef>' +
			'<ns1:Type>' +
			'<ns1:Code>Individual</ns1:Code>' +
			'</ns1:Type>' +
			'</ns1:Constituents>' +
			'</Constituent360XRef>' +
			'</GetConstituentXRefsResponse>' +
			'</S:Body>' +
			'</S:Envelope>';
	}

	private static String GetConstituentResponse() {
		return 
			'<S:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">' +
			'<env:Header/>' +
			'<S:Body>' +
			'<GetConstituentResponse xmlns="urn:soap.stjude.org" xmlns:ns0="urn:fault.soap.stjude.org" xmlns:ns2="urn:object.soap.stjude.org" xmlns:ns1="urn:domain.soap.stjude.org">' +
			'<Constituent xsi:type="ns1:Individual" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
			'<ns1:ConstituentID>56FC02D5-8B2E-4DB8-8F38-886006C7AC2B</ns1:ConstituentID>' +
			'<ns1:UUID>832DB0A5-5EED-4B14-A652-DCF6E9BFFC16</ns1:UUID>' +
			'<ns1:Type>' +
			'<ns1:Code>Individual</ns1:Code>' +
			'</ns1:Type>' +
			'<ns1:Staff/>' +
			'<ns1:Status>Active</ns1:Status>' +
			'<ns1:Preferred>true</ns1:Preferred>' +
			'<ns1:Profile>' +
			'<ns1:Addresses>' +
			'<ns1:ContactType>A</ns1:ContactType>' +
			'<ns1:ContactID>B441509B-52D9-4EEC-8F6C-F356301DE74F</ns1:ContactID>' +
			'<ns1:AddressType>' +
			'<ns1:ID>686CA766-20E2-4CF9-9B69-A20BC8077640</ns1:ID>' +
			'<ns1:Code>Mailing</ns1:Code>' +
			'</ns1:AddressType>' +
			'<ns1:ApartmentNumber>5</ns1:ApartmentNumber>' +
			'<ns1:Street1>98 E Jarvis St</ns1:Street1>' +
			'<ns1:City>Perris</ns1:City>' +
			'<ns1:State>CA</ns1:State>' +
			'<ns1:Country>USA</ns1:Country>' +
			'<ns1:ZipCode>92571</ns1:ZipCode>' +
			'<ns1:Preferred>true</ns1:Preferred>' +
			'<ns1:Seasonal>false</ns1:Seasonal>' +
			'<ns1:Status>Active</ns1:Status>' +
			'<ns1:UndeliverableCount>0</ns1:UndeliverableCount>' +
			'</ns1:Addresses>' +
			'<ns1:Phones>' +
			'<ns1:ContactType>P</ns1:ContactType>' +
			'<ns1:ContactID>CC65B1CA-8209-4FA4-B151-560E243A3D61</ns1:ContactID>' +
			'<ns1:PhoneType>' +
			'<ns1:ID>268579D8-C87D-44EA-B0F1-A435A6A29E8A</ns1:ID>' +
			'<ns1:Code>Home</ns1:Code>' +
			'</ns1:PhoneType>' +
			'<ns1:PhoneNumber>(951) 943-1252</ns1:PhoneNumber>' +
			'<ns1:Preferred>true</ns1:Preferred>' +
			'<ns1:Status>Active</ns1:Status>' +
			'<ns1:VendorAcquired>false</ns1:VendorAcquired>' +
			'</ns1:Phones>' +
			'<ns1:Emails>' +
			'<ns1:ContactType>E</ns1:ContactType>' +
			'<ns1:ContactID>0ED5CADC-B900-4604-9095-C6F424E4A0B6</ns1:ContactID>' +
			'<ns1:EmailType>' +
			'<ns1:ID>363BE796-DE23-49AE-9394-13A49D344E6B</ns1:ID>' +
			'<ns1:Code>Personal</ns1:Code>' +
			'</ns1:EmailType>' +
			'<ns1:EmailAddress>heldecambero@yahoo.com</ns1:EmailAddress>' +
			'<ns1:Status>Active</ns1:Status>' +
			'<ns1:Preferred>true</ns1:Preferred>' +
			'</ns1:Emails>' +
            '<ns1:FinancialProfile>' +
            '<ns1:LifeTimePaidAmount>1670.6800537109375</ns1:LifeTimePaidAmount>' +
            '<ns1:LifeTimeCount>59</ns1:LifeTimeCount>' +
            '<ns1:TotalYearsWithRevenue>12</ns1:TotalYearsWithRevenue>' +
            '<ns1:FirstGiftAmount>35.0</ns1:FirstGiftAmount>' +
            '<ns1:FirstGiftDate>2004-10-04T00:00:00.000-05:00</ns1:FirstGiftDate>' +
            '<ns1:LastGiftAmount>123.0</ns1:LastGiftAmount>' +
            '<ns1:LastGiftDate>2017-03-23T00:00:00.000-05:00</ns1:LastGiftDate>' +
            '<ns1:LargestGiftAmount>125.0</ns1:LargestGiftAmount>' +
            '<ns1:LargestGiftDate>2012-08-08T00:00:00.000-05:00</ns1:LargestGiftDate>' +
            '</ns1:FinancialProfile>' +
			'</ns1:Profile>' +
            '<ns1:Preferences>' +
            '<ns1:ConstituentPreferenceID>F65403A3-9255-479B-A6AF-DAE749613B8B</ns1:ConstituentPreferenceID>' +
            '<ns1:PreferenceID>1BFC87BF-DF6F-4B74-B1C6-38D1E8A36BFD</ns1:PreferenceID>' +
            '<ns1:Preference>LANGPREF</ns1:Preference>' +
            '<ns1:PreferenceDesc>Mail Language Preference</ns1:PreferenceDesc>' +
            '<ns1:PreferenceValue>BILINGUAL</ns1:PreferenceValue>' +
            '<ns1:PreferenceValueDesc>BILINGUAL</ns1:PreferenceValueDesc>' +
            '<ns1:PreferenceType>MAIL</ns1:PreferenceType>' +
            '<ns1:PreferenceTypeDesc>Request for a specific mailing</ns1:PreferenceTypeDesc>' +
            '<ns1:StartDate>2012-10-11T00:00:00.000-05:00</ns1:StartDate>' +
            '<ns1:Status>Active</ns1:Status>' +
            '<ns1:Comments>Inserted as missing value</ns1:Comments>' +
            '</ns1:Preferences>' +
            '<ns1:Properties>' +
			'<ns1:ConstituentBase>' +
			'<ns1:ConstituentID>F3BA07D8-9BBA-4C45-8306-696D7B523BAF</ns1:ConstituentID>' +
            '</ns1:ConstituentBase>' +
            '<ns1:PropertyID>BE0ED1AF-8FDB-4B75-900A-9B30B04396D2</ns1:PropertyID>' +
            '<ns1:Property>St. Jude Parent - Deceased</ns1:Property>' +
            '<ns1:Status>Active</ns1:Status>' +
            '<ns1:StartDate>2012-08-17T00:00:00.000-05:00</ns1:StartDate>' +
            '</ns1:Properties>' +
			'<ns1:Title>' +
			'<ns1:ID>D37EC718-DCDD-4AF9-8DDC-08EA7CF08583</ns1:ID>' +
			'<ns1:Code>Sra.</ns1:Code>' +
			'</ns1:Title>' +
			'<ns1:FirstName>Hildeliza</ns1:FirstName>' +
			'<ns1:LastName>De Luna</ns1:LastName>' +
			'<ns1:Suffix/>' +
			'<ns1:LongName>Sra. Hildeliza De Luna</ns1:LongName>' +
			'<ns1:RelatedHousehold>' +
			'<ns1:ConstituentID>1F842187-512C-471B-8DDF-5D7E6EB10728</ns1:ConstituentID>' +
			'<ns1:Name>Sra. Hildeliza De Luna</ns1:Name>' +
			'</ns1:RelatedHousehold>' +
			'<ns1:IndividualAttributes>' +
			'<ns1:NumChildren>0</ns1:NumChildren>' +
			'<ns1:NumGrandChildren>0</ns1:NumGrandChildren>' +
			'<ns1:Deceased>false</ns1:Deceased>' +
			'<ns1:Gender>F</ns1:Gender>' +
			'<ns1:FormerPatient>false</ns1:FormerPatient>' +
			'<ns1:RelativeToPatient>false</ns1:RelativeToPatient>' +
			'<ns1:AnonymousGiftAccount>false</ns1:AnonymousGiftAccount>' +
			'</ns1:IndividualAttributes>' +
			'</Constituent>' +
			'</GetConstituentResponse>' +
			'</S:Body>' +
			'</S:Envelope>';
	}

    global class CaseHighlightsContMock implements WebServiceMock {
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
            //don't do anything anymore. have to actually provide fake xml responses
            // :(   <---------- sadness
        }
        
    }
}