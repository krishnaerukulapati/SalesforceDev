//
// (c) 2014 Appirio, Inc.
//
// Check if the user is authorized to create record, else generate error
//
// 30 Sept, 2014   Sumit Tanwar   Original (Ref. Task T-321188)
// 
//
public with sharing class EventTriggerHandler {
	
	public static void ckeckUserAuthorized(List<Event> isNew){
      boolean isAuth =null;
      List<Authorized_users__c> authUsers = [select SetupOwnerId from Authorized_users__c];
      for(Event sObj : isNew){
        isAuth =false;
        for(Authorized_users__c cObj : authUsers) {
          if(cObj.SetupOwnerId==UserInfo.getuserId()){
            isAuth = true;
          }
        }
        if(!isAuth && (sObj.Edgeforce_Calendar_Event_Type__c == 'ALSAC Event' || sObj.Edgeforce_Calendar_Event_Type__c == 'Divisional Event' || sObj.Edgeforce_Calendar_Event_Type__c == 'Field Event'))
          sObj.addError('User not authorized to Create/Update Event.');
      }
	}
}