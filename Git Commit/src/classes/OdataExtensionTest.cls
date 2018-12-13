@isTest
global with sharing class OdataExtensionTest {

  @Testsetup
  static void testData(){
      OdataExtensionSettings__c odataSettings = new OdataExtensionSettings__c(setupOwnerId = UserInfo.getOrganizationId(),
          Event_Roles_Endpoint__c = 'EventRoles', Base_URL__c = 'https://services.qa.stjude.org/dev/odata/',
          Role_Attributes_Endpoint__c = 'RoleAttributes', Timeout_Milliseconds__c = 60000,
          Role_Types_Endpoint__c = 'RoleTypes', Username__c = 'alsacnt/eventmasterqa',
          password__c = 'a1evt$QA', Events_Endpoint__c = 'Events',
          Event_Masters_Endpoint__c = 'EventMasters', Event_Attributes_Endpoint__c = 'EventAttributes',
          Event_Constituents_Endpoint__c = 'EventConstituents', Role_Type_Attributes_Endpoint__c = 'RoleAttributes',
          Event_Constituent_Roles_Endpoint__c = 'EventConstituentRoles',
          Event_Notes_Endpoint__c = 'EventNotes');
    insert odataSettings;  
    Test.startTest();
    OdataExtension odex = new OdataExtension(new ApexPages.StandardController(odataSettings));
    Test.stopTest();                                                                         
  } 

  static testmethod void testSaveFOInteraction(){
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new OdataExtensionMock());
      OdataExtension.saveFOInteraction(null, new FOInteractions__x());
      Test.stopTest();
  }

  static testmethod void saveOIMOrderAndLineItem(){
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new OdataExtensionMock());
      OdataExtension.saveOIMOrder(null, new Orders__x());
      OdataExtension.saveOIMLineItem(null, new LineItems__x());
      Test.stopTest();
  }

  static testmethod void testSaveEvent(){
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new OdataExtensionMock());
      OdataExtension.saveEvent(null, new Events__x());
      OdataExtension.saveEventAttribute(null, new EventAttributes__x());
      OdataExtension.saveEventConstituent(null, new EventConstituents__x());
      OdataExtension.saveEventConstituentRole(null, new EventConstituentRoles__x());
      OdataExtension.saveEventNote(null, new EventNotes__x());
      OdataExtension.saveEventMaster(null, new EventMasters__x());
      OdataExtension.eventsByQuery('select EventId__c from Events__x',system.now(), system.now());
      Test.stopTest();        
  }
   
  static testmethod void testGetEvent(){

      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new OdataExtensionMock());
      OdataExtension.GetEventByName(null, False);
      OdataExtension.GetEventByName(null);
      OdataExtension.GetEventAttributeViews(null);
      OdataExtension.GetEventMasterByName(null);
      OdataExtension.GetEventAttributeViews(null, false);
      OdataExtension.GetStates();
      OdataExtension.GetContactTypes();
      OdataExtension.GetEventMasterByName(null, false);
      OdataExtension.GetEventMasterByName(null, true);
      //OdataExtension.GetEcrvFromConsId(null, null);
      OdataExtension.GetEventMasterById(null);
      OdataExtension.GetEventTypeAttributeViews(null);
      OdataExtension.GetEventByName(null, True);
      OdataExtension.GetEventTypeRolesByRoleType(null, null, null);
      OdataExtension.GetPreferredConstituentInfos(null);
      //OdataExtension.GetEventMasterByOrg(null, null, null);
      //OdataExtension.GetECFromEventId(null, null, null);
      OdataExtension.GetEventNotesByEventID(null);
      OdataExtension.GetTREventRegDetailByConsEvent(null, null);
      OdataExtension.getEventConsRoleAttrViews(null, null);
      OdataExtension.GetEventRegDetailsByEventIdCons(new List<Decimal> { null }, new List<Decimal> { null });
      OdataExtension.GetTREventDetailByEvent(null);
      //OdataExtension.GetContactTypeById(null);
      OdataExtension.GetEventTypeById(null);
      OdataExtension.GetRoles(null);
      OdataExtension.GetAllEventTypes();
      OdataExtension.GetEventsById(new set<string>{Guid.createGuid()});
      OdataExtension.GetEventConstituentRoleViews(new set<string>{Guid.createGuid()}, null);
      OdataExtension.GetEventById(new set<string>{Guid.createGuid()});
      OdataExtension.GetRecruitedEvents(new set<string>{null});
      OdataExtension.GetEventRevenueFromRecruitedEvents(new set<string>{null});
      OdataExtension.GetProgramtype(null);
      OdataExtension.GetReasons();
      Test.stopTest();        
  }

  static testmethod void testCountByQuery(){
      List<AggregateResult> testRes = new List<AggregateResult>();
      testRes = null;
      String q = 'test';
      Test.startTest();
      OdataExtension.countByQuery(q, testRes);
      Test.stopTest();
  }

  static testmethod void testV_ProductInfoQuery(){
      List<V_ProductInfo__x> testRes = new List<V_ProductInfo__x>();
      testRes = null;
      String q = 'test';
      Test.startTest();
      OdataExtension.V_ProductInfoQuery(q, testRes);
      Test.stopTest();
  }

  static testmethod void testV_OrderInfoQuery(){
    List<V_OrderInfo__x> testRes = new List<V_OrderInfo__x>();
    testRes = null;
    String q = 'test';
    Test.startTest();
    OdataExtension.V_OrderInfoQuery(q, testRes);
    Test.stopTest();
  }

  static testmethod void testV_LineItemInfoQuery(){
      List<V_LineItemInfo__x> testRes = new List<V_LineItemInfo__x>();
      testRes = null;
      String q = 'test';
      Test.startTest();
      OdataExtension.V_LineItemInfoQuery(q, testRes);
      Test.stopTest();
  }

  static testmethod void testLookupValuesByTopic(){
    List<LookupValues__x> testRes = new List<LookupValues__x>();
    String topic = 'test';
    Boolean includeInactive = true;
    Test.startTest();
    OdataExtension.LookupValuesByTopic(topic, includeInactive, testRes);
    Test.stopTest();
  }

  //static testmethod void testV_OrderInfoByOrderId(){
  //  String orderId = 'test';
  //  Test.startTest();
  //  OdataExtension.V_OrderInfoByOrderId(orderId);
  //  Test.stopTest();
  //}

  static testmethod void testGetIncentiveInfosByCampCons(){
    String campaignId = 'testCamp';
    String consId = 'test';
    Test.startTest();
    OdataExtension.GetIncentiveInfosByCampCons(campaignId, consId);
    Test.stopTest();
  }

  static testmethod void testGetMarathonRecommits(){
    Decimal eventId = 1.5;
    String consId = 'test';
    Test.startTest();
    OdataExtension.GetMarathonRecommits(eventId, consId);
    Test.stopTest();
  }

  static testmethod void testGetDMSPlanByConsId(){
    String consId = 'test';
    Boolean isActive = true;
    Test.startTest();
    OdataExtension.GetDMSPlanByConsId(consId, isActive);
    Test.stopTest();
  }

  //static testmethod void testGetTREventRegDetailByRegId(){
  //  Decimal regId = 1.5;
  //  Test.startTest();
  //  OdataExtension.GetTREventRegDetailByRegId(regId);
  //  Test.stopTest();
  //}

  static testmethod void testGetSingletOrdersByEvent(){
    Decimal eventId = 1.5;
    Decimal consId = 2.5;
    Test.startTest();
    OdataExtension.GetSingletOrdersByEvent(eventId, consId);
    Test.stopTest();
  }

  static testmethod void testGetEventAttributesOfflineViews_ByEvIDETAIDs(){
    List<String> eventIds = new List<String>();
    String eventId = 'test';
    List<String> eventTypeAttributeIDs = new List<String>();
    Test.startTest();
    OdataExtension.GetEventAttributeOfflineViews(eventIds);
    OdataExtension.GetEventAttributesByEvIDETAIDs(eventId, eventTypeAttributeIDs);
    Test.stopTest();
  }  

  static testmethod void testGetEventConstituentRoleViewsByConstituentID(){
    Set<string> setEventIds = new Set<string>();
    String constituentID = 'test';
    Test.startTest();
    OdataExtension.GetEventConstituentRoleViews(setEventIds);
    OdataExtension.GetEventConstituentRoleViewsByConstituentID(constituentID);
    Test.stopTest();
  }

  static testmethod void testGetEventConsRoleAttrViews(){
    List<String> eventId = new List<String>{'aa', 'bb', 'cc'};
    String consId = 'test';
    String attrName = 'test2';
    Test.startTest();
    OdataExtension.getEventConsRoleAttrViews(eventId, consId, attrName);
    OdataExtension.getEventConsRoleAttrViews(eventId, consId, null);
    OdataExtension.getEventConsRoleAttrViews(eventId, null, null);
    Test.stopTest();
  }

  static testmethod void testGetCoordEvent(){
    String consId = 'testconsId';
    Decimal fiscalYear = 1.5;
    String eventTypeId = 'testEvent';
    Test.startTest();
    OdataExtension.GetCoordEvent(consId, fiscalYear, eventTypeId);
    Test.stopTest();
  }

  static testmethod void testGetSurvQuestOptByQuestId(){
    Decimal questId = 1.5;
    Test.startTest();
    OdataExtension.GetSurvQuestOptByQuestId(questId);
    Test.stopTest();
  }

  static testmethod void testGetInteractions(){
    domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();
    Decimal accountId = 1.5;
    Decimal nameId = 2.5;
    String sourceCode = 'sourcetest';
    Test.startTest();
    OdataExtension.GetFOInteraction(i, accountId, nameId);
    OdataExtension.GetInteractions(accountId, sourceCode);
    Test.stopTest();
  }

  static testmethod void testGetStatus(){
    String statusId = 'test';
    Test.startTest();
    OdataExtension.GetStatus();
    OdataExtension.GetStatus(statusId);
    Test.stopTest();
  }

  static testmethod void testGetRevenueNotes(){
    String constituentId = 'test';
    Integer off = 1;
    Integer lim = 2;
    Test.startTest();
    OdataExtension.GetRevenueNotes(constituentId, off, lim);
    Test.stopTest();
  }

  static testmethod void testBuildHttpRequest(){
    String method = 'testMethod';
    String endpoint = 'testEndPoint';
    Boolean isNewRecord = false;
    String recordGuid = 'notaquid';
    String jsonString = 'testJson';
    Boolean isDelete = true;
    Test.startTest();
    OdataExtension.BuildHttpRequest(method, endpoint, isNewRecord, recordGuid, jsonString, isDelete);
    Test.stopTest();
  }

  static testmethod void test_GetEventHighLightsById(){
    Test.startTest();
    EventHighlights__x retval = odataextension.GetEventHighLightsById('notaguid');
    system.assert(retval != null);
    system.assert(retval.EventName__c == 'some event');
    Test.stopTest();

  }

  static testmethod void test_GetEventRevenueById(){
      Test.startTest();
    EventRevenues__x retval = odataextension.GetEventRevenueById('notaguid');
    system.assert(retval != null);
    system.assert(retval.Amount__c == 123.00);
    Test.stopTest();
  }

  //static testmethod void test_GetEventRevenueDetails(){
  //    Test.startTest();
  //    List<EventRevenueDetails__x> retval = odataextension.GetEventRevenueDetails('notaguid');
  //    system.assert(retval != null);
  //    system.assert(retval[0].TransactionAmount__c == 1000.00);
  //    Test.stopTest();
  //}

  static testmethod void test_GetEventHistorySummaryByQuery(){
      Test.startTest();
      List<EventHistorySummaries__x> retval = odataextension.GetEventHistorySummaryByQuery('some query');
      system.assert(retval != null);
      system.assert(retval[0].EventName__c == 'some event');
      Test.stopTest();
  }

  global class OdataExtensionMock implements HttpCalloutMock {
      global HTTPResponse respond(HTTPRequest req) {
          HttpResponse res = new HttpResponse();
          res.setHeader('Content-Type', 'application/json');
          res.setBody('{"foo":"bar"}');
          res.setStatusCode(299);
          return res;    
      }
  }

}