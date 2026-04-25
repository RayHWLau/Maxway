@isTest
public class SchdulerToDeactivateUsersTest {
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
        
        List<Account> accLis = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Contact> conList = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName , true,1);
        
        
    }
    
    public static testMethod void testMethod1(){
        
        Account acc = [SELECT ID FROM Account];
        acc.License_End_Date__c = Date.today();
        acc.Active_License__c =2;
        update acc;
        
        Contact con = [SELECT ID FROM Contact];
        con.AccountId = acc.Id;
        update con;
        User usr = [SELECT ID FROM User LIMIT 1];
        usr.ContactId = con.Id;
        String CRON_EXP = '0 0 23 * * ?';
        QueuebleToUpdateDectivateUser.doChainJob = false;
        Test.startTest();
        
        System.schedule('SchdulerToDeactivateUsersTest',  CRON_EXP, new SchdulerToDeactivateUsers());
        
        Test.stopTest();
    }
}