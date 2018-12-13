@isTest
global class FOUtilTest {
	
	@isTest static void TestUtil1() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new FOUtilMock());

		FOUtil.createConstituent(new domainSoapStjudeOrg.Individual());
		FOUtil.createConstituent(null, new domainSoapStjudeOrg.Household(), null);
		FOUtil.createConstituent(null, null, new domainSoapStjudeOrg.Organization());
        FOUtil.createConstituent(new domainSoapStjudeOrg.Individual(), null, null, 'test');
		FOUtil.editConstituent(new domainSoapStjudeOrg.Individual());
		FOUtil.editConstituent(null, new domainSoapStjudeOrg.Household(), null);
		FOUtil.editConstituent(null, null, new domainSoapStjudeOrg.Organization());
        FOUtil.editPhone('test', new domainSoapStjudeOrg.Phone());
		Test.stopTest();

	}

	@isTest static void TestUtil2() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new FOUtilMock());

		FOUtil.editPreference('test', 'test', 'test', 'test', 'test', 'test', 
			DateTime.Now(), DateTime.now(), 'test', 'test');
		FOUtil.getConstituent(null, null, null);
		FOUtil.getConstituent(null, null, null, null);
		FOUtil.getConstituentIds('test');
		FOUtil.getConstituentIds('test', true);
		FOUtil.getConstituentXRefs('test', 'test');
        FOUtil.editConstituent(null, null);

		Test.stopTest();
	}

	@isTest static void TestUtil3() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new FOUtilMock());

		FOUtil.getData('test');
		FOUtil.getData('test', 'test');
		FOUtil.getInteractions('test', 'test', 1, 2);
		FOUtil.getTransations('test', 'test', 1, 2, 'test', 'test');
		FOUtil.getSignature();
		FOUtil.removeProperty('test', 'test');

		Test.stopTest();
	}

	@isTest static void TestUtil4() {

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        Test.startTest();
        Test.setMock(WebServiceMock.class, new FOUtilMock());

		FOUtil.searchFO('test', '1231231234', 'test', 'test', 'test', 'test', 
			'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 1, 2);
		FOUtil.getPledgeId('test');
		FOUtil.getPreferences('test');
		FOUtil.getProperties('test');
		FOUtil.SetProperty('String consId', 'String property', 'String status', Datetime.now(), Datetime.now());
		FOUtil.getRelationships('String consId', 1, 2);
        FOUtil.createInteraction('String consId', new domainSoapStjudeOrg.Interaction());
        FOUtil.editInteraction('String consId', new domainSoapStjudeOrg.Interaction());

		Test.stopTest();
	}
	
	global class FOUtilMock implements WebServiceMock {
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
            if (requestName == 'EditInteractionRequest') {
                soapStjudeOrg.EditInteractionResponse_element cire = new soapStjudeOrg.EditInteractionResponse_element();
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
            }
		}
	}
	
}