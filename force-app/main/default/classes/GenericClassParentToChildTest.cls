@isTest
public class GenericClassParentToChildTest {
    
    @testSetup
    public static void createTestData(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        //ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        Profile objSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false ); 
        
        system.runAs( systemAdminUser ){
           ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
  
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            
            IncNumber__c incObj = new IncNumber__c();
            incObj.Name= 'Student ID';
            incObj.Reset__c='Daily';
            incObj.Current_Number__c = 2;
            
            insert incObj;
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            lisacc[0].Account_Manager__c = ListStaff[0].Id;
            insert lisacc;
            
            
            List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.studentRecTypeName, false, 1);
            lisOpp[0].AccountId = lisacc[0].Id;
            insert lisOpp;
            
            List<Case> lisCase = TestUtil.createApplication(ConstantsClass.caseOptOutRecTypeName, true, 1);
            
        }
    }
    
    public static testMethod void testchildToParentgetDataIfParentAccontChildOPp(){
        Account acc = [SELECT Id From Account LIMIT 1];
        Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.studentRecTypeName ];
        opp.StageName = 'Rejected';
        
        update opp;
        
        
        Test.startTest();
        GenericClassParentToChild.childToParentgetData('Account','Opportunity', new Set<Id>{acc.Id},new Set<Id>{opp.recordTypeId},false);   
       
        Test.stopTest();
    }
    
    public static testMethod void testchildToParentgetDataIfParentOppChildApp(){
        Test.startTest();
        System.debug('Test--->>>'+[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ]);
        //Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ];
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        //for contract agent account must have opportunity
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        
        Case Application = [SELECT ID,Stage__c,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Received';
        Application.Status = 'Commission paid';
        //Application.Rejected_By__c  = 'School';
        Application.Deposit_Amount__c = 12;
        Application.Reason_Of_Rejection__c = 'Tes';
        Application.Deposit_Payment_Instruction__c = 'Tesr';
        Application.Offer__c = 'Conditional';
        Application.Deposit_Due_date__c = System.today().addDays(3);
        Application.Deposit_Paid_Date__c = System.today();
        Application.Met_Conditions__c = true;
        Application.Student_Confirm_Offer__c = 'Yes';
        Application.Met_Conditions__c = true;
        Application.Other_Conditions__c = 'Yes';
        Application.Program_Offered__c = 'Test';
        Application.Visa_Required__c = 'No';
        //Application.Grade__c = ged.id;
        Application.Tuition_Stated_on_Offer__c = 12;
        Application.Conditions_Specificiation__c = 'Test';
        Application.Submit_Application_to_School_Date__c = System.today();
        Application.Opportunity__c = objOpp.Id;    
        update Application;
        
        System.debug('stg-->>>'+Application.Stage__c);
        Test.stopTest();
        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{objOpp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
    public static testMethod void testchildToParentgetDataIfParentOppChildApp8(){
        Test.startTest();
        System.debug('Test--->>>'+[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ]);
        //Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ];
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        //for contract agent account must have opportunity
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        
        Case Application = [SELECT ID,Stage__c,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Received';
        Application.Status = 'Reject';
        Application.Rejected_By__c  = 'School';
        Application.Opportunity__c = objOpp.Id;    
        update Application;
        
        System.debug('stg-->>>'+Application.Stage__c);
        Test.stopTest();
        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{objOpp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
     public static testMethod void testchildToParentgetDataIfParentOppChildApp2(){
                 Test.startTest();

        
        Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.studentRecTypeName ];
        
        Case Application = [SELECT ID,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Received';
        Application.Opportunity__c = opp.Id;  
        update Application;
                Test.stopTest();

        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{opp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
    
     public static testMethod void testchildToParentgetDataIfParentOppChildApp3(){
        Test.startTest();
        Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.studentRecTypeName ];
        
        Case Application = [SELECT ID,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Paid';
        Application.Opportunity__c = opp.Id;  
        update Application;
                Test.stopTest();
        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{opp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
    
     public static testMethod void testchildToParentgetDataIfParentOppChildApp4(){
                Test.startTest();

        Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.studentRecTypeName ];
        
        Case Application = [SELECT ID,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        //Application.Stage__c = 'Commission Paid';
        Application.Opportunity__c = opp.Id;  
        update Application;
                Test.stopTest();

         
         GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{opp.Id},new Set<Id>{Application.RecordTypeId},true); 
        
    }
    
     public static testMethod void testchildToParentgetDataIfParentOppChildApp9(){
        Test.startTest();
        System.debug('Test--->>>'+[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ]);
        //Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ];
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        //for contract agent account must have opportunity
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        
        Case Application = [SELECT ID,Stage__c,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Received';
        Application.Status = 'Arrived';
        //Application.Rejected_By__c  = 'School';
        Application.Deposit_Amount__c = 12;
        Application.Reason_Of_Rejection__c = 'Tes';
        Application.Deposit_Payment_Instruction__c = 'Tesr';
        Application.Offer__c = 'Conditional';
        Application.Deposit_Due_date__c = System.today().addDays(3);
        Application.Deposit_Paid_Date__c = System.today();
        Application.Met_Conditions__c = true;
        Application.Student_Confirm_Offer__c = 'Yes';
        Application.Met_Conditions__c = true;
        Application.Other_Conditions__c = 'Yes';
        Application.Program_Offered__c = 'Test';
        Application.Visa_Required__c = 'No';
        //Application.Grade__c = ged.id;
        Application.Tuition_Stated_on_Offer__c = 12;
        Application.Conditions_Specificiation__c = 'Test';
        Application.Submit_Application_to_School_Date__c = System.today();
        Application.Opportunity__c = objOpp.Id;    
        update Application;
        
        System.debug('stg-->>>'+Application.Stage__c);
        Test.stopTest();
        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{objOpp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
    
     public static testMethod void testchildToParentgetDataIfParentOppChildApp10(){
        Test.startTest();
        System.debug('Test--->>>'+[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ]);
        //Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ];
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        //for contract agent account must have opportunity
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        
        Case Application = [SELECT ID,Stage__c,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Received';
        Application.Status = 'Commission Received';
        //Application.Rejected_By__c  = 'School';
        Application.Deposit_Amount__c = 12;
        Application.Reason_Of_Rejection__c = 'Tes';
        Application.Deposit_Payment_Instruction__c = 'Tesr';
        Application.Offer__c = 'Conditional';
        Application.Deposit_Due_date__c = System.today().addDays(3);
        Application.Deposit_Paid_Date__c = System.today();
        Application.Met_Conditions__c = true;
        Application.Student_Confirm_Offer__c = 'Yes';
        Application.Met_Conditions__c = true;
        Application.Other_Conditions__c = 'Yes';
        Application.Program_Offered__c = 'Test';
        Application.Visa_Required__c = 'No';
        //Application.Grade__c = ged.id;
        Application.Tuition_Stated_on_Offer__c = 12;
        Application.Conditions_Specificiation__c = 'Test';
        Application.Submit_Application_to_School_Date__c = System.today();
        Application.Opportunity__c = objOpp.Id;    
        update Application;
        
        System.debug('stg-->>>'+Application.Stage__c);
        Test.stopTest();
        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{objOpp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
    
    public static testMethod void testchildToParentgetDataIfParentOppChildApp11(){
        Test.startTest();
        System.debug('Test--->>>'+[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ]);
        //Opportunity opp =[SELECT ID,RecordTypeId FROM Opportunity where RecordType.Name =:ConstantsClass.agentAcqRecTypeName ];
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        //for contract agent account must have opportunity
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        
        Case Application = [SELECT ID,Stage__c,RecordTypeId FROM Case where RecordType.Name =:ConstantsClass.caseOptOutRecTypeName ];
        Application.Stage__c = 'Commission Received';
        Application.Status = 'Pending Arrival';
        //Application.Rejected_By__c  = 'School';
        Application.Deposit_Amount__c = 12;
        Application.Reason_Of_Rejection__c = 'Tes';
        Application.Deposit_Payment_Instruction__c = 'Tesr';
        Application.Offer__c = 'Conditional';
        Application.Deposit_Due_date__c = System.today().addDays(3);
        Application.Deposit_Paid_Date__c = System.today();
        Application.Met_Conditions__c = true;
        Application.Student_Confirm_Offer__c = 'Yes';
        Application.Met_Conditions__c = true;
        Application.Other_Conditions__c = 'Yes';
        Application.Program_Offered__c = 'Test';
        Application.Visa_Required__c = 'No';
        //Application.Grade__c = ged.id;
        Application.Tuition_Stated_on_Offer__c = 12;
        Application.Conditions_Specificiation__c = 'Test';
        Application.Submit_Application_to_School_Date__c = System.today();
        Application.Opportunity__c = objOpp.Id;    
        update Application;
        
        System.debug('stg-->>>'+Application.Stage__c);
        Test.stopTest();
        GenericClassParentToChild.childToParentgetData('Opportunity','Case', new Set<Id>{objOpp.Id},new Set<Id>{Application.recordTypeId},false); 
    }
}