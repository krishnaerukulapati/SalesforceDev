public class DeleteLead

 { 
   @InvocableMethod     
   public static void LeadDelete(List<Id> LeadIds){         
       List<Lead> Leads =[select id from lead where Lead.id in :LeadIds and Status = 'Archived'];         
       delete Leads;    
       } 
   }