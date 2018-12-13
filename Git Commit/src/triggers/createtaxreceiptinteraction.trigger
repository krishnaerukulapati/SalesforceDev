trigger createtaxreceiptinteraction on Task (before insert, after insert) {
    
       for(Task t: Trigger.new)  {
                    if(t.Subject.contains('00XF0000000jfyc')&&t.Status.equals('Completed')) {
                        List<Case> lList = [select id, constituentid__c from case where id = :t.WhatId];
                                    if(lList.size() > 0) {
                Case c = lList.get(0);
                if (c != null) {
                    String consId = c.ConstituentID__c;
                    C360TaxReceiptInteraction.createtaxrecint(consId);
                
}
}
}
}
}