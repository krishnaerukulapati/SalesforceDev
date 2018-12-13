public class InteractionWarningsController {

	//declarations
	public Boolean modHasWarnings {get; set;}
	public String modConsId {get; set;}

	Integer TIMEOUT_INT_SECS = 60;

	@TestVisible private AsyncSoapStjudeOrg.GetInteractionsResponse_elementFuture interactionsResponse {get; set;}
	public List<domainSoapStJudeOrg.Interaction> modalInteractions {get; set;}

	public InteractionWarningsController() {
		init();
	}

	public void init(){
	}

	public Continuation reLoadWarnings(){
		System.debug('reLoadWarnings!');
		Continuation cont = null;

		cont = new Continuation(TIMEOUT_INT_SECS);
        cont.continuationMethod = 'gotInteractions';

        System.debug('modConsId = ' + modConsId);
        if (modConsId != null) {
        	interactionsResponse = AsyncC360Util.getInteractions(cont, null, 
															modConsId, null, 
															null,'WARNINGS', 
                                    						null, null);	
        }
        System.debug('interactionsResponse = ' + interactionsResponse);
		return cont;
	}

	public Object gotInteractions() {
		System.debug('gotInteractions!');
		Continuation cont = null;

		try {
			if (interactionsResponse.getValue().Interactions != null){
				modalInteractions = interactionsResponse.getValue().Interactions;	
			}
			if (modalInteractions != null){ modHasWarnings = true;}

			System.debug('modalInteractions : ' + modalInteractions);
			System.debug('modHasWarnings : ' + modHasWarnings);

			return null;
		}
		catch(CalloutException e){
			System.debug('CalloutException produced from getInteractions : ' + e);
			System.debug('Trying getInteractions again from MasterSystem:DMS');

			cont = new Continuation(TIMEOUT_INT_SECS);
			cont.continuationMethod = 'gotDMSInteractions';

			if (modConsId != null) {
			interactionsResponse = AsyncC360Util.getInteractions(cont, null, 
															modConsId, null, 
															'DMS','WARNINGS', 
                                    						null, null);
        	}
        	return cont;
		}
		catch(Exception e){
			System.debug('Caught Exception: ' + e);
			return null;
		}
	}

	public Object gotDMSInteractions(){
		System.debug('gotDMSInteractions!');
		try {
			if (interactionsResponse.getValue().Interactions != null){
				modalInteractions = interactionsResponse.getValue().Interactions;	
			}
		}
		catch(CalloutException e){
			System.debug('CalloutException produced from getInteractions w/ DMS : ' + e);
		}
		if (modalInteractions != null){ modHasWarnings = true;}
		System.debug('modalInteractions : ' + modalInteractions);
		System.debug('modHasWarnings : ' + modHasWarnings);

		return null;
	}

}