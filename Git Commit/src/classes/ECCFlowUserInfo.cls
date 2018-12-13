global class ECCFlowUserInfo implements Process.Plugin { 
    global Process.PluginResult invoke(Process.PluginRequest request) { 
        Map<String,Object> result = new Map<String,Object>();

        result.put('UserId', UserInfo.getUserId());
        result.put('UserName', UserInfo.getUserName());
        result.put('UserEmail', UserInfo.getUserEmail());
        result.put('UserLastName', UserInfo.getLastName());
        result.put('UserFirstName', UserInfo.getFirstName());

        return new Process.PluginResult(result);
    }

    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'ECCFlowUserInfo';
        result.Tag = 'Salesforce';

        result.outputParameters = new 
           List<Process.PluginDescribeResult.OutPutParameter>{ 
                new Process.PluginDescribeResult.OutputParameter('UserId', 
                    Process.PluginDescribeResult.ParameterType.STRING),
                new Process.PluginDescribeResult.OutputParameter('UserName', 
                    Process.PluginDescribeResult.ParameterType.STRING),
                new Process.PluginDescribeResult.OutputParameter('UserEmail', 
                    Process.PluginDescribeResult.ParameterType.STRING),
                         new Process.PluginDescribeResult.OutputParameter('UserLastName', 
                    Process.PluginDescribeResult.ParameterType.STRING),
                new Process.PluginDescribeResult.OutputParameter('UserFirstName', 
                    Process.PluginDescribeResult.ParameterType.STRING)
            }; 

        return result; 
    }
}