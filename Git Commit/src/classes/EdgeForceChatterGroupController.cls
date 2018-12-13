public class EdgeForceChatterGroupController{
    public CollaborationGroup userGroup{get;set;}
    public List<User> userList{get;set;}  //list of peoples belongs to the group
    public List<User> newuserList{get;set;}
    public list<ContentDocumentLink> groupFiles{get;set;} //all the files of the group
    public Boolean noFiles{get;set;}{noFiles=false;}    //if there is no any file in the group
    public List<String> userIds;
    public Id groupId;          //Id of the group getting from URL
    public Integer memberCount{get;set;}        //no of peoples in the group
    public String searchText{get;set;} //userName to be searched 
    public EdgeForceChatterGroupController(){
        userIds=new List<String>();
        newuserList=new List<User>();
        groupId=ApexPages.currentPage().getParameters().get('g');
        memberCount=([select id from CollaborationGroupMember where CollaborationGroupId=:groupId]).size();
        userGroup=[SELECT Id,fullPhotoUrl,Description,Name,(select MemberId from GroupMembers Limit 4) FROM CollaborationGroup where id=:groupId];
        for(CollaborationGroupMember member: userGroup.GroupMembers){
            userIds.add(member.MemberId);
        }
        userList=[select Id,smallPhotoUrl,firstName,lastName from User where id IN:userIds];
        newuserList=userList;
        groupFiles=[SELECT ContentDocument.LatestPublishedVersion.Title,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityid =:groupId];
        if(groupFiles.size()==0){
            noFiles=true;
        }
        
        
    }
    
    public void showAllUsers(){
        System.debug('fetching more');
       userGroup=[SELECT Id,fullPhotoUrl,Description,Name,(select MemberId from GroupMembers where memberId NOT IN:userIds Limit 4) FROM CollaborationGroup where id=:groupId];
       for(CollaborationGroupMember member: userGroup.GroupMembers){
            userIds.add(member.MemberId);
        } 
        userList=[select Id,smallPhotoUrl,firstName,lastName from User where id IN:userIds];
        newuserList=userList;
        System.debug('********userList is ********'+userList.size()); 
    }
    public void searchUser(){
        userList=new List<User>();
        System.debug('-------  > '+searchText);
        if(searchText.length()==0)
            userList=newUserList;
        else{
            searchText=searchText+'%';
            Map<id,User> matchingUsers=new Map<Id,User>([select Id,smallPhotoUrl,firstName,lastName from User where firstName Like:searchText]);
            System.debug('***matchingUsers***' +matchingUsers.keySet());
            List<CollaborationGroupMember> cgMember=[select memberId from CollaborationGroupMember where memberId IN:matchingUsers.keySet() and CollaborationGroupId=:groupId];
            System.debug('***cgMember***' +cgMember);
            for(CollaborationGroupMember members:cgMember){
                if(matchingUsers.containsKey(members.memberId))
                    userList.add(matchingUsers.get(members.memberId));
            }
        }
    }
}