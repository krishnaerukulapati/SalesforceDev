global class ECCFlowTAInfo implements Process.Plugin { 
   public domainSoapStjudeOrg.SystemXRef[] Xrefs {get; private set;}
     
   global Process.PluginResult invoke(Process.PluginRequest request) { 
    Map<String,Object> result = new Map<String,Object>();
     
     String taAccount;
     String consId;

    //  put result of taAccount  
    result.put('taAccount', taAccount);
    result.put('ConstituentId', consId);
    //  get ConstituentId value  ( variable from Flow = {!varCase.ConstituentId__c} )
    consId = (String)request.inputParameters.get('ConstituentId');
    system.debug('ConstituentId from Flow: ' +  consId);
    consId = (String)request.inputParameters.get('taAccount');
    system.debug('taAccount to Flow: ' +  taAccount);
                 
        
    //get sysName Info
    List<domainSoapStjudeOrg.SystemXRef> conXref = C360Util.getConstituentXRefs(consId, '');
     Xrefs = new List<domainSoapStjudeOrg.SystemXRef>();
   
      for(domainSoapStjudeOrg.SystemXRef xrCon : conXref) {
         if (xrCon.Sys != null && xrCon.Sys.Name != null) {
             if (xrCon.Sys.Name == 'TA') {
                 taAccount = 'true';
                  system.debug('True Value: ' +  taAccount);
                  }
                   else if (xrCon.Sys.Name == 'DMS') {
                            taAccount = 'false';
                            system.debug('False Value: ' +  taAccount);
                   }
                  }
          }
      

  return new Process.PluginResult(result);
    }


    // Returns the describe information for the interface
    global Process.PluginDescribeResult describe() { 
        Process.PluginDescribeResult result = new Process.PluginDescribeResult(); 
        result.Name = 'ECCFlowTAInfo';
        result.Tag = 'Salesforce';

          
            result.inputParameters = new 
           List<Process.PluginDescribeResult.InputParameter>{ 
               new Process.PluginDescribeResult.InputParameter('ConstituentId', 
               Process.PluginDescribeResult.ParameterType.STRING, true) 

           };

           result.outputParameters = new 
           List<Process.PluginDescribeResult.OutPutParameter>{ 
             new Process.PluginDescribeResult.OutputParameter('taAccount', 
                 Process.PluginDescribeResult.ParameterType.STRING)
          }; 


        return result; 
    }

      
}