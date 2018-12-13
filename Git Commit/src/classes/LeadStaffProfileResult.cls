global class LeadStaffProfileResult{
    global cls_profile profile;
    global boolean success;
    global class cls_profile {
        global String accountName;  
        global String name; 
        global String firstName;   
        global String lastName; 
        global String title;    
        global String phoneNumber;  
        global String email;   
    }
    global static LeadStaffProfileResult parse(String json){
        return (LeadStaffProfileResult) System.JSON.deserialize(json, LeadStaffProfileResult.class);
    }
}