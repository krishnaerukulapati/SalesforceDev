public class DeleteCampaignMember

{ 
   @InvocableMethod     
   public static void CampaignMemberDelete(List<Id> CampaignMemberIds){         
   		system.debug('tried to delete ' + CampaignMemberIds.size() + ' members');
       List<CampaignMember> CampaignMembers =[select id from campaignMember where CampaignMember.id in :CampaignMemberIds]; 
    
       delete CampaignMembers;    
       } 
   }