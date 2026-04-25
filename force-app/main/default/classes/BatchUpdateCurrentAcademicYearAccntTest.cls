//added on 4 June 2020
@isTest
public class BatchUpdateCurrentAcademicYearAccntTest {

    
    @testSetup
    public static void dataFactory(){
        
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
        
        List<Account> listAcc = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, false, 1);
        listAcc[0].Data_Origin__c  = 'H';
        
        insert listAcc;
        
    }
    
    public  static testMethod void TestBatch(){
        
        List<Account> listAcc = [SELECT Id,CreatedDate,Current_Academic_Year_Hidden__c,Start_of_Academic_Month__c FROM Account];
        system.debug('listAcc ---> ' + listAcc );
        
        if( listAcc.size() > 0 ){
            
            listAcc[0].Start_of_Academic_Month__c = 'January';
            update listAcc;
            
            test.startTest();
            
            Database.executeBatch( new BatchUpdateCurrentAcademicYearAccnt(), 50 );
            test.stopTest();
            
        }
    }
}