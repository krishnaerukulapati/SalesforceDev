public with sharing class AsyncC360Util {
    private static integer timeOutMS = 30000;
    private static integer longTimeout = 60000;

    public static objectSoapStjudeOrg.Signature getSignature() {
        return getSignature(null);
    }

    public static objectSoapStjudeOrg.Signature getSignature(String contactMethod) {
        objectSoapStjudeOrg.Signature sig = new objectSoapStjudeOrg.Signature();
        sig.channel = 'ECC';
        sig.user_x = UserInfo.getUserName();
        if (String.isNotBlank(contactMethod)) {
            system.debug('contactMethod: ' + contactMethod);
            sig.contactMethod = contactMethod;
        }

        return sig;
    }

    public static AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture getConstituent(
    		System.Continuation cont,
    		String UUID, String consId, String[] Facet, String scope) {
        system.debug('getConstituent(string UUID, string consId, string[] Facet, String scope)');
        return getConstituent(cont, UUID, consId, null, null, Facet, 'ALL');
    }

    public static AsyncSoapStjudeOrg.GetConstituentResponse_elementFuture getConstituent(
			System.Continuation cont,
    		string UUID, string consId, 
	        domainSoapStjudeOrg.SystemXRef SystemXRef, String MasterSystem, string[] Facet, String scope) {

		AsyncSoapStjudeOrg.AsyncConstituentPort cp = new AsyncSoapStjudeOrg.AsyncConstituentPort();
        system.debug('string UUID = ' + UUID);
        system.debug('string consId = ' + consId);
        system.debug('domainSoapStjudeOrg.SystemXRef SystemXRef = ' + SystemXRef);
        system.debug('string Facet = ' + Facet);
        system.debug('string scope = ' + scope);
        system.debug('string MasterSystem = ' + MasterSystem);
        system.debug('getConstituent(string UUID, string consId, domainSoapStjudeOrg.SystemXRef SystemXRef, ' +
        	'string[] Facet, String scope');
        
        system.debug('UUID: ' + UUID + ', consId: ' + consId + ', scope: ' + scope);
        
        cp.timeout_x = timeOutMS;
        
        return cp.beginGetConstituent(cont, UUID, consId, SystemXRef, null, MasterSystem, 
            scope, Facet, null, null, getSignature(), null);
    }

    public static AsyncSoapStjudeOrg.GetConstituentXRefsResponse_elementFuture getConstituentXRefs(
    		System.Continuation cont, String id, boolean uuid) {

        AsyncSoapStjudeOrg.AsyncConstituentPort cp = new AsyncSoapStjudeOrg.AsyncConstituentPort();
        
        cp.timeout_x = timeOutMS;
        
        //system.debug();
        return cp.beginGetConstituentXRefs(cont, uuid ? id : null, uuid ? null : id, null, getSignature());
    }

    public static AsyncSoapStjudeOrg.GetInteractionsResponse_elementFuture getInteractions(
            System.Continuation cont, String uuid, String consId,
            domainSoapStjudeOrg.SystemXRef SystemXRef, String MasterSystem, String InteractionFacet,
            objectSoapStjudeOrg.InteractionFilter[] Filter, objectSoapStjudeOrg.Paginator Paginator) {

        AsyncSoapStjudeOrg.AsyncConstituentPort cp = new AsyncSoapStjudeOrg.AsyncConstituentPort();
        
        cp.timeout_x = timeOutMS;

        return cp.beginGetInteractions(cont, uuid, consId, SystemXRef, MasterSystem
                                    , InteractionFacet, Filter, Paginator, getSignature());
        //return null;
    }

        
}