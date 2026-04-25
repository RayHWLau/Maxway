global class SchedulerToCreateOppRenewal implements Schedulable{
    global void execute(SchedulableContext sc){
        Id recordTypeIdagent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string Activated = 'Activated';
        date add90days = system.today().adddays(90);
        String contractquery ='select id,recordtypeid ,account.id,account.Account_Manager__c from contract where recordtypeid = :recordTypeIdagent  and status = :Activated  and  enddate = :add90days';
        BatchClassContract batchApex1 = new BatchClassContract(contractquery);
        ID batchprocessid1 = Database.executeBatch(batchApex1, 1); 
        
    }
    
}