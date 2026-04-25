@isTest
public class SchoolSearchAuraTest {
    
    @testSetup
    public static void  createData(){
        Test.StartTest();
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
        
        List<Account> lisAcc = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, true, 1);
        List<Contact> conLis = TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
        List<Account> lisAcc2 = TestUtil.createAccount(ConstantsClass.osUniRecTypeName, true, 1);
        List<Campus__c> lisCamps = TestUtil.createCampus(ConstantsClass.campusUniRecTypeName, true, 1);
        List<Program__c> lisPrgm = TestUtil.createProgram(ConstantsClass.programUniRecTypeName, true, 1);
        List<Major__c> lisMajor = TestUtil.createMajor(ConstantsClass.majorMjrRecTypeName, true,1);
        Test.StopTest();
    }
    
    public static testMethod void testMethod1(){
        
        SchoolSearchAura.getBranchPicklistvalues();
        List<Account> acc = [SELECT ID FROM ACCOUNT ];
        acc[0].School_s_Country__c = 'United States';
        update acc;
        
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Afghan, Afghanistan';
        cm.Amount__c = 123;
        cm.School__c = acc[0].Id;
        insert cm;
        
        Campus__c cms = new Campus__c();
        cms.Account__c = acc[0].Id;
        cms.Homestay_Grade__c = '10;12';
        // cms.Boarding_Grades__c = '10;11';
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
        //pgm.CurrencyIsoCode = 
        Pgm.Admission_Grade__c='10';
        insert pgm;
        
        //opt_out_School__c optSchool = new opt_out_School__c();
        //
        SchoolSearchAura.getBranchPicklistvalues();
        SchoolSearchAura.returnSearchedHighSchool('Afghan, Afghanistan','United States', pgm.Program_Type__c, '1200','100000','10',cms.Province_State_New__c,cms.Nearest_Big_City_New__c,cms.Housing_Option__c,pgm.CurrencyIsoCode);
        test.stopTest();    
    }
    
    public static testMethod void testMethod2(){
        SchoolSearchAura.getBranchPicklistvalues();
        List<Account> acc = [SELECT ID FROM ACCOUNT];
        acc[0].School_s_Country__c = 'United States';
        update acc;
        
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Afghan, Afghanistan';
        cm.Amount__c = 123;
        cm.School__c = acc[0].Id;
        insert cm;
        
        Campus__c cms = new Campus__c();
        cms.Account__c = acc[0].Id;
        cms.Homestay_Grade__c = '10;12';
        // cms.Boarding_Grades__c = '10;11';
        cms.Country_New__c = 'Canada';
        cms.Student_taking_IB__c = 10;
        cms.Housing_Option__c='Homestay';
        cms.Province_State_New__c = 'Ontario';
        cms.Nearest_Big_City_New__c = 'Toronto';
        insert cms;
        
         test.startTest();
        Program__c pgm = new Program__c();
        pgm.Program_Type__c = 'Certificate';
        pgm.Est_Annual_Cost__c = 2000;
        pgm.Campus__c = cms.Id;
        pgm.ESL_Housing__c = 2200;
        pgm.CurrencyIsoCode = 'CAD';
        //pgm.CurrencyIsoCode = 
        Pgm.Admission_Grade__c='10';
        insert pgm;
        
        //opt_out_School__c optSchool = new opt_out_School__c();
       
           SchoolSearchAura.getOppRecDetails('abc');
           SchoolSearchAura.OpprtRecdDetails o = new SchoolSearchAura.OpprtRecdDetails();
           SchoolSearchAura.PicklistEntryWrapper p = new SchoolSearchAura.PicklistEntryWrapper();
           SchoolSearchAura.HSschool h = new SchoolSearchAura.HSschool();
           SchoolSearchAura.PSschool ps = new SchoolSearchAura.PSschool();
           SchoolSearchAura.PGschool pg = new SchoolSearchAura.PGschool();
        SchoolSearchAura.returnSearchedHighSchool('Afghan, Afghanistan','United States', pgm.Program_Type__c, '1200','100000','10',cms.Province_State_New__c,cms.Nearest_Big_City_New__c,cms.Housing_Option__c,pgm.CurrencyIsoCode);
        test.stopTest();
    }
    public static testMethod void testMethod3(){
        SchoolSearchAura.getBranchPicklistvalues();
        List<Account> acc = [SELECT ID FROM ACCOUNT ];
        acc[0].School_s_Country__c = 'United States';
        update acc;
        
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Afghan, Afghanistan';
        cm.Amount__c = 123;
        cm.School__c = acc[0].Id;
        insert cm;
        
        Campus__c cms = new Campus__c();
        cms.Account__c = acc[0].Id;
        cms.Homestay_Grade__c = '10;12';
        // cms.Boarding_Grades__c = '10;11';
        cms.Country_New__c = 'Canada';
        cms.Student_taking_IB__c = 10;
        cms.Housing_Option__c='Homestay';
        cms.Province_State_New__c = 'Ontario';
        cms.Nearest_Big_City_New__c = 'Toronto';
        insert cms;
        
        test.startTest();
        Program__c pgm = new Program__c();
        pgm.Program_Type__c = 'Certificate';
        pgm.Est_Annual_Cost__c = 2000;
        pgm.Campus__c = cms.Id;
        pgm.ESL_Housing__c = 2200;
        pgm.CurrencyIsoCode = 'CAD';
        //pgm.CurrencyIsoCode = 
        Pgm.Admission_Grade__c='10';
       
        insert pgm;
        
         Major__c mjr =[SELECT ID FROM Major__c LIMIT 1];
        
        //opt_out_School__c optSchool = new opt_out_School__c();
        
        SchoolSearchAura.returnSearchedHighSchool('Afghan, Afghanistan','United States', pgm.Program_Type__c, '1200','100000','',cms.Province_State_New__c,cms.Nearest_Big_City_New__c,cms.Housing_Option__c,pgm.CurrencyIsoCode);
        SchoolSearchAura.returnSearchedcollegeSchool('Afghan, Afghanistan','United States', pgm.Program_Type__c, '1200','100000','',cms.Province_State_New__c,cms.Nearest_Big_City_New__c,mjr.id,pgm.CurrencyIsoCode,'','','','');
        test.stopTest();
    }
    
     /* commented on 2 June 2020 
       public static testMethod void testMethodUniversity(){ 
           
      // Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent_Acquisition').getRecordTypeId();
           
        List<Account> acc = [SELECT ID,RecordTypeId FROM ACCOUNT LIMIT 1];
           system.debug('acc===============>>>>'+acc);
           
       acc[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - CC').getRecordTypeId();
        acc[0].School_s_Country__c = 'United States';
        acc[0].Name = 'accUniversity';
        acc[0].BillingCity = 'Test';
            acc[0].BillingCountry = 'Test';
            acc[0].BillingState = 'Test';
            acc[0].BillingStreet = 'Test';
        update acc;
        
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Afghan, Afghanistan';
        cm.Amount__c = 123;
        cm.School__c = acc[0].Id;
        insert cm;
                  test.startTest();
      /*  
        Campus__c cms = new Campus__c();
        cms.Account__c = acc.Id;
          
        cms.Homestay_Grade__c = '10;12';
        // cms.Boarding_Grades__c = '10;11';
        cms.Country__c = 'Canada';
        cms.Student_taking_IB__c = 10;
        cms.Housing_Option__c='Homestay';
        cms.Province_State_New__c = 'Ontario';
        cms.Nearest_Big_City_New__c = 'Toronto';
        insert cms;
        
        Program__c pgm = new Program__c();
        pgm.Program_Type__c = 'All Grades Offered';
        pgm.Est_Annual_Cost__c = 2000;
        pgm.Campus__c = cms.Id;
        pgm.ESL_Housing__c = 2200;
        pgm.CurrencyIsoCode = 'CAD';
        pgm.Bachelor_Needed__c = 'Yes'; 
        pgm.IELTS_Min__c = '2.0';
        pgm.TOEFL_Min__c = 10;   
        //pgm.CurrencyIsoCode = 
        Pgm.Admission_Grade__c='10';
        insert pgm;
        */
    /*
           List<Contact> conLis = TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
        
        Campus__c cms = [SELECT ID,Province_State_New__c,Nearest_Big_City_New__c FROM Campus__c LIMIT 1];
        List<Program__c> pgm = [SELECT ID,Program_Type__c,CurrencyIsoCode,Bachelor_Needed__c FROM Program__c LIMIT 1];
        Major__c mjr =[SELECT ID FROM Major__c LIMIT 1];    
         // Opportunity__c op = new Opportunity__c();
           
        //opt_out_School__c optSchool = new opt_out_School__c();

     //   SchoolSearchAura.addRecomendedSchool( lisOpp[0].id,pgm);
         SchoolSearchAura.contractdisplay(acc[0].id);
       SchoolSearchAura.returnSearcheduniversitySchool('Afghan, Afghanistan', 'United States',  pgm[0].Program_Type__c, '1200', '100000', '10', 
                                                       cms.Province_State_New__c, cms.Nearest_Big_City_New__c, JSON.serialize(mjr), pgm[0].CurrencyIsoCode, 
                                                       pgm[0].Bachelor_Needed__c, '12', '1.5', acc[0].RecordTypeId);
           SchoolSearchAura.contractlist c = new SchoolSearchAura.contractlist();
           SchoolSearchAura.OpprtRecdDetails o = new SchoolSearchAura.OpprtRecdDetails();
           SchoolSearchAura.PicklistEntryWrapper p = new SchoolSearchAura.PicklistEntryWrapper();
           SchoolSearchAura.HSschool h = new SchoolSearchAura.HSschool();
           SchoolSearchAura.PSschool ps = new SchoolSearchAura.PSschool();
           SchoolSearchAura.PGschool pg = new SchoolSearchAura.PGschool();
                     
       test.stopTest();
    }
    */
    
    //overall class percentage was 31 % before this methods
    //______________________________________________________________________________________________________________________________________________________________________________
    //Added on 2 June 2020 31% - 51 %
    //3 June 2020 51% - 84%
    public static testMethod void testSearchedHighSchool(){
        
        Id accntSchlRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsClass.osHSRecTypeName).getRecordTypeId();
        Id campusHighSchRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusHSRecTypeName ).getRecordTypeId();
        Id progHighSchlRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programHSRecTypeName).getRecordTypeId();
        
        List< Account > listSchoolAccnt = [ SELECT Id FROM Account WHERE RecordTypeId =: accntSchlRecTypeId ];
        listSchoolAccnt[0].School_s_Country__c = 'Canada';
        update listSchoolAccnt;
        
        Commission_Table__c objCommTable = new Commission_Table__c();
        objCommTable.Nationality__c = 'Afghan, Afghanistan';
        objCommTable.Amount__c = 123;
        objCommTable.School__c = listSchoolAccnt[0].Id;
        insert objCommTable;
        
        Campus__c objCamp = new Campus__c();
        objCamp.Account__c = listSchoolAccnt[0].Id;
        objCamp.Homestay_Grade__c = '10;12';
        objCamp.Country_New__c = 'Canada';
        objCamp.Student_taking_IB__c = 10;
        objCamp.Housing_Option__c='Homestay';
        objCamp.RecordTypeId = campusHighSchRecTypeId;
        objCamp.Province_State_New__c = 'Ontario';
        objCamp.Nearest_Big_City_New__c = 'Toronto';
        objCamp.Housing_Option__c = 'Homestay';
        insert objCamp;
        
        test.startTest();
        
        Program__c objProg = new Program__c();
        objProg.RecordTypeId = progHighSchlRecTypeId;
        objProg.Program_Type__c = 'All Grades Offered';
        objProg.Est_Annual_Cost__c = 2000;
        objProg.Campus__c = objCamp.Id;
        objProg.ESL_Housing__c = 2200;
        objProg.CurrencyIsoCode = 'CAD';
        objProg.Bachelor_Needed__c = 'Yes'; 
        objProg.IELTS_Min__c = '2.0';
        objProg.TOEFL_Min__c = 10;   
        objProg.Admission_Grade__c='10';
        objProg.High_School_Graduation_Needed__c = 'Not Applicable';
        objProg.TOEFL_accepted_for_update_ESL_EAP__c = 'No';
        
        
        Program__c objProg1 = objProg.clone( false, true, false, false );
        objProg1.Program_Type__c = 'Performing Arts';
        
        insert new List< Program__c >{ objProg, objProg1 };
        
        SchoolSearchAura.getBranchPicklistvalues();
        
        //_________________________________________________  For Program Type " All Grades Offered "  ____________________________________________________________
        SchoolSearchAura.returnSearchedHighSchool('Afghan, Afghanistan', 'Canada', 'All Grades Offered', 'minbudget', '100000', '10', 'Ontario',
                                                  'Toronto', 'Homestay', 'CAD');
        
        //_________________________________________________  For Program Type " Performing Arts "  ____________________________________________________________
        SchoolSearchAura.returnSearchedHighSchool('Afghan, Afghanistan', 'Canada', 'Performing Arts', 'minbudget', '100000', '10', 'Ontario',
                                                  'Toronto', 'Homestay', 'CAD');
        
        //_________________________________________________ For Campus Search  _______________________________________________________-
        SchoolSearchAura.returnSearchedHighSchool('Afghan, Afghanistan', 'Canada', 'Performing Arts', 'minbudget', '100000', '', 'Ontario',
                                                  'Toronto', 'Homestay', 'CAD');
        
        
        test.stopTest();
    }
    
    //3rd June 2020
    public static testMethod void testMajorrecord(){
        
        Id accntSchlRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsClass.osHSRecTypeName).getRecordTypeId();
        Id campusHighSchRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusHSRecTypeName ).getRecordTypeId();
        Id campusCCRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusCCRecTypeName ).getRecordTypeId();
        Id progHighSchlRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programHSRecTypeName).getRecordTypeId();
        Id progCCRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programCCRecTypeName).getRecordTypeId();
        
        List< Account > listSchoolAccnt = [ SELECT Id FROM Account WHERE RecordTypeId =: accntSchlRecTypeId ];
        listSchoolAccnt[0].School_s_Country__c = 'Canada';
        update listSchoolAccnt;
        
        List<Account> lisAccCCSchool = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
        lisAccCCSchool[0].School_s_Country__c = 'Canada';
        insert lisAccCCSchool;
        
        
        Commission_Table__c objCommTable = new Commission_Table__c();
        objCommTable.Nationality__c = 'Afghan, Afghanistan';
        objCommTable.Amount__c = 123;
        objCommTable.School__c = listSchoolAccnt[0].Id;
        insert objCommTable;
        
        Campus__c objCamp = new Campus__c();
        objCamp.Account__c = listSchoolAccnt[0].Id;
        objCamp.Homestay_Grade__c = '10;12';
        objCamp.Country_New__c = 'Canada';
        objCamp.Student_taking_IB__c = 10;
        objCamp.Housing_Option__c='Homestay';
        objCamp.RecordTypeId = campusHighSchRecTypeId;
        objCamp.Province_State_New__c = 'Ontario';
        objCamp.Nearest_Big_City_New__c = 'Toronto';
        objCamp.Housing_Option__c = 'Homestay';
        
        Campus__c objCampCC =  objCamp.clone( false, true, false, false );
        objCampCC.RecordTypeId = campusCCRecTypeId;
        objCampCC.Account__c = lisAccCCSchool[0].Id;
        
        insert  new list< Campus__c > { objCamp, objCampCC };
        
        test.startTest();
        
        Program__c objProg = new Program__c();
        objProg.RecordTypeId = progHighSchlRecTypeId;
        objProg.Program_Type__c = 'All Grades Offered';
        objProg.Est_Annual_Cost__c = 2000;
        objProg.Campus__c = objCamp.Id;
        objProg.ESL_Housing__c = 2200;
        objProg.CurrencyIsoCode = 'CAD';
        objProg.Bachelor_Needed__c = 'Yes'; 
        objProg.IELTS_Min__c = '2.0';
        objProg.TOEFL_Min__c = 10;   
        objProg.Admission_Grade__c='10';
        objProg.High_School_Graduation_Needed__c = 'Not Applicable';
        objProg.TOEFL_accepted_for_update_ESL_EAP__c = 'No';
        
        
        Program__c objProg1 = objProg.clone( false, true, false, false );
        objProg1.Program_Type__c = 'Performing Arts';
        
        Program__c objProgCC = objProg.clone( false, true, false, false );
        objProgCC.RecordTypeId = progCCRecTypeId;
        objProgCC.Campus__c = objCampCC.Id;
        
        insert new List< Program__c >{ objProg, objProg1, objProgCC };
            
        Major__c objMajor = new Major__c();
        objMajor.Name = 'Test Prog CC Major';
        objMajor.Program__c = objProgCC.Id;
        insert objMajor;
        
        SchoolSearchAura.majorrecord('Canada', 'All Grades Offered', '', ConstantsClass.osCCRecTypeName,'Business');
        SchoolSearchAura.majorrecord('Canada', 'All Grades Offered', 'Test', ConstantsClass.osCCRecTypeName,'Business');
        
    }
    
    
    //3rd June 2020
    public static testMethod void testContractdisplay(){
        
        List<Account> lisAccCCSchool = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
        lisAccCCSchool[0].School_s_Country__c = 'Canada';
        lisAccCCSchool[0].Nationality__c='Afghan, Afghanistan';
        insert lisAccCCSchool;
        
        Commission_Table__c objCommTable = new Commission_Table__c();
        objCommTable.Nationality__c = 'Afghan, Afghanistan';
        objCommTable.Amount__c = 123;
        objCommTable.School__c = lisAccCCSchool[0].Id;
        insert objCommTable;
        
        List<Contract> lisCon = TestUtil.createContract(ConstantsClass.schoolRecTypeName, false,1);
        lisCon[0].AccountId =  lisAccCCSchool[0].Id;
        lisCon[0].Status = 'Valid';
        lisCon[0].Counter_Sign_Contract_Arrived_Date__c  = Date.today();
        lisCon[0].Contract_Open_End__c = true;
        lisCon[0].Fact_Sheet_Provided__c = 'No';
        lisCon[0].Need_Fact_Sheet__c  = 'No';         
        insert lisCon;
        
        test.startTest();
        
        SchoolSearchAura.contractdisplay( lisAccCCSchool[0].Id );
        
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        insert ListStaff;
        
        
        //Agent Account Creation
        List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
        lisacc[0].Account_Manager__c = ListStaff[0].Id;
        lisacc[0].Total_Admin_License__c = 10;
        lisacc[0].Total_User_License__c = 10;
        lisacc[0].Active_License__c=5;
        lisacc[0].License_End_Date__c=system.today()-1;
        insert lisacc;
        
        SchoolSearchAura.contractdisplay( lisacc[0].Id );
        
        SchoolSearchAura.formatCurr( 100); 
        test.stopTest();
        
    }
    
    //3rd June 2020
    public static testMethod void testAddRecomendedSchool(){
        
        Id accntSchlRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantsClass.osHSRecTypeName).getRecordTypeId();
        Id campusHighSchRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusHSRecTypeName ).getRecordTypeId();
        Id progHighSchlRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programHSRecTypeName).getRecordTypeId();
        
        List< Account > listSchoolAccnt = [ SELECT Id FROM Account WHERE RecordTypeId =: accntSchlRecTypeId ];
        listSchoolAccnt[0].School_s_Country__c = 'Canada';
        update listSchoolAccnt;
        
        Commission_Table__c objCommTable = new Commission_Table__c();
        objCommTable.Nationality__c = 'Afghan, Afghanistan';
        objCommTable.Amount__c = 123;
        objCommTable.School__c = listSchoolAccnt[0].Id;
        insert objCommTable;
        
        Campus__c objCamp = new Campus__c();
        objCamp.Account__c = listSchoolAccnt[0].Id;
        objCamp.Homestay_Grade__c = '10;12';
        objCamp.Country_New__c = 'Canada';
        objCamp.Student_taking_IB__c = 10;
        objCamp.Housing_Option__c='Homestay';
        objCamp.RecordTypeId = campusHighSchRecTypeId;
        objCamp.Province_State_New__c = 'Ontario';
        objCamp.Nearest_Big_City_New__c = 'Toronto';
        objCamp.Housing_Option__c = 'Homestay';
        insert objCamp;
        
        test.startTest();
        
        Program__c objProg = new Program__c();
        objProg.RecordTypeId = progHighSchlRecTypeId;
        objProg.Program_Type__c = 'All Grades Offered';
        objProg.Est_Annual_Cost__c = 2000;
        objProg.Campus__c = objCamp.Id;
        objProg.ESL_Housing__c = 2200;
        objProg.CurrencyIsoCode = 'CAD';
        objProg.Bachelor_Needed__c = 'Yes'; 
        objProg.IELTS_Min__c = '2.0';
        objProg.TOEFL_Min__c = 10;   
        objProg.Admission_Grade__c='10';
        objProg.High_School_Graduation_Needed__c = 'Not Applicable';
        objProg.TOEFL_accepted_for_update_ESL_EAP__c = 'No';
        
        insert objProg;
        
        List< Opportunity > listStudntOpp = TestUtil.createOpportunity( ConstantsClass.studentRecTypeName , true, 1);
        
        SchoolSearchAura.addRecomendedSchool( listStudntOpp[0].Id , new List< String > { objProg.ID + '/view' } );
        SchoolSearchAura.addRecomendedSchool( listStudntOpp[0].Id , new List< String > { objProg.ID } );
        
    }
    
    //3rd June 2020
    public static testMethod void testReturnSearchedCollegeUniversity(){
        
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
        
        test.startTest();
        
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
        
            
        //_________________________________________________________ For College ___________________________________________________________________________________________    
        SchoolSearchAura.returnSearchedcollegeSchool('Afghan, Afghanistan', 'Canada', 'All Grades Offered', '0', 
                                                     '1000000000000', '', 'Ontario', 'Toronto', 
                                                     'Test Prog CC Major', 'CAD', 'No', '', '', '');
        
        objProgCC.High_School_Graduation_Needed__c = 'Yes';
        objProgCC.Bachelor_Needed__c = 'Not Applicable';
        update objProgCC;
        
        SchoolSearchAura.returnSearchedcollegeSchool('Afghan, Afghanistan', 'Canada', 'All Grades Offered', '0', 
                                                     '1000000000000', '', 'Ontario', 'Toronto', 
                                                     'Test Prog CC Major', 'CAD', 'Yes', '', '', '');
        
        SchoolSearchAura.returnSearchedcollegeSchool('Afghan, Afghanistan', 'Canada', 'All Grades Offered', '0', 
                                                     '1000000000000', '', 'Ontario', 'Toronto', 
                                                     'Test Prog CC Major', 'CAD', 'Yes', '120', '8', '');
        
        
        //______________________________________________________ For University ________________________________________________________________________________________----
        
        objProgCC.High_School_Graduation_Needed__c = 'Not Applicable';
        objProgCC.Bachelor_Needed__c = 'No';
        update objProgCC;
        
        SchoolSearchAura.returnSearcheduniversitySchool('Afghan, Afghanistan', 'Canada', 'All Grades Offered', '0', 
                                                        '1000000000000', '', 'Ontario', 'Toronto', 
                                                        'Test Prog CC Major', 'CAD', 'No', '120', '8', '');
        
        objProgCC.High_School_Graduation_Needed__c = 'Not Applicable';
        objProgCC.Bachelor_Needed__c = 'Yes';
        update objProgCC;
        
         SchoolSearchAura.returnSearcheduniversitySchool('Afghan, Afghanistan', 'Canada', 'All Grades Offered', '0', 
                                                        '1000000000000', '', 'Ontario', 'Toronto', 
                                                        'Test Prog CC Major', 'CAD', 'Yes', '120', '8', '');
        
        SchoolSearchAura.getVoid();
        
        List< Opportunity > listStudntOpp = TestUtil.createOpportunity( ConstantsClass.studentRecTypeName , true, 1);
        
        SchoolSearchAura.getOppRecDetails('TestOppoStudent');
        
        
    }
}