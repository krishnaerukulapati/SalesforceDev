@isTest
private class faultSoapStjudeOrgTest {
	
	@isTest static void testServiceFault() {
		
		Test.startTest();

		faultSoapStjudeOrg.ServiceFault cac = new faultSoapStjudeOrg.ServiceFault();

		Test.stopTest();
	}

	@isTest static void testInvalidMessageFault(){

		Test.startTest();

		faultSoapStjudeOrg.InvalidMessageFault cac = new faultSoapStjudeOrg.InvalidMessageFault();

		Test.stopTest();
	}
	
	
}