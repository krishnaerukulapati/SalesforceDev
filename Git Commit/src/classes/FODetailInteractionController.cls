public without sharing class FODetailInteractionController {
    public FieldInteraction__c fi { get; set; }
    public domainSoapStjudeOrg.Interaction i {get; set;}
    public String relId { get; set; }
    public String leadType {get; private set;}
    public String summary {get; set;}
    public String action {get; private set;}
    public String comments { get; set; }
    public String contType {get; set;}
    public String viewCat {get; private set;}
    public String viewType {get; private set; }
    public String viewTech {get; private set; }
    public String contCat {get; set;}
    public String description {get; set;}
    public String tech {get; set;}
    public EVMUtil.consInfo ci {get; private set;}
    public String formattedDate {get; set;}
    public Boolean isSF1 {get;set;}

    public FODetailInteractionController() {
        i = new domainSoapStjudeOrg.Interaction();
        relId = System.currentPageReference().getParameters().get('id');
        action = System.currentPageReference().getParameters().get('action');
        leadType = System.currentPageReference().getParameters().get('leadType');
        i.ContactDate = System.currentPageReference().getParameters().get('contDate');
        summary = System.currentPageReference().getParameters().get('summary');
        comments = System.currentPageReference().getParameters().get('comments');
        if (String.isNotEmpty(System.currentPageReference().getParameters().get('SF1'))) {
            isSF1 = Boolean.valueOf(System.currentPageReference().getParameters().get('SF1'));
        }
        else {
            isSF1 = false;
        }

        //HTML decode for text strings
        if (String.isNotBlank(summary)) summary = summary.unescapeHtml4();
        if (String.isNotBlank(comments)) comments = comments.unescapeHtml4();

        contType = System.currentPageReference().getParameters().get('contType');
        contCat = System.currentPageReference().getParameters().get('contCat');
        tech = System.currentPageReference().getParameters().get('tech');
        if (String.isBlank(leadType)) leadType = 'ORG';
        if (String.isBlank(i.ContactDate)) i.ContactDate = DateTime.now().format('yyyy-MM-dd');
        system.debug(relId);
        ci = EVMUtil.getConsInfo(relId, leadType);
        fi = new FieldInteraction__c();
        PopulatePicklists();
        system.debug('IsSF1: ' + isSF1);
    }

    public String GetUserName() {
        Pattern nonAlpha = Pattern.compile('[^a-zA-Z]');
        String userName;
        String firstName = '';
        if (String.isNotBlank(UserInfo.getFirstName())) firstName = UserInfo.getFirstName().substring(0,1);
        String lastName = UserInfo.getLastName();
        Matcher matcher = nonAlpha.matcher(lastName);
        lastName = matcher.replaceAll('');
        if (lastName.length() >= 11) lastName = lastName.substring(0,11);
        userName = lastName + firstName;
        return userName.toUpperCase(); 
    }

    public void PopulatePicklists() {
        //populate description and program picklists
        if(String.isNotEmpty(contType) && String.isNotEmpty(contCat)) {
            List<FieldInteraction__c> fis = [
                SELECT id, Program__c, Description__c, Technique__c, ContactCategory__c, ContactType__c
                FROM FieldInteraction__c
                WHERE ContactCategory__c = :contCat and ContactType__c = :contType];
            //Load from SF mapping if results are returned
            if(fis.size() > 0) {
                fi.Program__c = fis.get(0).Program__c;
                fi.Description__c = fis.get(0).Description__c;
            }
            //Else Load from Database
            else {
                viewCat = contCat;
                viewType = contType;
            }            
        }
        //populate technique picklist
        if(String.isNotEmpty(tech)) {
            List<CodeLookups__c> cl = [
                SELECT id, CodeValue__c, CodeDescription__c, CodeType__c
                FROM CodeLookups__c
                WHERE CodeValue__c = :tech AND CodeType__c = 'Technique'];
            if(cl.size() > 0) {
                fi.Technique__c = cl.get(0).CodeDescription__c;
            }
            else {
                viewTech = tech;
            }           
        }
    }

    public PageReference save() {
        PageReference pr;
        if (validateForm()) {

            List<FieldInteraction__c> fis = [
                select id, Program__c, Description__c, Technique__c, ContactCategory__c, ContactType__c
                from FieldInteraction__c
                where Program__c = :fi.Program__c and Description__c = :fi.Description__c];

            List<CodeLookups__c> techs = [
                select id, CodeValue__c, CodeDescription__c, CodeType__c
                from CodeLookups__c
                where CodeDescription__c = :fi.Technique__c and CodeType__c = 'Technique'];

            if (fis.size() > 0) {
                FieldInteraction__c relFi = fis.get(0);
                List<String> after = new List<String>();

                if(!i.ContactDate.endsWith(' 00:00:00')) {
                    i.ContactDate += ' 00:00:00';
                }
                i.Page_x = 1;
                i.ContactCategory = relFi.ContactCategory__c;
                i.ContactType = relFi.ContactType__c;
                i.Summary = summary;
                i.LongComments = comments;
                i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
                if (techs.size() > 0) {
                    i.TransactionSource.Technique = techs.get(0).CodeValue__c;
                }

                system.debug('ci.consId: ' + ci.consId);
                system.debug('i.ContactDate: ' + i.ContactDate);               
                system.debug('i.ContactCategory: ' + i.ContactCategory);
                system.debug('i.ContactType: ' + i.ContactType);
                system.debug('i.LongComments: ' + i.LongComments);
                system.debug('i.Summary: ' + i.Summary);            
                system.debug('i.TransactionSource.Technique: ' + i.TransactionSource.Technique);

                try {
                    if (action != 'edit') {
                        system.debug('Creating... ');
                        i.Staff = GetUserName();
                        system.debug('i.Staff: ' + i.Staff);
                        system.debug('i.ContactSeq: ' + i.ContactSeq);
                        system.debug('i.Page_x: ' + i.Page_x);
                        FOUtil.createInteraction(ci.consId, i);
                        createFOInteraction(i, 'create');
                    }
                    else {
                        system.debug('Editing... ');
                        if (String.isNotEmpty(System.currentPageReference().getParameters().get('contPage'))) {
                            i.Page_x = integer.valueOf(System.currentPageReference().getParameters().get('contPage'));
                        }
                        else {
                            i.Page_x = 1;
                        }
                        if (String.isNotEmpty(System.currentPageReference().getParameters().get('contSeq'))) {
                            i.ContactSeq = integer.valueOf(System.currentPageReference().getParameters().get('contSeq'));
                        }
                        else {
                            i.ContactSeq = 1;
                        }
                        i.ResponseCategory = System.currentPageReference().getParameters().get('respCat');
                        i.ResponseType = System.currentPageReference().getParameters().get('respType');
                        i.TransactionSource.Code = System.currentPageReference().getParameters().get('sourceCode');
                        system.debug('i.Staff: ' + i.Staff);
                        system.debug('i.ContactSeq (composite key): ' + i.ContactSeq);
                        system.debug('i.Page_x (composite key): ' + i.Page_x);
                        system.debug('i.ContactDate (composite key): ' + i.ContactDate);
                        system.debug('ci.consId (composite key - xref to TA account/nameID) : ' + ci.consId);  
                        system.debug('i.ResponseCategory: ' + i.ResponseCategory);
                        system.debug('i.ResponseType: ' + i.ResponseType);
                        system.debug('i.TransactionSource.Code: ' + i.TransactionSource.Code);
                        FOUtil.editInteraction(ci.consId, i);
                        createFOInteraction(i, 'edit');
                        } 
                }
                catch(Exception e) {
                     System.debug('FODetailInteractionController.save: exception: ' + e.getMessage());
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving your interaction.'));
                    if (i.ContactDate.endsWith(' 00:00:00')){
                        String[] contDate = i.ContactDate.split(' ');
                        i.ContactDate = contDate[0];
                    }
                    return null;
                }
                

                after.add(String.format('{0} = {1}', new String[] {'Program', relFi.Program__c}));
                after.add(String.format('{0} = {1}', new String[] {'Description', relFi.Description__c}));
                after.add(String.format('{0} = {1}', new String[] {'Technique', fi.Technique__c}));
                after.add(String.format('{0} = {1}', new String[] {'Contact Category', relFi.ContactCategory__c}));
                after.add(String.format('{0} = {1}', new String[] {'ContactType', relFi.ContactType__C}));

                EVMUtil.createTask(ci, 'Log Interaction', 'Completed', relFi.Id, new List<String>(), after);
            }
            pr = new PageReference('/Apex/FOInteractions');
            pr.getParameters().put('id', relId);
            if (isSF1){
                pr = new PageReference('/Apex/FOSearchMobile');
                pr.getParameters().put('cid', relId);
            }
        }
        return pr;
    }

    public LIST<SelectOption> getPrograms() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
        FieldInteraction__c.Program__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }

    public LIST<SelectOption> getDescriptions() {
        List<SelectOption> options = new List<SelectOption>();
        List<FieldInteraction__c> fis = [select id, Description__c from FieldInteraction__c where Program__c = :fi.Program__c];
        
        system.debug('fi.Program__c: ' + fi.Program__c);
        system.debug('fis.size(): ' + fis.size());
        for( FieldInteraction__c fi : fis) {
          options.add(new SelectOption(fi.Description__c, fi.Description__c));
        }       
        return options;
    }

    public LIST<SelectOption> getTechniques() {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult =
        FieldInteraction__c.Technique__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
        for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }

    public void changePrograms() {

    }

    private boolean validateForm() {
        boolean valid = true;      
        String dateRegEx = '((19|20)\\d\\d)-(0?[1-9]|1[012])-(0?[1-9]|[12][0-9]|3[01])';
        Pattern datePattern = Pattern.compile(dateRegEx);
        DateTime dt;

        if(String.isBlank(fi.Program__c)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Program is required.'));
            valid = false;
        }
        if(String.isBlank(fi.Description__c)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Description is required.'));
            valid = false;
        }
        if(String.isBlank(fi.Technique__c)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Technique is required.'));
            valid = false;
        }
        if(String.isBlank(i.ContactDate)) {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Date is required.'));
            valid = false;
        }
        else {
            Matcher dateMatcher = datePattern.matcher(i.ContactDate);
            if(!dateMatcher.matches()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Date must be in YYYY-MM-DD format.'));
                valid = false;
            }
            else {
                if(!i.ContactDate.endsWith(' 00:00:00')) {
                    dt = DateTime.valueOf(i.ContactDate + ' 00:00:00');
                }
                else {
                    dt = DateTime.valueOf(i.ContactDate);
                }
                
                if (dt > DateTime.now()) {
                    ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Contact Date cannot be in the future.'));
                    valid = false;
                }
            }
        }
        
        system.debug('fi.Program__c: ' + fi.Program__c);
        system.debug('fi.Description__c: ' + fi.Description__c);
        system.debug('fi.Technique__c: ' + fi.Technique__c);
        system.debug('contDate: ' + i.ContactDate);

        if (!valid && i.ContactDate.endsWith(' 00:00:00')){
            String[] contDate = i.ContactDate.split(' ');
            i.ContactDate = contDate[0];
        }

        return valid;
    }

    //Writes to ODS.dbo.FOInteractions for reporting purposes
    public void createFOInteraction(domainSoapStjudeOrg.Interaction i, String action) {
        system.debug('createFOInteraction');
        system.debug('FOInteractions_Endpoint__c Custom setting value: ' + OdataExtensionSettings__c.getInstance().FOInteractions_Endpoint__c);
        FOInteractions__x foi = new FOInteractions__x();
        List<FieldInteraction__c> fis;
        List<CodeLookups__c> cl;
        String userId = UserInfo.getUserId();
        String[] splitAcct;

        //Get TA account ID and split into AccountID/NameID
        List<domainSoapStjudeOrg.SystemXRef> conXref = FOUtil.getConstituentXRefs(ci.consId, '');
        for(domainSoapStjudeOrg.SystemXRef xrCon : conXref) {
            if (xrCon.Sys != null && xrCon.Sys.Name != null) {
                if (xrCon.Sys.Name == 'TA') {
                    system.debug('TA Account: ' +  xrCon.XRefKey);
                    if (String.isNotEmpty(xrCon.XRefKey)) splitAcct = xrCon.XRefKey.split('\\|');
                    system.debug('AccountID: ' + splitAcct[0]);
                    system.debug('NameID: ' + splitAcct[1]);
                    if (String.isNotEmpty(splitAcct[0])) foi.AccountID__c = Decimal.valueOf(splitAcct[0]);
                    if (String.isNotEmpty(splitAcct[1])) foi.Name_ID__c = Decimal.valueOf(splitAcct[1]);
                }
            }
        }

        if (String.isNotEmpty(i.ContactCategory) && String.isNotEmpty(i.ContactType)) {
            fis = [
                SELECT id, Program__c, Description__c, Technique__c, ContactCategory__c, ContactType__c
                FROM FieldInteraction__c
                WHERE ContactCategory__c = :i.ContactCategory and ContactType__c = :i.ContactType];
        }   

        if (String.isNotEmpty(i.TransactionSource.Technique)) {
            cl = [
                SELECT id, CodeValue__c, CodeDescription__c, CodeType__c
                FROM CodeLookups__c
                WHERE CodeValue__c = :i.TransactionSource.Technique AND CodeType__c = 'Technique'];
        }      

        //Set FOInteraction attributes from interaction object
        system.debug('ContactDate Input: ' + i.ContactDate);
        if (String.isNotEmpty(i.ContactDate)) {
            foi.CONTACT_DATE__c = DateTime.valueOf(i.ContactDate);
            system.debug('Contact_Date: ' + foi.Contact_Date__c);
        }
        foi.Page__c = 1;
        system.debug('Page: ' + foi.Page__c);
        foi.CONTACT_SEQ__c = i.ContactSeq;
        system.debug('ContactSeq: ' + foi.CONTACT_SEQ__c);
        foi.ConstituentID__c = ci.consId;     
        if (String.isNotEmpty(i.ContactCategory)) foi.ContactCategory__c = i.ContactCategory;
        system.debug('ContactCategory: ' + foi.ContactCategory__c);
        if (String.isNotEmpty(i.ContactType)) foi.ContactType__c = i.ContactType;
        system.debug('ContactType: ' + foi.ContactType__c);
        if (fis.size() > 0 && String.isNotEmpty(fis.get(0).Description__c)) foi.ContactTypeDesc__c = fis.get(0).Description__c;
        system.debug('Contact Type Description: ' + foi.ContactTypeDesc__c);
        if (fis.size() > 0 && String.isNotEmpty(fis.get(0).Program__c)) foi.Program__c = fis.get(0).Program__c;
        system.debug('Program: ' + foi.Program__c);
        if (String.isNotEmpty(i.Summary)) foi.Summary__c = i.Summary;
        system.debug('Summary: ' + foi.Summary__c);
        if (String.isNotEmpty(i.LongComments)) foi.LongComments__c = i.LongComments;
        system.debug('LongComments: ' + foi.LongComments__c);
        if (String.isNotEmpty(i.TransactionSource.Technique)) foi.Technique__c = i.TransactionSource.Technique;
        system.debug('Technique: ' + foi.Technique__c);
        if (cl.size() > 0 && String.isNotEmpty(cl.get(0).CodeDescription__c)) foi.TechniqueDesc__c = cl.get(0).CodeDescription__c;
        system.debug('Technique Description: ' + foi.TechniqueDesc__c);


        //Get SF user details 
        List<User> user = [
            SELECT Id, FederationIdentifier, Region_Code__c, Cost_Center__c
            FROM User
            WHERE Id = :userId];

        if (action == 'create') {
            if (String.isNotEmpty(user.get(0).FederationIdentifier)) foi.CreatedFederationIdentifer__c = user.get(0).FederationIdentifier;
            system.debug('Created FederationIdentifier: ' + foi.CreatedFederationIdentifer__c);
            if (!String.isNotEmpty(foi.CreatedFederationIdentifer__c)) {
                foi.CreatedFederationIdentifer__c = UserInfo.getUserEmail();
                system.debug('Created User Email: ' + foi.CreatedFederationIdentifer__c);
            }

            foi.CreatedFirstName__c = UserInfo.getFirstName();
            system.debug('Created firstName: ' + foi.CreatedFirstName__c);
            foi.CreatedLastName__c = UserInfo.getLastName();
            system.debug('Created LastName: ' + foi.CreatedLastName__c);

            //if (String.isNotEmpty(user.get(0).)) foi.CreatedOffice__c = user.get(0).
            //system.debug('User Office: ' + foi.CreatedOffice__c);

            if (String.isNotEmpty(user.get(0).Region_Code__c))foi.CreatedRegion__c = user.get(0).Region_Code__c;
            system.debug('Created User Region: ' + foi.CreatedRegion__c);

            if (String.isNotEmpty(user.get(0).Cost_Center__c))foi.CreatedCostCenter__c = user.get(0).Cost_Center__c;
            system.debug('Created User Cost Center: ' + foi.CreatedCostCenter__c);

            foi.CreatedBy__c = foi.ModifiedBy__c = userId;
            foi.CreatedDate__c = foi.ModifiedDate__c = DateTime.now();
            system.debug('saveFOInteraction');
            String foId = OdataExtension.saveFOInteraction('', foi);
        }
        else {
            if (String.isNotEmpty(user.get(0).FederationIdentifier)) foi.ModifiedFederationIdentifer__c = user.get(0).FederationIdentifier;
            system.debug('Modified FederationIdentifier: ' + foi.ModifiedFederationIdentifer__c);
            if (!String.isNotEmpty(foi.ModifiedFederationIdentifer__c)) {
                foi.ModifiedFederationIdentifer__c = UserInfo.getUserEmail();
                system.debug('Modified User Email: ' + foi.ModifiedFederationIdentifer__c);
            }

            foi.ModifiedFirstName__c = UserInfo.getFirstName();
            system.debug('Modified firstName: ' + foi.ModifiedFirstName__c);
            foi.ModifiedLastName__c = UserInfo.getLastName();
            system.debug('Modified LastName: ' + foi.ModifiedLastName__c);

            //if (String.isNotEmpty(user.get(0).)) foi.CreatedOffice__c = user.get(0).
            //system.debug('User Office: ' + foi.CreatedOffice__c);

            if (String.isNotEmpty(user.get(0).Region_Code__c))foi.ModifiedRegion__c = user.get(0).Region_Code__c;
            system.debug('Modified User Region: ' + foi.ModifiedRegion__c);

            if (String.isNotEmpty(user.get(0).Cost_Center__c))foi.ModifiedCostCenter__c = user.get(0).Cost_Center__c;
            system.debug('Modified User Cost Center: ' + foi.ModifiedCostCenter__c);

            foi.ModifiedBy__c = userId;
            foi.ModifiedDate__c = DateTime.now();
            List<FOInteractions__x> interactions = OdataExtension.getFOInteraction(i, foi.AccountID__c, foi.Name_ID__c);
            if (interactions.size() > 0) {
                foi.InteractionId__c = interactions.get(0).InteractionId__c;
                foi.CreatedBy__c = interactions.get(0).CreatedBy__c;
                foi.CreatedDate__c = interactions.get(0).CreatedDate__c;
                system.debug('editFOInteraction');
                String foId = OdataExtension.saveFOInteraction(foi.InteractionId__c, foi);
            }
            else {
                system.debug('The action was an edit but a matching interaction was not found. Creating...');
                if (String.isNotEmpty(user.get(0).FederationIdentifier)) foi.CreatedFederationIdentifer__c = user.get(0).FederationIdentifier;
                system.debug('Created FederationIdentifier: ' + foi.CreatedFederationIdentifer__c);
                if (!String.isNotEmpty(foi.CreatedFederationIdentifer__c)) {
                    foi.CreatedFederationIdentifer__c = UserInfo.getUserEmail();
                    system.debug('Created User Email: ' + foi.CreatedFederationIdentifer__c);
                }

                foi.CreatedFirstName__c = UserInfo.getFirstName();
                system.debug('Created firstName: ' + foi.CreatedFirstName__c);
                foi.CreatedLastName__c = UserInfo.getLastName();
                system.debug('Created LastName: ' + foi.CreatedLastName__c);

                //if (String.isNotEmpty(user.get(0).)) foi.CreatedOffice__c = user.get(0).
                //system.debug('User Office: ' + foi.CreatedOffice__c);

                if (String.isNotEmpty(user.get(0).Region_Code__c))foi.CreatedRegion__c = user.get(0).Region_Code__c;
                system.debug('Created User Region: ' + foi.CreatedRegion__c);

                if (String.isNotEmpty(user.get(0).Cost_Center__c))foi.CreatedCostCenter__c = user.get(0).Cost_Center__c;
                system.debug('Created User Cost Center: ' + foi.CreatedCostCenter__c);

                foi.CreatedBy__c = userId;
                foi.CreatedDate__c = DateTime.now();
                String foId = OdataExtension.saveFOInteraction('', foi);
            }
        }    
    }
}