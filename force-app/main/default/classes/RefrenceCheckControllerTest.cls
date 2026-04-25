@isTest
public class RefrenceCheckControllerTest {
     @testSetup
    public static void  createData(){
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u1;
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
       // List<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
       // List<Lead> lisLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName, true, 1);
       // List<Invoice__c> lisInv = TestUtil.createInvoice(ConstantsClass.invoiceAgentRecTypeName, true, 1);
    }
    public static testMethod void testMethod2(){
         Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Reference_Verification_Sent_Date__c = date.today();
        update opp;
         RefrenceCheckController.referenceCheckFunction(opp.Id, 'verify');

    }
    
    public static testMethod void testMethod1(){
        Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Reference_Verification_Sent_Date__c = date.today().addDays(-8);
        update opp;
        test.startTest();
       RefrenceCheckController.referenceCheckFunction(opp.Id, 'verify');
        test.stopTest();
    }
      public static testMethod void testMethod3(){
         Opportunity opp = [SELECT ID FROM Opportunity];
        opp.Reference_Verification_Submitted_Date__c = Null;
        update opp;
         RefrenceCheckController.referenceCheckFunction(opp.Id, 'verify');

    }
    
}