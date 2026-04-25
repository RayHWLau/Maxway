global class AgentVerificationQuickActionController {
   
    @AuraEnabled
    public static String agentVerification(Id opId){
        
        List<Opportunity> oppList=[select Reference_Check_Sent__c from Opportunity 
                                   WHERE Id=:opId
                                   AND Reference_Verification_Submitted_Date__c = NULL
                                   AND StageName NOT IN ('Sales Won','Closed Lost')
                                  ];
        
        if(oppList.size()>0 && oppList!=NULL){
            oppList[0].Reference_Check_Sent__c=True;
            update oppList;
            return 'SUCCESS';
        }else{
            return NULL;
        }
    }
   
    
    webservice static String agentVerificationListButton(Id opId){
                List<Opportunity> oppList=[select Reference_Check_Sent__c from Opportunity 
                                   WHERE Id=:opId
                                   AND Reference_Verification_Submitted_Date__c = NULL 
                                   AND StageName NOT IN ('Sales Won','Closed Lost')];
        
        if(oppList.size()>0 && oppList!=NULL){
            oppList[0].Reference_Check_Sent__c=True;
            update oppList;
            return 'SUCCESS';
        }else{
            return NULL;
        }
        
    }
    
  
}