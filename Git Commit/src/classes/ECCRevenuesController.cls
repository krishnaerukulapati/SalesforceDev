global with sharing class ECCRevenuesController{
  public string eventId {get; private set;}
  public integer page {get; private Set;}
  public integer pageTotal {get; private Set;}
  private integer pageSize = 50;
  private Integer totalItems = 0;

   public ECCRevenuesController.ECCRevenuesController() {
        init();
      }

  public ECCRevenuesController(ApexPages.StandardController controller) {
        init();
      }

    private void init() {
	    eventId = System.currentPageReference().getParameters().get('eventId');
    	system.debug('ECCRevenuesController.eventId = ' + eventId);
    }

      @RemoteAction
  	global static List<EventRevenueDetails__x> getRevenueDetails(string eventId) {
    try {
    	system.debug('eventId = ' + eventId);

      if (eventId == '')
      {
        return new List<EventRevenueDetails__x>();
      }
      return OdataExtension.GetEventRevenueDetails(eventId);
      
    }
    catch(Exception e) {
      return new List<EventRevenueDetails__x>();
    }
  }
}