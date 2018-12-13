global class RefreshSandboxDev implements SandboxPostCopy {
	global void runApexClass(SandboxContext context) {
		System.debug('Hello Tester Pester ' + context.organizationId() + ' ' + context.sandboxId() + context.sandboxName());
		//de-production a dev org

		//BBEC Settings
		List<BbecSettings__c> bss = [
			select 
				Id
				, Name
				, BbecURL__c 
			from
				BbecSettings__c];

		if (bss.size() > 0) {
			for (BbecSettings__c bs : bss) {
				if (bs.Name == 'Master') {
					bs.BbecURL__c = 'https://dmsappd1s1.alsac.local/dms/webui/webshellpage.aspx?databasename=DMS#pageType=p&pageId=88159265-2b7e-4c7b-82a2-119d01ecd40f&recordId=';
				}
				else {
					//reset cuz it probably points at prod
					bs.BbecURL__c = '';
				}
			}

			upsert bss;
		}

		//C360 (and other) settigns
		List<C360Settings__c> c360s = [
			select 
				Id
				, Name
				, C360SettingsURL__c 
			from
				C360Settings__c];

		if (c360s.size() > 0) {
			for (C360Settings__c c360 : c360s) {
				if (c360.Name == 'Master') {
					c360.C360SettingsURL__c = 'https://servicesdev.qa.stjude.org/Constituent360/ConstituentPort';
				}
				else if (c360.Name == 'Mavro') {
					c360.C360SettingsURL__c = 'https://mavroarp1s1.alsac.local/mavro/mavarc/getpdf.aspx?webkey=##WEBKEY##&username=mavprdsa&password=TUFWMHAzcmF0aW9ucyE=&rearimg=1';
				}
				else if (c360.Name == 'SOURCE') {
					c360.C360SettingsURL__c = 'https://epsappd1s1.alsac.local/SourceCodes';
				}
				else {
					//reset cuz it probably points at prod
					c360.C360SettingsURL__c = '';
				}
			}

			upsert c360s;
		}

		//ccDonate - ought to move this into generic one
		List<ccDonateSettings__c> ccds = [
			select 
				Id
				, Name
				, ccDonateSettingsURL__c
			from
				ccDonateSettings__c];

		if (ccds.size() > 0) {
			for (ccDonateSettings__c ccd : ccds) {
				if (ccd.Name == 'Master') {
					ccd.ccDonateSettingsURL__c = 'https://accd1s1.alsac.local/accredit/ccDonate/Account/Land.aspx?';
				}
				else {
					//reset cuz it probably points at prod
					ccd.ccDonateSettingsURL__c = '';
				}
			}

			upsert ccds;
		}


		//Email addresses
		List<EmailSettings__c> emails = [
			select 
				Id
				, Name
				, Email__c
			from
				EmailSettings__c];

		if (emails.size() > 0) {
			for (EmailSettings__c email : emails) {
				if (email.Name == 'Heroes Segmentation') {
					email.Email__c = 'josh.rozier@stjude.org';
				}
                else if (email.Name == 'Remove Archived CampMem') {
					email.Email__c = 'belinda.tinsley@stjude.org';
				}
				else {
					//email me, i guess
					email.Email__c = 'josh.rozier@stjude.org';
				}
			}

			upsert emails;
		}

		//Environment settings
		List<EnvironmentSettings__c> ess = [
            SELECT 
				Id
                , EventInventory__c
                , FieldOpsReporting__c
                , SourceCodes__c
                , i360ContactDS__c
                , i360Events__c
                , Act2HoursToWait__c
                , Requests__c
                , EVMActiveStatusID__c
                , Cult2HoursToWait__c
                , EVMCancelledStatusID__c
                , EventDayURL__c
                , GuestAppURL__c
                , ChallHoursToWait__c
                , DMSOrg__c
                , EventsOrg__c
                , Report__c
                , WholesaleMerch__c
                , i360ContactPS__c
                , ActHoursToWait__c
                , CultHoursToWait__c
                , EVMCoordinatorRoleID__c
                , EVMDeletedStatusID__c
                , EVMOrganizerRoleID__c
                , ORAURL__c
                , StaffRegURL__c
                , FOSalesforceReports__c
            from
                EnvironmentSettings__c];

		if (ess.size() > 0) {
	        for (EnvironmentSettings__c es : ess) {
	            //doing this for all.  we don't want *any* unanticipated prod connections that we can avoid
	            es.EventInventory__c = 'https://amostest.stjude.org/sites/eventinventory/';
	            es.FieldOpsReporting__c = 'https://qamos2.stjude.org/sites/FO';
	            es.SourceCodes__c = 'https://epsappd1s1.alsac.local/sourcecodeapp';
	            es.i360ContactDS__c = 'https://stjecc--dev.cs7.my.salesforce.com/console?tsid=02uF0000000McnP';
	            es.i360Events__c = 'https://stjecc--dev.cs7.my.salesforce.com/home/home.jsp?tsid=02uM00000008nOj';
	            es.Act2HoursToWait__c = 168;
	            es.Requests__c = 'http:///setup/ui/recordtypeselect.jsp?ent=01IM0...';
	            es.EVMActiveStatusID__c = 'C32E1CC8-B034-4D8F-842B-DC22C3A62B64';
	            es.Cult2HoursToWait__c = 168;
	            es.EVMCancelledStatusID__c = '59311144-A18E-4F50-9E74-AE3DD6B4C096';
	            es.EventDayURL__c = 'https://eventapps.qa.stjude.org/events/login';
	            es.GuestAppURL__c = 'https://eventapps.qa.stjude.org/mobile/';
	            es.ChallHoursToWait__c = null;
	            es.DMSOrg__c = 'https://dmsappd1s1.alsac.local/dms/webui/webshellpage.aspx?databasename=DMS';
	            es.EventsOrg__c = 'https://alsacfed.stjude.org/adfs/ls/IdpInitiatedSignon.aspx?logintorp=https%3A%2F%2Fstj--events.cs10.my.salesforce.com';
	            es.Report__c = 'https://devamos2.stjude.org/sites/DevReporting/ReportDefs/';
	            es.WholesaleMerch__c = 'https://amostest.stjude.org/sites/MMR';
	            es.i360ContactPS__c = 'https://stjecc--dev.cs7.my.salesforce.com/00Q/o?tsid=02uF0000000MgZN';
	            es.ActHoursToWait__c = 168;
	            es.CultHoursToWait__c = 168;
	            es.EVMCoordinatorRoleID__c = 'A921D931-B561-57C5-E425-555B9A9819CD';
	            es.EVMDeletedStatusID__c = '9E01F24D-A559-47D9-BAA5-AFC6837AA1C5';
	            es.EVMOrganizerRoleID__c = 'AF03E4EB-C5E9-0615-8567-36458AE7145A';
	            es.ORAURL__c = 'https://eventapps.qa.stjude.org/ora/';
	            es.StaffRegURL__c = 'https://evtappq1s1/staffreg/login';
	            es.FOSalesforceReports__c = 'https://stjecc--dev--skuid.cs7.visual.force.com/apex/skuid__ui?page=FO_ReportsLandingPage';
	        }
			
			upsert ess;
		}

		//Odata Extension settings - only setting ones that appear to end points or auth
		List<OdataExtensionSettings__c> oes = [
            SELECT 
				Id
            	, Base_URL__c
            	, Event_Attributes_Endpoint__c
                , Lead_Staff_Base_Url__c
                , LeadStaffPassword__c
                , LeadStaffUsername__c
                , Password__c
                , Username__c
            from
                OdataExtensionSettings__c];
				
		if (oes.size() > 0) {
			for (OdataExtensionSettings__c oe : oes) {
	            oe.Base_URL__c = 'https://servicesdev.stjude.org/odata/';
	            oe.Event_Attributes_Endpoint__c = 'EventAttributes';
	            oe.Lead_Staff_Base_Url__c = 'https://servicesdev.stjude.org/';
	            oe.LeadStaffPassword__c = 'GG5c41co5oqqKBdOc3IH3XMUYIYqVZPPMUX0XGS8';
	            oe.LeadStaffUsername__c = 'Username';
	            oe.Password__c = 'a1evt$QA';
	            oe.Username__c = 'alsacnt/eventmasterqa';
	        }
			
			upsert oes;
		}


		//Pledge Maintenance Settings
		List<PledgeMaintenanceSettings__c> pms = [
			select 
				Id
				, Name
				, PledgeMaintURL__c 
			from
				PledgeMaintenanceSettings__c];

		if (pms.size() > 0) {
			for (PledgeMaintenanceSettings__c pm : pms) {
				if (pm.Name == 'Master') {
					pm.PledgeMaintURL__c = 'https://accd1s1.alsac.local/PledgeMaintenance/Account/Land';
				}
				else {
					//reset cuz it probably points at prod
					pm.PledgeMaintURL__c = '';
				}
			}

			upsert pms;
		}
	}
}