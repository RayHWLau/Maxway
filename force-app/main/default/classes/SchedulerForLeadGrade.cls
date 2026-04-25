global class SchedulerForLeadGrade implements Schedulable{
    
    global void execute(SchedulableContext sc) 
    { 
        String leadquery = 'select Current_Academic_Year_Hidden__c,Current_Grade_Mapping__c,Start_of_Academic_Month__c from lead where Current_Academic_Year_Hidden__c <: currentYear AND Start_of_Academic_Month__c=:months and createddate != :todays';

        BatchclassforgradeMapping batchApex1 = new BatchclassforgradeMapping(leadquery);
        ID batchprocessid1 = Database.executeBatch(batchApex1, 1);

    }
}