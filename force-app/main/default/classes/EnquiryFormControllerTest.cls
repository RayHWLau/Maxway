@isTest
public class EnquiryFormControllerTest {
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
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
       
       List<Lead> lisLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName,false,1);
        lisLead[0].status = 'New';
       // lisLead[0].IsConverted=true;
        insert lisLead;
       
    }
    
    public static testMethod void  test(){
        EnquiryFormController.getBranchPicklistvalues();
        Lead ld = [SELECT ID FROM Lead];
        EnquiryFormController.saveLeadDetailsApex(JSON.serialize(ld),new List<String>{'fgh'});
        EnquiryFormController.PicklistEntryWrapper ep = new EnquiryFormController.PicklistEntryWrapper();
    }
}