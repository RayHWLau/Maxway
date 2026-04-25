public class RefrenceCheckController{
    
    @AuraEnabled
    public static String referenceCheckFunction(String oppId,String buttonLabel) {
        try {
            List<Opportunity> oppList = [SELECT Reference_Verification_Submitted_Date__c,Accountid,Account.Reference_check_done__c,Reference_Verification_Sent_Date__c ,Agent_Reference_Check__c FROM Opportunity 
                                         WHERE Id =:oppId];
            
            if(oppList != NULL && oppList.size() > 0) {
                if(oppList[0].Reference_Verification_Sent_Date__c != NULL) {
                    if(oppList[0].Reference_Verification_Sent_Date__c.daysBetween(Date.today()) > Integer.valueOf(Label.CheckExpiryOfAgentSignupForm))
                        return Label.AgentSignupFormLinkExpired;
                    else if(oppList[0].Reference_Verification_Submitted_Date__c != NULL)
                        return Label.RefrenceCheckResponseAlreadySave;
                    else {
                        
                        oppList[0].Reference_Verification_Submitted_Date__c = Date.today();
                        oppList[0].Agent_Reference_Check__c = (buttonLabel == 'verify' ? 'Verified' : 'Denied');
                        //   if(buttonLabel == 'verify') oppList[0].stagename ='Prepare Quotation';
                        database.update(oppList[0],false); 
                        Account acc = new Account();
                        acc.id = oppList[0].AccountId;
                        acc.Reference_check_done__c=true;
                        database.update(acc,false);
                        return Label.RefrenceCheckResponseSave;
                    }    
                }	
            }
            return Label.AgentReferenceNoOppFound;
        }
        catch(Exception e) {
            return 'ERROR : '+e.getMessage();
        }
    }
}