@isTest
public class QueuebleDectivateUserTest 
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
    
    //------------------------------------------------------------  Testing when Active Contract not found for Portal User  -------------------------------------------------------------------
    public static testMethod void testRecordCreationFromPartnerWhenNoActiveContractFound(){
        
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
        
        QueuebleToUpdateDectivateUser obj=new QueuebleToUpdateDectivateUser();
        QueuebleToUpdateDectivateUser.doChainJob=false;
    		Test.startTest();
            System.enqueueJob(obj);
          Test.stopTest();

    } 
    
    
   
}