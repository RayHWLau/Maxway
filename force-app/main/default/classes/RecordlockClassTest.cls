@isTest
private class RecordlockClassTest {
    
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
    
    //@testSetup
    static testMethod void  test1(){
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
        List<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
        lisacc[0].Status_Sub_Agent__c = 'Close Lost';
        lisacc[0].Closed_Lost_Reason__c ='Not Recruitment co.'; 
        // lisacc[0].RecordTypeId =  '0120p000000AtI5AAK'; 
        try{
            insert lisacc;
            RecordlockClass.accountlock(lisacc, new Map<Id, Account>{lisacc[0].Id=>lisacc[0]});
        }  catch(exception e){
            List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
            lisOpp[0].Stagename = 'Closed Lost';
            lisOpp[0].Closed_Lost_Reason__c = 'Satisfy with system already in place';
            update lisOpp;
            
            RecordlockClass.opplock(lisOpp, new Map<Id, Opportunity>{lisOpp[0].Id=>lisOpp[0]});
        }          
        
        
        
        
        
        
        /*   List<Case> listcase = new List<Case>();

listcase[0].Start_Month__c = 'Jan';
listcase[0].Start_Year_Year__c = '2011';


insert listcase;

RecordlockClass.appOptInlock(listcase, new Map<id, case>{listcase[0].id => listcase[0]} ); */
        
        
        
        
        // List<Lead> lisLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName, false, 1);
        List<Lead> lisLead = new List<Lead>();
        Lead ld = new Lead();
        //ld.Status = 'Qualified';
        ld.Status = 'New';
        //	ld.Closed_Lost_Reason__c = 'Closed Lost Reason Others';
        ld.Salutation = 'Mr';
        ld.LeadSource = 'Website';
        ld.Where_did_you_hear_about_us__c = 'Google';
        //RecordType.Name ='Agent Acquisition';
        ld.LastName = 'suraj Rocks';
        ld.Country_Code__c = 'Algeria (213)';
        
        ld.Title= 'TY';
        ld.Email = 'srj@gmail.com';
        ld.Function__c ='Commission';
        ld.Mobile__c= '123';
        ld.MobilePhone ='1234';
        
        ld.Branch_Office_City__c ='srj';
        
        lisLead.add(ld); 
        
        insert lisLead;
        
        RecordlockClass.leadlock(lisLead, new Map<Id, Lead>{lisLead[0].Id=>lisLead[0]});
        
        List<Invoice__c> lisInv = TestUtil.createInvoice(ConstantsClass.invoiceAgentRecTypeName, false, 1);
        lisInv[0].Status__c ='Void';
        map<string , string> leadfieldmap = new map<string , string>();
        string error ='';
        
        insert lisInv;
        RecordlockClass.invoicelockPaid(lisInv, new Map<Id, Invoice__c>{lisInv[0].Id=>lisInv[0]});
        RecordlockClass.invoicelock(lisInv, new Map<Id, Invoice__c>{lisInv[0].Id=>lisInv[0]});
    }
    
    
    static testMethod void  test2(){
        
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
            
            system.runAs( systemAdminUser ){
                List<Case> listcase =  TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1);  
                listcase[0].Status =  'Accepted By Maxway';
                insert listcase;
                
                
                RecordlockClass.appOptInlock(listcase, new Map<id, Case>{listcase[0].id=>listcase[0]});
            }
        }
    }
    
    static testMethod void test3(){
        Id recordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId();
        
        List<Lead> objLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName,false,1);
        objLead[0].Status = 'Closed_Lost';
        objLead[0].RecordTypeId = recordTypeId;
        objLead[0].Closed_Lost_Reason__c ='Not Recruitment co.';
        // objLead[0].Closed_Lost__c='Not Recruitment co.';
        
        try{
            insert objLead;
             RecordlockClass.leadlock(objLead, new Map<Id, Lead>{objLead[0].Id=>objLead[0]});
        } catch(exception e){
            
        }
       
    }
    
    
}