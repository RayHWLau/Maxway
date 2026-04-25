@isTest
public class TestBatchClassToDeleteAgentDocs
{    
       @testSetup
    public static void createTestData(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        Profile objSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false );
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        system.runAs( systemAdminUser ){
            
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
            lisacc[0].Active_License__c=5;
            lisacc[0].License_End_Date__c=system.today()-1;
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            TestUtil.createInvoice('Agent', true, 1);
            TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
        }
    }
    
        public static testMethod void testili(){
        
     //   InvoiceTrigger_RollUpInvoiceAmount__c objTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
     //   Invoice__c objInvoice = [ SELECT Id,company_name__c from Invoice__c LIMIT 1];
        
     
        
       // insert ili;
        Case Application;
        
       // List <Staff__c> ListStaff = [ SELECT Id from Staff__c LIMIT 1];
        Invoice__c objInvoice1;
        
        Contact objCon = [ SELECT  Id,accountId FROM Contact LIMIT 1 ];    
        User partnerUser = [ SELECT Id,IsPortalEnabled FROM User WHERE LastName = 'partnerUser' ];
        
        system.runAs( partnerUser ){
       
             List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
            insert lisOpp;
            
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
            
            Application = TestUtil.createApplication('Application(Opt-In)', false, 1)[0];
            Application.Stage__c = 'Commission Received';
            Application.Status = 'Commission Received';
            Application.Deposit_Amount__c = 12;
            Application.Opportunity__c = lisOpp[0].id;
            Application.OwnerId = partnerUser.id;
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
            
            document_upload__c docUpld = new document_upload__c();
            docUpld.Name = 'TestUpload';
            //    docUpld.Document_Master__c = dm.Id;
            docUpld.Application__c = Application.Id;
            docUpld.Opportunity__c = lisOpp[0].id;
            insert docUpld;
            
            Invoice__c obj = TestUtil.createInvoice('Agent', false, 1)[0];
            
            obj.Status__c = 'Issued';
            obj.Company_Name__c = lisacc[0].id;
            insert obj;
			
			            
         
            test.stopTest();
        }
        partnerUser.IsActive = false;
            update partnerUser;
     Database.executeBatch(new BatchClassToDeleteAgentDocs());
    }
    
    
@isTest
public static void startMethod()
{
    Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    System.debug('profileId==='+profileId);
    
    User usr = new User(LastName = 'LIVESTON1',
                        FirstName='JASON1',
                        Alias = 'jliv1',
                        Email = 'jason21111.liveston@asdf.com',
                        Username = 'jason211.liveston@asdf.com',
                        ProfileId = profileId.id,
                        TimeZoneSidKey = 'GMT',
                        LanguageLocaleKey = 'en_US',
                        EmailEncodingKey = 'UTF-8',
                        LocaleSidKey = 'en_US',
                        isActive=true,
                        doc_deleted__c = false
                       );

    insert usr;
   //sr.IsPortalEnabled = true;
   //pdate usr;
    System.debug('isPort'+usr.IsPortalEnabled);
    list<Case> cs;

    System.RunAs(usr) {
        Opportunity opp=TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1)[0];
        System.debug('Opportunity==>'+opp.id);
        
        cs=TestUtil.createApplication('Application(Opt-In)', false, 1);
        cs[0].OwnerId=usr.id;
        cs[0].Opportunity__c=opp.id;
        cs[0].Status = 'In Progress';
        cs[0].Placed_Grade__c = 'Grade 3';
        cs[0].Term__c = 'Fall';
        cs[0].Year__c = '2011';
        cs[0].Start_Year_Year__c='2011';
        cs[0].Start_Month__c='May';
        insert cs;
        System.debug('Case==='+cs[0].OwnerId+'Opportunity==>'+cs[0].Opportunity__c);
    }
    usr.isActive=false;
  System.debug('Before IsPortalEnabled'+usr.IsPortalEnabled );
    update usr;
      usr.IsPortalEnabled = true;
    update usr;
    System.debug('After IsPortalEnabled'+usr.IsPortalEnabled );
    Test.startTest();
        BatchClassToDeleteAgentDocs x = new BatchClassToDeleteAgentDocs();
        database.executeBatch(x);
        Test.stopTest();


System.debug('user---->'+usr.IsActive+'Doc_Deleted__c'+usr.Doc_Deleted__c+'===='+usr.IsPortalEnabled+''+usr.id);
Case c=[Select Ownerid from Case];
    System.debug([Select id, isActive,doc_deleted__c,isportalenabled from User where id=:c.ownerid]);
list<Case> cs1=[select id,Opportunity__c,ownerid from case where ownerid in (select id from user where isactive=false and doc_deleted__c = false and isportalenabled =true)];
		System.debug(cs1);

}
   
   
}