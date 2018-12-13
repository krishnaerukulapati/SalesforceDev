global class ECCFlowC360Interaction implements Process.Plugin { 
	global Process.PluginResult invoke(Process.PluginRequest request) { 
		domainSoapStjudeOrg.Interaction i = new domainSoapStjudeOrg.Interaction();

    i.ContactDate = DateTime.now().format('yyyy-MM-dd HH:mm:ss');
    i.Page_x = 1;
    i.ContactCategory = (String)request.inputParameters.get('ContactCategory');
    i.ContactType = (String)request.inputParameters.get('ContactType');

    i.ResponseCategory = (String)request.inputParameters.get('ResponseCategory');
    i.ResponseType = (String)request.inputParameters.get('ResponseType');
    i.Warning = (String)request.inputParameters.get('Warning');
    i.WarningExpirationDate = (String)request.inputParameters.get('WarningExpirationDate');
    i.LongComments = (String)request.inputParameters.get('LongComments');
    if (String.isNotEmpty((String)request.inputParameters.get('Technique'))) {
      i.TransactionSource = new domainSoapStjudeOrg.TransactionSource();
      i.TransactionSource.Technique = (String)request.inputParameters.get('Technique');
    }

    system.debug(
      'i.ContactDate = ' + i.ContactDate + 
      '\ni.Page_x = ' + i.Page_x + 
      '\ni.ContactCategory = ' + i.ContactCategory + 
      '\ni.ContactType = ' + i.ContactType +
      '\ni.TransactionSource.Technique = ' + i.TransactionSource.Technique + 
      '\ni.ResponseCategory = ' + i.ResponseCategory + 
      '\ni.ResponseType = ' + i.ResponseType + 
      '\ni.Warning = ' + i.Warning + 
      '\ni.WarningExpirationDate = ' + i.WarningExpirationDate + 
      '\ni.LongComments = ' + i.LongComments
    );

    String consId = (String)request.inputParameters.get('ConstituentId');
    try {
        System.debug('i = ' + i);
        C360Util.createInteraction(consId, i);
    }
    catch(CalloutException e) {
        System.debug('i DMS = ' + i);
        C360Util.createInteractionDMS(consId, i);
    }
    catch(Exception e) {
        system.debug('ECCFlowC360Interaction.save: createInteraction exception: ' + e.getMessage());
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'There was an error saving your interaction.'));
        return null;
    }

    return new Process.PluginResult('Success', null); 
	}

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'ECCFlowC360Interaction';
        result.Tag = 'c360';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('ContactCategory', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('ContactType', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('ConstituentId', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('Technique', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('ResponseCategory', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('ResponseType', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('Warning', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('WarningExpirationDate', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('LongComments', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            }; 

        return result; 
    }
}