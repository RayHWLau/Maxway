global class SchedulerToDeletedocs implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchClassToDeleteAgentDocs batchApex1 = new BatchClassToDeleteAgentDocs();
        ID batchprocessid1 = Database.executeBatch(batchApex1,100); 
        
    }
    
}