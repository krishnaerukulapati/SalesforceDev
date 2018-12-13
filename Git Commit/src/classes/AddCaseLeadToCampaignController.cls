public with sharing class AddCaseLeadToCampaignController {
    public String consId {get; private set;}
    public String campAddReferral {get;  set;}
    public String selCampaignId {get;  set;}
    public String consType {get; private set;}
    public String consName {get; private set;}
    public String phoneNum {get; set;}
    public RecordType rt {get; private set;}
    public Boolean bDuplicate {get; private set;}
    public domainSoapStjudeOrg.Constituent con {get; set;}
    public String phoneTypeCode {Get; Set;}
    public String recruitedCampaignsOption {Get; Set;}
    List<Campaign> recruitedCampList = new List<Campaign>();
    Map<String, String> dict = new Map<String, String>();
    public String campaign {get; set;}


    public AddCaseLeadToCampaignController() {
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

    public LIST<SelectOption> getPhoneTypes() {
		return ECCUtil.getSelectFromC360Att(C360Util.getData('PHONE_TYPES')); 
	}

	/*public LIST<Campaign> getRecruitedCampaignsList() {
		System.debug('getRecruitedCampaigns list?');
		return ECCUtil.getRecruitedCampaigns(); 
	}*/

	public list<SelectOption> getRecruitedCampaignsList(){
	System.debug('getRecruitedCampaigns list?');
    //recruitedCampList =  ECCUtil.getRecruitedCampaigns();
    System.debug('recruitedCampList = ' + recruitedCampList);
    list<SelectOption>  lstOptions = new list<SelectOption>();
    for(Campaign getCampList : recruitedCampList){
    lstOptions.add(new SelectOption(getCampList.Id, getCampList.name));
   // dict.put(getCampList.Id, getCampList.name);
    }
    System.debug('lstOptions = ' + lstOptions);
    return lstOptions;
	}

    public PageReference saveLead() {
        selCampaignId = System.currentPageReference().getParameters().get('selCampaignId');
        system.debug('selCampaignId: ' + selCampaignId);
        system.debug('campAddReferral: ' + campAddReferral);
        system.debug('consId: ' + consId);
        system.debug('consType: ' + consType);
        system.debug('consName: ' + consName);
        system.debug('rt.Id: ' + rt.Id);
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

    public List<SelectOption> getCampaigns () {
		List<SelectOption> options = new List<SelectOption>();

		// pull all active campaigns
		Campaign[] activeCampaigns = [select id, name from campaign where isActive = true
									order by name];
		for (Campaign camp : activeCampaigns ) {
			options.add(new SelectOption(camp.id, camp.name));
		}

		return options;
	}
}