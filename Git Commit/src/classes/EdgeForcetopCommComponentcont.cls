public class EdgeForcetopCommComponentcont{
    public List<CollaborationGroup> userGroups{get;set;}
    public List<memberWrapper> memberWrapperList{get;set;}
    public String grpId{get;set;}
    public EdgeForcetopCommComponentcont(){
        createMemberList();
    }
    
    public void createMemberList(){
      try{
        memberWrapperList=new List<memberWrapper>();
        Map<ID,Integer> feedCountMap=new Map<ID,Integer>();
        List<Integer> countList=new List<Integer>();
        List<String> ids=new List<String>();
        userGroups=new List<CollaborationGroup>();
        
        Map<Id,CollaborationGroup> idGroupMap=new Map<Id,CollaborationGroup>([SELECT Id, Name,SmallPhotoUrl,Description,MemberCount FROM CollaborationGroup ]);
        Map<Id,CollaborationGroupMember> cMember=new Map<Id,CollaborationGroupMember>([select Id,CollaborationGroupId,CollaborationRole  from collaborationGroupMember where CollaborationGroupId IN: idGroupMap.keySet()  and memberId=:UserInfo.getUserId()]);
        System.debug('****cMember***'+cMember);
        for(Id uGroup:idGroupMap.keySet()){
            ids.add(uGroup);
        }
        for(CollaborationGroupFeed gFeed:[select id,ParentId from CollaborationGroupFeed ]){
            if(feedCountMap.containsKey(gFeed.parentId))
                feedCountMap.put(gFeed.ParentId,feedCountMap.get(gFeed.ParentId)+1);
            else
                feedCountMap.put(gFeed.ParentId,1);
        }
        for(Id feedId:feedCountMap.keySet()){
            countList.add(feedCountMap.get(feedId));
            
        }
        countList.sort();
        for(Integer count=countList[countList.size()-1];count>=0;count--){
            for(Id feedId:feedCountMap.keySet()){
                if(feedCountMap.get(feedId)==count){
                    userGroups.add(idGroupMap.get(feedId));
                }
            }
        }
        Integer size=userGroups.size();
        while(size<5){
            for(String notid:idGroupMap.keySet()){
                if(!feedCountMap.containsKey(notid))
                {
                    userGroups.add(idGroupMap.get(notid));
                    break;
                }
            }
            size=userGroups.size();
            if(size == idGroupMap.size()){
                break;
            }
        } 
        for(CollaborationGroup cg:userGroups){
            memberWrapperList.add(new memberWrapper(cg,cMember));
        }  
      }catch(Exception e){
        System.debug('ERROR :: ' + e.getMessage());
      }
       
    }
    
    public void follownewGroup(){
      try{
        System.debug('Joining..');
        CollaborationGroupMember member =new CollaborationGroupMember();
            member.CollaborationGroupId=grpId;
            member.memberId=UserInfo.getUserId();
            insert member;
            createMemberList();
            System.debug('*****member id is *****'+member.id);
      }catch(Exception e){
        System.debug('ERROR :: ' + e.getMessage());
      }
            
    }
    public void unFollowGroup(){
      try{
        CollaborationGroupMember member =[select id from CollaborationGroupMember where CollaborationGroupId=:grpId and memberId=:UserInfo.getUserId()];
        delete member;
        createMemberList();
      }catch(Exception e){
        System.debug('ERROR :: ' + e.getMessage());
      }
    }
    public class memberWrapper{
        public Boolean follow{get;set;}{follow=false;}
        public Boolean unFollow{get;set;}{unFollow=false;}
        public CollaborationGroup grpItem{get;set;}
        Boolean exist=false;
        public memberWrapper(CollaborationGroup cGroup,Map<Id,CollaborationGroupMember> cMember){
            this.grpItem=cGroup;
            for(Id ids:cMember.keyset()){
                if(cMember.get(ids).CollaborationGroupId==cGroup.id){
                    exist=true;
                    if((cMember.get(ids)).CollaborationRole=='Standard'){
                        unFollow=true;
                        
                        break;
                    } 
                }
                
            }
            if(!exist)
                follow=true;
        }
    }
    
}