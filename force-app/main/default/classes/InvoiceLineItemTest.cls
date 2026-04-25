@isTest
public class InvoiceLineItemTest {
    @testSetup
    public static void createTestData(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objProfile.Id, false ); 
        system.runAs( systemAdminUser ){
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            lisacc[0].Account_Manager__c = ListStaff[0].Id;
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            Invoice__c obj = TestUtil.createInvoice('Agent', false, 1)[0];
            //  obj.Payment_Receiver__c=ListStaff[0].id;
            //  obj.Payment_Method_Description__c='test';
            //obj.Mode_Of_Payment__c='Cash';
            // obj.Amount_Received__c=50000;
            // obj.Invoiced_Amount__c=50000;
            obj.Company_Name__c = lisacc[0].id;
            insert obj;
            
          
        }
    }
    
    public static testMethod void testili(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
        Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
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
           
            List<Case> caseId = new List<Case>();
            Case cs = new Case();
             cs.Status = 'In Progress';
                    cs.Placed_Grade__c = 'Grade 3';
                    cs.Term__c = 'Fall';
                    cs.Year__c = '2011';
                   cs.Start_Year_Year__c='2011';
                    cs.Start_Month__c='May';
            caseId.add(cs);
            insert caseId;
            
            
           // InvoiceLineItem.getarrivedapplication(objInvoice.id);
     //       InvoiceLineItem.appwrapper();
          //  InvoiceLineItem.saveinvoicelineitem(caseId[0].id, amountwithid, objInvoice);
            
        }
    }
}