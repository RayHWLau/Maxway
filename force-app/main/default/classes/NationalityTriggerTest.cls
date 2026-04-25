@isTest
public class NationalityTriggerTest 
{

 public static testmethod void testAccount() 
	   {
           
 		Test.startTest();
			List<Account> listAcc = TestUtil.createAccount(ConstantsClass.osCCRecTypeName, false, 1);
        listAcc[0].Data_Origin__c  = 'H';
        
        insert listAcc;
        Commission_Table__c cm = new Commission_Table__c();
        cm.Nationality__c = 'Afghan, Afghanistan';
        cm.Amount__c = 123;
        cm.School__c = listAcc[0].Id;
        insert cm;
           delete cm;
            Test.stopTest();

       }

}