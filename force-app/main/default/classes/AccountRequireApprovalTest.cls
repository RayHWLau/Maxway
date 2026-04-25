@isTest
public class AccountRequireApprovalTest {
    
    @isTest
    public static void createTestData(){
        // TestUtil.createCustomSettingInvoiceRollUp(true);

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
          User usr= TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
             List<Id> newWorkItemIds;
            System.runAs(usr)
            {
                
                 List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'HQ Admin';
            ListStaff1[0].OwnerId = usr.id;
            insert ListStaff1;
                  Id RecordTypeIdacc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();       
     				Account cs = new Account( Name = 'test',
            BillingStreet='Test Street',
            BillingCity='Test City',
            BillingState='Test State',
            BillingCountry='Test Country',
            BillingPostalCode='Test Postal Code');
                cs.RecordTypeId = RecordTypeIdacc;
                cs.Account_Manager__c = ListStaff1[0].Id;	
       			 insert cs;
            
            // List< ProcessDefinition > objProcessDef = [ SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Approve_Quotation' AND TableEnumOrId = 'Opportunity' ];
       // if( objProcessDef.size() > 0 ){
             Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting request for approval.');
           req.setNextApproverIds(new Id[] {UserInfo.getUserId()});
            req.setObjectId(cs.Id);
            req.setSubmitterId(usr.Id);

            Approval.ProcessResult resu = Approval.process(req);
            newWorkItemIds = resu.getNewWorkitemIds();
            system.debug('newWorkItemIds ::'+newWorkItemIds );

            
            }
            Approval.ProcessWorkitemRequest req2 =  new Approval.ProcessWorkitemRequest();
            req2.setComments('Approving request.');
            req2.setAction('Reject');
            req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});//UserInfo.getUserId()
            system.debug('req2::'+req2);
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(newWorkItemIds.get(0));
            system.debug('req3::'+req2);
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);
      //  }
        
        }
    }
    
    
}