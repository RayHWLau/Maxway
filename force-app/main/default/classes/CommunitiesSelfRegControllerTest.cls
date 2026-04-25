@IsTest
public class CommunitiesSelfRegControllerTest {
    
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
            insert obj;            
            
        }
    }
    
    
    @IsTest
    public static void testCommunitiesSelfRegController() {
        CommunitiesSelfRegController controller = new CommunitiesSelfRegController();
        controller.firstName = 'FirstName';
        controller.lastName = 'LastName';
        controller.email = 'test@force.com';
        controller.communityNickname = 'test';
        
        System.assert(controller.registerUser() == null);           
        
        controller.password = 'abcd1234';
        controller.confirmPassword = 'abcd123';
        System.assert(controller.registerUser() == null);  
    }  
    
    static testMethod void UserIdTest() {
        
        List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
        
        lisacc[0].Total_Admin_License__c = 10;
        lisacc[0].Total_User_License__c = 10;
        insert lisacc;
        
        List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
        
        liscon[0].AccountId = lisacc[0].Id;
        insert liscon; 
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin'];
        
        User PoratalUser = TestUtil.createPartnerUser(liscon[0].Id, objProfile.Id, false ); 
        system.runAs( PoratalUser ){  
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = PoratalUser.id;
            insert ListStaff;
            
            /*   List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
lisacc[0].ownerId = systemAdminUser.id;
lisacc[0].School_List_Purchased__c = '';
lisacc[0].Account_Manager__c = ListStaff[0].Id;
insert lisacc;

List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);

liscon[0].AccountId = lisacc[0].Id;
insert liscon; */
            
            List<Opportunity> oppLis = TestUtil.createOpportunity(ConstantsClass.renAgntRecTypeName, false, 1);
            insert oppLis;
            List<Case> lisCase = TestUtil.createApplication(ConstantsClass.caseOptOutRecTypeName, false, 1);
            insert lisCase;
            
            Invoice__c obj = TestUtil.createInvoice('Agent', false, 1)[0];
            //  obj.Payment_Receiver__c=ListStaff[0].id;
            //  obj.Payment_Method_Description__c='test';
            //obj.Mode_Of_Payment__c='Cash';
            // obj.Amount_Received__c=50000;
            // obj.Invoiced_Amount__c=50000;
            insert obj;            
            
            String userId ='jhjhfkdjhf';
            
            test.startTest();		   
            //   String userId = Site.createExternalUser(PoratalUser, lisacc[0].Id, 'abc123!'); 
            System.debug('UserID:++++==============================>>>>>>>>>>>>>>>>>> ' + userId);
            test.stopTest(); 
            
            //User testU = [select Id, Title from User where IsActive = TRUE limit 1];
            //testU.Title = testU.Title;
            //Update testU;                  
            
        }  
    }
    
    
    //Added 8 June 2020
    //___________________________________________________________________________________________________________________________________________________________
    
    public static testMethod Void testMethod1(){
        
        list< Profile > listGuestProfile = [ SELECT Id FROM Profile WHERE Name = 'Guest License User' ];
        
        if( listGuestProfile.size() == 0 ) return;
        
        User objGuestUser = new User(Alias = 'WGWeb', Email='WGWebUser@testorg.com', 
                                     EmailEncodingKey='UTF-8', LastName='WGWebUser', LanguageLocaleKey='en_US', 
                                     LocaleSidKey='en_US', ProfileId = listGuestProfile[0].Id, 
                                     TimeZoneSidKey='America/Los_Angeles', UserName='WGWebUser@testorg.com');
        
        //if we use this , it will make the generate error
       // system.runAs( objGuestUser ){
            
            CommunitiesSelfRegController objCommSelfReg = new CommunitiesSelfRegController();
            objCommSelfReg.password = 'qwertyui1234';
            objCommSelfReg.confirmPassword = 'qwertyui123';
            objCommSelfReg.registerUser();
            
            objCommSelfReg.confirmPassword = 'qwertyui1234';
            objCommSelfReg.email = 'www.testSample22@sample.com';
            objCommSelfReg.communityNickname = 'test22Abla';
            objCommSelfReg.registerUser(); 
        //}
        
    }
}