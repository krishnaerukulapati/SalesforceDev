@isTest
global class OutboundPopControllerTest{


	public Static testMethod void updateLead_setsCallObject()
    { 
		String contactId = '12';

		Lead c = new Lead();
        c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        c.TR_ID__c = '123456';
        c.EventID__c = '123456';
        c.CallObject__c = '';
        //c.Id = leadId;
        insert c;        

        Test.startTest();
        
      	Lead l = [select id, CallObject__c from lead where LastName = 'test' limit 1];
      	System.assertNotEquals(l, null);
      	System.assertNotEquals(l.Id, null);

        PageReference pr = Page.OutboundPop;
         pr.getParameters().put('relId', l.Id);
         pr.getParameters().put('_c', contactId);
        Test.setCurrentPage(pr);    

        ApexPages.currentPage().getParameters().put('relId', l.Id);
        ApexPages.currentPage().getParameters().put('_c', contactId);

		OutboundPopController opc = new OutboundPopController();

		PageReference resultPr = opc.updateAndRedirect();
      	Lead updatedLead = [select id, CallObject__c from lead where LastName = 'test' limit 1];

        System.assertEquals(contactId,updatedLead.CallObject__c);


        System.assert(resultPr.getUrl().endsWith('/apex/C360OpenConsole?cid=' + l.Id));
        Test.stopTest();
    }


}