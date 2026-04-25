public class TestUtil {
    
    public static List<Staff__c> createStaff(Boolean isDML, Integer recordSize){
        List<Staff__c> listStaff = new List<Staff__c>();
        for(Integer i=0;i<recordSize; i++){
            Staff__c objStaff = new Staff__c();
            objStaff.Name = 'TestStaff';
            objStaff.Email__c = 'testStaff@gmail.com';
            objStaff.Mobile__c = '9999999999';
            objStaff.Active__c = true;
            objStaff.CurrencyIsoCode = 'HKD';
            objStaff.Title__c = 'TestTitle';
            //objStaff.ISMaxway__c='True';
            listStaff.add(objStaff);
        }
        if(isDML && listStaff.size()>0)
            insert listStaff;
        return listStaff;
        
    }
    
    public static List<Account> createAccount(String recTypeName, Boolean isDML, Integer recordSize){
        
        List<Account> ListAccount = new List<Account>();
        string s=Schema.SObjectType.Account.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s <> Null){
            
            for(Integer i=0;i<recordSize;i++){
                Account objacc = new Account();
                objacc.School_s_Country__c = 'United States';
                objacc.RecordTypeId = s;
                
                if(recTypeName == ConstantsClass.accAgentRecTypeName){
                    objacc.Name = 'TestAgent';
                    objacc.Bank_Account_Holder__c = 'TT';
                    objacc.Bank_Account_Number__c = 4567890;
                    objacc.Bank_Address__c = 'Test Address';
                    objacc.Bank_Code__c = 'we234';
                    objacc.Bank_Routing_or_Transit_Number__c = '45678';
                    objacc.Banking_Info__c  = 'Test TEst TEst';
                    objacc.Bank__c = 'TestBank';
                    objacc.Website= 'www.test.com';
                    
                    objacc.Status_Sub_Agent__c = ConstantsClass.statusSubAgentProspect;
                    objacc.BillingStreet = '7';    
                    objacc.BillingCity = 'testing';
                    objacc.BillingPostalCode  = '202001';    
                    objacc.SWIFT_Code__c = '1655';
                    objacc.CurrencyIsoCode='USD';    //account currency
                    //objacc.Study_Abroad_Countries__c = 'Afghanistan';
                    objacc.Top_Sending_Country__c = 'Afghanistan';
                    objacc.Last_Year_s_Total_Number_of_Successful_A__c = '21-50';
                    objacc.Goal_With_Portal__c = 'Empowerment';
                    objacc.Branch_Conflicts_with_Maxway__c = 'Yes';
                    objacc.Account_Manager__c = TestUtil.createStaff(true,1)[0].Id;
                    //objacc.School_s_Country__c = 'United States';
                    ListAccount.add(objacc);
                }
                
                if(recTypeName == ConstantsClass.studntAccRecTypeName){
                    objacc.LastName = 'Test Last';
                    objacc.Student_Status__c = 'Prospective';
                    objacc.Account_Manager__c = TestUtil.createStaff(true,1)[0].Id;
                    ListAccount.add(objacc);
                }
                if(recTypeName == ConstantsClass.homeCompRecTypeName){
                    objacc.LastName = 'TestHomeCompny';
                    objacc.CurrencyIsoCode='USD';    //account currency
                    ListAccount.add(objacc);
                }
                if(recTypeName == ConstantsClass.osCCRecTypeName){
                    objacc.Name = 'TestMarketing';
                    objacc.CurrencyIsoCode='USD';    //account currency
                    objacc.Nationality__c= 'Afghan, Afghanistan	';
                    ListAccount.add(objacc);
                }
                if(recTypeName == ConstantsClass.subAgcyRecTypeName){
                    objacc.Name = 'TestSubAgency';
                    objacc.CurrencyIsoCode='USD';    //account currency
                    objacc.Nationality__c= 'Afghan';
                    ListAccount.add(objacc);
                }
                if(recTypeName == ConstantsClass.localSclRecTypeName){
                    objacc.Name = 'TestSubAgency';
                    objacc.CurrencyIsoCode='USD';    //account currency
                    objacc.Nationality__c= 'Afghan';
                    ListAccount.add(objacc);
                }
                
                if(recTypeName == ConstantsClass.osHSRecTypeName){
                    objacc.Name = 'TestHighSchool';
                    ListAccount.add(objacc);
                }
                
                if(recTypeName == ConstantsClass.osUniRecTypeName){
                    objacc.Name = 'TestUniSchool';
                    ListAccount.add(objacc);
                }
            }
        }
        // set values here
        if(isDml && ListAccount.size() >0){
            insert ListAccount;
        }
        return ListAccount;
    }
    
    public static List<Opportunity> createOpportunity(String recTypeName, Boolean isDML, Integer recordSize){
        List<Opportunity> oppList = new List<Opportunity>();
        string s = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s <> Null){
            for(Integer i=0;i<recordSize;i++){
                
                Opportunity objOpp = new Opportunity();
                objOpp.RecordTypeId = s;
                if(recTypeName ==  ConstantsClass.agentAcqRecTypeName){
                    DateTime myDateTime = DateTime.now();
                    objOpp.Name = 'TestOppoAcq'+ String.ValueOf(myDateTime.millisecond());
                    objOpp.Business_Type__c = 'New';
                    objOpp.StageName = 'Initiate Contact';
                    objOpp.CloseDate = date.today().addDays(+10);
                    objOpp.Reference_Check_Sent__c = true;
                    objOpp.Reference_Verification_Submitted_Date__c = Null;
                    oppList.add(objOpp);
                }
                
                if(recTypeName == ConstantsClass.studentRecTypeName){
                     DateTime mydt = DateTime.now();
                    objOpp.Name = 'TestOppoStudent' +String.ValueOf(mydt.millisecond());
                    objOpp.AccountId = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, true, 1)[0].Id;
                    objOpp.CloseDate = date.today().addDays(+10);
                    objOpp.StageName = 'Placed';
                    objOpp.Case_Manager__c = TestUtil.createStaff(true,1)[0].Id;
                    oppList.add(objOpp);
                    
                }
                
                if(recTypeName == ConstantsClass.renAgntRecTypeName){
                     DateTime mydt = DateTime.now();
                    objOpp.Name = 'TestRenAgent' +String.ValueOf(mydt.millisecond());
                    objOpp.Number_Of_Licence__c = 2;
                    objOpp.Number_of_not_in_database_schools__c = 2;
                    objOpp.Business_License_Valid_Till__c= date.today().addDays(+50);
                    objOpp.Agent_Sign_Up_Form_Sent_Date__c = date.today().addDays(-5);
                    objOpp.Agent_Sign_Up_Form_Submitted_Date__c = date.today();
                    objOpp.Number_of_Admin_Licenses__c = 5;
                    objOpp.Which_country_s_school_list_to_purchase__c = 'Canada';
                    objOpp.Portal_Admin_Email__c = 'test@gmail.com';
                    objOpp.StageName = 'Initiate Contact';
                    objOpp.CloseDate = date.today().addDays(+50);
                    oppList.add(objOpp);
                }
            }
            
        }
        if(isDml && oppList.size() >0){
            insert  oppList;
        }
        return oppList;
    }
    
    public static List<Contract> createContract(String recTypeName, Boolean isDML, Integer recordSize){
        List<Contract> ListCntrct = new List<Contract>();
        string s = Schema.SObjectType.Contract.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<> Null){
            for(Integer i=0;i<recordSize;i++){
                Contract conObj = new Contract();
                conObj.RecordTypeId = s;
                if(recTypeName == ConstantsClass.schoolRecTypeName){
                    conObj.Status = 'Soliciting contract';
                    conObj.Commissionable__c = 'Commission';
                    conObj.Contract_Type__c = 'Global Contract';
                    ListCntrct.add(conObj);
                }
                if(recTypeName == ConstantsClass.oppAgentRecTypeName){
                    conObj.Status = 'Draft';
                    conObj.StartDate = date.today();
                    conObj.ContractTerm = 2;
                    ListCntrct.add(conObj);
                }
                if(recTypeName == ConstantsClass.marketingConRecTypeName ){
                    conObj.Status = 'Draft';
                    conObj.StartDate = date.today().addDays(-31);
                    conObj.ContractTerm = 2;
                    ListCntrct.add(conObj);
                }
            }
        }
        if(isDML && ListCntrct.size()>0)
            insert ListCntrct;
        return ListCntrct;
    } 
    
    public static List<Lead> createLead(String recTypeName, Boolean isDML, Integer recordSize){
        List<Lead> ListLead = new List<Lead>();
        string s = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<> Null){
            for(Integer i=0;i<recordSize;i++){
                Lead ld = new Lead();
                ld.RecordTypeId = s;
                if(recTypeName == ConstantsClass.leadAgentAcqRecTypeName){
                    ld.Status = 'Qualified';
                    ld.Salutation = 'Mr';
                    ld.LeadSource = 'Website';
                    ld.LastName = 'TestLead';
                    ld.Country_Code__c = 'Algeria (213)';
       
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
                    //ld.Head_Office_Country__c = 'United States';
                    ld.Head_Office_City__c = 'Anchorage';
                    ld.Head_Office_Province_State__c = 'Alaska';
                    ld.Last_Years_Total_Successful_Applications__c= '0-20';
                    ld.Number_Of_Full_Time_Staff__c = 20;
                    ld.Study_Abroad_Countries__c = 'Afghanistan';
                    ld.Goal_With_Portal__c  = 'Others';
                    ld.Top_Sending_Countries__c ='Afghanistan';
                    ld.Goal_With_Portal_Others__c = 'test';   
                    ListLead.add(ld);
                }
            }
        }
        system.debug('ListLead.size()'+ListLead.size());
        if(isDML && ListLead.size()>0)
            insert ListLead;
        return ListLead;
    }
    
    public static List<Invoice__c> createInvoice(String recTypeName, Boolean isDML, Integer recordSize){
        List<Invoice__c> ListInvoice = new List<Invoice__c>();
        string s = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<> Null){
            for(Integer i=0;i<recordSize;i++){
                Invoice__c inv  = new Invoice__c();
                inv.RecordTypeId = s;
                if(recTypeName == ConstantsClass.invoiceAgentRecTypeName){
                    inv.Invoice_Type__c = 'License Fee';
                    inv.Invoiced_Amount__c = 20000;
                    inv.Status__c= 'Issued'; 
                    inv.CurrencyIsoCode = 'USD';
                    ListInvoice.add(inv);
                }
            }
        }
        if(isDML && ListInvoice.size() >0)
            insert ListInvoice;
        return ListInvoice;
    }
    
    public static List<Contact> createContact(String recTypeName, Boolean isDML, Integer recordSize){
        List<Contact> listCon = new List<Contact>();
        string s = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<> Null){
            for(Integer i=0;i<recordSize;i++){
                Contact con = new Contact();
                con.RecordTypeId = s;
                if(recTypeName == ConstantsClass.contactAgentRecTypeName){
                    con.Salutation = 'Mr';
                    con.LastName = 'TestCon';
                    con.Title = 'TestTitle';
                    con.Email ='a@g.com';
                    listCon.add(con);
                }
                if(recTypeName == ConstantsClass.contactPrimaryRecTypeName){
                    con.Salutation = 'Mr';
                    con.LastName = 'TestCon';
                    con.Title = 'TestTitle';
                    con.Email ='a@g.com';
                    con.Function__c = 'Admission';
                    listCon.add(con);               
                }
                if(recTypeName == ConstantsClass.contactOverSeaRecTypeName){
                    con.Salutation = 'Mr';
                    con.LastName = 'TestCon';
                    con.Title = 'TestTitle';
                    con.Email ='a@g.com';
                    con.Function__c = 'Admission';
                    con.AccountId = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, true, 1)[0].Id;
                    listCon.add(con);    
                }
            }
        }
        
        if(isDML && listCon.size() >0)
            insert listCon;
        return listCon;
    }
    
    public static List<Case> createApplication(String recTypeName, Boolean isDML, Integer recordSize){
        List<Case> lisApp = new List<Case>();
        string s = Schema.SObjectType.Case.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<>Null){
            for(Integer i=0;i<recordSize; i++){
                Case cs = new Case();
                cs.RecordTypeId = s;
                if( true ){ // Commented by karan recTypeName == ConstantsClass.caseCCRecTypeName
                    cs.Status = 'In Progress';
                    cs.Placed_Grade__c = 'Grade 3';
                    cs.Term__c = 'Fall';
                    cs.Year__c = '2011';
                   cs.Start_Year_Year__c='2011';
                    cs.Start_Month__c='May';
                    lisApp.add(cs);
                }
            }
        }
        
        if(isDML && lisApp.size() >0)
            insert lisApp;
        return lisApp;
    }
    
    public static List<Campus__c> createCampus(String recTypeName, Boolean isDML, Integer recordSize){
        List<Campus__c> cmpsLis = new List<Campus__c>();
        string s = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<>Null){
            for(Integer i=0;i<recordSize; i++){
                Campus__c cms = new Campus__c();
                cms.RecordTypeId = s;
                if(recTypeName == ConstantsClass.campusCCRecTypeName){
                    
                    
                    
                }
                if(recTypeName == ConstantsClass.campusESLRecTypeName){
                    
                }
                if(recTypeName == ConstantsClass.campusHSRecTypeName){
                    cms.Homestay_Grade__c = '10;12';
                    // cms.Boarding_Grades__c = '10;11';
                    cms.Country_New__c = 'United States';
                    cms.Student_taking_IB__c = 10;
                   // cms.Housing_Option__c='Homestay';
                    //cms.Province_State_New__c = 'Ontario';
                    //cms.Nearest_Big_City_New__c = 'Toronto';
                    cms.CurrencyIsoCode='USD';
                    cmpsLis.add(cms);
                    
                    
                }
                if(recTypeName == ConstantsClass.campusUniRecTypeName){
                    cms.Account__c = TestUtil.createAccount(ConstantsClass.osUniRecTypeName, true, 1)[0].Id;
                    cms.Homestay_Grade__c = '10;12';
                    // cms.Boarding_Grades__c = '10;11';
                    cms.Country_New__c = 'Canada';
                    cms.Student_taking_IB__c = 10;
                    cms.Housing_Option__c='Homestay';
                    cms.Province_State_New__c = 'Ontario';
                    cms.Nearest_Big_City_New__c = 'Toronto';
                    cms.CurrencyIsoCode='CAD';
                    cmpsLis.add(cms);
                    
                }
            }
            
        }
        if(isDML && cmpsLis.size() >0)
            insert cmpsLis;
        return cmpsLis;
    }
    
    public static List<Program__c> createProgram(String recTypeName, Boolean isDML, Integer recordSize){
        List<Program__c> prgrmLis = new List<Program__c>();
        string s = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<>Null){
            for(Integer i=0;i<recordSize; i++){
                Program__c pgm = new Program__c();
                pgm.RecordTypeId = s;
                if(recTypeName == ConstantsClass.programCCRecTypeName){
                    
                    
                }
                if(recTypeName == ConstantsClass.eslCRecTypeName){
                    
                }
                if(recTypeName == ConstantsClass.programHSRecTypeName){
                    
                }
                if(recTypeName == ConstantsClass.programUniRecTypeName){
                    pgm.Program_Type__c = 'Bachelor';
                    pgm.Est_Annual_Cost__c = 2000;
                    pgm.Campus__c = TestUtil.createCampus(ConstantsClass.campusUniRecTypeName, true, 1)[0].Id;
                    pgm.ESL_Housing__c = 2200;
                    pgm.CurrencyIsoCode = 'CAD';
                    pgm.Bachelor_Needed__c = 'Not Applicable'; 
                    pgm.IELTS_Min__c = '2.0';
                    pgm.TOEFL_Min__c = 10;   
                    pgm.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
                    pgm.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
                    pgm.High_School_Graduation_Needed__c = 'Yes';
                    Pgm.Admission_Grade__c='10';
                    prgrmLis.add(pgm);
                }
            }
            
        }
        if(isDML && prgrmLis.size() >0)
            insert prgrmLis;
        return prgrmLis;
    }
    
    public static List<Major__c> createMajor(String recTypeName, Boolean isDML, Integer recordSize){
        List<Major__c> lisMajor = new List<Major__c>();
        string s = Schema.SObjectType.Major__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId();
        if(s<>Null){
            for(Integer i=0;i<recordSize; i++){
                Major__c mjr = new Major__c();
                mjr.RecordTypeId =s;
                if(recTypeName == ConstantsClass.majorMjrRecTypeName){
                    mjr.Name = 'TestMajor';
                    mjr.Program__c = TestUtil.createProgram(ConstantsClass.programUniRecTypeName, true, 1)[0].Id;
                    lisMajor.add(mjr);
                }
            }
        }
        if(isDML && lisMajor.size() >0)
            insert lisMajor;
        return lisMajor;
    }
    
    //#####################################################################################################################################################################################
    //@Karan Singh 29 Jan 2020
    
    //-------------------------------------------------------------------  Contract Line Creation  -------------------------------------------------------------------------------------
    public static list< Contract_Item__c > createContractItem ( Id contractId, String recType, Integer recordSize, String tariffType, Boolean isDml ){
        
        list< Contract_Item__c > listContract = new list< Contract_Item__c >();
        Id recordTypeId = Schema.SObjectType.Contract_Item__c.getRecordTypeInfosByName().get( recType ).getRecordTypeId();
        
        for( Integer i = 0; i < recordSize; i++ ){
            
            Contract_Item__c objContractLine = new Contract_Item__c();
            objContractLine.RecordTypeId = recordTypeId;
            objContractLine.Contract__c = contractId;
            objContractLine.Tariff_Type__c = tariffType;
           // objContractLine.Unit_Price__c = 2;
            objContractLine.Opt_In__c = 4;
            objContractLine.Opt_Out_NIN__c = 0;
            objContractLine.CurrencyIsoCode='USD';
            
            listContract.add( objContractLine );
        }
        
        if( isDml )
            insert listContract;
        
        return listContract;
    }
    
    //-------------------------------------------------------------------Commission Table Creation -------------------------------------------------------------------------------------
    public static List< Commission_Table__c > createCommissionTable( Integer recordSize, Id schoolId, Boolean isDMl ){
        
        list< Commission_Table__c > listCommission = new list< Commission_Table__c >();
        
        for( Integer i = 0; i < recordSize; i++ ){
            
            Commission_Table__c objCommTable = new Commission_Table__c();
            objCommTable.School__c = schoolId;
            objCommTable.Amount__c = 12;
            objCommTable.Nationality__c = Account.Nationality__c.getDescribe().getPicklistValues()[0].getValue();
            listCommission.add( objCommTable );
            
        }
        
        if( isDml )
            insert listCommission;
        
        return listCommission;
    }
    
    //-------------------------------------------------------------------System Admin User Creation -------------------------------------------------------------------------------------
    public static User createSystemAdminUser ( Id portalRoleId, Id systemAdminProfifleID, Boolean isDml ){
        User systemAdminUser = new User(
            ProfileId = systemAdminProfifleID,
            LastName = 'Invoice last',
            isActive = true,
            UserRoleId = portalRoleId,
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
        
        if( isDml )
            insert systemAdminUser;
        
        return systemAdminUser;
    }
    //-------------------------------------------------------------------  Partner User Creation -------------------------------------------------------------------------------------
    public static User createPartnerUser ( Id contactId, Id partnerProfifleID, Boolean isDml ){
        
        User partnerUser = new User(
            Username = System.now().millisecond() + 'test12345nghj@test.com',
            //  UserRoleId = portalRole2.Id,
            ContactId = contactId,
            ProfileId = partnerProfifleID,
            isActive = true,
            Alias = 'test123',
            Email = 'test12345nghj@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'partnerUser',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        
        if( isDml )
            insert partnerUser;
        
        return partnerUser;
    }
    
    //-------------------------------------------------------------------Invoice Custom Setting -------------------------------------------------------------------------------------
    public static InvoiceTrigger_RollUpInvoiceAmount__c createCustomSettingInvoiceRollUp( Boolean isDml ){
        
        InvoiceTrigger_RollUpInvoiceAmount__c triggerSetting = new InvoiceTrigger_RollUpInvoiceAmount__c();
        triggerSetting.Name = 'triggerSettings';
        triggerSetting.Invoice_Type__c = 'Prepaid';
        triggerSetting.showDebugLogs__c = true;
        triggerSetting.isActive__c = true;
        triggerSetting.Status__c = 'Paid';
        
        if( isDml )
            insert triggerSetting;
        
        return triggerSetting;
    }
    
    //-------------------------------------------------------------------Application Custom Setting -------------------------------------------------------------------------------------
    public static ApplicationTrigger_checkPrepaidBalence__c createCustomSettingApplicationPrepaidBaln( Boolean isDml ){
        
        ApplicationTrigger_checkPrepaidBalence__c triggerSetting = new ApplicationTrigger_checkPrepaidBalence__c();
        triggerSetting.Name = 'triggerSettings';
        triggerSetting.Application_Approval_Process_Name__c = 'OptInApplicationApprovalProcess';
        triggerSetting.Application_RecordType_Name_For_Approval__c = 'Application(Opt-In)';
        triggerSetting.Application_RecordType_Name_Non_Approval__c  = 'Application(Opt-Out/NIN/Maxway)';
        triggerSetting.Application_StageName__c = 'Accepted By Maxway';
        triggerSetting.Application_Tariff_Type__c =  'Application Creation';
        triggerSetting.Contract_Line_Item_Record_Name__c = 'Usage';
        triggerSetting.Contract_Status__c = 'Activated';
        triggerSetting.Error_Message_for_Insufficient_Amount__c = 'Insufficient Amount to create Application';
        triggerSetting.Error_Message_for_No_Contract__c = 'Please Create a Active Contract first before creating Application.';
        triggerSetting.isActive__c = true;
        triggerSetting.School_Tariff_Type__c = 'School Account Creation';
        triggerSetting.showDebugLogs__c = true;
        triggerSetting.Student_Tariff_Type__c = 'Student Account Creation';
        triggerSetting.System_Admin_Profile_Name__c = 'Maxway System Administrator';
        triggerSetting.Account_Student_Record_Type_Name__c = 'Student Account';
        triggerSetting.Staff_Name_For_Portal_User__c = 'HQ Admin';
        
        if( isDml )
            insert triggerSetting;
        
        return triggerSetting;
    }
    
    //-------------------------------------------------------------------  Account Custom Setting -------------------------------------------------------------------------------------
    
    public static AccountTrigger_checkPrepaidBalence__c createCustomSettingAccountPrepaidBaln( Boolean isDml ){
        AccountTrigger_checkPrepaidBalence__c triggerSetting = new AccountTrigger_checkPrepaidBalence__c();
        
        triggerSetting.Account_Approval_Process_Name__c = 'CommunityNINAccountApproval';
            triggerSetting.Account_Approval_Status__c = 'Approved';
            triggerSetting.Account_RecordType_Name_For_Approval__c = 'Overseas School - CC,Overseas School - HS,Overseas School - University';
            triggerSetting.Account_RecordType_Name_Non_Approval__c  = 'Student Account';
            triggerSetting.Application_Tariff_Type__c = 'Application Creation';
            triggerSetting.Contract_Line_Item_Record_Name__c = 'Usage';
            triggerSetting.Contract_Status__c  =  'Activated';
            triggerSetting.Error_Message_for_Insufficient_Amount__c = 'Insufficient Amount to create Account.';
            triggerSetting.Error_Message_for_No_Contract__c = 'Please Create a Active Contract first before creating Account.';
            triggerSetting.Name  = 'triggerSettings';
            triggerSetting.School_Tariff_Type__c = 'School Account Creation';
            triggerSetting.Student_Tariff_Type__c  = 'Student Account Creation';
            triggerSetting.System_Admin_Profile_Name__c = 'Maxway System Administrator';
            triggerSetting.isActive__c  =  True;
            triggerSetting.showDebugLogs__c  = True;
            
            if( isDml )
            insert triggerSetting;
        
        return triggerSetting;
    }
    
    
     
}