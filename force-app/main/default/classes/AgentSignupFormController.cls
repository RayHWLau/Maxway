public without sharing class AgentSignupFormController {
    
    @AuraEnabled
    public static CheckVisibility checkComponentVisibility(String oppId){
        CheckVisibility checkVisibility = new CheckVisibility();
        try {
            if(String.isNotBlank(oppId)){            
                List<Opportunity> oppList = [SELECT Id,Agent_Sign_Up_Form_Sent_Date__c,Number_Of_Licence__c,Number_of_not_in_database_schools__c,Business_License_Valid_Till__c,Agent_Sign_Up_Form_Submitted_Date__c,AccountId,Number_of_Admin_Licenses__c,Portal_Admin_Email__c,Which_country_s_school_list_to_purchase__c,recordtypeid FROM Opportunity WHERE Id =:oppId AND AccountId != NULL ];                        
                if(oppList != NULL && oppList.size() > 0 && oppList[0].Agent_Sign_Up_Form_Sent_Date__c != NULL){
                    Integer difference = oppList[0].Agent_Sign_Up_Form_Sent_Date__c.daysBetween(Date.today());  
                    if(difference > Integer.valueOf(Label.CheckExpiryOfAgentSignupForm)){
                        checkVisibility.linkExpired = true;
                        checkVisibility.message = 'Expired';
                        return checkVisibility;
                    }
                    if(String.isNotBlank(String.valueOf(oppList[0].Agent_Sign_Up_Form_Submitted_Date__c))){
                        checkVisibility.alreadySubmitted = true;
                        checkVisibility.message = 'Already Submitted';
                        return checkVisibility;
                    }                                                                           
                    checkVisibility.showform = true;
                    if(String.isNotBlank(oppList[0].Which_country_s_school_list_to_purchase__c)){
                        for(string str : oppList[0].Which_country_s_school_list_to_purchase__c.split(';'))
                            checkVisibility.currencyListprepop.add(str);
                    }
                    
                    Schema.DescribeFieldResult currencyField = Account.CurrencyIsoCode.getDescribe();        
                    List<Schema.PicklistEntry> picList=currencyField.getPicklistvalues();
                    for(Schema.PicklistEntry plist:picList)
                        checkVisibility.currencyList.add(plist.getValue());
                    
                    Schema.DescribeFieldResult lastYearTNOSAField = Account.Last_Year_s_Total_Number_of_Successful_A__c.getDescribe();
                    List<Schema.PicklistEntry> rpicList=lastYearTNOSAField.getPicklistvalues();
                    for(Schema.PicklistEntry rplist:rpicList)
                        checkVisibility.lastYearTNOSTList.add(rplist.getLabel());
                    
                    Schema.DescribeFieldResult noOfBranchesField = Account.Number_of_Branches__c.getDescribe();
                    List<Schema.PicklistEntry> branchList= noOfBranchesField.getPicklistvalues();
                    for(Schema.PicklistEntry bList:branchList)
                        checkVisibility.noOfBranchesList.add(bList.getLabel());
                    
                    Schema.DescribeFieldResult countrypurchaselists = Opportunity.Which_country_s_school_list_to_purchase__c.getDescribe();
                    List<Schema.PicklistEntry> contrypurchedList= countrypurchaselists.getPicklistvalues();
                    for(Schema.PicklistEntry conpurList:contrypurchedList)
                        checkVisibility.countrypurchaselist.add(conpurList.getLabel());
                    
                    
                    List<Account> listAccount = [SELECT Referee_Institution__c,Referee_Name__c,Referee_Email__c,Number_of_Branches__c,
                                                 Last_Year_s_Total_Number_of_Successful_A__c,Bank__c,Bank_Code__c,
                                                 Bank_Address__c,Bank_Routing_or_Transit_Number__c,Bank_Account_Number__c,
                                                 Bank_Account_Holder__c,CurrencyIsoCode,SWIFT_Code__c FROM Account WHERE Id = :oppList[0].AccountId];
                    if(listAccount != NULL && listAccount.size() > 0)
                        checkVisibility.accToReturn = listAccount[0];
                    checkVisibility.oppToReturn = oppList[0];
                    checkVisibility.message = 'SUCCESS';
                    
                    Id recordTypeIdRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal -Agent Acquisition').getRecordTypeId();
                    
                    if(recordTypeIdRenewal == oppList[0].recordtypeid){
                        checkVisibility.isrenewal = true;
                    }
                    Map<String,String> mapdocUploadToName = new Map<String,String>();
                    Map<String,String> mapdocUploadToConDocLink = new Map<String,String>(); 
                    map<string,string> nonrequiredmapdocUploadToName = new map<string,string>();
                    map<string,string> nonrequiredmapdocUploadToConDocLink  = new map<string,string>();
                    for(Document_Upload__c docUploadList : [SELECT Id,Name,Document_Master__r.Name,Document_Master__r.Required__c FROM Document_Upload__c WHERE Opportunity__c =:oppId AND Document_Master__c != NULL AND Process__c ='Agent Signup Form']){
                        system.debug('docUploadList1st-->'+docUploadList);
                        if(docUploadList.Document_Master__r.Required__c==true) { 
                            mapdocUploadToName.put(docUploadList.Id,'* '+docUploadList.Document_Master__r.Name); 
                            checkVisibility.mapdocUploadToConDocLink.put('* '+docUploadList.Document_Master__r.Name,docUploadList.Id);
                        }
                        else{
                            nonrequiredmapdocUploadToName.put(docUploadList.Id,docUploadList.Document_Master__r.Name);  
                            nonrequiredmapdocUploadToConDocLink.put(docUploadList.Document_Master__r.Name,docUploadList.Id);
                        }                        
                    }
                    for(string key : nonrequiredmapdocUploadToName.keyset()){
                        mapdocUploadToName.put(key,nonrequiredmapdocUploadToName.get(key));   
                    }
                    for(string key : nonrequiredmapdocUploadToConDocLink.keyset()){
                        system.debug('checkVisibility.mapdocUploadToConDocLink-->11'+checkVisibility.mapdocUploadToConDocLink);
                        checkVisibility.mapdocUploadToConDocLink.put(key,nonrequiredmapdocUploadToConDocLink.get(key));   
                    }
                    
                    
                    
                    if(mapdocUploadToName != NULL && mapdocUploadToName.keySet().size() > 0){
                        for(ContentDocumentLink conDocLink :[SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN : mapdocUploadToName.keySet()])
                        {checkVisibility.mapdocUploadToConDocLink.put(mapdocUploadToName.get(conDocLink.LinkedEntityId),conDocLink.LinkedEntityId+'#'+conDocLink.ContentDocumentId);
                         system.debug('checkVisibility.mapdocUploadToConDocLink-->'+checkVisibility.mapdocUploadToConDocLink);}                                                                             	
                    } 
                    
                }
                else
                    checkVisibility.message = Label.AgentReferenceNoOppFound;  
            }
            else {
                checkVisibility.message = Label.OppIdNotBlank;
            }
        }
        catch(Exception e) {
            checkVisibility.message = e.getMessage();    
        }
        System.debug('checkVisibility.mapdocUploadToConDocLink-->'+checkVisibility.mapdocUploadToConDocLink);
        return checkVisibility;
    }
    
    @AuraEnabled 
    public Static String saveAsDraftApex(String oppId,String acc,String buttonLabel,string uploadList,String idandfilename,string opp,list<string> countrypurchasedlist){       
        try{   
            
            List<Sobject> uplodDocDeleteList = new List<Sobject>();
            Map<String,ContentVersion> mapLinkEntityIdToContentVersion = new Map<String,ContentVersion>();
            Map<String,String> mapcontentVersionIdToLinkEntityId = new Map<String,String>();
            List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
            
            String str = 'SUCCESS';
            list<string> receivedfilelist = (List<string>)(JSON.deserialize(uploadList,List<string>.class)); 
            List<receivedUploadListWrapper> receivedUploadListnameandid = (List<receivedUploadListWrapper>)(JSON.deserialize(idandfilename,List<receivedUploadListWrapper>.class));                        
            //******************************to delete already inserted notes and attachments**********************************************
            if(receivedUploadListnameandid != NULL && receivedUploadListnameandid.size() > 0 && receivedfilelist != NULL && receivedfilelist.size() > 0){
                for(receivedUploadListWrapper recUpld : receivedUploadListnameandid){
                    system.debug('recUpldkey-->'+recUpld.key);
                    if(recUpld.key.contains('#')){
                        ContentDocument conDocLink = new ContentDocument();                     
                        conDocLink.Id = recUpld.key.split('#')[1];
                        uplodDocDeleteList.add(conDocLink);
                    }                                
                }
            }
            
            if(uplodDocDeleteList != NULL && uplodDocDeleteList.size() > 0){
                database.delete(uplodDocDeleteList,false);
            }
            //****************************************************************************************************************************************************************************************************************        
            //***********************************************To Insert Notes And Attachment For Respective Document Upload****************************************************************************************************
            if(receivedUploadListnameandid != NULL && receivedUploadListnameandid.size() > 0  && receivedfilelist != NULL && receivedfilelist.size() > 0){
                system.debug('receivedUploadListnameandid.size()-->'+receivedUploadListnameandid.size());
                for(integer i=0; i<receivedUploadListnameandid.size(); i++){
                    System.debug('recUpld-->'+receivedUploadListnameandid[i]);
                    System.debug('recUpld-->'+receivedfilelist[i]);
                    ContentVersion content =new ContentVersion(); 
                    content.Title = receivedUploadListnameandid[i].fileName; 
                    // List<String> dataencode = receivedfilelist[0].split(',');
                    // if(dataencode != NULL && dataencode.size() >= 2)
                    content.VersionData=EncodingUtil.base64Decode(receivedfilelist[i]);                        
                    content.PathOnClient= '/' + receivedUploadListnameandid[i].fileName; 
                    
                    if(receivedUploadListnameandid[0].Key.contains('#')){
                        System.debug('recUpld-->'+receivedUploadListnameandid[i].key);
                        mapLinkEntityIdTOcontentVersion.put(receivedUploadListnameandid[i].key.split('#')[0],content);
                        System.debug('contentDocumentLinkToInsert-->'+receivedUploadListnameandid[i].key.split('#')[0]);
                        System.debug('contentDocumentLinkToInsert-->'+content);}
                    else
                    { 
                        mapLinkEntityIdTOcontentVersion.put(receivedUploadListnameandid[i].key,content);  
                        System.debug('contentDocumentLinkToInsert-->'+receivedUploadListnameandid[i].key);
                    } 
                }
                
            }
            
            if(mapLinkEntityIdTOcontentVersion != NULL && mapLinkEntityIdTOcontentVersion.keySet().size() > 0){
                database.insert(mapLinkEntityIdTOcontentVersion.values(),false);                                
                for(String conVer : mapLinkEntityIdTOcontentVersion.keySet()){  
                    System.debug('contentDocumentLinkToInsert-->'+mapLinkEntityIdTOcontentVersion.get(conVer).Id);
                    mapcontentVersionIdToLinkEntityId.put(mapLinkEntityIdTOcontentVersion.get(conVer).Id,conVer);
                }
            }                        
            
            If(mapcontentVersionIdToLinkEntityId != NULL && mapcontentVersionIdToLinkEntityId.keySet().size() > 0){
                for(ContentVersion conVer : [select id,ContentDocumentId from ContentVersion WHERE Id IN : mapcontentVersionIdToLinkEntityId.keySet()]){
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = conVer.ContentDocumentId;
                    cl.LinkedEntityId = mapcontentVersionIdToLinkEntityId.get(conVer.Id); 
                    cl.ShareType = 'V';                    
                    contentDocumentLinkToInsert.add(cl);
                }                
            }
            System.debug('contentDocumentLinkToInsert-->'+contentDocumentLinkToInsert);
            if(contentDocumentLinkToInsert != NULL && contentDocumentLinkToInsert.size() > 0)
                database.insert(contentDocumentLinkToInsert,false); 
            //******************************************************************************************************************************************************************************************************************            
            
            //********************************************To Update Parent Account & Opportunity********************************************************************************************************************************
            Id recordTypeIdRenewal = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Renewal -Agent Acquisition').getRecordTypeId();
            List<Opportunity> oppList = [SELECT AccountId,recordtypeid,Number_Of_Licence__c,Number_of_not_in_database_schools__c,Which_country_s_school_list_to_purchase__c,Agent_Sign_Up_Form_Submitted_Date__c,Referee_Institution__c,Refree_Email__c,Refree_Name__c FROM Opportunity WHERE Id =:oppId AND AccountId != NULL];
            system.debug('oppList-->'+oppList);
            String countryStr = '';
            for(String countr : countrypurchasedlist){
                countryStr += countr + ';';}
            system.debug('countryStr-->>'+countryStr);
            countryStr = countryStr.removeEnd(';');
            if(oppList != NULL && oppList.size() > 0){                                
                if(buttonLabel == 'Submit'){
                    oppList[0].Agent_Sign_Up_Form_Submitted_Date__c = Date.today();                    
                } 
                if(string.isNotBlank(acc) && string.isNotBlank(opp)){
                    
                    opportunity opportunityrecord = (Opportunity)JSON.deserialize(opp,Opportunity.class);
                    
                    system.debug('opportunityrecord-->'+opportunityrecord);
                    
                    if(recordTypeIdRenewal != oppList[0].recordtypeid){
                        
                        Account account = (Account)JSON.deserialize(acc,Account.class); 
                        system.debug('account-->'+account);
                        account.Id = oppList[0].AccountId;            
                        database.update(account,false);
                        if(account.Referee_Institution__c!= null) oppList[0].Referee_Institution__c = account.Referee_Institution__c;
                        if(account.Referee_Name__c!= null) oppList[0].Refree_Name__c = account.Referee_Name__c;
                        if(account.Referee_Email__c!= null) oppList[0].Refree_Email__c = account.Referee_Email__c;
                    }
                    
                    system.debug('oppList[0].Refree_Email__c-->'+oppList[0].Refree_Email__c);                   
                    if(opportunityrecord.Business_License_Valid_Till__c != null)  oppList[0].Business_License_Valid_Till__c = opportunityrecord.Business_License_Valid_Till__c;
                    if(opportunityrecord.Number_Of_Licence__c != null)  oppList[0].Number_Of_Licence__c = opportunityrecord.Number_Of_Licence__c;
                    if(opportunityrecord.Number_of_Admin_Licenses__c != null)  oppList[0].Number_of_Admin_Licenses__c = opportunityrecord.Number_of_Admin_Licenses__c;
                    if(opportunityrecord.Portal_Admin_Email__c != null)  oppList[0].Portal_Admin_Email__c = opportunityrecord.Portal_Admin_Email__c;
                    oppList[0].Which_country_s_school_list_to_purchase__c = countryStr;
                    update oppList[0];
                }
                
            }                        
            return str;
        }
        catch(Exception e){            
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static showdocumentlink doInitUploadApex(String opportunityId){  
        showdocumentlink documents = new showdocumentlink();
        Map<String,String> mapdocUploadToName = new Map<String,String>();
        map<string,string> nonrequiredmapdocUploadToName = new map<string,string>();
        map<string,string> nonrequiredmapdocUploadToConDocLink  = new map<string,string>();
        string oppstage = '';
        
        if(String.isNotBlank(opportunityId)){
            for(Document_Upload__c docUploadList : [SELECT Id,Name,Document_Master__r.Name,Document_Master__r.Required__c,Document_Master__r.corresponding_stage__c,Document_Link__c,opportunity__r.stagename FROM Document_Upload__c WHERE Opportunity__c =:opportunityId AND Document_Master__c != NULL ]){
                oppstage =  docUploadList.opportunity__r.stagename; 
                if(docUploadList.Document_Master__r.Required__c==true) { mapdocUploadToName.put(docUploadList.Id,'* '+docUploadList.Document_Master__r.Name); 
                                                                        documents.mapdocUploadToConDocLink.put('* '+docUploadList.Document_Master__r.Name,docUploadList.Id);
                                                                        documents.linkview.put('* '+docUploadList.Document_Master__r.Name,docUploadList.Document_Link__c);
                                                                        documents.ProcessDisplay.put('* '+docUploadList.Document_Master__r.Name,docUploadList.Document_Master__r.corresponding_stage__c);
                                                                       }
                else{
                    nonrequiredmapdocUploadToName.put(docUploadList.Id,docUploadList.Document_Master__r.Name);  
                    nonrequiredmapdocUploadToConDocLink.put(docUploadList.Document_Master__r.Name,docUploadList.Id);
                    documents.linkview.put(docUploadList.Document_Master__r.Name,docUploadList.Document_Link__c);
                    documents.ProcessDisplay.put(docUploadList.Document_Master__r.Name,docUploadList.Document_Master__r.corresponding_stage__c);
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
        list<string> oppstagelist = new list<string>{'Quotation & Agreement Signed','Invoice Issued','Sales Won','Quotation Pending Approval'};
            
            if(oppstagelist.contains(oppstage)) documents.deletedoc=true;
        
        System.debug('mapdocUploadToConDocLink-->'+documents.mapdocUploadToConDocLink);
        return documents;
    }
    
    @AuraEnabled
    public static String saveUploadDocFromChildComp(String uploadList,String idandfilename){
        system.debug('uploadList-->'+uploadList);
        try{               
            List<Sobject> uplodDocDeleteList = new List<Sobject>();
            Map<String,ContentVersion> mapLinkEntityIdToContentVersion = new Map<String,ContentVersion>();
            Map<String,String> mapcontentVersionIdToLinkEntityId = new Map<String,String>();
            List<ContentDocumentLink> contentDocumentLinkToInsert = new List<ContentDocumentLink>();
            
            String str = 'SUCCESS';
            List<string> base64datalist = (List<string>)(JSON.deserialize(uploadList,List<string>.class));
            List<receivedUploadListWrapper> receivedUploadListnameandid = (List<receivedUploadListWrapper>)(JSON.deserialize(idandfilename,List<receivedUploadListWrapper>.class));                        
            
            //******************************to delete already inserted notes and attachments**********************************************
            if(receivedUploadListnameandid != NULL && receivedUploadListnameandid.size() > 0 && base64datalist != NULL && base64datalist.size() > 0){
                for(receivedUploadListWrapper recUpld : receivedUploadListnameandid){
                    if(recUpld.key.contains('#')){
                        ContentDocument conDocLink = new ContentDocument();                     
                        conDocLink.Id = recUpld.key.split('#')[1];
                        uplodDocDeleteList.add(conDocLink);
                    }                                
                }
            }
            
            if(uplodDocDeleteList != NULL && uplodDocDeleteList.size() > 0){
                database.delete(uplodDocDeleteList,false);
            }
            //****************************************************************************************************************************************************************************************************************        
            //***********************************************To Insert Notes And Attachment For Respective Document Upload****************************************************************************************************
            if(receivedUploadListnameandid != NULL && receivedUploadListnameandid.size() > 0  && base64datalist != NULL && base64datalist.size() > 0){
                system.debug('receivedUploadListnameandid.size()-->'+receivedUploadListnameandid.size());
                for(integer i=0; i<receivedUploadListnameandid.size(); i++){
                    System.debug('recUpld-->'+receivedUploadListnameandid[0]);
                    ContentVersion content =new ContentVersion(); 
                    content.Title = receivedUploadListnameandid[0].fileName; 
                    List<String> dataencode = base64datalist[0].split(',');
                    if(dataencode != NULL && dataencode.size() >= 2)
                        content.VersionData=EncodingUtil.base64Decode(dataencode[1]);                        
                    content.PathOnClient= '/' + receivedUploadListnameandid[0].fileName; 
                    
                    if(receivedUploadListnameandid[0].Key.contains('#')){
                        System.debug('recUpld-->'+receivedUploadListnameandid[0].key);
                        mapLinkEntityIdTOcontentVersion.put(receivedUploadListnameandid[0].key.split('#')[0],content);
                        System.debug('contentDocumentLinkToInsert-->'+receivedUploadListnameandid[0].key.split('#')[0]);
                        System.debug('contentDocumentLinkToInsert-->'+content);}
                    else
                    { 
                        mapLinkEntityIdTOcontentVersion.put(receivedUploadListnameandid[0].key,content);  
                        System.debug('contentDocumentLinkToInsert-->'+receivedUploadListnameandid[0].key);
                    }
                }
                
            }
            
            if(mapLinkEntityIdTOcontentVersion != NULL && mapLinkEntityIdTOcontentVersion.keySet().size() > 0){
                database.insert(mapLinkEntityIdTOcontentVersion.values(),false);                                
                for(String conVer : mapLinkEntityIdTOcontentVersion.keySet()){  
                    System.debug('contentDocumentLinkToInsert-->'+mapLinkEntityIdTOcontentVersion.get(conVer).Id);
                    mapcontentVersionIdToLinkEntityId.put(mapLinkEntityIdTOcontentVersion.get(conVer).Id,conVer);
                }
            }                        
            
            If(mapcontentVersionIdToLinkEntityId != NULL && mapcontentVersionIdToLinkEntityId.keySet().size() > 0){
                for(ContentVersion conVer : [select id,ContentDocumentId from ContentVersion WHERE Id IN : mapcontentVersionIdToLinkEntityId.keySet()]){
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = conVer.ContentDocumentId;
                    cl.LinkedEntityId = mapcontentVersionIdToLinkEntityId.get(conVer.Id); 
                    cl.ShareType = 'V';                    
                    contentDocumentLinkToInsert.add(cl);
                }                
            }
            System.debug('contentDocumentLinkToInsert-->'+contentDocumentLinkToInsert);
            if(contentDocumentLinkToInsert != NULL && contentDocumentLinkToInsert.size() > 0)
                database.insert(contentDocumentLinkToInsert,false);
            //******************************************************************************************************************************************************************************************************************                                    
            return str;
        }
        catch(Exception e){
			system.debug('error->'+ e.getMessage());            
            return e.getMessage();
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
    @AuraEnabled
    public static String updatedoclist(String docTypeId,string docId,string businessdatecheck){
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
                if(businessdatecheck != null){
                    List<document_upload__c> docupload = [Select opportunity__r.Business_License_Valid_Till__c from document_upload__c where
                                                          id = :docTypeId];
                    if(docupload.size()>0 && docupload[0].opportunity__r.Business_License_Valid_Till__c != null)
                        return 'business#'+string.valueof(docupload[0].opportunity__r.Business_License_Valid_Till__c);      
                    return 'success';  
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
    public static string businesslicenceupdate(string oppid,date businessdate){
        try{
            opportunity opp = new opportunity();
            opp.id = oppid;
            opp.Business_License_Valid_Till__c =businessdate ;
            update opp;
            return 'success';
        }
        catch(exception e){
            return  e.getMessage();
        } 
        
    }
    
    public class CheckVisibility {
        @AuraEnabled 
        public Boolean linkExpired = false;
        @AuraEnabled 
        public Boolean alreadySubmitted = false;
        @AuraEnabled 
        public Boolean showform = false;
        @AuraEnabled   
        public List<String> noOfBranchesList = new List<String>();
        @AuraEnabled  
        public List<String> lastYearTNOSTList = new List<String>();
        @AuraEnabled  
        public List<String> countrypurchaselist = new List<String>();
        @AuraEnabled
        public Map<String,String> mapdocUploadToConDocLink = new Map<String,String>();
        @AuraEnabled  
        public List<String> currencyList = new List<string>();
        @AuraEnabled  
        public List<String> currencyListprepop = new List<string>();
        @AuraEnabled public Account accToReturn = new Account();
        @AuraEnabled public Opportunity oppToReturn = new Opportunity();
        @AuraEnabled public String message = '';
        @AuraEnabled public boolean isrenewal = false;
    }            
    
    public class receivedUploadListWrapper{
        public String key = '';
        public String filename = '';
        
    }
    public class receivedfile{
        public String b = '';
        
    }
    public class showdocumentlink{
        @AuraEnabled  
        public Map<String,String> mapdocUploadToConDocLink = new Map<String,String>();
        @AuraEnabled  
        public Map<string,string> linkview = new map<string,string>();
        @AuraEnabled
        public Map<string,string> ProcessDisplay = new Map<string,string>();
        @AuraEnabled
        public boolean deletedoc = false;
    }
}