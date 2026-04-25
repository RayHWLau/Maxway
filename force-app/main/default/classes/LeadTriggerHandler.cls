public without sharing class LeadTriggerHandler implements Triggers.Handler{
    public void handle() {
        if(Trigger.isBefore) {
            if(Trigger.isUpdate) {
            	Map<Id, Id> leadMap = new Map<Id, Id>();
            	List<Account> accs = new List<Account>();
            	
            	List<Opportunity> opps = new List<Opportunity>();
            	for(Lead lead: (List<Lead>)Trigger.new) {
            		system.debug('### lead.IsConverted ' + lead.IsConverted);
            		system.debug('### lead.ConvertedAccountId ' + lead.ConvertedAccountId);            		
            		system.debug('### lead.convertedOpportunityId ' + lead.convertedOpportunityId);
            		if(lead.IsConverted && !((Lead)trigger.oldmap.get(lead.Id)).IsConverted){
            			if(lead.ConvertedAccountId != null) {
            				leadMap.put(lead.Id, lead.ConvertedAccountId);
            				Account a = new Account(Id=lead.ConvertedAccountId, Account_Manager__c=lead.Case_Manager__c, Original_Grade_Mapping__c=lead.Original_Grade_Mapping__c , Current_Grade_Mapping__c=lead.Current_Grade_Mapping__c);
            				accs.add(a);
            			}
            			if(lead.convertedOpportunityId != null) {
            				Opportunity opp = new Opportunity(Id=lead.convertedOpportunityId, Case_Manager__c=lead.Case_Manager__c);
            				opps.add(opp);
            			}
            		}
            	}
            	system.debug('### leadMap ' + leadMap);
            	List<Sibling__c> siblings = [
            		Select Id, 
            		Principal_Student_Lead__c, Sibling_Student_Lead__c,
            		Principal_Student__c, Sibling_Student__c
            		From Sibling__c
            		Where (Principal_Student_Lead__c IN :leadMap.keySet()
            		OR Sibling_Student_Lead__c IN:leadMap.keySet())
            		And Principal_Student_Lead__r.IsConverted = false
            		And Sibling_Student_Lead__r.IsConverted = false
            	];
            	system.debug('### before siblings ' + siblings);
            	for(Sibling__c s: siblings) {
            		Boolean bSkip = false;
            		//Record sit in Principal Lead
            		if(s.Principal_Student_Lead__c != null) {	
            			if(leadMap.containsKey(s.Principal_Student_Lead__c)) {    
            				system.debug('### cp1 ');        			
        					//Lead & Lead
            				if(s.Sibling_Student_Lead__c != null) {
            					system.debug('### cp1.1 '); 
		            			s.Principal_Student__c = leadMap.get(s.Principal_Student_Lead__c);
		            			s.Principal_Student_Lead__c = s.Sibling_Student_Lead__c;
		            			s.Sibling_Student_Lead__c = null;
		            			bSkip = true;
            				//Lead & Account
            				} else if(s.Principal_Student__c != null){
            					system.debug('### cp1.2 '); 
            					s.Sibling_Student__c = leadMap.get(s.Principal_Student_Lead__c);
            					s.Principal_Student_Lead__c = null;
            					bSkip = true;
            				}	
            			}
            		//Record sit in Secondary Lead            		
            		}
            		if(!bSkip && s.Sibling_Student_Lead__c != null) {
            			if(leadMap.containsKey(s.Sibling_Student_Lead__c)) {     
            				system.debug('### cp2 ');         			
	        				//Lead & Lead
	            			if(s.Principal_Student_Lead__c != null) {	 
	            				system.debug('### cp2.1 ');             				
		            			s.Principal_Student__c = leadMap.get(s.Sibling_Student_Lead__c);
		            			s.Sibling_Student_Lead__c = null;	            				
	            			//Lead & Account
	            			} else if(s.Principal_Student__c != null){
            					system.debug('### cp2.2 ');        
            					s.Sibling_Student__c = leadMap.get(s.Sibling_Student_Lead__c);
            					s.Sibling_Student_Lead__c = null;
	            			}	  
            			}          		
            		}
            	}
            	system.debug('### after siblings ' + siblings);
            	if(!siblings.isEmpty()) {
            		update siblings;
            	}
            	if(!accs.isEmpty()){
            		update accs;
            	}
            	if(!opps.isEmpty()){
            		update opps;
            	}
            }
        } else if(Trigger.isAfter){
        	Map<Id, Id> accleadMgr = new Map<Id, Id>();
        	Map<Id, Id> con2Acc = new Map<Id, Id>();
        	Map<Id, Id> lead2Opp = new Map<Id, Id>();
        	for(Lead lead: (List<Lead>)Trigger.new) {
	        	if(lead.IsConverted && !((Lead)trigger.oldmap.get(lead.Id)).IsConverted){
	    			if(lead.ConvertedAccountId != null) {
	    				accleadMgr.put(lead.ConvertedAccountId, lead.Case_Manager__c);
	    			}
	    			if(lead.convertedOpportunityId != null) {
	    				lead2Opp.put(lead.Id, lead.convertedOpportunityId);
	    			}
	    		}
        	}
    		for(Contact c: [Select Id, AccountId From Contact Where AccountId IN :accleadMgr.keySet()]) {
    			con2Acc.put(c.Id, c.AccountId);
    		}
    		List<Task> tasks = [Select Id, WhoId, Subject, Task_Owner__c From Task 
    			Where whoId IN: con2Acc.keySet() And Task_Owner__c = null];
    		for(Task t:tasks) {
    			if(con2Acc.containsKey(t.whoId)) {
    				if(accleadMgr.containsKey(con2Acc.get(t.whoId))) {    					
    					t.Task_Owner__c = accleadMgr.get(con2Acc.get(t.whoId));
    				}
    			}
    		}
        	system.debug('### after accleadMgr ' + accleadMgr);
        	system.debug('### after con2Acc ' + con2Acc);
        	system.debug('### after lead tasks ' + tasks);
        	update tasks;
        	
        	//
        	List<Recommended_Schools__c> rs = [
			Select Id, Name, Lead__c, Opportunity__c 
			From Recommended_Schools__c Where Lead__c In: lead2Opp.keyset()];
			system.debug('@@@ 1 rs size ' + rs.size());
			system.debug('@@@ 1 rs ' + rs);
			for(Recommended_Schools__c r: rs) {
				if(lead2Opp.containsKey(r.Lead__c)) {
					r.Opportunity__c = lead2Opp.get(r.Lead__c);
					r.Lead__c = null;
				}
			}
			update rs;
			system.debug('@@@ 2 rs size ' + rs.size());
			system.debug('@@@ 2 rs ' + rs);
			
			List<Nominated_school_new__c> ns = [
			Select Id, Name, Lead__c, Opportunity__c 
			From Nominated_school_new__c Where Lead__c In: lead2Opp.keyset()];
			system.debug('@@@ 1 ns size ' + ns.size());
			system.debug('@@@ 1 ns ' + ns);
			for(Nominated_school_new__c n: ns) {
				if(lead2Opp.containsKey(n.Lead__c)) {
					n.Opportunity__c = lead2Opp.get(n.Lead__c);
					n.Lead__c = null;
				}
			}
			update ns;
			system.debug('@@@ 2 ns size ' + ns.size());
			system.debug('@@@ 2 ns ' + ns);
        	
        }
    }
}