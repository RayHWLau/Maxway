global class checkSentAgentSignupController {
    
    webservice static void checkSentAgentSignup(Id oppId)
    {       
        if(String.isNotBlank(oppId)){
            List<Opportunity> oppList = [SELECT Id,Sent_Agent_Signup__c FROM Opportunity Where Id =:oppId];
            if(oppList != NULL && oppList.size() > 0){
                oppList[0].Sent_Agent_Signup__c = true;
                update oppList;            
            }   
        }                            
    }        
    
    @AuraEnabled
    public static String checkSentAgentSignupQuickAction(Id oppId)
    {                       
        if(String.isNotBlank(oppId)){
            List<Opportunity> oppList = [SELECT Id,Sent_Agent_Signup__c,Agent_Sign_Up_Form_Submitted_Date__c,StageName FROM Opportunity Where Id =:oppId];
            if(oppList != NULL && oppList.size() > 0){
                if(oppList[0].Sent_Agent_Signup__c == true){
                  return 'Alreadysent';  
                }
                
                else if(oppList[0].Agent_Sign_Up_Form_Submitted_Date__c != NULL){
                    return 'submittedDate';
                }
                else if(oppList[0].StageName == 'Closed Lost' || oppList[0].StageName == 'Sales Won' ){
                    return 'stage';
                }
                else{
                    oppList[0].Sent_Agent_Signup__c = true;
                    update oppList;   				
                    return 'SUCCESS'; 
                }                
            }   
        }                           
        return null;
    }
    @AuraEnabled
     public static String agentemailpopulate(Id oppId)
    {                       
        if(String.isNotBlank(oppId)){
            List<Opportunity> oppList = [SELECT Id,Sent_Agent_Signup__c,Agent_Sign_Up_Form_Submitted_Date__c,StageName,Sub_Agent_Email__c,Name_for_quote_collect__c
                                         FROM Opportunity 
                                         Where Id =:oppId AND Sub_Agent_Email__c != null AND Name_for_quote_collect__c!= NULL];
            if(oppList != NULL && oppList.size() > 0){
             return oppList[0].Sub_Agent_Email__c;          
            }   
        }                           
        return null;
    }
    
    
    //Added By Shalini
    webservice static void agentVerificationListButton(Id oppId){
        
        if(String.isNotBlank(oppId)){
            Opportunity oppObj = new Opportunity();
            oppObj.Id = oppId;
            oppObj.Reference_Check_Sent__c = true;
            update oppObj;
        }  
    }
      @AuraEnabled
     public static String refreeemailpopulate(Id oppId)
    {                    
        //added 8 may as validation only
        set< Id > setMayWayProfId = ( new map< Id, Profile >( [ SELECT Id FROM Profile WHERE Name = 'Maxway System Administrator' ] )).keySet();
        
        if(  !setMayWayProfId.contains( UserInfo.getProfileId() ) ){
            
            return 'Only Maxway admin can verify reference';
        }
        
        if(String.isNotBlank(oppId)){
            List<Opportunity> oppList = [SELECT Id,Sent_Agent_Signup__c,Agent_Sign_Up_Form_Submitted_Date__c,StageName,Sub_Agent_Email__c,Refree_Email__c FROM Opportunity Where Id =:oppId];
            if(oppList.size() > 0){
                if(oppList[0].StageName !='Closed Lost'){
                  
                    return oppList[0].Refree_Email__c; 
                } 
                return 'closedlost';
            }   
        }                           
        return null;
    }
    
    @AuraEnabled
    public static String agentVerification(Id oppId){        
        if(String.isNotBlank(oppId)){
            List<Opportunity> oppList=[select Reference_Check_Sent__c,Refree_Email__c,Reference_Verification_Submitted_Date__c,StageName,Agent_Reference_Check__c from Opportunity 
                                       WHERE Id=:oppId];
            
            if(oppList.size()>0 && oppList!=NULL){
                if(oppList[0].Reference_Verification_Submitted_Date__c != NULL){
                    return 'submittedDate';
                }
                else if(oppList[0].Reference_Check_Sent__c==True){
                    return 'referencecheck';
                }
                
                else if(oppList[0].StageName == 'Closed Lost' || oppList[0].StageName == 'Sales Won' ){
                    return 'stage';
                }
                  else if(string.isblank(oppList[0].Refree_Email__c)){
                    return 'refreeemail';
                }
                
                else{
                    oppList[0].Reference_Check_Sent__c=True;
                    update oppList;
                    return 'SUCCESS';
                }
            }
        }
        return NULL;
    }        
}