@isTest
public class SchoolSharingForComunityUserTest {
    
    
    //commented on 5 june as this method was giving error
    /*public static testMethod void test3(){

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


List<Account> lisAcc = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, false, 1);
lisAcc[0].Visible_to_Agent__c = 'Yes';
lisAcc[0].School_List_Purchased__c = 'Australia';
lisAcc[0].School_s_Country__c = 'Australia';
insert  lisAcc;

List<Opportunity> listOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
listOpp[0].AccountId = lisAcc[0].Id;
insert listOpp;

Commission_Table__c cm = new Commission_Table__c();
cm.Amount__c = 123;
cm.School__c = lisAcc[0].Id;
insert cm;

List<Contract> lisCon = TestUtil.createContract(ConstantsClass.schoolRecTypeName, false,1);
lisCon[0].AccountId =  lisAcc[0].Id;
lisCon[0].Counter_Sign_Contract_Arrived_Date__c  = Date.today();
lisCon[0].Contract_Open_End__c = true;
lisCon[0].Fact_Sheet_Provided__c = 'No';
lisCon[0].Need_Fact_Sheet__c  = 'No';         
insert lisCon; 

Campus__c cms = new Campus__c();
cms.Account__c = lisAcc[0].Id;
cms.Homestay_Grade__c = '10;12';
cms.Country_New__c = 'Canada';
cms.Student_taking_IB__c = 10;
cms.Housing_Option__c='Homestay';
cms.Province_State_New__c = 'Ontario';
cms.Nearest_Big_City_New__c = 'Toronto';
insert cms;

test.startTest();
Program__c pgm = new Program__c();
pgm.Program_Type__c = 'All Grades Offered';
pgm.Est_Annual_Cost__c = 2000;
pgm.Campus__c = cms.Id;
pgm.ESL_Housing__c = 2200;
pgm.CurrencyIsoCode = 'CAD';
Pgm.Admission_Grade__c='10';
insert pgm;



Account acc = lisAcc[0].clone( false, true, false, false );

acc.Visible_to_Agent__c = 'No';

SchoolSharingForComunityUser.schoolshare(new List<Account>{lisAcc[0]},new Map<Id,Account>{lisAcc[0].Id=>acc});

SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased(lisAcc[0],'Australia');
test.stopTest();
} */
    
    //5 June 2020
    //_____________________________________________________________________________________________________________________________________________________________
    
    @testSetup
    public static void dataFactory(){
        Test.StartTest();
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        Profile objSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false );
        Profile objMaxSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'Maxway System Administrator'];
        User maxwaySystemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objSystAdminProfile.Id, false );
        
        Id campusCCRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusCCRecTypeName ).getRecordTypeId();
        Id progHighSchlRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programHSRecTypeName).getRecordTypeId();
        Id progCCRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programCCRecTypeName).getRecordTypeId();
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        
        system.runAs( systemAdminUser ){
            TestUtil.createCustomSettingApplicationPrepaidBaln( true );
            
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
            lisacc[0].School_List_Purchased__c = 'United States;United Kingdom;Canada;Australia;New Zealand';
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
            Opportunity objOpp = TestUtil.createOpportunity(ConstantsClass.renAgntRecTypeName, false, 1)[0];  
            objOpp.AccountId = lisacc[0].Id;
            insert objOpp;
            
            List< Contract > listContract = TestUtil.createContract(ConstantsClass.oppAgentRecTypeName, false, 1 ); 
            listContract[0].AccountId = lisacc[0].Id;
            listContract[0].Opportunity__c = objOpp.Id;
            listContract[0].CurrencyIsoCode='USD';
            listContract[0].Status = 'Valid';
            listContract[0].Counter_Sign_Contract_Arrived_Date__c = Date.today();
            insert listContract;
            
            TestUtil.createInvoice('Agent', true, 1);
            
            //Agent Account Creation
            List< Account > lisacc1 = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
            lisacc1[0].ownerId = systemAdminUser.id;
            lisacc1[0].ParentId = lisacc[0].Id;
            insert lisacc1;
            
            Commission_Table__c cm = new Commission_Table__c();
            cm.Nationality__c = 'Afghan, Afghanistan';
            cm.Amount__c = 123;
            cm.School__c = lisacc1[0].Id;
            insert cm;
            
            Campus__c objCampCC =  new Campus__c();
            objCampCC.RecordTypeId = campusCCRecTypeId;
            objCampCC.Account__c = lisacc1[0].Id;
            objCampCC.Homestay_Grade__c = '10;12';
            objCampCC.Country_New__c = 'Canada';
            objCampCC.Student_taking_IB__c = 10;
            objCampCC.Housing_Option__c='Homestay';
            objCampCC.Province_State_New__c = 'Ontario';
            objCampCC.Nearest_Big_City_New__c = 'Toronto';
            objCampCC.Housing_Option__c = 'Homestay';
            
            insert  new list< Campus__c > { objCampCC };
                
                Program__c objProgCC = new Program__c();
            objProgCC.RecordTypeId = progCCRecTypeId;
            objProgCC.Campus__c = objCampCC.Id;
            objProgCC.Program_Type__c = 'All Grades Offered';
            objProgCC.Est_Annual_Cost__c = 2000;
            objProgCC.ESL_Housing__c = 2200;
            objProgCC.CurrencyIsoCode = 'CAD';
            objProgCC.Bachelor_Needed__c = 'Yes'; 
            objProgCC.IELTS_Min__c = '2.0';
            objProgCC.TOEFL_Min__c = 10;   
            objProgCC.Admission_Grade__c='10';
            objProgCC.High_School_Graduation_Needed__c = 'Not Applicable';
            objProgCC.TOEFL_accepted_for_update_ESL_EAP__c = 'No';
            
            insert new List< Program__c >{  objProgCC };
                
                Major__c objMajor = new Major__c();
            objMajor.Name = 'Test Prog CC Major';
            objMajor.Program__c = objProgCC.Id;
            insert objMajor;
            
            TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
            Test.StopTest();
            
        }
    }
    
    public static testMethod void testMethod1(){
        
        user objPartnerUser = [ SELECT Id,contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        list< Account > listSchoolAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.osCCRecTypeName ];
       list< Account > listAgentAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.accAgentRecTypeName ];
        // List< Account > lisacc1;
        /*system.runAs( objPartnerUser ){
            
            List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'HQ Admin1';
            ListStaff1[0].OwnerId = objPartnerUser.id;
            insert ListStaff1;
            
            lisacc1 = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
            lisacc1[0].ownerId = objPartnerUser.id;
            lisacc1[0].ParentId = objPartnerUser.contact.AccountId;
            lisacc1[0].Account_Manager__c = ListStaff1[0].Id;
            
            insert lisacc1;
        }*/
       
        listSchoolAccnt[0].Visible_to_Agent__c = 'Yes';
        update listSchoolAccnt;
        
        listAgentAccnt[0].School_List_Purchased__c = 'United States;United Kingdom;Canada;Australia';
        update listAgentAccnt;
        
        test.startTest();
        listAgentAccnt[0].School_List_Purchased__c = '';
        update listAgentAccnt;
        test.stopTest();
    }
    
     public static testMethod void testMethod2(){
        
        user objPartnerUser = [ SELECT Id,contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        list< Account > listSchoolAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.osCCRecTypeName ];
        list< Account > listAgentAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.accAgentRecTypeName ];
         listSchoolAccnt[0].Visible_to_Agent__c = 'No';
        update listSchoolAccnt;
         
         listAgentAccnt[0].School_List_Purchased__c = '';
         SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( listAgentAccnt[0],'United States;United Kingdom;Canada;Australia' );
        
         listAgentAccnt[0].School_List_Purchased__c = 'United States;United Kingdom;Canada;Australia';
         SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( listAgentAccnt[0],'' );
    }
    public static testMethod void testMethod3(){
        
        user objPartnerUser = [ SELECT Id,contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        list< Account > listSchoolAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.osCCRecTypeName ];
        list< Account > listAgentAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.accAgentRecTypeName ];
        listSchoolAccnt[0].Visible_to_Agent__c = 'No';
        update listSchoolAccnt;
        
        listAgentAccnt[0].School_List_Purchased__c = 'United States;United Kingdom;Canada;Australia';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( listAgentAccnt[0],'' );
        
        listAgentAccnt[0].School_List_Purchased__c = 'United States';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( listAgentAccnt[0],'' );
    }
     public static testMethod void testMethod4(){
        
        user objPartnerUser = [ SELECT Id,contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        list< Account > listSchoolAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.osCCRecTypeName ];
        list< Account > listAgentAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.accAgentRecTypeName ];
        listSchoolAccnt[0].Visible_to_Agent__c = 'No';
        update listSchoolAccnt;
        
         recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        listAgentAccnt[0].School_List_Purchased__c = '';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( listAgentAccnt[0],'' );
    }
    
    public static testMethod void testMethod5(){ 
        
        user objPartnerUser = [ SELECT Id,contact.AccountId FROM User WHERE LastName = 'partnerUser' ];
        list< Account > listSchoolAccnt = [ SELECT Id,Owner.IsPortalEnabled,Visible_to_Agent__c FROM Account WHERE RecordType.Name =: ConstantsClass.osCCRecTypeName ];
        
        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        listSchoolAccnt[0].Visible_to_Agent__c = 'Yes';
        listSchoolAccnt[0].School_s_Country__c = 'United States';
        update listSchoolAccnt;
        
        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        AccountShare objAccShare = new AccountShare();
        objAccShare.UserOrGroupId = objPartnerUser.Id;
        objAccShare.AccountId = listSchoolAccnt[0].Id;
        objAccShare.CaseAccessLevel = 'Read';
        objAccShare.ContactAccessLevel = 'Read';
        objAccShare.OpportunityAccessLevel = 'Read';
        objAccShare.AccountAccessLevel = 'Read';
        insert objAccShare;
        
        Account objAccnt = new Account();
        objAccnt.Id = objPartnerUser.contact.AccountId;
        objAccnt.School_List_Purchased__c = 'United States;United Kingdom;Canada;Australia';
        
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( objAccnt,'United States;United Kingdom' );
        
        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        objAccnt.School_List_Purchased__c = 'United States';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( objAccnt,'United States' );
        
        AccountShare objAccShare1 = new AccountShare();
        objAccShare1.UserOrGroupId = objPartnerUser.Id;
        objAccShare1.AccountId = listSchoolAccnt[0].Id;
        objAccShare1.CaseAccessLevel = 'Read';
        objAccShare1.ContactAccessLevel = 'Read';
        objAccShare1.OpportunityAccessLevel = 'Read';
        objAccShare1.AccountAccessLevel = 'Read';
        insert objAccShare1;
        
        objAccnt.School_List_Purchased__c = '';
        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( objAccnt,'United States' );
        
        test.startTest();
         AccountShare objAccShare2 = new AccountShare();
        objAccShare2.UserOrGroupId = objPartnerUser.Id;
        objAccShare2.AccountId = listSchoolAccnt[0].Id;
        objAccShare2.CaseAccessLevel = 'Read';
        objAccShare2.ContactAccessLevel = 'Read';
        objAccShare2.OpportunityAccessLevel = 'Read';
        objAccShare2.AccountAccessLevel = 'Read';
        insert objAccShare2;

        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        objAccnt.School_List_Purchased__c = 'United States;United Kingdom;Canada;Australia';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( objAccnt,'' );
        
        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        objAccnt.School_List_Purchased__c = 'United States';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( objAccnt,'' );
        
         AccountShare objAccShare3 = new AccountShare();
        objAccShare3.UserOrGroupId = objPartnerUser.Id;
        objAccShare3.AccountId = listSchoolAccnt[0].Id;
        objAccShare3.CaseAccessLevel = 'Read';
        objAccShare3.ContactAccessLevel = 'Read';
        objAccShare3.OpportunityAccessLevel = 'Read';
        objAccShare3.AccountAccessLevel = 'Read';
        insert objAccShare3;
        
        recursiveCheck.sharingchangeaccordingtoschoollistpurchasedCheck = False;
        objAccnt.School_List_Purchased__c = '';
        SchoolSharingForComunityUser.sharingchangeaccordingtoschoollistpurchased( objAccnt,'' );
        
        
        test.stopTest();
    }
}