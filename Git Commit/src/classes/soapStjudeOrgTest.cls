@isTest
global class soapStjudeOrgTest {
    
    @isTest static void testSoap() {
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        
        soapStJudeOrg.MergeResponse_element MergeResponse_element_inst = new soapStJudeOrg.MergeResponse_element();
        soapStJudeOrg.LoadTransactionResponse_element LoadTransactionResponse_element_inst = new soapStJudeOrg.LoadTransactionResponse_element();
        soapStJudeOrg.SearchConstituentsRawResponse_element SearchConstituentsRawResponse_element_inst = new soapStJudeOrg.SearchConstituentsRawResponse_element();
        soapStJudeOrg.CreatePhoneRequest_element CreatePhoneRequest_element_inst = new soapStJudeOrg.CreatePhoneRequest_element();
        soapStJudeOrg.CreateEmailResponse_element CreateEmailResponse_element_inst = new soapStJudeOrg.CreateEmailResponse_element();
        soapStJudeOrg.GetConstituentResponse_element GetConstituentResponse_element_inst = new soapStJudeOrg.GetConstituentResponse_element();
        soapStJudeOrg.GetPlannedGiftsRequest_element GetPlannedGiftsRequest_element_inst = new soapStJudeOrg.GetPlannedGiftsRequest_element();
        soapStJudeOrg.GetLoyaltyProfileResponse_element GetLoyaltyProfileResponse_element_inst = new soapStJudeOrg.GetLoyaltyProfileResponse_element();
        soapStJudeOrg.GetContactAttributesResponse_element GetContactAttributesResponse_element_inst = new soapStJudeOrg.GetContactAttributesResponse_element();
        soapStJudeOrg.LoadTransactionRequest_element LoadTransactionRequest_element_inst = new soapStJudeOrg.LoadTransactionRequest_element();
        soapStJudeOrg.CreateConstituentResponse_element CreateConstituentResponse_element_inst = new soapStJudeOrg.CreateConstituentResponse_element();
        soapStJudeOrg.CreatePreferenceRequest_element CreatePreferenceRequest_element_inst = new soapStJudeOrg.CreatePreferenceRequest_element();
        soapStJudeOrg.EditTransactionResponse_element EditTransactionResponse_element_inst = new soapStJudeOrg.EditTransactionResponse_element();
        soapStJudeOrg.RemovePropertyRequest_element RemovePropertyRequest_element_inst = new soapStJudeOrg.RemovePropertyRequest_element();
        soapStJudeOrg.EditEmailResponse_element EditEmailResponse_element_inst = new soapStJudeOrg.EditEmailResponse_element();
        soapStJudeOrg.EditConstituentResponse_element EditConstituentResponse_element_inst = new soapStJudeOrg.EditConstituentResponse_element();
        soapStJudeOrg.GetInteractionsRequest_element GetInteractionsRequest_element_inst = new soapStJudeOrg.GetInteractionsRequest_element();
        soapStJudeOrg.CreateAddressResponse_element CreateAddressResponse_element_inst = new soapStJudeOrg.CreateAddressResponse_element();
        soapStJudeOrg.EditPlannedGiftAdvisorResponse_element EditPlannedGiftAdvisorResponse_element_inst = new soapStJudeOrg.EditPlannedGiftAdvisorResponse_element();
        soapStJudeOrg.VersionResponse_element VersionResponse_element_inst = new soapStJudeOrg.VersionResponse_element();
        soapStJudeOrg.RemoveInterestResponse_element RemoveInterestResponse_element_inst = new soapStJudeOrg.RemoveInterestResponse_element();
        soapStJudeOrg.GetTransactionsRequest_element GetTransactionsRequest_element_inst = new soapStJudeOrg.GetTransactionsRequest_element();
        soapStJudeOrg.EditPlannedGiftRequest_element EditPlannedGiftRequest_element_inst = new soapStJudeOrg.EditPlannedGiftRequest_element();
        soapStJudeOrg.CreateEmailRequest_element CreateEmailRequest_element_inst = new soapStJudeOrg.CreateEmailRequest_element();
        soapStJudeOrg.SearchEventsRequest_element SearchEventsRequest_element_inst = new soapStJudeOrg.SearchEventsRequest_element();
        soapStJudeOrg.CreatePlannedGiftResponse_element CreatePlannedGiftResponse_element_inst = new soapStJudeOrg.CreatePlannedGiftResponse_element();
        soapStJudeOrg.CreateAddressRequest_element CreateAddressRequest_element_inst = new soapStJudeOrg.CreateAddressRequest_element();
        soapStJudeOrg.GetMarketingProfileRequest_element GetMarketingProfileRequest_element_inst = new soapStJudeOrg.GetMarketingProfileRequest_element();
        soapStJudeOrg.CreateContactPreferenceRequest_element CreateContactPreferenceRequest_element_inst = new soapStJudeOrg.CreateContactPreferenceRequest_element();
        soapStJudeOrg.GetContactPreferencesResponse_element GetContactPreferencesResponse_element_inst = new soapStJudeOrg.GetContactPreferencesResponse_element();
        soapStJudeOrg.GetTransactionProfileResponse_element GetTransactionProfileResponse_element_inst = new soapStJudeOrg.GetTransactionProfileResponse_element();
        soapStJudeOrg.ValidateRequest_element ValidateRequest_element_inst = new soapStJudeOrg.ValidateRequest_element();
        soapStJudeOrg.EditPhoneResponse_element EditPhoneResponse_element_inst = new soapStJudeOrg.EditPhoneResponse_element();
        soapStJudeOrg.CreatePhoneResponse_element CreatePhoneResponse_element_inst = new soapStJudeOrg.CreatePhoneResponse_element();
        soapStJudeOrg.GetEnrichmentProfileRequest_element GetEnrichmentProfileRequest_element_inst = new soapStJudeOrg.GetEnrichmentProfileRequest_element();
        soapStJudeOrg.EditContactAttributeRequest_element EditContactAttributeRequest_element_inst = new soapStJudeOrg.EditContactAttributeRequest_element();
        soapStJudeOrg.SetPropertyResponse_element SetPropertyResponse_element_inst = new soapStJudeOrg.SetPropertyResponse_element();
        soapStJudeOrg.SetInterestResponse_element SetInterestResponse_element_inst = new soapStJudeOrg.SetInterestResponse_element();
        soapStJudeOrg.EditConstituentRequest_element EditConstituentRequest_element_inst = new soapStJudeOrg.EditConstituentRequest_element();
        soapStJudeOrg.CancelTransactionResponse_element CancelTransactionResponse_element_inst = new soapStJudeOrg.CancelTransactionResponse_element();
        soapStJudeOrg.MergeRequest_element MergeRequest_element_inst = new soapStJudeOrg.MergeRequest_element();
        soapStJudeOrg.EditPlannedGiftResponse_element EditPlannedGiftResponse_element_inst = new soapStJudeOrg.EditPlannedGiftResponse_element();
        soapStJudeOrg.EditPreferenceResponse_element EditPreferenceResponse_element_inst = new soapStJudeOrg.EditPreferenceResponse_element();
        soapStJudeOrg.GetRelationshipsRequest_element GetRelationshipsRequest_element_inst = new soapStJudeOrg.GetRelationshipsRequest_element();
        soapStJudeOrg.GetConstituentXRefsRequest_element GetConstituentXRefsRequest_element_inst = new soapStJudeOrg.GetConstituentXRefsRequest_element();
        soapStJudeOrg.SearchConstituents360Request_element SearchConstituents360Request_element_inst = new soapStJudeOrg.SearchConstituents360Request_element();
        soapStJudeOrg.SetXRefRequest_element SetXRefRequest_element_inst = new soapStJudeOrg.SetXRefRequest_element();
        soapStJudeOrg.CreatePlannedGiftRequest_element CreatePlannedGiftRequest_element_inst = new soapStJudeOrg.CreatePlannedGiftRequest_element();
        soapStJudeOrg.EditContactAttributeResponse_element EditContactAttributeResponse_element_inst = new soapStJudeOrg.EditContactAttributeResponse_element();
        soapStJudeOrg.GetEnrichmentProfileResponse_element GetEnrichmentProfileResponse_element_inst = new soapStJudeOrg.GetEnrichmentProfileResponse_element();
        soapStJudeOrg.GetProfileRequest_element GetProfileRequest_element_inst = new soapStJudeOrg.GetProfileRequest_element();
        soapStJudeOrg.EditInteractionRequest_element EditInteractionRequest_element_inst = new soapStJudeOrg.EditInteractionRequest_element();
        soapStJudeOrg.GetInterestsResponse_element GetInterestsResponse_element_inst = new soapStJudeOrg.GetInterestsResponse_element();
        soapStJudeOrg.GetEventRequest_element GetEventRequest_element_inst = new soapStJudeOrg.GetEventRequest_element();
        soapStJudeOrg.GetPreferencesResponse_element GetPreferencesResponse_element_inst = new soapStJudeOrg.GetPreferencesResponse_element();
        soapStJudeOrg.GetLoyaltyProfileRequest_element GetLoyaltyProfileRequest_element_inst = new soapStJudeOrg.GetLoyaltyProfileRequest_element();
        soapStJudeOrg.GetFinancialProfileRequest_element GetFinancialProfileRequest_element_inst = new soapStJudeOrg.GetFinancialProfileRequest_element();
        soapStJudeOrg.EditEmailRequest_element EditEmailRequest_element_inst = new soapStJudeOrg.EditEmailRequest_element();
        soapStJudeOrg.GetProfileResponse_element GetProfileResponse_element_inst = new soapStJudeOrg.GetProfileResponse_element();
        soapStJudeOrg.GetContactAttributesRequest_element GetContactAttributesRequest_element_inst = new soapStJudeOrg.GetContactAttributesRequest_element();
        soapStJudeOrg.GetPlannedGiftsResponse_element GetPlannedGiftsResponse_element_inst = new soapStJudeOrg.GetPlannedGiftsResponse_element();
        soapStJudeOrg.GetPreferencesRequest_element GetPreferencesRequest_element_inst = new soapStJudeOrg.GetPreferencesRequest_element();
        soapStJudeOrg.SearchConstituentsRawRequest_element SearchConstituentsRawRequest_element_inst = new soapStJudeOrg.SearchConstituentsRawRequest_element();
        soapStJudeOrg.CreateInteractionRequest_element CreateInteractionRequest_element_inst = new soapStJudeOrg.CreateInteractionRequest_element();
        soapStJudeOrg.EditPreferenceRequest_element EditPreferenceRequest_element_inst = new soapStJudeOrg.EditPreferenceRequest_element();
        soapStJudeOrg.SetPropertyRequest_element SetPropertyRequest_element_inst = new soapStJudeOrg.SetPropertyRequest_element();
        soapStJudeOrg.DataRequest_element DataRequest_element_inst = new soapStJudeOrg.DataRequest_element();
        soapStJudeOrg.GetDocumentationRequest_element GetDocumentationRequest_element_inst = new soapStJudeOrg.GetDocumentationRequest_element();
        soapStJudeOrg.GetDocumentationResponse_element GetDocumentationResponse_element_inst = new soapStJudeOrg.GetDocumentationResponse_element();
        soapStJudeOrg.ValidateAddressRequest_element ValidateAddressRequest_element_inst = new soapStJudeOrg.ValidateAddressRequest_element();
        soapStJudeOrg.RemoveInterestRequest_element RemoveInterestRequest_element_inst = new soapStJudeOrg.RemoveInterestRequest_element();
        soapStJudeOrg.GetPropertiesRequest_element GetPropertiesRequest_element_inst = new soapStJudeOrg.GetPropertiesRequest_element();
        soapStJudeOrg.EditAddressRequest_element EditAddressRequest_element_inst = new soapStJudeOrg.EditAddressRequest_element();
        soapStJudeOrg.ValidateAddressResponse_element ValidateAddressResponse_element_inst = new soapStJudeOrg.ValidateAddressResponse_element();
        soapStJudeOrg.GetInterestsRequest_element GetInterestsRequest_element_inst = new soapStJudeOrg.GetInterestsRequest_element();
        soapStJudeOrg.AsyncC360MessageResponse_element AsyncC360MessageResponse_element_inst = new soapStJudeOrg.AsyncC360MessageResponse_element();
        soapStJudeOrg.GetContactPreferencesRequest_element GetContactPreferencesRequest_element_inst = new soapStJudeOrg.GetContactPreferencesRequest_element();
        soapStJudeOrg.GetConstituentXRefsResponse_element GetConstituentXRefsResponse_element_inst = new soapStJudeOrg.GetConstituentXRefsResponse_element();
        soapStJudeOrg.AsyncC360MessageRequest_element AsyncC360MessageRequest_element_inst = new soapStJudeOrg.AsyncC360MessageRequest_element();
        soapStJudeOrg.EditAddressResponse_element EditAddressResponse_element_inst = new soapStJudeOrg.EditAddressResponse_element();
        soapStJudeOrg.AddPlannedGiftAdvisorResponse_element AddPlannedGiftAdvisorResponse_element_inst = new soapStJudeOrg.AddPlannedGiftAdvisorResponse_element();
        soapStJudeOrg.SetXRefResponse_element SetXRefResponse_element_inst = new soapStJudeOrg.SetXRefResponse_element();
        soapStJudeOrg.CreatePreferenceResponse_element CreatePreferenceResponse_element_inst = new soapStJudeOrg.CreatePreferenceResponse_element();
        soapStJudeOrg.CreateContactPreferenceResponse_element CreateContactPreferenceResponse_element_inst = new soapStJudeOrg.CreateContactPreferenceResponse_element();
        soapStJudeOrg.SearchEventsResponse_element SearchEventsResponse_element_inst = new soapStJudeOrg.SearchEventsResponse_element();
        soapStJudeOrg.EditContactPreferenceRequest_element EditContactPreferenceRequest_element_inst = new soapStJudeOrg.EditContactPreferenceRequest_element();
        soapStJudeOrg.RemovePropertyResponse_element RemovePropertyResponse_element_inst = new soapStJudeOrg.RemovePropertyResponse_element();
        soapStJudeOrg.GetPropertiesResponse_element GetPropertiesResponse_element_inst = new soapStJudeOrg.GetPropertiesResponse_element();
        soapStJudeOrg.GetRelationshipsResponse_element GetRelationshipsResponse_element_inst = new soapStJudeOrg.GetRelationshipsResponse_element();
        soapStJudeOrg.CreateConstituentRequest_element CreateConstituentRequest_element_inst = new soapStJudeOrg.CreateConstituentRequest_element();
        soapStJudeOrg.ConstituentPort ConstituentPort_inst = new soapStJudeOrg.ConstituentPort();
        soapStJudeOrg.EditTransactionRequest_element EditTransactionRequest_element_inst = new soapStJudeOrg.EditTransactionRequest_element();
        soapStJudeOrg.ExactMatch360Response_element ExactMatch360Response_element_inst = new soapStJudeOrg.ExactMatch360Response_element();
        soapStJudeOrg.EditInteractionResponse_element EditInteractionResponse_element_inst = new soapStJudeOrg.EditInteractionResponse_element();
        soapStJudeOrg.CancelTransactionRequest_element CancelTransactionRequest_element_inst = new soapStJudeOrg.CancelTransactionRequest_element();
        soapStJudeOrg.ValidateResponse_element ValidateResponse_element_inst = new soapStJudeOrg.ValidateResponse_element();
        soapStJudeOrg.GetFinancialProfileResponse_element GetFinancialProfileResponse_element_inst = new soapStJudeOrg.GetFinancialProfileResponse_element();
        soapStJudeOrg.GetTransactionProfileRequest_element GetTransactionProfileRequest_element_inst = new soapStJudeOrg.GetTransactionProfileRequest_element();
        soapStJudeOrg.EditContactPreferenceResponse_element EditContactPreferenceResponse_element_inst = new soapStJudeOrg.EditContactPreferenceResponse_element();
        soapStJudeOrg.GetMarketingProfileResponse_element GetMarketingProfileResponse_element_inst = new soapStJudeOrg.GetMarketingProfileResponse_element();
        soapStJudeOrg.GetConstituentRequest_element GetConstituentRequest_element_inst = new soapStJudeOrg.GetConstituentRequest_element();
        soapStJudeOrg.AddPlannedGiftAdvisorRequest_element AddPlannedGiftAdvisorRequest_element_inst = new soapStJudeOrg.AddPlannedGiftAdvisorRequest_element();
        soapStJudeOrg.EditPlannedGiftAdvisorRequest_element EditPlannedGiftAdvisorRequest_element_inst = new soapStJudeOrg.EditPlannedGiftAdvisorRequest_element();
        soapStJudeOrg.ExactMatch360Request_element ExactMatch360Request_element_inst = new soapStJudeOrg.ExactMatch360Request_element();
        soapStJudeOrg.CreateInteractionResponse_element CreateInteractionResponse_element_inst = new soapStJudeOrg.CreateInteractionResponse_element();
        soapStJudeOrg.EditPhoneRequest_element EditPhoneRequest_element_inst = new soapStJudeOrg.EditPhoneRequest_element();
        soapStJudeOrg.DataResponse_element DataResponse_element_inst = new soapStJudeOrg.DataResponse_element();
        soapStJudeOrg.GetEventResponse_element GetEventResponse_element_inst = new soapStJudeOrg.GetEventResponse_element();
        soapStJudeOrg.VersionRequest_element VersionRequest_element_inst = new soapStJudeOrg.VersionRequest_element();
        soapStJudeOrg.SetInterestRequest_element SetInterestRequest_element_inst = new soapStJudeOrg.SetInterestRequest_element();
        
        Test.setMock(WebServiceMock.class, new soapStjudeOrgMock());

        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        cp.SearchConstituents360(null, null, null, null, null, null, null);
        cp.GetConstituent(null, null, null, null, null, null, null, null, null,null,null);
        cp.GetTransactions(null, null , null, null, null, null, null, null, null);
        cp.GetConstituentXRefs(null, null, null, null);
        cp.EditConstituent(null, null, null, null, null, null);
        cp.CreateConstituent(null, null, null, null,null,null,null);
        cp.GetInteractions(null, null, null, null, null, null, null,null);
        cp.getData(null, null, null);
        cp.GetPreferences(null, null, null, null, null, null);
        cp.EditPreference(null, null, null, null, null, null, null, 
                null, null, null, null, null, null);
        Test.stopTest();
    }

    @isTest static void testOther() {
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();

        Test.setMock(WebServiceMock.class, new soapStjudeOrgMock());

        soapStjudeOrg.ConstituentPort cp = new soapStjudeOrg.ConstituentPort();
        cp.CreatePreference(null, null, null, null, null, null, null, null,
                null, null, null, null);
        cp.GetProperties(null, null, null, null, null);
        cp.RemoveProperty(null, null, null, null, null);
        cp.SetProperty(null, null, null, null, null);
        cp.GetRelationships(null, null, null, null, null);
        cp.CreateInteraction(null, null, null, null, null,null);
        //cp.GetContactAttributes(null,null, null, null);
        cp.AsyncC360Message(null, null);
        cp.Setxref(null,null);
        cp.ExactMatch360(null,null,null,null);
        cp.GetTransactionProfile(null,null,null,null,null);
        cp.GetInterests(null,null,null,null,null);
        cp.CancelTransaction(null,null,null,null,null,null,null,null,null,null,null);
        cp.EditContactAttribute(null,null,null,null,null);
        cp.RemoveInterest(null,null,null,null,null);
        //cp.CreateEmail(null,null,null,null,null);
        cp.GetPlannedGifts(null,null,null,null,null,null);
        cp.GetMarketingProfile(null,null,null,null);
        cp.GetProfile(null,null,null,null,null,null,null);
        cp.EditPlannedGift(null,null,null,null,null,null);
        //cp.EditPhone(null,null,null,null,null);
        cp.CreateContactPreference(null,null,null,null,null,null,null,null,null,null,null,null,null,null,null);
        cp.setInterest(null,null,null,null,null);
        cp.GetEnrichmentProfile(null,null,null,null);
        cp.SearchEvents(null,null,null,null,null);
        cp.ValidateService(null, null);
        cp.AddPlannedGiftAdvisor(null,null,null,null,null,null);
        cp.GetFinancialProfile(null,null,null,null,null,null);
        cp.Merge_x(null,null,null,null);
        cp.EditPlannedGiftAdvisor(null,null,null,null,null,null);
        cp.LoadTransaction(null,null,null,null,null,null);
        cp.Version(null);
        cp.EditInteraction(null,null,null,null,null,null);
        cp.EditContactPreference(null,null,null,null,null,null,null,null,null,null,null,null,null);
        cp.SearchConstituentsRaw(null,null,null,null,null,null,null);
        cp.GetContactPreferences(null,null,null,null,null,null,null,null,null);
        cp.GetLoyaltyProfile(null,null,null,null);
        cp.EditTransaction(null,null,null,null,null,null,null);
        Test.stopTest();
    }

    
    global class soapStjudeOrgMock implements WebServiceMock {
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
                soapStjudeOrg.CreateInteractionResponse_element cire = new soapStjudeOrg.CreateInteractionResponse_element();
                cire.Result = 'result';

                response.put('response_x', cire);
            }
            else if (requestName == 'DataRequest') {
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
            else if(requestName == 'CreateConstituentRequest') {
                soapStjudeOrg.CreateConstituentResponse_element ccre = new soapStjudeOrg.CreateConstituentResponse_element();
                ccre.CreatedConstituent = new domainSoapStjudeOrg.Constituent();
                ccre.CreatedConstituent.ConstituentId = 'notaguid';
                response.put('response_x', ccre); 
            }
            else if(requestName == 'GetPreferencesRequest') {
                soapStjudeOrg.GetPreferencesResponse_element ecre = new soapStjudeOrg.GetPreferencesResponse_element();
                domainSoapStjudeOrg.Preference p = new domainSoapStjudeOrg.Preference();
                p.PreferenceId = 'doesnt';
                ecre.Preferences = new domainSoapStjudeOrg.Preference[] { p };
                response.put('response_x', ecre); 
            }
            else if(requestName == 'EditPreferenceRequest') {
                soapStjudeOrg.EditPreferenceResponse_element ecre = new soapStjudeOrg.EditPreferenceResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'CreatePreferenceRequest') {
                soapStjudeOrg.CreatePreferenceResponse_element ecre = new soapStjudeOrg.CreatePreferenceResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'SetPropertyRequest') {
                soapStjudeOrg.SetPropertyResponse_element ecre = new soapStjudeOrg.SetPropertyResponse_element();
                ecre.Result = 'result';

                response.put('response_x', ecre); 
            }
            else if(requestName == 'EditPreferenceRequest') {
                soapStjudeOrg.EditPreferenceResponse_element ecre = new soapStjudeOrg.EditPreferenceResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'CreatePreferenceRequest') {
                soapStjudeOrg.CreatePreferenceResponse_element ecre = new soapStjudeOrg.CreatePreferenceResponse_element();
                ecre.Result = 'Result';
                response.put('response_x', ecre); 
            }
            else if(requestName == 'SearchConstituents360Request') {
                soapStjudeOrg.SearchConstituents360Response_element gcre = new soapStjudeOrg.SearchConstituents360Response_element();
                gcre.TotalResults = 9;
                objectSoapStjudeOrg.SearchResponse con = new objectSoapStjudeOrg.SearchResponse();

                gcre.Constituents = new objectSoapStjudeOrg.SearchResponse[] { con };
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetPreferencesRequest') {
                soapStjudeOrg.GetPreferencesResponse_element gcre = new soapStjudeOrg.GetPreferencesResponse_element();
  
                gcre.Preferences = new domainSoapStjudeOrg.Preference[] {
                    new domainSoapStjudeOrg.Preference()
                };
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetPropertiesRequest') {
                soapStjudeOrg.GetPropertiesResponse_element gcre = new soapStjudeOrg.GetPropertiesResponse_element();
  
                gcre.Properties = new domainSoapStjudeOrg.Property[] {
                    new domainSoapStjudeOrg.Property()
                };
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'RemovePropertyRequest') {
                soapStjudeOrg.RemovePropertyResponse_element gcre = new soapStjudeOrg.RemovePropertyResponse_element();
  
                gcre.Result = 'yep';
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetRelationshipsRequest') {
                soapStjudeOrg.GetRelationshipsResponse_element gcre = new soapStjudeOrg.GetRelationshipsResponse_element();
  
                gcre.TotalResults = 1;
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'RemovePropertyRequest') {
                soapStjudeOrg.RemovePropertyResponse_element gcre = new soapStjudeOrg.RemovePropertyResponse_element();
  
                gcre.Result = 'yep';
                                
                response.put('response_x', gcre); 
            }
            else if(requestName == 'GetInteractionsRequest') {
                soapStjudeOrg.GetInteractionsResponse_element gcre = new soapStjudeOrg.GetInteractionsResponse_element();

                response.put('response_x', gcre); 
            }
            
            else if(requestName == 'GetConstituentXRefsRequest') {
                soapStjudeOrg.GetConstituentXRefsResponse_element gcre = new soapStjudeOrg.GetConstituentXRefsResponse_element();
                gcre.Constituent360XRef = new  domainSoapStjudeOrg.Constituent360XRef();
                domainSoapStjudeOrg.Constituent con = new domainSoapStjudeOrg.Constituent();
                con.ConstituentId = 'test';

                gcre.Constituent360XRef.Constituents = new domainSoapStjudeOrg.Constituent[] {con};

                response.put('response_x', gcre); 
            }
            else if (requestName == 'GetTransactionsRequest') {
                soapStjudeOrg.GetTransactionsResponse_element de = new soapStjudeOrg.GetTransactionsResponse_element();
                de.TotalResults = 50;

                response.put('response_x', de);
            }else if(requestName == 'AsyncC360MessageRequest'){
                soapStjudeOrg.AsyncC360MessageResponse_element re = new soapStjudeOrg.AsyncC360MessageResponse_element();
                re.result = 'test';
                response.put('response_x', re);
            }else if(requestName == 'SetXRefRequest'){
                soapStjudeOrg.SetXRefResponse_element xrefRe = new soapStjudeOrg.SetXRefResponse_element();
                response.put('response_x', xrefRe);
            }else if(requestName == 'ExactMatch360Request'){
                soapStjudeOrg.ExactMatch360Response_element exactRe = new soapStjudeOrg.ExactMatch360Response_element();
                exactRe.constituent = new objectSoapStjudeOrg.MatchResponse();
                exactRe.constituent.ConstituentId = 'test';
                response.put('response_x', exactRe );
            }else if(requestName == 'GetContactAttributesResponse'){
                soapStjudeOrg.GetContactAttributesResponse_element gCAR = new soapStjudeOrg.GetContactAttributesResponse_element();
                //objectSoapStjudeOrg.KeyVal[]
                gCAR.Result = new objectSoapStjudeOrg.KeyVal[]{new objectSoapStjudeOrg.KeyVal()};
                response.put('response_x', gCAR);
            }else if(requestName == 'GetTransactionProfileRequest'){
                soapStjudeOrg.GetTransactionProfileResponse_element txnRes = new soapStjudeOrg.GetTransactionProfileResponse_element();
                txnRes.TransactionProfile = new domainSoapStjudeOrg.TransactionProfile();
                response.put('response_x', txnRes);
            }else if(requestName == 'GetInterestsRequest'){
                soapStjudeOrg.GetInterestsResponse_element giRes = new soapStjudeOrg.GetInterestsResponse_element();
                giRes.Interests = new domainSoapStjudeOrg.Interest[]{}; 
                response.put('response_x', giRes);
            }else if(requestName == 'CancelTransactionRequest'){
            	soapStjudeOrg.CancelTransactionResponse_element response_x = new soapStjudeOrg.CancelTransactionResponse_element();
            	response_x.Result = 'Success';
            	response.put('response_x', response_x);
            }else if(requestName == 'EditContactAttributeRequest'){
            	soapStjudeOrg.EditContactAttributeResponse_element response_x = new soapStjudeOrg.EditContactAttributeResponse_element();
            	response_x.Result = 'Success';
            	response.put('response_x', response_x);
            }else if(requestName == 'RemoveInterestRequest'){
            	soapStjudeOrg.RemoveInterestResponse_element response_x = new soapStjudeOrg.RemoveInterestResponse_element();
            	response_x.Result = 'Success';
            	response.put('response_x', response_x);
            }else if(requestName == 'GetPlannedGiftsRequest'){
            	soapStjudeOrg.GetPlannedGiftsResponse_element response_x = new soapStjudeOrg.GetPlannedGiftsResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'GetMarketingProfileRequest'){
            	soapStjudeOrg.GetMarketingProfileResponse_element response_x = new soapStjudeOrg.GetMarketingProfileResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'EditPlannedGiftRequest'){
            	soapStjudeOrg.EditPlannedGiftResponse_element response_x = new soapStjudeOrg.EditPlannedGiftResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'CreateContactPreferenceRequest'){
            	soapStjudeOrg.CreateContactPreferenceResponse_element response_x = new soapStjudeOrg.CreateContactPreferenceResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'SetInterestRequest'){
            	soapStjudeOrg.SetInterestResponse_element response_x = new soapStjudeOrg.SetInterestResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'GetEnrichmentProfileRequest'){
            	soapStjudeOrg.GetEnrichmentProfileResponse_element response_x = new soapStjudeOrg.GetEnrichmentProfileResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'GetProfileRequest'){
            	soapStjudeOrg.GetProfileResponse_element response_x = new soapStjudeOrg.GetProfileResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'SearchEventsRequest'){
            	soapStjudeOrg.SearchEventsResponse_element response_x = new soapStjudeOrg.SearchEventsResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'ValidateRequest'){
            	soapStjudeOrg.ValidateResponse_element response_x = new soapStjudeOrg.ValidateResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'AddPlannedGiftAdvisorRequest'){
            	soapStjudeOrg.AddPlannedGiftAdvisorResponse_element response_x = new soapStjudeOrg.AddPlannedGiftAdvisorResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'GetFinancialProfileRequest'){
            	soapStjudeOrg.GetFinancialProfileResponse_element response_x = new soapStjudeOrg.GetFinancialProfileResponse_element();
            	response.put('response_x', response_x);//GetFinancialProfileResponse_element
            }else if(requestName == 'MergeRequest'){
            	soapStjudeOrg.MergeResponse_element response_x = new soapStjudeOrg.MergeResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'EditPlannedGiftAdvisorRequest'){
            	soapStjudeOrg.EditPlannedGiftAdvisorResponse_element response_x = new soapStjudeOrg.EditPlannedGiftAdvisorResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'LoadTransactionRequest'){
            	soapStjudeOrg.LoadTransactionResponse_element response_x = new soapStjudeOrg.LoadTransactionResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'VersionRequest'){
            	soapStjudeOrg.VersionResponse_element response_x = new soapStjudeOrg.VersionResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'EditInteractionRequest'){
            	soapStjudeOrg.EditInteractionResponse_element response_x = new soapStjudeOrg.EditInteractionResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'EditInteractionRequest'){
            	soapStjudeOrg.EditInteractionResponse_element response_x = new soapStjudeOrg.EditInteractionResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'EditContactPreferenceRequest'){
            	soapStjudeOrg.EditContactPreferenceResponse_element response_x = new soapStjudeOrg.EditContactPreferenceResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'SearchConstituentsRawRequest'){
            	soapStjudeOrg.SearchConstituentsRawResponse_element response_x = new soapStjudeOrg.SearchConstituentsRawResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'GetContactPreferencesRequest'){
            	soapStjudeOrg.GetContactPreferencesResponse_element response_x = new soapStjudeOrg.GetContactPreferencesResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'GetLoyaltyProfileRequest'){
            	soapStjudeOrg.GetLoyaltyProfileResponse_element response_x = new soapStjudeOrg.GetLoyaltyProfileResponse_element();
            	response.put('response_x', response_x);
            }else if(requestName == 'EditTransactionRequest'){
            	soapStjudeOrg.EditTransactionResponse_element response_x = new soapStjudeOrg.EditTransactionResponse_element();
            	response.put('response_x', response_x);
            }                               
            
        }
    }
}