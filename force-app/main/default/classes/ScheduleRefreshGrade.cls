global class ScheduleRefreshGrade implements Schedulable{
    global void execute(SchedulableContext sc) 
    { 
        String leadquery = 'select id, Current_Grade_Mapping__c from Lead where Current_Grade_Mapping__c != null And IsConverted = false and IsDeleted = false ';
        // 2013-Sep-3 : Commented the accquery because Expected_Graduation_Date__c is removed
        //String accquery = 'select id,Expected_Graduation_Date__c,Student_Status__c from Account where IsPersonAccount = true and IsDeleted = false';
        String accquery = 'select id, Current_Grade_Mapping__c, Student_Status__c from Account where Current_Grade_Mapping__c != null and IsPersonAccount = true and IsDeleted = false';
        
        MassUpdateRecords batchApex1 = new MassUpdateRecords(leadquery);
        ID batchprocessid1 = Database.executeBatch(batchApex1, 1);
        MassUpdateRecords batchApex2 = new MassUpdateRecords(accquery);
        ID batchprocessid2 = Database.executeBatch(batchApex2, 1);
    /*
        list<Lead> ll = [select id from Lead where IsConverted = false];
        if(ll.size()>0)
             update ll;
        list<Account> lacc = [select id,Expected_Graduation_Date__c,Student_Status__c from Account where IsPersonAccount = true];
        for(Account acc:lacc)
            if((acc.Expected_Graduation_Date__c<=system.today())&&acc.Student_Status__c=='Arrived')
                acc.Student_Status__c = 'Idle';
        if(lacc.size()>0)
            update lacc;
    */
    }
    /*private static testMethod void ScheduleRefreshGrade_test()
    {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'test lead';
        l.Mobile__c= '12345657';
        l.Original_Academic_Yr__c = '2009';
        l.Original_Grade__c = 'F1';
        insert l;
        
        Lead l2 = new Lead();
        l2.LastName = 'test lead2';
        l2.Mobile__c= '12345333';
        l2.Original_Grade__c = 'F1';
        insert l2;
        
        Account a = new Account();        
        a.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
        a.FirstName='test firstname';        
        a.LastName='test lastname';
        a.PersonMobilePhone='22222222';
        a.Original_Academic_Yr__c = '2005';
        a.Original_Grade__c = 'F7';
        a.Student_ID__c='H2020-05-00133';
        insert a;
            Try{
                Account a2 = new Account();        
                a2.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
                a2.FirstName='test firstname';        
                a2.LastName='test lastname2';
                a2.PersonMobilePhone='22223332';
                a2.Original_Grade__c = 'F7';
                a2.Student_ID__c='Test';
                insert a2;
}Catch(Exception ex){

}
        
        
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
    }*/
}