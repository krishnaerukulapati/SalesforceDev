/*
* Modified By : Sumit tanwar 12th Sept, 2014 Ref - T-318410
*/
public class EdgeForceIntranetMenuMobileController {

    private static final String FAV_NAME = 'Favorites';
    
    //map to hold result. The result will have cms page name and their respective parent page name.
    public Map <String, String> parentTabMap {get; set;}
    
    //map that will hold cms page name and list of all child pages 
    public Map<String, List<IntranetWrapper>> aMap {get; set;}
    
    //String that will used to create HTML for intranet Menu
    public String ulString {get; set;}
    
    //String used to create HTML for subMenu
    public Integer ulLabel {get; set;}
    
    //List that hold IntranetWrapper class list
    public List<IntranetWrapper> finalMenuList {get; set;}
    
    //String used to select tab on Inranet pages.
    private String tabName {get;set;}
    public String AndroidMarketplaceUrl {get; set;}
    public String IOSMarketplaceUrl {get; set;} 
    Public String userType;
    
    public EdgeForceIntranetMenuMobileController() {
        tabName = '';
        ulString = '';
        ulLabel = 1;
        finalMenuList =  new List<IntranetWrapper>();
        aMap = new Map<String, List<IntranetWrapper>>();
        userType = Userinfo.getUserType();
        if(userType.toLowerCase() == 'standard')
            userType = 'Intranet';
        else if(userType.toLowerCase() == 'guest')
            userType = 'External';
        else
            userType = 'Portal';
            
        parentTabMap = new map<String, String>();
        for(Intranet_content__c marketPlaceUrl : [Select Name, value__c From Intranet_content__c where recordType.Name = 'Config - Portal']) {
            if(marketPlaceUrl.Name == 'Android_Marketplace_URL') {
                        AndroidMarketplaceUrl = marketPlaceUrl.Value__c;                                
            }
            if(marketPlaceUrl.Name == 'IOS_Marketplace_URL') {
                        IOSMarketplaceUrl = marketPlaceUrl.Value__c;                                
            }
        }

        getMenuList();
    }
    
    
      //Method will craete menu list that will be used on Intranet pages to show menu bar.
    public void getMenuList() {
    //List to hold all top level CMS pages.
    List<IntranetWrapper> intraListWithNull = new List<IntranetWrapper>();
        for(EdgeForceIntranetContentController.ContentVersionWrapper menu : getAllLinksDetails()) {
        //populate parentTabMap will have cms page name and their respective parent page name
        Intranet_Content__c menuItem = menu.content;                     
        parentTabMap.put(menuItem.Name, menuItem.Parent__r.Name);
        IntranetWrapper intraWrapper = new IntranetWrapper(menuItem,menu.contentVersionforDisplay.Name);
        if(menuItem.Parent__c == null) {
            intraListWithNull.add(intraWrapper);
            aMap.put(menuItem.id, new List<IntranetWrapper> ());
        } else {
            if (!aMap.containsKey(menuItem.Parent__c)) {
                aMap.put(menuItem.Parent__c, new List<IntranetWrapper>());
            }
            aMap.get(menuItem.Parent__c).add(intraWrapper);     
        }
    } 
    aMap.put(null, intraListWithNull);   
    finalMenuList = addNodeToList( aMap, finalMenuList, null); 
    //if(!Test.isRunningTest())
        createMenu( finalMenuList );
    ulString = '<ul class="nav navbar-nav">' + ulString + '</ul>';
    }
    
       public List<EdgeForceIntranetContentController.ContentVersionWrapper> getAllLinksDetails(){
    
   List<EdgeForceIntranetContentController.ContentVersionWrapper> tempListofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
     List<EdgeForceIntranetContentController.ContentVersionWrapper> listofLocalContentVersionWrapper = new  List<EdgeForceIntranetContentController.ContentVersionWrapper>();
   String queryString =  'SELECT Id, Parent__c,URL__c, Parent__r.Name,Skip_Menu_Link__c, Name,Template__c, Sequence__c,Target__c,(Select Tags__r.Tag__c From Intranet_Content_Tags__r)  FROM Intranet_Content__c  WHERE Status__c = \'Published\' AND RecordType.Name = \'Intranet CMS Pages\' AND Show_In_Header_Menu__c = true AND Site__c=\''+userType+'\' order by Parent__c,Sequence__c ';                               
   EdgeForceIntranetContentController contentController = new EdgeForceIntranetContentController();
     tempListofLocalContentVersionWrapper = contentController.processContentAndVersionMenu(queryString);
     
     Integer recordCount = 0;
     for(Intranet_Content__c content : [SELECT Id
                                       FROM Intranet_Content__c 
                                       WHERE Status__c = 'Published'
                                       AND RecordType.Name = 'Intranet CMS Pages'
                                       AND Show_In_Header_Menu__c = true 
                                       AND Site__c=:userType
                                       order by Parent__c,Sequence__c ]){
        for(EdgeForceIntranetContentController.ContentVersionWrapper wrapper : tempListofLocalContentVersionWrapper)  {
           if(string.valueOf(wrapper.content.Id).substring(0,15) == string.valueOf(content.Id).substring(0,15)){
               listofLocalContentVersionWrapper.add(wrapper);
               recordCount= recordCount + 1;
         }
        }  
     }      
     System.debug('-------  >  '+listofLocalContentVersionWrapper.size());
     return listofLocalContentVersionWrapper;
    }
    
    // Method used to create HTML string for Menu bar that will be used on all Intranet Pages  
  public void createMenu( List<IntranetWrapper> menuList ) {
    String url = '';
    String liClass = '';
    String settingsHTML = '';
    String setURL = '';
    for(IntranetWrapper temp : menuList) {
        url = 'javascript:void(0)';  
        if(temp.skipMenuLink != true) {
            if(temp.Url != null) {
                url = temp.Url;
            }else {
                if(temp.template == 'Home') {
                    url = '/apex/EF_Home';
                }else if(temp.template == 'Interior Home') {
                    url = '/apex/EF_Home?tabName='+EncodingUtil.urlEncode(temp.name, 'UTF-8');
                }else if(temp.template == 'Team') {
                    getParentpageName(temp.name);
                    url = '/apex/EF_Team?&name='+EncodingUtil.urlEncode(temp.name, 'UTF-8')+'&tabName='+EncodingUtil.urlEncode(tabName, 'UTF-8');
                }else if(temp.template == 'Content') {
                    getParentpageName(temp.name);
                    url = '/apex/EF_Content?Id=' + temp.id + '&category=Content&tabName='+EncodingUtil.urlEncode(tabName, 'UTF-8');
                }
                else if(temp.Template == 'Chatter')
                    url = '/apex/EF_ChatterPage';
                else if(temp.Template == 'Employee Directory')
                    url = '/apex/EF_EmployeeDirectory';
                else if(temp.Template == 'Search')
                    url = '/apex/EF_IntranetSearch';
                else if(temp.Template == 'News')
                    url = '/apex/EF_NewsPage';
                else if(temp.Template == 'Video Gallery')
                    url = '/apex/EF_VideoGallery';
                else if(temp.Template == 'Document Directory')
                    url = '/apex/EF_DocumentDirectory';
            }
        }
        settingsHTML = '';
        setURL = 'javascript:void(0)';
        if(String.isNotBlank(temp.settingsUrl)){
            setURL = temp.settingsUrl;
        }
        if(temp.hasSettings <> null && temp.hasSettings){
            settingsHTML = ' <a class="settingsAnchor" target="_self" href=\"'+setURL+'\"><span class="glyphicon glyphicon-cog"/>&nbsp;</a>';
        }
        
        //Crete HTML String with respective linked URL and CSS classes 
        if(temp.subList == null){
            liClass = '';
            if(temp.name.equalsIgnoreCase('Home')){
                liClass = '' + temp.name.toLowerCase();
            } 
            ulString = ulString + '<li id=\"'+ temp.name+'\" class=\"'+ liClass +'\"><a href=\"'+ url +'\" target=\"'+ temp.target +'\"> <span class=\"glyphicon glyphicon-'+temp.iconClass+'\"></span> ' +temp.name+ ' </a>'+settingsHTML;
           
        }else if( temp.subList.isEmpty() ){
            liClass = '';
            if(!String.isBlank(temp.name) && temp.name.equalsIgnoreCase('Home')){
                liClass = '' + temp.name.toLowerCase();
            }
            ulString = ulString + '<li onclick="openDynamicPage(this)" class=\"'+ liClass +'\"><a  id="'+url+'"  href=\"'+ url +'\" target=\"'+ temp.target +'\"> <span class=\"glyphicon glyphicon-'+temp.iconClass+'\"></span> ' + temp.name+ '</a>'+settingsHTML;
        }else{
            liClass = ulLabel <= 1 ? ('dropdown ' + temp.name.toLowerCase()) : ('dropdown-submenu');
            ulString = ulString + '<li id="_lidropdown" class=\"'+ liClass +'\"><a href=\"'+ 'javascript:void(0)' +'\" target=\"'+ '' +'\" class=\"dropdown-toggle\" data-toggle=\"dropdown\" > <span class=\"glyphicon glyphicon-'+temp.iconClass+'\"></span> ' + temp.name+ '<b class=\"caret\"></b></a>'+settingsHTML; 
            ulString = ulString + '<ul class=\"dropdown-menu\">';
            ulLabel++;
            createMenu(temp.subList);
            ulString = ulString + '</ul>';
            ulLabel--;
        }
        ulString = ulString + '</li>';
    }
  }
  
    
    //Wrapper class used to create CSM pages list with child parent relationship 
  public class IntranetWrapper {
    public String id {get; set;}
    public String parent {get; set;}
    public Integer flag {get; set;}
    public List <IntranetWrapper> subList {get;set;}
    public String name {get; set;}
    public String Url {get;set;}
    public String template {get;set;}
    public Boolean skipMenuLink {get;set;}
    public String sequence {get;set;}
    public String target {get;set;}
    public String iconClass {get; set;}
    public String settingsUrl {get;set;}
    public Boolean hasSettings {get;set;}
        
    public IntranetWrapper(Intranet_Content__c intra,String translatedName) {
        this.id = intra.id;
        this.parent = intra.Parent__c;
        this.flag = 0;
        this.subList = null;
        this.name = translatedName; //intra.name;
        this.Url = intra.URL__c;
        //this.Url=intra.URLwithID__c;
        this.template = intra.Template__c;
        this.skipMenuLink = intra.Skip_Menu_Link__c;
        this.sequence = intra.Sequence__c;
        this.target = intra.Target__c;
        //this.iconClass = intra.Icon__c;
        //this.settingsUrl = intra.Settings_URL__c;
        //this.hasSettings = intra.Has_Settings__c;
    }
        
    public IntranetWrapper(String id, String parent, String iconClass, Boolean hasSets, String setUrl, Integer flag, List<IntranetWrapper> subList, String name,String Url,String template,Boolean skipMenuList,String target) {
        this.id = id; 
        this.parent = parent; 
        this.flag = flag; 
        this.subList = subList; 
        this.name = name;
        this.Url = Url;
        this.template = template;
        this.skipMenuLink = skipMenuList;
        this.target = target;
        this.iconClass = iconClass;
        this.settingsUrl = setUrl;
        this.hasSettings = hasSets;
    }
  }
  
  //Method is used create list of cms Pages with thier related child list.
  //Recursive process is used to create list of CMS page with list of related child 
  public static List<IntranetWrapper> addNodeToList( Map<String, List<IntranetWrapper>> menuMap, List<IntranetWrapper> menuList, String id ){
    for(IntranetWrapper intranetWrapper : menuMap.get(id)){     
      if(menuMap.get(intranetWrapper.id) == null){
        menuList.add(new IntranetWrapper(intranetWrapper.id, id, intranetWrapper.iconClass, intranetWrapper.hasSettings, intranetWrapper.settingsURL, 0, null, intranetWrapper.name,intranetWrapper.Url,intranetWrapper.template, intranetWrapper.skipMenuLink, intranetWrapper.target));
      }
      else{
        List<IntranetWrapper> subMenuList = new List<IntranetWrapper>();
        menuList.add(new IntranetWrapper(intranetWrapper.id, id, intranetWrapper.iconClass, intranetWrapper.hasSettings, intranetWrapper.settingsURL, 1, addNodeToList(menuMap, subMenuList, intranetWrapper.id), intranetWrapper.name, intranetWrapper.Url, intranetWrapper.template, intranetWrapper.skipMenuLink, intranetWrapper.target));
      }
    }    
    return menuList;
  }
  
  //Method used resursive process to find top level parent of any CMS Page
  public void getParentpageName(String pageName) {
    tabName = pageName;
    if(parentTabMap.get(pageName) != null) {
        getParentpageName(parentTabMap.get(pageName));
    }
  }
  
}