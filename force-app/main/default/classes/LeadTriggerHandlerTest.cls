@isTest
public class LeadTriggerHandlerTest {
    
    @testSetup
    public static void  createData(){
        Test.StartTest();
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
        Account acc=TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0];
        List<Lead> lisLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName,false,1);
        lisLead[0].status = 'New';
        insert lisLead;
        Test.StopTest();
    }
    
    @isTest
    public static void leadtest1(){
        
       
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;        
        
        
        Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Lead ld=new Lead();
        ld.RecordTypeId =RecordTypeIdLead;
        
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - ESL').getRecordTypeId();
        
        Account objacc = new Account( Name='Test Account',
                                     BillingStreet='Test Street',
                                     BillingCity='Test City',
                                     BillingState='Test State',
                                     BillingCountry='Test Country',
                                     BillingPostalCode='Test Postal Code');
        objacc.RecordTypeId = RecordTypeIdAcc;
        
        insert objacc;
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
        Account acc= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678' 
        );
        
        insert acc;
        
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
        insert lisOpp;
        
        ld.Country ='Ind';
        ld.City = 'jbd';
        ld.State = 'Up';
        ld.Street = 'GT';
        
        ld.Status = 'New';   
        ld.Website = 'www.salesforce.com';
        ld.Head_Office_Country__c = 'Afghanistan';
        ld.Branch_Conflicts_with_Maxway__c = 'No';
        ld.LeadSource = 'Website';
        ld.Where_did_you_hear_about_us__c = 'Referral';
        ld.Last_Years_Total_Successful_Applications__c = '101-130';
        ld.Number_Of_Full_Time_Staff__c = 1;
        ld.Study_Abroad_Countries__c ='Afghanistan';
        ld.Top_Sending_Countries__c = 'Afghanistan';
        ld.Salutation = 'Mr';
        ld.Country_Code__c = 'Afghanistan (93)';
        ld.Mobile__c = '23456789';
        ld.Phone = '9984675896';
        ld.Email = 'neha.singh@techmatrixconsulting.com';
        ld.Case_Manager_Email__c = 'abc@g3l.com';
        ld.Title = 'BA';
        ld.LastName = 'Neha chauhan Test';
        
         test.startTest();
        insert ld;
        
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(ld.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
     //    Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Lead ldd=new Lead();
        ldd.RecordTypeId =RecordTypeIdLead;
         ldd.Country ='Ind';
        ldd.City = 'jbd';
        ldd.State = 'Up';
        ldd.Street = 'GT';
        
        ldd.Status = 'New';   
        ldd.Website = 'www.salesforce.com';
        ldd.Head_Office_Country__c = 'Afghanistan';
        ldd.Branch_Conflicts_with_Maxway__c = 'No';
        ldd.LeadSource = 'Website';
        ldd.Where_did_you_hear_about_us__c = 'Referral';
        ldd.Last_Years_Total_Successful_Applications__c = '101-130';
        ldd.Number_Of_Full_Time_Staff__c = 1;
        ldd.Study_Abroad_Countries__c ='Afghanistan';
        ldd.Top_Sending_Countries__c = 'Afghanistan';
        ldd.Salutation = 'Mr';
        ldd.Country_Code__c = 'Afghanistan (93)';
        ldd.Mobile__c = '23456789';
        ldd.Phone = '9984675896';
        ldd.Email = 'neha.singh@techmatrixconsulting.com';
        ldd.Case_Manager_Email__c = 'abc@g3l.com';
        ldd.Title = 'BA';
        ldd.LastName = 'Neha chauhan Test';
        insert ldd;
        
        Sibling__c sib=new Sibling__c();
        sib.Principal_Student_Lead__c=ld.id;
        sib.Sibling_Student_Lead__c=ldd.Id;
        sib.Principal_Student__c=acc.id;
        sib.Sibling_Student__c=acc.id;
        insert sib; 
        
        Nominated_school_new__c ns = new Nominated_school_new__c();
        ns.Lead__c = ld.id;
        ns.Opportunity__c = lisOpp[0].id;
        insert ns;
        
        Recommended_Schools__c rs = new Recommended_Schools__c();
        rs.Lead__c = ld.id;
        rs.Opportunity__c = lisOpp[0].id;
        insert rs;
        test.stopTest();
        
    } 
    
    @isTest
    public static void leadtest2(){
        
        test.startTest();
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;        
        
        Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        Lead ld=new Lead();
        ld.RecordTypeId =RecordTypeIdLead;
        
        Id RecordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - ESL').getRecordTypeId();
        
        Account objacc = new Account( Name='Test Account',
                                     BillingStreet='Test Street',
                                     BillingCity='Test City',
                                     BillingState='Test State',
                                     BillingCountry='Test Country',
                                     BillingPostalCode='Test Postal Code');
        objacc.RecordTypeId = RecordTypeIdAcc;
        
        insert objacc;
        
        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
        Account acc= new Account(
            RecordTypeID=recordTypeId ,
            FirstName='Test FName',
            LastName='Test LName',
            PersonMailingStreet='test@yahoo.com',
            PersonMailingPostalCode='12345',
            PersonMailingCity='SFO',
            PersonEmail='test@yahoo.com',
            PersonHomePhone='1234567',
            PersonMobilePhone='12345678' 
        );
        
        insert acc;
     
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
        insert lisOpp;
        
        ld.Country ='Ind';
        ld.City = 'jbd';
        ld.State = 'Up';
        ld.Street = 'GT';
        ld.Status = 'New';   
        ld.Website = 'www.salesforce.com';
        ld.Head_Office_Country__c = 'Afghanistan';
        ld.Branch_Conflicts_with_Maxway__c = 'No';
        ld.LeadSource = 'Website';
        ld.Where_did_you_hear_about_us__c = 'Referral';
        ld.Last_Years_Total_Successful_Applications__c = '101-130';
        ld.Number_Of_Full_Time_Staff__c = 1;
        ld.Study_Abroad_Countries__c ='Afghanistan';
        ld.Top_Sending_Countries__c = 'Afghanistan';
        ld.Salutation = 'Mr';
        ld.Country_Code__c = 'Afghanistan (93)';
        ld.Mobile__c = '23456789';
        ld.Phone = '9984675896';
        ld.Email = 'neha.singh@techmatrixconsulting.com';
        ld.Case_Manager_Email__c = 'abc@g3l.com';
        ld.Title = 'BA';
        ld.LastName = 'Neha chauhan Test';
        
        insert ld;
        
        Sibling__c sib=new Sibling__c();
        sib.Principal_Student_Lead__c=ld.id;
        sib.Sibling_Student_Lead__c=ld.Id;
        sib.Principal_Student__c=acc.id;
        sib.Sibling_Student__c=acc.id;
        insert sib; 
        
        List<Sibling__c> siblings = [
                    Select Id, 
                    Principal_Student_Lead__c, Sibling_Student_Lead__c,
                    Principal_Student__c, Sibling_Student__c
                    From Sibling__c];
        
        Nominated_school_new__c ns = new Nominated_school_new__c();
        ns.Lead__c = ld.id;
        ns.Opportunity__c = lisOpp[0].id;
        
        Recommended_Schools__c rs = new Recommended_Schools__c();
        rs.Lead__c = ld.id;
        rs.Opportunity__c = lisOpp[0].id;
        
        test.stopTest();
        
    } 
}