public with sharing class AddLeadFromCaseToCampaignController {
    public String consId {get; set;}
    public String callId {get; set;}
    public String campAddReferral {get;  set;}
    public String consType {get;  set;}
    public String consName {get;  set;}
    public String phoneNum {get; set;}
    public String email {get; set;}
    public RecordType rt {get;  set;}
    public Campaign cmp {get;  set;}
    public Boolean bDuplicate {get; private set;}
    public domainSoapStjudeOrg.Constituent con {get; set;}
    List<Campaign> recruitmentCampaignList = new List<Campaign>();
    Map<String, String> dict = new Map<String, String>();

    public AddLeadFromCaseToCampaignController() {
        consId = System.currentPageReference().getParameters().get('consId');
        callId = System.currentPageReference().getParameters().get('callId');
        campAddReferral = System.currentPageReference().getParameters().get('campAddReferral');
        consType = System.currentPageReference().getParameters().get('consType');
        consName = System.currentPageReference().getParameters().get('consName');
        con = C360Util.getConstituent(null, consId, new string[] {'PROFILE'}, 'ALL');
    }

    public LIST<SelectOption> getPhoneTypes() {
        return ECCUtil.getSelectFromC360Att(C360Util.getData('PHONE_TYPES')); 
    }

    public list<SelectOption> getRecruitmentCampaignsList(){
        System.debug('getRecruitedCampaigns list?');
        recruitmentCampaignList =  ECCUtil.getRecruitmentCampaigns();
        System.debug('recruitmentCampaignList = ' + recruitmentCampaignList);
        list<SelectOption>  lstOptions = new list<SelectOption>();
        for(Campaign getCampList : recruitmentCampaignList){
            lstOptions.add(new SelectOption(getCampList.Id, getCampList.name));
            // dict.put(getCampList.Id, getCampList.name);
        }
        System.debug('lstOptions = ' + lstOptions);
        return lstOptions;
    }

    public PageReference saveLead() {
        system.debug('campAddReferral: ' + campAddReferral);
        system.debug('consId: ' + consId);
        system.debug('consType: ' + consType);
        system.debug('consName: ' + consName);
        system.debug('phoneNum: ' + phoneNum);

        cmp = [select LeadRecType__c from Campaign where Id = :campAddReferral];
        if(cmp.LeadRecType__c != null){
            system.debug('cmp.LeadRecType__c : ' + cmp.LeadRecType__c);
            rt = [select Id from RecordType where DeveloperName = :cmp.LeadRecType__c and sObjectType = 'Lead'];
        }
        else{
            rt = [select Id from RecordType where DeveloperName = 'St_Jude_Challenge' and sObjectType = 'Lead']; 
            system.debug('rt.Id : ' + rt.Id);
        }

        List<Lead> dupLead = [select id from lead where RecordTypeId = :rt.Id and (ConstituentID__c = :consId or CoordinatorID__c = :consId) and CurrentCampaign__c = :campAddReferral];
        system.debug('dupLead.size(): ' + dupLead.size());
        if (dupLead.size() > 0) {
            bDuplicate = true;
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This lead already exists.'));
            return null;
        }
        else {
            domainSoapStjudeOrg.Constituent con = C360Util.getConstituent(null, consId, null, 'ALL');
            
            domainSoapStjudeOrg.Individual i = new domainSoapStjudeOrg.Individual();
            domainSoapStjudeOrg.Profile p = new domainSoapStjudeOrg.Profile();
            domainSoapStjudeOrg.Phone ph = new domainSoapStjudeOrg.Phone();
            domainSoapStjudeOrg.TypeAttribute pt = new domainSoapStjudeOrg.TypeAttribute();

            i.ConstituentID = consId;
            i.FirstName = con.firstName;
            i.LastName = con.lastName;

            //Save Phone
            ph.ContactType = 'P';
            ph.Preferred = true;
            ph.PhoneNumber = ECCUtil.formatPhone(phoneNum);
            pt.Code = 'HOME';
            ph.PhoneType = pt;
            p.Phones = new domainSoapStjudeOrg.Phone[] {ph};
            i.Profile = p;
            C360Util.EditConstituent(i, null, null);
            Id id = ECCUtil.CreateLeadReferral(campAddReferral, consId, consType, consName, rt.Id, phoneNum, null, callId);
            PageReference detail = new PageReference('/apex/C360OpenConsole?cid=' + id);
            detail.setRedirect(true);
            system.debug('detail.getUrl() ' + detail.getUrl());
            return detail;
        }
    }
}