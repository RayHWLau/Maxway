@isTest
private class TestTaskTriggerHandler {

    static testMethod void myUnitTest() {
        
       
        Opportunity opp=new Opportunity();
        opp.Name='Test';
        opp.StageName='Open';
        opp.CloseDate=system.today();
        insert opp;
        Task ot=new Task(whatId=opp.Id, 
           // WhoId=opp.Id,
            Subject='[sys] - test action', 
            status='Not Started', 
            Priority='Normal',
            ActivityDate = Date.today());
        insert ot;
         Case cs=new Case();
        Task t = new Task(
            whatId=cs.Id, 
            WhoId=cs.Id,
            Subject='[sys] - test action', 
            status='Not Started', 
            Priority='Normal',
            ActivityDate = Date.today()
        );
        insert t;        
    }
}