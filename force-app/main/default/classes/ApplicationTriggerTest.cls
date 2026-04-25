/**
* @File Name : ApplicationTriggerTest.cls
* @Description : 
* @Author : Karan Singh Soni
* @Apex Trigger : ApplicationTrigger,AccountPrepaidCalculate
* @Last Modified By : Karan Singh Soni
* @Last Modified On : 29 Jan 2020
* @Modification Log :
*==============================================================================
* Ver Date Author Modification
*==============================================================================
* 1.0  29 Jan 2020 Initial Version
**/
@isTest
public class ApplicationTriggerTest {
    
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
    
    //------------------------------------------------------------  Testing when Active Contract not found for Portal User  -------------------------------------------------------------------
    public static testMethod void testRecordCreationFromPartnerWhenNoActiveContractFound(){
                  TestUtil.createCustomSettingInvoiceRollUp(true);

        User partnerUser = [ SELECT Id,IsPortalEnabled FROM User WHERE LastName = 'partnerUser' ];
        system.debug('partnerUser---> ' + partnerUser.IsPortalEnabled);
        AccountTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingAccountPrepaidBaln( true );
        
        //-------------------------------------------------------------  Running as Partner User  ----------------------------------------------------------------------------------
        system.runAs( partnerUser ){
            
            String accountApprovalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(objTestSetting.Account_RecordType_Name_For_Approval__c.split(',')[0]).getRecordTypeId();
            String accountNonApprovalRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(objTestSetting.Account_RecordType_Name_Non_Approval__c).getRecordTypeId();
            
            try{
                Account objStudentAcc = TestUtil.createAccount( ConstantsClass.osUniRecTypeName, false, 1 )[0];
               
                
            }
            Catch ( Exception objExp ){
                system.debug('error--> '+ objExp.getMessage());
            }
        }
   
    } 
    
    public static testMethod void testRecordCreationFromPartnerForPrepaid(){
        
                 TestUtil.createCustomSettingInvoiceRollUp(true);

        User partnerUser = [ SELECT Id FROM User WHERE LastName = 'partnerUser' ];
       
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
       
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        InvoiceTrigger_RollUpInvoiceAmount__c objInvoiceTestSetting = TestUtil.createCustomSettingInvoiceRollUp( true );
       
        String applicationApprovalRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(objTestSetting.Application_RecordType_Name_For_Approval__c).getRecordTypeId();
        String applicationNonApprovalRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get(objTestSetting.Application_RecordType_Name_Non_Approval__c).getRecordTypeId();
            
        //for contract agent account must have opportunity
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
       
        String studentAndCommisionNationality  =  Account.Nationality__c.getDescribe().getPicklistValues()[0].getValue();
        List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
        ListStaff1[0].Name = 'HQ Admin';
        ListStaff1[0].OwnerId = userinfo.getUserId();
        insert ListStaff1;   
        update ListStaff1;
       
        List< Account > listUniversityAcc = TestUtil.createAccount(ConstantsClass.osUniRecTypeName, false, 1);
        listUniversityAcc[0].ownerId = userinfo.getUserId();
        listUniversityAcc[0].Account_Manager__c = ListStaff1[0].Id;
        insert listUniversityAcc;
         Case cs = new Case();
                    cs.Status = 'In Progress';
                    cs.Placed_Grade__c = 'Grade 3';
                    cs.Term__c = 'Fall';
                    cs.Year__c = '2011';
                   cs.Start_Year_Year__c='2011';
                    cs.Start_Month__c='May';
        			cs.School_Type__c = 'High School';
        cs.Housing__c = 'Homestay';
        cs.Intended_Grade__c = '11';
        insert cs;
        
       
        //AccountTrigger_checkPrepaidBalence__c acc = TestUtil.AccountTrigger_checkPrepaidBalence__c(true);
        //AccountPrepaidCalculate.calculatePrepaidBalence(listUniversityAcc[0].id,'Account');  
        TestUtil.createCommissionTable(1,listUniversityAcc[0].Id , true );
		
        Invoice__c objInvoice=new Invoice__c();        
        objInvoice.Amount_Received__c = 4;
        objInvoice.Invoiced_Amount__c = 4;
        objInvoice.Status__c ='Paid';
        objInvoice.Payment_Receiver__c = ListStaff1[0].id;
        objInvoice.Payment_Method_Description__c = 'Test';
        objInvoice.Mode_Of_Payment__c = 'Cash';
        objInvoice.Company_Name__c = objAgentAcc.Id;
        objInvoice.Invoice_Type__c = 'Commission To School';
        insert objInvoice;
      
        
       
        List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
        listContract[0].AccountId = objAgentAcc.Id;
        listContract[0].Opportunity__c = objOpp.Id;
        insert listContract;
        Test.startTest();
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
      // AccountPrepaidCalculate.calculatePrepaidBalence(listContract[0].id,'Account'); 
        
        list< Contract_Item__c > listContractItem = TestUtil.createContractItem( listContract[0].id, objTestSetting.Contract_Line_Item_Record_Name__c, 1, objTestSetting.Application_Tariff_Type__c, true );
       
        Approval.ProcessResult result;
        
        system.runAs( partnerUser ){
       
            Case objApprovalApplication = new Case();
            objApprovalApplication.Status = 'In Progress';
            objApprovalApplication.Placed_Grade__c = 'Grade 3';
            objApprovalApplication.Term__c = 'Fall';
            objApprovalApplication.Year__c = '2011';
        			objApprovalApplication.School_Type__c = 'High School';
        objApprovalApplication.Housing__c = 'Homestay';
        objApprovalApplication.Intended_Grade__c = '11';
            //objApprovalApplication.RecordTypeId = applicationApprovalRecordTypeID;
            objApprovalApplication.RecordTypeId = applicationApprovalRecordTypeID;
            objApprovalApplication.Start_Year_Year__c = '2020';
            objApprovalApplication.Start_Month__c = 'Jan';
            
            
            Case objApprovalApplicationApproval = objApprovalApplication.clone(false,true,false,false);
            objApprovalApplicationApproval.RecordTypeId = applicationNonApprovalRecordTypeID;
            
            insert  new List< Case > { objApprovalApplication, objApprovalApplicationApproval};
               update new List< Case > { objApprovalApplication, objApprovalApplicationApproval};            
            
            /*
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
            app.setObjectId(objApprovalApplication.Id);
            result = Approval.process(app);
            
            */
        }
        
        
        /*
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        //Approval.ProcessResult result2 =  Approval.process(req2);
        
        /*system.runAs( partnerUser ){
            
            Case objApprovalApplication = new Case();
            objApprovalApplication.Status = 'In Progress';
            objApprovalApplication.Placed_Grade__c = 'Grade 3';
            objApprovalApplication.Term__c = 'Fall';
            objApprovalApplication.Year__c = '2011';
            objApprovalApplication.RecordTypeId = applicationApprovalRecordTypeID;
            
            insert new List< Case > { objApprovalApplication, objApprovalApplication.clone( false, true, false, false )};
        }*/
        
       // objInvoice.Amount_Received__c = 4;
        //objInvoice.Invoiced_Amount__c = 4;
        //update objInvoice;
        
        /*system.runAs( partnerUser ){
            
            Case objApprovalApplication = new Case();
            objApprovalApplication.Status = 'In Progress';
            objApprovalApplication.Placed_Grade__c = 'Grade 3';
            objApprovalApplication.Term__c = 'Fall';
            objApprovalApplication.Year__c = '2011';
            objApprovalApplication.Start_Year_Year__c = '2020';
            objApprovalApplication.Start_Month__c = 'Jan';
            objApprovalApplication.RecordTypeId = applicationNonApprovalRecordTypeID;
            
            insert new List< Case > { objApprovalApplication, objApprovalApplication.clone( false, true, false, false )};
        }*/
        Test.stopTest();
        
    }
    
        
       public static testMethod void testNiNAccount(){
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
          User partnerUser = [ SELECT Id FROM User WHERE LastName = 'partnerUser' ];
          Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
          Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
           
             List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
        listContract[0].AccountId = objAgentAcc.Id;
        listContract[0].Opportunity__c = objOpp.Id;
           listContract[0].CurrencyIsoCode='USD';
        insert listContract;
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
       
        Test.startTest();
        list< Contract_Item__c > listContractItem = TestUtil.createContractItem( listContract[0].id, objTestSetting.Contract_Line_Item_Record_Name__c, 1, objTestSetting.School_Tariff_Type__c, false );
       			//listContractItem[0].Unit_Price__c=0;
           insert listContractItem;
           

          system.runAs(partnerUser){
             //Account acc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
              
            NINAccountApproval.returnprice( TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0].Id);
              NINAccountApproval.lightningapproval( TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0].Id);
              
        }
          
           
       }
   
    
    
    
}