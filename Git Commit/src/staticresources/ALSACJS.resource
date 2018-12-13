/*Global variables*/
var changedRows = [];

/*Function for executing on page load */
(function (skuid) {
	var $ = skuid.$;
	detectUnsavedChanges();
})(skuid);

skuid.snippet.registerSnippet('clearChangedRows', function() {
    changedRows = [];
});

/***Snippets for saving the various external objects***/
skuid.snippet.registerSnippet('save.Event', function() {
    function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
    function isDate(txtDate)
    {
        var currVal = txtDate;
        if(currVal == '')
            return false;
        
        var rxDatePattern = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/; //Declare Regex
        var dtArray = currVal.match(rxDatePattern); // is format OK?
        
        if (dtArray == null) 
            return false;
        
        //Checks for mm/dd/yyyy format.
        dtMonth = dtArray[1];
        dtDay= dtArray[3];
        dtYear = dtArray[5];        
        
        if (dtMonth < 1 || dtMonth > 12) 
            return false;
        else if (dtDay < 1 || dtDay> 31) 
            return false;
        else if ((dtMonth==4 || dtMonth==6 || dtMonth==9 || dtMonth==11) && dtDay ==31) 
            return false;
        else if (dtMonth == 2) 
        {
            var isleap = (dtYear % 4 == 0 && (dtYear % 100 != 0 || dtYear % 400 == 0));
            if (dtDay> 29 || (dtDay ==29 && !isleap)) 
                    return false;
        }
        return true;
    }
   
// Create a jQuery Deferred

    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;
    var eventId = row.EventID__c === undefined ? null : row.EventID__c;
    console.log(row);
    if(eventId == null){
        row.EventTypeID__c = $(".eventTypeSelectList select").val();
        row.FiscalYear__c = $(".FiscalYear__c input").val();
    }
    
    row.StateID__c = $(".StateID__c select").val();
    row.CountryID__c = $(".CountryID__c select").val();
    console.log('$$CountryID__c value while saving'+$(".CountryID__c select").val());
    
	
	row.CostCenterID__c = $(".costCenterSelectList select").val();
	console.log('$$CostCenterID__c value while saving'+$(".costCenterSelectList select").val());
	
    row.StateID__c = row.StateID__c === undefined || row.StateID__c== ''? null : row.StateID__c;
    row.EventTimeZoneID__c = $(".EventTimeZoneID__c select").val();
    row.EventTimeZoneID__c = row.EventTimeZoneID__c === undefined ||  row.EventTimeZoneID__c== ''? null : row.EventTimeZoneID__c;
    row.CountryID__c = row.CountryID__c === undefined ||  row.CountryID__c== ''? null : row.CountryID__c;
    row.ZipCode__c = row.ZipCode__c  === undefined ||  row.ZipCode__c== ''? null : row.ZipCode__c.toUpperCase();
	row.EventCode__c = row.EventCode__c  === undefined ||  row.EventCode__c== ''? null : row.EventCode__c.toUpperCase();
    //JG: not sure what the deferred method accomplishes for you.
    // Goutham: dealing with Asynchronous functions such as updateData() or save(), 
    // we have to employ a different approach to controlling whether or not to move on to the next Action
    // in your sequence of actions, an approach based on jQuery Deferred Promises.
    // This approach is described in this Community Post: https://community.skuidify.com/skuid/topics/block-ui-and-show-message-until-sforce-connection-remotefunction-call-completes
    // In our case we are updating EventCodes model data for validated duplicate event code
    var dfd = $.Deferred();
    
    var requiredFieldsEntered = validateRequiredFields(model, editor);
	console.log('FiscalYear__c'+row.FiscalYear__c);
	var EventCodes = skuid.model.getModel('EventCodes');
    //JG: same here - I'd use skuid's API (like in the validateRequiredFields() function) to add messages to the page instead of injecting raw HTML.
	// Goutham : Thanks for the input Jonathan, Okey we will use custom message of skuid api
	// Yes now we have used standard function for adding custom message
    
    var Statuses = skuid.model.getModel('Statuses');
    var isOtherError = false;
    var statusId ='';
    if(Statuses.getRows().length ==0){
       	isOtherError = true;
        addErrorMessage(editor,'Active Status Record Not found in Statuses external object');
    }else{
        statusId = Statuses.getFirstRow().ExternalId;
    }
    EventCodesCondition = EventCodes.getConditionByName('EventCode__c');
    EventCodes.activateCondition(EventCodesCondition);
    EventCodes.setCondition(EventCodesCondition,row.EventCode__c);
    //JG: It looks like you want the query to re-run on the skuid model after you activated the condition,
    //but that won't work. doQuery is a read-only attribute (http://help.skuidify.com/m/11720/l/205447-skuid-model-model)
    //Use EventCodes.updateData() instead to have the model update with the condition set
    
    //Goutham: Removed doQuery and we are already using EventCodes.updateData() in line no 161 below.
    // We are updating condition value only whenever Event code lookup value changed 
    var dt = new Date();
    if(parseInt(row.FiscalYear__c)<dt.getFullYear() && eventId == null){
        isOtherError = true;
        addErrorMessage(editor,'Fiscal Year can not be previous years.');
    }
    var startDate = row.StartDate__c === undefined ? null : row.StartDate__c;
    var endDate = row.EndDate__c === undefined ? null : row.EndDate__c;
    console.log('$$row.StartDate__c'+row.StartDate__c);
    var dtStartDate = $(".StartDate__c input").val();
    dtStartDate = dtStartDate === undefined ? null : dtStartDate;
    var dtEndDate = $(".EndDate__c input").val();
    dtEndDate = dtEndDate === undefined ? null : dtEndDate;
    if(dtStartDate != null &&  dtStartDate != '' && isDate(dtStartDate) == false){
        isOtherError = true;
        addErrorMessage(editor,'Please enter valid start Date/Time ');
    }
    if(dtEndDate != null &&  dtEndDate != '' && isDate(dtEndDate) == false){
        isOtherError = true;
        addErrorMessage(editor,'Please enter valid end Date/Time ');  
    }      		
               
    
    if (isOtherError == false && startDate != null && endDate != null &&  (Date.parse(startDate) > Date.parse(endDate))) {
        addErrorMessage(editor,'Event End Date/Time can not be before start date/Time.');
        isOtherError = true;
    }
    if(($(".LeadStaffEmail__c input").val() == undefined || $(".LeadStaffEmail__c input").val() =='') && (row.StaffUserId__c != undefined && row.StaffUserId__c !='')){
        addErrorMessage(editor,'Lead Staff value is required.');
		isOtherError = true;
    }
    //JG: It looks like you're unblocking the UI if isOtherError = true? Wouldn't you want to block if the UI if isOtherError = true?
    // Goutham : If OtherError == false then we are unblock UI From Button Action that we define on "Save" button on skuid page.
    if(!requiredFieldsEntered || isOtherError) {$.unblockUI(); return false;}
    // reload data in CostCenters data model
    EventCodes.updateData(function() {

       if(skuid.model.getModel("EventCodes").getRows().length>0 && eventId == null){
			console.log('Error duplicate Event Code');
          
            //JG: same here - I'd use skuid's API (like in the validateRequiredFields() function) to add messages to the page instead of injecting raw HTML
           // Goutham : Yes now we have used standard function for adding custom message
           addErrorMessage(editor,'Event with this Event Code already exists'); 
            dfd.reject('');
			$.unblockUI(); return false;

       }else{
           // Do save
           //JG: I've added comments to OdataExtension, but this seems like an excessive number of parameters
           //The JSON representation of the record (JSON.stringify(row)) should be able to handle pasing the majority of the data
		   
           
           // Goutham : Yes fixed that changes that you suggested.Please recheck OdataExtension class
			 
            row.StatusID__c = statusId;
           //JG: You already have the same logic in the OdataExtension class for state & timezone - don't repeat it here
           //And same thing here - this is way too many parameters to maintain. Let the serialized JSON object handle passing the data
           // Goutham : Now fixed that issue. Please recheck OdataExtension class
           
               OdataExtension.saveEvent(
				eventId,JSON.stringify(row),
				function(result, event) {
					console.log(event.status);
					if(event.type === 'exception') {
						console.log("exception");
						console.log(event);
                        dfd.reject('');
						return false;
					} else if(event.status) {
						console.log('Save successful: ' + result);
						console.log(changedRows);
                        dfd.resolve('');
					} else {
						console.log(event.message);
                        dfd.resolve('');
					}
				}
			);

       }

    });
	// Return the Deferred's Promise
	return dfd.promise();
});

skuid.snippet.registerSnippet('save.EventAttribute', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;
console.log(row);
    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {return false;}

    var eventAttributeId = row.EventAttributeID__c === undefined ? null : row.EventAttributeID__c,
        eventId = skuid.model.getModel('Event').getFirstRow().EventID__c;
    OdataExtension.saveEventAttribute(
        eventAttributeId,
        eventId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Event attribute save successful for ' + row.Id);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('save.EventRole', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;
	row.RoleID__c = $(".RoleSelectList select").val();
    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {
		$.unblockUI();
		return false;
	}
	var Statuses = skuid.model.getModel('Statuses');
    var isOtherError = false;
    var statusId ='';
    if(Statuses.getRows().length ==0){
       	isOtherError = true;
        addErrorMessage(editor,'Active Status Record Not found in Statuses external object');
		$.unblockUI();
		return false;
    }else{
        row.StatusID__c = Statuses.getFirstRow().ExternalId;
    }
    var eventRole = row.EventRoleID__c === undefined ? null : row.EventRoleID__c;
    eventId = skuid.model.getModel('Event').getFirstRow().EventID__c;
	
	console.log($(".RoleSelectList select").val());
    OdataExtension.saveEventRole(
        eventRole,
        eventId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Event Role save successful for ' + row.Id);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('delete.EventType', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {
		$.unblockUI();
		return false;
	}
	var DeleteStatuses = skuid.model.getModel('DeleteStatuses');
     var isOtherError = false;
     var statusId = '';
     if (DeleteStatuses.getRows().length == 0) {
         isOtherError = true;
         $.unblockUI();
         editor.handleMessages(
               [
                   {
                      message: 'Delete Status Record Not found in Statuses external object',
                      severity: 'ERROR'
                   }
               ]
        );
        
     } else {
        row.StatusID__c = DeleteStatuses.getFirstRow().ExternalId;
    }
    var eventTypeId = row.EventTypeID__c === undefined ? null : row.EventTypeID__c;
    OdataExtension.saveEventType(
        eventTypeId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Event type save successful for ' + row.Id);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('delete.Role', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {
		$.unblockUI();
		return false;
	}
	var DeleteStatuses = skuid.model.getModel('DeleteStatuses');
     var isOtherError = false;
     var statusId = '';
     if (DeleteStatuses.getRows().length == 0) {
         isOtherError = true;
         $.unblockUI();
         editor.handleMessages(
               [
                   {
                      message: 'Delete Status Record Not found in Statuses external object',
                      severity: 'ERROR'
                   }
               ]
        );
        
     } else {
        row.StatusID__c = DeleteStatuses.getFirstRow().ExternalId;
    }
    var roleId = row.RoleID__c === undefined ? null : row.RoleID__c;
    OdataExtension.saveRole(
        roleId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Event type save successful for ' + row.Id);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('delete.EventRole', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {
		$.unblockUI();
		return false;
	}
	var DeleteStatuses = skuid.model.getModel('DeleteStatuses');
     var isOtherError = false;
     var statusId = '';
     if (DeleteStatuses.getRows().length == 0) {
         isOtherError = true;
         $.unblockUI();
         editor.handleMessages(
               [
                   {
                      message: 'Delete Status Record Not found in Statuses external object',
                      severity: 'ERROR'
                   }
               ]
        );
        
     } else {
        row.StatusID__c = DeleteStatuses.getFirstRow().ExternalId;
    }
    var eventRoleId = row.EventRoleID__c === undefined ? null : row.EventRoleID__c;
    eventId = skuid.model.getModel('Event').getFirstRow().EventID__c;
    OdataExtension.saveEventRole(
        eventRoleId,
        eventId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Event Role save successful for ' + row.Id);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('delete.Attribute', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {
		$.unblockUI();
		return false;
	}
	var DeleteStatuses = skuid.model.getModel('DeleteStatuses');
     var isOtherError = false;
     var statusId = '';
     if (DeleteStatuses.getRows().length == 0) {
         isOtherError = true;
         $.unblockUI();
         editor.handleMessages(
               [
                   {
                      message: 'Delete Status Record Not found in Statuses external object',
                      severity: 'ERROR'
                   }
               ]
        );
        
     } else {
        row.StatusID__c = DeleteStatuses.getFirstRow().ExternalId;
    }
    var attributeId = row.AttributeID__c === undefined ? null : row.AttributeID__c;
    OdataExtension.saveAttribute(
         attributeId,
         JSON.stringify(row),
         function(result, event) {
        	console.log(event.status);
        	if(event.type === 'exception') {
           	 console.log("exception");
            	console.log(event);
      	  } else if(event.status) {
           	 console.log('Save successful for ' + event.status);
       	  } else {
           	 console.log(event.message);
          }
        }
    );
});

skuid.snippet.registerSnippet('save.EventTypes', function() {
    var params = arguments[0],
        list = params.list,
        eventTypes = skuid.model.getModel('EventTypes'),
        $ = skuid.$;

    $.each(eventTypes.data,function(i,row){
        var index = changedRows.indexOf(row.Id);
        if(index === -1) {return true;}

        var eventTypeId = row.EventTypeID__c === undefined ? null : row.EventTypeID__c;

        OdataExtension.saveEventType(
            eventTypeId,
            JSON.stringify(row),
            function(result, event) {
                console.log(event.status);
                if(event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
                } else if(event.status) {
                    console.log('Event type save successful: ' + result + ' for ' + row.Id);
                    changedRows.splice(index, 1);
                    console.log(changedRows);
                } else {
                    console.log(event.message);
                }
            }
        );
    });
});

skuid.snippet.registerSnippet('save.EventTypeAttribute', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

     var requiredFieldsEntered = validateRequiredFields(model, editor);
     if(!requiredFieldsEntered) {
		    $.unblockUI();
		   return false;
	 }
     var Statuses = skuid.model.getModel('Statuses');
     var isOtherError = false;
     var statusId ='';
     if(Statuses.getRows().length ==0){
        	isOtherError = true;
            addErrorMessage(editor,'Active Status Record Not found in Statuses external object');
		    $.unblockUI();
		    return false;
     }else{
        row.StatusID__c = Statuses.getFirstRow().ExternalId;
     }
    var eventTypeAttributeId = row.EventTypeAttributeID__c === undefined ? null : row.EventTypeAttributeID__c,
    eventTypeId = skuid.model.getModel('EventType').getFirstRow().EventTypeID__c;
    console.log ('EventTypeAttributeID while editing' +row.EventTypeAttributeID__c);
    OdataExtension.saveEventTypeAttribute(
        eventTypeAttributeId,
        eventTypeId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Save successful for ' + event.status);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('save.RoleAttribute', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

     var requiredFieldsEntered = validateRequiredFields(model, editor);
     if(!requiredFieldsEntered) {
		    $.unblockUI();
		   return false;
	 }
     var Statuses = skuid.model.getModel('Statuses');
     var isOtherError = false;
     var statusId ='';
     if(Statuses.getRows().length ==0){
        	isOtherError = true;
            addErrorMessage(editor,'Active Status Record Not found in Statuses external object');
		    $.unblockUI();
		    return false;
     }else{
        row.StatusID__c = Statuses.getFirstRow().ExternalId;
     }
    var roleAttributeId = row.RoleAttributeID__c === undefined ? null : row.RoleAttributeID__c,
    roleId = skuid.model.getModel('Role').getFirstRow().RoleID__c;
    OdataExtension.saveRoleAttribute(
        roleAttributeId,
        roleId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Save successful for ' + event.status);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('save.RoleTypeAttribute', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {return false;}

    var roleTypeAttributeID = row.RoleTypeAttributeID__c === undefined ? null : row.RoleTypeAttributeID__c,
        attributeID = row.AttributeID__c,
        roleTypeID = row.RoleTypeID__c;
        /*attributeID = skuid.model.getModel('Attributes').getFirstRow().AttributeID__c,
		roleTypeID = skuid.model.getModel('RoleTypes').getFirstRow().RoleTypeID__c;*/
console.log(row);
    OdataExtension.saveRoleTypeAttribute(
        roleTypeAttributeID,
        attributeID,
		roleTypeID,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Save successful for ' + event.status);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('save.EventConstituent', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {return false;}

    var eventConstituentID = row.EventConstituentID__c === undefined ? null : row.EventConstituentID__c,
        eventID = skuid.model.getModel('Event').getFirstRow().EventID__c;
    OdataExtension.saveEventConstituent(
        eventConstituentID,
        eventID,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Save successful for ' + event.status);
            } else {
                console.log(event.message);
            }
        }
    );
});

skuid.snippet.registerSnippet('validation.CustomEventValdiation', function() {
    var params = arguments[0],
     model = params.model,
     editor = params.component.element.editor,
     row = params.row,
     $ = skuid.$;
	function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
	var eventId = row.EventID__c === undefined ? null : row.EventID__c; 
	
	var isOtherError = false;
	 var statusId = '';
	 var errMsg = 'Required Fields have no Value '
	 if ($(".EventName__c input").val() == undefined || $(".EventName__c input").val() == '') {
		 isOtherError = true;
		 errMsg += ' [Event Name]';
	 }
	/* if ($(".EventDescription__c textarea").val() == undefined || $(".EventDescription__c textarea").val() == '') {
		 
		 if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Event Description]';
	 } */
	 if ($(".FiscalYear__c input").val() == undefined || $(".FiscalYear__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Fiscal Year]';
	 }
	 if ($(".regionSelectList select").val() == undefined || $(".regionSelectList select ").val() == '') {
		 if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Region Code]';
	 }
	 if ($(".costCenterSelectList select").val() == undefined || $(".costCenterSelectList select ").val() == '') {
		 if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Regional Office]';
	 }
	 if ($(".EventTimeZoneID__c select").val() == undefined || $(".EventTimeZoneID__c select").val() == '') {
		if(isOtherError)
			errMsg+= ', ';	
		isOtherError = true;
		 errMsg += ' [Event Time Zone]';
	 }
	 
	 console.log('$$$'+$(".StaffUserId__c input").val());
	 if ($(".LeadStaffEmail__c input").val() == undefined || $(".LeadStaffEmail__c input").val() == '' || $(".StaffUserId__c input").val() == undefined || $(".StaffUserId__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		isOtherError = true;
		errMsg += ' [Lead Staff]';
	 }
	 $(".nx-messages .nx-error").remove();
	 if(isOtherError)
		addErrorMessage(editor,errMsg);
	return isOtherError ? false:true;
});

skuid.snippet.registerSnippet('validation.CustomRoleTypeValidation', function() {
    var params = arguments[0],
     model = params.model,
     editor = params.component.element.editor,
     row = params.row,
     $ = skuid.$;
	function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
	var roleTypeId = row.RoleTypeID__c === undefined ? null : row.RoleTypeID__c;
    var isOtherError = false;
    var statusId = '';
	var errMsg = 'Required Fields have no Value '
     if ($(".RoleTypeDescription__c input").val() == undefined || $(".RoleTypeDescription__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Role Type Description]';
	 }
	 $(".nx-messages .nx-error").remove();
	 if(isOtherError)
		addErrorMessage(editor,errMsg);
	return isOtherError ? false:true;
});

skuid.snippet.registerSnippet('validation.CustomAttributeValidation', function() {
    var params = arguments[0],
     model = params.model,
     editor = params.component.element.editor,
     row = params.row,
     $ = skuid.$;
	function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
	var attributeId = row.AttributeID__c === undefined ? null : row.AttributeID__c;
    var isOtherError = false;
    var statusId = '';
	var errMsg = 'Required Fields have no Value '
     /* if ($(".AttributeName__c input").val() == undefined || $(".AttributeName__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Attribute Name]';
	 } */
	 if ($(".AttributeDescription__c textarea").val() == undefined || $(".AttributeDescription__c textarea").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Attribute Description]';
	 }
	 /* if ($(".AttributeDataTypeID__c select").val() == undefined || $(".AttributeDataTypeID__c select").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Attribute Data Type]';
	 } */
	 $(".nx-messages .nx-error").remove();
	 if(isOtherError)
		addErrorMessage(editor,errMsg);
	return isOtherError ? false:true;
});

skuid.snippet.registerSnippet('validation.CustomRoleTypeValidation', function() {
    var params = arguments[0],
     model = params.model,
     editor = params.component.element.editor,
     row = params.row,
     $ = skuid.$;
	function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
	var roleTypeId = row.RoleTypeID__c === undefined ? null : row.RoleTypeID__c;
    var isOtherError = false;
    var statusId = '';
	var errMsg = 'Required Fields have no Value '
      if ($(".RoleTypeDescription__c input").val() == undefined || $(".RoleTypeDescription__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Role Type Description]';
	 } 
	 $(".nx-messages .nx-error").remove();
	 if(isOtherError)
		addErrorMessage(editor,errMsg);
	return isOtherError ? false:true;
});

skuid.snippet.registerSnippet('validation.CustomEventTypeValidation', function() {
     var params = arguments[0],
     model = params.model,
     editor = params.component.element.editor,
     row = params.row,
     $ = skuid.$;
	 function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
	var eventTypeId = row.EventTypeID__c === undefined ? null : row.EventTypeID__c;
    var isOtherError = false;
    var statusId = '';
	var errMsg = 'Required Fields have no Value '
     if ($(".EventTypeName__c input").val() == undefined || $(".EventTypeName__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Event Type]';
	 }
	 if ($(".EventProgramID__c select").val() == undefined || $(".EventProgramID__c select").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Event Program]';
	 }
	 $(".nx-messages .nx-error").remove();
	 if(isOtherError)
		addErrorMessage(editor,errMsg);
	return isOtherError ? false:true;
});

skuid.snippet.registerSnippet('validation.CustomRoleValidation', function() {
     var params = arguments[0],
     model = params.model,
     editor = params.component.element.editor,
     row = params.row,
     $ = skuid.$;
	 function addErrorMessage(editor,msg){
        editor.handleMessages(
               [
                   {
                      message: msg,
                      severity: 'ERROR'
                   }
               ]
        );
    }
	var roleId = row.RoleID__c === undefined ? null : row.RoleID__c;
    var isOtherError = false;
    var statusId = '';
	var errMsg = 'Required Fields have no Value '
      /*if ($(".RoleName__c input").val() == undefined || $(".RoleName__c input").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Role Name]';
	 } */
	 if ($(".RoleDescription__c textarea").val() == undefined || $(".RoleDescription__c textarea").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Role Description]';
	 }
    /*if ($(".RoleTypeID__c select").val() == undefined || $(".RoleTypeID__c select").val() == '') {
		if(isOtherError)
			errMsg+= ', ';
		 isOtherError = true;
		 errMsg += ' [Role Type]';
	 } */
	 $(".nx-messages .nx-error").remove();
	 if(isOtherError)
		addErrorMessage(editor,errMsg);
	return isOtherError ? false:true;
}); 

skuid.snippet.registerSnippet('save.EventConstituentRoleAttribute', function() {
    var params = arguments[0],
        model = params.model,
        editor = params.component.element.editor,
        row = params.row,
        $ = skuid.$;

    var requiredFieldsEntered = validateRequiredFields(model, editor);
    if(!requiredFieldsEntered) {return false;}

    var eventConstituentRoleAttributeID = row.EventConstituentRoleAttributeID__c === undefined ? null : row.EventConstituentRoleAttributeID__c,
        eventConstituentRoleID = skuid.model.getModel('EventConstituentRole').getFirstRow().EventConstituentRoleID__c;
		roleTypeAttributeID = skuid.model.getModel('RoleTypeAttribute').getFirstRow().RoleTypeAttributeID__c;
    OdataExtension.saveEventConstituentRoleAttribute(
        eventConstituentRoleAttributeID,
        eventConstituentRoleID,
		roleTypeAttributeID,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Save successful for ' + event.status);
            } else {
                console.log(event.message);
            }
        }
    );
});
/*END : Added by Goutham*/
/***Skuid snippets for deleting the various external objects***/
skuid.snippet.registerSnippet('delete.Event', function() {
    var params = arguments[0],
    row = params.row,
    $ = skuid.$;

    var eventId = row.EventID__c === undefined ? null : row.EventID__c;
    OdataExtension.deleteEvent(
        eventId,
        JSON.stringify(row),
        function(result, event) {
            console.log(event.status);
            if(event.type === 'exception') {
                console.log("exception");
                console.log(event);
            } else if(event.status) {
                console.log('Event delete successful: ' + result);
            } else {
                console.log(event.message);
            }
        }
    );
});

/***General purpose renderer snippets - mostly to circumvent the fact that external objects are read-only***/
skuid.snippet.registerSnippet('renderer.editReadOnly', function(field,value) {
    var $ = skuid.$,
	field = arguments[0],
	cellElem = field.element,
	value = skuid.utils.decodeHTML(arguments[1]);

    cellElem.change(function(newValue) {
        changedRows.push(field.row.Id);
        //field.model.updateRow(field.row, field, newValue);
    })

    skuid.ui.fieldRenderers[field.metadata.displaytype].edit(field,value);
    if(field.required) {
    	cellElem.addClass('requiredField');
    }
    return;
});

skuid.snippet.registerSnippet('renderer.LeadStaffEdit', function(field,value) {
    
var $ = skuid.$,
	field = arguments[0],
	cellElem = field.element,
	value = skuid.utils.decodeHTML(arguments[1]);

    cellElem.change(function(newValue) {
        changedRows.push(field.row.Id);
        //field.model.updateRow(field.row, field, newValue);
    })

    skuid.ui.fieldRenderers[field.metadata.displaytype].edit(field,value);
    if(field.required) {
    	cellElem.addClass('requiredField');
    }
    cellElem.addClass('mytext');
    cellElem.attr('id','mytext');
    //JG: is this to make the field act like a lookup? 
    //Goutham : yes to make lead staff as  a lookup field
    var btnHtml = '<div id="chooseLeadStaffIcon" on class="ui-icon ui-icon-search nx-field-reference-search" style="cursor: pointer;" ></div>';

    field.element.append(btnHtml);
    

	setTimeout(function(){ 
		skuid.$( ".nx-field #chooseLeadStaffIcon" ).on('click',function() {  
			$(".LeadStaffEmail__c input").val('');
			var context = {

			}; 
            //JG: any reason you're dynamically creating the popup component in JS instead of through the skuid UI/action framework?
			var popupXMLString1 =


				'<popup width="50%" title="Lead Staff Result">'


			+'<components>'


			+ '<pagetitle model="LeadStaffResult">'


			+ '<maintitle>Search Result: ' + '</maintitle>'


			+ '<actions>'

			+ '</actions>'


			+ '</pagetitle>' + '<basicfieldeditor uniqueid="leadStaffSearchEditor" showheader="false" showsavecancel="false" model="Event" buttonposition="" mode="read" layout=""><columns><column width="50%"><sections><section title=""><fields><field id="City__c" valuehalign="" type="CUSTOM" snippet="LeadStaffCustom"/></fields></section></sections></column></columns></basicfieldeditor>' + '<skootable showconditions="true" showsavecancel="false" searchmethod="server" searchbox="false" showexportbuttons="false" pagesize="10" createrecords="false" model="LeadStaffResult" buttonposition="" mode="read"><fields><field id="FirstName" ><label>Lead Staff</label></field><field id="Title" ><label>Username</label></field></fields><rowactions><action type="custom" label="Select Row and Close PopUp" icon="sk-icon-magic" snippet="closepopup"/></rowactions><views><view type="standard"/></views></skootable>'


			+ '</components>'


			+ '</popup>';

			var popupXML = skuid.utils.makeXMLDoc(popupXMLString1);
			var popup = skuid.utils.createPopupFromPopupXML(popupXML, context);
		});
		if(field.required)	
			cellElem.addClass('requiredField');
	}, 200);
	
});
skuid.snippet.registerSnippet('renderer.NumberToText', function(field,value) {
    //JG: If you're just using this snippet to render a number field as read-only text, you can cut out most of the logic below.
    // Goutham: Made the changes
    var $ = skuid.$,
	field = arguments[0],
	cellElem = field.element,
	value = skuid.utils.decodeHTML(arguments[1]);
    skuid.ui.fieldRenderers['TEXT'].read(field,value);
    if(field.required) {
    	cellElem.addClass('requiredField');
    }
    return;
});


skuid.snippet.registerSnippet('renderer.editReadOnly.Boolean', function(field,value) {
    var $ = skuid.$,
	field = arguments[0],
	cellElem = field.element,
	value = arguments[1];

    cellElem.change(function(newValue) {
        changedRows.push(field.row.Id);
        //field.model.updateRow(field.row, field, newValue);
    })

    skuid.ui.fieldRenderers.BOOLEAN.edit(field,value);
    return;
});

skuid.snippet.registerSnippet('renderer.editReadOnly.TextArea', function(field,value) {
    var $ = skuid.$,
	field = arguments[0],
	cellElem = field.element,
	value = skuid.utils.decodeHTML(arguments[1]);

    cellElem.change(function(newValue) {
        changedRows.push(field.row.Id);
        //field.model.updateRow(field.row, field, newValue);
    })
    skuid.ui.fieldRenderers.TEXTAREA.edit(field,value);
	console.log(field.element);
	console.log('field'+field.required);
    if(field.required != undefined && field.required) {
    	cellElem.addClass('requiredField');
    }
    return;
});

/***Object-specific renderer snippets - these handle rendering specific fields based on certain model names***/
skuid.snippet.registerSnippet('renderer.Attribute.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var attributes = [];
    attributes.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });

    skuid.$.each(skuid.model.getModel('Attributes').getRows(), function(i,row) {
        attributes.push({
            active: true
            ,defaultValue: false
            ,label : row.AttributeName__c
            ,value : row.AttributeID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : attributes,
        required : field.required,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }

        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    if(field.required) {
        field.element.append(customSelect).addClass('requiredField');
    } else {
        field.element.append(customSelect);
    }
});
skuid.snippet.registerSnippet('renderer.Attribute.readOnly', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var attributeName;
    skuid.$.each(skuid.model.getModel('Attributes').getRows(), function(i,row) {
        if(row.AttributeID__c === value) {
            attributeName = row.AttributeName__c;
        }
    });

    skuid.ui.fieldRenderers[field.metadata.displaytype].read(field,attributeName);
    return;
});

skuid.snippet.registerSnippet('renderer.DataType.readOnly', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var dataTypeName;
    skuid.$.each(skuid.model.getModel('DataTypes').getRows(), function(i,row) {
        if(row.DataTypeID__c === value) {
            dataTypeName = row.DataTypeName__c;
        }
    });

    skuid.ui.fieldRenderers[field.metadata.displaytype].read(field,dataTypeName);
    return;
});

skuid.snippet.registerSnippet('renderer.EventTypeAttribute.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var eventTypeAttributes = [];
    eventTypeAttributes.push({
        active: true
       ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });

    skuid.$.each(skuid.model.getModel('EventTypeAttributes').getRows(), function(i,row) {
        eventTypeAttributes.push({
            active: true
            ,defaultValue: false
            ,label : row.AttributeID__r.AttributeName__c
            ,value : row.EventTypeAttributeID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : eventTypeAttributes,
        required : true,
        value : value
    }).change(function(newValue) {

        var selectedOption = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOption += newValue.target.selectedOptions[i].value;
        }

        //Update the row in the target object
        changedRows.push(field.row.Id);
        field.row[field.id] = selectedOption;
        //field.model.updateRow(field.row, field, selectedOption);

        if(selectedOption) {
            console.log('selectedOption=' + selectedOption);
            
            //Query the selected event type attribute so we can get the attribute ID
            var selectedEventTypeAttribute = skuid.model.getModel('SelectedEventTypeAttribute'),
            	condition = selectedEventTypeAttribute.getConditionByName('EventTypeAttributeID');
            selectedEventTypeAttribute.emptyData();
            selectedEventTypeAttribute.activateCondition(condition);
        	selectedEventTypeAttribute.setCondition(condition, selectedOption);
            selectedEventTypeAttribute.updateData(function() {
                //Callback function to make sure the selectedEventTypeAttribute model has been queried
                //Query the enums for the relevant attribute using the
                console.log(selectedEventTypeAttribute);
                console.log(selectedEventTypeAttribute.getFirstRow().AttributeID__c);
                /*var enums = skuid.$M('AttributeEnums'),
                	condition = enums.getConditionByName('AttributeID');
                enums.emptyData();                
                enums.setCondition(condition, selectedEventTypeAttribute.getFirstRow().AttributeID__c);      
                enums.activateCondition(condition);*/
                //enums.updateData();
                $('.eventAttributeValue').css('display', 'block');
            });            
        } else {
            $('.eventAttributeValue').css('display', 'none');
        }
    })
    //Append the picklist to the DOM element
    field.element.append(customSelect).addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.EventTypeAttributeValue.edit', function (field, value) {
    var field = arguments[0],
		value = skuid.utils.decodeHTML(arguments[1]),
        selectedEventTypeAttribute = skuid.model.getModel('SelectedEventTypeAttribute'),
        dataType = selectedEventTypeAttribute.getFirstRow().AttributeID__r.AttributeDataTypeID__r.DataTypeName__c,
        enums = skuid.model.getModel('AttributeEnums'),
		$ = skuid.$;

    console.log(enums.data);
	//console.log('Attribute data type=' + dataType);
	//var enums = skuid.model.getModel('AttributeEnums'),
    var condition = enums.getConditionByName('AttributeID');
    enums.emptyData();
    enums.setCondition(condition, selectedEventTypeAttribute.data[0].AttributeID__c); //selectedEventTypeAttribute.data[0].AttributeID__c);
    enums.activateCondition(condition);
    enums.updateData(function() {
        console.log('enums');
        console.log(enums);
        console.log(enums.data);
        console.log(enums.data.length);
        if(enums.data.length) {
            field.metadata.picklistEntries = [];
          /*  
            field.metadata.picklistEntries.push({
                active: true
                ,defaultValue: true
                ,label : '--None--'
                ,value : ''
            });
           */ 
            $.each(enums.data, function(i,row) {
                console.log(row);
                field.metadata.picklistEntries.push(
                    { value: row.Value__c, label: row.Value__c, defaultValue: false, active: true }
                );
            });
            skuid.ui.fieldRenderers.PICKLIST.edit(field,value);
            if(field.required) {
                field.element.addClass('requiredField');
            }
            return;
        } else {
            switch(dataType) {
                case 'DateTime':
                    skuid.ui.fieldRenderers.DATETIME.edit(field,value);
                    if(field.required) {
                        field.element.addClass('requiredField');
                    }
                    return;
                case 'Number':
                    skuid.ui.fieldRenderers.INTEGER.edit(field,value);
                    if(field.required) {
                        field.element.addClass('requiredField');
                    }
                    return;
                default:
                    skuid.ui.fieldRenderers.TEXTAREA.edit(field,value);
                    if(field.required) {
                        field.element.addClass('requiredField');
                    }
                    return;
            }
        }
    });   
    
});

skuid.snippet.registerSnippet('renderer.EventTypeAttributeValue.readOnly', function(field, value) {
    var field = arguments[0],
		value = skuid.utils.decodeHTML(arguments[1]),
        selectedAttribute = skuid.model.getModel('SelectedEventTypeAttribute'),
        dataType = field.row.EventTypeAttributeID__r.AttributeID__r.AttributeDataTypeID__r.DataTypeName__c,
        
		$ = skuid.$;         
    switch(dataType) {
        case 'DateTime':
            skuid.ui.fieldRenderers.DATETIME.readonly(field,value);
            return;
        case 'Number':
            skuid.ui.fieldRenderers.INTEGER.readonly(field,value);
            return;
        default:
            skuid.ui.fieldRenderers.TEXTAREA.readonly(field,value);
            return;
    }
});

skuid.snippet.registerSnippet('renderer.EventTypeAttributeValueTest.readOnly', function(field, value) {
    var field = arguments[0],
		value = skuid.utils.decodeHTML(arguments[1]),
        selectedAttribute = skuid.model.getModel('SelectedEventTypeAttribute'),
        dataType = field.row.DataTypeName__c,
        
		$ = skuid.$;         
    switch(dataType) {
        case 'DateTime':
            skuid.ui.fieldRenderers.DATETIME.readonly(field,value);
            return;
        case 'Number':
            skuid.ui.fieldRenderers.INTEGER.readonly(field,value);
            return;
        default:
            skuid.ui.fieldRenderers.TEXTAREA.readonly(field,value);
            return;
    }
});

skuid.snippet.registerSnippet('renderer.EventConstituent.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var eventConstituent = [];
    eventConstituent.push({
        active: true
       ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });

	skuid.$.each(skuid.model.getModel('EventConstituents').getRows(), function(i,row) {
        eventConstituent.push({
            active: true
            ,defaultValue: false
            ,label : row.EventConstituentID__c
            ,value : row.EventConstituentID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : eventConstituent,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }

        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    field.element.append(customSelect).addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.EventType.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var eventTypes = [];
    eventTypes.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });

    skuid.$.each(skuid.model.getModel('EventTypes').getRows(), function(i,row) {
        eventTypes.push({
            active: true
            ,defaultValue: false
            ,label : row.EventTypeName__c
            ,value : row.EventTypeID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : eventTypes,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    field.element.append(customSelect).addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.RegionalOffices.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var CostCenters = [];
    CostCenters.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });

    skuid.$.each(skuid.model.getModel('CostCenters').getRows(), function(i,row) {
        CostCenters.push({
            active: true
            ,defaultValue: false
            ,label : row.CostCenterDescription__c
            ,value : row.CostCenterID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : CostCenters,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    field.element.append(customSelect).addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.EventType.readOnly', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var eventTypeName;

    skuid.$.each(skuid.model.getModel('EventTypes').getRows(), function(i,row) {
        if(row.EventTypeID__c === field.row.EventTypeID__c) {
            eventTypeName = row.EventTypeName__c;
        }
    });

    skuid.ui.fieldRenderers[field.metadata.displaytype].read(field,eventTypeName);
    return;
});

/***Functions that are called by skuid snippets***/
function detectUnsavedChanges() {
    window.onbeforeunload = function() {
        if(changedRows.length > 0){
            return "You have unsaved changes.";
        }
    }
}

function validateRequiredFields(model, editor) {
    //http://help.skuidify.com/m/11720/l/218340-wizard-component-custom-button-actions
    var $ = skuid.$,
        requiredFields = {},
        messages = [];

    editor.clearMessages();

    /*Loop through any editors on the page and figure out which fields have been marked as required*/
    $.each(model.registeredLists,function(i,list){
          //requiredFields = list.requiredFields;
          var listMessages = list.validateRequiredFields();
           if(listMessages && listMessages.length) {
               $.each(listMessages,function(){
                  messages.push(this);
               });
           }
    });



    //If we have warning messages, do NOT proceed
    if (messages.length) {
        //Have our editor handle the messages
        editor.handleMessages(messages);
        return false;
    }

    return true;
}

/* Added by Goutham*/
skuid.snippet.registerSnippet('renderer.Region.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;
    var regions = [];
    regions.push({
        active: true
       ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('Regions').getRows(), function(i,row) {
        regions.push({
            active: true
            ,defaultValue: false
            ,label : row.RegionCode__c
            ,value : row.RegionID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : regions,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
	field.element.append(customSelect)
	if(field.required)
		field.element.addClass('requiredField');
    
});

skuid.snippet.registerSnippet('renderer.State.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var states = [];
    states.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('States').getRows(), function(i,row) {
        states.push({
            active: true
            ,defaultValue: false
            ,label : row.StateCode__c + ' ('+ row.StateDescription__c+')'
            ,value : row.StateID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : states,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
	field.element.append(customSelect);
	if(field.required)
		field.element.addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.Country.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var Countries = [];
    Countries.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('Countries').getRows(), function(i,row) {
        Countries.push({
            active: true
            ,defaultValue: false
            ,label : row.CountryName__c + ' ('+ row.CountryCode__c+')'
            ,value : row.CountryID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : Countries,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
	field.element.append(customSelect);
	if(field.required)
		field.element.addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.TimeZone.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var timezones = [];
    timezones.push({
        active: true
       ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('TimeZones').getRows(), function(i,row) {
        timezones.push({
            active: true
            ,defaultValue: false
            ,label : row.TimeZone1__c
            ,value : row.TimeZoneID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : timezones,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    field.element.append(customSelect);
	if(field.required)
		field.element.addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.RoleTypeAttribute.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var roletypeattributes = [];
    roletypeattributes.push({
        active: true
       ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('RoleTypeAttributes').getRows(), function(i,row) {
        roletypeattributes.push({
            active: true
            ,defaultValue: false
            ,label : row.RoleTypeAttributeID__c
            ,value : row.RoleTypeAttributeID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : roletypeattributes,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    field.element.append(customSelect).addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.Event.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var events = [];
    events.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('Events').getRows(), function(i,row) {
        events.push({
            active: true
            ,defaultValue: false
            ,label : row.EventName__c
            ,value : row.EventID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : events,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    field.element.append(customSelect).addClass('requiredField');
});

skuid.snippet.registerSnippet('renderer.RoleType.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var roletypes = [];
    roletypes.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('RoleTypes').getRows(), function(i,row) {
        roletypes.push({
            active: true
            ,defaultValue: false
            ,label : row.RoleTypeName__c
            ,value : row.RoleTypeID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : roletypes,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    if(field.required) {
        field.element.append(customSelect).addClass('requiredField');
    } else {
        field.element.append(customSelect);
    }
});

skuid.snippet.registerSnippet('renderer.Role.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;

    var roles = [];
    roles.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('Roles').getRows(), function(i,row) {
        roles.push({
            active: true
            ,defaultValue: false
            ,label : row.RoleName__c
            ,value : row.RoleID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : roles,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
    if(field.required) {
        field.element.append(customSelect).addClass('requiredField');
    } else {
        field.element.append(customSelect);
    }
});

skuid.snippet.registerSnippet('renderer.EventProgram.edit', function(field, value) {
 	var field = arguments[0],
	value = skuid.utils.decodeHTML(arguments[1]),
	$ = skuid.$;
    var eventPrograms = [];
    eventPrograms.push({
        active: true
        ,defaultValue: false
        /*,label : 'Select...'
        ,value : ''*/
    });
	//JG: When possible, don't hardcode model names - use dynamic references like params.model instead
	//Goutham: We cant't dynamic reference here
    skuid.$.each(skuid.model.getModel('EventPrograms').getRows(), function(i,row) {
        eventPrograms.push({
            active: true
            ,defaultValue: false
            ,label : row.EventProgram1__c
            ,value : row.EventProgramID__c
        });
    });

    var customSelect = skuid.ui.renderers.PICKLIST.edit({
        entries : eventPrograms,
        required : true,
        value : value
    }).change(function(newValue) {
        var selectedOptions = '';
        for(i = 0; i < newValue.target.selectedOptions.length; i++) {
            //There will only be one selected option since it's rendered as a picklist
            //But I wrote this originally to do something similar with multiselects
            selectedOptions += newValue.target.selectedOptions[i].value;
        }
        console.log('selectedOptions=' + selectedOptions);
        //Update the row in the target object
        field.row[field.id] = selectedOptions;
        //field.model.updateRow(field.row, field, selectedOptions);
    })
    //Append the MULTIPICKLIST to the DOM element
	field.element.append(customSelect)
	if(field.required) 
		field.element.addClass('requiredField');
});
function test1(){
    alert('tes1');
     }
/* End by Goutham*/