global class ECCFlowC360Deceased implements Process.Plugin { 
	global Process.PluginResult invoke(Process.PluginRequest request) { 
	
		String consId = (String)request.inputParameters.get('ConstituentId'),
			consType = (String)request.inputParameters.get('ConstituentType'),
			deceasedDate = (String)request.inputParameters.get('DeceasedDate'),
			origDeceasedDate = '',
			res = '';
		Boolean deceased = (Boolean)request.inputParameters.get('Deceased'),
			deceasedChanged = false;
		Boolean origDeceased = false;

		if (consType == 'INDIVIDUAL') {
			domainSoapStjudeOrg.Constituent con = C360Util.getConstituent(null, consId, null);
			domainSoapStjudeOrg.IndividualAttributes ia = new domainSoapStjudeOrg.IndividualAttributes();

			origDeceased = con.IndividualAttributes.Deceased;
			origDeceasedDate = con.IndividualAttributes.DeceasedDate;
			
			if (deceased != origDeceased) {
				ia.Deceased = deceased;
				deceasedChanged = true;
				if (!origDeceased) {
					//ECCUtil.createDeceasedPrefs(consId);
				}
			}

			if (deceasedDate != origDeceasedDate) {
				ia.DeceasedDate = deceasedDate;
				deceasedChanged = true;
			}

			domainSoapStjudeOrg.Individual i = new domainSoapStjudeOrg.Individual();

			i.ConstituentID = consId;
			i.LastName = con.LastName;

			i.IndividualAttributes = ia;

			system.debug('deceased: ' + deceased + ', origDeceased: ' + origDeceased + ', deceasedDate: ' + deceasedDate +
				', origDeceasedDate: ' + origDeceasedDate + ', deceasedChanged: ' + deceasedChanged);
			if (deceasedChanged) {
				res = C360Util.EditConstituent(i);
			}
		}

		system.debug(
			'consId: ' + consId + '\n' + 
			'Deceased: ' + deceased + '\n' +
			'DeceasedDate: ' + deceased + '\n' );

	    return new Process.PluginResult('Success', null); 
	}

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'ECCFlowC360Deceased';
        result.Tag = 'c360';
        result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('ConstituentId', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
               , new Process.PluginDescribeResult.InputParameter('ConstituentType', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 
               , new Process.PluginDescribeResult.InputParameter('Deceased', 
               Process.PluginDescribeResult.ParameterType.Boolean, true) 
               , new Process.PluginDescribeResult.InputParameter('DeceasedDate', 
               Process.PluginDescribeResult.ParameterType.STRING, false) 
            }; 

        return result; 
    }
}