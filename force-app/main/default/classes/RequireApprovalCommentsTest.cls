@isTest
public class RequireApprovalCommentsTest {
   
    public static TestMethod void test(){
       
        
      Opportunity objOpp =TestUtil.createOpportunity(ConstantsClass.renAgntRecTypeName,false, 1)[0];
        			objOpp.Name = 'TestRenAgent';
                    objOpp.Number_Of_Licence__c = 2;
        			objOpp.Quotation_Attached__c=true;
                    objOpp.Number_of_not_in_database_schools__c = 2;
                    objOpp.Business_License_Valid_Till__c= date.today().addDays(+50);
                    objOpp.Agent_Sign_Up_Form_Sent_Date__c = date.today().addDays(-5);
                    objOpp.Agent_Sign_Up_Form_Submitted_Date__c = date.today();
                    objOpp.Number_of_Admin_Licenses__c = 5;
                    objOpp.Which_country_s_school_list_to_purchase__c ='Canada';
                    objOpp.Portal_Admin_Email__c = 'test@gmail.com';
        			objOpp.Required_Successful_Applications_to_Data__c ='1';
        			objOpp.Agent_Reference_Check__c	='Verified';
                    objOpp.StageName = 'Prepare Quotation';
                    objOpp.CloseDate = date.today().addDays(+50);
        insert objOpp;
        User usr = [SELECT ID FROM User LIMIT 1];    
        
        List< ProcessDefinition > objProcessDef = [ SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Approve_Quotation' AND TableEnumOrId = 'Opportunity' ];
        
        if( objProcessDef.size() > 0 ){
            objOpp.StageName='Quotation Rejected';
             Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
            req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(objOpp.Id);

            Approval.ProcessResult resu = Approval.process(req);
            system.debug('resu'+resu);
           objOpp.Approval_Status__c = 'Rejected';
            update objOpp;
        }
    }
  
    
}