@isTest
public class checkSentAgentSignupControllerTest {
    @testSetup
     public static void  createData(){
          List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
     }
    public static testMethod void testMethod1(){
         ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        
        Opportunity opp = [SELECT ID FROM Opportunity];        
        opp.Agent_Sign_Up_Form_Submitted_Date__c = Date.today();
        update opp;
        checkSentAgentSignupController.checkSentAgentSignup(opp.Id);
        checkSentAgentSignupController.checkSentAgentSignupQuickAction(opp.Id);
       checkSentAgentSignupController.agentVerification(opp.Id);
        
    }
    public static testMethod void testMethod2(){
        Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Sent_Agent_Signup__c = false;
        opp.StageName = 'Closed Lost';
        opp.Closed_Lost_Reason__c ='Branch office location overlap with Maxway\'s';
        update opp;
        checkSentAgentSignupController.checkSentAgentSignupQuickAction(opp.Id);
        checkSentAgentSignupController.agentVerification(opp.Id);
        opp.Sent_Agent_Signup__c =true;
        checkSentAgentSignupController.checkSentAgentSignupQuickAction(opp.Id);
        
    }
     public static testMethod void testMethod3(){
         Opportunity opp = [SELECT ID FROM Opportunity];
         checkSentAgentSignupController.checkSentAgentSignupQuickAction(opp.Id);
         checkSentAgentSignupController.agentemailpopulate(opp.Id);
         checkSentAgentSignupController.agentVerification(opp.Id);
         checkSentAgentSignupController.agentVerificationListButton(opp.Id);
         checkSentAgentSignupController.refreeemailpopulate(opp.Id);
     }
      public static testMethod void testMethod4(){
        Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Reference_Check_Sent__c = False;
        opp.StageName = 'Closed Lost';
        opp.Closed_Lost_Reason__c ='Branch office location overlap with Maxway\'s';
        update opp;
        checkSentAgentSignupController.agentVerification(opp.Id);
       
     }
       public static testMethod void testMethod5(){
         Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Reference_Check_Sent__c = False;
           update opp;
         checkSentAgentSignupController.agentVerification(opp.Id);
         
     }
     public static testMethod void testMethod6(){
         Opportunity opp = [SELECT ID FROM Opportunity];
         opp.Sub_Agent_Email__c = 'q@g.com';
         opp.Name_for_quote_collect__c = 'ak';
         update opp;
         checkSentAgentSignupController.agentemailpopulate(opp.Id);
         checkSentAgentSignupController.agentVerification(opp.Id);
         
     }
    public static testMethod void testMethod7(){
        Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Agent_Sign_Up_Form_Submitted_Date__c = date.today();
        opp.Reference_Verification_Sent_Date__c = date.today().addDays(-4);
        opp.Reference_Check_Sent__c = False;
        update opp;
        checkSentAgentSignupController.checkSentAgentSignupQuickAction(opp.Id);
        checkSentAgentSignupController.agentVerification(opp.Id);
    }
}