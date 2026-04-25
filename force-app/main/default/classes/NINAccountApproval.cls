public class NINAccountApproval {
    @AuraEnabled
    public  static wrappercls returnprice(Id objectid){
        
        wrappercls wrap = new wrappercls();
        list<ContentDocumentLink> conDocLink = new list<ContentDocumentLink>();
        Set<string> SetReqdocIds = new Set<string>();
        Schema.SObjectType objtype = objectid.getsobjecttype();
        list<case> caselist = new list<case>();
        
        map<string,string> mapwithobjectnameandfieldandtarriftype = new map<string,string>();
        mapwithobjectnameandfieldandtarriftype.put('Account','NIN__c;School Account Creation');
        mapwithobjectnameandfieldandtarriftype.put('Case','Required_Document_Upload__c;Application Creation');
        
        if(mapwithobjectnameandfieldandtarriftype.containskey(string.valueOf(objtype))){
            
            string[] rrequireddetails = mapwithobjectnameandfieldandtarriftype.get(string.valueOf(objtype)).split(';');
            string str = 'select approval_status__c,'+rrequireddetails[0]+' from '+string.valueOf(objtype)+' where id = :objectid';
            
            if(string.valueOf(objtype)=='Case'){
                
                Case cse = [select opportunity__c,opportunity__r.StageName from case where id =:objectid]; //19 may 2020 removed ,'Pending Arrival'
                caselist = [Select id from case where opportunity__c =:cse.opportunity__c AND Status in ('Commission Paid','Commission Received','Arrived')];//Stage__c in ('Commission Paid','Commission Received','Arrived','Pending Arrival')
                for(Document_Upload__c docUpld : [SELECT ID,Application__c, Required__c FROM Document_Upload__c WHERE (Application__c =:objectid or opportunity__c =:cse.opportunity__c) AND Required__c = True ])
                {
                                                      SetReqdocIds.add(docUpld.Id);
                                                  }
                if(SetReqdocIds.size()>0)
                    conDocLink = [SELECT Id,ContentDocumentId,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :SetReqdocIds];
            }
            
            sobject acc = Database.query(str);
            
            boolean nin = False;
            
            if(string.valueOf(objtype)=='Account'){
                SetReqdocIds.add('topasscheck');
                
                if((string) acc.get('NIN__c') == 'Yes'){
                    nin = True;    
                }
                
            }
            
            if( string.valueOf(objtype)=='Case' && caselist.size()>0){
                wrap.msg = 'Cannot submit this application for approval, as there is another application with status Commission Paid/Commission Received/Arrived within same opportunity.';  //changed on 15  may 2020 Cannot send Case for approval//19 may 2020 removed /Pending Arrival
                return wrap;
            }
            else{
                
                if(nin == True || SetReqdocIds.size() == conDocLink.size()){
                    
                    if(string.isBlank((string) acc.get('approval_status__c')) || (string) acc.get('approval_status__c') == 'Rejected'){
                        
                        User u = [select contactid from user where id = :UserInfo.getUserId() and contactid != null];
                        
                        if(string.isNotBlank(u.contactid)){
                            
                            Contact con = [select accountid,CurrencyIsoCode from contact where id =:u.contactid ];
                            
                            wrap.schoolcurrency = con.CurrencyIsoCode;
                            
                            if(string.isNotBlank(con.accountid)){
                                
                                Id recordTypeIdUsage = Schema.SObjectType.Contract_Item__c.getRecordTypeInfosByName().get('Usage').getRecordTypeId();
                                list<Contract_Item__c> contractitem = [select id, Unit_Price__c,CurrencyIsoCode,Opt_In__c,Contract__r.accountid,Tariff_Type__c from Contract_Item__c 
                                                                       where 
                                                                       Contract__r.accountid = :con.accountid 
                                                                       and recordtypeid = :recordTypeIdUsage
                                                                       and Tariff_Type__c= :rrequireddetails[1]
                                                                       and contract__r.enddate>today];
                                
                                if(contractitem.size()>0){ 
                                    if(string.valueOf(objtype)=='Account'){
                                        account updateaccount = new account();
                                        updateaccount.id = objectid;
                                        updateaccount.Deny_Reason__c = '';
                                        update updateaccount;
                                    }
                                    wrap.msg = string.valueof(contractitem[0].Unit_Price__c);
                                    
                                    //added changes on 17 March 2020
                                    //Now Currency will be shown from the Contact Item and amount will be shown on the basis of the Object type on wrap.schoolcurrency
                                    
                                    if( String.isNotBlank( contractitem[0].CurrencyIsoCode ) && contractitem[0].CurrencyIsoCode.contains('-') ){
                                        
                                        wrap.schoolcurrency = contractitem[0].CurrencyIsoCode.split('-')[0].trim();
                                        
                                    }else if ( String.isNotBlank( contractitem[0].CurrencyIsoCode )  ){
                                        
                                        wrap.schoolcurrency = contractitem[0].CurrencyIsoCode;
                                    }
                                    //incase of case( opt-out ) 
                                    if( string.valueOf(objtype)=='Case' ){
                                        
                                        wrap.msg = string.valueof(contractitem[0].Opt_In__c);
                                        
                                        if( String.isBlank( wrap.msg ))
                                            wrap.msg = '0';
                                    }
                                    
                                    //END changes on 17 March 2020
                                    return wrap;
                                    
                                }
                                wrap.msg = 'No Contract Item Found';
                                return wrap;
                            }   
                        }
                        return null;   
                    }
                    wrap.msg = 'Either Account has been already apprroved or pending for approval';
                    return wrap;
                }
                if(string.valueOf(objtype)=='Account') wrap.msg = 'Cannot send school for approval';
                if(string.valueOf(objtype)=='Case') wrap.msg = 'Please upload required document first';
                
                return wrap;  
            }
        }
        return null;
    }
    @AuraEnabled
    public  static string lightningapproval(Id accid){
        try{
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(accid);
            Approval.ProcessResult result = Approval.process(req1);
            return 'SUCCESS';
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    public  class wrappercls{
        @Auraenabled
        public string schoolcurrency='';
        @Auraenabled
        public string msg = '';
    }
}