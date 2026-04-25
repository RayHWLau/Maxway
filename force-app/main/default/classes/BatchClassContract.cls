global class BatchClassContract  implements  Database.Batchable<sObject> {
    
    global final string query;
    global  Id recordTypeIdagent;
    global  Id recordTypeIdmarketing;
    
    global BatchClassContract(String q){
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        recordTypeIdagent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        recordTypeIdmarketing = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Marketing Contract').getRecordTypeId();
        string Activated = 'Activated';
        string ContractActivated = 'Contract Activated';
        date todaydate = system.today();
        date add90days = system.today().adddays(90);
        date thritydaysbeforeexpiredate = system.today().adddays(30);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<contract> con_List = (List<contract>)scope;
        system.debug(con_List.size());
        list<contract> contracttoupdate = new list<contract>();
        list<task> taskcreation = new list<task>();
        list<Opportunity> renewalopp = new list<Opportunity>();
        Id recordTypeIdRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal -Agent Acquisition').getRecordTypeId();
        recordTypeIdagent = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        recordTypeIdmarketing = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Marketing Contract').getRecordTypeId();
        date thritydaysbeforeexpiredate = system.today().adddays(30);
        date todaydate = system.today();
        
        for(contract s : con_List){
            
            if((string)s.get('recordtypeID') == recordTypeIdmarketing && (date)s.get('enddate') == todaydate){
                contracttoupdate.add(new contract(id = (Id)s.get('Id'),status='Expired'));
            }
            if((string)s.get('recordtypeID') == recordTypeIdmarketing && (date)s.get('enddate') == thritydaysbeforeexpiredate){
                taskcreation.add(new task (WhatId=(Id)s.get('Id') ,Subject= s.account.name+': should we / how to renew?',Task_Owner__c=s.account.Account_Manager__c,OwnerId=(Id)s.get('OwnerId'),ActivityDate=system.today()));
            }
            if((string)s.get('recordtypeID') == recordTypeIdagent){
                renewalopp.add(new opportunity(Recordtypeid=recordTypeIdRenewal, name='Renewal',AccountId = (Id)s.get('AccountId'),Business_Type__c='Renewal',StageName='Initiate Contact',CloseDate=system.today().addyears(1)));   
            }
        }  
        if(contracttoupdate.size()>0) update contracttoupdate;
        if(renewalopp.size()>0) insert renewalopp;
        if(taskcreation.size()>0) insert taskcreation;
    }
    global void finish(Database.BatchableContext BC){
    }
    
}