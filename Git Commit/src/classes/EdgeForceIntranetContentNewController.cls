/**
  * Apex Class: IntranetContentNewController
  * Description: T-179349 : Develop VF page to enter content
  * Created By: Ashish Sharma (Appirio Off)
  * Created Date: September 2nd, 2013.
  */
public with sharing class EdgeForceIntranetContentNewController {
    public Intranet_Content__c intranetContent {get ; set ;}
    public Intranet_Content_Version__c intranetContentVersion {get ; set ;}
    public String recordTypeName {get ; set ;}
    public boolean isCMSField {get ; set ;}
    public boolean isArticleField {get ; set ;}
    public boolean isLinkField {get ; set ;}
    public boolean isBannerField {get ; set ;}
    public boolean isLearningCenter {get ; set ;}
    public boolean isDynamicComponent {get ; set ;}
    public boolean showSummary{get ; set ;}
    public List<SelectOption> listOfObjectsName{get;set;}
    public String selectedObject{get;set;}
    public String sortColumn{get;set;}
    public List<SelectOption> listOfObjectsFields{get;set;}
    public List<String> selectedFields{get;set;}
    public Boolean isSearchConfig {get;set;}
    public boolean showDocManagementLayout{get;set;}
    
    public EdgeForceIntranetContentNewController(){
        intranetContent = new Intranet_Content__c();
        intranetContentVersion = new Intranet_Content_Version__c();
        isCMSField = false;
        isArticleField = false;
        isDynamicComponent = false;
        isSearchConfig = false;
        intranetContentVersion.Language__c = 'English';
        intranetContentVersion.Primary_Record__c = true;
        showSummary = false;
        
        //Fetch the record type name and id which are selected in Record Type Selection page
        recordTypeName = Apexpages.currentPage().getParameters().get('RecordTypeName');
        intranetContent.RecordTypeId = Apexpages.currentPage().getParameters().get('RecordTypeId');
        
        if(recordTypeName == 'Intranet CMS Pages'){
            isCMSField = true;
        }else if(recordTypeName == 'Intranet Article' || recordTypeName == 'Learning Center'){
            isArticleField = true;
        }else if(recordTypeName == 'Intranet Banner'){
            isBannerField = true;
        }else if(recordTypeName == 'Intranet Link'){
            isLinkField = true;
        }else if(recordTypeName == 'Dynamic Component'){
            listOfObjectsName = new List<selectOption>();
            listOfObjectsName.add(new SelectOption('---Select---','---Select---'));
            for(Schema.SObjectType SObj : Schema.getGlobalDescribe().Values())
            {
               listOfObjectsName.add(new SelectOption(SObj.getDescribe().getName(),SObj.getDescribe().getName()));
            }
            listOfObjectsName.sort();
            isDynamicComponent = true;
        }
        if(recordTypeName == 'Learning Center'){
            isLearningCenter = true;
        }
        
        if(recordTypeName == 'Intranet Article'){
            showSummary = true;
        }
        if(recordTypeName == 'Search Component'){
           isSearchConfig  = true;
        }
        if(recordTypeName == 'Document Management'){
           showDocManagementLayout  = true;
        }
    }
    //return List of all the fields of selected object in dynamic Components
    public void fetchObjectFields(){
        listOfObjectsFields = new List<SelectOption>();
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        if(selectedObject!=null && selectedObject!='' && selectedObject != '---Select---'){
            Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
            System.debug('!!!!!!!!dsrS'+dsr);
            Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
            for(String key : fieldMap.keySet()) {
                listOfObjectsFields.add(new SelectOption(key,key));
            }
            listOfObjectsFields.sort();
        }
    }
    //Save the Intranet Content and Intranet Content version records
    public Pagereference save(){
     try{
        if(intranetContent.Template__c == 'Team' && 
               !intranetContent.Create_Chatter_Group__c){
            intranetContent.addError('Create Chatter Group? checkbox must be checked.');
            return null;
        }
        
        /*if(intranetContent.Template__c == 'Content' 
            && intranetContent.Type__c == 'External'){
           if(intranetContent.URL__c == null || intranetContent.URL__c == ''){
                intranetContent.addError('URL: You must enter a value');
                return null;
           }
        }*/
        
        if(intranetContent.Target__c == null){
            intranetContent.Target__c = '_self';
        }
        
        if(recordTypeName == 'Dynamic Component'){
            intranetContent.Object_Name__c = selectedObject;
            String fieldsString = '';
            for(String s:selectedFields) {
               fieldsString += (fieldsString==''?'':',')+s;
            }
            //intranetContent.Fields_to_Display__c = JSON.serialize(selectedFields);
            intranetContent.Fields_to_Display__c = fieldsString;
            intranetContent.Sort_Column__c = sortColumn;
        }
        insert intranetContent;
        intranetContentVersion.Intranet_Content__c = intranetContent.Id;
        intranetContentVersion.Name = intranetContent.Name;
        intranetContentVersion.isPublished__c = true;
        insert intranetContentVersion;      
        
        return new Pagereference('/' + intranetContent.Id);
     }catch(DmlException e){
        intranetContent.addError(e.getDmlMessage(0));
        return null;
     }
    }
    
    //This function will cancel the action and redirect to Intranet Content list view
    public Pagereference cancel(){
        return new Pagereference('/' + Intranet_Content__c.sObjectType.getDescribe().getKeyPrefix());
    }
}