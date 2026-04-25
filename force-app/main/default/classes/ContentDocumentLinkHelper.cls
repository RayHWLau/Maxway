/*                                                                                                                                                                                                                                                               /*
Description        
*/

public class ContentDocumentLinkHelper {
    
    //*************************************************************To provide access to siteusers***********************************************************
    public static void provideAccessToSiteUsers(List<ContentDocumentLink> triggerNew){
        Schema.DescribeSObjectResult r = schema.getGlobalDescribe().get('Document_Upload__c').getDescribe();
        list<ContentDocumentLink> contentlist = new list<ContentDocumentLink>();
        String keyPrefix = r.getKeyPrefix();
        for(ContentDocumentLink cdl : triggerNew){
            String entityId = cdl.LinkedEntityId; 
            if(entityId.startsWith(keyPrefix)){ 
                contentlist.add(new ContentDocumentLink(id = cdl.id,Visibility = 'AllUsers'));
            }
        }
        if(contentlist.size()>0) update contentlist;
        
    }
    //******************************************************************************************************************************************************
    
    public static void updateDocumentUploadUrl ( List< ContentDocumentLink > triggerNew){
        
        map< Id,Document_Upload__c > mapDocUpldUrl = new  map< Id,Document_Upload__c >();
        map< string,string > mapCntntlinkToDocUpldId = new  map< string,string >();
        map< string,string > mapcontentversnandlinkldId = new  map< string,string >();
        list< Opportunity > listUpdtOpp = new list< Opportunity >();
        Schema.DescribeSObjectResult pre = schema.getGlobalDescribe().get('Document_Upload__c').getDescribe();
        String keyPrefix = pre.getKeyPrefix(); 
        
        for( ContentDocumentLink objCtnt : triggerNew ){
            if( String.valueOf(objCtnt.LinkedEntityId).startsWith(keyPrefix) ){
                system.debug('objCtnt-->'+objCtnt.ContentDocumentId);
                system.debug('LinkedEntityId-->'+objCtnt.LinkedEntityId);
                mapCntntlinkToDocUpldId.put( objCtnt.ContentDocumentId,objCtnt.LinkedEntityId );
            }
            
        }
        
        list<ContentDistribution> distributionlist = new list<ContentDistribution>();
        
        if( mapCntntlinkToDocUpldId.keySet().size() > 0 ){
            for( ContentVersion objConVer : [SELECT Id,ContentDocumentId,title FROM ContentVersion Where ContentDocumentId IN: mapCntntlinkToDocUpldId.keySet() ]){
                ContentDistribution cd = new ContentDistribution();
                cd.contentVersionId  = objConVer.Id;
                cd.PreferencesAllowViewInBrowser = True;
                cd.PreferencesNotifyRndtnComplete=false;
                cd.PreferencesNotifyOnVisit=false;
                cd.Name = objConVer.title;
                distributionlist.add(cd);
                mapcontentversnandlinkldId.put(objConVer.id,mapCntntlinkToDocUpldId.get(objConVer.ContentDocumentId));
            }
        }
        database.insert(distributionlist,false);
        
        set<string> ids = new set<string>();
        for(ContentDistribution con : distributionlist){
            ids.add(con.id);   
        }
        for(ContentDistribution contentdis :[SELECT DistributionPublicUrl,contentVersionId FROM ContentDistribution WHERE id in :ids]){
            Document_Upload__c objDocUpld = new Document_Upload__c();
            objDocUpld.Id = mapcontentversnandlinkldId.get(contentdis.contentVersionId);
            objDocUpld.Document_Link__c = contentdis.DistributionPublicUrl;
            system.debug(contentdis.DistributionPublicUrl);
            mapDocUpldUrl.put(objDocUpld.Id,objDocUpld);
            
        }
        
        if( mapDocUpldUrl.keyset().size() > 0){
            update mapDocUpldUrl.values();
            
        }
    }
    // method used in contendocumentdeletetrigger for restrictdeletion of files 
    public static void restrictdocumentdelete(set<id> ContentDocumentIds,list<ContentDocument> contentlist){
        
        Schema.DescribeSObjectResult r = schema.getGlobalDescribe().get('Document_Upload__c').getDescribe();
        String keyPrefix = r.getKeyPrefix();
        
        map<string,string> mapforoppstage = new map<string,string>();
        set<string> nottobedeletedids = new set<string>();
        
        list<string> oppstagelist = new list<string>{'Quotation & Agreement Signed','Invoice Issued','Sales Won'};
            
            for(Contentdocumentlink doclink :[SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN : ContentDocumentIds]){
                if(string.valueof(doclink.LinkedEntityId).startswith(keyPrefix))
                    mapforoppstage.put(doclink.LinkedEntityId,doclink.ContentDocumentId);   
            }
        
        for(document_upload__c doc :[select opportunity__r.stagename from document_upload__c where id in :mapforoppstage.keyset()]){
            if(oppstagelist.contains(doc.Opportunity__r.stagename)){
                nottobedeletedids.add(mapforoppstage.get(doc.id));     
            }
            
            
        }
        for(ContentDocument doclink : contentlist){
            if(nottobedeletedids.contains(doclink.id)){
                doclink.adderror('Cannot delete document');
            }
        }
    }
    
    public static void documentuploadcheck(set<ID> Docid){
        
        
        map<string,string> documentuploadquotationmap = new map<string,string>();
        
        set<id> documentuploadforrequiredquote = new set<id>();
        set<id> documentuploadforsignedquote = new set<id>();
        set<id> documentuploadforrequiredandsignedquote = new set<id>();
        set<id> documentuploadforrequiredAgentsignup = new set<id>();
        
        Integer requireddocsize =0;
        Integer signeddocsize=0;
        Integer requiredsigneddocsize=0;
        Integer Agentsignupform=0;
        
        set<string> signeddoclist = new set<string>();
        
        for(string str : label.SignedDocumentlistforSignedQuotationStage.split(';')){
            signeddoclist.add(str);   
        }
        
        if(Docid.size()>0){
            
            id oppid = [Select id,opportunity__c from document_upload__c where id in :Docid LIMIT 1].opportunity__c;
            if(oppid != null){
                
                for(Document_Upload__c doc : [Select id,opportunity__c,Document_Master__r.required__c,Document_Master__r.name,Document_Master__r.Process__c from document_upload__c WHERE  Document_Master__r.active__c=True
                                              AND opportunity__c = :oppid
                                              AND Document_Master__r.process__c in ('Agent Signup Form','Quotation')]) {
                                                  if(doc.Document_Master__r.process__c=='Quotation'){
                                                      if(doc.Document_Master__r.required__c==True){
                                                          documentuploadquotationmap.put(doc.id,'Required');
                                                          requireddocsize++; 
                                                      }
                                                      if(signeddoclist.contains(doc.Document_Master__r.name)){
                                                          documentuploadquotationmap.put(doc.id,'Signed'); 
                                                          signeddocsize++; 
                                                      }
                                                      if(signeddoclist.contains(doc.Document_Master__r.name) && doc.Document_Master__r.required__c==True){
                                                          documentuploadquotationmap.put(doc.id,'Required & Signed');
                                                          requiredsigneddocsize++; 
                                                      }
                                                  }
                                                  else{
                                                      if(doc.Document_Master__r.required__c==True){
                                                          documentuploadquotationmap.put(doc.id,'Requiredagent');
                                                          Agentsignupform++; 
                                                      }   
                                                  }
                                              }
                
                if(documentuploadquotationmap.size()>0){ 
                    for(ContentDocumentLink conDocLink :[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :documentuploadquotationmap.keySet()]){
                        if(documentuploadquotationmap.get(conDocLink.LinkedEntityId)=='Required')
                            documentuploadforrequiredquote.add(conDocLink.LinkedEntityId); 
                        if(documentuploadquotationmap.get(conDocLink.LinkedEntityId)=='Signed')
                            documentuploadforsignedquote.add(conDocLink.LinkedEntityId); 
                        if(documentuploadquotationmap.get(conDocLink.LinkedEntityId)=='Required & Signed')
                            documentuploadforrequiredandsignedquote.add(conDocLink.LinkedEntityId); 
                        if(documentuploadquotationmap.get(conDocLink.LinkedEntityId)=='Requiredagent')
                            documentuploadforrequiredAgentsignup.add(conDocLink.LinkedEntityId); 
                    }
                    if(requiredsigneddocsize == documentuploadforrequiredandsignedquote.size() &&
                       requireddocsize-requiredsigneddocsize == documentuploadforrequiredquote.size()){ 
                           system.debug('requiredoc');
                           opportunity opp = new opportunity();
                           opp.id = oppid;
                           opp.Quotation_Attached__c = true;
                           update opp;
                       }
                    if(requiredsigneddocsize == documentuploadforrequiredandsignedquote.size() &&
                       signeddocsize-requiredsigneddocsize == documentuploadforsignedquote.size()){ 
                           system.debug('requiresigndoc'+requiredsigneddocsize);
                           
                           opportunity opp = new opportunity();
                           opp.id = oppid;
                           opp.SignedDocument__c = true;
                           update opp;
                       }
                    if(Agentsignupform == documentuploadforrequiredAgentsignup.size() ){ 
                        opportunity opp = new opportunity();
                        opp.id = oppid;
                        opp.AgentSignedUpDocUpload__c = true;
                        update opp;
                    }
                    system.debug('requiredocf++++++++++++++>>>>>>>>>>'+requiredsigneddocsize);
                    if(requiredsigneddocsize != documentuploadforrequiredandsignedquote.size() ||
                       requireddocsize-requiredsigneddocsize != documentuploadforrequiredquote.size()){ 
                           
                           opportunity opp = new opportunity();
                           opp.id = oppid;
                           opp.Quotation_Attached__c = false;
                           database.update(opp,false);
                       }
                     system.debug('requiresigndocf==========>>>>>>'+requiredsigneddocsize);
                    if(requiredsigneddocsize != documentuploadforrequiredandsignedquote.size() ||
                       signeddocsize-requiredsigneddocsize != documentuploadforsignedquote.size()){ 
                          
                           opportunity opp = new opportunity();
                           opp.id = oppid;
                           opp.SignedDocument__c = false;
                           update opp;
                       }
                    system.debug('Agentsignupform=============>'+Agentsignupform);
                    if(Agentsignupform != documentuploadforrequiredAgentsignup.size() ){ 
                        
                        opportunity opp = new opportunity();
                        opp.id = oppid;
                        opp.AgentSignedUpDocUpload__c = false;
                        update opp;
                    }   
                }
            }
        }
    }
    
    /*    public static void submitForApprovalCheckOnApplication(set<ID> DocId){
List<sObject> LisCaseOrOpp = new List<sObject>();

if(DocId.Size() >0){
id appId = [Select id, Application__c from document_upload__c where id in :Docid LIMIT 1].Application__c;
id oppId = [SELECT id, Opportunity__c from document_upload__c where id in: Docid LIMIT 1].Opportunity__c;
// Map<Id,Integer> mapRequiredDocToCount = new MAp<Id, Integer>();
Set<Id> SetReqdocIds = new Set<Id>();
System.debug('appId'+appId);
System.debug('oppId'+oppId);

Integer count =0;
Boolean onlyOppRequired = False;
if(String.isNotBlank(appId)){
for(Document_Upload__c docUpld : [SELECT ID,Application__c, Required__c FROM Document_Upload__c WHERE Application__c =:appId
AND Required__c = True AND Application__c != Null 
]){
//  count++;
SetReqdocIds.add(docUpld.Id);
}

}
System.debug('SetReqdocIds'+SetReqdocIds);

if(String.isBlank(appId) && String.isNotBlank(oppId) ){
for(Document_Upload__c docUpld : [SELECT ID,Opportunity__c, Required__c FROM Document_Upload__c WHERE 
Opportunity__c =:oppId AND Required__c = True 
]){
//  count++;
SetReqdocIds.add(docUpld.Id);

}
}

System.debug('SetReqdocIds'+SetReqdocIds);
if(SetReqdocIds.size() >0){
for(ContentDocumentLink conDocLink :[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:SetReqdocIds]){
if(SetReqdocIds.contains(conDocLink.LinkedEntityId))
count++;
}

}
System.debug('count'+count);
if(count == SetReqdocIds.size() && appId <> Null){

Case cs = new Case();
cs.Id = appId;
cs.Required_Document_Upload__c = 'Yes';
LisCaseOrOpp.add(cs);
}

if(count == SetReqdocIds.size() && oppId <> Null){
Opportunity opp = new Opportunity();
opp.Id = oppId;
opp.Required_Document_Upload__c	 = 'Yes';
LisCaseOrOpp.add(opp);                
}
}
System.debug('LisCaseOrOpp-->'+LisCaseOrOpp);
// if(LisCaseOrOpp.size() >0)
//   update LisCaseOrOpp;
}*/
    
    public static map<string,string> contentdocumentvalidationcheck(set<string> recordids , string recordnames , string conditions){
        // recordids = id1
        // recordnames = name1
        // conditions = datatype,fieldname;condition
        map<id,list<string>> mapOfRecordIdWithDocUploadList = new map<id,list<string>>();
        map<string,string> mapOflinkedentityidWithcontentdoc = new map<string,string>();
        map<string,string> mapOfrecordidWithcondition = new map<string,string>();
        set<string> linkedentityid = new set<string>();
        
        if(recordids.size()>0){
            
            string query = 'select id,application__c,opportunity__c from document_upload__c where '+recordnames+' in :recordids';
           
            string[] conditiontype = conditions.split(',');
            string[] conditionsplit = conditiontype[1].split(';');
           
            if(conditiontype[0]=='Boolean'){
                //query += ' and '+conditionsplit[0]+' = '+conditiontype[1];
                query += ' and '+conditionsplit[0]+' = '+conditionsplit[1]; 
            }
            if(conditiontype[0]=='string'){
                set<string> stringcondition = new set<string>();
                stringcondition.add(conditionsplit[1]);
                query += ' and '+conditionsplit[0]+' in :stringcondition';     
            }
            
            system.debug(query);
            for(document_upload__c doc: database.query(query)){
                linkedentityid.add(doc.id);
                mapOflinkedentityidWithcontentdoc.put(doc.id,'false');
                Id recordid = (Id)doc.get(recordnames);
                if(mapOfRecordIdWithDocUploadList.containskey(recordid)){
                    list<string> docuploadlist =  mapOfRecordIdWithDocUploadList.get(recordid);
                    docuploadlist.add(doc.id); 
                    mapOfRecordIdWithDocUploadList.put(doc.Application__c,docuploadlist);
                }
                else{
                    mapOfRecordIdWithDocUploadList.put(doc.Application__c,new list<string>{doc.id});
                }
              
            } 
            system.debug('linkedentityid'+linkedentityid);
            system.debug('mapOfRecordIdWithDocUploadList'+mapOfRecordIdWithDocUploadList);
            if(linkedentityid.size()>0){
                for(contentdocumentlink content : [select linkedentityid from contentdocumentlink where linkedentityid in :linkedentityid]){
                    if(mapOflinkedentityidWithcontentdoc.containskey(content.linkedentityid)){
                        mapOflinkedentityidWithcontentdoc.put(content.linkedentityid,'true');  
                    }
                }
            }
            for(string str : mapOfRecordIdWithDocUploadList.keyset()){
                for(string strf : mapOfRecordIdWithDocUploadList.get(str)){
                    
                    if(mapOflinkedentityidWithcontentdoc.containskey(strf)){
                        
                        mapOfrecordidWithcondition.put(str,'true');
                        
                        if(mapOflinkedentityidWithcontentdoc.get(strf)=='false'){
                            
                            mapOfrecordidWithcondition.put(str,'false'); 
                        }
                    }  
                }
            }
            return mapOfrecordidWithcondition;
        }
        return null;
    }  
}