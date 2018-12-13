@isTest 
public with sharing class FOConsSearchRedirectContTest {
	@isTest static void FOConsSearchRedirectContTest() {
        Test.startTest();
        PageReference pageRef = Page.FOConsSearchRedirect;
        Test.setCurrentPage(pageRef);

        FOConsSearchRedirectController cac = new FOConsSearchRedirectController();
        cac.getSearchURL();   
	
		Test.stopTest();		
	}
}