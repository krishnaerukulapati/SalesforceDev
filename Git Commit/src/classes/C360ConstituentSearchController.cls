global with sharing class C360ConstituentSearchController {
	public domainSoapStjudeOrg.Constituent con {get; private Set;}
	public domainSoapStjudeOrg.Transaction_x[] transactions {get; private Set;}
	public domainSoapStjudeOrg.SystemXRef[] xrs {get; private Set;}
	public domainSoapStjudeOrg.Interest[] ints {get; private Set;}
	public boolean isConsole {get; set;}

	public String getBackURL() {
		return Page.C360ConstituentSearch.getUrl() + 
			'?search=' + ApexPages.currentPage().getParameters().get('search') + 
			'&searchType=' + ApexPages.currentPage().getParameters().get('searchType');
	}

	public PageReference CreateCase() {
		System.debug(ApexPages.currentPage().getParameters().get('SelectUUID'));
		System.debug(ApexPages.currentPage().getParameters().get('SelectName'));
		System.debug(ApexPages.currentPage().getParameters().get('SelectConType'));
		system.debug('isConsole: ' + string.valueof(isConsole));

		String consName = ApexPages.currentPage().getParameters().get('SelectName');
		String consType = ApexPages.currentPage().getParameters().get('SelectConType');
		String selectUUID = ApexPages.currentPage().getParameters().get('SelectUUID');
		String consId = ApexPages.currentPage().getParameters().get('ConsId');

		PageReference pr = Page.C360CaseFromLead;
		pr.getParameters().put('consId', consId);
		return pr;
		//return ECCUtil.CreateAssignedCase(consName, consType, selectUUID, 'Other');
	}

	public C360ConstituentSearchController(ApexPages.StandardController controller) {
		String consId = System.currentPageReference().getParameters().get('consId');
		String caseId = System.currentPageReference().getParameters().get('id');
		System.debug('caseId: ' + caseId);
		if (caseId != null && caseId.length() > 0) {
			ConstituentInformation__c c = [select id, ConstituentID__c from ConstituentInformation__c where CaseID__c = :caseId and Preferred__c = true];
			consId = c.ConstituentID__c;
		}
		system.debug('consId: ' + consId);
		if (consId != null) {
			con = C360Util.getConstituent(null, consId, new string[] {'PROFILE', 'PROPERTIES', 
				'FINANCIAL_PROFILE', 'PREFERENCES', 'RELATIONSHIPS', 'XREFS'});

			system.debug('get constituent success');
			soapStjudeOrg.GetInteractionsResponse_element gire;
			soapStjudeOrg.GetTransactionsResponse_element gtre;
			try {
				gire = C360Util.getInteractions(consId, 'ALL', 1, 20);
			}
			catch(Exception e) {
				//leave it null, i guess.  
			}

			try {
				gtre = C360Util.getTransations(null, consId, 1, 20, 'DIRECT_ALL', 'GIFT_DESC');
			}
			catch(Exception e) {
				//also null?
			}

			try {
        		ints = C360Util.getInterests(consId);
			}
			catch(Exception e) {
				//leave it null, i guess.  
			}

			try {
        		xrs = C360Util.getConstituentXRefs(consId, '');
			}
			catch(Exception e) {
				//leave it null, i guess.  
			}
			/*
			if (gire != null && gire.TotalResults > 0 && gire.Interactions != null) {
				interactions = gire.Interactions;
			}
			else {
				interactions = new domainSoapStjudeOrg.Interaction[] {};
			}*/

			if (gtre != null && gtre.TotalResults > 0 && gtre.Transactions != null) {
				transactions = gtre.Transactions;
			}
			else {
				transactions = new domainSoapStjudeOrg.Transaction_x[] {};
			}
		}
	}

	@RemoteAction
	global static soapStjudeOrg.SearchConstituents360Response_element searchConstituents(String pPhone, 
			String pAddress1, String pName, String pZip, String pCity, String pState, String pDonorId, 
			String pPledgeId, String pAltId, String pEmail, integer pStartRow, integer pEndRow,
			String pLastName, String pFirstName, String p2pId) {
		system.debug('searchConstituents');
		return C360Util.searchC360('ALL', pPhone,  pAddress1,  null, pName,  pLastName,  pFirstName,
			pZip,  pCity,  pState,  pDonorId,  pPledgeId,  pAltId,  pEmail,
			pStartRow, pEndRow, null, p2pId);
	}
}