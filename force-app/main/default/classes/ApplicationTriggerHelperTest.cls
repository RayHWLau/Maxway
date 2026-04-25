@isTest
public class ApplicationTriggerHelperTest {
    @testSetup
    public static void createTestData(){
        
        test.startTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        Profile objSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false );
        Profile objMaxSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'Maxway System Administrator'];
        User maxwaySystemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false );
        Id InvoiceAgentRecTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Agent').getRecordTypeId(); 
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        
        system.runAs( systemAdminUser ){
            InvoiceTrigger_RollUpInvoiceAmount__c objInvoiceTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
            ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
            
            TestUtil.createCustomSettingApplicationPrepaidBaln( true );
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            
            //Agent Account Creation
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            lisacc[0].Account_Manager__c = ListStaff[0].Id;
            lisacc[0].Total_Admin_License__c = 10;
            lisacc[0].Total_User_License__c = 10;
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            TestUtil.createInvoice('Agent', true, 1);
            TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
            
            //
            Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.renAgntRecTypeName, false, 1)[0];  
            objOpp.AccountId = lisacc[0].Id;
            insert objOpp;
            
            Invoice__c objInvoice = new Invoice__c();        
            objInvoice.Amount_Received__c = 4;
            objInvoice.Invoiced_Amount__c = 4;
            objInvoice.Status__c ='Paid';
            objInvoice.Payment_Receiver__c = ListStaff[0].id;
            objInvoice.Payment_Method_Description__c = 'Test';
            objInvoice.Mode_Of_Payment__c = 'Cash';
            objInvoice.Company_Name__c = lisacc[0].Id;
            objInvoice.Invoice_Type__c = 'Prepaid';
            objInvoice.RecordTypeId = InvoiceAgentRecTypeId;
            objInvoice.CurrencyIsoCode = 'USD';
            insert objInvoice;
            
            List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
            listContract[0].AccountId = lisacc[0].Id;
            listContract[0].Opportunity__c = objOpp.Id;
            listContract[0].CurrencyIsoCode='USD';
            insert listContract;
            
            list< Contract_Item__c > listContractItem = TestUtil.createContractItem( listContract[0].id, objTestSetting.Contract_Line_Item_Record_Name__c, 1, objTestSetting.Application_Tariff_Type__c, true );
        }
        system.runAs( systemAdminUser ){
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            
            //Agent Account Creation
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            
            insert lisacc;
            
        }
        
        test.stopTest();
    }
    //for approval process update
    public static testMethod void testmethod1(){
        
        system.debug('@@@@@@@--- ' + limits.getQueries());
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = [ SELECT Id, Name, CurrencyIsoCode, isActive__c, showDebugLogs__c, School_Tariff_Type__c, Student_Tariff_Type__c,
                                                                    Application_Tariff_Type__c, Contract_Status__c, Application_RecordType_Name_For_Approval__c,
                                                                    Error_Message_for_Insufficient_Amount__c, Application_RecordType_Name_Non_Approval__c, 
                                                                    Error_Message_for_No_Contract__c, Contract_Line_Item_Record_Name__c, Application_Approval_Process_Name__c,
                                                                    Application_StageName__c, System_Admin_Profile_Name__c, Account_Student_Record_Type_Name__c, Staff_Name_For_Portal_User__c,
                                                                    schoolNameValidationErrorOptIn__c, schoolNameValidationErrorOptOut__c, OptOutNotInDatabase__c,
                                                                    schoolNameValidationErrorMaxwayApp__c
                                                                    FROM ApplicationTrigger_checkPrepaidBalence__c ][0];
        List< Contract > listContract = [ SELECT Id FROM Contract WHERE CurrencyIsoCode = 'USD' ];
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
        
        User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        Opportunity objOpp = [ SELECT Id FROM Opportunity WHERE RecordType.Name =:ConstantsClass.renAgntRecTypeName LIMIT 1 ][0];
        Id caseOptOutRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptOutRecTypeName).getRecordTypeId(); 
        String applicationId;
        Approval.ProcessResult approvalProcessSubmit;
        OpportunityShare sh = new OpportunityShare();
        sh.OpportunityId=objOpp.Id;
        sh.UserOrGroupId=partnerUser.Id;
        sh.OpportunityAccessLevel='Edit';
        insert sh;
        Case Application;
        System.runAs( partnerUser ){
            
            list< Staff__c  >ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List < Account >lisAcc1 = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
            lisAcc1[0].Account_Manager__c = ListStaff[0].Id;
            lisAcc1[0].Approval_Status__c='Approved';
            insert lisAcc1;
            
            Id campid=Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('High School - Campus').getRecordTypeId();
            
            Campus__c cms=new Campus__c();
            cms.Account__c = lisAcc1[0].id;
            cms.RecordTypeId=campid;
            cms.Homestay_Grade__c = 'K1';
            cms.Country_New__c = 'United States';
            cms.Student_taking_IB__c = 10;
            cms.Housing_Option__c='Homestay';
            cms.Province_State_New__c = 'Alabama';
            cms.Nearest_Big_City_New__c = 'Birmingham';
            cms.CurrencyIsoCode='USD';
            insert cms;
            
            Id  progid=Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('High School Program').getRecordTypeId();
            
            
            Program__c pgm=new Program__c();
            pgm.Program_Type__c = 'Bachelor';
            pgm.Est_Annual_Cost__c = 2000;
            pgm.recordTypeId=progid;
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
            
            Application = TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission paid';
            Application.Deposit_Amount__c = 12;
            Application.Program__c=pgm.id;
            Application.Campus__c=cms.id;
            Application.Reason_Of_Rejection__c = 'Tes';
            Application.Deposit_Payment_Instruction__c = 'Tesr';
            Application.Offer__c = 'Conditional';
            Application.Deposit_Due_date__c = System.today().addDays(3);
            Application.Deposit_Paid_Date__c = System.today();
            Application.Met_Conditions__c = true;
            Application.School__c=lisAcc1[0].Id;
            Application.Student_Confirm_Offer__c = 'Yes';
            Application.Met_Conditions__c = true;
            Application.Other_Conditions__c = 'Yes';
            Application.Program_Offered__c = 'Test';
            Application.Visa_Required__c = 'No';
            Application.Tuition_Stated_on_Offer__c = 12;
            Application.Conditions_Specificiation__c = 'Test';
            Application.Submit_Application_to_School_Date__c = System.today();
            Application.Opportunity__c = objOpp.Id;  
            Application.Allow_parallel_processing_of_Application__c = true;
            Application.Submit_Application_to_School_Date__c = date.today();
            Application.Student_Nationality_is_Commissionable__c = true;
            
            Case ApplicationOptOut = Application.clone( false, true, false, false );
            ApplicationOptOut.RecordTypeId = caseOptOutRecId;
            
            insert new List< Case > { Application,ApplicationOptOut };
                
                applicationId = Application.id;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments( 'Submitting request for approval.' );
            req1.setObjectId( Application.id );
            
            req1.setSubmitterId( partnerUser.Id ); 
            
            req1.setProcessDefinitionNameOrId('OptInApplicationApprovalProcess');
            req1.setSkipEntryCriteria(true);
            
            Test.startTest();
            approvalProcessSubmit = Approval.process(req1);
            
            system.debug('@@@@@ -->  ' + approvalProcessSubmit.isSuccess() );
            
        }//end of portal user
        
        List<Id> newWorkItemIds = approvalProcessSubmit.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        Approval.ProcessResult result2 =  Approval.process(req2);
        
    } 
    //for insufficient amount
     public static testMethod void testmethod2(){
        
        system.debug('@@@@@@@--- ' + limits.getQueries());
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = [ SELECT Id, Name, CurrencyIsoCode, isActive__c, showDebugLogs__c, School_Tariff_Type__c, Student_Tariff_Type__c,
                                                                    Application_Tariff_Type__c, Contract_Status__c, Application_RecordType_Name_For_Approval__c,
                                                                    Error_Message_for_Insufficient_Amount__c, Application_RecordType_Name_Non_Approval__c, 
                                                                    Error_Message_for_No_Contract__c, Contract_Line_Item_Record_Name__c, Application_Approval_Process_Name__c,
                                                                    Application_StageName__c, System_Admin_Profile_Name__c, Account_Student_Record_Type_Name__c, Staff_Name_For_Portal_User__c,
                                                                    schoolNameValidationErrorOptIn__c, schoolNameValidationErrorOptOut__c, OptOutNotInDatabase__c,
                                                                    schoolNameValidationErrorMaxwayApp__c
                                                                    FROM ApplicationTrigger_checkPrepaidBalence__c ][0];
        List< Contract > listContract = [ SELECT Id FROM Contract WHERE CurrencyIsoCode = 'USD' ];
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
        
         list< Contract_Item__c > listContractItem = [ SELECT Id FROM Contract_Item__c WHERE Contract__c =: listContract[0].Id ];
         listContractItem[0].Opt_Out_NIN__c = 8;
         update listContractItem;
         
         User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        Opportunity objOpp = [ SELECT Id FROM Opportunity WHERE RecordType.Name =:ConstantsClass.renAgntRecTypeName LIMIT 1 ][0];
        Id caseOptOutRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptOutRecTypeName).getRecordTypeId(); 
        String applicationId;
        Approval.ProcessResult approvalProcessSubmit;
        Case Application;
         OpportunityShare sh = new OpportunityShare();
         sh.OpportunityId=objOpp.Id;
         sh.UserOrGroupId=partnerUser.Id;
         sh.OpportunityAccessLevel='Edit';
         insert sh;
        System.runAs( partnerUser ){
            
            list< Staff__c  >ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List < Account >lisAcc1 = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
            lisAcc1[0].Account_Manager__c = ListStaff[0].Id;
            lisAcc1[0].Approval_Status__c='Approved';
            insert lisAcc1;
            
            Id campid=Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('High School - Campus').getRecordTypeId();
            
            Campus__c cms=new Campus__c();
            cms.Account__c = lisAcc1[0].id;
            cms.RecordTypeId=campid;
            cms.Homestay_Grade__c = 'K1';
            cms.Country_New__c = 'United States';
            cms.Student_taking_IB__c = 10;
            cms.Housing_Option__c='Homestay';
            cms.Province_State_New__c = 'Alabama';
            cms.Nearest_Big_City_New__c = 'Birmingham';
            cms.CurrencyIsoCode='USD';
            insert cms;
            
            Id  progid=Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('High School Program').getRecordTypeId();
            
            
            Program__c pgm=new Program__c();
            pgm.Program_Type__c = 'Bachelor';
            pgm.Est_Annual_Cost__c = 2000;
            pgm.recordTypeId=progid;
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
            
            Application = TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission paid';
            Application.Deposit_Amount__c = 12;
            Application.Program__c=pgm.id;
            Application.Campus__c=cms.id;
            Application.Reason_Of_Rejection__c = 'Tes';
            Application.Deposit_Payment_Instruction__c = 'Tesr';
            Application.Offer__c = 'Conditional';
            Application.Deposit_Due_date__c = System.today().addDays(3);
            Application.Deposit_Paid_Date__c = System.today();
            Application.Met_Conditions__c = true;
            Application.School__c=lisAcc1[0].Id;
            Application.Student_Confirm_Offer__c = 'Yes';
            Application.Met_Conditions__c = true;
            Application.Other_Conditions__c = 'Yes';
            Application.Program_Offered__c = 'Test';
            Application.Visa_Required__c = 'No';
            Application.Tuition_Stated_on_Offer__c = 12;
            Application.Conditions_Specificiation__c = 'Test';
            Application.Submit_Application_to_School_Date__c = System.today();
            Application.Opportunity__c = objOpp.Id;  
            Application.Allow_parallel_processing_of_Application__c = true;
            Application.Submit_Application_to_School_Date__c = date.today();
            Application.Student_Nationality_is_Commissionable__c = true;
            
            Case ApplicationOptOut = Application.clone( false, true, false, false );
            ApplicationOptOut.RecordTypeId = caseOptOutRecId;
            
            insert new List< Case > { ApplicationOptOut };
                
            
        }//end of portal user
        
        
    } 

//for partial creation of application ex out of two, only one application to be submitted.    
    public static testMethod void testmethod3(){
        
        system.debug('@@@@@@@--- ' + limits.getQueries());
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = [ SELECT Id, Name, CurrencyIsoCode, isActive__c, showDebugLogs__c, School_Tariff_Type__c, Student_Tariff_Type__c,
                                                                    Application_Tariff_Type__c, Contract_Status__c, Application_RecordType_Name_For_Approval__c,
                                                                    Error_Message_for_Insufficient_Amount__c, Application_RecordType_Name_Non_Approval__c, 
                                                                    Error_Message_for_No_Contract__c, Contract_Line_Item_Record_Name__c, Application_Approval_Process_Name__c,
                                                                    Application_StageName__c, System_Admin_Profile_Name__c, Account_Student_Record_Type_Name__c, Staff_Name_For_Portal_User__c,
                                                                    schoolNameValidationErrorOptIn__c, schoolNameValidationErrorOptOut__c, OptOutNotInDatabase__c,
                                                                    schoolNameValidationErrorMaxwayApp__c
                                                                    FROM ApplicationTrigger_checkPrepaidBalence__c ][0];
        List< Contract > listContract = [ SELECT Id FROM Contract WHERE CurrencyIsoCode = 'USD' ];
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
        
         list< Contract_Item__c > listContractItem = [ SELECT Id FROM Contract_Item__c WHERE Contract__c =: listContract[0].Id ];
         listContractItem[0].Opt_Out_NIN__c = 4;
         update listContractItem;
         
         User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        Opportunity objOpp = [ SELECT Id FROM Opportunity WHERE RecordType.Name =:ConstantsClass.renAgntRecTypeName LIMIT 1 ][0];
        Id caseOptOutRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptOutRecTypeName).getRecordTypeId(); 
        String applicationId;
        Approval.ProcessResult approvalProcessSubmit;
        Case Application;
        OpportunityShare sh = new OpportunityShare();
        sh.OpportunityId=objOpp.Id;
        sh.UserOrGroupId=partnerUser.Id;
        sh.OpportunityAccessLevel='Edit';
        insert sh;
        System.runAs( partnerUser ){
            
            list< Staff__c  >ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List < Account >lisAcc1 = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
            lisAcc1[0].Account_Manager__c = ListStaff[0].Id;
            lisAcc1[0].Approval_Status__c='Approved';
            insert lisAcc1;
            
            Id campid=Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('High School - Campus').getRecordTypeId();
            
            Campus__c cms=new Campus__c();
            cms.Account__c = lisAcc1[0].id;
            cms.RecordTypeId=campid;
            cms.Homestay_Grade__c = 'K1';
            cms.Country_New__c = 'United States';
            cms.Student_taking_IB__c = 10;
            cms.Housing_Option__c='Homestay';
            cms.Province_State_New__c = 'Alabama';
            cms.Nearest_Big_City_New__c = 'Birmingham';
            cms.CurrencyIsoCode='USD';
            insert cms;
            
            Id  progid=Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('High School Program').getRecordTypeId();
            
            
            Program__c pgm=new Program__c();
            pgm.Program_Type__c = 'Bachelor';
            pgm.Est_Annual_Cost__c = 2000;
            pgm.recordTypeId=progid;
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
            
            Application = TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission paid';
            Application.Deposit_Amount__c = 12;
            Application.Program__c=pgm.id;
            Application.Campus__c=cms.id;
            Application.Reason_Of_Rejection__c = 'Tes';
            Application.Deposit_Payment_Instruction__c = 'Tesr';
            Application.Offer__c = 'Conditional';
            Application.Deposit_Due_date__c = System.today().addDays(3);
            Application.Deposit_Paid_Date__c = System.today();
            Application.Met_Conditions__c = true;
            Application.School__c=lisAcc1[0].Id;
            Application.Student_Confirm_Offer__c = 'Yes';
            Application.Met_Conditions__c = true;
            Application.Other_Conditions__c = 'Yes';
            Application.Program_Offered__c = 'Test';
            Application.Visa_Required__c = 'No';
            Application.Tuition_Stated_on_Offer__c = 12;
            Application.Conditions_Specificiation__c = 'Test';
            Application.Submit_Application_to_School_Date__c = System.today();
            Application.Opportunity__c = objOpp.Id;  
            Application.Allow_parallel_processing_of_Application__c = true;
            Application.Submit_Application_to_School_Date__c = date.today();
            Application.Student_Nationality_is_Commissionable__c = true;
            
            Case ApplicationOptOut = Application.clone( false, true, false, false );
            ApplicationOptOut.RecordTypeId = caseOptOutRecId;
            
            insert new List< Case > { ApplicationOptOut , ApplicationOptOut.clone( false, true, false, false )};
                
            
        }//end of portal user
        
        
    } 
    
    //for no contract found
    public static testMethod void testmethod4(){
        
        system.debug('@@@@@@@--- ' + limits.getQueries());
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = [ SELECT Id, Name, CurrencyIsoCode, isActive__c, showDebugLogs__c, School_Tariff_Type__c, Student_Tariff_Type__c,
                                                                    Application_Tariff_Type__c, Contract_Status__c, Application_RecordType_Name_For_Approval__c,
                                                                    Error_Message_for_Insufficient_Amount__c, Application_RecordType_Name_Non_Approval__c, 
                                                                    Error_Message_for_No_Contract__c, Contract_Line_Item_Record_Name__c, Application_Approval_Process_Name__c,
                                                                    Application_StageName__c, System_Admin_Profile_Name__c, Account_Student_Record_Type_Name__c, Staff_Name_For_Portal_User__c,
                                                                    schoolNameValidationErrorOptIn__c, schoolNameValidationErrorOptOut__c, OptOutNotInDatabase__c,
                                                                    schoolNameValidationErrorMaxwayApp__c
                                                                    FROM ApplicationTrigger_checkPrepaidBalence__c ][0];
        List< Contract > listContract = [ SELECT Id FROM Contract WHERE CurrencyIsoCode = 'USD' ];
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        delete listContract;
        
        // list< Contract_Item__c > listContractItem = [ SELECT Id FROM Contract_Item__c WHERE Contract__c =: listContract[0].Id ];
         //listContractItem[0].Opt_Out_NIN__c = 4;
         //update listContractItem;
         
         User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        Opportunity objOpp = [ SELECT Id FROM Opportunity WHERE RecordType.Name =:ConstantsClass.renAgntRecTypeName LIMIT 1 ][0];
        Id caseOptOutRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptOutRecTypeName).getRecordTypeId(); 
        String applicationId;
        Approval.ProcessResult approvalProcessSubmit;
        Case Application;
        OpportunityShare sh = new OpportunityShare();
        sh.OpportunityId=objOpp.Id;
        sh.UserOrGroupId=partnerUser.Id;
        sh.OpportunityAccessLevel='Edit';
        insert sh;
        System.runAs( partnerUser ){
            
            list< Staff__c  >ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List < Account >lisAcc1 = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
            lisAcc1[0].Account_Manager__c = ListStaff[0].Id;
            lisAcc1[0].Approval_Status__c='Approved';
            insert lisAcc1;
            
            Id campid=Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('High School - Campus').getRecordTypeId();
            
            Campus__c cms=new Campus__c();
            cms.Account__c = lisAcc1[0].id;
            cms.RecordTypeId=campid;
            cms.Homestay_Grade__c = 'K1';
            cms.Country_New__c = 'United States';
            cms.Student_taking_IB__c = 10;
            cms.Housing_Option__c='Homestay';
            cms.Province_State_New__c = 'Alabama';
            cms.Nearest_Big_City_New__c = 'Birmingham';
            cms.CurrencyIsoCode='USD';
            insert cms;
            
            Id  progid=Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('High School Program').getRecordTypeId();
            
            
            Program__c pgm=new Program__c();
            pgm.Program_Type__c = 'Bachelor';
            pgm.Est_Annual_Cost__c = 2000;
            pgm.recordTypeId=progid;
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
            
            Application = TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission paid';
            Application.Deposit_Amount__c = 12;
            Application.Program__c=pgm.id;
            Application.Campus__c=cms.id;
            Application.Reason_Of_Rejection__c = 'Tes';
            Application.Deposit_Payment_Instruction__c = 'Tesr';
            Application.Offer__c = 'Conditional';
            Application.Deposit_Due_date__c = System.today().addDays(3);
            Application.Deposit_Paid_Date__c = System.today();
            Application.Met_Conditions__c = true;
            Application.School__c=lisAcc1[0].Id;
            Application.Student_Confirm_Offer__c = 'Yes';
            Application.Met_Conditions__c = true;
            Application.Other_Conditions__c = 'Yes';
            Application.Program_Offered__c = 'Test';
            Application.Visa_Required__c = 'No';
            Application.Tuition_Stated_on_Offer__c = 12;
            Application.Conditions_Specificiation__c = 'Test';
            Application.Submit_Application_to_School_Date__c = System.today();
            Application.Opportunity__c = objOpp.Id;  
            Application.Allow_parallel_processing_of_Application__c = true;
            Application.Submit_Application_to_School_Date__c = date.today();
            Application.Student_Nationality_is_Commissionable__c = true;
            
            Case ApplicationOptOut = Application.clone( false, true, false, false );
            ApplicationOptOut.RecordTypeId = caseOptOutRecId;
            
            insert new List< Case > { ApplicationOptOut , ApplicationOptOut.clone( false, true, false, false )};
                
            
        }//end of portal user
        
        
    } 
    
    //for populateCommissionAndAppManger
    public static testMethod void testmethod5(){
        
        system.debug('@@@@@@@--- ' + limits.getQueries());
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = [ SELECT Id, Name, CurrencyIsoCode, isActive__c, showDebugLogs__c, School_Tariff_Type__c, Student_Tariff_Type__c,
                                                                    Application_Tariff_Type__c, Contract_Status__c, Application_RecordType_Name_For_Approval__c,
                                                                    Error_Message_for_Insufficient_Amount__c, Application_RecordType_Name_Non_Approval__c, 
                                                                    Error_Message_for_No_Contract__c, Contract_Line_Item_Record_Name__c, Application_Approval_Process_Name__c,
                                                                    Application_StageName__c, System_Admin_Profile_Name__c, Account_Student_Record_Type_Name__c, Staff_Name_For_Portal_User__c,
                                                                    schoolNameValidationErrorOptIn__c, schoolNameValidationErrorOptOut__c, OptOutNotInDatabase__c,
                                                                    schoolNameValidationErrorMaxwayApp__c
                                                                    FROM ApplicationTrigger_checkPrepaidBalence__c ][0];
        List< Contract > listContract = [ SELECT Id FROM Contract WHERE CurrencyIsoCode = 'USD' ];
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
        
        User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        Opportunity objOpp = [ SELECT Id FROM Opportunity WHERE RecordType.Name =:ConstantsClass.renAgntRecTypeName LIMIT 1 ][0];
        Id caseOptOutRecId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptOutRecTypeName).getRecordTypeId(); 
        String applicationId;
        Approval.ProcessResult approvalProcessSubmit;
        Case Application;
        OpportunityShare sh = new OpportunityShare();
        sh.OpportunityId=objOpp.Id;
        sh.UserOrGroupId=partnerUser.Id;
        sh.OpportunityAccessLevel='Edit';
        insert sh;
        System.runAs( partnerUser ){
            
            list< Staff__c  >ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List < Account >lisAcc1 = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
            lisAcc1[0].Account_Manager__c = ListStaff[0].Id;
            lisAcc1[0].Approval_Status__c='Approved';
            insert lisAcc1;
            
            Id campid=Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('High School - Campus').getRecordTypeId();
            
            Campus__c cms=new Campus__c();
            cms.Account__c = lisAcc1[0].id;
            cms.RecordTypeId=campid;
            cms.Homestay_Grade__c = 'K1';
            cms.Country_New__c = 'United States';
            cms.Student_taking_IB__c = 10;
            cms.Housing_Option__c='Homestay';
            cms.Province_State_New__c = 'Alabama';
            cms.Nearest_Big_City_New__c = 'Birmingham';
            cms.CurrencyIsoCode='USD';
            insert cms;
            
            Id  progid=Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('High School Program').getRecordTypeId();
            
            
            Program__c pgm=new Program__c();
            pgm.Program_Type__c = 'Bachelor';
            pgm.Est_Annual_Cost__c = 2000;
            pgm.recordTypeId=progid;
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
            
            Application = TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission paid';
            Application.Deposit_Amount__c = 12;
            Application.Program__c=pgm.id;
            Application.Campus__c=cms.id;
            Application.Reason_Of_Rejection__c = 'Tes';
            Application.Deposit_Payment_Instruction__c = 'Tesr';
            Application.Offer__c = 'Conditional';
            Application.Deposit_Due_date__c = System.today().addDays(3);
            Application.Deposit_Paid_Date__c = System.today();
            Application.Met_Conditions__c = true;
            Application.School__c=lisAcc1[0].Id;
            Application.Student_Confirm_Offer__c = 'Yes';
            Application.Met_Conditions__c = true;
            Application.Other_Conditions__c = 'Yes';
            Application.Program_Offered__c = 'Test';
            Application.Visa_Required__c = 'No';
            Application.Tuition_Stated_on_Offer__c = 12;
            Application.Conditions_Specificiation__c = 'Test';
            Application.Submit_Application_to_School_Date__c = System.today();
            Application.Opportunity__c = objOpp.Id;  
            Application.Allow_parallel_processing_of_Application__c = true;
            Application.Submit_Application_to_School_Date__c = date.today();
            Application.Student_Nationality_is_Commissionable__c = true;
            
            
            insert new List< Case > { Application };
                
            ApplicationTriggerHelper.populateCommissionAndAppManger( new List< Case > { Application } , true, objTestSetting, true );
            
        }//end of portal user
    } 
}