//
// (c) 2014 Appirio, Inc.
//
// Test Class for EventTrigger
//
// 23 Sept, 2014   Sumit Tanwar   Original (Ref. Task T-321188)
// 
//
@isTest
private class EventTriggerTest {
    static testMethod void myUnitTest() {
    	
    	Test.startTest();
    	Event ev = new Event(Subject='Test 1',StartDateTime=System.now(),EndDateTime=System.now(),IsAllDayEvent=true);
    	insert ev;
    	Test.stopTest(); 
    }
}