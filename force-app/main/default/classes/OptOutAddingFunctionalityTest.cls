@isTest
public class OptOutAddingFunctionalityTest {

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
        
        
        List<Account> lisacc = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, true, 1);
        List<Contact> conLis = TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
    }
    
    public static testMethod void testMethod1(){
        
        Account acc = [SELECT ID FROM Account];
        acc.School_List_Purchased__c = 'Australia';
        acc.School_s_Country__c = 'Australia';
        update acc;
        
        Opt_Out_School__c optScl = new Opt_Out_School__c();
        optScl.Agent__c = acc.Id;
        optScl.School__c = acc.Id;
        insert optScl;
        OptOutAddingFunctionality.fetchschoollist(acc.Id);
        OptOutAddingFunctionality.schoolwithsamecountry(acc.School_s_Country__c,acc.Id,1,10);
        OptOutAddingFunctionality.saveoptoutschool( optScl.Agent__c , optScl.School__c,acc.School_s_Country__c);
        OptOutAddingFunctionality.saveoptoutschoolPage( optScl.Agent__c , optScl.School__c,acc.School_s_Country__c, optScl.School__c);
        OptOutAddingFunctionality.getschoolPage(optScl.School__c,optScl.Agent__c,1,10,'Aust'); 
    }
}