global class Guid {
    global static Boolean isEmpty(String guid) {
        return guid == null || guid == '00000000-0000-0000-0000-000000000000' || guid == '';
    }
    
    global static String createGuid() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertToHex(b);
        String guid = h.SubString(0,8) 
            + '-' + h.SubString(8,12) 
            + '-' + h.SubString(12,16) 
            + '-' + h.SubString(16,20) 
            + '-' + h.substring(20);
        
        return guid; 
    }
}