@isTest
public class ContracttriggerHelperTest {
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
        
        List<Account> lisAcc = TestUtil.createAccount(ConstantsClass.subAgcyRecTypeName, false, 2);
        lisAcc[0].Nationality__c='Afghan, Afghanistan';
        lisAcc[1].Nationality__c='Afghan, Afghanistan';

        insert lisAcc;
       
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        List<Opportunity> listOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
        listOpp[0].Business_Type__c='New';
        listOpp[0].CloseDate=system.today()+1;
        listOpp[0].AccountId = lisAcc[0].Id;
        insert listOpp;
            
        List<Contract> lisCon = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false,1);
        lisCon[0].Opportunity__c  = listOpp[0].Id;
        lisCon[0].AccountId =  listOpp[0].AccountId;
        lisCon[0].status = 'Draft';
       // lisCon[0].enddate = Date.today().addDays(+2);
        insert lisCon;

        ContracttriggerHelper.visibletoagentupdate(new Set<Id>{lisAcc[0].Id});
        ContracttriggerHelper.licencenumberupdate(new Set<Id>{lisAcc[0].Id});
        ContracttriggerHelper.calculatedays(date.today(), 12, date.today().addDays(+2));
    }
    
     public static testMethod void test2(){
        
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
        
         
        List<Account> lisAcc = TestUtil.createAccount(ConstantsClass.localSclRecTypeName, false, 2);
         
        lisAcc[0].Nationality__c='Afghan, Afghanistan';
        lisAcc[1].Nationality__c='Afghan, Afghanistan';


        insert lisAcc;
       ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        List<Opportunity> listOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
        listOpp[0].AccountId = lisAcc[0].Id;
        listOpp[0].Business_Type__c='New';
        listOpp[0].CloseDate=system.today()+1;


        insert listOpp;
           
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Afghan, Afghanistan';
        cm.Amount__c = 123;
        cm.School__c = lisAcc[0].Id;
        insert cm;
        List<Contract> lisCon = TestUtil.createContract(ConstantsClass.schoolRecTypeName, false,1);
        //lisCon[0].Opportunity__c  = listOpp[0].Id;
        lisCon[0].AccountId =  lisAcc[0].Id;
        lisCon[0].Status = 'Valid';
        lisCon[0].Counter_Sign_Contract_Arrived_Date__c  = Date.today();
       // lisCon[0].Issue_contract_after_1st_student_is_sent__c  = true;  
        lisCon[0].Contract_Open_End__c = true;
       // lisCon[0].Contract_End_Date__c = date.today(); 
        lisCon[0].Fact_Sheet_Provided__c = 'No';
        lisCon[0].Need_Fact_Sheet__c  = 'No';         
        insert lisCon;
         
        ContracttriggerHelper.validateValidContarct(lisCon);
         /*
         lisCon[0].Status = 'Contract Activated';
         lisCon[0].Counter_Sign_Contract_Arrived_Date__c = Null;
         lisCon[0].StartDate = date.today();
         lisCon[0].ContractTerm  = 2;
         lisCon[0].Commissionable__c = 'Commission';
         lisCon[0].Contract_Open_End__c = true;
         lisCon[0].Fact_Sheet_Provided__c = 'No';
          lisCon[0].Issue_contract_after_1st_student_is_sent__c  = true;  
         lisCon[0].Need_Fact_Sheet__c  = 'No';  
         
         update lisCon;
         ContracttriggerHelper.validateValidContarct(lisCon);
*/
         System.debug('lisCon-->'+lisCon);
         
         ContracttriggerHelper.calculatedays(date.today(), 2, date.today().addDays(+2));
     }
    
     public static testMethod void test3(){
         
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
        
        List<Account> lisAcc = TestUtil.createAccount(ConstantsClass.subAgcyRecTypeName, false, 2);
        lisAcc[0].Nationality__c='Afghan, Afghanistan';
        lisAcc[1].Nationality__c='Afghan, Afghanistan';
        insert lisAcc;
       
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        List<Opportunity> listOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
        listOpp[0].AccountId = lisAcc[0].Id;
        listOpp[0].Business_Type__c='New';
        listOpp[0].CloseDate=system.today()+1;


        insert listOpp;
            
        List<Contract> lisCon = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false,1);
        lisCon[0].Opportunity__c  = listOpp[0].Id;
        lisCon[0].AccountId =  listOpp[0].AccountId;
        
         
       // lisCon[0].enddate = Date.today().addDays(+2);
        insert lisCon;
        lisCon[0].status = 'Activated';
         update lisCon;
          ContracttriggerHelper.licencenumberupdate(new Set<Id>{lisAcc[0].Id});
     }
}