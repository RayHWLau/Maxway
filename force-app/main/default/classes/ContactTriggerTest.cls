@isTest
public class ContactTriggerTest {
    
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
            lisacc[0].Approval_Status__c = 'Rejected';
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            TestUtil.createInvoice('Agent', true, 1);
            TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
        }
    }
    
    public static testMethod void testCon(){
        
        Account objAgentAcc = [ SELECT Id,Approval_Status__c FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;  
        
        User partnerUser = [ SELECT Id, contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        
        System.runAs(partnerUser){
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, true, 1);            
            liscon[0].AccountId = objAgentAcc.Id;
            update liscon;
        }        
    }
}