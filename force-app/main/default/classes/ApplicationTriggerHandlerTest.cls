@isTest
public class ApplicationTriggerHandlerTest {
    @testSetup
    public static void createTestData(){
        Test.StartTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        Profile objSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false);
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        system.runAs( systemAdminUser ){
            
           /* List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
                            TestUtil.createCustomSettingInvoiceRollUp(true);*/

            
            //Agent Account Creation
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            //lisacc[0].Account_Manager__c = ListStaff[0].Id;
            lisacc[0].Total_Admin_License__c = 10;
            lisacc[0].Total_User_License__c = 10;
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            TestUtil.createInvoice('Agent', true, 1);
            TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
            
        }
        Test.StopTest();
    }
    
    public static testMethod void testNINAccount(){
        // Test.startTest();
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
          User partnerUser = [ SELECT Id FROM User WHERE LastName = 'partnerUser' ];
          Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
          Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
         objOpp.StageName='Arrived';
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
       //Id RecordTypeIdProgram = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Uni Program').getRecordTypeId();       

        list<Program__c> listpr= TestUtil.createProgram(ConstantsClass.programUniRecTypeName, true, 1);
         List<Campus__c> listcmp=TestUtil.createCampus(ConstantsClass.campusUniRecTypeName, true, 1);
         List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
        listContract[0].AccountId = objAgentAcc.Id;
        listContract[0].Opportunity__c = objOpp.Id;
        insert listContract;
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
       // listContract[0].endDate = Date.today();

        update listContract;

        //listpr[0].recordTypeId=RecordTypeIdProgram;
        //insert listpr;
        System.debug('Record Type====>'+listpr[0].recordTypeId);
          //Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();       
                    //list<Case> listcs=TestUtil.createApplication('Summer Program Application', false, 1); 
                    list<Case> listcs=TestUtil.createApplication('Application(Opt-Out/NIN/Maxway)', false, 1); 
                        listcs[0].Opportunity__c=objOpp.id;
                        listcs[0].AccountId=objAgentAcc.id;
                        listcs[0].Campus__c=listcmp[0].id;
                        listcs[0].Program__c=listpr[0].id;
                        listcs[0].Expected_Commencement_Date__c=date.today().addDays(100);
                        insert listcs;
        
                        
          system.runAs(partnerUser){
                         Test.StartTest();
                       NINAccountApproval.returnprice(listcs[0].id);

             //Account acc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
              
           // NINAccountApproval.returnprice( TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0].Id);
             // NINAccountApproval.lightningapproval( TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0].Id);
               //
             

              
        }
          
            // Test.stopTest();
        list<Case> listcs1=TestUtil.createApplication('Summer Program Application', false, 1); 
                    
                        listcs1[0].Opportunity__c=objOpp.id;
                        listcs1[0].AccountId=objAgentAcc.id;
                        listcs1[0].Campus__c=listcmp[0].id;
                        listcs1[0].Program__c=listpr[0].id;
                        listcs1[0].Expected_Commencement_Date__c=date.today().addDays(100);
                        insert listcs1;
        
        
            System.debug('listcs[0]=====>'+listcs[0].id);
            Test.StopTest();
        
         
       }
        

}