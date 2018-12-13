public class EmailMessageonCaseLayout{
   public String caseid;
   public Boolean show {get;set;}
   public Case cs {get;set;}
   public  List<EmailMessageArchives__x> emailmsglist=new List<EmailMessageArchives__x>();
   
   public EmailMessageonCaseLayout(ApexPages.StandardController controller){
         cs=(Case)controller.getrecord();
         caseid=ApexPages.currentPage().getParameters().get('id');
         show=true;
   }
   
    public void met(){
        show=true;
        if(cs!=null){
            //for(EmailMessageArchives__x em : [SELECT CcAddress__c,BccAddress__c,FromAddress__c,FromName__c,HtmlBody__c,ParentId__c,Subject__c,TextBody__c,ToAddress__c FROM EmailMessageArchives__x WHERE ParentId__c=:cs.id]){
            //  emailmsglist.add(em);
            //}
        }
    }
    
    public  List<EmailMessageArchives__x> getemailmsgs(){              
      return emailmsglist;
   }
}