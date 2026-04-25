global class SchdulerToDeactivateUsers  implements Schedulable{
    
    global void execute(SchedulableContext sc) 
    { 
        ID jobID2= System.enqueueJob(new QueuebleToUpdateDectivateUser());
        system.debug('jobID2-->'+jobID2); 
    }
}