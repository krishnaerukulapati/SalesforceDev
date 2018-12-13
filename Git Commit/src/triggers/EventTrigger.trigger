//
// (c) 2014 Appirio, Inc.
//
// Check if the user is authorized to create record, else generate error
//
// 23 Sept, 2014   Sumit Tanwar   Original (Ref. Task T-321188)
// 30 Sept, 2014   Sumit Tanwar   (Ref. Task T-321188)
//
trigger EventTrigger on Event (before insert, before update) {
      EventTriggerHandler.ckeckUserAuthorized(trigger.new);
}