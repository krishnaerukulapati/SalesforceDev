/**
  * Apex Class: IntranetContentRTSelectionController
  * Description: T-179349 : Develop VF page to enter content
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 2nd, 2013.
  */
public with sharing class EdgeForceIntranetContentRTSelController {
	public String selectedContentRecordType {get ; set ;}
	public List<SelectOption> intranetContentRecordTypes {get ; set ;}
	Map<String, String> recordTypeIdNameMap;
	
	public EdgeForceIntranetContentRTSelController(ApexPages.StandardController stdController){
		Intranet_Content__c content = (Intranet_Content__c)stdController.getRecord();
		intranetContentRecordTypes = new List<SelectOption>();
		recordTypeIdNameMap = new Map<String, String>();
		
		//Fetch Record Types for Intranet_Content__c sObject
		Map<String,Schema.RecordTypeInfo> rtMapByName = 
		      Schema.SObjectType.Intranet_Content__c.getRecordTypeInfosByName();
		
		
		//Create select option list of Intranet Content record types 
		for(Schema.RecordTypeInfo recordTypeInfo : rtMapByName.values()){
		  if(recordTypeInfo.getName() != 'Master'){
		   intranetContentRecordTypes.add(new SelectOption(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName()));
		   recordTypeIdNameMap.put(recordTypeInfo.getRecordTypeId(), recordTypeInfo.getName());
		  }
		}
	}
	
	//this function will redirect the user to IntranetContentNew page with record type id and name
	public Pagereference selectRecordType(){
		String recordTypeName = recordTypeIdNameMap.get(selectedContentRecordType);
		return new Pagereference('/Apex/EdgeForceIntranetContentNew?RecordTypeId=' + selectedContentRecordType + '&RecordTypeName=' + recordTypeName);
	}
	
	//This function will cancel the action and redirect to Intranet Content list view
	public Pagereference cancel(){
		return new Pagereference('/' + Intranet_Content__c.sObjectType.getDescribe().getKeyPrefix());
	}
}