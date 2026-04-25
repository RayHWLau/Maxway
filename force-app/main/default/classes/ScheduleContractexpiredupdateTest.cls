@isTest
public class ScheduleContractexpiredupdateTest {
    public static testMethod void test(){
        String CRON_EXP = '0 0 0 15 3 ? *'; 
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
        
            
        List<Account> ListAcc = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, False, 1);
        ListAcc[0].Account_Manager__c = ListStaff[0].Id;
        insert ListAcc;
        system.debug('ListAcc'+ListAcc);
        
        Commission_Table__c cmsnTbl = new Commission_Table__c();
        cmsnTbl.Nationality__c = 'Afghan, Afghanistan';
        cmsnTbl.School__c = ListAcc[0].Id;
        insert cmsnTbl;
        
        List<Contract> ListCntrct = TestUtil.createContract(ConstantsClass.marketingConRecTypeName,false,1);
        ListCntrct[0].status ='Contract Activated';
        ListCntrct[0].AccountId =  ListAcc[0].Id;
        ListCntrct[0].Quota_Per_Contract__c = 2;
        insert ListCntrct;
        
        Test.startTest();
        String jobId = System.schedule('ScheduleContractexpiredupdateTest',  CRON_EXP, new ScheduleContractexpiredupdate());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }
}