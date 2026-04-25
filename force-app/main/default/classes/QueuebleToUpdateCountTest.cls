@isTest
public class QueuebleToUpdateCountTest 
{
    @isTest
    public static void QueuebleToUpdateCountOfDeactivateUser()
    {
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            Account acc=new Account(Name='Example1');
        acc.RecordTypeId=RecordTypeIdAccount; 
            acc.ownerId = userinfo.getUserId();
        acc.BillingCity='allahabad';
        acc.BillingCountry='india';
            acc.Nationality__c='Cuban, Cuba';
        acc.BillingState='Uttar Pradesh';
        acc.BillingStreet='Naini';
        insert acc;
        Map<String, decimal> active = new Map<String, decimal>();
		active.put(acc.id, 34);
		active.put(acc.Id, 25);
        Map<String, integer> inactive = new Map<String, integer>();
		inactive.put(acc.id, 44);
		inactive.put(acc.Id, 34);
        QueuebleToUpdateCountOfDeactivateUser obj=new QueuebleToUpdateCountOfDeactivateUser(inactive,active);
        Test.startTest();
            System.enqueueJob(obj);
          Test.stopTest();
    }
    

}