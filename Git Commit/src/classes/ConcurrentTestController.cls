public with sharing class ConcurrentTestController {

	public Time sTime {get; set;}

	public ConcurrentTestController(ApexPages.StandardController controller) {
		init();	
	}

	public void init(){
		sTime = getServerTime();
	}

	public Time getServerTime(){
		Time currTime = DateTime.now().time(); 
		return currTime;
	}
}