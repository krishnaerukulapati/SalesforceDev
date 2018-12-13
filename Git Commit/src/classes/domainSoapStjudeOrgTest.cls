@isTest
private class domainSoapStjudeOrgTest {
	
	@isTest static void createDomain() {
		domainSoapStjudeOrg dso = new domainSoapStjudeOrg();
		//Commented lines here have been move further down to test their auto-props.
		domainSoapStjudeOrg.Constituent Constituent_inst = new domainSoapStjudeOrg.Constituent();
		domainSoapStjudeOrg.ConstituentBase ConstituentBase_inst = new domainSoapStjudeOrg.ConstituentBase();
		domainSoapStjudeOrg.EmailAttributes EmailAttributes_inst = new domainSoapStjudeOrg.EmailAttributes();
		//domainSoapStjudeOrg.Property Property_inst = new domainSoapStjudeOrg.Property();
		//domainSoapStjudeOrg.TypeAttribute TypeAttribute_inst = new domainSoapStjudeOrg.TypeAttribute();
		domainSoapStjudeOrg.MarketingProfile MarketingProfile_inst = new domainSoapStjudeOrg.MarketingProfile();
		domainSoapStjudeOrg.HouseholdAttributes HouseholdAttributes_inst = new domainSoapStjudeOrg.HouseholdAttributes();
		//domainSoapStjudeOrg.Interaction Interaction_inst = new domainSoapStjudeOrg.Interaction();
		domainSoapStjudeOrg.Staff Staff_inst = new domainSoapStjudeOrg.Staff();
		domainSoapStjudeOrg.IndividualAttributes IndividualAttributes_inst = new domainSoapStjudeOrg.IndividualAttributes();
		domainSoapStjudeOrg.TransactionProfile TransactionProfile_inst = new domainSoapStjudeOrg.TransactionProfile();
		domainSoapStjudeOrg.Event Event_inst = new domainSoapStjudeOrg.Event();
		domainSoapStjudeOrg.Constituent360 Constituent360_inst = new domainSoapStjudeOrg.Constituent360();
		//domainSoapStjudeOrg.Profile Profile_inst = new domainSoapStjudeOrg.Profile();
		domainSoapStjudeOrg.EventType EventType_inst = new domainSoapStjudeOrg.EventType();
		domainSoapStjudeOrg.TransactionHistory TransactionHistory_inst = new domainSoapStjudeOrg.TransactionHistory();
		domainSoapStjudeOrg.ContactPreference ContactPreference_inst = new domainSoapStjudeOrg.ContactPreference();
		domainSoapStjudeOrg.OpenBills OpenBills_inst = new domainSoapStjudeOrg.OpenBills();
		domainSoapStjudeOrg.InteractionReport InteractionReport_inst = new domainSoapStjudeOrg.InteractionReport();
		//domainSoapStjudeOrg.Email Email_inst = new domainSoapStjudeOrg.Email();
		//domainSoapStjudeOrg.Relationship Relationship_inst = new domainSoapStjudeOrg.Relationship();
		//domainSoapStjudeOrg.SystemXRef SystemXRef_inst = new domainSoapStjudeOrg.SystemXRef();
		domainSoapStjudeOrg.PlannedGift PlannedGift_inst = new domainSoapStjudeOrg.PlannedGift();
		domainSoapStjudeOrg.Program Program_inst = new domainSoapStjudeOrg.Program();
		domainSoapStjudeOrg.Auth Auth_inst = new domainSoapStjudeOrg.Auth();
		domainSoapStjudeOrg.Login Login_inst = new domainSoapStjudeOrg.Login();
		domainSoapStjudeOrg.Registration Registration_inst = new domainSoapStjudeOrg.Registration();
		//domainSoapStjudeOrg.Phone Phone_inst = new domainSoapStjudeOrg.Phone();
		domainSoapStjudeOrg.OrganizationAttributes OrganizationAttributes_inst = new domainSoapStjudeOrg.OrganizationAttributes();
		domainSoapStjudeOrg.TransactionXRef TransactionXRef_inst = new domainSoapStjudeOrg.TransactionXRef();
		//domainSoapStjudeOrg.Transaction_x Transaction_x_inst = new domainSoapStjudeOrg.Transaction_x();
		domainSoapStjudeOrg.Social Social_inst = new domainSoapStjudeOrg.Social();
		domainSoapStjudeOrg.LoginXRef LoginXRef_inst = new domainSoapStjudeOrg.LoginXRef();
		domainSoapStjudeOrg.Stamp Stamp_inst = new domainSoapStjudeOrg.Stamp();
		//domainSoapStjudeOrg.Interest Interest_inst = new domainSoapStjudeOrg.Interest();
		domainSoapStjudeOrg.PlannedGiftAdvisor PlannedGiftAdvisor_inst = new domainSoapStjudeOrg.PlannedGiftAdvisor();
		domainSoapStjudeOrg.SocialAttributes SocialAttributes_inst = new domainSoapStjudeOrg.SocialAttributes();
		domainSoapStjudeOrg.Constituent360XRef Constituent360XRef_inst = new domainSoapStjudeOrg.Constituent360XRef();
		//domainSoapStjudeOrg.Household Household_inst = new domainSoapStjudeOrg.Household();
		domainSoapStjudeOrg.Tickler Tickler_inst = new domainSoapStjudeOrg.Tickler();
		//domainSoapStjudeOrg.TransactionSource TransactionSource_inst = new domainSoapStjudeOrg.TransactionSource();
		domainSoapStjudeOrg.PhoneAttributes PhoneAttributes_inst = new domainSoapStjudeOrg.PhoneAttributes();
		//domainSoapStjudeOrg.Sys Sys_inst = new domainSoapStjudeOrg.Sys();
		//domainSoapStjudeOrg.PaymentDetail PaymentDetail_inst = new domainSoapStjudeOrg.PaymentDetail();
		domainSoapStjudeOrg.AddressAttributes AddressAttributes_inst = new domainSoapStjudeOrg.AddressAttributes();
		domainSoapStjudeOrg.EnrichmentProfile EnrichmentProfile_inst = new domainSoapStjudeOrg.EnrichmentProfile();
		domainSoapStjudeOrg.Contact Contact_inst = new domainSoapStjudeOrg.Contact();
		//domainSoapStjudeOrg.FinancialProfile FinancialProfile_inst = new domainSoapStjudeOrg.FinancialProfile();
		//domainSoapStjudeOrg.Individual Individual_inst = new domainSoapStjudeOrg.Individual();
		domainSoapStjudeOrg.LoyaltyProfile LoyaltyProfile_inst = new domainSoapStjudeOrg.LoyaltyProfile();
		domainSoapStjudeOrg.Audit Audit_inst = new domainSoapStjudeOrg.Audit();
		//domainSoapStjudeOrg.Address Address_inst = new domainSoapStjudeOrg.Address();
		//domainSoapStjudeOrg.Preference Preference_inst = new domainSoapStjudeOrg.Preference();
		domainSoapStjudeOrg.EventAttribute EventAttribute_inst = new domainSoapStjudeOrg.EventAttribute();
	}

	@isTest static void testCreditDetail(){
		domainSoapStjudeOrg.CreditDetail CreditDetail_inst = new domainSoapStjudeOrg.CreditDetail();
		CreditDetail_inst.TransactionXRef = null;
		CreditDetail_inst.ConstituentXRef = null;
		CreditDetail_inst.Name = 'test';
	}

	@isTest static void testOrganization(){
		domainSoapStjudeOrg.Organization Organization_inst = new domainSoapStjudeOrg.Organization();
		Organization_inst.ConstituentID = 'consIdTest';
		Organization_inst.Type_x = null;
		Organization_inst.Name = 'nameTest';
		Organization_inst.ParentOrgID = 'porgIDtest';
		Organization_inst.OrgID = 'orgIDtest';
		Organization_inst.Comments = 'commentsTest';
		Organization_inst.Profile = null;
		Organization_inst.Relationships = null;
		Organization_inst.OrganizationAttributes = null;
	}

	@isTest static void testProperty(){
		domainSoapStjudeOrg.Property Property_inst = new domainSoapStjudeOrg.Property();
		Property_inst.PropertyID = 'propTest';
		Property_inst.Property = 'propTest2';
		Property_inst.PropertyDesc = 'descTest';
		Property_inst.Status = 'statTest';
		Property_inst.StartDate = null;
		Property_inst.EndDate = null;
		Property_inst.Comments = 'commentTest';
	}

	@isTest static void testTypeAttribute(){
		domainSoapStjudeOrg.TypeAttribute TypeAttribute_inst = new domainSoapStjudeOrg.TypeAttribute();
		TypeAttribute_inst.ID = 'idTest';
		TypeAttribute_inst.Code = 'codeTest';
		TypeAttribute_inst.Description = 'descTest';
	}

	@isTest static void testInteraction(){
		domainSoapStjudeOrg.Interaction Interaction_inst = new domainSoapStjudeOrg.Interaction();
		Interaction_inst.InteractionID = 'intIDtest';
		Interaction_inst.ConstituentBase = null;
		Interaction_inst.ContactDate = 'contTest';
		Interaction_inst.ActualDate = null;
		Interaction_inst.ExpectedDate = null;
		Interaction_inst.ContactSeq = 1;
		Interaction_inst.Page_x = 2;
		Interaction_inst.ContactCategory = 'concatTest';
		Interaction_inst.ContactCategoryDesc = 'concatdescTest';
		Interaction_inst.ContactType = 'conTypeTest';
		Interaction_inst.ContactTypeDesc = 'conTypeDescTest';
		Interaction_inst.Technique = 'techTest';
		Interaction_inst.TechniqueDesc = 'techDescTest';
		Interaction_inst.Event = 'evTest';
		Interaction_inst.ContactExpense = 'contExpTest';
		Interaction_inst.TimeOfContact = 'tocTest';
		Interaction_inst.ResponseID = 'respIDTest';
		Interaction_inst.ResponseCategory = 'respCatTest';
		Interaction_inst.ResponseCategoryDesc = 'respCatDescTest';
		Interaction_inst.ResponseType = 'respTypeTest';
		Interaction_inst.ResponseTypeDesc = 'respTypeDescTest';
		Interaction_inst.ResponseDate = 'respDateTest';
		Interaction_inst.ResponseGiftSeq = 3;
		Interaction_inst.TotalRenewCount = 4;
		Interaction_inst.SolicitationCycle = 'solCycTest';
		Interaction_inst.Track = 'trackTest';
		Interaction_inst.BequestSeq = 5;
		Interaction_inst.Summary = 'sumTest';
		Interaction_inst.LongComments = 'longComTest';
		Interaction_inst.NoteTopicId = 6;
		Interaction_inst.Tickler = null;
		Interaction_inst.Warning = 'warnTest';
		Interaction_inst.WarningExpirationDate = 'warnExpDatTest';
		Interaction_inst.Reporting = null;
		Interaction_inst.TransactionSource = null;
		Interaction_inst.Solicitor = 'solicTest';
		Interaction_inst.Sender = 'sendTest';
		Interaction_inst.Staff = 'staffTest';
		Interaction_inst.Status = 'statusTest';
		Interaction_inst.ActivityStatus = 'actStatTest';
		Interaction_inst.DateEntered = 'dateEntTest';
		Interaction_inst.Stamp = null;
		Interaction_inst.DateInserted = null;
		Interaction_inst.Participation = 'partTest';
		Interaction_inst.Region = 'regTest';
		Interaction_inst.LinkId = 'linkIdTest';
	}

	@isTest static void testProfile(){
		domainSoapStjudeOrg.Profile Profile_inst = new domainSoapStjudeOrg.Profile();
		Profile_inst.Addresses = null;
		Profile_inst.Phones = null;
		Profile_inst.Emails = null;
		Profile_inst.Social = null;
		Profile_inst.FinancialProfile = null;
		Profile_inst.LoyaltyProfile = null;
		Profile_inst.EnrichmentProfile = null;
		Profile_inst.MarketingProfile = null;
	}

	@isTest static void testEmail(){
		domainSoapStjudeOrg.Email Email_inst = new domainSoapStjudeOrg.Email();
		Email_inst.ContactXRef = null;
		Email_inst.ContactType = 'contTypeTest';
		Email_inst.ContactID = 'contIDTest';
		Email_inst.ContactPreference = null;
		Email_inst.EmailType = null;
		Email_inst.EmailAddress = 'emailTest';
		Email_inst.Status = 'statTest';
		Email_inst.Preferred = true;
		Email_inst.Comments = 'commentTest';
		Email_inst.EmailAttributes = null;
	}

	@isTest static void testRelationship(){
		domainSoapStjudeOrg.Relationship Relationship_inst = new domainSoapStjudeOrg.Relationship();
		Relationship_inst.RelationshipID = 'relIDtest';
		Relationship_inst.Status = 'statTest';
		Relationship_inst.RelatedConstituent = null;
		Relationship_inst.Type_x = null;
		Relationship_inst.ReciprocalType = null;
		Relationship_inst.StartDate = null;
		Relationship_inst.EndDate = null;
		Relationship_inst.CompanyMatch = true;
		Relationship_inst.Comments = 'commentTest';
	}

	@isTest static void testDocumentation(){
		domainSoapStjudeOrg.Documentation Documentation_inst = new domainSoapStjudeOrg.Documentation();
		Documentation_inst.DocumentationID = 'docuIDTest';
		Documentation_inst.Type = 'typeTest';
		Documentation_inst.DocumentationType = 'docuTypeTest';
		Documentation_inst.Title = 'titleTest';
		Documentation_inst.Name = 'nameTest';
		Documentation_inst.MediaURL = 'MediaURLTest';
		Documentation_inst.TextNote = 'testNoteTest';
		Documentation_inst.HtmlNote = 'htmlTest';
		Documentation_inst.DateEntered = 'dateEntTest';
		Documentation_inst.Status = 'statTest';
		Documentation_inst.Technique = 'techTest';
		Documentation_inst.ResponseCategory = 'respCatTest';
		Documentation_inst.ResponseType = 'respTypeTest';
		Documentation_inst.ResponseDate = 'respDateTest';
		Documentation_inst.ResponseGiftSeq = 1;
	}

	@isTest static void testSystemXRef(){
		domainSoapStjudeOrg.SystemXRef SystemXRef_inst = new domainSoapStjudeOrg.SystemXRef();
		SystemXRef_inst.Sys = null;
		SystemXRef_inst.XRefKey = 'xRefTest';
		SystemXRef_inst.AlternateXRefKey = 'altXRefTest';
		domainSoapStjudeOrg.SystemXRefs SystemXRefs_inst = new domainSoapStjudeOrg.SystemXRefs();
		SystemXRefs_inst.SystemXRef = null;
	}

	@isTest static void testPhone(){
		domainSoapStjudeOrg.Phone Phone_inst = new domainSoapStjudeOrg.Phone();
		Phone_inst.ContactXRef = null;
		Phone_inst.ContactType = 'contTest';
		Phone_inst.ContactID = 'contIDTest';
		Phone_inst.ContactPreference = null;
		Phone_inst.PhoneType = null;
		Phone_inst.PhoneNumber = '1-800-Too-Test';
		Phone_inst.PhoneExtension = '123';
		Phone_inst.Preferred = true;
		Phone_inst.PreferredTime = '1';
		Phone_inst.PreferredFromDate = 'prefTest';
		Phone_inst.PreferredThroughDate = 'prefthroughTest';
		Phone_inst.Status = 'statTest';
		Phone_inst.Comments = 'commentTest';
		Phone_inst.VendorAcquired = true;
		Phone_inst.PhoneAttributes = null;
	}

	@isTest static void testConstituentBase(){
		domainSoapStjudeOrg.ConstituentBase ConstituentBase_inst = new domainSoapStjudeOrg.ConstituentBase();
		ConstituentBase_inst.ConstituentID = 'consIdTest';
		ConstituentBase_inst.UUID = 'uuidTest';
		ConstituentBase_inst.SystemXRef = null;
		ConstituentBase_inst.Type_x = null;
	}

	@isTest static void testAdjustment(){
		domainSoapStjudeOrg.Adjustment Adjustment_inst = new domainSoapStjudeOrg.Adjustment();
		Adjustment_inst.AdjustmentID = '123';
		Adjustment_inst.Date_x = 'dateTest';
		Adjustment_inst.Reason = 'reasonTest';
		Adjustment_inst.Description = 'descTest';
		Adjustment_inst.PreviousAmount = 1.5;	
	}

	@isTest static void testRecognition(){
		domainSoapStjudeOrg.Recognition Recognition_inst = new domainSoapStjudeOrg.Recognition();
		Recognition_inst.RecognitionID = 'reconID';
		Recognition_inst.ConstituentID = 'consIdTest';
		Recognition_inst.Name = 'nameTest';
		Recognition_inst.FinancialTransactionID = 'finTransIDtest';
		Recognition_inst.Date_x = 'dateTest';
		Recognition_inst.Type = 'typeTest';
		Recognition_inst.Amount = 1.5;
	}

	@isTest static void testRevenueNote(){
		domainSoapStjudeOrg.RevenueNote RevenueNote_inst = new domainSoapStjudeOrg.RevenueNote();
		RevenueNote_inst.RevenueNoteID = 'revNoteIDtest';
		RevenueNote_inst.Date_x = 'dateTest';
		RevenueNote_inst.Title = 'titleTest';
		RevenueNote_inst.NoteType = 'noteTypeTest';
		RevenueNote_inst.TextNote = 'testNoteTest';
		RevenueNote_inst.HtmlNote = 'htmlTest';
	}

	@isTest static void testTransaction_x(){
		domainSoapStjudeOrg.Transaction_x Transaction_x_inst = new domainSoapStjudeOrg.Transaction_x();
		Transaction_x_inst.TransactionXRef = null;
		Transaction_x_inst.ConstituentXRef = null;
		Transaction_x_inst.FinancialTransactionID = 'finTransIDtest';
		Transaction_x_inst.TransactionID = 'tranTest';
		Transaction_x_inst.AlternateTransactionID = 'altTranTest';
		Transaction_x_inst.SourceTransactionKey = 'sourTranKeyTest';
		Transaction_x_inst.ConstituentBase = null;
		Transaction_x_inst.TransactionType = 'tranTypeTest';
		Transaction_x_inst.TransactionDesc = 'tranDescTest';
		Transaction_x_inst.GiftType = 'gftTest';
		Transaction_x_inst.GiftDate = null;
		Transaction_x_inst.DateInserted = null;
		Transaction_x_inst.GiftApplyMMYY = 'gftApplyTest';
		Transaction_x_inst.PullDay = 'pullTest';
		Transaction_x_inst.CardNotCharged = true;
		Transaction_x_inst.SoftCreditType = 'sftCredTest';
		Transaction_x_inst.CreditDetail = null;
		Transaction_x_inst.SpecialActionComments = 'sActionsComTest';
		Transaction_x_inst.PullMonth = 'pullMonTest';
		Transaction_x_inst.Frequency = 'freqTest';
		Transaction_x_inst.PledgeStatus = 'pledStatTest';
		Transaction_x_inst.Status = 'statTest';
		Transaction_x_inst.PledgeNumOfInstallments = 15;
		Transaction_x_inst.Currency_x = 'dollars';
		Transaction_x_inst.TotalPledgeAmount = 1.5;
		Transaction_x_inst.TotalRecurringGiftAmount = 2.5;
		Transaction_x_inst.TotalPaidAmount = 5.5;
		Transaction_x_inst.PaymentAmount = 3.5;
		Transaction_x_inst.HoldFromDate = null;
		Transaction_x_inst.HoldEndDate = null;
		Transaction_x_inst.TransactionSource = null;
		Transaction_x_inst.PaymentDetail = null;
		Transaction_x_inst.TransactionHistory = null;
		Transaction_x_inst.OpenBills = null;
		Transaction_x_inst.TotalPayments = 1;
		Transaction_x_inst.MemorialType = 'memTypeTest';
		Transaction_x_inst.TributeID = 'tribIDtest';
		Transaction_x_inst.AckCode = 'ackCodeTest';
		Transaction_x_inst.Adjustments = null;
		Transaction_x_inst.RevenueNotes = null;
		Transaction_x_inst.Recognition = null;
		Transaction_x_inst.LinkId = 'linkIdTest';
		Transaction_x_inst.ConstituentName = 'consNameTest';
	}

	@isTest static void testInterest(){
		domainSoapStjudeOrg.Interest Interest_inst = new domainSoapStjudeOrg.Interest();
		Interest_inst.ConstituentBase = null;
		Interest_inst.InterestID = 'intIDtest';
		Interest_inst.Interest = 'intTest';
		Interest_inst.InterestDesc = 'intDescTest';
		Interest_inst.ProgramType = 'proTypeTest';
		Interest_inst.ProgramTypeDesc = 'proTypeDescTest';
		Interest_inst.Comments = 'commentTest';
		Interest_inst.Status = 'statTest';
	}

	@isTest static void testHousehold(){
		domainSoapStjudeOrg.Household Household_inst = new domainSoapStjudeOrg.Household();
		Household_inst.ConstituentID = null;
		Household_inst.Type_x = null;
		Household_inst.Profile = null;
		Household_inst.Relationships = null;
	}

	@isTest static void testTransactionSource(){
		domainSoapStjudeOrg.TransactionSource TransactionSource_inst = new domainSoapStjudeOrg.TransactionSource();
		TransactionSource_inst.Code = 'codeTest';
		TransactionSource_inst.Description = 'descTest';
		TransactionSource_inst.Initiative = 'initTest';
		TransactionSource_inst.Event = 'evenTest';
		TransactionSource_inst.Effort = 'effTest';
		TransactionSource_inst.Channel = 'chanTest';
		TransactionSource_inst.Program = 'proTest';
		TransactionSource_inst.Activity = 'actTest';
		TransactionSource_inst.Campaign = 'campTest';
		TransactionSource_inst.Technique = 'techTest';
		TransactionSource_inst.SourceDate = null;
	}

	@isTest static void testSys(){
		domainSoapStjudeOrg.Sys Sys_inst = new domainSoapStjudeOrg.Sys();
		Sys_inst.ID = 'idTest';
		Sys_inst.Name = 'nameTest';
	}

	@isTest static void testPaymentDetail(){
		domainSoapStjudeOrg.PaymentDetail PaymentDetail_inst = new domainSoapStjudeOrg.PaymentDetail();
		PaymentDetail_inst.PaymentMethod = 'payMethTest';
		PaymentDetail_inst.PaymentFName = 'payFNameTest';
		PaymentDetail_inst.PaymentMName = 'payMNameTest';
		PaymentDetail_inst.PaymentLName = 'payLNameTest';
		PaymentDetail_inst.CCLast4 = '1234';
		PaymentDetail_inst.CCExpirationDate = '4/20';
		PaymentDetail_inst.Alias = 'aliasTest';
		PaymentDetail_inst.MerchantID = 'merchTest';
		PaymentDetail_inst.MerchantRefCode = 'merchRefTest';
		PaymentDetail_inst.RequestID = 'requestTest';
		PaymentDetail_inst.RequestToken = 'requestToken';
		PaymentDetail_inst.ReconciliationID = 'reconIDTest';
		PaymentDetail_inst.BankApprovalStatus = 'bankApprStatTest';
		PaymentDetail_inst.BankApprovalCode = 'bankApprCodeTest';
	}

	@isTest static void testFinancialProfile(){
		domainSoapStjudeOrg.FinancialProfile FinancialProfile_inst = new domainSoapStjudeOrg.FinancialProfile();
		FinancialProfile_inst.LifeTimePaidAmount = 1.5;
		FinancialProfile_inst.LifeTimeCount = 1;
		FinancialProfile_inst.TotalYearsWithRevenue = 2;
		FinancialProfile_inst.FirstGiftAmount = 2.5;
		FinancialProfile_inst.FirstGiftDate = null;
		FinancialProfile_inst.LastGiftAmount = 3.5;
		FinancialProfile_inst.LastGiftDate = null;
		FinancialProfile_inst.LargestGiftAmount = 1.5;
		FinancialProfile_inst.LargestGiftDate = null;
		FinancialProfile_inst.RealestateAssets = 5.5;
		FinancialProfile_inst.BusinessOwnershipAssets = 6.5;
		FinancialProfile_inst.SecuritiesAssets = 7.5;
		FinancialProfile_inst.OtherAssets = 8.5;
	}

	@isTest static void testIndividual(){
		domainSoapStjudeOrg.Individual Individual_inst = new domainSoapStjudeOrg.Individual();
		Individual_inst.ConstituentID = 'consIdTest';
		Individual_inst.UUID = 'uuidTest';
		Individual_inst.SystemXRef = null;
		Individual_inst.Type_x = null;
		Individual_inst.Staff = null;
		Individual_inst.Status = 'statTest';
		Individual_inst.Preferred = true;
		Individual_inst.Profile = null;
		Individual_inst.Relationships = null;
		Individual_inst.Interests = null;
		Individual_inst.Preferences = null;
		Individual_inst.Interactions = null;
		Individual_inst.PlannedGifts = null;
		Individual_inst.Properties = null;
		Individual_inst.Transactions = null;
		Individual_inst.Logins = null;
		Individual_inst.Title = null;
		Individual_inst.FirstName = 'John';
		Individual_inst.LastName = 'Test';
		Individual_inst.MiddleName = 'McTest';
		Individual_inst.MaidenName = 'Tester';
		Individual_inst.Email = 'emailTest';
		Individual_inst.Phone = 'phoneTest';
		Individual_inst.Suffix = null;
		Individual_inst.LongName = 'JTest';
		Individual_inst.Comments = 'commentTest';
		Individual_inst.RelatedHousehold = null;
		Individual_inst.IndividualAttributes = null;
	}

	@isTest static void testRelatedHousehold(){
		domainSoapStjudeOrg.RelatedHousehold RelatedHousehold_inst = new domainSoapStjudeOrg.RelatedHousehold();
		RelatedHousehold_inst.ConstituentID = 'consIdTest';
		RelatedHousehold_inst.Name = 'nameTest';
		RelatedHousehold_inst.SystemXRef = null;
		RelatedHousehold_inst.SystemXRefs = null;
	}

	@isTest static void testConstituent(){
		domainSoapStjudeOrg.Constituent Constituent_inst = new domainSoapStjudeOrg.Constituent();
		Constituent_inst.ConstituentID = 'contIDTest';
		Constituent_inst.UUID = 'uuidTest';
		Constituent_inst.SystemXRef = null;
		Constituent_inst.Type_x = null;
		Constituent_inst.Staff = null;
		Constituent_inst.Status = 'statTest';
		Constituent_inst.Preferred = true;
		Constituent_inst.Profile = null;
		Constituent_inst.Relationships = null;
		Constituent_inst.Interests = null;
		Constituent_inst.Preferences = null;
		Constituent_inst.Interactions = null;
		Constituent_inst.PlannedGifts = null;
		Constituent_inst.Properties = null;
		Constituent_inst.Transactions = null;
		Constituent_inst.Logins = null;
		Constituent_inst.Title = null;
		Constituent_inst.Name = 'nameTest';
		Constituent_inst.ParentOrgID = 'parOrgIDtest';
		Constituent_inst.OrgID = 'orgIDtest';
		Constituent_inst.FirstName = 'John';
		Constituent_inst.LastName = 'Test';
		Constituent_inst.MiddleName = 'McTest';
		Constituent_inst.MaidenName = 'Tester';
		Constituent_inst.Email = 'emailTest';
		Constituent_inst.Phone = 'phoneTest';
		Constituent_inst.Suffix = null;
		Constituent_inst.LongName = 'JTest';
		Constituent_inst.Comments = 'commentTest';
		//Constituent_inst.VIP_Yes = 'Yes';
		Constituent_inst.RelatedHousehold = null;
		Constituent_inst.IndividualAttributes = null;
		Constituent_inst.HouseholdAttributes = null;
		Constituent_inst.OrganizationAttributes = null;
	}

	@isTest static void testAddress(){
		domainSoapStjudeOrg.Address Address_inst = new domainSoapStjudeOrg.Address();
		Address_inst.ContactXRef = null;
		Address_inst.ContactType = 'conTypeTest';
		Address_inst.ContactID = 'contIDTest';
		Address_inst.ContactPreference = null;
		Address_inst.AddressType = null;
		Address_inst.ApartmentNumber = 'aprtTest';
		Address_inst.StreetNumber = '123';
		Address_inst.StreetName = 'road';
		Address_inst.Street1 = 'road1';
		Address_inst.Street2 = 'road2';
		Address_inst.Street3 = 'road3';
		Address_inst.City = 'TestVille';
		Address_inst.State = 'Test Virginia';
		Address_inst.Country = 'USA';
		Address_inst.ZipCode = '12345';
		Address_inst.ZipExtension = '321';
		Address_inst.Preferred = true;
		Address_inst.Seasonal = false;
		Address_inst.PreferredDuringDates = 'prefTest';
		Address_inst.PreferredFromDate = 'prefFromTest';
		Address_inst.PreferredThroughDate = 'prefthroughTest';
		Address_inst.Status = 'statTest';
		Address_inst.Comments = 'commentTest';
		Address_inst.CarrierRoute = 'carrierTest';
		Address_inst.County = 'shelby';
		Address_inst.CongressionalDistrict = 'congDistTest';
		Address_inst.UndeliverableCount = 5;
		Address_inst.AddressAttributes = null;
	}

	@isTest static void testPreference(){
		domainSoapStjudeOrg.Preference Preference_inst = new domainSoapStjudeOrg.Preference();
		Preference_inst.ConstituentPreferenceID = 'consPrefIDTest';
		Preference_inst.PreferenceID = 'prefIDTest';
		Preference_inst.Preference = 'prefTest';
		Preference_inst.PreferenceDesc = 'prefDescTest';
		Preference_inst.PreferenceValueID = 'notaquid';
		Preference_inst.PreferenceValue = 'valueTest';
		Preference_inst.PreferenceValueDesc = 'prefValuDescTest';
		Preference_inst.PreferenceTypeID = 'prefTypeIDTest';
		Preference_inst.PreferenceType = 'prefTypeTest';
		Preference_inst.PreferenceTypeDesc = 'prefTypeDescTest';
		Preference_inst.ProgramType = 'progTypeTest';
		Preference_inst.ProgramTypeDesc = 'progTypeDescTest';
		Preference_inst.StartDate = null;
		Preference_inst.EndDate = null;
		Preference_inst.Status = 'statTest';
		Preference_inst.Comments = 'commentTest';
	}

}