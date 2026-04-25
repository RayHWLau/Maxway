@isTest
public class OpportunityTriggerHandlerTest {
    
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
        OpportunityCustomScreenAura.getUser(u1.id);
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
        List<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Contact> conLis = TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
        
        
    }
    
    public static testMethod void test(){
        Contact con = [SELECT ID,AccountId FROM Contact];
        // Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsClass.studntAccRecTypeName).getRecordTypeId();
        Set<String> accidSet = new Set<String>();
        
        // Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('osHSRecTypeName').getRecordTypeId();
        Account acc = [SELECT ID,RecordTypeId FROM Account];
        // acc.RecordTypeId = RecordTypeIdAccount;
        accidSet.add(acc.id);
        
        Set<Id> oppidSet = new Set<Id>();
        Opportunity oppSet = [select id from Opportunity ];
        oppidSet.add(oppSet.id);
        OpportunityTriggerHandler.generateDraftInvoice(oppidSet);
        update acc;
        
        //   List<Account> listacc = TestUtil.createAccount(ConstantsClass.Overseas_School_CC, false, 1);
        
        Opportunity opp = [SELECT ID  FROM Opportunity ];
        opp.AccountId =acc.Id;
        //  opp.StageName = 'Closed Lost';
        //  opp.Closed_Lost_Reason__c = 'Closed Lost';
        update opp;
        
        list<Account> lisAcc = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, true, 1);
        lisAcc[0].CurrencyIsoCode='USD';
        update lisAcc;
        Campus__c cms=new Campus__c();
        cms.Account__c = lisAcc[0].id;
        cms.Homestay_Grade__c = 'K1';
        cms.Country_New__c = 'United States';
        cms.Student_taking_IB__c = 10;
        cms.Housing_Option__c='Homestay';
        cms.Province_State_New__c = 'Alabama';
        cms.Nearest_Big_City_New__c = 'Birmingham';
        cms.CurrencyIsoCode='USD';
        insert cms;
        Program__c pgm=new Program__c();
        pgm.Program_Type__c = 'Bachelor';
        pgm.Est_Annual_Cost__c = 2000;
        pgm.Campus__c = cms.id;
        pgm.ESL_Housing__c = 2200;
        pgm.CurrencyIsoCode = 'USD';
        pgm.Bachelor_Needed__c = 'Not Applicable'; 
        pgm.IELTS_Min__c = '2.0';
        pgm.TOEFL_Min__c = 10;   
        pgm.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
        pgm.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
        pgm.High_School_Graduation_Needed__c = 'Yes';
        pgm.Admission_Grade__c='K1';
        insert pgm;
        
        Commission__c comms = new Commission__c();
        // comms.Account__c = lisAcc[0].id;
        comms.Program__c = pgm.id;
        comms.Billing_Frequency_Per_Year__c = 80;
        comms.Commission_Order__c = 3;
        insert comms;
        
        
        // List<Case> caseList = TestUtil.createApplication(caseCCRecTypeName, false, 1);
        // caseList[0].Opportunity__c = opp.id;
        List<Case> caseId = new List<Case>();
        Case cs = new Case();
        cs.Status = 'In Progress';
        cs.Placed_Grade__c = 'Grade 3';
        cs.Term__c = 'Fall';
        cs.Year__c = '2011';
        cs.Start_Year_Year__c='2011';
        cs.Start_Month__c='May';
        cs.Opportunity__c = opp.id;
        //		cs.Program__c = pgm.id;
        caseId.add(cs);
        insert caseId;
        
        OpportunityTriggerHandler.generateDraftInvoice(oppidSet);
        OpportunityTriggerHandler.accountstatustoclosedlost(accidSet);
        
    }
    
    
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
        lisacc[0].Closed_Lost_Reason__c ='Others'; 
        try{
            insert lisacc;
            RecordlockClass.accountlock(lisacc, new Map<Id, Account>{lisacc[0].Id=>lisacc[0]});
        }  catch(exception e){
            List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
            lisOpp[0].Stagename = 'Closed Lost';
            lisOpp[0].Closed_Lost_Reason__c = 'Satisfy with system already in place';
            update lisOpp;
            
            
            //   OpportunityTriggerHandler.accountstatustoclosedlost(accidSet);
            
            list<Document_Master__c> docmaster = new list<Document_Master__c>();
            Document_Master__c dm = new Document_Master__c();
            dm.Name = 'Doc';
            dm.Active__c = true;
            dm.Required__c = true;
            dm.Process__c = 'Agent Signup Form';
            docmaster.add(dm);
            insert docmaster;
            
            list<Document_Upload__c> documenttoinsert = new list<Document_Upload__c>();
            Document_Upload__c docup = new Document_Upload__c();
            docup.Name='Test Doc';
            docup.Account__c= lisacc[0].id;
            docup.Document_Master__c = docmaster[0].id;
            docup.Opportunity__c =lisOpp[0].id;
            documenttoinsert.add(docup);
            insert documenttoinsert;
            
        }   
    }
    public static testMethod void testMethod5(){
        // integer closedlostoppsize = 0; 
        Set<String> accidSet = new Set<String>();
        
        Account acc = [SELECT ID,ParentId FROM Account];
        accidSet.add(acc.id);
        
        OpportunityTriggerHandler.accountstatustoclosedlost(accidSet);
        
        
    }
    
    //3rd June 2020 intial -> 43% ( removed Errors as with errors 49% )
    //___________________________________________________________________________________________________________________________________________________________________________
    
    public static testMethod void TestMethod1(){
        
        Id campusCCRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusCCRecTypeName ).getRecordTypeId();
		Id progCCRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programCCRecTypeName).getRecordTypeId();
        
        List<Account> lisAccCCSchool = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
        lisAccCCSchool[0].School_s_Country__c = 'Canada';
        insert lisAccCCSchool;
        
        
        Commission_Table__c objCommTable = new Commission_Table__c();
        objCommTable.Nationality__c = 'Afghan, Afghanistan';
        objCommTable.Amount__c = 123;
        objCommTable.School__c = lisAccCCSchool[0].Id;
        insert objCommTable;
        
        Campus__c objCampCC =  new Campus__c();
        objCampCC.RecordTypeId = campusCCRecTypeId;
        objCampCC.Account__c = lisAccCCSchool[0].Id;
        objCampCC.Homestay_Grade__c = '10;12';
        objCampCC.Country_New__c = 'Canada';
        objCampCC.Student_taking_IB__c = 10;
        objCampCC.Housing_Option__c='Homestay';
        objCampCC.Province_State_New__c = 'Ontario';
        objCampCC.Nearest_Big_City_New__c = 'Toronto';
        objCampCC.Housing_Option__c = 'Homestay';
        
        insert objCampCC;
        
        
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
        objProgCC.High_School_Graduation_Needed__c = 'No';
        objProgCC.Bachelor_Needed__c = 'Not Applicable';
        objProgCC.TOEFL_accepted_for_update_ESL_EAP__c = 'No';
        
        insert objProgCC;
        
        
        Major__c objMajor = new Major__c();
        objMajor.Name = 'Test Prog CC Major';
        objMajor.Program__c = objProgCC.Id;
        insert objMajor;
        
        Commission__c comms = new Commission__c();
        comms.Program__c = objProgCC.id;
        comms.Billing_Frequency_Per_Year__c = 80;
        comms.Commission_Order__c = 3;
        comms.Retainer_Year__c = 1;
        comms.Annual_Commission_Amount_Fixed__c = 10;
        insert comms;

 		 List<Commission_Config__c> commfigs = new List<Commission_Config__c>();
        commfigs.add( new Commission_Config__c( Name= comms.Billing_Frequency_Per_Year__c+'-Fall', Billing_Frequency__c=2, Term__c='Fall', Next_Term__c='2-Winter', Start_Date__c=date.newInstance(2016, 9, 1),
                                               End_Date__c=date.newInstance(2016, 6, 30) ) ) ;
        commfigs.add( new Commission_Config__c( Name= '2-Winter', Billing_Frequency__c=2, Term__c='Fall', Next_Term__c='3-Winter', Start_Date__c=date.newInstance(2016, 9, 1),
                                               End_Date__c=date.newInstance(2016, 6, 30) ) ) ;
        insert commfigs;
        
        

        
        Test.startTest();
        
        list<Opportunity> lisStudentOpp = TestUtil.createOpportunity(ConstantsClass.studentRecTypeName, false, 1);
        lisStudentOpp[0].Num_of_Year_to_Graduation__c = 2;
        insert lisStudentOpp;
        
        list< Case > listApplication = TestUtil.createApplication( ConstantsClass.caseOptOutRecTypeName , false, 1);
        listApplication[0].Opportunity__c = lisStudentOpp[0].Id;
        listApplication[0].Program__c = objProgCC.Id;
        insert listApplication;
        
        OpportunityTriggerHandler.generateDraftInvoice( new set< Id > { lisStudentOpp[0].Id } );
        
        Document_Master__c objDocMaster = new Document_Master__c();
        objDocMaster.Name = 'Document';
        objDocMaster.Active__c = true;
        objDocMaster.Required__c = true;
        objDocMaster.Process__c = 'Agent Signup Form';
        
        Document_Master__c objDocMaster1 = new Document_Master__c();
        objDocMaster1.Name = 'Document';
        objDocMaster1.Active__c = true;
        objDocMaster1.Default__c = true;
        objDocMaster1.Required__c = true;
        objDocMaster1.Process__c = 'Application';
        objDocMaster1.Level__c = 'Application';
        
        insert new List< Document_Master__c > { objDocMaster, objDocMaster1 };
        
        
        OpportunityTriggerHandler.documentuploadcreation( new list< String > { lisStudentOpp[0].Id + '#' + lisAccCCSchool[0].Id } );
        OpportunityTriggerHandler.documentuploadCreationForStudent( new list< String > { lisStudentOpp[0].Id + '#' + lisAccCCSchool[0].Id }, 'Application' );
        Test.stopTest();
    }
}