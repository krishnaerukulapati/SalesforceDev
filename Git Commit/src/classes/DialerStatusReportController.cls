public with sharing class DialerStatusReportController {
	public List<ReportUtil.DialerStatusModel> ReportData {get; set;}
    private String CacheKey = 'DialerStatusReportCacheKey';
    public String CurrentTime {get; private set;}

	public DialerStatusReportController()
	{
		CurrentTime = DateTime.now().format('MM-dd-yyyy HH:mm:ss');
		ReportData = new List<ReportUtil.DialerStatusModel>();
		//ReportData = ReportUtil.GetDialerStatusReportData();
        if (Cache.Session.contains(CacheKey) && !Test.isRunningTest()){
             ReportData = (List<ReportUtil.DialerStatusModel>)Cache.Session.get(CacheKey);
             system.debug('cache used');
        }
        else{
            system.debug('cache not used');
            ReportData = ReportUtil.GetDialerStatusReportData();
            Cache.Session.put(CacheKey, ReportData);
        }
	}
}