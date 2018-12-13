global class ECCFlowC360Preference implements Process.Plugin { 
	global Process.PluginResult invoke(Process.PluginRequest request) { 
	
		String prefId = null,
      newPref = (String)request.inputParameters.get('Preference'),
      newPrefType = (String)request.inputParameters.get('PreferenceType'),
			consId = (String)request.inputParameters.get('ConstituentId');

    system.debug(
      'consId: ' + consId + '\n' + 
      'prefId: ' + prefId + '\n' +
      'newPref: ' + newPref + '\n' +
      'PreferenceValue: ' + (String)request.inputParameters.get('PreferenceValue') + '\n' +
      'PreferenceType: ' + (String)request.inputParameters.get('PreferenceType') + '\n' +
      'Programtype: ' + (String)request.inputParameters.get('ProgramType') + '\n' +
      'StartDate: ' + (DateTime)request.inputParameters.get('StartDate') + '\n' +
      'EndDate: ' + (DateTime)request.inputParameters.get('EndDate') + '\n' +
      'Comments: ' + (String)request.inputParameters.get('Comments') + '\n' +
      'Status: ' + (String)request.inputParameters.get('Status'));

		domainSoapStjudeOrg.Preference[] prefs = C360Util.getPreferences(consId);

    if (prefs != null) {
  		for(domainSoapStjudeOrg.Preference pref : prefs) {
  			if (pref.Preference == newPref && pref.PreferenceType == newPrefType) {
  				prefId = pref.PreferenceId;
  			}
  		}
    }

    system.debug(
      'consId: ' + consId + '\n' + 
      'prefId: ' + prefId + '\n' +
      'newPref: ' + newPref + '\n' +
      'PreferenceValue: ' + (String)request.inputParameters.get('PreferenceValue') + '\n' +
      'PreferenceType: ' + (String)request.inputParameters.get('PreferenceType') + '\n' +
      'Programtype: ' + (String)request.inputParameters.get('ProgramType') + '\n' +
      'StartDate: ' + (DateTime)request.inputParameters.get('StartDate') + '\n' +
      'EndDate: ' + (DateTime)request.inputParameters.get('EndDate') + '\n' +
      'Comments: ' + (String)request.inputParameters.get('Comments') + '\n' +
      'Status: ' + (String)request.inputParameters.get('Status'));

		C360Util.editPreference(
			consId, 
			prefId, 
			newPref,
			(String)request.inputParameters.get('PreferenceValue'),
			(String)request.inputParameters.get('PreferenceType'),
			(String)request.inputParameters.get('Programtype'),
			(DateTime)request.inputParameters.get('StartDate'), 
			(DateTime)request.inputParameters.get('EndDate'), 
			(String)request.inputParameters.get('Comments'), 
			(String)request.inputParameters.get('Status'));

	    return new Process.PluginResult('Success', null); 
	}

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'ECCFlowC360Interaction';
        result.Tag = 'c360';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('ConstituentId', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('Preference', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('PreferenceValue', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('PreferenceType', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('Status', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
            ,  new Process.PluginDescribeResult.InputParameter('ProgramType', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('StartDate', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('EndDate', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            ,  new Process.PluginDescribeResult.InputParameter('Comments', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            }; 

        return result; 
    }
}