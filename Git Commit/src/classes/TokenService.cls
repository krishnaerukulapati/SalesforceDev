global class TokenService{
  private static final String LEAD_STAFF_USERNAME= OdataExtensionSettings__c.getInstance().LeadStaffUsername__c;
  private static final String LEAD_STAFF_PASSWORD= OdataExtensionSettings__c.getInstance().LeadStaffPassword__c;
  webservice static String CreateToken()
   {
         
       String username=LEAD_STAFF_USERNAME;
       String password =LEAD_STAFF_PASSWORD;  
       //String md5Coded    = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(password)));
       String md5Coded    =LEAD_STAFF_PASSWORD;  
       string currentTime = string.valueOf(DateTime.Now().getTime());
       String hash        = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf(currentTime + ':'+username+':' + md5Coded)));
    
       return string.valueof(EncodingUtil.base64Encode(Blob.valueOf(CurrentTime + ':'+username+':' + hash)));
   
    
   }
}