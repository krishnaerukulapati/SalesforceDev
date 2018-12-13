public with sharing class ECCAddLeadToCampaignController {
    public String consId {get; private set;}
    public String campAddReferral {get; private set;}
    public String consType {get; private set;}
    public String consName {get; private set;}
    public String phoneNum {get; set;}
    public RecordType rt {get; private set;}
    public Boolean bDuplicate {get; private set;}
    public domainSoapStjudeOrg.Constituent con {get; set;}

    public ECCAddLeadToCampaignController() {
        consId = System.currentPageReference().getParameters().get('consId');
        campAddReferral = System.currentPageReference().getParameters().get('campAddReferral');
        consType = System.currentPageReference().getParameters().get('consType');
        consName = System.currentPageReference().getParameters().get('consName');
        rt = [select Id from RecordType where DeveloperName = 'St_Jude_Challenge' and sObjectType = 'Lead'];

        system.debug('consId: ' + consId);
        List<Lead> dupLead = [select id from lead where RecordTypeId = :rt.Id and (ConstituentID__c = :consId or CoordinatorID__c = :consId)];

        system.debug('dupLead.size(): ' + dupLead.size());
        if (dupLead.size() > 0) {
            bDuplicate = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This lead already exists.'));
        }
        else {
            bDuplicate = false;

            con = C360Util.getConstituent(null, consId, new string[] {'PROFILE'}, 'ALL');
        }
    }

    public PageReference saveLead() {
        system.debug('phoneNum: ' + phoneNum);
        if (!bDuplicate) {
            system.debug('phoneNum: ' + phoneNum);
            Id id = ECCUtil.CreateLeadReferral(campAddReferral, consId, consType, consName, rt.Id, phoneNum);

            PageReference detail = new PageReference('/' + id);
            detail.setRedirect(true);
            system.debug(detail.getUrl());
            return detail;
        }
        else {
            system.debug('bDuplicate: ' + bDuplicate);
            return null;
        }
    }
}