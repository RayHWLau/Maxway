global class SchedulerForAccountGrade implements Schedulable{
    global void execute(SchedulableContext sc) 
    { 

        String accquery = 'select Current_Academic_Year_Hidden__c,Current_Grade_Mapping__c,Start_of_Academic_Month__c from account where Current_Academic_Year_Hidden__c <: currentYear AND Start_of_Academic_Month__c=:months and createddate != :todays';

        BatchclassforgradeMapping batchApex2 = new BatchclassforgradeMapping(accquery);
        ID batchprocessid2 = Database.executeBatch(batchApex2, 1);

    }
}