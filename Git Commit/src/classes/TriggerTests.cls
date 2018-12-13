@isTest
private class TriggerTests {
	@isTest static void Leads_WithBadPhone_AreNotSetToReady()
	{
		//setup campaigns
		Campaign ca = new Campaign();
		ca.Name = 'some campaign';
		insert ca;

		Campaign bca = new Campaign();
		bca.Name = 'Bad Record';
		insert bca;

		//setup leads
                Lead c = new Lead();
                c.LastName = 'test';
                c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
                c.Constituent_Type__c = 'INDIVIDUAL';
                c.Company = 'fake';
                c.TR_ID__c = '123456';
                c.EventID__c = '123456';
                c.CurrentCampaign__c = ca.Id;
                c.Phone = ' 517 5252 ';

                insert c;

		system.debug('Invalid.ca.Id=' + ca.Id);
                Lead updatedLead = [SELECT Id, DialerStatus__c, CurrentCampaign__c, Phone, LastModifiedById, Trigger_Modified_Date__c FROM Lead WHERE Id = :c.Id];
                system.debug('Invalid.updatedLead=' + updatedLead);

                //verify dialer status is not set to Ready
                system.Assert(updatedLead.DialerStatus__c=='Bad Phone');

        		//verify campaignmember and lead.currentcampaignid set to bad 
                List<CampaignMember> cmList = [Select id, LeadId, CampaignId from CampaignMember where LeadId =: c.Id];

                system.debug('Invalid.cmList.size()=' + cmList.size());
                system.debug('Invalid.cmList.get(0).CampaignId=' + cmList.get(0).CampaignId);
                system.Assert(cmList.size() == 1);
                system.Assert(cmList.get(0).CampaignId == updatedLead.CurrentCampaign__c);

                system.debug('Invalid.bca.Id=' + bca.Id);
                system.debug('updatedLead.ModifiedBy=' + updatedLead.LastModifiedById);
                //verify trigger set last modified date
                system.Assert(updatedLead.Trigger_Modified_Date__c.date() == System.now().date());
                system.Assert(updatedLead.CurrentCampaign__c == ca.Id);
                system.Assert(updatedLead.Phone == '5175252');
	}

        @isTest static void trigger_updates_Phone(){
                //setup campaigns
                Campaign ca = new Campaign();
                ca.Name = 'some campaign';
                insert ca;

                Campaign bca = new Campaign();
                bca.Name = 'Bad Record';
                insert bca;

                //setup leads
                Lead c = new Lead();
                c.LastName = 'test';
                c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
                c.Constituent_Type__c = 'INDIVIDUAL';
                c.Company = 'fake';
                c.TR_ID__c = '123456';
                c.EventID__c = '123456';
                c.CurrentCampaign__c = ca.Id;
                c.Phone = '9015175252 x.1234';

                insert c;

                system.debug('ValidPhone.c.Id=' + c.Id);
                Lead updatedLead = [SELECT Id, DialerStatus__c, CurrentCampaign__c, LastModifiedById, Phone, Trigger_Modified_Date__c  FROM Lead WHERE Id = :c.Id];
                system.debug('ValidPhone.updatedLead=' + updatedLead);

                //verify dialer status is set to ready
                system.Assert(updatedLead.DialerStatus__c=='Ready');

                //verify trigger set last modified date
                system.Assert(updatedLead.Trigger_Modified_Date__c.date() == System.now().date());
                system.Assert(updatedLead.CurrentCampaign__c == ca.Id);
                system.Assert(updatedLead.Phone == '9015175252');
        }

	@isTest static void Leads_WithValidPhone_AreSetToReady()
	{
        	//setup campaigns
        	Campaign ca = new Campaign();
        	ca.Name = 'some campaign';
        	insert ca;

        	Campaign bca = new Campaign();
        	bca.Name = 'Bad Record';
        	insert bca;

		//setup leads
                Lead c = new Lead();
                c.LastName = 'test';
                c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
                c.Constituent_Type__c = 'INDIVIDUAL';
                c.Company = 'fake';
                c.TR_ID__c = '123456';
                c.EventID__c = '123456';
                c.CurrentCampaign__c = ca.Id;
                c.Phone = '9015175252';

                insert c;

		system.debug('ValidPhone.c.Id=' + c.Id);
                Lead updatedLead = [SELECT Id, DialerStatus__c, CurrentCampaign__c, LastModifiedById, Phone, Trigger_Modified_Date__c  FROM Lead WHERE Id = :c.Id];
                system.debug('ValidPhone.updatedLead=' + updatedLead);

                //verify dialer status is set to ready
                system.Assert(updatedLead.DialerStatus__c=='Ready');

                //verify campaignmember was added for the lead
                List<CampaignMember> cmList = [Select id, LeadId, CampaignId from CampaignMember where LeadId =: c.Id];

                system.debug('ValidPhone.cmList.size()=' + cmList.size());
                system.debug('ValidPhone.cmList.get(0).id=' + cmList.get(0).id);
                system.debug('updatedLead.ModifiedBy=' + updatedLead.LastModifiedById);
                system.Assert(cmList.size() == 1);
                system.Assert(cmList.get(0).CampaignId == updatedLead.CurrentCampaign__c);

                //verify trigger set last modified date
                system.Assert(updatedLead.Trigger_Modified_Date__c.date() == System.now().date());
                system.Assert(updatedLead.CurrentCampaign__c == ca.Id);
                system.Assert(updatedLead.Phone == '9015175252');
	}

        @isTest static void Leads_With10digitsInPhone_StripOutNonNumericData()
        {
                //setup campaigns
                Campaign ca = new Campaign();
                ca.Name = 'some campaign';
                insert ca;

                //setup leads
                Lead c = new Lead();
                c.LastName = 'test';
                c.ConstituentID__c = '56FC02D5-8B2E-4DB8-8F38-886006C7AC2B';
                c.Constituent_Type__c = 'INDIVIDUAL';
                c.Company = 'fake';
                c.TR_ID__c = '123456';
                c.EventID__c = '123456';
                c.CurrentCampaign__c = ca.Id;
                c.Phone = '901asdf517asdf52!!#52@';

                insert c;

                Lead updatedLead = [SELECT Id, DialerStatus__c, CurrentCampaign__c, LastModifiedById, Phone, Trigger_Modified_Date__c  FROM Lead WHERE Id = :c.Id];
                system.debug('updatedLead=' + updatedLead);

                //verify dialer status is set to ready
                system.Assert(updatedLead.DialerStatus__c=='Ready');

                //verify trigger set last modified date
                system.Assert(updatedLead.Trigger_Modified_Date__c.date() == System.now().date());
                system.Assert(updatedLead.CurrentCampaign__c == ca.Id);
                system.Assert(updatedLead.Phone == '9015175252');
        }     
}