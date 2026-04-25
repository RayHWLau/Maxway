@isTest
private class TestOpportunityTriggerHandler {
    private static testMethod void test1() {
        Account a1 = TestDataFactory.getStudent();
        Program__c p1 = TestDataFactory.getProgram();
        Commission__c c1 = TestDataFactory.getCommission();
        c1.Program__c = p1.Id;
        update c1;
        Opportunity o1 = new Opportunity();
        o1.Name = 'Test Opp 1';
        o1.AccountId = a1.Id;
        o1.StageName= 'Prospective';
        o1.CloseDate=date.today();
        o1.Num_of_Year_to_Graduation__c =1;
        insert o1;

        TestDataFactory.getCommConfig();

        IncNumber__c i = new IncNumber__c();
        i.name='Service Payment ID';
        i.Last_Increment__c = date.today();
        i.Current_Number__c = 1;
        i.Reset__c= 'Monthly';
        insert i;
        Payment_Record__c p = new Payment_Record__c();
        p.Opportunity__c = o1.Id;
        p.Payment_No__c='1';
        p.Payment_Method__c='Cash';
        p.Invoice_Creation_Date__c=date.today();
        p.Invoice_Due_Date__c=date.today();
        p.Invoice_Issue_Date__c=date.today();
        p.Payment_Pay_in_Date__c=date.today();
        p.Invoice_Amt__c = 10000;
        insert p;

        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Case']; 
        Map<String,String> appRecordTypes = new Map<String,String>{};
        for(RecordType rt: rtypes) {
            appRecordTypes.put(rt.Name,rt.Id);
        }
         ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        Case c = new Case();        
        //c.RecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Uni Program').getRecordTypeId();
        c.Opportunity__c = o1.Id;
        c.Program__c = p1.Id;
        c.Billing_Year__c=2;
        c.Status= 'In Progress';
        c.Term__c='Fall';
        c.Year__c='2016';
        insert c;
        c.Status= 'Completed';
        update c;
        Test.startTest();
        o1.StageName= 'Placed';
        o1.Expected_Graduation_Date__c=date.today();
        //update o1;
        o1.StageName= 'Arrived';
        //update o1;
        Test.stopTest();
    }
}