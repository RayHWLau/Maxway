@isTest
public Without sharing class AccountTriggerHelperTest {
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
            
            AccountTrigger_checkPrepaidBalence__c objTestSetting1 = TestUtil.createCustomSettingAccountPrepaidBaln( true );
            
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
        test.stopTest();
    }
    
    public static testMethod void testMethod1(){
        
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
        
        String AccountId;
         Approval.ProcessResult approvalProcessSubmit;
        
        User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        
        system.runAs( partnerUser ){
            
            list< Staff__c  >ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List < Account >lisAcc1 = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
            lisAcc1[0].Account_Manager__c = ListStaff[0].Id;
            lisAcc1[0].Start_of_Academic_Month__c = 'January';
            insert lisAcc1;
            
            AccountId = lisAcc1[0].id;
             Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments( 'Submitting request for approval.' );
            req1.setObjectId( lisAcc1[0].id );
            
            req1.setSubmitterId( partnerUser.Id ); 
            
            req1.setProcessDefinitionNameOrId('CommunityNINAccountApproval');
            req1.setSkipEntryCriteria(true);
            
            Test.startTest();
            approvalProcessSubmit = Approval.process(req1);
            
            system.debug('@@@@@ -->  ' + approvalProcessSubmit.isSuccess() );
            
            /*List<Account> listAcc = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, false, 1);
            listAcc[0].Data_Origin__c  = 'H';
            listAcc[0].Account_Manager__c = ListStaff[0].Id;
            listAcc[0].Expected_Graduation_Date__c = Date.today();
            
            listAcc[0].PersonMailingStreet='test@yahoo.com';
            listAcc[0].PersonMailingPostalCode='12345';
            listAcc[0].PersonMailingCity='SFO';
            listAcc[0].PersonEmail='test@yahoo.com';
            listAcc[0].PersonHomePhone='1234567';
            listAcc[0].PersonMobilePhone='12345678';
            //insert listAcc;
            
             Contact con=TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, false, 1)[0];
            Opportunity opp = new Opportunity();
            opp.Expected_Graduation_Date__c = date.today();
            opp.Name = 'Test';
            list<String> lst=new list<String>();
            lst.add('Australia');
            lst.add('one');
            lst.add('two');
            
            OpportunityCustomScreenAura.saveOpportunity(JSON.serialize(listAcc[0]),JSON.serialize(con),JSON.serialize(con),JSON.serialize(opp),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst));
			*/
        }
        
        List<Id> newWorkItemIds = approvalProcessSubmit.getNewWorkitemIds();
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        Approval.ProcessResult result2 =  Approval.process(req2);
    }
    
    public static testMethod void testMethod2(){
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = UserInfo.getUserId();
        insert ListStaff; 
        
    	Account acct = new Account (
        	RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('School Agency').getRecordTypeId(),
        	Name = 'schoolAgencyUT',
            Chinese_Name__c = 'schoolAgencyUT',
            Account_Manager__c = ListStaff[0].Id
        );
        insert acct;
        delete acct;
    }
    
}