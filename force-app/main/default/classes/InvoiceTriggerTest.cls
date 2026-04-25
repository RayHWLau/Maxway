/**
* @File Name : InvoiceTriggerTest.cls
* @Description : 
* @Author : Karan Singh Soni
* @Apex Trigger : InvoiceTrigger
* @Last Modified By : Karan Singh Soni
* @Last Modified On : 29 Jan 2020
* @Modification Log :
*==============================================================================
* Ver Date Author Modification
*==============================================================================
* 1.0  29 Jan 2020 Initial Version
**/
@isTest
public class InvoiceTriggerTest {
    
    //-----------------------------------------------------------------  Creation of Test Data  -----------------------------------------------------------------------------------
   @testSetup
    public static void createTestData(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objProfile.Id, false ); 
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        
        system.runAs( systemAdminUser ){
            
           
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            lisacc[0].Account_Manager__c = ListStaff[0].Id;
            lisacc[0].Total_Admin_License__c = 15;
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            Invoice__c obj = TestUtil.createInvoice('Agent', false, 1)[0];
            
           
            
            obj.Status__c = 'Issued';
            obj.Company_Name__c = lisacc[0].id;
            insert obj;
            
            User u = TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, false );
            u.LastName = 'testInvoice';
            insert u;
            
        }
    }
    
    public static testMethod void testITH(){
        
         string s=Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        
        insert ili;
        Case Application;
        
        List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
             List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'Partner';
            ListStaff1[0].OwnerId = partnerUser.id;
            insert ListStaff1;
            
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            
            insert lisacc;
            
            objInvoice1 = TestUtil.createInvoice('Agent', false, 1)[0]; 
            
            objInvoice1.Company_Name__c = objCon.accountid ;
            
            objInvoice1.Invoice_Type__c = 'Commission Payable To Agent';
             objInvoice1.RecordTypeId = s;
            objInvoice1.Issuing_Staff__c = ListStaff1[0].id;
            
            objInvoice1.Status__c='Issued';
            objInvoice1.Invoiced_Amount__c=20000;
            
            insert objInvoice1;
            
            Test.startTest();
            Invoice_Line_Item__c ili1 = new Invoice_Line_Item__c();
            ili1.Invoice__c=objInvoice1.Id;
            ili1.Amount__c=20000;
            insert ili1;
            
            Application = TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission Received';
            Application.Deposit_Amount__c = 12;
            
            Application.Reason_Of_Rejection__c = 'Tes';
            Application.Deposit_Payment_Instruction__c = 'Tesr';
            Application.Offer__c = 'Conditional';
            Application.Deposit_Due_date__c = System.today().addDays(3);
            Application.Deposit_Paid_Date__c = System.today();
            Application.Met_Conditions__c = true;
            Application.School__c=lisacc[0].Id;
            Application.Student_Confirm_Offer__c = 'Yes';
            Application.Met_Conditions__c = true;
            Application.Other_Conditions__c = 'Yes';
            Application.Program_Offered__c = 'Test';
            Application.Visa_Required__c = 'No';
            Application.Tuition_Stated_on_Offer__c = 12;
            Application.Conditions_Specificiation__c = 'Test';
            Application.Submit_Application_to_School_Date__c = System.today();
            
            Application.Allow_parallel_processing_of_Application__c = true;
            Application.Submit_Application_to_School_Date__c = date.today();
            Application.Student_Nationality_is_Commissionable__c = true;
            insert Application;
            
            Invoice__c obj = TestUtil.createInvoice('Agent', false, 1)[0];
            
            obj.Status__c = 'Issued';
            obj.Company_Name__c = lisacc[0].id;
            insert obj;
            
            List<String> lst = new List<String>();
            
            
            InvoiceLineItem.appwrapper app = new InvoiceLineItem.appwrapper();
            app.appnumber = '123';
            app.appid = '';
            app.amount = '1234';
            app.studentId ='';
            app.studentName = 'Ram';
            app.opportunityStage ='';
            app.opportunityName = 'TestOpp';
            app.applicationStage ='';
            app.curency ='';
            app.existInvLineId ='';
            app.commission ='';
            InvoiceLineItem.saveinvoicelineitem(lst, lst, obj.id);
            test.stopTest();
        }
       // InvoiceTriggerHelper.rollupInvoiceAmount();
    }
    
      public static testMethod void testRollUpFunctionality(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id from Invoice__c LIMIT 1];
        
        
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       // ili.Name='test';
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        //ili.CurrencyIsoCode='';
         insert ili;
        
        //Invoice_Line_Item__c objili=[SELECT Id from Invoice_Line_Item__c LIMIT 1];
        
       List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        
        
        
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User objSystemAdmin = [ SELECT Id from User WHERE LastName = 'Invoice last' ];
        
        system.runAs( objSystemAdmin ){
            
            objInvoice.Company_Name__c = objcon.AccountId ;
            objInvoice.Amount_Received__c = 20000;
            objInvoice.Invoice_Type__c = objTestSetting.Invoice_Type__c;
            objInvoice.Status__c = objTestSetting.Status__c;
            objInvoice.Mode_Of_Payment__c = 'Cash';
            objInvoice.Status__c='Paid';
            objInvoice.Invoiced_Amount__c=20000;
           // objInvoice.CurrencyIsoCode='INR';
            objInvoice.Payment_Receiver__c=ListStaff[0].id;
            objInvoice.Payment_Method_Description__c='test';
                
                
                update objInvoice;
            
            update ili;
            
        }
    }
    
      public static testMethod void testRollUpFunctionality2(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id from Invoice__c LIMIT 1];
        
        
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       // ili.Name='test';
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        //ili.CurrencyIsoCode='';
         insert ili;
        
        //Invoice_Line_Item__c objili=[SELECT Id from Invoice_Line_Item__c LIMIT 1];
        
       List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        
        
        
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User objSystemAdmin = [ SELECT Id from User WHERE LastName = 'Invoice last' ];
        
        system.runAs( objSystemAdmin ){
            
            objInvoice.Company_Name__c = objcon.AccountId ;
          //  objInvoice.Amount_Received__c = 20000;
            objInvoice.Invoice_Type__c = 'Commission Payable To Agent';
          //  objInvoice.Status__c = objTestSetting.Status__c;
          //  objInvoice.Mode_Of_Payment__c = 'Cash';
            objInvoice.Status__c='Issued';
            objInvoice.Invoiced_Amount__c=20000;
           // objInvoice.CurrencyIsoCode='INR';
           // objInvoice.Payment_Receiver__c=ListStaff[0].id;
        //    objInvoice.Payment_Method_Description__c='test';
                
                
                update objInvoice;
            
            update ili;
            
        }
    }
    
     public static testMethod void testRollUpFunctionality3(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id from Invoice__c LIMIT 1];
        
        
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       // ili.Name='test';
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        //ili.CurrencyIsoCode='';
         insert ili;
        
        //Invoice_Line_Item__c objili=[SELECT Id from Invoice_Line_Item__c LIMIT 1];
        
       List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        
        
        
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User objSystemAdmin = [ SELECT Id from User WHERE LastName = 'Invoice last' ];
        
        system.runAs( objSystemAdmin ){
            
            objInvoice.Company_Name__c = objcon.AccountId ;
          //  objInvoice.Amount_Received__c = 20000;
            objInvoice.Invoice_Type__c = 'Commission Payable To Agent';
          //  objInvoice.Status__c = objTestSetting.Status__c;
          //  objInvoice.Mode_Of_Payment__c = 'Cash';
            objInvoice.Status__c='Void';
            objInvoice.Invoiced_Amount__c=20000;
           // objInvoice.CurrencyIsoCode='INR';
           // objInvoice.Payment_Receiver__c=ListStaff[0].id;
        //    objInvoice.Payment_Method_Description__c='test';
                
                
                update objInvoice;
            
            update ili;
            
        }
    }
    
     public static testMethod void testRollUpFunctionality4(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id from Invoice__c LIMIT 1];
        
        
       Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
       // ili.Name='test';
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        //ili.CurrencyIsoCode='';
         insert ili;
        
        //Invoice_Line_Item__c objili=[SELECT Id from Invoice_Line_Item__c LIMIT 1];
        
       List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        
        
        
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User objSystemAdmin = [ SELECT Id from User WHERE LastName = 'Invoice last' ];
        
        system.runAs( objSystemAdmin ){
            
            objInvoice.Company_Name__c = objcon.AccountId ;
            objInvoice.Amount_Received__c = 19000;
            objInvoice.Invoice_Type__c = 'Commission Payable To Agent';
          //  objInvoice.Status__c = objTestSetting.Status__c;
            objInvoice.Mode_Of_Payment__c = 'Cash';
            objInvoice.Status__c='Outstanding';
            objInvoice.Invoiced_Amount__c=20000;
           // objInvoice.CurrencyIsoCode='INR';
            objInvoice.Payment_Receiver__c=ListStaff[0].id;
            objInvoice.Payment_Method_Description__c='test';
                
                
                update objInvoice;
            
            update ili;
            
        }
    }
    
     public static testMethod void test1(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        
        insert ili;
        Case Application;
        
        List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            
            insert lisacc;
            
            objInvoice1 = TestUtil.createInvoice('Agent', false, 1)[0]; 
            
            objInvoice1.Company_Name__c = objCon.accountid ;
            
            objInvoice1.Invoice_Type__c = 'Commission Payable To Agent';
            
            objInvoice1.Status__c='void';
            objInvoice1.Invoiced_Amount__c=20000;
            
            insert objInvoice1;
            Test.startTest();
            Invoice_Line_Item__c ili1 = new Invoice_Line_Item__c();
            ili1.Invoice__c=objInvoice1.Id;
            ili1.Amount__c=20000;
            insert ili1;
        
        }
       // InvoiceTriggerHelper.rollupInvoiceAmount();
    }
    
      public static testMethod void test2(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        
        insert ili;
        Case Application;
        
      //  List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            
            insert lisacc;
            
            objInvoice1 = TestUtil.createInvoice('Agent', false, 1)[0]; 
            
            objInvoice1.Company_Name__c = objcon.AccountId ;
            objInvoice1.Amount_Received__c = 20000;
           
            objInvoice1.Mode_Of_Payment__c = 'Cash';
            objInvoice1.Status__c='Paid';
            objInvoice1.Invoiced_Amount__c=20000;
           // objInvoice.CurrencyIsoCode='INR';
            objInvoice1.Payment_Receiver__c=ListStaff[0].id;
            objInvoice1.Payment_Method_Description__c='test';
                
            
            insert objInvoice1;
            Test.startTest();
            Invoice_Line_Item__c ili1 = new Invoice_Line_Item__c();
            ili1.Invoice__c=objInvoice1.Id;
            ili1.Amount__c=20000;
            insert ili1;
        
        }
       // InvoiceTriggerHelper.rollupInvoiceAmount();
    }
    
      public static testMethod void test3(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        
        insert ili;
        Case Application;
        
      //  List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
             List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ';
            ListStaff[0].OwnerId = partnerUser.id;
            insert ListStaff;
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            
            insert lisacc;
            
            objInvoice1 = TestUtil.createInvoice('Agent', false, 1)[0]; 
            
            objInvoice1.Company_Name__c = objcon.AccountId ;
            objInvoice1.Amount_Received__c = 19000;
            objInvoice1.Invoice_Type__c = 'Commission Payable To Agent';
          //  objInvoice.Status__c = objTestSetting.Status__c;
            objInvoice1.Mode_Of_Payment__c = 'Cash';
            objInvoice1.Status__c='Outstanding';
            objInvoice1.Invoiced_Amount__c=20000;
           // objInvoice.CurrencyIsoCode='INR';
            objInvoice1.Payment_Receiver__c=ListStaff[0].id;
            objInvoice1.Payment_Method_Description__c='test';
                
            insert objInvoice1;
            Test.startTest();
            Invoice_Line_Item__c ili1 = new Invoice_Line_Item__c();
            ili1.Invoice__c=objInvoice1.Id;
            ili1.Amount__c=20000;
            insert ili1;
        
        }
       // InvoiceTriggerHelper.rollupInvoiceAmount();
    }
    
     public static testMethod void testmethod1(){
        
         string s=Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
             List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'Partner';
            ListStaff1[0].OwnerId = partnerUser.id;
            insert ListStaff1;
            
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            insert lisacc;
            
            objInvoice1 = TestUtil.createInvoice('Agent', false, 1)[0]; 
            objInvoice1.Company_Name__c = objCon.accountid ;
            objInvoice1.Invoice_Type__c = 'Commission Payable To Agent';
            objInvoice1.RecordTypeId = s;
            objInvoice1.Issuing_Staff__c = ListStaff1[0].id;
            objInvoice1.Status__c='Issued';
            objInvoice1.Invoiced_Amount__c=20000;
            
            insert objInvoice1;
            
        }
          objInvoice1.Status__c='Paid';
            objInvoice1.Amount_Received__c = 20000;
            objInvoice1.Mode_Of_Payment__c = 'Cash';
            objInvoice1.Payment_Receiver__c = objInvoice1.Issuing_Staff__c;
            objInvoice1.Payment_Method_Description__c = 'Test';
            update objInvoice1;
    }
    public static testMethod void testmethod2(){
        
         string s=Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
             List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'Partner';
            ListStaff1[0].OwnerId = partnerUser.id;
            insert ListStaff1;
            
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            insert lisacc;
            
            objInvoice1 = TestUtil.createInvoice('Agent', false, 1)[0]; 
            objInvoice1.Company_Name__c = objCon.accountid ;
            objInvoice1.Invoice_Type__c = 'Commission Payable To Agent';
            objInvoice1.RecordTypeId = s;
            objInvoice1.Issuing_Staff__c = ListStaff1[0].id;
            objInvoice1.Status__c='Issued';
            objInvoice1.Invoiced_Amount__c=20000;
            objInvoice1.Status__c='Paid';
            objInvoice1.Amount_Received__c = 20000;
            objInvoice1.Mode_Of_Payment__c = 'Cash';
            objInvoice1.Payment_Receiver__c = objInvoice1.Issuing_Staff__c;
            objInvoice1.Payment_Method_Description__c = 'Test';
            
            insert objInvoice1;
            
            Invoice__c objInvoice = objInvoice1.clone( false, true, false, false );
            objInvoice.Invoice_Type__c = 'License Fee';
            insert objInvoice;

			test.starttest();            
            update new List< Invoice__c >{ objInvoice1, objInvoice };
            test.stopTest();
        }
     
    }
}