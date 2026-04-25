@isTest
public class OpportunityTriggerTest {
    
     @testSetup
    public static void  createData(){
        Test.startTest();
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
        OpportunityCustomScreenAura.getUser(u1.id);
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
        List<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Contact> conLis = TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
         Test.stopTest();
        
    }
    
    public static testMethod void test(){
        Test.startTest();
        Contact con = [SELECT ID,AccountId FROM Contact];
        // Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsClass.studntAccRecTypeName).getRecordTypeId();
        Set<String> accidSet = new Set<String>();
        
        // Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('osHSRecTypeName').getRecordTypeId();
        Account acc = [SELECT ID,RecordTypeId FROM Account];
        // acc.RecordTypeId = RecordTypeIdAccount;
        accidSet.add(acc.id);
        
        Set<Id> oppidSet = new Set<Id>();
        Opportunity oppSet = [select id from Opportunity ];
        oppidSet.add(oppSet.id);
       // OpportunityTriggerHandler.generateDraftInvoice(oppidSet);
        update acc;
        
        //   List<Account> listacc = TestUtil.createAccount(ConstantsClass.Overseas_School_CC, false, 1);
        
        Opportunity opp = [SELECT ID  FROM Opportunity ];
        opp.AccountId =acc.Id;
        //  opp.StageName = 'Closed Lost';
        //  opp.Closed_Lost_Reason__c = 'Closed Lost';
        update opp;
        
        list<Account> lisAcc = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, true, 1);
        lisAcc[0].CurrencyIsoCode='USD';
        update lisAcc;
        Campus__c cms=new Campus__c();
        cms.Account__c = lisAcc[0].id;
        cms.Homestay_Grade__c = 'K1';
        cms.Country_New__c = 'United States';
        cms.Student_taking_IB__c = 10;
        cms.Housing_Option__c='Homestay';
        cms.Province_State_New__c = 'Alabama';
        cms.Nearest_Big_City_New__c = 'Birmingham';
        cms.CurrencyIsoCode='USD';
        insert cms;
        Program__c pgm=new Program__c();
        pgm.Program_Type__c = 'Bachelor';
        pgm.Est_Annual_Cost__c = 2000;
        pgm.Campus__c = cms.id;
        pgm.ESL_Housing__c = 2200;
        pgm.CurrencyIsoCode = 'USD';
        pgm.Bachelor_Needed__c = 'Not Applicable'; 
        pgm.IELTS_Min__c = '2.0';
        pgm.TOEFL_Min__c = 10;   
        pgm.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
        pgm.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
        pgm.High_School_Graduation_Needed__c = 'Yes';
        pgm.Admission_Grade__c='K1';
        insert pgm;
        
        Commission__c comms = new Commission__c();
        // comms.Account__c = lisAcc[0].id;
        comms.Program__c = pgm.id;
        comms.Billing_Frequency_Per_Year__c = 80;
        comms.Commission_Order__c = 3;
        insert comms;
        
        
        // List<Case> caseList = TestUtil.createApplication(caseCCRecTypeName, false, 1);
        // caseList[0].Opportunity__c = opp.id;
        List<Case> caseId = new List<Case>();
        Case cs = new Case();
        cs.Status = 'In Progress';
        cs.Placed_Grade__c = 'Grade 3';
        cs.Term__c = 'Fall';
        cs.Year__c = '2011';
        cs.Start_Year_Year__c='2011';
        cs.Start_Month__c='May';
        cs.Opportunity__c = opp.id;
        //		cs.Program__c = pgm.id;
        caseId.add(cs);
        insert caseId;
        
        //OpportunityTriggerHandler.generateDraftInvoice(oppidSet);
        //OpportunityTriggerHandler.accountstatustoclosedlost(accidSet);
        Test.stopTest();
        
    }

}