public class EventMastering {
    public AttributeEnum AttributeEnum;
    public Attribute Attribute;
    public Event Event;
    public EventAttribute EventAttribute;
    public EventAttributeViews EventAttributeViews;
    public EventType EventType;
    public Role Role;
    public roletype roletype;
    public EventTypeAttribute EventTypeAttribute;
    public EventRole EventRole;
    public RoleTypeAttribute RoleTypeAttribute;
    public EventConstituent EventConstituent;
    //public EventConstituentRole EventConstituentRole;
    public EventConstituentRoleAttribute EventConstituentRoleAttributes;
    public RoleAttribute RoleAttribute;
    public static EventMastering  parse(String json){
        return (EventMastering ) System.JSON.deserialize(json, EventMastering.class);
    }
    public class Attribute {
        public String AttributeDataTypeID {get;set;}
        public String AttributeDescription {get;set;}
        public String AttributeID {get;set;}
        public String AttributeName {get;set;}
        //public String AttributeType {get;set;}   
        public String StatusID {get;set;}         
    }
    
    public class AttributeEnum {
        public String AttributeEnumID {get;set;}
        public String AttributeID {get;set;}
        public Datetime EndDate {get;set;}
        public Datetime StartDate {get;set;}
        public String Value {get;set;}            
    }
    
    public class Event {
        public String Address {get;set;}
        public String City {get;set;}
        public Datetime EndDate {get;set;}
        public String EventCode {get; set;}
        public String EventDescription {get; set;}
        public String EventID {get;set;}
        public String CostCenterID {get;set;}
        public String CountryID {get;set;}
        public String EventName {get;set;}
        public String EventTimeZoneID {get;set;}
        public String EventTypeID {get;set;}
        public String EventProgramID {get;set;}
        public String FiscalYear {get;set;}
        public String RegionID {get;set;}
        public String LeadStaffEmail {get;set;}
        public String StaffUserId {get;set;}
        public Datetime StartDate {get;set;}
        public String StateID {get;set;}
        public String StatusID {get;set;}
        public String ZipCode {get;set;}
    }
    
    public class EventAttribute {
        public String EventAttributeID {get;set;}
        public String EventAttributeValue {get;set;}
        public String EventID {get;set;}
        public String EventTypeAttributeID {get;set;}
    }
    
     public class EventAttributeViews {
        public String ActiveAttribute {get;set;}
        public String Address {get;set;}
        public String AttributeDataTypeID {get;set;}
        public String AttributeDescription {get;set;}
        public String AttributeID {get;set;}
        public String AttributeName {get;set;}
        public String AttributeType {get;set;}
        public String City {get;set;}
        public String DefaultAttributeValue {get;set;}
        public String EndDate {get;set;}
        public String EventCode {get;set;}
        public String EventAttributeID{get;set;}
        public String EventDescription {get;set;}
        public String EventID {get;set;}
        public String EventName {get;set;}
        public String EventProgramID {get;set;}
        public String EventTimeZoneID {get;set;}
        public String EventTypeAttributeID {get;set;}
        public String EventTypeID {get;set;}
        public String FiscalYear {get;set;}
        public String LeadStaffEmail {get;set;}
        public String RegionID {get;set;}
        public String RequireAttribute {get;set;}
        public String ShowAttribute {get;set;}
        public String StaffAddress {get;set;}
        public String StaffPhone {get;set;}
        public String StaffUserID {get;set;}
        public String StartDate {get;set;}
        public String StateID {get;set;}
        public String StatusID {get;set;}
        public String EventAttributeValue {get;set;}
        public String ZipCode {get;set;}
    }
    
    public class EventType {
        public String EventTypeID {get;set;}
        public String EventTypeName {get;set;}
        public String EventProgramID{get;set;}
        public String StatusID{get;set;}
    }
    
    public class Role {
        public String RoleID {get;set;}
        public String RoleName {get;set;}
        public String RoleDescription {get;set;}
        public String RoleTypeID{get;set;}
        public String StatusID{get;set;}
    }
    
    public class EventTypeAttribute {
        public Boolean ActiveAttribute {get {
            if(ActiveAttribute == null) {
                return false;
            } else {
                return ActiveAttribute;
            }
        } set;}
        public String AttributeID {get;set;}
        public String EventTypeAttributeID {get;set;}
        public String EventTypeID {get;set;}
        public String StatusID {get;set;}
        public String DefaultAttributeValue {get;set;}
        public Boolean RequireAttribute {get {
            if(RequireAttribute == null) {
                return false;
            } else {
                return RequireAttribute;
            }
        } set;}
        public Boolean ShowAttribute {get {
            if(ShowAttribute == null) {
                return false;
            } else {
                return ShowAttribute;
            }
        } set;}
    }
      /*start : Added by Goutham*/
    public class RoleType {
        public Boolean IsKeyRole {get{
            if(IsKeyRole == null){
                return false;
            }else {
               return IsKeyRole;
            }
        } set;}
        public Boolean IsTemplate {get{
            if(IsTemplate == null){
                return false;
            }else {
               return IsTemplate;
            }
        } set;}
        public String RoleTypeDescription {get;set;}
        public String RoleTypeID {get;set;}
        public String RoleTypeName {get;set;}
        public String StatusID {get;set;}
    }
    
    public class EventRole {
        public String EventRoleID {get;set;}
        public String EventID {get;set;}
        public String RoleTypeID {get;set;}
        public String RoleID {get;set;}
        public String StatusID {get;set;}
    }
    
    public class RoleTypeAttribute {
        public Boolean ActiveAttribute {get {
            if(ActiveAttribute == null) {
                return false;
            } else {
                return ActiveAttribute;
            }
        } set;}
        public String AttributeID {get;set;}
        public String RoleTypeAttributeID {get;set;}
        public String RoleTypeID {get;set;}
        public Boolean RequireAttribute {get {
            if(RequireAttribute == null) {
                return false;
            } else {
                return RequireAttribute;
            }
        } set;}
        public Boolean ShowAttribute {get {
            if(ShowAttribute == null) {
                return false;
            } else {
                return ShowAttribute;
            }
        } set;}
    }
    
    public class RoleAttribute {
        public Boolean ActiveAttribute {get {
            if(ActiveAttribute == null) {
                return false;
            } else {
                return ActiveAttribute;
            }
        } set;}
        public String AttributeID {get;set;}
        public String RoleAttributeID {get;set;}
        public String RoleID {get;set;}
        //public String StatusID {get;set;}
        public String DefaultAttributeValue {get;set;}
        public Boolean RequireAttribute {get {
            if(RequireAttribute == null) {
                return false;
            } else {
                return RequireAttribute;
            }
        } set;}
        public Boolean ShowAttribute {get {
            if(ShowAttribute == null) {
                return false;
            } else {
                return ShowAttribute;
            }
        } set;}
    }
    
    public class EventConstituentRoleAttribute {
        public String AttributeValue {get;set;}
        public String EventConstituentRoleAttributeID {get;set;}
        public String EventConstituentRoleID {get;set;}
        public String RoleTypeAttributeID {get;set;}
    }
    
    public class EventConstituentRole {
        public String EventConstituentID {get;set;}
        public String EventConstituentRoleID {get;set;}
        public String EventRoleID {get;set;}
        public String StatusID {get;set;}
    }
    
    public class EventConstituent {
        public String ConstituentID {get;set;}
        public String EventConstituentID {get;set;}
        public String EventID {get;set;}
        public String StatusID {get;set;}
    }
    
     /*END : Added by Goutham*/
    
    private class EventMasteringException extends Exception {}
}