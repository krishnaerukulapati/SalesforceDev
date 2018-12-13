public with sharing class ConstituentActionController {
    public String leadRecordType {get; set;}
    public String campaign {get; set;}

	public PageReference test() {
		return null;
	}

	public List<SelectOption> getLeadRecordTypes () {
		List<SelectOption> options = new List<SelectOption>();

		// pull lead record types from recordTypes table
		Schema.DescribeSObjectResult result = Schema.SObjectType.Lead;
		Map<id, Schema.RecordTypeInfo> rtMapById = result.getRecordTypeInfosById();
		for (Id rtId : rtMapById.keySet() ) {
			Schema.RecordTypeInfo rtInfo = rtMapById.get(rtId);
			options.add(new SelectOption(rtId, rtInfo.getName()));
		}

		return options;
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