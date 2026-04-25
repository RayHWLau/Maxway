@isTest
public class SchedulerToDeletedocsTest {
   
    public static testMethod void testMethod1(){
        
        String CRON_EXP = '0 0 23 * * ?'; 
         	
        Test.startTest();
        
            System.schedule('SchedulerToDeletedocsTest',  CRON_EXP, new SchedulerToDeletedocs());
        
        Test.stopTest();
    }
}