@isTest
public class FollowupTaskTest {
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
        //ist<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.studentRecTypeName, true, 1);
        //ist<Lead> lisLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName, true, 1);
        //ist<Invoice__c> lisInv = TestUtil.createInvoice(ConstantsClass.invoiceAgentRecTypeName, true, 1);
    }
    
    public static testMethod void  testMethod1(){
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        Opportunity opp = [SELECT ID FROM Opportunity];
       
        FollowupTask.taskcomponentOnLoad(opp.ID);
        
        
        
    }
    public static testMethod void  testMethod2(){
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        Opportunity opp = [SELECT ID,StageName FROM Opportunity];
        Staff__c[] sf = [SELECT ID FROM Staff__c];
        Task tk = new task();
        tk.whatid = opp.id;
        tk.Task_Owner__c= sf[0].Id;
        tk.Status = 'Completed';
        insert tk;
        test.startTest();
        FollowupTask.savetask(Date.today(), 'subject', 'Not Recruitment co.', 'followupremarks', 'onholdreason', tk.id, opp.stagename);
        FollowupTask.savetask(Date.today(), '', 'Not Recruitment co.', 'followupremarks', 'onholdreason', tk.id, opp.stagename);
        
        test.stopTest();
    }
    
  
}