global class C360TaxReceiptInteraction {
   public domainSoapStjudeOrg.Interaction i {get; set;}
 

  global static void createtaxrecint (string consId) {
        domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();

        i.ContactDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        i.Page_x = 1;
        i.ContactCategory = 'LR';
        i.ContactType = 'TAXRCPT';
        i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
        i.TransactionSource.Technique = 'CF';
        i.LongComments = UserInfo.getUserName()+ 'Annual Donor Information Sent' + DateTime.now().format('yyyy-MM-dd HH:mm:ss');

        system.debug('i.ContactDate = ' + i.ContactDate +
            '\ni.Page_x = ' + i.Page_x +
            '\ni.ContactCategory = ' + i.ContactCategory +
            '\ni.ContactType = ' + i.ContactType +
            '\ni.TransactionSource.Technique = ' + i.TransactionSource.Technique +
            '\ni.LongComments = ' + i.LongComments);
      
      try {
                    System.debug('i = ' + i);
          			System.debug('consId = ' + consId);
                    System.debug('i.Technique = ' + i.Technique);
                    C360Util.createInteraction(consId, i);
                }
                catch(CalloutException e) {
                    C360Util.createInteractionDMS(consId, i);
                }
    }
   
}