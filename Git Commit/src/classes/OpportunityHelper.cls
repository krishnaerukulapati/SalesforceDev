public class OpportunityHelper{
    public static void updateOwnerBasedonRegion(List<Opportunity> opplist,Map<Id,Opportunity> oldMap){
        
        Map<String,Opportunity_Region_Detail__mdt> oppRegionMap=new Map<String,Opportunity_Region_Detail__mdt>();
        for(Opportunity_Region_Detail__mdt oppmdt : [SELECT Id,MasterLabel,DeveloperName,User1_Id__c,User2_Id__c,User3_Id__c,User4_Id__c FROM Opportunity_Region_Detail__mdt]){
           oppRegionMap.put(oppmdt.DeveloperName,oppmdt);
        }
        
         Id RecordTypeId=Schema.SObjectType.Opportunity.RecordTypeInfosByName.get('St Jude Challenge').RecordTypeId;
        System.debug('--oppRegionMap---'+oppRegionMap);
        List<Opportunity> newopplist=new List<Opportunity>();
        Set<Id> oppId=new Set<Id>();
        for(Opportunity opp1 : opplist){
            if(opp1.RecordTypeId==RecordTypeId){
             oppId.add(opp1.id);
            }
        }
        Map<Id,opportunity> oppMap=new Map<Id,Opportunity>();
        System.debug('--oppId---'+oppId);
        if(oppId.size()>0){
            for(Opportunity opp : [SELECT Id,Name,CampaignId,Campaign.Name,Region__c,States__c,OwnerId FROM Opportunity WHERE Id=:oppId]){
                Opportunity_Region_Detail__mdt oppmdtObj=oppRegionMap.get(opp.Region__c);
                System.debug('--oppmdtObj---'+oppmdtObj);
                if(oppRegionMap.containsKey(opp.Region__c)){
                    if(opp.Region__c=='WEST'){
                         if(opp.Campaign.Name.Contains('Math')){
                            opp.OwnerId=oppmdtObj.User1_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Trike')){
                            opp.OwnerId=oppmdtObj.User2_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Challenge')){
                            opp.OwnerId=oppmdtObj.User3_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Saddle up') || opp.Campaign.Name.Contains('yourway') || opp.Campaign.Name.Contains('cruisine')){
                            opp.OwnerId=oppmdtObj.User4_Id__c;
                         }
                    }
                    if(opp.Region__c=='MIDWEST'){
                         if(opp.Campaign.Name.Contains('Math')){
                            opp.OwnerId=oppmdtObj.User1_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Trike')){
                            opp.OwnerId=oppmdtObj.User2_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Challenge')){
                            opp.OwnerId=oppmdtObj.User3_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Saddle up') || opp.Campaign.Name.Contains('yourway') || opp.Campaign.Name.Contains('cruisine')){
                            opp.OwnerId=oppmdtObj.User4_Id__c;
                         }
                    }
                    if(opp.Region__c=='SOUTHEAST'){
                         if(opp.Campaign.Name.Contains('Math')){
                            opp.OwnerId=oppmdtObj.User1_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Trike')){
                            opp.OwnerId=oppmdtObj.User2_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Challenge')){
                            opp.OwnerId=oppmdtObj.User3_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Saddle up') || opp.Campaign.Name.Contains('yourway') || opp.Campaign.Name.Contains('cruisine')){
                            opp.OwnerId=oppmdtObj.User4_Id__c;
                         }
                    }
                    if(opp.Region__c=='NORTHEAST'){
                         if(opp.Campaign.Name.Contains('Math')){
                            opp.OwnerId=oppmdtObj.User1_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Trike')){
                            opp.OwnerId=oppmdtObj.User2_Id__c;
                         }                       
                         if(opp.Campaign.Name.Contains('Challenge') || opp.Campaign.Name.Contains('Saddle up') || opp.Campaign.Name.Contains('yourway') || opp.Campaign.Name.Contains('cruisine')){
                            opp.OwnerId=oppmdtObj.User3_Id__c;
                         }
                    }
                    if(opp.Region__c=='SOUTHWEST'){
                         if(opp.Campaign.Name.Contains('Math')){
                            opp.OwnerId=oppmdtObj.User1_Id__c;
                         }
                         if(opp.Campaign.Name.Contains('Trike')){
                            opp.OwnerId=oppmdtObj.User2_Id__c;
                         }                       
                         if(opp.Campaign.Name.Contains('Challenge') || opp.Campaign.Name.Contains('Saddle up') || opp.Campaign.Name.Contains('yourway') || opp.Campaign.Name.Contains('cruisine')){
                            opp.OwnerId=oppmdtObj.User3_Id__c;
                         }
                    }
                    oppMap.put(opp.Id,opp);
                 }
            }
        }
        
        if(oppMap.size()>0){
           update oppMap.values();
        }   
    }
}