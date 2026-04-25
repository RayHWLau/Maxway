@isTest

private class TaskCreationClassTest {
    /*
    static testMethod void  test1(){
        TestUtil.createCustomSettingInvoiceRollUp(true);
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
            List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, false, 1);
            lisOpp[0].Intended_Go_Abroad_Date__c=system.today();
            insert lisOpp[0];
            lisOpp[0].Stagename = 'Closed Lost';
            lisOpp[0].Closed_Lost_Reason__c = 'Satisfy with system already in place';
            
            update lisOpp;
            
            List<Case> caseList =  TestUtil.createApplication(ConstantsClass.caseOptInRecTypeName, false, 1);
            //  caseList[0].Agent_Application_Manager__c = lisacc[0].id;
            insert caseList;
            
            
            TaskCreationClass.Opportunityrejected(lisOpp, new Map<Id, Opportunity>{lisOpp[0].Id=>lisOpp[0]});
            system.debug('lisOpptest'+lisOpp);
           // TaskCreationClass.opportunitycreation(lisOpp);
            
            Test.startTest();
            
            TaskCreationClass.taskWhenapplicationcreated(caseList);
            TaskCreationClass.taskWhenDepositPaidDateNotNull(caseList);
            TaskCreationClass.taskCreationWhenOptInApplicationForApproval(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskWhenClientCanfullfillOtherConditions(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskWhendepositfilled(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskWhenpendingArrival(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskWhenVisaInprogress(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskWhensubmittedtoschooldateisfilled(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskWhenstagependingstudentconformation(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
            TaskCreationClass.taskCreationWhenNINapproverejected(lisacc, new map<id,Account>{lisacc[0].id=>lisacc[0]});
            TaskCreationClass.taskWhenstudentdoesnotconforminterview(caseList, new map<id,case>{caseList[0].id=>caseList[0]});
           // TaskCreationClass.accountcreation(lisacc);
            TaskCreationClass.taskcreate('new', Date.newInstance(2020, 05, 19), lisOpp[0].Id, lisOpp[0].Id, lisOpp[0].Id);
            
            test.stopTest();
            
        }               
    }
    */
    //June 4 2020
    //________________________________________________________________________________________________________________________________________________________________________
    
    @testSetup
    public static void dataFactory(){
        
        TestUtil.createCustomSettingApplicationPrepaidBaln(true);
        
        Id campusCCRecTypeId = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get( ConstantsClass.campusCCRecTypeName ).getRecordTypeId();
        Id progCCRecTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(ConstantsClass.programCCRecTypeName).getRecordTypeId();
        
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin1';
        insert ListStaff;
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
        List<Account> lisAccCCSchool = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
        lisAccCCSchool[0].School_s_Country__c = 'Canada';
        lisAccCCSchool[0].account_manager__c = ListStaff[0].Id;
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
        
        Major__c maj = new Major__c(
        	Program__c = objProgCC.Id,
            Require_Related_Undergraduate_Major__c = 'No',
            Name = 'Business',
            GMAT_Uni_Admission__c = 'No'
        );
        
        insert maj;
        
        list<Opportunity> lisStudentOpp = TestUtil.createOpportunity(ConstantsClass.studentRecTypeName, false, 1);
        lisStudentOpp[0].Num_of_Year_to_Graduation__c = 2;
        insert lisStudentOpp;
        
        Test.startTest();
        list< Case > listApplication = TestUtil.createApplication( ConstantsClass.caseOptOutRecTypeName , false, 1);
        listApplication[0].Opportunity__c = lisStudentOpp[0].Id;
        listApplication[0].Program__c = objProgCC.Id;
        listApplication[0].School__c = lisAccCCSchool[0].Id;
        listApplication[0].Major2__c = maj.Id;
        insert listApplication;
        Test.stopTest();
    }
    
    //added on 4 June 2020
    //5 June 2020
    public static testMethod void testMethod1(){
        
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        Id recordTypeIdOptIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        insert ListStaff;
        
        List<Account> listAcc = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, false, 1);
        listAcc[0].Data_Origin__c  = 'H';
        listAcc[0].Account_Manager__c = ListStaff[0].Id;
        listAcc[0].Expected_Graduation_Date__c = Date.today();
        insert listAcc;
        
        list<Opportunity> lisStudentOpp = [ SELECT Id,OwnerId,RecordTypeId,StageName FROM Opportunity WHERE RecordType.Name =: ConstantsClass.studentRecTypeName ];
        
        lisStudentOpp[0].Intended_Go_Abroad_Date__c = Date.today();
        lisStudentOpp[0].Case_Manager__c = ListStaff[0].Id;
        
       // TaskCreationClass.opportunitycreation( lisStudentOpp );
        
        Opportunity objOppClone =  lisStudentOpp[0].clone( false, True, false, false );
        lisStudentOpp[0].stageName = 'Rejected'; 
        
        TaskCreationClass.Opportunityrejected( lisStudentOpp , new Map< Id, opportunity > { lisStudentOpp[0].Id => objOppClone } );
        
        List< Case > listCase = [ SELECT Id,OwnerId,Deposit_Amount__c,RecordTypeId,Maxway_Application_Manager__c,Agent_Application_Manager__c,
                                 Other_Conditions__c,Met_Conditions__c,Deposit_Due_date__c,Opportunity__c,Stage__c,Submit_Application_to_School_Date__c,
                                 Deposit_Paid_Date__c,School__c,approval_status__c
                                 FROM Case 
                                 WHERE RecordType.Name =: ConstantsClass.caseOptOutRecTypeName ];
        
        listCase[0].Agent_Application_Manager__c = ListStaff[0].Id;
        listCase[0].Maxway_Application_Manager__c = ListStaff[0].Id;
        TaskCreationClass.taskWhenapplicationcreated( listCase );
        
        listCase[0].recordTypeId = recordTypeIdOptIN;
        TaskCreationClass.taskWhenapplicationcreated( listCase );
        listCase[0].recordTypeId = recordTypeIdOptIN;
        listCase[0].Deposit_Paid_Date__c = Date.today();
        //TaskCreationClass.taskWhenDepositPaidDateNotNull( listCase );
        
        listCase[0].recordTypeId = recordTypeIdOptOutNIN;
        
        Case objCaseClone = listCase[0].clone( false, true, false, false );
        listCase[0].Other_Conditions__c = 'Yes';
        listCase[0].Met_Conditions__c = true; 
        
        test.startTest();
        TaskCreationClass.taskWhenClientCanfullfillOtherConditions(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].Deposit_Amount__c = 100;
        listCase[0].Deposit_Due_date__c = Date.today();
        TaskCreationClass.taskWhendepositfilled(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].recordTypeId = recordTypeIdOptIN;
        TaskCreationClass.taskWhendepositfilled(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].stage__c = 'Pending Arrival';
        
        TaskCreationClass.taskWhenpendingArrival(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].recordTypeId = recordTypeIdOptOutNIN;
        TaskCreationClass.taskWhenpendingArrival(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].stage__c = 'Visa In Progress';
        TaskCreationClass.taskWhenVisaInprogress(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].recordTypeId = recordTypeIdOptIN;
        TaskCreationClass.taskWhenVisaInprogress(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].Submit_Application_to_School_Date__c = Date.today();
        TaskCreationClass.taskWhensubmittedtoschooldateisfilled(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].recordTypeId = recordTypeIdOptOutNIN;
        TaskCreationClass.taskWhensubmittedtoschooldateisfilled(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].Deposit_Paid_Date__c = Date.today();
        objCaseClone.Deposit_Paid_Date__c = Date.today().addDays( -1 );
        
        TaskCreationClass.taskWhenstagependingstudentconformation(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].recordTypeId = recordTypeIdOptIN;
        TaskCreationClass.taskWhenstagependingstudentconformation(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        test.stopTest();
        
    }
    
    //added on 5 June 2020
    public static testMethod void testMethod2(){
        
        Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
        Id recordTypeIdOptIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        insert ListStaff;
        
        List<Account> listAcc = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, false, 1);
        listAcc[0].Data_Origin__c  = 'H';
        listAcc[0].Account_Manager__c = ListStaff[0].Id;
        listAcc[0].Expected_Graduation_Date__c = Date.today();
        insert listAcc;
        
        list<Opportunity> lisStudentOpp = [ SELECT Id,OwnerId,RecordTypeId,StageName FROM Opportunity WHERE RecordType.Name =: ConstantsClass.studentRecTypeName ];
        
        lisStudentOpp[0].Intended_Go_Abroad_Date__c = Date.today();
        lisStudentOpp[0].Case_Manager__c = ListStaff[0].Id;
        
        Opportunity objOppClone =  lisStudentOpp[0].clone( false, True, false, false );
        lisStudentOpp[0].stageName = 'Rejected'; 
        
        
        List< Case > listCase = [ SELECT Id,OwnerId,Deposit_Amount__c,RecordTypeId,Maxway_Application_Manager__c,Agent_Application_Manager__c,
                                 Other_Conditions__c,Met_Conditions__c,Deposit_Due_date__c,Opportunity__c,Stage__c,Submit_Application_to_School_Date__c,
                                 Deposit_Paid_Date__c,School__c,approval_status__c
                                 FROM Case 
                                 WHERE RecordType.Name =: ConstantsClass.caseOptOutRecTypeName ];
        
        listCase[0].Agent_Application_Manager__c = ListStaff[0].Id;
        listCase[0].Maxway_Application_Manager__c = ListStaff[0].Id;
        
        Case objCaseClone = listCase[0].clone( false, true, false, false );
        
        Test.startTest();
        
        listCase[0].Approval_Status__c = 'Pending';
        
        TaskCreationClass.taskCreationWhenOptInApplicationForApproval(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].Approval_Status__c = 'Approved';
        TaskCreationClass.taskCreationWhenOptInApplicationForApproval(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].Approval_Status__c = 'Rejected';
        TaskCreationClass.taskCreationWhenOptInApplicationForApproval(listCase, new map< Id, Case > { listCase[0].Id => objCaseClone });
        
        listCase[0].Student_Confirm_Offer__c = 'No';
        objCaseClone.Stage__c = 'Test';
        TaskCreationClass.taskWhenstudentdoesnotconforminterview( listCase, new map< Id, Case > { listCase[0].Id => objCaseClone } );
        test.stopTest();
    }
    
    //added on 5 June 2020
    public static testMethod void testMethod3(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        Profile objMaxSystAdminProfile = [SELECT Id FROM Profile WHERE Name = 'Maxway System Administrator'];
        User maxwaySystemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objMaxSystAdminProfile.Id, false );
        
        system.runAs( maxwaySystemAdminUser ){
            
            List<Staff__c> ListStaff1 = TestUtil.createStaff(False, 1);
            ListStaff1[0].Name = 'HQ Admin';
            insert ListStaff1;
        }
        
        User objCurrUser =  new User();
        objCurrUser.Id = Userinfo.getUserId();
        system.runAs( objCurrUser ){
            
            
            Id recordTypeIdOptOutNIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-Out/NIN/Maxway)').getRecordTypeId();
            Id recordTypeIdOptIN = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Application(Opt-In)').getRecordTypeId();
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            insert ListStaff;
            
            List<Account> listAcc = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, false, 1);
            listAcc[0].Data_Origin__c  = 'H';
            listAcc[0].Account_Manager__c = ListStaff[0].Id;
            listAcc[0].Expected_Graduation_Date__c = Date.today();
            insert listAcc;
            
            list<Opportunity> lisStudentOpp = [ SELECT Id,OwnerId,RecordTypeId,StageName FROM Opportunity WHERE RecordType.Name =: ConstantsClass.studentRecTypeName ];
            
            lisStudentOpp[0].Intended_Go_Abroad_Date__c = Date.today();
            lisStudentOpp[0].Case_Manager__c = ListStaff[0].Id;
            
            Opportunity objOppClone =  lisStudentOpp[0].clone( false, True, false, false );
            lisStudentOpp[0].stageName = 'Rejected'; 
            
            
            List< Case > listCase = [ SELECT Id,OwnerId,Deposit_Amount__c,RecordTypeId,Maxway_Application_Manager__c,Agent_Application_Manager__c,
                                     Other_Conditions__c,Met_Conditions__c,Deposit_Due_date__c,Opportunity__c,Stage__c,Submit_Application_to_School_Date__c,
                                     Deposit_Paid_Date__c,School__c,approval_status__c
                                     FROM Case 
                                     WHERE RecordType.Name =: ConstantsClass.caseOptOutRecTypeName ];
            
            listCase[0].Agent_Application_Manager__c = ListStaff[0].Id;
            listCase[0].Maxway_Application_Manager__c = ListStaff[0].Id;
            
            Case objCaseClone = listCase[0].clone( false, true, false, false );
            
            Account objAccntClone = listAcc[0].clone( False, true, false, false );
            listAcc[0].Approval_Status__c = 'Pending';
            TaskCreationClass.taskCreationWhenNINapproverejected( listAcc , new Map< Id, Account >{ listAcc[0].Id => objAccntClone } );
            
            listAcc[0].Approval_Status__c = 'Approved';
            TaskCreationClass.taskCreationWhenNINapproverejected( listAcc , new Map< Id, Account >{ listAcc[0].Id => objAccntClone } );
            
            listAcc[0].Approval_Status__c = 'Rejected';
            TaskCreationClass.taskCreationWhenNINapproverejected( listAcc , new Map< Id, Account >{ listAcc[0].Id => objAccntClone } );
        }
    }
}