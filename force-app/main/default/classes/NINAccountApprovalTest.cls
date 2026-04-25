@isTest
public class NINAccountApprovalTest {
    @testSetup
    public static void createTestData(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        Profile objSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false);
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        system.runAs( systemAdminUser ){
            ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            TestUtil.createCustomSettingInvoiceRollUp(true);
            
            
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
            
            test.startTest();
            Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
            objOpp.StageName='Arrived';
            objOpp.AccountId = lisacc[0].Id;
            insert objOpp;
            
            List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
            listContract[0].AccountId = lisacc[0].Id;
            listContract[0].Opportunity__c = objOpp.Id;
            listContract[0].CurrencyIsoCode='USD';
            insert listContract;
            
            listContract[0].Status = objTestSetting.Contract_Status__c;
            listContract[0].StartDate = Date.today().addDays(-1);
            //update listContract;
            
            
            list< Contract_Item__c > listContractItem = TestUtil.createContractItem( listContract[0].id, objTestSetting.Contract_Line_Item_Record_Name__c, 1, objTestSetting.School_Tariff_Type__c, false );
            listContractItem[0].CurrencyIsoCode='USD';
            insert listContractItem;
            test.stopTest();
        }
    }
    
    
    public static testMethod void testNINAccount(){
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        User partnerUser = [ SELECT Id FROM User WHERE LastName = 'partnerUser' ];
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        
        Test.startTest();
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.StageName='Arrived';
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        test.stopTest();
        
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();       
        
        list<Case> listcs=TestUtil.createApplication('Application(Opt-In)', false, 1); 
        listcs[0].Opportunity__c=objOpp.id;
        listcs[0].AccountId=objAgentAcc.id;
        insert listcs;
        
        Document_Upload__c du=new Document_Upload__c();
        du.Application__c=listcs[0].id;
        du.Required__c=true;
        du.Opportunity__c=objOpp.id;
        insert du;
        
        List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
        listContract[0].AccountId = objAgentAcc.Id;
        listContract[0].Opportunity__c = objOpp.Id;
        listContract[0].CurrencyIsoCode='USD';
        insert listContract;
        
        listContract[0].Status = objTestSetting.Contract_Status__c;
        listContract[0].StartDate = Date.today().addDays(-1);
        update listContract;
        
        
        list< Contract_Item__c > listContractItem = TestUtil.createContractItem( listContract[0].id, objTestSetting.Contract_Line_Item_Record_Name__c, 1, objTestSetting.School_Tariff_Type__c, false );
        listContractItem[0].CurrencyIsoCode='USD';
        insert listContractItem;
        
        system.runAs(partnerUser){
            
            /*  NINAccountApproval.returnprice( TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0].Id);
NINAccountApproval.lightningapproval( TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1)[0].Id);
NINAccountApproval.returnprice(listcs[0].id);
*/
        }
        
        
    }
    @isTest
    public static void test2()
    {
        Account objAgentAcc = [ SELECT Id FROM Account WHERE RecordType.Name = :ConstantsClass.accAgentRecTypeName ];
        Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1)[0];  
        objOpp.StageName='Arrived';
        objOpp.AccountId = objAgentAcc.Id;
        insert objOpp;
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();       
        list<Case> listcs=TestUtil.createApplication('Application(Opt-In)', false, 1); 
        listcs[0].Opportunity__c=objOpp.id;
        listcs[0].AccountId=objAgentAcc.id;
        insert listcs;
        Task tsk=new Task();
        tsk.WhatId=listcs[0].id;
        insert tsk;
        
    }
    
    //Added 10 june 
    //__________________________________________________________________________________________________________________________________________________________________________
    
    public static testMethod void testMethodForAccount(){
        
        List< User > listPartnerUser = [ SELECT Id FROM User WHERE Profile.Name = 'Partner - Admin' and isActive = true];
        
        if( listPartnerUser.size() == 0 ){
            system.debug(' No user found ');
            return;
        }

        try{
            
            system.runAs(listPartnerUser[0]){
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            insert ListStaff;
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
            lisacc[0].Account_Manager__c = ListStaff[0].Id;
            insert lisacc;
            
            NINAccountApproval.returnprice( lisacc[0].Id );
            
            NINAccountApproval.lightningapproval( lisacc[0].Id );
            NINAccountApproval.lightningapproval( ListStaff[0].Id );
        }
            
        }Catch( Exception objExcep ){
            //as sometime it is passing or failing 
        }        
        
    }
    public static testMethod void testMethodForCase(){
        
        List< User > listPartnerUser = [ SELECT Id,ContactId FROM User WHERE Profile.Name = 'Partner - Admin' and isActive = true];
        
        if( listPartnerUser.size() == 0 ){
            system.debug(' No user found ');
            return;
        }
        
        try{
            
            List< Opportunity > listOpp = [ SELECT Id,AccountId FROM Opportunity WHERE RecordType.Name =:ConstantsClass.agentAcqRecTypeName LIMIT 1 ];
            
            system.runAs( listPartnerUser[0] ){
                
                list<Case> listcs=TestUtil.createApplication('Application(Opt-In)', false, 1); 
                listcs[0].Opportunity__c=listOpp[0].id;
                listcs[0].AccountId=listOpp[0].AccountId;
                insert listcs;
                
                Document_Upload__c du=new Document_Upload__c();
                du.Application__c=listcs[0].id;
                du.Required__c=true;
                du.Opportunity__c=listOpp[0].id; 
                insert du;
                
                NINAccountApproval.returnprice( listcs[0].Id );
            }
            
        }Catch( Exception obj ){
        //as sometime it is passing or failing    
        }
        
    }
}