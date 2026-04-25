@isTest
public class ContracttriggerTest {
 
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
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            TestUtil.createInvoice('Agent', true, 1);
            TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
        }
    }
    
    
     public static testMethod void testContract(){
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