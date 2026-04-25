@isTest
public class ProgramTriggerHelperTest {
   
    @isTest
    public static void test()
    {
        list<Program__c> listpgm=new List<Program__c>();
        List<Program__c> lisCon = TestUtil.createProgram(ConstantsClass.programUniRecTypeName, false, 5);
         insert lisCon;   
        listpgm.add(lisCon[0]);
       // ProgramTriggerHelper.ValidateCurrency(lisCon);
     TestUtil.createCustomSettingInvoiceRollUp(true);
        Test.startTest();
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
        
        listpgm.add(pgm);
                Campus__c cms1=new Campus__c();
         cms1.Account__c = lisAcc[0].id;
                    cms1.Homestay_Grade__c = 'K1';
                    cms1.Country_New__c = 'New Zealand';
                    cms1.Student_taking_IB__c = 10;
                    cms1.Housing_Option__c='Homestay';
                    cms1.Province_State_New__c = 'Canterbury';
                    cms1.Nearest_Big_City_New__c = 'Christchurch';
                    cms1.CurrencyIsoCode='NZD';
        insert cms1;
        Program__c pgm1=new Program__c();
        pgm1.Program_Type__c = 'Bachelor';
                    pgm1.Est_Annual_Cost__c = 2000;
                    pgm1.Campus__c = cms1.id;
                    pgm1.ESL_Housing__c = 2200;
                    pgm1.CurrencyIsoCode = 'NZD';
                    pgm1.Bachelor_Needed__c = 'Not Applicable'; 
                    pgm1.IELTS_Min__c = '2.0';
                   pgm1.TOEFL_Min__c = 10;   
                    pgm1.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
                    pgm1.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
                    pgm1.High_School_Graduation_Needed__c = 'Yes';
                    pgm1.Admission_Grade__c='K1';
                  insert pgm1;
        
        listpgm.add(pgm1);
        ProgramTriggerHelper.ValidateCurrency(listpgm);
        Test.stopTest();
        
       
       
    }
   @isTest
    public static void test1()
    {
        TestUtil.createCustomSettingInvoiceRollUp(true);
         list<Program__c> listpgm=new List<Program__c>();
         list<Account> lisAcc = TestUtil.createAccount(ConstantsClass.osHSRecTypeName, true, 1);
        lisAcc[0].CurrencyIsoCode='USD';
        update lisAcc;
         /*For 'United Kingdom' data*/
         Campus__c cms2=new Campus__c();
         cms2.Account__c = lisAcc[0].id;
                    cms2.Homestay_Grade__c = 'K1';
                    cms2.Country_New__c = 'United Kingdom';
                    cms2.Student_taking_IB__c = 10;
                    cms2.Housing_Option__c='Homestay';
                    cms2.Province_State_New__c ='England';
                    cms2.Nearest_Big_City_New__c ='Bournemouth';
                    cms2.CurrencyIsoCode='GBP';
        insert cms2;
        Program__c pgm2=new Program__c();
        pgm2.Program_Type__c = 'Bachelor';
                    pgm2.Est_Annual_Cost__c = 2000;
                    pgm2.Campus__c = cms2.id;
                   pgm2.ESL_Housing__c = 2200;
                    pgm2.CurrencyIsoCode = 'GBP';
                    pgm2.Bachelor_Needed__c = 'Not Applicable'; 
                   pgm2.IELTS_Min__c = '2.0';
                   pgm2.TOEFL_Min__c = 10;   
                    pgm2.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
                    pgm2.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
                    pgm2.High_School_Graduation_Needed__c = 'Yes';
                    pgm2.Admission_Grade__c='K1';
                  insert pgm2;
        
        listpgm.add(pgm2);
        /*For Australia data*/
         Campus__c cms3=new Campus__c();
         cms3.Account__c = lisAcc[0].id;
                    cms3.Homestay_Grade__c = 'K1';
                    cms3.Country_New__c = 'Australia';
                    cms3.Student_taking_IB__c = 10;
                    cms3.Housing_Option__c='Homestay';
                    cms3.Province_State_New__c = 'Australian Capital Territory';
                    cms3.Nearest_Big_City_New__c = 'Canberra';
                    cms3.CurrencyIsoCode='AUD';
        insert cms3;
        Program__c pgm3=new Program__c();
        pgm3.Program_Type__c = 'Bachelor';
                    pgm3.Est_Annual_Cost__c = 2000;
                    pgm3.Campus__c = cms3.id;
                   pgm3.ESL_Housing__c = 2200;
                    pgm3.CurrencyIsoCode = 'AUD';
                    pgm3.Bachelor_Needed__c = 'Not Applicable'; 
                   pgm3.IELTS_Min__c = '2.0';
                   pgm3.TOEFL_Min__c = 10;   
                    pgm3.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
                    pgm3.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
                    pgm3.High_School_Graduation_Needed__c = 'Yes';
                    pgm3.Admission_Grade__c='K1';
                  insert pgm3;
        
        listpgm.add(pgm3);
        ProgramTriggerHelper.ValidateCurrency(listpgm);
        
        pgm3.CurrencyIsoCode = 'HKD';
        ProgramTriggerHelper.ValidateCurrency( new List< program__c > { pgm3 } );
        
        pgm3.CurrencyIsoCode = 'CNY';
        ProgramTriggerHelper.ValidateCurrency( new List< program__c > { pgm3 } );
        pgm3.CurrencyIsoCode = 'CAD';
        ProgramTriggerHelper.ValidateCurrency( new List< program__c > { pgm3 } );
        

        
    }
    
   
    
    
    


}