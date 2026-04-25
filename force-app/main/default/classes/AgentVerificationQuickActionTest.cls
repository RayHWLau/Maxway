@isTest
public class AgentVerificationQuickActionTest {
    
    public static testMethod void test(){
        List<Opportunity> oppList = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
        AgentVerificationQuickActionController.agentVerification(oppList[0].Id);
        AgentVerificationQuickActionController.agentVerificationListButton(oppList[0].ID);
        
    }
    
    public static testMethod void testElse(){
        List<Opportunity> oppList = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
        oppList[0].Reference_Verification_Submitted_Date__c = date.today();
        insert oppList;
        AgentVerificationQuickActionController.agentVerification(oppList[0].ID);
        AgentVerificationQuickActionController.agentVerificationListButton(oppList[0].ID);
    } 
}