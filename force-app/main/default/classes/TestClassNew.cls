@isTest
private class TestClassNew {

    
    private static testMethod void ScheduleRefreshGrade_test()
    {
    	Account a1 =TestDataFactory.getStudent();
    
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'test lead';
        l.Mobile__c= '12345657';
        l.Original_Academic_Yr__c = '2009';
        l.Original_Grade__c = 'F1';
        insert l;
        
        Lead l2 = new Lead();
        l2.LastName = 'test lead2';
        l2.Mobile__c= '12345337';
        l2.Original_Grade__c = 'F1';
        insert l2;
        
        Account a = new Account();        
        a.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
        a.FirstName='test firstname';        
        a.LastName='test lastname';
        a.PersonMobilePhone='222244444';
        a.Original_Academic_Yr__c = '2005';
        a.Original_Grade__c = 'F7';
        insert a;
        
        Account a2 = new Account();        
        a2.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
        a2.FirstName='test firstname';        
        a2.LastName='test lastname2';
        a2.PersonMobilePhone='22223333';
        a2.Original_Grade__c = 'F7';
        insert a2;
        
        // Schedule the test job
        String jobId = System.schedule('ScheduleProgressChecktest','0 0 0 3 9 ? 2022', new ScheduleRefreshGrade());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals('0 0 0 3 9 ? 2022', ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
    }
}