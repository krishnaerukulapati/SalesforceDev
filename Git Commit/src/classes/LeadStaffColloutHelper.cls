global class LeadStaffColloutHelper{
    private static final String BASE_URL = OdataExtensionSettings__c.getInstance().Lead_Staff_Base_URL__c;
    private static final String LEADSTAFFSEARCH_ENDPOINT = OdataExtensionSettings__c.getInstance().Lead_Staff_Search_Endpoint__c;
    private static final String LEADSTAFFPROFILE_ENDPOINT = OdataExtensionSettings__c.getInstance().Lead_Staff_Profile_Endpoint__c;
    public LeadStaffColloutHelper(ApexPages.StandardSetController controller) {

    }


    public LeadStaffColloutHelper(ApexPages.StandardController controller) {

    }

    @RemoteAction
    global static LeadSearchResult searchLeadStaff(String leadStaffName) {
       system.debug('###3hello');
       // try{
            return LeadSearchResult.parse(buildHttpRequest('POST',LeadStaffColloutHelper.BASE_URL +LeadStaffColloutHelper.LEADSTAFFSEARCH_ENDPOINT ,'token='+ TokenService.createToken()+'&name='+leadStaffName));
       /** }Catch(Exception e){
            return null;
        }*/
    }
    
    @RemoteAction
    global static LeadStaffProfileResult fetchLeadStaffProfile(String accountName) {
        return LeadStaffProfileResult.parse(buildHttpRequest('POST',LeadStaffColloutHelper.BASE_URL +LeadStaffColloutHelper.LEADSTAFFPROFILE_ENDPOINT ,'token='+ TokenService.createToken()+'&accountName='+accountName));
        
    }
     global  static string buildHttpRequest(String method, String endpoint, String requestBody) {
        system.debug('$$$'+endpoint);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);      
        request.setBody(requestBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        
         if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
            // Everthing fine
            system.debug('$$$'+response.getBody());
            return response.getBody();    
        } else {
            throw new LeadStaffException (response.getBody());
        }
        
    }
    
    global   class LeadStaffException extends Exception{
    }
   
 
    
}