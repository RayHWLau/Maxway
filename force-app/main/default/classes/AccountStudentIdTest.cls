@isTest(SeeAllData=true)
public class AccountStudentIdTest {
    
    Public static testmethod void mytest(){
        Account a = [SELECT Id, Data_Origin__c, Student_S_agent_Code__c, Student_Id__c, Original_Academic_Yr__c, RecordTypeId FROM Account WHERE RecordType.Name = 'Student Account' ORDER BY CreatedDate DESC LIMIT 1];
        a.Student_Id__c = null;
        update a;
        
    }
    
    public static testmethod void mytest2()  {
		Account a = [SELECT Id, Data_Origin__c, Student_S_agent_Code__c, Student_Id__c, Original_Academic_Yr__c, RecordTypeId FROM Account WHERE RecordType.Name = 'Student Account' ORDER BY CreatedDate DESC LIMIT 1];
        a.Student_Id__c = null;
        a.Original_Academic_Yr__c = null;
        update a;        
    }
    
    public static testmethod void mytest3()  {
		Account a = [SELECT Id, Data_Origin__c, Student_S_agent_Code__c, Student_Id__c, Original_Academic_Yr__c, RecordTypeId FROM Account WHERE RecordType.Name = 'Student Account' ORDER BY CreatedDate DESC LIMIT 1];
        a.Id = null;
        a.Student_Id__c = null;
        a.Original_Academic_Yr__c = null;
        
        Account b = a;
        b.LastName = 'UnitTest09';
        b.FirstName = 'unitTest0909';
        b.PersonEmail = 'abc@exampleunittestmax.com';
        insert b;        
    }

}