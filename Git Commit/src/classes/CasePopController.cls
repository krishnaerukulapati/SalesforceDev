/*******************************************************************
* Author        :  John Kirkpatrick
* Name          :  OutboundPopController
* Date          :  September 11th,2017
* Description   :  Used to create a case for Offline support              
*******************************************************************/

public with sharing class CasePopController{
	public String PhoneNumber {get; set;}
    private String OfflineRecordType = 'Offline';
    private String SubjectTemplate = 'Inbound Call from ';

    public CasePopController(ApexPages.StandardController controller) {
        
    }

	public PageReference createAndLoad() {
		system.debug('System.currentPageReference().getParameters().get(\'ani\'):' + System.currentPageReference().getParameters().get('ani'));
		system.debug('System.currentPageReference().getParameters().get(\'dnis\'):' + System.currentPageReference().getParameters().get('dnis'));
		system.debug('System.currentPageReference().getParameters().get(\'_c\'):' + System.currentPageReference().getParameters().get('_c'));
		system.debug('System.currentPageReference().getParameters().get(\'callid\'):' + System.currentPageReference().getParameters().get('callid'));

		String callId = System.currentPageReference().getParameters().get('_c');
		if (String.isEmpty(callId)) {
			callId = System.currentPageReference().getParameters().get('callid');
		}

		String ani = System.currentPageReference().getParameters().get('ani');
		if (String.isEmpty(ani)) {
			ani = System.currentPageReference().getParameters().get('dnis');
		}

		String caseId = CreateCase(ani, callId);
        system.debug('caseId: ' + caseId);

	  	PageReference pr = new PageReference('/' + caseId);
        pr.setRedirect(true);
        system.debug(pr.getUrl());

		return pr;
	}

	public String CreateCase(String phoneNbr, String callId)
	{
		String retVal = null;

		if (phoneNbr == null || phoneNbr == '')
		{
			return retVal;
		}

	    Case c = new Case();
	    
	    //set case values
	    RecordType rt = GetRecordTypeByName(OfflineRecordType);
	    c.RecordTypeId = rt.Id;
	    c.Status = 'New';
	    c.Subject = SubjectTemplate + phoneNbr;
		c.Origin = 'Phone';

		if (callId != null && callId != '')
		{
			c.CallObject__c = callId;
		}

	    insert c;
	    retVal = String.ValueOf(c.Id);
        system.debug('retVal: ' + retVal);
	    return retVal;
	}

	public RecordType GetRecordTypeByName(String name)
	{
		RecordType retVal = null;

		List<RecordType> rts = [
            select 
                  Id
                , Name
            from 
                RecordType 
            where 
                Name = :name];


        if (rts.size() > 0) {
            retVal = rts.get(0);
        }

        system.debug('retVal: ' + retVal);
        return retVal;
	}

}