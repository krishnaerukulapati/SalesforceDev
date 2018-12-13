public with sharing class FOConsAddCaseController {

    public ApexPages.StandardController sController;
    private final Case c;

    public FOConsAddCaseController(ApexPages.StandardController controller) {
        sController = controller;
        c = (Case)controller.getRecord();      
    }

    public PageReference prepopulateValues() {
        c.Constituent_Name__c = System.currentPageReference().getParameters().get('name');
        c.ConstituentId__c = System.currentPageReference().getParameters().get('consId');
        c.ConstituentType__c = System.currentPageReference().getParameters().get('consType');
        c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('FO Donor Services / Program Support').getRecordTypeId();

        sController.save();        
        PageReference pr = sController.edit();
        System.debug('Lead ID: ' + c.Id);
        System.debug(pr);

        return pr;
    }    
}