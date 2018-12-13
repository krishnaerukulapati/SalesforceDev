@isTest
global class ECCChallengeSegBatTest {
	
	@TestSetup
    static void prepareData(){
        EmailSettings__c emailSet = new EmailSettings__c(name = 'Heroes Segmentation',Email__c= 'HeroesSegmentation@test.com');
        insert emailSet;
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.ActHoursToWait__c = 22;
        es.Act2HoursToWait__c = 22;
        es.CultHoursToWait__c = 22;
        es.Cult2HoursToWait__c = 22;
        es.ChallHoursToWait__c = 22;
        insert es;
    }

    static testMethod void leadWithOpp(){

        Account a = new Account(Name = ECCChallengeSegBat.accountName);
        insert a;
        
        Statuses__x st = new Statuses__x();
        st.Status1__c = 'Active';
        st.StatusID__c = Guid.createGuid();
        
        EventMasters__x em = new EventMasters__x();
        em.EventMasterName__c = 'Masters NAme';
        em.EventMasterID__c = Guid.createGuid();
        em.StatusID__c = st.StatusID__c;
         
        States__x state = new States__x();
        state.StateID__c = Guid.createGuid();
        state.StateCode__c='12345';
        
        Events__x evnt = new Events__x();
        evnt.EventId__c = Guid.createGuid();
        evnt.StatusID__c = st.StatusID__c;
        evnt.EventCode__c = '12345';
        evnt.EventName__c = 'Name';
        evnt.StartDate__c = Date.valueOf(system.today());
        evnt.EventMasterID__c = em.EventMasterID__c;
        evnt.StateID__c = state.StateID__c; 
        EventNotes__x evntnote =  new EventNotes__x();
        //evntnote.Notes__c = 'notes';
        evntnote.EventID__c = evnt.EventId__c;

 		String parCampId;
        Campaign c = new Campaign( Name = 'Test parent PCampaign' , EventId__c = '1234'  , OppRecordType__c = 'St_Jude_Challenge'  , OppAcc__c = a.Id , EventTypeID__c = '123456');
        insert c;
        parCampId = c.Id;

 		Campaign ch = new Campaign( Name = 'Test child CCampaign', SegFiltRev__c = 0,  SegFiltReg__c = ' ', SegFiltPart__c = ' ',  SegStageName__c = 'Staged',
            	SegHrsToWait__c = 0,  AllowPreStages__c = '',  EventTypeID__c = '123456', IsSeg__c = true,  ParentId = c.Id);
        insert ch;

        system.debug('c.id = ' + c.id);
        list<Campaign> childCmpLst = new list<Campaign>();
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.chall15SegName, SegName__c = ECCChallengeSegBat.chall15SegName, IsSeg__c = true, ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.chall30SegName, SegName__c= ECCChallengeSegBat.chall30SegName, IsSeg__c = true, ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.chall500SegName, SegName__c= ECCChallengeSegBat.chall500SegName, IsSeg__c = true, ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.chall1000SegName, SegName__c= ECCChallengeSegBat.chall1000SegName, IsSeg__c = true,  ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.chall2000SegName, SegName__c= ECCChallengeSegBat.chall2000SegName, IsSeg__c = true,  ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.challMonSegName, SegName__c= ECCChallengeSegBat.challMonSegName, IsSeg__c = true, ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.challMon2SegName, SegName__c= ECCChallengeSegBat.challMon2SegName, IsSeg__c = true, ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        childCmpLst.add(new Campaign(Name = ECCChallengeSegBat.challCancelSegName, SegName__c= ECCChallengeSegBat.challCancelSegName, IsSeg__c = true, ParentId = ch.id, EndDate = Date.valueOf(system.today())));
        
        insert childCmpLst;

        //this lead doesn't have an opportunity
        Lead l = new Lead( LastName = 'TestLead1', Status = 'Open', Company = 'Test', TransSourceCode__c = '12345678910', EventID__c = '12345',
        	Account_id__c = '123456',  TR_ID__c = '321654', CurrentCampaign__c = parCampId, XREF__c = 'test|one',
        	CoordinatorID__c = Guid.createGuid(), ConstituentID__c = 'ORGANIZATION'
        	, Constituent_Type__c = 'ORGANIZATION' );
      
        insert l;
		system.debug('l.id = ' + l.id);

		
        Opportunity opp = new Opportunity(
            Name = 'test',
            StageChanged__c = System.today(),
            Probability = 0.0,
            Stagename = 'Staged', 
            CloseDate=System.today(),
            Revenue__c = 5.00,
            CampaignId = c.Id,
            EventId__c = '12345', 
            Event_Organizer__c = l.id
            );
        insert opp;
        system.debug('l.id after opp= ' + l.id);

        //this lead doesn't have an opportunity
        Lead l2 = new Lead( LastName = 'TestLead1', Status = 'Open', Company = 'Test', TransSourceCode__c = '12345677910', EventID__c = '12345',
            Account_id__c = '1234567',  TR_ID__c = '3216547', CurrentCampaign__c = parCampId, XREF__c = 'test|one',
            CoordinatorID__c = Guid.createGuid(), ConstituentID__c = 'ORGANIZATION'
            , Constituent_Type__c = 'ORGANIZATION' );
      
        insert l2;
        system.debug('l2.id = ' + l2.id);

        Opportunity oppTwo = new Opportunity(
            Name = 'test',
            StageChanged__c = System.today(),
            Probability = 0.0,
            Stagename = 'Some Complete', 
            CloseDate=System.today(),
            Revenue__c = 850.00,
            CampaignId = c.Id,
            EventId__c = '1234567',
            Event_Organizer__c = l2.id);
        insert oppTwo;

        System.debug('opp in test calss = ' + opp.StageChanged__c);

        CampaignMember cmem = new CampaignMember(CampaignId = ch.id, LeadId = l.id);
        insert cmem;

        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;

		List<Opportunity> oppLst = new List<Opportunity>();
        oppLst.add(New Opportunity(Name='Op Tesr', CloseDate=date.valueOf(system.today()),StageName=ECCChallengeSegBat.prosStage 
        ,accountId=a.id,Probability = 10, EventId__c = '12345345', StageChanged__c = System.today(), Revenue__c=0,Event_Organizer__c = l.id));
        insert oppLst;

        Task t = new Task(
            Subject = 'Email: Welcome',
            WhatId = opp.Id);

        insert t;
        
        Task t1 = new Task(
            Subject = 'Email: Encouragement',
            WhatId = oppTwo.Id);

        insert t1;

        system.debug('ch.Id = ' + ch.Id);
        Test.startTest();

        /*PageReference pageRef = Page.FitnessHighlights;
        Test.setCurrentPage(pageRef);*/
        Test.setMock(WebServiceMock.class, new ECCChallengeSegBatMock());

        ApexPages.currentPage().getParameters().put('id', c.id);
        l.ConstituentID__c = 'test';
        l.Constituent_Type__c = '';
    //    ccac.reLoad();
        l.account_id__c = 'test';
        update l;
        DataBase.executeBatch(new ECCChallengeSegBat(ch.Id));
        List<Email__c> ems = new List<Email__c>();
        ECCChallengeSegBat.emailSaves('test@test.com',
            'template',
            'firstname',
            'eventcode',
            String.valueOf(DateTime.now()),
            ems);
        ECCChallengeSegBat.GetEnvelope();
        Test.stopTest();
        
    }

	global class ECCChallengeSegBatMock implements WebServiceMock {
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
            else if(requestName == 'GetPreferencesRequest') {
            	system.debug('GetPreferencesRequest');
                soapStjudeOrg.GetPreferencesResponse_element ecre = new soapStjudeOrg.GetPreferencesResponse_element();
                domainSoapStjudeOrg.Preference p = new domainSoapStjudeOrg.Preference();
                p.Preference = '2email';
                p.PreferenceValue = 'no';
                ecre.Preferences = new domainSoapStjudeOrg.Preference[] { p };
                response.put('response_x', ecre); 
                system.debug('response = ' + response);
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