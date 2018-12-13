@isTest
global class EventRecruitedContTest {

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
        c.OppAcc__c=a.id;               
        insert c;

        Lead l = new Lead();
        l.LastName = 'test';
        l.ConstituentID__c = 'notaguid';
        l.Company = 'alsac';
        l.CurrentCampaign__c = c.Id;
        l.Recruited_Date__c =Date.Today();
        l.Phone ='567890';
        l.Event_Status__c ='Active';
        l.Email='test@gg.com';
        insert l;
                
        REcordType rtopp= [select Id from RecordType where DeveloperName = :c.OppRecordType__c and sObjectType = 'Opportunity'];

        REcordType rtlead = [select Id from RecordType where DeveloperName = :c.LeadRecType__c and sObjectType = 'Lead'];
        Test.startTest();
        PageReference pageRef = Page.EventRecruited;
        Test.setCurrentPage(pageRef);

        String eventid=ApexPages.currentPage().getParameters().put('eventid', 'notaguid');
        ApexPages.currentPage().getParameters().put('id', l.id);

        EventRecruitedController erc = new EventRecruitedController();
        erc.eventLead=l;
        erc.accId=a.id;
        erc.eventCamp =c;
        erc.rtOpp =rtopp;
        erc.rtLead =rtlead;
        //missing account
        erc.recruit();
        erc.MoveLead();
        //erc.CreateOpp(eventid);
        erc.updateEvent();
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

        Test.startTest();
        PageReference pageRef = Page.EventRecruited;
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('eventid', 'notaguid');

        EventRecruitedController erc = new EventRecruitedController();

        //missing account
        erc.recruit();
        c.OppAcc__c = a.Id;
        update c;
        delete c;
        //with account
        erc.recruit();  
        Test.stopTest();
    }
    
    @isTest static void ExistingCampCreate() {
        Account a = new Account();
        a.Name = 'ALSAC Challenge';
        insert a;
        
        C360Settings__c setting = new C360Settings__c();
        setting.Name = 'Master';
        setting.C360SettingsURL__c = 'dummy';
        insert setting;
        
        EnvironmentSettings__c es = new EnvironmentSettings__c();
        es.EVMActiveStatusID__c = '123456789';
        es.EVMCancelledStatusID__c = '325135165161';
        es.EVMCoordinatorRoleID__c = '2411361361';
        es.EVMDeletedStatusID__c = '54651631351313131';
        es.EVMOrganizerRoleID__c = '35413613131313';
        insert es;
        
        CustomSettings__c cs = new CustomSettings__c();
        cs.Name = 'EventsRecruitment';
        cs.Value__c = 'whoknows';
        insert cs;

       /* Campaign c = new Campaign();
        c.EventTypeID__c = 'testeventtype11';
        c.Name = 'test111';
        c.OppRecordType__c = 'St_Jude_Challenge';
        c.LeadRecType__c = 'St_Jude_Challenge';
        c.IsSupportParent__c = true; 
        c.OppAcc__c=a.id;               
        insert c;*/
        
        Campaign c1 = new Campaign();
        c1.EventTypeID__c = 'testeventtype';
        c1.Name = 'test';
        c1.OppRecordType__c = 'St_Jude_Challenge';
        c1.LeadRecType__c = 'St_Jude_Challenge';
        c1.IsSupportParent__c = true; 
        c1.OppAcc__c=a.id;               
        insert c1;
        
        List<Campaign> camplist=new List<Campaign>();
        //camplist.add(c);
        camplist.add(c1);
        
        
        
        Lead l = new Lead();
        l.LastName = 'test';
        l.ConstituentID__c = 'notaguid';
        l.Company = 'alsac';
        l.CurrentCampaign__c = c1.Id;
        l.Recruited_Date__c =Date.Today();
        l.Phone ='567890';
        l.Event_Status__c ='Active';
        l.Email='test@gg.com';
        insert l;
        
        CampaignMember campmem=new CampaignMember ();
        campmem.CampaignId=c1.Id;
        campmem.LeadId=l.Id;
       // insert campmem;
        
        List<REcordType> rtopplist= [select Id from RecordType where DeveloperName = :c1.OppRecordType__c and sObjectType = 'Opportunity'];

       List<REcordType> rtleadlist = [select Id from RecordType where DeveloperName = :c1.LeadRecType__c and sObjectType = 'Lead'];
        Test.startTest();
        PageReference pageRef = Page.EventRecruited;
        Test.setCurrentPage(pageRef);

        String eventid=ApexPages.currentPage().getParameters().put('eventid', 'notaguid');
        ApexPages.currentPage().getParameters().put('id', l.id);

        EventRecruitedController erc = new EventRecruitedController();
        erc.eventLead=l;
       
        erc.eventCamp =camplist[0];
        erc.accId = camplist[0].OppAcc__c;
        erc.rtOpp =rtopplist[0];
        erc.rtLead =rtleadlist[0];
        //missing account
        erc.recruit();
        erc.MoveLead();
        //erc.CreateOpp(eventid);
        c1.OppAcc__c = a.Id;
        update c1;
        erc.accId=null;
        //with account
        erc.recruit();
    
        Test.stopTest();
    }
}