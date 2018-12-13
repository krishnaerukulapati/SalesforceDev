@isTest
private class DispositionControllerTest {

	@testSetup static void testSetup(){

	}

	@isTest static void testChangeDispoType() {
		
		Lead c = new Lead();
			c.LastName = 'test';
        	c.ConstituentID__c = 'notaquid';
        	c.Constituent_Type__c = 'INDIVIDUAL';
        	c.Company = 'fake';
        	insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();

        dispC.dispositionValue = 'something';
        dispC.changeDispoType();
        System.assertEquals('', dispC.dispositionValue, 'changeDispoType did not alter dispositionValue');
		Test.stopTest();
	}
	
	@isTest static void testResetDispo(){

		Lead c = new Lead();
			c.LastName = 'test';
        	c.ConstituentID__c = 'notaquid';
        	c.Constituent_Type__c = 'INDIVIDUAL';
        	c.Company = 'fake';
        	insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();

        dispC.dispositionType = 'someType';
        dispC.dispositionValue = 'someValue';
        dispC.callDate = 'sometime';
        dispC.callComments = 'something';
        dispC.resetDispo();
        System.assertEquals('', dispC.dispositionType, 'resetDispo() did not alter dispositionType');
        System.assertEquals('', dispC.dispositionValue, 'changeDispoType did not alter dispositionValue');
        System.assertEquals('', dispC.callDate, 'resetDispo() did not alter callDate');
        System.assertEquals('', dispC.callComments, 'resetDispo() did not alter callComments');
		Test.stopTest();
	}

	@isTest static void testValidate(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();

        dispC.dispositionType = null;
        dispC.validateForm();
        System.assertEquals(false, dispC.validateForm(), 'validForm did not catch null');
		Test.stopTest();
	}

	@isTest static void testSave(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();

        dispC.callDate = '08/04/2016';
        ECCUtil.consInfo ci = new ECCUtil.consInfo();
        String consId = '15151515';
        dispC.save(ci, consId);

		Test.stopTest();
	}

	@isTest static void testConvertDateValue(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();
        String callDate = '08/04/2016';
        dispC.convertDateValue(callDate);

		Test.stopTest();
	}

	@isTest static void testConcateTaskDispo(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();
        String dispoType = 'No';
        String dispoVal = 'Illness';
        String test1 = dispC.concateTaskDispo(dispoType, dispoVal);
        System.assertEquals('No - Illness', test1, 'concateTaskDispo did not concate properly');
        String dispoVal2 = '';
        String test2 = dispC.concateTaskDispo(dispoType, dispoVal2);
        //System.assertEquals('No', test2, 'concateTaskDispo did not assign dispoType correctly');

		Test.stopTest();
	}

	@isTest static void testGetConsInfo(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();
        String leadId = 'notaquid';
        ECCUtil.consInfo ci =	dispC.getConsInfoFromECCUtil(leadId);

		Test.stopTest();
	}

	@isTest static void testSendDispositionInfo(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();
        ECCUtil.consInfo ci = new ECCUtil.consInfo();
        String campId = 'notaquid';
        String dispoType = 'No';
        String dispoValue = 'Other';
        String callId = '12345';
        String dispoComments = 'test comments';
        Datetime callD = DateTime.now();
        dispC.sendDispositionInfo(ci, campId, dispoType, dispoValue, callId, dispoComments, callD);

		Test.stopTest();
	}

	@isTest static void testSendTaskInfo(){

		Lead c = new Lead();
		c.LastName = 'test';
        c.ConstituentID__c = 'notaquid';
        c.Constituent_Type__c = 'INDIVIDUAL';
        c.Company = 'fake';
        insert c;

		Test.startTest();
		
		PageReference pageRef = Page.DIYFitnessHighlights;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', c.id);

        DispositionController dispC = new DispositionController();
        ECCUtil.consInfo ci = new ECCUtil.consInfo();
        String contId = '15151515';
        String taskDisposition = 'No - Other';
        dispC.sendTaskInfo(ci, contId, taskDisposition);

		Test.stopTest();
	}
	
}