/*******************************************************************************************
  *Modified by   : Sil
  *Modified date : 10-March-2014
  *purpose       : Recent News was nor coming as category was not dynamic.fixed the issue.modified wrapper.
  *changeid      : c001 
   ******************************************************************************************
   */
Public without sharing class EdgeforceIntranetNewsPageController {

    public Map<Id, IntranetUtility.LikesCommentFollwerInfo> socialInfoMap {get; private set;}
    public List<contentWrapper> wrapperList{get;set;}
    public String offSet{get;set;}{offSet='1';}
    public List<contentWrapper> displayList{get;set;}
    public List<String> paginationno{get;set;}
    public Integer itemsperpage=5;
    public Integer offSetInt{get;set;}
    public Integer endWith{get;set;}
    public Integer totalNews{get;set;}
    public String isFirst{get;set;}
    public String isLast{get;set;}
    String prevOffSet;
    Integer count;


    public EdgeforceIntranetNewsPageController() {
        Map<String,String> langMap = new Map<String,String>();
        langMap.put('en_US','English');
        langMap.put('de','German');
        langMap.put('es','Spanish');
        System.debug('!!!!Language!!!!'+UserInfo.getLanguage());
        socialInfoMap = new Map<Id, IntranetUtility.LikesCommentFollwerInfo>();
        wrapperList=new List<contentWrapper>();
        displayList=new List<contentWrapper>();
        paginationno=new List<String>();
        Set<Id> contentIds = new Set<Id>();
        //ID recordTypeId=[SELECT Id, Name FROM RecordType WHERE SObjectType = 'Intranet_Content__c' AND DeveloperName ='Intranet Article'].id;
        for(Intranet_content__c content:[select Id,Type__c, (select Id from Attachments Limit 1),(select name,tags__r.tag__c from Intranet_Content_Tags__r),(select id,Name,summary__c from Intranet_content_versions__r where Language__c =:langMap.get(UserInfo.getLanguage())) from Intranet_Content__c where recordType.Name='Intranet Article' ]){
            contentIds.add(content.Id);
            String imageId;

            List<String> tagsList=new List<String>();
            //List of all the tags of IC
            for(Intranet_Content_Tags__c tags:content.Intranet_Content_Tags__r){
                tagsList.add(tags.tags__r.tag__c);
            }
            //Image for IC
            for(Attachment attachment:content.Attachments){
                imageId=attachment.id;
            }
            //wrapping image,tags,title and summary for ICV
            for(Intranet_content_version__c ICV:content.Intranet_content_versions__r){
            	//c001
                wrapperList.add(new contentWrapper(imageId,ICV.Name,ICV.summary__c,tagsList,content.id,content.Type__c));
            }
        }
        totalNews=wrapperList.size();
        socialInfoMap = IntranetUtility.getSocialInfo(contentIds);
        //Setting the Page numbers to display
        paginationno.clear();
        count=totalNews/itemsperpage;
        if(Math.mod(totalNews,itemsperpage)>0){count++;}
        for(Integer x=1;x<=3;x++){
            if(x<=count)
                paginationno.add(String.valueOf(x));
        }
        addToDispalyList();

    }



    public void addToDispalyList(){
        isFirst='false';
        isLast='false';

        //User click on any page no. i.e 1,2,3...
        try{
            system.debug('----  '+prevOffset +'----  '+offSet +'----  '+offSetInt);
            If(!(offSet.equals('Previous')) && !(offSet.equals('Next'))){
                offSetInt=((Integer.valueOf(offSet)*itemsperpage-itemsperpage)<wrapperList.size()?Integer.valueOf(offSet)*itemsperpage-itemsperpage:0);
            }
            //User click on Prev Link
            else if(offSet.equals('Previous')){
                offSet=String.valueOf((Integer.valueOf(prevOffSet)-1)<0?1:(Integer.valueOf(prevOffSet)-1));
                offSetInt=(offSetInt-itemsperpage>0?offSetInt-itemsperpage:0);
            }
            //User click on Next Link
            
            else{
                offSet=String.valueOf((Integer.valueOf(prevOffSet)+1)>count?count:(Integer.valueOf(prevOffSet)+1));
                offSetInt=(offSetInt+itemsperpage<wrapperList.size()?offSetInt+itemsperpage:wrapperList.size()-itemsperpage);
            }
            
            system.debug('----  '+prevOffset +'----  '+offSet +'----  '+offSetInt);
            if(offSetInt>=0){
                //disable or enable variables for Prev and Next
                if(offSet=='1')
                    isFirst='true';
                if(offSet==String.valueOf(count))
                    isLast='true';
                //Setting new List of Pagination pages nos.
                set<String> paginationSet=new set<String>();
                paginationSet.addAll(paginationno);
    
                if(!paginationSet.contains(offSet) && ((Integer.valueOf(offSet))>0 && (Integer.valueOf(offSet))<=count)){
                    if(Integer.valueOf(offSet)<Integer.valueOf(paginationno[0])){
                        paginationno.remove(paginationno.size()-1);
                        paginationno.add(0,offSet);
                    }
                    else{
                        paginationno.remove(0);
                        paginationno.add(offSet);
                    }
                }
                //last News Number
                endWith=(offSetInt+itemsperpage<wrapperList.size()?offSetInt+itemsperpage:wrapperList.size());
    
    
                //First clear all the data from displayList
                displayList.clear();

                //Assign new data to dispalyList according to the page number.
                for(Integer x=offSetInt; x<(offSetInt+itemsperpage<wrapperList.size()?offSetInt+itemsperpage:wrapperList.size());x++){
                    displayList.add(wrapperList[x]);
                }
                prevOffSet=offSet;
            }
            else{
                offSetInt+=itemsperpage-1;
            }
        }
        Catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    
    //Wrapper class to wrap image,tags,title and summary for ICV
    public class contentWrapper{
        public String articleId{get;set;}
        public String categorytype{get;set;}//c001 
        public String imageId{get;set;}
        public String title{get;set;}
        public String summary{get;set;}
        public List<String> tagsList{get;set;}
        public contentWrapper(String imageId,String title,String summary,List<String> tagsList,String articleId,String localcategorytype){
            if(imageId==null) imageId=system.Label.Intranet_Default_Image_Id;
            this.imageId='/servlet/servlet.FileDownload?file='+imageId;
            this.title=title;
            this.summary=summary;
            this.tagsList=tagsList;
            this.articleId=articleId;
            this.categorytype = localcategorytype;
        }
    }
}