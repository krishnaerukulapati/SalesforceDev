@isTest
private class ArchiveLeadsBatTest {

	///summary///
	///Testing isCampaignValid(Campaign c)
	///method will check campaign as valid Archive Campaign
	///summary///
	@isTest static void validate_campaign_as_archivable(){
		System.debug('_____TEST METHOD: validate_campaign_as_archivable_____');

		Campaign invalidCamp = [SELECT Id, isArchivable__c, ArchiveDestination__c FROM Campaign WHERE Name = 'nonArchiveCamp'];
		Campaign validCamp = [SELECT Id, isArchivable__c, ArchiveDestination__c FROM Campaign WHERE Name = 'archivableCamp'];

		Test.startTest();

		ArchiveLeadsBat alb = new ArchiveLeadsBat();
		
		Boolean result = alb.isCampaignValid(invalidCamp);
		System.assert((result == false), 'isCampaignValid(invalidCamp) returned: ' + result + '. Expected: false');
		result = alb.isCampaignValid(validCamp);
		System.assert((result == true), 'isCampaignValid(validCamp) returned: ' + result + '. Expected: true');

		Test.stopTest();
	}

	///summary///
	///Testing assignLeadFromCampM(CampaignMember cm)
	///Method will take Lead info off CampaignMember into its own Lead object
	///summary///
	//@isTest static void can_assignLeadFromCampM(){
	//	System.debug('_____TEST METHOD: can_assignLeadFromCampM______');

	//	CampaignMember cm = [SELECT Id, LeadId, Lead.CurrentCampaign__c, Lead.DialerStatus__c FROM CampaignMember WHERE Lead.Name = 'StandardLead'];
	//	Lead lead = [SELECT Id, CurrentCampaign__c, DialerStatus__c FROM Lead where Name = 'StandardLead'];

	//	Test.startTest();

	//	ArchiveLeadsBat alb = new ArchiveLeadsBat();

	//	Lead leadTest = alb.assignLeadFromCampM(cm);

	//	System.assertEquals(lead, leadTest, 'msg');

	//	Test.stopTest();
	//}

	///summary///
	///Test checkLeadSkillsAndRemove(Lead l, Campaign c)
	///Method will take a lead and a campaign and see if this lead has leadskills with that combination && DialerStatus is Ready || CheckedOut
	///If it does it will set the dialerStatus__c to Remove
	///summary///
	@isTest static void can_checkLeadSkillsAndRemove(){
		System.debug('_____TEST METHOD: can_checkLeadSkillsAndRemove_____');
		Lead lead = [SELECT Id FROM Lead WHERE Name = 'StandardLead'];
		Campaign currCamp = [SELECT Id FROM Campaign WHERE Name = 'archiveCamp'];

		Test.startTest();

		//In test setup there are no leadskills set to remove, make sure there are 0 
		Integer beforeCount = database.countQuery('SELECT COUNT() FROM LeadSkill__c WHERE DialerStatus__c = \'Remove\'');
		System.assert((beforeCount == 0), 'Should not be any Remove type LeadSkills');

		ArchiveLeadsBat alb = new ArchiveLeadsBat();

		alb.checkLeadSkillsAndRemove(lead, currCamp);

		//After checkLeadSkillsAndRemove there should be 2 leadskills set to remove.  
		Integer afterCount = database.countQuery('SELECT COUNT() FROM LeadSkill__c WHERE DialerStatus__c = \'Remove\'');
		System.assert((afterCount == 2), 'Should not be any Remove type LeadSkills');

		Test.stopTest();
	}

	///summary///
	///Testing isLeadInSameCampaign(CampaignMember cm, Lead l)
	///Method will validate is campaignmember and lead are in the same campaign
	///summary///
	@isTest static void validate_isLeadInSameCampaign(){
		System.debug('_____TEST METHOD: validate_isLeadInSameCampaign_____');

		CampaignMember cm = [SELECT Id, CampaignId, LeadId, Lead.CurrentCampaign__c, Lead.DialerStatus__c FROM CampaignMember WHERE Lead.Name = 'StandardLead'];
		Lead lead = [SELECT Id, CurrentCampaign__c, DialerStatus__c FROM Lead WHERE Name = 'StandardLead'];
		Lead archivedLead = [SELECT Id, CurrentCampaign__c, DialerStatus__c FROM Lead WHERE Name = 'ArchivedLead'];

		Test.startTest();

		ArchiveLeadsBat alb = new ArchiveLeadsBat();

		Boolean result = alb.isLeadInSameCampaign(cm, lead);
		System.assert((result == true), 'isLeadInSameCampaign returned: ' + result + '. Expected: true');		
		result = alb.isLeadInSameCampaign(cm, archivedLead);
		System.assert((result == false), 'isLeadInSameCampaign returned: ' + result + '. Expected: false');		

		Test.stopTest();		
	}

	///summary///
	///Testing moveLeadToArchive(Lead l, Campaign c)
	///Method will move Lead to Campaign.ArchiveDestination__c
	///summary///
	@isTest static void can_moveLeadToArchive() {
		System.debug('_____TEST METHOD: can_moveLeadToArchive_____');

		Lead standardLead = [SELECT Id, DialerStatus__c, CurrentCampaign__c FROM Lead WHERE Name = 'StandardLead'];
		Campaign archivableCamp = [SELECT Id, ArchiveDestination__c FROM Campaign WHERE Id = :standardLead.CurrentCampaign__c];

		Test.startTest();

		ArchiveLeadsBat alb = new ArchiveLeadsBat();

		alb.moveLeadToArchive(standardLead, archivableCamp);

		System.assertEquals(standardLead.CurrentCampaign__c, archivableCamp.ArchiveDestination__c, 'Lead.CurrentCampaign__c: ');		

		Test.stopTest();
	}

	//Need to find an assertion to put on this
	@isTest static void test_archiveLeadsBatTestOverload(){
		Campaign validCamp = [SELECT Id, isArchivable__c, ArchiveDestination__c FROM Campaign WHERE Name = 'archivableCamp'];

		Test.startTest();

		ArchiveLeadsBat alb = new ArchiveLeadsBat(validCamp);

		Test.stopTest();
	}

	//Missing assert
	@isTest static void can_GetEnvelope(){
		System.debug('_____TEST METHOD: can_GetEnvelope_____');
		EmailSettings__c e = new EmailSettings__c();
		e.Email__c = 'test@email.com';
		e.DeliminatedEmail__c = 'test@email.com;test2@email.com';
		e.Name = 'ArchiveLeads';
		insert e;

		Test.startTest();

		Messaging.SingleEmailMessage result = ArchiveLeadsBat.GetEnvelope();

		Test.stopTest();
	}

	@isTest static void test_IncrementCount(){
		System.debug('_____TEST METHOD: test_IncrementCount_____');

		String countName = 'test';

		Test.startTest();

		ArchiveLeadsBat alb = new ArchiveLeadsBat();
		alb.IncrementCount(countName);
		alb.IncrementCount(countName);

		System.assert(alb.processCounts != null);

		Test.stopTest();
	}

	@isTest static void test_SystemAbortJob() {
		//need to do some research to see how to assert on this
	}

	//This is for testing the routing of the business logic flow.  Requires a lot of setup
	//Might want to split in multiple scenarios
	//@isTest static void test_BatchFlow() {
	//	Campaign camp = new Campaign();
	//	camp.Name = 'Archival Camp';
	//	insert camp;

	//	Campaign c = new Campaign();
	//	c.Name = 'TestCampaign';
	//	c.isArchivable__c = true;
	//	c.ArchiveDestination__c = camp.Id;
	//	insert c;

	//	Lead l = new Lead();
	//	l.LastName = 'TestLead ';// + String.valueOf(i);
	//	l.Company = 'ALSAC';
	//	l.phone = '5012317711';
	//	insert l;		

	//	CampaignMember cm = new CampaignMember();		
	//	cm.LeadId = l.Id;		
	//	cm.CampaignId = c.Id;		
	//	insert cm;		
	//	l.CurrentCampaign__c = c.Id;		
	//	l.DialerStatus__c = 'CheckedOut';		   
	//	update l;
	//	Test.setCreatedDate(cm.Id, Datetime.now().addDays(-56));

	//	Test.startTest();

	//	ArchiveLeadsBat alb = new ArchiveLeadsBat(c);
	//	database.executebatch(alb, 15);

	//	Lead result = [SELECT Id, DialerStatus__c FROM Lead WHERE Id = :l.Id];

	//	System.assertEquals('Remove', result.DialerStatus__c, 'Lead was not set to Remove'); //assert that the lead we just created is set to remove and campaign member is NOT deleted

	//	Test.stopTest();
	//}

	@testSetup static void test_setup(){
		//Test data setup
		Campaign nonArchiveCamp = new Campaign();
		nonArchiveCamp.Name = 'nonArchiveCamp';
		nonArchiveCamp.isArchivable__c = false;
		nonArchiveCamp.ArchiveDestination__c = null;
		insert nonArchiveCamp;

		Campaign archiveCamp = new Campaign();
		archiveCamp.Name = 'archiveCamp';
		insert archiveCamp;

		Campaign archivableCamp = new Campaign();
		archivableCamp.Name = 'archivableCamp';
		archivableCamp.isArchivable__c = true;
		archivableCamp.ArchiveDestination__c = archiveCamp.Id;
		insert archivableCamp;

		Lead standardLead = new Lead();
		standardLead.LastName = 'StandardLead';
		standardLead.Company = 'ALSAC';
		standardLead.CurrentCampaign__c = archivableCamp.Id; //This will auto create a campaignMember for this lead
		standardLead.Phone = '5012317711';
		insert standardLead;
		standardLead.DialerStatus__c = 'CheckedOut';
		update standardLead;

		Lead archivedLead = new Lead();
		archivedLead.LastName = 'ArchivedLead';
		archivedLead.Company = 'ALSAC';
		archivedLead.CurrentCampaign__c = archiveCamp.Id; //This will auto create a campaignMember for this lead
		archivedLead.Phone = '5012317712';
		insert archivedLead;
		archivedLead.DialerStatus__c = 'CheckedIn';
		update archivedLead;

		LeadSkill__c leadSkill1 = new LeadSkill__c();
		leadSkill1.Campaign__c = archiveCamp.Id;
		leadSkill1.Lead__c = standardLead.Id;
		leadSkill1.DialerStatus__c = 'CheckedOut';
		insert leadSkill1;

		LeadSkill__c leadSkill2 = new LeadSkill__c();
		leadSkill2.Campaign__c = archiveCamp.Id;
		leadSkill2.Lead__c = standardLead.Id;
		leadSkill2.DialerStatus__c = 'Ready';
		insert leadSkill2;

		LeadSkill__c leadSkill3 = new LeadSkill__c();
		leadSkill3.Campaign__c = archiveCamp.Id;
		leadSkill3.Lead__c = standardLead.Id;
		leadSkill3.DialerStatus__c = 'Ignore';
		insert leadSkill3;

		//CampaignMember cm = new CampaignMember();
		//cm.LeadId = standardLead.Id;
		//cm.CampaignId = nonArchiveCamp.Id;
		//insert cm;
		//Test.setCreatedDate(cm.Id, Datetime.now().addDays(-56));
	}
}