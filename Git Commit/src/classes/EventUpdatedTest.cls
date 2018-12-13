@isTest
global class EventUpdatedTest {
  @isTest static void ExistingLeadCreate() {
    Account a = new Account();
    a.Name = 'ALSAC Challenge';
    insert a;

                CustomSettings__c cs = new CustomSettings__c();
                cs.Name = 'EventsRecruitment';
                cs.Value__c = 'whoknows';
                insert cs;

                Campaign c = new Campaign();
                c.EventTypeID__c = 'testeventtype';
                c.Name = 'test';
                c.OppRecordType__c = 'St_Jude_Challenge';
                c.LeadRecType__c = 'St_Jude_Challenge';
                c.IsSupportParent__c = true;
                insert c;

                Lead l = new Lead();
                l.LastName = 'test';
                l.ConstituentID__c = 'notaguid';
                l.Company = 'alsac';
                l.CurrentCampaign__c = c.Id;
                insert l;

                Test.startTest();
                PageReference pageRef = Page.EventRecruited;
                Test.setCurrentPage(pageRef);

                ApexPages.currentPage().getParameters().put('eventid', 'notaguid');
                ApexPages.currentPage().getParameters().put('id', l.id);

                EventRecruitedController erc = new EventRecruitedController();

                //missing account
                erc.recruit();
                c.OppAcc__c = a.Id;
                update c;

                //with account
                erc.recruit();
  
    Test.stopTest();
  }

  @isTest static void NewLeadCreate() {
    Account a = new Account();
    a.Name = 'ALSAC Challenge';
    insert a;

                CustomSettings__c cs = new CustomSettings__c();
                cs.Name = 'EventsUpdate';
                cs.Value__c = 'whoknows';
                insert cs;

                Campaign c = new Campaign();
                c.EventTypeID__c = 'testeventtype';
                c.Name = 'test';
                c.OppRecordType__c = 'St_Jude_Challenge';
                c.LeadRecType__c = 'St_Jude_Challenge';
                c.IsSupportParent__c = true;
                insert c;

                Test.startTest();
                PageReference pageRef = Page.EventUpdated;
                Test.setCurrentPage(pageRef);

                ApexPages.currentPage().getParameters().put('eventid', 'notaguid');

                EventRecruitedController erc = new EventRecruitedController();

                //missing account
                erc.recruit();
                c.OppAcc__c = a.Id;
                update c;

                //with account
                erc.recruit();  
    Test.stopTest();
  }
}