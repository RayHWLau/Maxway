global class BatchClassToDeleteAgentDocs implements  Database.Batchable<sObject>, Database.Stateful {
    global Set<Id> userids = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext BC){
        String applicationquery ='select id,Opportunity__c,ownerid from case where ownerid in (select id from user where isactive=false and doc_deleted__c = false and isportalenabled =true)';
        return database.getQueryLocator(applicationquery);
    }
    global void execute(Database.BatchableContext BC, List<case> scope){
        set<id> linkedentitydata = new set<id>();
        set<id> oppappidlist = new set<id>();
        list<ContentDocument> contentdoctobedeleted = new list<ContentDocument>();
        for(case cse : scope){
            userids.add(cse.OwnerId);
            oppappidlist.add(cse.id); 
            oppappidlist.add(cse.Opportunity__c); 
            
        }
        for(document_upload__c doc :[select id, application__c,opportunity__c from document_upload__c where application__c in :oppappidlist or opportunity__c in :oppappidlist]){
            linkedentitydata.add(doc.id);
        }
        for(Contentdocumentlink doclink :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : linkedentitydata]){
            contentdoctobedeleted.add(new ContentDocument(id = doclink.ContentDocumentId));
            system.debug('ffff'+linkedentitydata);
            system.debug('fffg'+doclink.ContentDocumentId);
        }
          if(contentdoctobedeleted.size()>0)
          delete contentdoctobedeleted;
        
    }
    global void finish(Database.BatchableContext BC){
        system.debug('useridsg'+userids);
        ID jobID1 = System.enqueueJob(new QueuebleToUpdateDocDeleteCheck(userids));
        system.debug('jobID1-->'+jobID1);
        
        
    }
}