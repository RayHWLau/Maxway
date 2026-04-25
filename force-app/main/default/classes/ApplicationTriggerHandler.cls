public with sharing class ApplicationTriggerHandler implements Triggers.Handler{
    public void handle() {
		if(Trigger.isBefore) {
			if(Trigger.isInsert || Trigger.isUpdate) {
				//if(Trigger.isInsert) {
					set<Id> oppIds = new set<Id>();
					for (Case c : (List<Case>) trigger.new) {
						if(c.Opportunity__c !=null) {
							oppIds.add(c.Opportunity__c);
						}
					}
					List<Opportunity> opps = [Select Id, AccountId From Opportunity Where Id IN:oppIds];
					Map<Id, Id> studId = new Map<Id,Id>();
					for(Opportunity o : opps) {
						studId.put(o.Id, o.AccountId);
					}
					for (Case c : (List<Case>) trigger.new) {
						if(c.Student__c == null) {
							if(c.Opportunity__c !=null && studId.containsKey(c.Opportunity__c)) {
								c.Student__c = studId.get(c.Opportunity__c);
							}
						}
					}
				//}
				List<RecordType> rtypes = [Select Name, Id,DeveloperName From RecordType where sObjectType='Case']; 
                 
                //added on 16 April 2020
                set< Id > recTypeIdForSkipValdiation = new set< Id >();
			    
                Map<String,String> appRecordTypes = new Map<String,String>{};
			    for(RecordType rt: rtypes) {
			        appRecordTypes.put(rt.Name,rt.Id);
			    
                     //added on 16 April 2020
                    if( rt.DeveloperName != 'Application_Opt_In' && rt.DeveloperName != 'Application_Opt_Out_NIN_Maxway' ){
                        recTypeIdForSkipValdiation.add( rt.Id );
                    }
                }
				Set<Id> updateProgIds = new Set<Id>();
				for (Case c : (List<Case>) trigger.new) {
					if(c.Program__c !=null) {
						updateProgIds.add(c.Program__c);
					}
				}
				Map<Id, Program__c> progMap = new Map<Id, Program__c>();
				for(Program__c p: [Select Id, 
					Campus__c,
					Campus__r.Account__c,
					Campus__r.Account__r.ParentId,
					RecordType.Name
					From Program__c
					Where Id In:updateProgIds]) {
					progMap.put(p.Id, p);
				}

				for (Case c : (List<Case>) trigger.new) {
					System.debug('***progMap ' + progMap + '');
					System.debug('***c.Program__c: ' + c.Program__c + '');
					System.debug('*** 1 c.RecordTypeId: ' + c.RecordTypeId + '');
					System.debug('*** 2 : ' + appRecordTypes.get('University Program Application') + '');
                    
                    //added on 16 April 2020
                   if( recTypeIdForSkipValdiation.contains( c.RecordTypeId ) ) continue;
					
					if(c.Program__c !=null) {
						if(progMap.containsKey(c.Program__c)) {	
							System.debug('*** 3 c.Program__c Name: ' + progMap.get(c.Program__c).RecordType.Name + '');
							System.debug('*** 3 c.Program__c: ' + progMap.get(c.Program__c) + '');					
							if(((c.RecordTypeId==appRecordTypes.get('CC Program Application')) && (progMap.get(c.Program__c).RecordType.Name!='CC Program'))
			                ||((c.RecordTypeId==appRecordTypes.get('ESL Program Application')) && (progMap.get(c.Program__c).RecordType.Name!='ESL Program'))
			                ||((c.RecordTypeId==appRecordTypes.get('HS Program Application')) && (progMap.get(c.Program__c).RecordType.Name!='High School Program'))
			                ||((c.RecordTypeId==appRecordTypes.get('University Program Application')) && (progMap.get(c.Program__c).RecordType.Name!='Uni Program'))) {    
			                    c.addError('Selected school type does not match the application type!');
			                } else {
								c.Campus__c = progMap.get(c.Program__c).Campus__c;
								c.School__c = progMap.get(c.Program__c).Campus__r.Account__c;								
								c.School_Parent_Id__c = progMap.get(c.Program__c).Campus__r.Account__r.ParentId;
			                }
						}
					}
				}
			}
		} else if (Trigger.isAfter) {
			if(Trigger.isInsert) {
				Set<Id> accIds = new Set<Id>();
				Set<Id> appIds = new Set<Id>();
				Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Case.getRecordTypeInfosByName();
				for (Case c : (List<Case>) trigger.new) {
					System.debug('*** c.RecordTypeId: ' + c.RecordTypeId + '');
					System.debug('*** get : ' + rtMapByName.get('HS Program Application').getRecordTypeId() + '');
					if( c.RecordTypeId == rtMapByName.get('CC Program Application').getRecordTypeId() ||
						c.RecordTypeId == rtMapByName.get('ESL Program Application').getRecordTypeId() ||
						c.RecordTypeId == rtMapByName.get('HS Program Application').getRecordTypeId() ||
						c.RecordTypeId == rtMapByName.get('University Program Application').getRecordTypeId() ||
						c.RecordTypeId == rtMapByName.get('Summer Program Application').getRecordTypeId()
					) {						
						appIds.add(c.Campus__c);
					}
				}
				System.debug('*** rtMapByName: ' + rtMapByName + '');
				System.debug('*** appIds: ' + appIds + '');
				Map<Id, Boolean> openEnd = new Map<Id, Boolean>();				
				Map<Id, Date> endDate = new Map<Id, Date>();							
				Map<Id, Date> onboardDate = new Map<Id, Date>();

				List<Campus__c> appls = [Select Id, 
					//Opportunity__r.Intended_Go_Abroad_Date__c,
					//Expected_Commencement_Date__c,
					Account__r.Contract_Status__c, 
					Account__r.Contract_End_Date__c, 
					Account__r.Contract_Open_End__c
					From Campus__c
					Where Id In:appIds];
				for(Campus__c c:appls) {
					openEnd.put(c.Id, c.Account__r.Contract_Open_End__c);
					endDate.put(c.Id, c.Account__r.Contract_End_Date__c);					
					//onboardDate.put(c.Id, c.Opportunity__r.Intended_Go_Abroad_Date__c);					
				}
				System.debug('*** openEnd: ' + openEnd + '');
				System.debug('*** endDate: ' + endDate + '');
				//System.debug('*** onboardDate: ' + onboardDate + '');
				List<Task> tasks = new List<Task>();
				for (Case c : (List<Case>) trigger.new) {
					//Not Open End Contract, need further verfiy COntract Date with Start Date
					if(appIds.contains(c.Campus__c)) {
						if(openEnd.containsKey(c.Campus__c)) {
							if(!openEnd.get(c.Campus__c)) {
								//if(onboardDate.containsKey(c.Id)) {
									if(endDate.containsKey(c.Campus__c)) {
										//if(onboardDate.get(c.Id) != null && endDate.get(c.Id) != null) {
											//if(onboardDate.get(c.Id) > endDate.get(c.Id).addMonths(2)) {
										//System.debug('*** c.Expected_Commencement_Date__c: ' + c.Expected_Commencement_Date__c + '');
										//System.debug('*** endDate.get(c.Campus__c)' + endDate.get(c.Campus__c) + '');
										//System.debug('*** endDate.get(c.Campus__c).addMonths(2) ' + endDate.get(c.Campus__c).addMonths(2) + '');
										if(c.Expected_Commencement_Date__c != null && endDate.get(c.Campus__c) != null) {
											if(c.Expected_Commencement_Date__c.addMonths(2) > endDate.get(c.Campus__c)) {
												//c.addError('Invalid School Contract! Please check!');
												System.debug('*** cp1 ');
												Task t = new Task(
													WhatId=c.Id,
													OwnerId=c.OwnerId,
													subject='[sys] Follow up School Contract',
													ActivityDate=date.today()+1
													);
												tasks.add(t);
											}
										}
									}
								//}
							}
						}
					}
				}
				System.debug('*** tasks ' + tasks + '');
				insert tasks;
			}
		}
	}
}