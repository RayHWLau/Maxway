@isTest
public class OpportunityApprovalControllerTest {

     @testSetup
    public static void  createData(){
        
         User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u1;
        
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        List<Opportunity> oppLis = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
        
        
    }
    
    public static testMethod void testMethod1(){
        Opportunity opp =  [SELECT ID FROM Opportunity];
        OpportunityApprovalController.lightningapproval(opp.Id);
      
        
       
    }
    public static testMethod void testMethod2(){
        Opportunity opp =  [SELECT ID,Quotation_Attached__c FROM Opportunity];
        opp.StageName = 'Prepare Quotation';
        opp.Quotation_Attached__c = False;
        opp.Agent_Reference_Check__c = 'Verified';
        opp.AgentSignedUpDocUpload__c = true;
        update opp;
        OpportunityApprovalController.lightningapproval(opp.Id);
    }
   
  

      public static testMethod void testMethod3(){
        Opportunity opp =  [SELECT ID,Quotation_Attached__c FROM Opportunity];
        opp.StageName = 'Prepare Quotation';
       // opp.Hot_Prospect_Reasons__c = 'Has counselors in place';
       // opp.Hot_Prospect_Description__c = 'TEst';
        opp.Quotation_Attached__c = true;
        opp.Agent_Reference_Check__c = 'Verified';
        opp.AgentSignedUpDocUpload__c = true;
        update opp;
        OpportunityApprovalController.lightningapproval(opp.Id);
    }
    
     public static testMethod void testMethod4(){
        Opportunity opp =  [SELECT ID,Quotation_Attached__c FROM Opportunity];
        opp.StageName = 'Prepare Quotation';
       // opp.Hot_Prospect_Reasons__c = 'Has counselors in place';
       // opp.Hot_Prospect_Description__c = 'TEst';
        opp.Quotation_Attached__c = true;
        opp.Agent_Reference_Check__c = 'Verified';
        opp.AgentSignedUpDocUpload__c = true;
        opp.Number_of_admin_licenses__c =2;
        opp.Number_Of_Licence__c = 5;
        opp.Portal_Admin_Email__c = 's@g.com';
        opp.Required_Successful_Applications_to_Data__c = 'No';
        opp.Which_country_s_school_list_to_purchase__c = 'Canada'; 
        update opp;
        OpportunityApprovalController.lightningapproval(opp.Id);
    }
    
      public static testMethod void testMethod5(){
          try{
              Opportunity opp =  [SELECT ID,Quotation_Attached__c FROM Opportunity];
              opp.StageName = 'Prepare Quotation';
              // opp.Hot_Prospect_Reasons__c = 'Has counselors in place';
              // opp.Hot_Prospect_Description__c = 'TEst';
              opp.Quotation_Attached__c = true;
              opp.Agent_Reference_Check__c = 'Denied';
              opp.AgentSignedUpDocUpload__c = true;
              update opp;
              OpportunityApprovalController.lightningapproval(opp.Id);
          }catch(Exception e){}
    }
    
    public static testMethod void testOpp () {
        Opportunity opp = [SELECT ID FROM Opportunity];
        
        OpportunityApprovalController oppC = new OpportunityApprovalController ();
        apexPages.Currentpage().getParameters().put('Id',opp.id);
       oppC.CallApproval();
     
        
    }

    
}