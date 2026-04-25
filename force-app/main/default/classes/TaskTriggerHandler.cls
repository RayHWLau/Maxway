public without sharing class TaskTriggerHandler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore) {
            //if(Trigger.isInsert) {
                Schema.DescribeSObjectResult dsr = Case.SObjectType.getDescribe();
                String casePrefix = dsr.getKeyPrefix();
                Schema.DescribeSObjectResult dsr1 = Account.SObjectType.getDescribe();
                String accPrefix = dsr1.getKeyPrefix();
                Schema.DescribeSObjectResult dsr2 = Opportunity.SObjectType.getDescribe();
                String oppPrefix = dsr2.getKeyPrefix();
                Schema.DescribeSObjectResult dsr3 = Lead.SObjectType.getDescribe();
                String leadPrefix = dsr3.getKeyPrefix();
                Schema.DescribeSObjectResult dsr4 = Payment_Record__c.SObjectType.getDescribe();
                String servicefeePrefix = dsr4.getKeyPrefix();
                //system.debug('### t.casePrefix ' + casePrefix);
                Set<Id> caseIds = new Set<Id>();
                Set<Id> accIds = new Set<Id>();
                Set<Id> oppIds = new Set<Id>();
                Set<Id> leadIds = new Set<Id>();
                Set<Id> feesIds = new Set<Id>();
                for(Task t:(List<Task>)Trigger.new) {
                    if(t.subject != null && t.Task_Owner__c ==null) {
                        if(t.subject.contains('[sys]')) {
                            system.debug('whatId==========>>>>>'+t.whatId);
                        	if(t.whatId != null) {
		                    	if(((String)t.whatId).substring(0,3) == casePrefix) {
		                            caseIds.add(t.whatId);                  
		                        } else if(((String)t.whatId).substring(0,3) == accPrefix) {
		                            accIds.add(t.whatId);                  
		                        } else if(((String)t.whatId).substring(0,3) == oppPrefix) {
		                            oppIds.add(t.whatId);                  
		                        } else if(((String)t.whatId).substring(0,3) == servicefeePrefix) {
		                            feesIds.add(t.whatId);                  
		                        }
                        	} else if(t.whoId != null) {
	                        	if(((String)t.whoId).substring(0,3) == leadPrefix) {
		                            leadIds.add(t.whoId);
		                        }
                        	}
                        }
                    }
                }
                
                Map<Id, Case> caseMap = new Map<Id, Case>([
                	Select Id, Application_Manager__c ,
                	Opportunity__r.Account.PersonContactId,
                	School__c, School__r.Account_Manager__c
                	From Case Where Id In:caseIds]);
                Map<Id, Account> accMap = new Map<Id, Account>([
                	Select Id, Account_Manager__c,
                	PersonContactId
                	From Account Where Id In:accIds]);
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
                	Select Id, Case_Manager__c,
                	Account.PersonContactId
                	From Opportunity Where Id In:oppIds]);
                Map<Id, Lead> leadMap = new Map<Id, Lead>([
                	Select Id, Case_Manager__c
                	From Lead Where Id In:leadIds]);
                Map<Id, Payment_Record__c> feesMap = new Map<Id, Payment_Record__c>([
                	Select Id, Opportunity__r.Case_Manager__c, Opportunity__r.Account.PersonContactId
                	From Payment_Record__c Where Id In:feesIds]);
                                 
                //Update WhoId for all on-boarding tasks
                for(Task t:(List<Task>)Trigger.new) {
                    if(t.subject != null) {
                    	if(t.subject.contains('[sys]')) {
	                        if(t.whatId != null) {
		                        if(caseIds.contains(t.whatId)) {
		                            if(caseMap.containsKey(t.whatId)) {		
		                            	system.debug('@@@@@@@@@@ caseMap ' + caseMap);
		                            	system.debug('@@@@@@@@@@ t.whatId ' + t.whatId);                                
		                                if(t.subject.contains('[sys] Check school contract validity')) {
		                                	//system.debug('@@@@@@@@@@ caseMap.get(t.whatId).School__c ' + caseMap.get(t.whatId).School__c);
		                                	//system.debug('@@@@@@@@@@ t.Task_Owner__c ' + t.Task_Owner__c);
		                                	//system.debug('@@@@@@@@@@ caseMap.get(t.whatId).School__r.Account_Manager__c ' + caseMap.get(t.whatId).School__r.Account_Manager__c);
		                                	t.Task_Owner__c = caseMap.get(t.whatId).School__r.Account_Manager__c;
		                                	t.whatId = caseMap.get(t.whatId).School__c;
		                                } else {
		                                	t.WhoId = caseMap.get(t.whatId).Opportunity__r.Account.PersonContactId;
		                                	t.Task_Owner__c = caseMap.get(t.whatId).Application_Manager__c;
		                                }
		                            }
		                        } else if(accIds.contains(t.whatId)) {
		                            if(accMap.containsKey(t.whatId)) {
		                                t.Task_Owner__c = accMap.get(t.whatId).Account_Manager__c;
		                                t.WhoId = accMap.get(t.whatId).PersonContactId;
		                            }
		                        } if(oppIds.contains(t.whatId)) {
		                            if(oppMap.containsKey(t.whatId)) {
		                                t.Task_Owner__c = oppMap.get(t.whatId).Case_Manager__c;
		                                t.WhoId = oppMap.get(t.whatId).Account.PersonContactId;
		                            }
		                        } if(feesIds.contains(t.whatId)) {
		                            if(feesMap.containsKey(t.whatId)) {
		                                t.Task_Owner__c = feesMap.get(t.whatId).Opportunity__r.Case_Manager__c;
		                                t.WhoId = feesMap.get(t.whatId).Opportunity__r.Account.PersonContactId;
		                            }
		                        }
	                        } else if(t.whoId != null) {	                        	
		                        if(leadIds.contains(t.whoId)) {
		                            if(leadMap.containsKey(t.whoId)) {
		                                t.Task_Owner__c = leadMap.get(t.whoId).Case_Manager__c;	                                
		                            }
		                        } 
	                        }
                    	}
                    }
                }                
                system.debug('### Trigger.new ' + Trigger.new);
            //}
        }
    }
}