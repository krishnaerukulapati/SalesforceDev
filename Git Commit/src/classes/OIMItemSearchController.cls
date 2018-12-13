public with sharing class OIMItemSearchController {
	public String orderId { get; set; }
    public String eventTypeId { get; set; }
    public String SKU { get; set; }
    public String description { get; set; }
    public String categoryId { get; set; }
    public Boolean active { get; set; }

	public OIMItemSearchController() {
		init();
	}

	private void init() {
		orderId = System.currentPageReference().getParameters().get('orderId');
	}

	private PageReference search() {
		

		return null;
	}
}