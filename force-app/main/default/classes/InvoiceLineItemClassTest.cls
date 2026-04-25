@isTest
public class InvoiceLineItemClassTest {
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
    
    public static testMethod void testili(){
        
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
        InvoiceLineItem.getarrivedapplication(objInvoice1.id);
    }
    
    public static testMethod void testili2(){
        
        string s = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('School').getRecordTypeId();
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        
        ili.Invoice__c=objInvoice.Id;
        ili.Amount__c=20000;
        
        insert ili;
        Case Application;
        
        List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        Invoice__c objInvoice1;
        Invoice__c objInvoice2;
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id from User WHERE LastName = 'testInvoice' ];
        
        system.runAs( partnerUser ){
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            
            insert lisacc;
            
            
            List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'HQ Admin';
            insert ListStaff1;
            
            List< Account > listAccntSchl = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
            listAccntSchl[0].Account_Manager__c = ListStaff1[0].Id;
            insert listAccntSchl;
            
            objInvoice1 = new Invoice__c(); 
            
            objInvoice1.Account__c = objCon.accountid ;
            
            objInvoice1.RecordTypeId = s;
            
            objInvoice1.Invoice_Type__c = 'Commission To School';
            
            objInvoice1.Status__c='Issued';
            objInvoice1.Invoiced_Amount__c=20000;
            

			objInvoice2  = objInvoice1.clone( false, true, false, false );
            objInvoice2.Account__c = listAccntSchl[0].Id;
            
            insert new List< Invoice__c > {  objInvoice1, objInvoice2 };
            Test.startTest();
            Invoice_Line_Item__c ili1 = new Invoice_Line_Item__c();
            ili1.Invoice__c=objInvoice1.Id;
            ili1.Amount__c=20000;
            insert ili1;
            
            Application = TestUtil.createApplication('Application(Opt-Out/NIN/Maxway)', false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Arrived';
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
            Application.School__c = listAccntSchl[0].Id;
            Application.Application_Type__c = 'Not in Database';
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
            
            InvoiceLineItem.getarrivedapplication(objInvoice2.id);
            
            InvoiceLineItem.saveinvoicelineitem( new List< String >{ Application.Id } , new List< String >{ Application.Id+';100' }, objInvoice2.Id);
            test.stopTest();
        }
        InvoiceLineItem.getarrivedapplication(objInvoice1.id);
        
        
        
    }
}