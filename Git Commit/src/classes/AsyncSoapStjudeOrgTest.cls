@isTest
global class AsyncSoapStjudeOrgTest {
	
	@isTest static void testAsyncSoap() {
		C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

        Continuation continuation = new Continuation(5);
        continuation.continuationMethod = 'gotConstituent'; 

		Test.startTest();

		AsyncSoapStjudeOrg.EditDocumentationResponse_elementFuture EditDocumentationResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditDocumentationResponse_elementFuture();
		AsyncSoapStjudeOrg.RemoveContactResponse_elementFuture RemoveContactResponse_elementFuture_inst = new AsyncSoapStjudeOrg.RemoveContactResponse_elementFuture();
		AsyncSoapStjudeOrg.EditConstituentResponse_elementFuture EditConstituentResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditConstituentResponse_elementFuture();
		AsyncSoapStjudeOrg.GetInterestsResponse_elementFuture GetInterestsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetInterestsResponse_elementFuture();
		AsyncSoapStjudeOrg.EditInteractionResponse_elementFuture EditInteractionResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditInteractionResponse_elementFuture();
		AsyncSoapStjudeOrg.CreatePlannedGiftResponse_elementFuture CreatePlannedGiftResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreatePlannedGiftResponse_elementFuture();
		AsyncSoapStjudeOrg.EditTransactionResponse_elementFuture EditTransactionResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditTransactionResponse_elementFuture();
		AsyncSoapStjudeOrg.GetCommunicationsResponse_elementFuture GetCommunicationsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetCommunicationsResponse_elementFuture();
		AsyncSoapStjudeOrg.GetPreferencesResponse_elementFuture GetPreferencesResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetPreferencesResponse_elementFuture();
		AsyncSoapStjudeOrg.GetTransactionsResponse_elementFuture GetTransactionsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetTransactionsResponse_elementFuture();
		AsyncSoapStjudeOrg.EditEmailResponse_elementFuture EditEmailResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditEmailResponse_elementFuture();
		AsyncSoapStjudeOrg.EditAddressResponse_elementFuture EditAddressResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditAddressResponse_elementFuture();
		AsyncSoapStjudeOrg.SetXRefResponse_elementFuture SetXRefResponse_elementFuture_inst = new AsyncSoapStjudeOrg.SetXRefResponse_elementFuture();
		AsyncSoapStjudeOrg.GetLoyaltyProfileResponse_elementFuture GetLoyaltyProfileResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetLoyaltyProfileResponse_elementFuture();
		AsyncSoapStjudeOrg.RemoveInterestResponse_elementFuture RemoveInterestResponse_elementFuture_inst = new AsyncSoapStjudeOrg.RemoveInterestResponse_elementFuture();
		AsyncSoapStjudeOrg.CreateEmailResponse_elementFuture CreateEmailResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateEmailResponse_elementFuture();
		AsyncSoapStjudeOrg.GetRelationshipsResponse_elementFuture GetRelationshipsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetRelationshipsResponse_elementFuture();
		AsyncSoapStjudeOrg.ValidateAddressResponse_elementFuture ValidateAddressResponse_elementFuture_inst = new AsyncSoapStjudeOrg.ValidateAddressResponse_elementFuture();
		AsyncSoapStjudeOrg.GetDocumentationResponse_elementFuture GetDocumentationResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetDocumentationResponse_elementFuture();
		AsyncSoapStjudeOrg.EditPlannedGiftAdvisorResponse_elementFuture EditPlannedGiftAdvisorResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditPlannedGiftAdvisorResponse_elementFuture();
		AsyncSoapStjudeOrg.EditPreferenceResponse_elementFuture EditPreferenceResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditPreferenceResponse_elementFuture();
		AsyncSoapStjudeOrg.EditCommunicationResponse_elementFuture EditCommunicationResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditCommunicationResponse_elementFuture();
		AsyncSoapStjudeOrg.CreateContactPreferenceResponse_elementFuture CreateContactPreferenceResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateContactPreferenceResponse_elementFuture();
		AsyncSoapStjudeOrg.SetPropertyResponse_elementFuture SetPropertyResponse_elementFuture_inst = new AsyncSoapStjudeOrg.SetPropertyResponse_elementFuture();
		AsyncSoapStjudeOrg.GetPlannedGiftsResponse_elementFuture GetPlannedGiftsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetPlannedGiftsResponse_elementFuture();
		AsyncSoapStjudeOrg.SearchConstituents360Response_elementFuture SearchConstituents360Response_elementFuture_inst = new AsyncSoapStjudeOrg.SearchConstituents360Response_elementFuture();
		AsyncSoapStjudeOrg.CreateDocumentationResponse_elementFuture CreateDocumentationResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateDocumentationResponse_elementFuture();
		AsyncSoapStjudeOrg.ValidateResponse_elementFuture ValidateResponse_elementFuture_inst = new AsyncSoapStjudeOrg.ValidateResponse_elementFuture();
		AsyncSoapStjudeOrg.ExactMatch360Response_elementFuture ExactMatch360Response_elementFuture_inst = new AsyncSoapStjudeOrg.ExactMatch360Response_elementFuture();
		AsyncSoapStjudeOrg.AsyncC360MessageResponse_elementFuture AsyncC360MessageResponse_elementFuture_inst = new AsyncSoapStjudeOrg.AsyncC360MessageResponse_elementFuture();
		AsyncSoapStjudeOrg.MergeResponse_elementFuture MergeResponse_elementFuture_inst = new AsyncSoapStjudeOrg.MergeResponse_elementFuture();
		AsyncSoapStjudeOrg.SetInterestResponse_elementFuture SetInterestResponse_elementFuture_inst = new AsyncSoapStjudeOrg.SetInterestResponse_elementFuture();
		AsyncSoapStjudeOrg.GetEnrichmentProfileResponse_elementFuture GetEnrichmentProfileResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetEnrichmentProfileResponse_elementFuture();
		AsyncSoapStjudeOrg.MergeDetailResponse_elementFuture MergeDetailResponse_elementFuture_inst = new AsyncSoapStjudeOrg.MergeDetailResponse_elementFuture();
		AsyncSoapStjudeOrg.GetMarketingProfileResponse_elementFuture GetMarketingProfileResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetMarketingProfileResponse_elementFuture();
		AsyncSoapStjudeOrg.EditPlannedGiftResponse_elementFuture EditPlannedGiftResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditPlannedGiftResponse_elementFuture();
		AsyncSoapStjudeOrg.EditPhoneResponse_elementFuture EditPhoneResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditPhoneResponse_elementFuture();
		AsyncSoapStjudeOrg.CreatePreferenceResponse_elementFuture CreatePreferenceResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreatePreferenceResponse_elementFuture();
		AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture GetConstituentResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture();
		AsyncSoapStjudeOrg.GetInteractionsResponse_elementFuture GetInteractionsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetInteractionsResponse_elementFuture();
		AsyncSoapStjudeOrg.GetFinancialProfileResponse_elementFuture GetFinancialProfileResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetFinancialProfileResponse_elementFuture();
		AsyncSoapStjudeOrg.AddPlannedGiftAdvisorResponse_elementFuture AddPlannedGiftAdvisorResponse_elementFuture_inst = new AsyncSoapStjudeOrg.AddPlannedGiftAdvisorResponse_elementFuture();
		AsyncSoapStjudeOrg.EditContactAttributeResponse_elementFuture EditContactAttributeResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditContactAttributeResponse_elementFuture();
		AsyncSoapStjudeOrg.SearchConstituentsRawResponse_elementFuture SearchConstituentsRawResponse_elementFuture_inst = new AsyncSoapStjudeOrg.SearchConstituentsRawResponse_elementFuture();
		AsyncSoapStjudeOrg.CreateInteractionResponse_elementFuture CreateInteractionResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateInteractionResponse_elementFuture();
		AsyncSoapStjudeOrg.LoadTransactionResponse_elementFuture LoadTransactionResponse_elementFuture_inst = new AsyncSoapStjudeOrg.LoadTransactionResponse_elementFuture();
		AsyncSoapStjudeOrg.VersionResponse_elementFuture VersionResponse_elementFuture_inst = new AsyncSoapStjudeOrg.VersionResponse_elementFuture();
		AsyncSoapStjudeOrg.CreatePhoneResponse_elementFuture CreatePhoneResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreatePhoneResponse_elementFuture();
		AsyncSoapStjudeOrg.CancelTransactionResponse_elementFuture CancelTransactionResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CancelTransactionResponse_elementFuture();
		AsyncSoapStjudeOrg.RemovePropertyResponse_elementFuture RemovePropertyResponse_elementFuture_inst = new AsyncSoapStjudeOrg.RemovePropertyResponse_elementFuture();
		AsyncSoapStjudeOrg.GetContactPreferencesResponse_elementFuture GetContactPreferencesResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetContactPreferencesResponse_elementFuture();
		AsyncSoapStjudeOrg.GetContactAttributesResponse_elementFuture GetContactAttributesResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetContactAttributesResponse_elementFuture();
		AsyncSoapStjudeOrg.SearchEventsResponse_elementFuture SearchEventsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.SearchEventsResponse_elementFuture();
		AsyncSoapStjudeOrg.CreateAddressResponse_elementFuture CreateAddressResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateAddressResponse_elementFuture();
		AsyncSoapStjudeOrg.GetPropertiesResponse_elementFuture GetPropertiesResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetPropertiesResponse_elementFuture();
		AsyncSoapStjudeOrg.EditContactPreferenceResponse_elementFuture EditContactPreferenceResponse_elementFuture_inst = new AsyncSoapStjudeOrg.EditContactPreferenceResponse_elementFuture();
		AsyncSoapStjudeOrg.CreateConstituentResponse_elementFuture CreateConstituentResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateConstituentResponse_elementFuture();
		AsyncSoapStjudeOrg.GetProfileResponse_elementFuture GetProfileResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetProfileResponse_elementFuture();
		AsyncSoapStjudeOrg.GetTransactionProfileResponse_elementFuture GetTransactionProfileResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetTransactionProfileResponse_elementFuture();
		AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture GetConstituentXRefsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture();
		AsyncSoapStjudeOrg.GetEventResponse_elementFuture GetEventResponse_elementFuture_inst = new AsyncSoapStjudeOrg.GetEventResponse_elementFuture();
		AsyncSoapStjudeOrg.CreateCommunicationResponse_elementFuture CreateCommunicationResponse_elementFuture_inst = new AsyncSoapStjudeOrg.CreateCommunicationResponse_elementFuture();
		AsyncSoapStjudeOrg.DataResponse_elementFuture DataResponse_elementFuture_inst = new AsyncSoapStjudeOrg.DataResponse_elementFuture();
		AsyncSoapStjudeOrg.SearchTransactionsResponse_elementFuture SearchTransactionsResponse_elementFuture_inst = new AsyncSoapStjudeOrg.SearchTransactionsResponse_elementFuture();

		Test.setMock(WebServiceMock.class, new AsyncSoapStjudeOrgMock());

		AsyncSoapStjudeOrg.AsyncConstituentPort cp = new AsyncSoapStjudeOrg.AsyncConstituentPort();
        cp.beginEditDocumentation(continuation, null, null, null, null, null, null);
        cp.beginRemoveContact(continuation, null, null, null, null, null);
        cp.beginEditConstituent(continuation, null, null, null, null, null, null);
        cp.beginGetInterests(continuation, null, null, null, null, null);
        cp.beginEditInteraction(continuation, null, null, null, null, null, null);
        cp.beginCreatePlannedGift(continuation, null, null, null, null, null, null);
        cp.beginEditTransaction(continuation, null, null, null, null, null, null,null);
        cp.beginGetCommunications(continuation, null, null, null, null, null, null);
        cp.beginGetPreferences(continuation, null, null, null, null, null, null);
        cp.beginGetTransactions(continuation, null, null, null, null, null, null, 
                null, null, null);

        cp.beginEditEmail(continuation, null, null, null, null, null);
        cp.beginEditAddress(continuation, null, null, null, null, null);
        cp.beginSetXRef(continuation, null, null);
        cp.beginGetLoyaltyProfile(continuation, null, null, null, null);
        cp.beginRemoveInterest(continuation, null, null, null, null, null);
        cp.beginCreateEmail(continuation, null, null, null, null, null);
        cp.beginGetRelationships(continuation, null, null, null, null, null);
        cp.beginValidateAddress(continuation, null, null, null, null, null);
        cp.beginGetDocumentation(continuation, null, null, null, null);
        cp.beginEditPlannedGiftAdvisor(continuation, null, null, null, null, null, null);
        cp.beginEditPreference(continuation, null, null, null, null, null, null, null, null, 
        		null, null, null, null, null);
        cp.beginEditCommunication(continuation, null, null, null, null, null, null);
        cp.beginCreateContactPreference(continuation, null, null, null, null, null, null, null, null, 
        		null, null, null, null, null, null, null);
        cp.beginSetProperty(continuation, null, null, null, null, null);
        cp.beginGetPlannedGifts(continuation, null, null, null, null, null, null);
        cp.beginSearchConstituents360(continuation, null, null, null, null, null, null, null);
        cp.beginCreateDocumentation(continuation, null, null, null, null, null);
        cp.beginValidateService(continuation, null, null);
        cp.beginExactMatch360(continuation, null, null, null, null);
        cp.beginAsyncC360Message(continuation, null, null);
        cp.beginMerge_x(continuation, null, null, null, null);
        cp.beginSetInterest(continuation, null, null, null, null, null);
        cp.beginGetEnrichmentProfile(continuation, null, null, null, null);
        cp.beginMergeDetail(continuation, null, null, null);
        cp.beginGetMarketingProfile(continuation, null, null, null, null);
        cp.beginEditPlannedGift(continuation, null, null, null, null, null, null);
        cp.beginEditPhone(continuation, null, null, null, null, null);
        cp.beginCreatePreference(continuation, null, null, null, null, null, null,
        		null, null, null, null, null, null);
        cp.beginGetConstituent(continuation, null, null, null, null, null, null,
        		null, null, null, null, null);
        cp.beginGetInteractions(continuation, null, null, null, null, null, null, null, null);
        cp.beginGetFinancialProfile(continuation, null, null, null, null, null, null);
        cp.beginAddPlannedGiftAdvisor(continuation, null, null, null, null, null, null);
        cp.beginEditContactAttribute(continuation, null, null, null, null, null);
        cp.beginSearchConstituentsRaw(continuation, null, null, null, null, null, null, null);
        cp.beginCreateInteraction(continuation, null, null, null, null, null, null);
        cp.beginLoadTransaction(continuation, null, null, null, null, null, null);
        cp.beginVersion(continuation, null);
        cp.beginCreatePhone(continuation, null, null, null, null, null);
        cp.beginCancelTransaction(continuation, null, null, null, null, null, null, null, null, null, null, null);
        cp.beginRemoveProperty(continuation, null, null, null, null, null);
        cp.beginGetContactPreferences(continuation, null, null, null, null, null, null, null, null, null);
        cp.beginGetContactAttributes(continuation, null, null, null, null);
        cp.beginSearchEvents(continuation, null, null, null, null, null);
        cp.beginCreateAddress(continuation, null, null, null, null, null);
        cp.beginGetProperties(continuation, null, null, null, null, null);
        cp.beginEditContactPreference(continuation, null, null, null, null, null, null, null, null, null, null, null, null, null);
        cp.beginCreateConstituent(continuation, null, null, null, null, null, null, null);
        cp.beginGetProfile(continuation, null, null, null, null, null, null, null);
        cp.beginGetTransactionProfile(continuation, null, null, null, null, null);
        cp.beginGetConstituentXRefs(continuation, null, null, null, null);
        cp.beginGetEvent(continuation, null, null, null);
        cp.beginCreateCommunication(continuation, null, null, null, null, null);
        cp.beginGetData(continuation, null, null, null);
        cp.beginSearchTransactions(continuation, null, null, null, null, null, null, null, null, null); 

		Test.stopTest();
	}
	
	@isTest static void test_method_two() {
		// Implement test code
	}

     global class AsyncSoapStjudeOrgMock implements WebServiceMock {
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
            if (requestName == 'CreateInteractionRequest') {
                AsyncSoapStjudeOrg.CreateInteractionResponse_elementFuture cire = new AsyncSoapStjudeOrg.CreateInteractionResponse_elementFuture();
                //cire.getValue = 'result';

                response.put('response_x', cire);
            }
            else if (requestName == 'EditDocumentationRequest')
            {
                AsyncSoapStjudeOrg.EditDocumentationResponse_elementFuture cre = new AsyncSoapStjudeOrg.EditDocumentationResponse_elementFuture();
                response.put('response_x', cre.getValue());
            }


            else if (requestName == 'DataRequest') {
                AsyncSoapStjudeOrg.DataResponse_elementFuture de = new AsyncSoapStjudeOrg.DataResponse_elementFuture();
                objectSoapStjudeOrg.Attribute att = new objectSoapStjudeOrg.Attribute();

                att.Desc_x = 'xyz';
                att.ID = 'abc';
                att.Name = 'name';

                objectSoapStjudeOrg.Attribute[] atts = new objectSoapStjudeOrg.Attribute[] 
                { att };

                //de.Result = atts;
                response.put('response_x', de);
            }
            else if(requestName == 'GetConstituentRequest') {
                AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture gcre = new AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture();
                //gcre.Constituent = new domainSoapStjudeOrg.Constituent();
                //gcre.request_x.ConstituentId = 'notaguid';
                response.put('response_x', gcre); 
            }
            else if(requestName == 'EditConstituentRequest') {
                AsyncSoapStjudeOrg.EditConstituentResponse_elementFuture ecre = new AsyncSoapStjudeOrg.EditConstituentResponse_elementFuture();
                //ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'CreateConstituentRequest') {
                AsyncSoapStjudeOrg.CreateConstituentResponse_elementFuture ccre = new AsyncSoapStjudeOrg.CreateConstituentResponse_elementFuture();
                //ccre.CreatedConstituent = new domainSoapStjudeOrg.Constituent();
                //ccre.CreatedConstituent.ConstituentId = 'notaguid';
                response.put('response_x', ccre); 
            }
            else if(requestName == 'GetPreferencesRequest') {
                AsyncSoapStjudeOrg.GetPreferencesResponse_elementFuture ecre = new AsyncSoapStjudeOrg.GetPreferencesResponse_elementFuture();
                domainSoapStjudeOrg.Preference p = new domainSoapStjudeOrg.Preference();
                p.PreferenceId = 'doesnt';
                //ecre.Preferences = new domainSoapStjudeOrg.Preference[] { p };
                response.put('response_x', ecre); 
            }
            else if(requestName == 'EditPreferenceRequest') {
                AsyncSoapStjudeOrg.EditPreferenceResponse_elementFuture ecre = new AsyncSoapStjudeOrg.EditPreferenceResponse_elementFuture();
                //ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'CreatePreferenceRequest') {
                AsyncSoapStjudeOrg.CreatePreferenceResponse_elementFuture ecre = new AsyncSoapStjudeOrg.CreatePreferenceResponse_elementFuture();
                //ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'SetPropertyRequest') {
                AsyncSoapStjudeOrg.SetPropertyResponse_elementFuture ecre = new AsyncSoapStjudeOrg.SetPropertyResponse_elementFuture();
                //ecre.Result = 'result';

                response.put('response_x', ecre); 
            }
            else if(requestName == 'EditPreferenceRequest') {
                AsyncSoapStjudeOrg.EditPreferenceResponse_elementFuture ecre = new AsyncSoapStjudeOrg.EditPreferenceResponse_elementFuture();
                //ecre.Result = 'Result';
                //ecre. = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'CreatePreferenceRequest') {
                AsyncSoapStjudeOrg.CreatePreferenceResponse_elementFuture ecre = new AsyncSoapStjudeOrg.CreatePreferenceResponse_elementFuture();
                //ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'SearchConstituents360Request') {
                AsyncSoapStjudeOrg.SearchConstituents360Response_elementFuture gcre = new AsyncSoapStjudeOrg.SearchConstituents360Response_elementFuture();
                //gcre.TotalResults = 9;
                objectSoapStjudeOrg.SearchResponse con = new objectSoapStjudeOrg.SearchResponse();

                //gcre.Constituents = new objectSoapStjudeOrg.SearchResponse[] { con };
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetPreferencesRequest') {
                AsyncSoapStjudeOrg.GetPreferencesResponse_elementFuture gcre = new AsyncSoapStjudeOrg.GetPreferencesResponse_elementFuture();
  
                //gcre.Preferences = new domainSoapStjudeOrg.Preference[] {
                //    new domainSoapStjudeOrg.Preference()
                //};
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetPropertiesRequest') {
                AsyncSoapStjudeOrg.GetPropertiesResponse_elementFuture gcre = new AsyncSoapStjudeOrg.GetPropertiesResponse_elementFuture();
  
                //gcre.Properties = new domainSoapStjudeOrg.Property[] {
                //    new domainSoapStjudeOrg.Property()
                //};
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'RemovePropertyRequest') {
                AsyncSoapStjudeOrg.RemovePropertyResponse_elementFuture gcre = new AsyncSoapStjudeOrg.RemovePropertyResponse_elementFuture();
  
                //gcre.Result = 'yep';
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetRelationshipsRequest') {
                AsyncSoapStjudeOrg.GetRelationshipsResponse_elementFuture gcre = new AsyncSoapStjudeOrg.GetRelationshipsResponse_elementFuture();
  
                //gcre.TotalResults = 1;
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'RemovePropertyRequest') {
                AsyncSoapStjudeOrg.RemovePropertyResponse_elementFuture gcre = new AsyncSoapStjudeOrg.RemovePropertyResponse_elementFuture();
  
                //gcre.Result = 'yep';
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetInteractionsRequest') {
                AsyncSoapStjudeOrg.GetInteractionsResponse_elementFuture gcre = new AsyncSoapStjudeOrg.GetInteractionsResponse_elementFuture();

                response.put('response_x', gcre); 
            }
            
            else if(requestName == 'GetConstituentXRefsRequest') {
                AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture gcre = new AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture();
                //gcre.Constituent360XRef = new  domainSoapStjudeOrg.Constituent360XRef();
                domainSoapStjudeOrg.Constituent con = new domainSoapStjudeOrg.Constituent();
                con.ConstituentId = 'test';

                //gcre.Constituent360XRef.Constituents = new domainSoapStjudeOrg.Constituent[] {con};

                response.put('response_x', gcre); 
            }
            else if (requestName == 'GetTransactionsRequest') {
                AsyncSoapStjudeOrg.GetTransactionsResponse_elementFuture de = new AsyncSoapStjudeOrg.GetTransactionsResponse_elementFuture();
                //de.TotalResults = 50;

                response.put('response_x', de);
            }else if(requestName == 'AsyncC360MessageRequest'){
                AsyncSoapStjudeOrg.AsyncC360MessageResponse_elementFuture re = new AsyncSoapStjudeOrg.AsyncC360MessageResponse_elementFuture();
                //re.result = 'test';
                response.put('response_x', re);
            }else if(requestName == 'SetXRefRequest'){
                AsyncSoapStjudeOrg.SetXRefResponse_elementFuture xrefRe = new AsyncSoapStjudeOrg.SetXRefResponse_elementFuture();
                response.put('response_x', xrefRe);
            }else if(requestName == 'ExactMatch360Request'){
                AsyncSoapStjudeOrg.ExactMatch360Response_elementFuture exactRe = new AsyncSoapStjudeOrg.ExactMatch360Response_elementFuture();
                //exactRe.constituent = new objectSoapStjudeOrg.MatchResponse();
                //exactRe.constituent.ConstituentId = 'test';
                response.put('response_x', exactRe );
            }else if(requestName == 'GetContactAttributesResponse'){
                AsyncSoapStjudeOrg.GetContactAttributesResponse_elementFuture gCAR = new AsyncSoapStjudeOrg.GetContactAttributesResponse_elementFuture();
                //objectSoapStjudeOrg.KeyVal[]
                //gCAR.Result = new objectSoapStjudeOrg.KeyVal[]{new objectSoapStjudeOrg.KeyVal()};
                response.put('response_x', gCAR);
            }else if(requestName == 'GetTransactionProfileRequest'){
                AsyncSoapStjudeOrg.GetTransactionProfileResponse_elementFuture txnRes = new AsyncSoapStjudeOrg.GetTransactionProfileResponse_elementFuture();
                //txnRes.TransactionProfile = new domainSoapStjudeOrg.TransactionProfile();
                response.put('response_x', txnRes);
            }else if(requestName == 'GetInterestsRequest'){
                AsyncSoapStjudeOrg.GetInterestsResponse_elementFuture giRes = new AsyncSoapStjudeOrg.GetInterestsResponse_elementFuture();
                //giRes.Interests = new domainSoapStjudeOrg.Interest[]{}; 
                response.put('response_x', giRes);
            }else if(requestName == 'CancelTransactionRequest'){
                AsyncSoapStjudeOrg.CancelTransactionResponse_elementFuture response_x = new AsyncSoapStjudeOrg.CancelTransactionResponse_elementFuture();
                //response_x.Result = 'Success';
                response.put('response_x', response_x);
            }else if(requestName == 'EditContactAttributeRequest'){
                AsyncSoapStjudeOrg.EditContactAttributeResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditContactAttributeResponse_elementFuture();
                //response_x.Result = 'Success';
                response.put('response_x', response_x);
            }else if(requestName == 'RemoveInterestRequest'){
                AsyncSoapStjudeOrg.RemoveInterestResponse_elementFuture response_x = new AsyncSoapStjudeOrg.RemoveInterestResponse_elementFuture();
                //response_x.Result = 'Success';
                response.put('response_x', response_x);
            }else if(requestName == 'GetPlannedGiftsRequest'){
                AsyncSoapStjudeOrg.GetPlannedGiftsResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetPlannedGiftsResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'GetMarketingProfileRequest'){
                AsyncSoapStjudeOrg.GetMarketingProfileResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetMarketingProfileResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'EditPlannedGiftRequest'){
                AsyncSoapStjudeOrg.EditPlannedGiftResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditPlannedGiftResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'CreateContactPreferenceRequest'){
                AsyncSoapStjudeOrg.CreateContactPreferenceResponse_elementFuture response_x = new AsyncSoapStjudeOrg.CreateContactPreferenceResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'SetInterestRequest'){
                AsyncSoapStjudeOrg.SetInterestResponse_elementFuture response_x = new AsyncSoapStjudeOrg.SetInterestResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'GetEnrichmentProfileRequest'){
                AsyncSoapStjudeOrg.GetEnrichmentProfileResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetEnrichmentProfileResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'GetProfileRequest'){
                AsyncSoapStjudeOrg.GetProfileResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetProfileResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'SearchEventsRequest'){
                AsyncSoapStjudeOrg.SearchEventsResponse_elementFuture response_x = new AsyncSoapStjudeOrg.SearchEventsResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'ValidateRequest'){
                AsyncSoapStjudeOrg.ValidateResponse_elementFuture response_x = new AsyncSoapStjudeOrg.ValidateResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'AddPlannedGiftAdvisorRequest'){
                AsyncSoapStjudeOrg.AddPlannedGiftAdvisorResponse_elementFuture response_x = new AsyncSoapStjudeOrg.AddPlannedGiftAdvisorResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'GetFinancialProfileRequest'){
                AsyncSoapStjudeOrg.GetFinancialProfileResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetFinancialProfileResponse_elementFuture();
                response.put('response_x', response_x);//GetFinancialProfileResponse_elementFuture
            }else if(requestName == 'MergeRequest'){
                AsyncSoapStjudeOrg.MergeResponse_elementFuture response_x = new AsyncSoapStjudeOrg.MergeResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'EditPlannedGiftAdvisorRequest'){
                AsyncSoapStjudeOrg.EditPlannedGiftAdvisorResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditPlannedGiftAdvisorResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'LoadTransactionRequest'){
                AsyncSoapStjudeOrg.LoadTransactionResponse_elementFuture response_x = new AsyncSoapStjudeOrg.LoadTransactionResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'VersionRequest'){
                AsyncSoapStjudeOrg.VersionResponse_elementFuture response_x = new AsyncSoapStjudeOrg.VersionResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'EditInteractionRequest'){
                AsyncSoapStjudeOrg.EditInteractionResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditInteractionResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'EditInteractionRequest'){
                AsyncSoapStjudeOrg.EditInteractionResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditInteractionResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'EditContactPreferenceRequest'){
                AsyncSoapStjudeOrg.EditContactPreferenceResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditContactPreferenceResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'SearchConstituentsRawRequest'){
                AsyncSoapStjudeOrg.SearchConstituentsRawResponse_elementFuture response_x = new AsyncSoapStjudeOrg.SearchConstituentsRawResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'GetContactPreferencesRequest'){
                AsyncSoapStjudeOrg.GetContactPreferencesResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetContactPreferencesResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'GetLoyaltyProfileRequest'){
                AsyncSoapStjudeOrg.GetLoyaltyProfileResponse_elementFuture response_x = new AsyncSoapStjudeOrg.GetLoyaltyProfileResponse_elementFuture();
                response.put('response_x', response_x);
            }else if(requestName == 'EditTransactionRequest'){
                AsyncSoapStjudeOrg.EditTransactionResponse_elementFuture response_x = new AsyncSoapStjudeOrg.EditTransactionResponse_elementFuture();
                response.put('response_x', response_x);
            }                               
            
        }

        private String GetConstituentResponse() {
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

    }
	
}