global class ScheduleContractexpiredupdate implements Schedulable{
    global void execute(SchedulableContext sc){
        id recordTypeIdmarketing = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Marketing Contract').getRecordTypeId();
      
        string ContractActivated = 'Contract Activated';
        date todaydate = system.today();
        date thritydaysbeforeexpiredate = system.today().adddays(30);
        String contractquery ='select id,recordtypeid,OwnerId,account.name,account.Account_Manager__c,enddate from contract where recordtypeid= :recordTypeIdmarketing and status = :ContractActivated and (enddate = :todaydate or enddate = :thritydaysbeforeexpiredate)';
        BatchClassContract batchApex1 = new BatchClassContract(contractquery);
        ID batchprocessid1 = Database.executeBatch(batchApex1, 1);  
    }
    
}