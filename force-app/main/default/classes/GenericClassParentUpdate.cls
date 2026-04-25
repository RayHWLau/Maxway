public class GenericClassParentUpdate {
    public static ApplicationTrigger_checkPrepaidBalence__c triggerSetting = ApplicationTrigger_checkPrepaidBalence__c.getValues('triggerSettings'); 
    ///////////// Method to update opportunity///////////////////////////
    public static void opportunityUpdate(Map<Id,Case> mapOldApp){
        
        Set<String> SetOppIds = new Set<String>();
        map< String, String > map1 = new map< String, String >();
        Map<Id,String> mapResult = new Map<Id,String>();
        List<sObject> lisObj = new List<sObject>();
        List<Task> lisTsk =new List<Task>();
        for(Case objCs :(List<Case>)trigger.new){
            if(objCs.Opportunity__c <> Null  && trigger.isUpdate && String.isNotBlank(objCs.Stage__c) && objCs.Stage__c <> mapOldApp.get(objCs.Id).Stage__c)
                SetOppIds.add('\''+objCs.Opportunity__c+'\'');
            if( triggerSetting.showDebugLogs__c )
                System.debug('SetOppIds-->'+SetOppIds);
        }
        
        //Custom mete Data query
        Map<String, Object> fieldsToValue = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Parent_sObject__c, child_sObject__c,Child_Relationship_Name__c, Parent_Reocrd_Types__c, Child_Record_Types__c, Where_Clause__c,Where_Clause_For_Child__c
                                             FROM GenericClassParentUpdate__mdt WHERE MasterLabel='GenericClassParentUpdateForOpportunity'][0].getPopulatedFieldsAsMap();
        for( String key : fieldsToValue.keySet () ){
            map1.put(key, String.valueOf( fieldsToValue.get(key)));
        }
        if( triggerSetting.showDebugLogs__c )
            System.debug('map1'+map1);
        map1.put('setOppId',String.valueOf(SetOppIds));
        if(SetOppIds.size() >0){
            if(map1.keySet().size() >0){
                
                mapResult = childToParentUpdate(map1 ); 
            }
        }
        
        if( triggerSetting.showDebugLogs__c )
            System.debug('mapResult'+mapResult); 
        if(mapResult.keySet().size() >0){
            if(map1.get('Parent_sObject__c') == 'Opportunity' && map1.get('child_sObject__c') == 'Case'){
                for(Id key :mapResult.keySet() ){
                    if(mapResult.get(key) == 'true'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.Status_Check__c = true;
                        opp.stageName = 'Rejected';
                        lisObj.add(opp);
                    }
                    if(mapResult.get(key) == 'Yes#Received'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.Status_Check__c = true;
                        opp.stageName = 'Commission Received';
                        lisObj.add(opp);
                    }
                    if(mapResult.get(key) == 'Yes#Paid'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.Status_Check__c = true;
                        opp.stageName = 'Commission paid';
                        lisObj.add(opp);
                    }
                    if(mapResult.get(key) == 'Yes#Arrived'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.Status_Check__c = true;
                        opp.stageName = 'Arrived';  //causing validation error ( Update - validation is off )
                        lisObj.add(opp);
                    }
                    
                    //added on 17 APril 2020 as per Feedback NTF-0595 , mirror Case Stage__c to Opp StageName
                    else if(mapResult.get(key) == 'Pending Arrival'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.Status_Check__c = true;
                        opp.stageName = 'Pending Arrival';
                        lisObj.add(opp);
                    }
                    //end 
                }
            }
        }
        
        if(lisObj.size() >0)
            update lisObj;
        if(lisTsk.size() >0)
            insert lisTsk;
    }
    
    //////////// Method to update Account //////////////////////////////
    public static void accountUpdate(Map<Id,Opportunity> mapold){
        
        Set<String> SetAccIds = new Set<String>();
        map< String, String > map1 = new map< String, String >();
        Map<Id,String> mapResult = new Map<Id,String>();
        List<Account> lisAcc = new List<Account>();
        List<Task> lisTask = new List<Task>();    
        //Custom mete Data query
        Map<String, Object> fieldsToValue = [SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Parent_sObject__c, child_sObject__c,Child_Relationship_Name__c, Parent_Reocrd_Types__c, Child_Record_Types__c, Where_Clause__c,Where_Clause_For_Child__c
                                             FROM GenericClassParentUpdate__mdt WHERE MasterLabel='GenericClassParentUpdateForAccount'][0].getPopulatedFieldsAsMap();    
        Map< Id, RecordType > mapOppRecordType = new Map< Id, RecordType >([ SELECT Name, Id, DeveloperName FROM  recordtype where SobjectType = 'Opportunity' AND IsActive = true]);
        
        for(Opportunity objOpp :(List<Opportunity>)trigger.new){
            if(objOpp.AccountId <> Null && String.isNotBlank(objOpp.StageName) && trigger.isUpdate && objOpp.StageName <> mapold.get(objOpp.Id).stageName)
                SetAccIds.add('\''+objOpp.AccountId+'\'');
        }
        
        for( String key : fieldsToValue.keySet () ){
            map1.put(key, String.valueOf( fieldsToValue.get(key)));
        }
        
        if(SetAccIds.size() >0){
            map1.put('SetAccId',String.valueOf(SetAccIds));
            if(map1.size() >0){
                if(map1.get('Parent_sObject__c') == 'Account' && map1.get('child_sObject__c') == 'Opportunity'){
                    mapResult = childToParentUpdate(map1 );
                    if(mapResult.keySet().size() >0){
                        for(Opportunity objOpp :(List<Opportunity>)trigger.new){
                            if(mapOppRecordType.keySet().contains( objOpp.RecordTypeId ) && map1.get('Child_Record_Types__c').contains(mapOppRecordType.get(objOpp.RecordTypeId).Name) && (map1.get('Child_Record_Types__c').contains('Agent Acquisition') || map1.get('Child_Record_Types__c').contains('Renewal -Agent Acquisition'))
                               && (mapOppRecordType.get(objOpp.RecordTypeId).Name == 'Agent Acquisition' || mapOppRecordType.get(objOpp.RecordTypeId).Name == 'Renewal -Agent Acquisition')){
                                   for(Id key : mapResult.keySet()){
                                       if(mapResult.get(key) == 'true'){
                                           Account acc = new Account();
                                           acc.Id = key;
                                           acc.Status_Sub_Agent__c = 'Close Lost';
                                           acc.Closed_Lost_Reason__c='Continue Existing System';
                                           acc.Closed_Lost_Reason_Others__c='All the opportunity under this account is closed lost';
                                           lisAcc.add(acc);
                                       }
                                   }
                               }
                            if(mapOppRecordType.keySet().contains( objOpp.RecordTypeId ) && (map1.get('Child_Record_Types__c').contains(mapOppRecordType.get(objOpp.RecordTypeId).Name) && map1.get('Child_Record_Types__c').contains('Student'))
                               && mapOppRecordType.get( objOpp.RecordTypeId ).Name == 'Student'){
                                   for(Id key : mapResult.keySet()){
                                       if(mapResult.get(key) == 'true'){
                                           Task tsk = new Task();
                                           tsk.ActivityDate = date.today();
                                           tsk.Priority = 'Normal';
                                           tsk.WhatId = key;
                                           tsk.Subject = label.TaskSubject;
                                           lisTask.add(tsk);                           
                                       }
                                       
                                       if(mapResult.get(key) =='allCloseLost' ){
                                           Task tsk = new Task();
                                           tsk.ActivityDate = date.today();
                                           tsk.Priority = 'Normal';
                                           tsk.WhatId = key;
                                           tsk.Subject = label.CloseLostStudentOppTask;
                                           tsk.Task_Owner__c= [SELECT Id, Account_Manager__c FROM Account WHERE ID=:key][0].Account_Manager__c;
                                           lisTask.add(tsk);   
                                       }
                                   }
                               }
                        }
                    }
                } 
            }
        }
      /*  System.debug('triggerSetting-->>>'+triggerSetting);
        if( triggerSetting.showDebugLogs__c )
            System.debug('lisAcc-->'+lisAcc); */
        
        if(lisTask.size() >0)
            insert lisTask;  
        System.debug('task==>'+lisTask);
        if(lisAcc.size() >0)
            update lisAcc;
    }
    
    /////////// Method to update Opportunity on insertion of Application
    public static void opportunityUpdateOnAppInsert(){
        List<Opportunity> LisOpp = new List<Opportunity>();
        for(Case csObj:(List<Case>)trigger.new){
            if(csObj.Opportunity__c <> Null && trigger.isInsert){
                Opportunity opp = new Opportunity();
                opp.StageName = 'Application In progress';
                opp.Id = csObj.Opportunity__c;                                                                                   
                LisOpp.add(opp); 
            }
        }
        
        if(LisOpp.size() >0)
            update LisOpp;
    }
    
    // Generic Method to update Parent if criteria meets on child object
    public static Map<Id, String> childToParentUpdate(Map<String,String> mapCustmMetaData){
        System.debug('mapCustmMetaData'+mapCustmMetaData);
        Map<Id,String> MapRequiredCondition = new Map<Id,String>();
        String query;
        for( String fields :Schema.getGlobalDescribe().get(mapCustmMetaData.get('child_sObject__c')).getDescribe().fields.getMap().keySet()){
            if(!fields.contains('last')){
                if(query == Null ){
                    query = 'SELECT ID,(SELECT '+ fields;
                }else{
                    query+= ','+fields;
                }
                
            }
        }
        query+= ' FROM '+ mapCustmMetaData.get('Child_Relationship_Name__c')+' '+ mapCustmMetaData.get('Where_Clause_For_Child__c')+' ) FROM '+mapCustmMetaData.get('Parent_sObject__c') +' ' +mapCustmMetaData.get('Where_Clause__c') ;
        String keyNotToMap = 'Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, Parent_sObject__c, child_sObject__c,Child_Record_Types__c, Where_Clause__c';
        for( String key : mapCustmMetaData.keySet() ){
            
            if( query.contains( key ) && !keyNotToMap.contains(key)){
                
                query = query.replace( key,mapCustmMetaData.get(key ));
            }
        }
        query = query.replace('{', '(').replace('}',')');
        if(String.isNotBlank(query)){
            for(sObject obj  : Database.query(query)){
                
                Integer rejectCount=0;
                Integer commisnRec =0;
                Integer commisnPaid =0;
                Integer arrivedCount =0;
                Integer studentCnfrm = 0;
                Integer countFOrStudentCloseLost=0;
                Integer count = 0;
                /////// When parent is Opportunity and child is Application //////////////
                if(mapCustmMetaData.get('Parent_sObject__c') == 'Opportunity' && mapCustmMetaData.get('child_sObject__c') == 'Case'){
                    for(sObject caseObj : obj.getSobjects('Applications__r')){
                        if(caseObj.get('Stage__c') == 'Reject' && caseObj.get('Rejected_By__c') !='Maxway'){
                            rejectCount++;
                        }
                        if(caseObj.get('Stage__c') == 'Commission Received'){
                            commisnRec++;
                        }
                        if(caseObj.get('Stage__c') == 'Commission Paid'){
                            commisnPaid++;
                        }
                        if(caseObj.get('Stage__c') == 'Arrived'){
                            arrivedCount++;
                        }
                        //added on 17 APril 2020 as per Feedback NTF-0595 , mirror Case Stage__c to Opp StageName
                        system.debug('caseObj --> ' + caseObj.get('Stage__c'));
                        if( caseObj.get('Stage__c') == 'Pending Arrival' ){
                            
                            MapRequiredCondition.put(obj.Id, 'Pending Arrival');
                        }
                        //end
                    }
                    if(rejectCount == obj.getSobjects('Applications__r').size())
                        MapRequiredCondition.put(obj.Id, 'True');
                    if(commisnRec > 0)
                        MapRequiredCondition.put(obj.Id, 'Yes#Received');
                    
                    if(commisnPaid>0  )
                        MapRequiredCondition.put(obj.Id, 'Yes#Paid');
                    if(arrivedCount >0)
                        MapRequiredCondition.put(obj.Id, 'Yes#Arrived');
                    
                }
                //// when parent is Account and Child is opportunity////////all opportunity stage is close lost or Rejected////////////
                if(mapCustmMetaData.get('Parent_sObject__c') == 'Account' && mapCustmMetaData.get('child_sObject__c') == 'Opportunity'){
                    for(sObject oppObj : obj.getSobjects('Opportunities')){
                        if(oppObj.get('StageName') == 'Closed Lost' && (oppObj.get('RecordTypeId') == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.agentAcqRecTypeName).getRecordTypeId() ||
                                                                        oppObj.get('RecordTypeId') == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.renAgntRecTypeName).getRecordTypeId() )){
                                                                            count++;
                                                                             System.debug('count==>'+count);
                                                                        }
                        if(oppObj.get('StageName') == 'Rejected' && (oppObj.get('RecordTypeId') == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.studentRecTypeName).getRecordTypeId())){
                            count++;
                        }
                        if(oppObj.get('StageName') == 'Closed Lost' && (oppObj.get('RecordTypeId') == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.studentRecTypeName).getRecordTypeId())){
                          countFOrStudentCloseLost++;
                        }
                    }
                    System.debug('count==>'+count);
                    System.debug('countFOrStudentCloseLost==>'+countFOrStudentCloseLost);
                    System.debug('obj'+obj.getSobjects('Opportunities').size());
                    if(count == obj.getSobjects('Opportunities').size()){
                        System.debug('map true');
                        MapRequiredCondition.put(obj.Id, 'True');
                    }
                    if(countFOrStudentCloseLost == obj.getSobjects('Opportunities').size()){
                        MapRequiredCondition.put(obj.Id,'allCloseLost');
                    }
                    else {
                        MapRequiredCondition.put(obj.Id, 'False');
                    }
                }
            }
        }
        if( triggerSetting.showDebugLogs__c )
            System.debug('MapRequiredCondition-->'+MapRequiredCondition);
            return MapRequiredCondition;
    }
    
}