@isTest
public class SchedulerForAccountGradeTest {
   
    public static testMethod void testMethod1(){
        
        String CRON_EXP = '0 0 23 * * ?'; 
         	
        Test.startTest();
        
            System.schedule('SchedulerForAccountGradeTest',  CRON_EXP, new SchedulerForAccountGrade());
        
        Test.stopTest();
    }
}