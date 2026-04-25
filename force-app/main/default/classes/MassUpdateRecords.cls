global class MassUpdateRecords implements  Database.Batchable<sObject> {

    global final string query;
    
    global MassUpdateRecords (String q)
    {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
    	//List<Sobject> scope = [select id, Original_Grade_Mapping__c, Current_Grade_Mapping__c from Lead where id='00Qp0000001Kd12'];
		Map<Id, Id> gradeMap = new Map<Id, Id>();
    	for(Grade_Mapping__c g:[Select Id, Next_Year_Grade__c From Grade_Mapping__c]){
    		gradeMap.put(g.Id, g.Next_Year_Grade__c);
    	}
    	system.debug('###before lead ' + scope);
    	for(Sobject s : scope){
    		if(gradeMap.containsKey((Id)s.get('Current_Grade_Mapping__c'))) {
    			s.put('Current_Grade_Mapping__c',gradeMap.get((Id)s.get('Current_Grade_Mapping__c')));
    		}
      	}
      	system.debug('###after lead ' + scope);
		update scope;
    }
    
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job  
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.  
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,
        TotalJobItems, CreatedBy.Email
        from AsyncApexJob where Id =:BC.getJobId()];
        
        // Send an email to the Apex job's submitter notifying of job completion.  
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        
        //Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}