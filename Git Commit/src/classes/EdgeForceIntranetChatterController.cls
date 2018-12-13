public class EdgeForceIntranetChatterController{
    public Boolean isfeed{get;set;}
    public Boolean isPeople{get;set;}
    public Boolean isGroup{get;set;}
    public String groupName{get;set;}
    public String groupDesc{get;set;}
    public boolean allowCustomer{get;set;}{allowCustomer=false;}
    public String access{get;set;}{access='public';}
    public String isAutoArchieve{get;set;}{isAutoArchieve='false';}
    public User currentUser{get;set;}
    public List<User> chatterUsers{get;set;}
    public List<CollaborationGroup> userGroups{get;set;}
    public List<Id> memberIds;
    public EdgeForceIntranetChatterController(){
        currentUser=new User();
        isFeed=true;
        isPeople=false;
        isGroup=false;
        currentUser=[SELECT Id, Name,Email,Title,FullPhotoUrl,Department,SmallPhotoUrl,CompanyName,Country,IsActive FROM User where id=:UserInfo.getUserId()];
    }
    public void showPeople(){
        memberIds=new List<Id>();
        isFeed=false;
        isPeople=true;
        isGroup=false;
        chatterUsers=new List<user>();
        for(User chatterUser:[SELECT Id, Name,Email,userType,Title,FullPhotoUrl,Department,SmallPhotoUrl,CompanyName,Country,IsActive FROM User Limit 10]){
            chatterUsers.add(chatterUser);
            memberIds.add(chatterUser.Id);
        }
       
    }
    public void showfeed(){
        isFeed=true;
        isPeople=false;
        isGroup=false;
    }
    public void showGroup(){
        isFeed=false;
        isPeople=false;
        isGroup=true;
        Map<ID,Integer> feedCountMap=new Map<ID,Integer>();
        List<Integer> countList=new List<Integer>();
        List<String> ids=new List<String>();
        userGroups=new List<CollaborationGroup>();
        List<String> groupIds=new List<String>();
        List<CollaborationGroupMember> gMember=[select CollaborationGroupId from CollaborationGroupMember where memberId=:userInfo.getUserId()];
        for(CollaborationGroupMember cm : gMember)
            groupIds.add(cm.CollaborationGroupId);
        for(CollaborationGroup userGroup:[SELECT Id, Name,SmallPhotoUrl,Description,MemberCount FROM CollaborationGroup where id in:groupIds]){
            userGroups.add(userGroup);
            //idGroupMap.put(userGroup.id,user);
        } 
        
    }
    public void createNewGroup(){
        CollaborationGroup cGroup=new CollaborationGroup(
            name=groupName,
            Description=groupDesc,
            //IsAutoArchiveDisabled=Boolean.valueOf(isAutoArchieve),
            CollaborationType=access,
            CanHaveGuests=allowCustomer
        );
        try{
            insert cGroup;
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    public void showMorePeople(){
        if(isPeople){
            for(User chatterUser:[SELECT Id, Name,Email,Title,userType,FullPhotoUrl,Department,SmallPhotoUrl,CompanyName,Country,IsActive FROM User where Id not IN:memberIds Limit 10]){
                chatterUsers.add(chatterUser);
                memberIds.add(chatterUser.Id);
            }
        }
    }
  
}