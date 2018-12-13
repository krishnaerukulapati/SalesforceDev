/*
*@author Debadyuti Sil
*@purpose Controller for IntranetPeople search vf component
*/
public class EdgeForceIntranetPeopleSearchController {
  
    public  String searchString{get;set;}
    public  List<User> listofUsers{get;set;}
    public  String searchInputinController{get;set;}
    public  set<String> setofUserId{get;set;}
    public  Integer resultLimit;
    public  String   pageParam{get;set;}
    public  String   pageName{get;set;}
    public  User     userProfileDetails{get;set;}
    public  String currentTime{get;set;}

    public EdgeForceIntranetPeopleSearchController() {
       listofUsers = new  List<User>();
       resultLimit = 7;
       
         if(apexPages.currentPage().getParameters().get('userId') <> null && apexPages.currentPage().getParameters().get('userId')<> ''){
            userProfileDetails = new User();
            userProfileDetails.id = apexPages.currentPage().getParameters().get('userId');
            processProfileDetails(userProfileDetails.id);
                Datetime cDT = System.now();    
                //returns the properly formatted datetime value
                Map<String, String> mappedValues = new Map<String, String>(); //map for holding locale to datetime format
                mappedValues = MapValues(); //populate the map with all the locale specific datetime formats
                //String user_locale = UserInfo.getLocale(); //grab the locale of the logged in user
                String user_locale = userProfileDetails.LocaleSidKey;
                String datetime_format = 'hh:mm:ss aa zzz'; //variable for the datetime format defaulted to the US format
                if (mappedValues.containsKey(user_locale)) { //if the map contains the correct datetime format
                    datetime_format = mappedValues.get(user_locale); //grab the datetime format for the locale
                }
                currentTime = cDT.format(datetime_format, userProfileDetails.TimeZoneSidKey); //create a string with the proper format
            
         }
       
   
    }
    
    public void clear(){
         listofUsers = new  List<User>();
         setofUserId = new  Set<String>();
    }
    
    public void processPeopleSearch(){
         listofUsers = new  List<User>();
         setofUserId = new  Set<String>();
        if(apexpages.currentPage().getParameters().get('searchInput') <> null && apexpages.currentPage().getParameters().get('searchInput') <> ''){
            searchString = apexpages.currentPage().getParameters().get('searchInput');
             system.debug('searchString'+searchString);
              if(searchString.length()>=2){
                String userSearchInput = '%'+searchString+'%';
                String query = 'SELECT Id, Name,Email,Title,FullPhotoUrl,SmallPhotoUrl,Department,CompanyName,Country,IsActive,Phone, MobilePhone, Street, City, State, PostalCode, Alias,LocaleSidKey, TimeZoneSidKey,  EmployeeNumber, Manager.Name   FROM User Where (Email LIKE : userSearchInput OR NAME LIKE : userSearchInput OR Title LIKE : userSearchInput ) And Id NOT IN :setofUserId AND IsActive=true limit '+resultLimit ;
                for(User chatterUser :database.query(query)){
                    
                                            if(chatterUser <> null){
                                                listofUsers.add(chatterUser);
                                                setofUserId.add(chatterUser.id);
                                           }
                                  
                }        
              }else{
                clear();
              }
         }
         system.debug('listofUsers'+listofUsers);
    }   
    
    public void processPeopleSearchMore(){
        
            if(searchString <> null && searchString <> ''){
             system.debug('searchString'+searchString);
              if(searchString.length()>=2){
                String userSearchInput = '%'+searchString+'%';
                String query = 'SELECT Id, Name,Email,Title,FullPhotoUrl,SmallPhotoUrl,Department,CompanyName,Country,IsActive,Phone, MobilePhone, Street, City, State, PostalCode, Alias,LocaleSidKey, TimeZoneSidKey,  EmployeeNumber, Manager.Name   FROM User Where (Email LIKE : userSearchInput OR NAME LIKE : userSearchInput OR Title LIKE : userSearchInput ) And Id NOT IN :setofUserId AND IsActive=true limit '+resultLimit ;
                for(User chatterUser :database.query(query)){
                    
                                            if(chatterUser <> null){
                                                listofUsers.add(chatterUser);
                                                setofUserId.add(chatterUser.id);
                                           }
                                  
                 }        
               }else{
                 clear();
               }
             }
    }
    
    public pagereference RedirectPage(){
         Pagereference newPage;
         if(apexPages.currentPage().getParameters().get('pageName')<> null && apexPages.currentPage().getParameters().get('pageName') <> ''){
              if(apexPages.currentPage().getParameters().get('pageName') == 'EF_ViewUserProfile'){
                    newPage = Page.EF_ViewUserProfile;  
                   if(apexPages.currentPage().getParameters().get('pageParam') <> null && apexPages.currentPage().getParameters().get('pageParam') <> ''){
                     for(String paramNameandValue : apexPages.currentPage().getParameters().get('pageParam').split('&')){
                        if(paramNameandValue <> null && paramNameandValue <> ''){
                            String[] paramNameandValueArray = paramNameandValue.split('=');                          
                            newPage.getParameters().put(paramNameandValueArray[0],paramNameandValueArray[1]);    
                        }                
                     } 
                    
                   }
                  newPage.setRedirect(true);
              }else{
                return null;
              }        
                  
         }
         return newPage;
    }


   public void processProfileDetails(String chatterUserId){
             for(User chatterUser :  [SELECT Id, Name,Email,Title,FullPhotoUrl,SmallPhotoUrl,Department,CompanyName,Country,IsActive,Phone, MobilePhone, Street, City, State, PostalCode, Alias,LocaleSidKey, TimeZoneSidKey,  EmployeeNumber, Manager.Name 
                                      FROM User 
                                      Where Id =:chatterUserId]){
                  if(chatterUser <> null){
                    userProfileDetails = chatterUser;
                  }  
                                  
              }    
       }
  
   
    
   
   
   
   
    //populate a map with locale values and corresponding datetime formats
    private Map<String, String> MapValues() {
        Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
        locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        locale_map.put('bg_BG', 'yyyy-M-d H:mm');
        locale_map.put('ca', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('cs', 'd.M.yyyy H:mm');
        locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
        locale_map.put('da', 'dd-MM-yyyy HH:mm');
        locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
        locale_map.put('de', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('el_GR', 'd/M/yyyy h:mm a');
        locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
        locale_map.put('en_B', 'M/d/yyyy h:mm a');
        locale_map.put('en_BM', 'M/d/yyyy h:mm a');
        locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
        locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_GH', 'M/d/yyyy h:mm a');
        locale_map.put('en_ID', 'M/d/yyyy h:mm a');
        locale_map.put('en_IE', 'HH:mm zzz');
        locale_map.put('en_IE_EURO', 'HH:mm zzz');
        locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
        locale_map.put('en_SG', 'M/d/yyyy h:mm a');
        locale_map.put('en_US', 'hh:mm:ss aa zzz');
        locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        locale_map.put('es', 'd/MM/yyyy H:mm');
        locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
        locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_ES', 'd/MM/yyyy H:mm');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('et_EE', 'd.MM.yyyy H:mm');
        locale_map.put('fi', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        locale_map.put('fr', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
        locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
        locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
        locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
        locale_map.put('hu', 'yyyy.MM.dd. H:mm');
        locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
        locale_map.put('is_IS', 'd.M.yyyy HH:mm');
        locale_map.put('it', 'dd/MM/yyyy H.mm');
        locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
        locale_map.put('iw', 'HH:mm dd/MM/yyyy');
        locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd H:mm');
        locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
        locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
        locale_map.put('km_KH', 'M/d/yyyy h:mm a');
        locale_map.put('ko', 'yyyy. M. d a h:mm');
        locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
        locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
        locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
        locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
        locale_map.put('nl', 'd-M-yyyy H:mm');
        locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
        locale_map.put('nl_NL', 'd-M-yyyy H:mm');
        locale_map.put('nl_SR', 'd-M-yyyy H:mm');
        locale_map.put('no', 'dd.MM.yyyy HH:mm');
        locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
        locale_map.put('pl', 'yyyy-MM-dd HH:mm');
        locale_map.put('pt', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
        locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
        locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
        locale_map.put('ru', 'dd.MM.yyyy H:mm');
        locale_map.put('sk_SK', 'd.M.yyyy H:mm');
        locale_map.put('sl_SI', 'd.M.y H:mm');
        locale_map.put('sv', 'yyyy-MM-dd HH:mm');
        locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
        locale_map.put('th', 'M/d/yyyy h:mm a');
        locale_map.put('th_TH', 'd/M/yyyy, H:mm ?.');
        locale_map.put('tr', 'dd.MM.yyyy HH:mm');
        locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
        locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d ah:mm');
        locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
        locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
        locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
        return locale_map; //return the map
    }
}