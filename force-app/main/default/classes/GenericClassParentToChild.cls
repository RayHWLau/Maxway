/**
* @File Name : GenericClassParentToChild.cls
* @Description : 
* @Author : Shalini Singh
* @Last Modified By : Shalini Singh
* @Last Modified On : 27 Jan 2020
* @Modification Log :
*==============================================================================
* Ver Date Author Modification
*==============================================================================
* 1.0  24 Jan 2020 Initial Version
**/
public class GenericClassParentToChild {
    
    public static Set<ID> SetRecursiveoppId = new Set<Id>();
    public static void childToParentgetData(String MasterObject, String childRelationshipObject, Set<Id> masterObjectID, Set<Id> recordTypeIdChild,  Boolean isInsert){
        System.debug('SetRecursiveoppId.size(-->)'+SetRecursiveoppId.size());
        if(SetRecursiveoppId.size()==0){
               System.debug('inside1');
        Map<Id,String> MapIfTure = new Map<Id,String>();
        List<sObject> lisObj = new List<sObject>();
        List<Task> lisTask = new List<Task>();
        System.debug('recordTypeIdChild-->'+recordTypeIdChild);
        if(!isInsert){
            if(MasterObject == 'Account' && childRelationshipObject == 'Opportunity'){
                
                if(recordTypeIdChild.contains(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.agentAcqRecTypeName).getRecordTypeId()) ||
                   recordTypeIdChild.contains(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.renAgntRecTypeName).getRecordTypeId())){
                       MapIfTure =   parentToChildValidation(MasterObject,childRelationshipObject,masterObjectID,recordTypeIdChild);
                       
                       for(Id key : MapIfTure.keySet()){
                           if(MapIfTure.get(key) == 'true'){
                               Account acc = new Account();
                               acc.Id = key;
                               acc.Status_Sub_Agent__c = 'Close Lost';
                               acc.Closed_Lost_Reason__c='Others';
                               acc.Closed_Lost_Reason_Others__c='All the opportunity under this account is closed lost';
                               lisObj.add(acc);
                           }
                       }
                   }
                if(recordTypeIdChild.contains(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.studentRecTypeName).getRecordTypeId())){
                    MapIfTure =   parentToChildValidation(MasterObject,childRelationshipObject,masterObjectID,recordTypeIdChild);
                    
                    for(Id key : MapIfTure.keySet()){
                        if(MapIfTure.get(key) == 'true'){
                            
                            Task tsk = new Task();
                            tsk.ActivityDate = date.today();
                            tsk.Priority = 'Normal';
                            tsk.WhatId = key;
                            tsk.Subject = label.TaskSubject;
                            lisTask.add(tsk);                           
                            
                            
                        }
                    }
                }
            } 
            
            if(MasterObject == 'Opportunity' && childRelationshipObject == 'Case' /*&& recordTypeIdChild.contains(Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseCCRecTypeName).getRecordTypeId())*/ /*&& trigger.isUpdate*/){
                
                MapIfTure = parentToChildValidation(MasterObject,childRelationshipObject,masterObjectID,new Set<Id>{});
                
                System.debug('MapIfTure---->>>>>>>'+MapIfTure);
                
                for(Id key : MapIfTure.keySet()){
                    if(MapIfTure.get(key) == 'true'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.stageName = 'Rejected';
                        lisObj.add(opp);
                    }
                    if(MapIfTure.get(key) == 'Yes#Received'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        opp.stageName = 'Commission Received';
                        lisObj.add(opp);
                    }
                    if(MapIfTure.get(key) == 'Yes#Paid'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                           opp.stageName = 'Commission paid';
                        lisObj.add(opp);
                    }  
                  /*  if(MapIfTure.get(key) == 'Yes#Arrived'){
                        Opportunity opp = new Opportunity();
                        opp.Id = key;
                        lisObj.add(opp);
                    } */
                }
            }    
        }
        
        if(isInsert){
            
            if(MasterObject == 'Opportunity' && childRelationshipObject == 'Case' && (recordTypeIdChild.contains(Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptInRecTypeName).getRecordTypeId())
                                                                                      || recordTypeIdChild.contains(Schema.SObjectType.Case.getRecordTypeInfosByName().get(ConstantsClass.caseOptOutRecTypeName).getRecordTypeId())) /*&& trigger.isInsert*/){
                                                                                          
                                                                                          if(masterObjectID<> Null){
                                                                                              for(Id key : masterObjectID){
                                                                                                  Opportunity opp = new Opportunity();
                                                                                                  opp.StageName = 'Application In progress';
                                                                                                  opp.Id = key;
                                                                                                  lisObj.add(opp);
                                                                                              }
                                                                                          }
                                                                                      }
        }
        
        
        System.debug('lisObj-->'+lisObj);
            if(lisObj.size() >0){
                try{
               update lisObj; 
                }catch(Exception e){
                    System.debug('Error e--->'+e);
                }
            }
            
        if(lisTask.size() >0)
            insert lisTask;
        }
     
    }
    
    
    public static Map<Id,String> parentToChildValidation(String MasterObject, String childRelationshipObject, Set<Id> masterObjectID, Set<Id> recordTypeIdSet){
        system.debug('recordTypeIdSet-->'+recordTypeIdSet);
       
        Map<Id,String> MapRequiredCondition = new Map<Id,String>();
        String query ='';
        
        System.debug('inside3');
        if(!String.isBlank(MasterObject) && !String.isBlank(childRelationshipObject) ){
            
            if(masterObjectID.size() > 0){
                query = 'SELECT ID,(SELECT Id,';
                if(MasterObject == 'Account' && childRelationshipObject == 'Opportunity'){
                    
                    query+= ' StageName FROM Opportunities WHERE STAGENAME != Null AND RECORDTYPEID IN :recordTypeIdSet) FROM ACCOUNT WHERE ID IN  (SELECT ACCOUNTID FROM Opportunity WHERE AccountID IN : masterObjectID )';
                }
                if(MasterObject == 'Opportunity' && childRelationshipObject == 'Case'){
                    
                    query+= ' Stage__c FROM Applications__r WHERE Stage__c != Null) FROM Opportunity WHERE ID IN  (SELECT Opportunity__c FROM Case WHERE Opportunity__c IN : masterObjectID )';
                }
                
            }
            
            list<sObject> listobj = new list<sObject>();
            //System.debug('query data-->'+Database.query(query));      
            if( String.isNotBlank( query ) ){                              //----> added null check 
                for(sObject obj : Database.query(query)){
                    Integer count = 0;
                    //System.debug('@@@@12'+obj.getSobjects('Applications__r'));
                         if( obj.getSObjectType() == Schema.Account.getSObjectType() && MasterObject == 'Account' && childRelationshipObject == 'Opportunity'){
                        System.debug('obj.getSObjectType()-->'+obj.getSObjectType());
                        System.debug('MasterObject-->'+MasterObject);
                        System.debug('childRelationshipObject-->'+childRelationshipObject);
                        System.debug('obj.getSobject-->'+obj.getSobjects('Opportunities'));
                        for(sObject oppObj : obj.getSobjects('Opportunities')){
                            if(oppObj.get('StageName') == 'Closed Lost' && (recordTypeIdSet.contains(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.agentAcqRecTypeName).getRecordTypeId()) ||
                                                                            recordTypeIdSet.contains(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.renAgntRecTypeName).getRecordTypeId())                                          )
                              ){
                                  System.debug('count');
                                  count++;
                              }
                            if(oppObj.get('StageName') == 'Rejected' && recordTypeIdSet.contains(Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(ConstantsClass.studentRecTypeName).getRecordTypeId())){
                                count++;
                                
                            }
                            
                        }
                        System.debug('count-->'+count);
                        
                        if(count == obj.getSobjects('Opportunities').size()){
                            MapRequiredCondition.put(obj.Id, 'True');
                             SetRecursiveoppId.add(obj.Id);
                        }
                            
                        else {
                            MapRequiredCondition.put(obj.Id, 'False');
                             SetRecursiveoppId.add(obj.Id);
                        }
                            
                    }
                    
                    if(obj.getSObjectType() == Schema.Opportunity.getSObjectType() && MasterObject == 'Opportunity' && childRelationshipObject == 'Case' ){
                        System.debug('inside4'); 
                        Integer rejectCount=0;
                        Integer commisnRec =0;
                        Integer commisnPaid =0;
                        Integer arrivedCount =0;
                        Boolean  commissionRecORPaid = false;
                        System.debug('@@@@'+obj.getSobjects('Applications__r'));
                        for(sObject caseObj : obj.getSobjects('Applications__r')){
                            if(caseObj.get('Stage__c') == 'Reject' )
                                rejectCount++;
                            if(caseObj.get('Stage__c') == 'Commission Received'){
                                commisnRec++;
                            }
                            if(caseObj.get('Stage__c') == 'Commission Paid'){
                                commisnPaid++;
                            }
                            if(caseObj.get('Stage__c') == 'Arrived'){
                                arrivedCount++;
                            }
                        }
                        System.debug('commisnPaid-->'+commisnPaid);
                        System.debug('commisnRec-->'+commisnRec);
                        System.debug('rejectCount-->'+rejectCount);
                        System.debug('arrivedCount-->'+arrivedCount);
                        if(rejectCount == obj.getSobjects('Applications__r').size()){
                            MapRequiredCondition.put(obj.Id, 'True');
                            SetRecursiveoppId.add(obj.Id);
                        }
                            
                        if(commisnRec > 0){
                            System.debug('inside commision received');
                             MapRequiredCondition.put(obj.Id, 'Yes#Received');
                            SetRecursiveoppId.add(obj.Id);
                        }
                           
                        if(commisnPaid>0  ){
                             MapRequiredCondition.put(obj.Id, 'Yes#Paid');
                             SetRecursiveoppId.add(obj.Id);
                        }
                           
                        if(arrivedCount >0){
                             MapRequiredCondition.put(obj.Id, 'Yes#Arrived');
                             SetRecursiveoppId.add(obj.Id);
                        }
                         /*   
                        else{
                             MapRequiredCondition.put(obj.Id, 'False');
                             SetRecursiveoppId.add(obj.Id);
                        }
                          */  
                    }
                   
                    
                    
                }        
            }      
        }
        System.debug('MapRequiredCondition-->'+MapRequiredCondition);
        return MapRequiredCondition;
        
    }
    
}