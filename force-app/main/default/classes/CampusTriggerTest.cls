@isTest
public class CampusTriggerTest {

    public static TestMethod void invokeCampus(){
        List<Program__c> prgrmLis = new List<Program__c>();
        List< Account > lisacc = TestUtil.createAccount('Overseas School - HS', true, 1);
            //lisacc[0].ownerId = systemAdminUser.id;
            //lisacc[0].Account_Manager__c = ListStaff[0].Id;
            /*lisacc[0].Total_Admin_License__c = 10;
            lisacc[0].Total_User_License__c = 10;
            insert lisacc;*/
        List<Campus__c> cmpsLis = new List<Campus__c>();
        string s = Schema.SObjectType.Campus__c.getRecordTypeInfosByName().get('High School - Campus').getRecordTypeId();
        string p=Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('High School Program').getRecordTypeId();
        Campus__c cms = new Campus__c();
        cms.RecordTypeId = s;
        cms.Homestay_Grade__c = '10;12';
        // cms.Boarding_Grades__c = '10;11';
        cms.Country_New__c = 'Canada';
        cms.Student_taking_IB__c = 10;
        cms.Account__c=lisacc[0].Id;
        // cms.Housing_Option__c='Homestay';
        //cms.Province_State_New__c = 'Ontario';
        //cms.Nearest_Big_City_New__c = 'Toronto';
        cms.CurrencyIsoCode='CAD';
        cmpsLis.add(cms);
            insert cmpsLis;
        Program__c pgm = new Program__c();
        pgm.RecordTypeId = p;
        pgm.Program_Type__c = 'Bachelor';
        pgm.Est_Annual_Cost__c = 2000;
        pgm.Campus__c = cmpsLis[0].Id;
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
        insert prgrmLis;
        cmpsLis[0].Student_taking_IB__c=9;
        update cmpsLis;
         /*pgm.Program_Type__c = 'Bachelor';
                    pgm.Est_Annual_Cost__c = 2000;
                    pgm.Campus__c = cmpsLis.Id;
                    pgm.ESL_Housing__c = 2200;
                    pgm.CurrencyIsoCode = 'CAD';
                    pgm.Bachelor_Needed__c = 'Not Applicable'; 
                    pgm.IELTS_Min__c = '2.0';
                    pgm.TOEFL_Min__c = 10;   
                    pgm.TOEFL_accepted_for_update_ESL_EAP__c = 'Yes';
                    pgm.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c = 9;
                    pgm.High_School_Graduation_Needed__c = 'Yes';
                    Pgm.Admission_Grade__c='10';
                    prgrmLis.add(pgm);*/
        // List<Campus__c> listcmp=TestUtil.createCampus('High_School_Campus', true, 1);
    } 
}