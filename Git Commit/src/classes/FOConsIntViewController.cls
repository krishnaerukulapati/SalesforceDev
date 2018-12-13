public with sharing class FOConsIntViewController {
	public domainSoapStjudeOrg.Interaction i {get; set;}
	public boolean warning {get; set;}
	public String relId {get; private set;}
	public String consId {get; private set;}

	public FOConsIntViewController(ApexPages.StandardController controller) {
		init();
	}

	public FOConsIntViewController() {
		init();
	}

	private void init() {
		i = new domainSoapStjudeOrg.Interaction();
		i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
		relId = System.currentPageReference().getParameters().get('id');
		consId = System.currentPageReference().getParameters().get('consId');
		i.ContactDate = System.currentPageReference().getParameters().get('contDate');
		i.ContactCategory = System.currentPageReference().getParameters().get('contCat');
		i.ContactType = System.currentPageReference().getParameters().get('contType');
		i.ResponseType = System.currentPageReference().getParameters().get('respType');
		i.ResponseCategory = System.currentPageReference().getParameters().get('respCat');
		i.TransactionSource.Technique = System.currentPageReference().getParameters().get('tech');
		i.LongComments = System.currentPageReference().getParameters().get('comments');
		warning = System.currentPageReference().getParameters().get('warn') == 'Y';
		i.WarningExpirationDate = System.currentPageReference().getParameters().get('warnExp');
	}
}