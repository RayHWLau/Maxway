public class docUpload {
    @Auraenabled
    public static documentlist docuploadmethod(string applicationid){
        documentlist documaster = new  documentlist();
        list<document_upload__c> existingdoclist = [select name,document_discription__c,required__c from document_upload__c where application__c = :applicationid 
                                                    AND 
                                                    application__c != null
                                                    AND
                                                    document_master__r.default__c=false];
        for(document_master__c masterdoclist : [select name,Process__c,Id,required__c from document_master__c where Process__c ='Application' and default__c=false and level__c='Application']){
            WrapMasterDoclist wrapmasterdoc =  new WrapMasterDoclist();  
            wrapmasterdoc.masterdoc = masterdoclist;
            documaster.documentmasterlist.add(wrapmasterdoc);
        }
        user usr = [select contactid from user where id=:UserInfo.getUserId()];
        if(string.isNotBlank(usr.contactid))
            documaster.ismaxway=false;
        if(existingdoclist.size()>0)
            documaster.documentuploadlist = existingdoclist;
        
        return documaster;
    }
    @Auraenabled
    public static existinglistdocclass savedocupload(list<string> requirechecklist,list<document_upload__c> docuploadlist,string appid){
        existinglistdocclass wrapclas = new existinglistdocclass();
        try{
            list<document_upload__share> docsharelist = new list<document_upload__share>();
            set<id> usridtoshare = new set<id>();
            list<document_upload__c> doclist = new list<document_upload__c>(); 
            if(docuploadlist.size()>0 && string.isNotBlank(appid)){
                
                for(integer i=0;i<=docuploadlist.size()-1;i++){
                    if(string.isNotBlank(docuploadlist[i].Name)){
                        if(requirechecklist[i]=='true') docuploadlist[i].Required__c=true;
                        docuploadlist[i].Application__c=appid;
                        doclist.add(docuploadlist[i]);
                    } 
                }
                if(doclist.size()>0) insert doclist;
            }
            
            list<document_upload__c> existingdoclist = [select name,document_discription__c,required__c,application__r.ownerid from document_upload__c where application__c = :appid 
                                                        AND 
                                                        application__c != null
                                                        AND
                                                        document_master__r.default__c=false];
            if(existingdoclist.size()>0){
                wrapclas.documentuploadlist = existingdoclist;
                map<id,user> partalusermap = new map<id,user>();
                map<id,user> nonpartalusermap = new map<id,user>();
                for(user usr : [select accountid,id,isportalenabled from user where isactive=true]){
                    if(usr.isportalenabled){
                        partalusermap.put(usr.id,usr);   
                    }
                    else{
                        nonpartalusermap.put(usr.id,usr);  
                    }
                    
                }
                if(partalusermap.containsKey(existingdoclist[0].application__r.ownerid ) && nonpartalusermap.containsKey(UserInfo.getUserId()) ){
                    id accountid = partalusermap.get(existingdoclist[0].application__r.ownerid).accountid;
                    for(id us : partalusermap.keyset()){
                        if(partalusermap.get(us).accountid==accountid){
                            usridtoshare.add(us);  
                        }
                    }
                    for(document_upload__c doc :doclist){
                        for(id u : usridtoshare){
                            document_upload__share docshare = new document_upload__share();
                            docshare.parentid=doc.id;
                            docshare.userorgroupid = u;
                            docshare.accesslevel ='Read';    
                            docsharelist.add(docshare);   
                        }
                        
                    }
                    insert docsharelist;
                }
                
            }
            wrapclas.msg = 'success;'+string.valueof(doclist.size());
            
            return wrapclas;
        }
       catch(exception e){
            existinglistdocclass wrapclasexception = new existinglistdocclass();
            wrapclasexception.msg = e.getMessage();
            return wrapclasexception;
        } 
    }
    @Auraenabled
    public static existinglistdocclass addmasterdocupload(list<string> mainmasterdoclist,list<string> requiremasterdoc,string appid){
        existinglistdocclass wrapclas = new existinglistdocclass();
        try{
            list<document_upload__share> docsharelist = new list<document_upload__share>();
            set<id> usridtoshare = new set<id>();
            list<document_upload__c> doclist = new list<document_upload__c>(); 
            if(mainmasterdoclist.size()>0 && string.isNotBlank(appid)){ 
                
                for(string doc : mainmasterdoclist){
                    system.debug(doc);
                    if(requiremasterdoc.contains(doc)){
                        string[] splitdocdetails =doc.split(';');
                        doclist.add(new document_upload__c(name=splitdocdetails[1],Application__c=appid,document_master__c = splitdocdetails[0],required__c=true));   
                    }
                    else{
                        string[] splitdocdetails =doc.split(';');
                        doclist.add(new document_upload__c(name=splitdocdetails[1],Application__c=appid,document_master__c = splitdocdetails[0]));}
                    
                }
                if(doclist.size()>0) insert doclist;
            }
            list<document_upload__c> existingdoclist = [select name,document_discription__c,required__c,application__r.ownerid  from document_upload__c where application__c = :appid 
                                                        AND 
                                                        application__c != null
                                                        AND
                                                        document_master__r.default__c=false];
            if(existingdoclist.size()>0){
                wrapclas.documentuploadlist = existingdoclist;
                map<id,user> partalusermap = new map<id,user>();
                map<id,user> nonpartalusermap = new map<id,user>();
                for(user usr : [select accountid,id,isportalenabled from user where isactive=true]){
                    if(usr.isportalenabled){
                        partalusermap.put(usr.id,usr);   
                    }
                    else{
                        nonpartalusermap.put(usr.id,usr);  
                    }
                    
                }
                System.debug('partalusermap=====++++++++++++++>>>>>>>>>>'+partalusermap);
                System.debug('nonpartalusermap=====++++++++++++++>>>>>>>>>>'+nonpartalusermap);
                 System.debug('existingdoclist[0].application__r.ownerid=====++++++++++++++>>>>>>>>>>'+existingdoclist[0].application__r.ownerid);
                if(partalusermap.containsKey(existingdoclist[0].application__r.ownerid ) && nonpartalusermap.containsKey(UserInfo.getUserId()) ){
                    id accountid = partalusermap.get(existingdoclist[0].application__r.ownerid).accountid;
                    for(id us : partalusermap.keyset()){
                        if(partalusermap.get(us).accountid==accountid){
                            usridtoshare.add(us);  
                        }
                    }
                    for(document_upload__c doc :doclist){
                        for(id u : usridtoshare){
                            document_upload__share docshare = new document_upload__share();
                            docshare.parentid=doc.id;
                            docshare.userorgroupid = u;
                            docshare.accesslevel ='Read';    
                            docsharelist.add(docshare);   
                        }
                        
                    }
                    insert docsharelist;
                }
                
            }
            
            wrapclas.msg = 'success';
            
            return wrapclas;
        }
        catch(exception e){
            existinglistdocclass wrapclasexception = new existinglistdocclass();
            wrapclasexception.msg = e.getMessage();
            return wrapclasexception;
        }
        
    }
    @AuraEnabled
    public static existinglistdocclass deletedocuploadrecord(string docId,string applicationid){
        existinglistdocclass wrapclas = new existinglistdocclass();
        try{
            document_upload__c docupload = new document_upload__c();                     
            docupload.Id = docId;
            delete docupload;
            
            list<document_upload__c> existingdoclist = [select name,document_discription__c,required__c from document_upload__c where application__c = :applicationid 
                                                        AND 
                                                        application__c != null
                                                        AND
                                                        document_master__r.default__c=false];
            if(existingdoclist.size()>0)
                wrapclas.documentuploadlist = existingdoclist;
            
            wrapclas.msg = 'success';
            
            return wrapclas;
        }
        catch(exception e){
            existinglistdocclass wrapclasexception = new existinglistdocclass();
            wrapclasexception.msg = e.getMessage();
            return wrapclasexception;
        }
        
    }
    @Auraenabled
    public static showdocumentlink doInitUploadApex(string applicationid){
        showdocumentlink documents = new showdocumentlink();
        Map<String,String> mapdocUploadToName = new Map<String,String>();
        map<string,string> nonrequiredmapdocUploadToName = new map<string,string>();
        map<string,string> nonrequiredmapdocUploadToConDocLink  = new map<string,string>();
        string oppstage = '';
        
        system.debug('applicationid ---> ' + applicationid);
        if(String.isNotBlank(applicationid)){
            id oppid =  [select opportunity__c from case where id =:applicationid].opportunity__c;
            
            system.debug('@@@ --> ' + [SELECT Id,Name,Required__c,Document_Master__r.Name,document_discription__c,Document_Master__r.Required__c,Document_Link__c,Document_Master__c FROM Document_Upload__c WHERE (application__c ='5000p000002raJsAAI' or opportunity__c ='0060p000005o74PAAQ') order by createddate asc]);
            for(Document_Upload__c docUploadList : [SELECT Id,Name,Required__c,Document_Master__r.Name,document_discription__c,Document_Master__r.Required__c,Document_Link__c,Document_Master__c FROM Document_Upload__c WHERE (application__c =:applicationid or opportunity__c =:oppid) order by createddate asc]){ 
                
                system.debug(docUploadList.Required__c+';'+docUploadList.Name);
                if(docUploadList.Required__c) { mapdocUploadToName.put(docUploadList.Id,'* '+docUploadList.Name); 
                                               documents.mapdocUploadToConDocLink.put('* '+docUploadList.Name,docUploadList.Id);
                                               documents.linkview.put('* '+docUploadList.Name,docUploadList.Document_Link__c);
                                               documents.docdiscription.put('* '+docUploadList.Name,docUploadList.document_discription__c);
                                              }
                else{
                    nonrequiredmapdocUploadToName.put(docUploadList.Id,docUploadList.Name);  
                    nonrequiredmapdocUploadToConDocLink.put(docUploadList.Name,docUploadList.Id);
                    documents.linkview.put(docUploadList.Name,docUploadList.Document_Link__c);
                    documents.docdiscription.put(docUploadList.Name,docUploadList.document_discription__c);
                }   
            }
            for(string key : nonrequiredmapdocUploadToName.keyset()){
                mapdocUploadToName.put(key,nonrequiredmapdocUploadToName.get(key));   
            }
            for(string key : nonrequiredmapdocUploadToConDocLink.keyset()){
                documents.mapdocUploadToConDocLink.put(key,nonrequiredmapdocUploadToConDocLink.get(key));   
            }
        }        
        
        if(mapdocUploadToName != NULL && mapdocUploadToName.keySet().size() > 0){
            for(ContentDocumentLink conDocLink :[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : mapdocUploadToName.keySet()])
                documents.mapdocUploadToConDocLink.put(mapdocUploadToName.get(conDocLink.LinkedEntityId),conDocLink.LinkedEntityId+'#'+conDocLink.ContentDocumentId);                                                                             	
        }
        user usr = [select contactid from user where id=:UserInfo.getUserId()];
        if(string.isNotBlank(usr.contactid))
            documents.ismaxway=false;
        //   list<string> oppstagelist = new list<string>{'Quotation & Agreement Signed','Invoice Issued','Sales Won','Quotation Pending Approval'};
        
        // if(oppstagelist.contains(oppstage)) documents.deletedoc=true;
        
        System.debug('mapdocUploadToConDocLink-->'+documents.mapdocUploadToConDocLink);
        return documents;   
    }
    @AuraEnabled
    public static String updatedoclist(String docTypeId,string docId){
        try{
            List<Sobject> uplodDocDeleteList = new List<Sobject>();
            List<string> contentdocid = new List<string>();
            if(docTypeId != null & docId != null){
                for(ContentDocumentLink cd : [SELECT ContentDocumentId 
                                              FROM ContentDocumentLink 
                                              WHERE LinkedEntityId = :docTypeId
                                              AND  ContentDocumentId != :docId]){
                                                  contentdocid.add(cd.ContentDocumentId);
                                              }
                if(contentdocid.size() > 0){
                    for(string str : contentdocid){
                        ContentDocument conDocLink = new ContentDocument();                     
                        conDocLink.Id = str;
                        uplodDocDeleteList.add(conDocLink);  
                        system.debug('str-->'+str);
                    }
                    delete uplodDocDeleteList;    
                }
                
                return 'success';
            }
            return 'error';
        }
        catch(exception e){
            return  e.getMessage();
        }  
    }
    @AuraEnabled
    public static String deletedoc(String docTypeId,string docId){
        try{
            List<Sobject> uplodDocDeleteList = new List<Sobject>();
            ContentDocument conDocLink = new ContentDocument();                     
            conDocLink.Id = docId;
            uplodDocDeleteList.add(conDocLink);
            delete uplodDocDeleteList;
            system.debug('docTypeId-->'+docTypeId);
            system.debug('docId-->'+docId);
            return 'success';
        }
        catch(exception e){
            return  e.getMessage();
        }
        
    }
    public class showdocumentlink{
        @AuraEnabled  
        public Map<String,String> mapdocUploadToConDocLink = new Map<String,String>();
        @AuraEnabled  
        public Map<string,string> linkview = new map<string,string>();
         @AuraEnabled  
        public Map<string,string> docdiscription = new map<string,string>();
         @AuraEnabled  
        public boolean ismaxway = true;
    }
    public class existinglistdocclass{
        @AuraEnabled  
        public list<document_upload__c> documentuploadlist = new list<document_upload__c>();
        @AuraEnabled  
        public string msg ='';
    }
    public class documentlist{
        @AuraEnabled  
        public list<document_upload__c> documentuploadlist = new list<document_upload__c>();
        @AuraEnabled  
        public boolean ismaxway = true;
        @AuraEnabled  
        public list<WrapMasterDoclist> documentmasterlist = new list<WrapMasterDoclist>();
    }
    public class WrapMasterDoclist{
        @AuraEnabled  public document_master__c masterdoc = new document_master__c();
        @AuraEnabled  public boolean add =false;
        @AuraEnabled  public boolean required =false;
        
    }
    
}