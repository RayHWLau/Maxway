@isTest
public class SchedulerForLeadGradeTest {
   
    public static testMethod void testMethod1(){
        
        String CRON_EXP = '0 0 23 * * ?'; 
         	
        Test.startTest();
        
            System.schedule('SchedulerForLeadGradeTest',  CRON_EXP, new SchedulerForLeadGrade());
        
        Test.stopTest();
    }
}