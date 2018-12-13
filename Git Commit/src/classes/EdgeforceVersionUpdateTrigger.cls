public with sharing class EdgeforceVersionUpdateTrigger {
  
  public static  void createNewVersion(Map<Id,Intranet_Content_Version__c> oldVersionMap , Map<Id,Intranet_Content_Version__c> newVersionMap){
  	List<Intranet_Content_Version__c> listofVersionsToInsert = new  List<Intranet_Content_Version__c> ();
  	for(String oldVersionId : oldVersionMap.keySet()){
  		if( oldVersionMap.get(oldVersionId).Name != newVersionMap.get(oldVersionId).Name || oldVersionMap.get(oldVersionId).Summary__c != newVersionMap.get(oldVersionId).Summary__c || oldVersionMap.get(oldVersionId).DescripTion__c != newVersionMap.get(oldVersionId).DescripTion__c){
	  		Intranet_Content_Version__c oldVersionToInsert = new Intranet_Content_Version__c();
	  		oldVersionToInsert = oldVersionMap.get(oldVersionId).Clone();
	  		if(newVersionMap.get(oldVersionId).isPublished__c == true)
	  		 oldVersionToInsert.isPublished__c = false;
	  		
	  		listofVersionsToInsert.add(oldVersionToInsert);
  		}
  	}
  	
  	try{
  		Database.insert(listofVersionsToInsert);
  	}catch(Exception e){
  		
  	}
  }
}