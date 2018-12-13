/*
Created By : Harshit Jain
Created Date : December 12,2012
Description  : Controller for IntranetTeam page.

****************************************************
*@modified by : sil
*@modified Date : 17-march-2014
*@purpose : process custom resourse content document  
*/
public with sharing class EdgeForceIntranetTeamController {
        //String to hold team name selected by current user
        public String groupName {get;set;}
        //Respective group id of selected team 
        public Id groupId {get;set;}
        public String pageName {get;set;}
        public boolean showCRMContent{get;set;} {showCRMContent = true;}
        
        public EdgeForceIntranetTeamController() {
                groupName = ApexPages.currentPage().getParameters().get('name');
                //fetch groupId of selected team show chatter feed on IntranetTeam page.
                for(CollaborationGroup groupObj : [Select c.Name, c.Id From CollaborationGroup c where c.Name =: groupName limit 1] ) {
                        groupId = groupObj.Id;
                }
                
                if(ApexPages.currentPage().getParameters().get('name') != null) {
                        pageName = ApexPages.currentPage().getParameters().get('name');
                }
                for(Intranet_Content__C teamContent : [select Content_Type__C from Intranet_Content__C where name =: pageName]){
                    if(teamContent.content_type__c == 'Custom Content'){
                        showCRMContent = false;
                    }
                }
        }
}