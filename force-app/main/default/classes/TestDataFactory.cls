@isTest
public class TestDataFactory {

    public static testMethod Account getAccount() {
        Account a = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - University').getRecordTypeId(),
            Name = 'Test Uni',
            Partner_Type__c ='Commission',
            Contract_Open_End__c = true         
        );
        insert a;
        return a;
    }

    public static testMethod Campus__c getCampus() {
        Campus__c a = new Campus__c(
            Account__c = getAccount().Id,
            RecordTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('Uni - Campus').getRecordTypeId(),
            Name = 'Test Uni Campus',
            Country_New__c = 'Australia',
           Province_State_New__c = 'Tasmania',
            Nearest_Big_City_New__c ='Hobart',
            Housing_Option__c ='F. Apt',
            Grade_Level_Offered__c = '1',
            Homestay_Grade__c = '1'
        );
        insert a;
        return a;
    }

    public static testMethod Program__c getProgram() {
        Program__c a = new Program__c(
            Campus__c = getCampus().Id,
            RecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Uni Program').getRecordTypeId(),
            Name = 'Test Uni Program',
            Program_Type__c ='Bachelor',
            High_School_Graduation_Needed__c='Yes',
            Bachelor_Needed__c='Not Applicable'
        );
        a.Est_Annual_Cost__c = 123456;
        a.CurrencyIsoCode='AUD';
        insert a;
        return a;
    }

    public static testMethod Major__c getMajor() {
        Major__c a = new Major__c(
            Program__c = getProgram().Id,
            RecordTypeId = Schema.SObjectType.Major__c.getRecordTypeInfosByName().get('Major').getRecordTypeId(),
            Name = 'Test Uni Major'
        );
        insert a;
        return a;
    }

    public static testMethod Commission__c getCommission() {
        Commission__c a = new Commission__c();
        a.Commission_Order__c=1;
        a.Retainer_Year__c=2;
        a.Billing_Frequency_Per_Year__c=2;
        a.Annual_Commission_Amount_Percentage__c=10000;
        a.Commission_Percentage__c=4;
        insert a;
        return a;
    }
    
    public static testMethod Account getStudent() {
        IncNumber__c i = new IncNumber__c();
        i.name='Student ID';
        i.Last_Increment__c = date.today();
        i.Current_Number__c = 1;
        i.Reset__c= 'Monthly';
        insert i;
        Account a = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId(),
            LastName = 'Test Student'   
        );
        a.Data_Origin__c= 'H';
        insert a;
        return a;
    }
    public static testMethod void getCommConfig() {
        List<Commission_Config__c> commfigs = new List<Commission_Config__c>();
        commfigs.add(new Commission_Config__c(Name='1-Fall',Billing_Frequency__c=2,Term__c='Fall',Next_Term__c='2-Winter',Start_Date__c=date.newInstance(2016, 9, 1), End_Date__c=date.newInstance(2016, 6, 30)));
commfigs.add(new Commission_Config__c(Name='2-Fall',Billing_Frequency__c=2,Term__c='Fall',Next_Term__c='2-Winter',Start_Date__c=date.newInstance(2016, 9, 1), End_Date__c=date.newInstance(2016, 1, 31)));
commfigs.add(new Commission_Config__c(Name='2-Winter',Billing_Frequency__c=2,Term__c='Winter',Next_Term__c='2-Fall',Start_Date__c=date.newInstance(2016, 2, 1), End_Date__c=date.newInstance(2016, 6, 30)));
commfigs.add(new Commission_Config__c(Name='3-Fall',Billing_Frequency__c=3,Term__c='Fall',Next_Term__c='3-Spring',Start_Date__c=date.newInstance(2016, 9, 1), End_Date__c=date.newInstance(2016, 12, 31)));
commfigs.add(new Commission_Config__c(Name='3-Spring',Billing_Frequency__c=3,Term__c='Spring',Next_Term__c='3-Winter',Start_Date__c=date.newInstance(2016, 4, 1), End_Date__c=date.newInstance(2016, 6, 30)));
commfigs.add(new Commission_Config__c(Name='3-Winter',Billing_Frequency__c=3,Term__c='Winter',Next_Term__c='3-Fall',Start_Date__c=date.newInstance(2016, 1, 1), End_Date__c=date.newInstance(2016, 3, 31)));
commfigs.add(new Commission_Config__c(Name='4-Fall',Billing_Frequency__c=4,Term__c='Fall',Next_Term__c='4-Spring',Start_Date__c=date.newInstance(2016, 9, 1), End_Date__c=date.newInstance(2016, 12, 31)));
commfigs.add(new Commission_Config__c(Name='4-Spring',Billing_Frequency__c=4,Term__c='Spring',Next_Term__c='4-Summer',Start_Date__c=date.newInstance(2016, 4, 1), End_Date__c=date.newInstance(2016, 6, 30)));
commfigs.add(new Commission_Config__c(Name='4-Summer',Billing_Frequency__c=4,Term__c='Summer',Next_Term__c='4-Winter',Start_Date__c=date.newInstance(2016, 7, 1), End_Date__c=date.newInstance(2016, 8, 31)));
commfigs.add(new Commission_Config__c(Name='4-Winter',Billing_Frequency__c=4,Term__c='Winter',Next_Term__c='4-Fall',Start_Date__c=date.newInstance(2016, 1, 1), End_Date__c=date.newInstance(2016, 3, 31)));

        insert commfigs;
    }
}