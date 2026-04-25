@isTest
public class NationalityTableApexTest {
    public static testMethod void test(){
     
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
        
        List<Account> listAcc = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
        listAcc[0].Data_Origin__c  = 'H';
        
        insert listAcc;
        
        
     
       
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Albanian, Albania	';
        cm.Amount__c = 123;
        cm.School__c = listAcc[0].Id;
        insert cm;
        
        NationalityTableApex.alreadyexistingnationality(listAcc[0].Id);
        NationalityTableApex.savenationality(new List<Commission_Table__c>{cm}, 'HKD');
       
    }
}