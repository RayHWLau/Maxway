@isTest
public class LeadTriggerTest {
 
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
        Account acc=TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0];
        List<Lead> lisLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName,false,1);
        lisLead[0].status = 'New';
       // lisLead[0].IsConverted=true;
        insert lisLead;
       // lisLead[0].ConvertedAccountId=acc.id;
       // lisLead[0].Closed_Lost_Reason__c = 'Not Recruitment co.';
        
        
    }
    @isTest
public static void convertTest(){
    lead l=[select id from lead where IsConverted=false limit 1];
    delete l;
    
    TestDataFactory.getStudent();
   Account acc=TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0];

    Test.startTest();
  Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId();
    Lead ld=new Lead();
    ld.RecordTypeId =RecordTypeIdLead;
  Database.LeadConvert lc = new database.LeadConvert(); 
 
    ld.Status = 'Qualified';
                    ld.Salutation = 'Mr';
                    ld.LeadSource = 'Website';
                    ld.LastName = 'TestLead';
                    ld.Country_Code__c = 'Algeria (213)';
    				ld.Start_of_Academic_Month__c = 'June';
       
                    ld.Title= 'TY';
                    ld.email = 'a@g.com';
                    ld.Function__c ='Commission';
                    ld.Mobile__c= '7777777777';
                    ld.MobilePhone ='6666666666';
                    ld.Company = 'Tmc';
                    ld.Where_did_you_hear_about_us__c = 'Google';
                    ld.City ='Japan';
                    ld.Website= 'https://developer.salesforce.com/';
                    ld.Number_Of_Branches__c = '0';
                    ld.Branch_Conflicts_with_Maxway__c ='No';
                    ld.Head_Office_Country__c = 'United States';
                    ld.Head_Office_City__c = 'Anchorage';
                    ld.Head_Office_Province_State__c = 'Alaska';
                    ld.Last_Years_Total_Successful_Applications__c= '0-20';
                    ld.Number_Of_Full_Time_Staff__c = 20;
                    ld.Study_Abroad_Countries__c = 'Afghanistan';
                    ld.Goal_With_Portal__c  = 'Others';
                    ld.Top_Sending_Countries__c ='Afghanistan';
                    ld.Goal_With_Portal_Others__c = 'test'; 
    				ld.status='Qualified';
    				ld.IsConverted = false;
    			
                       	insert ld;
    			
  
    				//update ld;
    				
    // lc.setLeadId(ld.id); 
  //lc.setDoNotCreateOpportunity(false);
  //lc.setConvertedStatus('Qualified'); 
  //Database.LeadConvertResult lcr = Database.convertLead(lc); 
 //Lead passingLeads=[SELECT IsConverted,convertedAccountId,Id FROM Lead where id=:ld.Id limit 1];
  // passingLeads.IsConverted=false;
   // update passingLeads;
 // classname.MethodName(passingLeads);
 Sibling__c sib=new Sibling__c();
    sib.Principal_Student_Lead__c=ld.id;
    sib.Sibling_Student_Lead__c=ld.Id;
    sib.Principal_Student__c=TestUtil.createAccount('Student Account', true, 1)[0].Id;  //'0010p00000bmdzDAAQ';
    sib.Sibling_Student__c=TestUtil.createAccount('Student Account', true, 1)[0].Id;//'0010p00000boyTFAAY';
    insert sib;
    Test.stopTest();
}
    
    public static testMethod void testMethod1(){
        
        Lead objLead = [ SELECT Id From Lead ];
        objLead.Status = 'Closed_Lost';
        objLead.Closed_Lost_Reason__c ='Branch office location overlap with Maxway\'s';
        update objLead;
        
    }
    
      public static testMethod void testMethod2(){
        
        Lead objLead = [ SELECT Id From Lead ];
        objLead.Status = 'Closed_Lost';
        objLead.Closed_Lost_Reason__c ='Not Recruitment co.';
        update objLead;
        
    }
    
     public static testMethod void testMethod3(){
        
        Lead objLead = [ SELECT Id From Lead ];
         objLead.Start_of_Academic_Month__c = 'May';
        objLead.Status = 'New';
        objLead.Branch_Conflicts_with_Maxway__c ='Yes';
        update objLead;
        
    }
}