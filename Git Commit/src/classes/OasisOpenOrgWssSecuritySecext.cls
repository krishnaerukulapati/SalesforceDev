public class OasisOpenOrgWssSecuritySecext 
{

    // UserToken Class
    public class UsernameToken 
    {
        // Constructor for UsernameToken used to pass in username and password parameters
        public UsernameToken(String username, String password)
        {
            this.Username = username;
            this.Password = password;
        }

        public String Username;
        public String Password;
        private String[] Username_type_info = new String[]{'Username','http://www.w3.org/2001/XMLSchema','string','0','1','false'};
        private String[] Password_type_info = new String[]{'Password','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText','string','0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'Username','Password'};
    }

    // SecurityHeaderType Class
    public class SecurityHeaderType  
    {       
        // Constructor for SecurityHeaderType used to pass in username and password parameters and instantiate the UsernameToken object     
        public SecurityHeaderType(String username, String password)
        {
            this.UsernameToken = new OasisOpenOrgWssSecuritySecext.UsernameToken(username, password);
        }

        public String wsuNamespace = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd';              
        public OasisOpenOrgWssSecuritySecext.UsernameToken UsernameToken;
        private String[] UsernameToken_type_info = new String[]{'UsernameToken','http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','UsernameToken','1','1','false'};
        private String[] wsuNamespace_att_info = new String[]{'xmlns:wsu'};               
        private String[] apex_schema_type_info = new String[]{'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd','true','false'};
        private String[] field_order_type_info = new String[]{'UsernameToken'};
    }
}