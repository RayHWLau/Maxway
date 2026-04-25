public without sharing class OpportunityApprovalController{
    
    public pageReference CallApproval(){
        
        String oppId = Apexpages.currentPage().getParameters().get('Id');
        
        if(oppId!=null && oppId.trim().length()>0){
            
            try{
                
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(oppId);
                Approval.ProcessResult result = Approval.process(req1);
                return new pageReference('/'+oppId);
            }catch(Exception e){
                Apexpages.addMessage(new Apexpages.message(Apexpages.Severity.Error,e.getMessage()));
            }            
        }
        return null;
    }
    @AuraEnabled
    public  static string lightningapproval(Id oppId){
        
        if(oppId!=null){
            List<Opportunity> oppList=[select Quotation_Attached__c,Agent_Sign_Up_Form_Submitted_Date__c,StageName,Agent_Reference_Check__c,Number_of_admin_licenses__c
                                       ,Number_Of_Licence__c,Portal_Admin_Email__c,Required_Successful_Applications_to_Data__c ,
                                       Which_country_s_school_list_to_purchase__c from Opportunity 
                                       WHERE Id=:oppId];
            if(oppList.size()>0){
                try{
                    if(oppList[0].StageName  != 'Prepare Quotation' && oppList[0].StageName  != 'Quotation Rejected') { 
                        return 'Stage should be \'Prepare Quotation\' or \'Quotation Rejected\' in order to initiate approval process'; 
                    } 
                    else if(oppList[0].Quotation_Attached__c ==false ) { 
                        return 'Please attach document required before sending for approval'; 
                    } 
                    else if(oppList[0].Agent_Reference_Check__c != 'Verified' ) { 
                        return 'Reference Check should be Verified in order to initiate approval process'; 
                    }
                   
                    else if(
                             string.isblank(string.valueof(oppList[0].Number_of_admin_licenses__c)) ||
                             string.isblank(string.valueof(oppList[0].Number_Of_Licence__c)) ||
                             string.isblank(oppList[0].Portal_Admin_Email__c)|| 
                            string.isblank(oppList[0].Required_Successful_Applications_to_Data__c )||
                            string.isblank(oppList[0].Which_country_s_school_list_to_purchase__c)) 
                    { 
                        return 'Please fill Quotation variable section'; 
                    } 
                    else{ 
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setComments('Submitting request for approval.');
                        req1.setObjectId(oppId);
                        Approval.ProcessResult result = Approval.process(req1);
                        return 'SUCCESS';
                    }
                }catch(Exception e){
                    return e.getMessage();
                }            
            }
        }
        return null;
    }
    
    
}