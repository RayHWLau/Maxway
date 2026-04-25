//component -->  AddinvoiceItems
public class InvoiceLineItem {
    @AuraEnabled
    //changed method name used in doinit
    //3 May 2020 changed the visiblity logic of the Application's( Case ) as per maxway and agent user. 
    public static  list<appwrapper> getarrivedapplication(id recordid){
        
        //added on 3rd may 2020
        //checking the current user profile 
        list< AddInvoiceLineItemComp__mdt > listMetaData = [SELECT Id, Maxway_Profile_Name__c, Agent_Profile_Name__c, ApplicationType1__c, ApplicationType2__c, ApplicationType3__c, ApplicationType4__c, ApplicationStage1__c, ApplicationStage2__c, InvoiceType1__c, InvoiceSchoolRecTypeName__c, InvoiceAgentRecTypeName__c, InvoiceStatus__c, InvoiceLineItemRecType__c, ApplicationRecType1__c, ApplicationRecType2__c 
                                                            FROM AddInvoiceLineItemComp__mdt
                                                            WHERE MasterLabel = 'InvoiceMetaData' LIMIT 1 ];
        
        set< string > setMaxwayProfileCheck = new set< string >();
        set< string > setAgentProfileCheck = new set< string >();
        
        if( String.isNotBlank( listMetaData[0].Maxway_Profile_Name__c ) ){
            
            if( listMetaData[0].Maxway_Profile_Name__c.contains(',') ){
                
                setMaxwayProfileCheck.addAll( listMetaData[0].Maxway_Profile_Name__c.split(',') );
            }else{
                setMaxwayProfileCheck.add( listMetaData[0].Maxway_Profile_Name__c );
            }
        } 
        
        if( String.isNotBlank( listMetaData[0].Agent_Profile_Name__c ) ){
            
            if( listMetaData[0].Agent_Profile_Name__c.contains(',') ){
                
                setAgentProfileCheck.addAll( listMetaData[0].Agent_Profile_Name__c.split(',') );
            }else{
                setAgentProfileCheck.add( listMetaData[0].Agent_Profile_Name__c );
            }  
        } 
            
        for( Profile objProfile : [ SELECT Id, Name 
                                   FROM Profile 
                                   WHERE Name IN: setMaxwayProfileCheck OR Name IN: setAgentProfileCheck ]){
            
                                       if( setMaxwayProfileCheck.contains( objProfile.Name )){
                                           
                                          setMaxwayProfileCheck.add(objProfile.Id );  
                                       }else if ( setAgentProfileCheck.contains( objProfile.Name ) ) {
                                           
                                           setAgentProfileCheck.add(objProfile.Id ); 
                                       }
        }
        //end 3 may 2020 
        
        list<appwrapper> wraplist = new list<appwrapper>();
        Id devschoolRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get( listMetaData[0].InvoiceSchoolRecTypeName__c ).getRecordTypeId();
        Id devagentRecordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get( listMetaData[0].InvoiceAgentRecTypeName__c ).getRecordTypeId();
        System.debug('devschoolRecordTypeId+++++++++'+devschoolRecordTypeId);
        System.debug('devagentRecordTypeId=========='+devagentRecordTypeId);
         System.debug('recordid==========>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+recordid);
        list<Invoice__c> invoice = [select company_name__c,CurrencyIsoCode,recordtypeid,Account__c,invoice_type__c from Invoice__c where id = :recordid and Status__c='Issued'];
        System.debug('invoice****************'+invoice);
        System.debug('invoice[0].recordtypeid=====================>>>>>>>&&&&&&&'+invoice[0].recordtypeid);
        System.debug('invoice[0].invoice_type__c++++++++++>>>>>>>'+invoice[0].invoice_type__c);
        System.debug('listMetaData[0].InvoiceType1__c===============>>>>>>>>'+listMetaData[0].InvoiceType1__c);
        System.debug(' invoice[0].company_name__c+++++++++++==========>>>>>>'+ invoice[0].company_name__c);
        //-----------------------------------------------------  Agent Invoice -----------------------------------------------------------------------------
        if(invoice.size()>0 && invoice[0].recordtypeid==devagentRecordTypeId && invoice[0].invoice_type__c == listMetaData[0].InvoiceType1__c
           &&  invoice[0].company_name__c != null){
               
               //3 May 2020 partner user cannot create invoice with Agent Record type
               if( setAgentProfileCheck.contains( UserInfo.getProfileId() )) return wraplist;
               
               set<id> userids = new set<id>();
               
               for(user u : [select id from user where accountid = :invoice[0].company_name__c]){
                   userids.add(u.id); 
                   
               }
              
               
               if(userids.size()>0){
                   
                   /*commented on 24 april 2020for(case caselist : [select id,stage__c,CaseNumber from case where ownerid in :userids and stage__c='Arrived']){appwrapper app = new appwrapper(); app.appnumber=caselist.CaseNumber;app.appid=caselist.id;wraplist.add(app);}*/
                   
                   //if record type is "agent" then all the case with record type "Commission Received" should come up.
                   for(case caselist : [ SELECT  Id,Student__r.Student_ID__c,Student__r.Name,Opportunity__r.Name,Opportunity__r.StageName,
                                        ( SELECT Id,Invoice__c,Amount__c,Invoice__r.RecordTypeId FROM Invoice_Line_Items__r),
                                        Status,CaseNumber,Application_Type__c,RecordType.DeveloperName,Commission__c 
                                        FROM case WHERE ownerid in :userids AND Status =: listMetaData[0].ApplicationStage1__c ]){ //stage__c='Arrived' chaneged at 27 april 2020
                                            
                                            boolean isCaseValidtoShow = false;
                                            Invoice_Line_Item__c objExistInvLiine = Null; 
                                            
                                            //added on 3 may 2020
                                            //Maxway user can only create invoice if its Agent record Type and application rec type = Opt-In and Application type = Opt-In
                                            if( caselist.RecordType.DeveloperName == listMetaData[0].ApplicationRecType1__c &&
                                               caseList.Application_Type__c == listMetaData[0].ApplicationType4__c ){
                                                   
                                                   //checking as with which invoice this case is linked with
                                            if( caselist.Invoice_Line_Items__r.size() > 0 ){
                                                
                                                for( Invoice_Line_Item__c objInvLine : caselist.Invoice_Line_Items__r ){
                                                    
                                                    //not linked with current inv and its's record type is agent that means this case is linked iwth other invoice, then skip
                                                    //6 May 2020 as application can have more than one invoice and still need to see
                                                    /*if( String.isNotBlank( objInvLine.Invoice__c ) && ( objInvLine.Invoice__c != recordid && 
                                                                                                       objInvLine.Invoice__r.RecordTypeId == devagentRecordTypeId )){ 
                                                                                                           isCaseValidtoShow = false;
                                                                                                           break; }
                                                    */
                                                    //if linked with current invoice then fetch its invoice line item and at a time only one invoice is ther
                                                    if( String.isNotBlank( objInvLine.Invoice__c ) && objInvLine.Invoice__c == recordid && objInvLine.Invoice__r.RecordTypeId == devagentRecordTypeId){
                                                        isCaseValidtoShow = true;
                                                        objExistInvLiine = objInvLine;
                                                        break;
                                                    }
                                                    
                                                    
                                                }//end of invoice line item loop
                                            }// end of invoice line item check
                                            
                                            //6 may 2020 as now other invoice can also add these application
                                           // if( !isCaseValidtoShow ) continue;   //incase if this case is not linked to current invoice ,then skip it.
                                            
                                            //showing current application ( Case ) in UI
                                            appwrapper app = new appwrapper(); 
                                            app.appnumber=caselist.CaseNumber;
                                            app.appid=caselist.id;
                                            app.studentId = caselist.Student__r.Student_ID__c;
                                            app.studentName = caselist.Student__r.Name;
                                            app.opportunityStage = caselist.Opportunity__r.StageName;
                                            app.opportunityName = caselist.Opportunity__r.Name;
                                            app.applicationStage = caselist.Status;
                                            app.curency = invoice[0].CurrencyIsoCode;
                                            app.commission = caselist.Commission__c;
                                            app.existInvLineId = '';
                                            
                                            if( objExistInvLiine != Null ){
                                                
                                                app.amount = String.valueOf( objExistInvLiine.Amount__c );
                                                app.existInvLineId = objExistInvLiine.Id;
                                            }
                                            wraplist.add(app);
                                                   
                                               }//end of maxway user check
                                            
                                            //end 3 may 2020
                                        }//end of case list
                   return wraplist;
               }//end of userId check
               
               return null; //incase no user was found
           }//end of agent invoice
        
        //---------------------------------------------  School Invoice  ----------------------------------------------------------------------------------
        if(invoice.size()>0 && invoice[0].recordtypeid==devschoolRecordTypeId && invoice[0].Account__c != null){
            
            /*commented on 24 april 2020* for(case caselist : [select id,stage__c,CaseNumber,School__c from case where School__c = :invoice[0].Account__c and stage__c='Arrived']){appwrapper app = new appwrapper(); app.appnumber=caselist.CaseNumber;app.appid=caselist.id;wraplist.add(app);}*/
            
            //27 april 2020 If Invoice record type is school then all the Case with status "Arrived" should come up
            for(case caselist : [ SELECT id,Student__r.Student_ID__c,Student__r.Name,Opportunity__r.Name,Opportunity__r.StageName,
                                 ( SELECT Id,Invoice__c,Invoice__r.RecordTypeId,Amount__c FROM Invoice_Line_Items__r ),
                                 Status,Application_Type__c,RecordType.DeveloperName, CaseNumber,School__c,Commission__c 
                                 FROM case WHERE School__c = :invoice[0].Account__c and Status =: listMetaData[0].ApplicationStage2__c ]){	//stage__c='Arrived' chaneged at 27 april 2020
                                     
                                     system.debug('recordid --> '+ recordid);
                                     system.debug('caselist --> ' + caselist);
                                     system.debug('caselist.Invoice_Line_Items__r --> ' + caselist.Invoice_Line_Items__r);
                                     
                                     //added on 3 may 2020
                                     if( ( setMaxwayProfileCheck.contains( Userinfo.getProfileId() ) && ( ( caseList.RecordType.DeveloperName == listMetaData[0].ApplicationRecType2__c && caseList.Application_Type__c == listMetaData[0].ApplicationType3__c ) || ( caseList.RecordType.DeveloperName == listMetaData[0].ApplicationRecType1__c && caseList.Application_Type__c == listMetaData[0].ApplicationType4__c  ) ))
                                        || ( setAgentProfileCheck.contains( Userinfo.getProfileId() ) &&  caseList.RecordType.DeveloperName == listMetaData[0].ApplicationRecType2__c && caseList.Application_Type__c == listMetaData[0].ApplicationType2__c )){
                                            
                                            
                                             boolean isCaseValidtoShow = false;
                                     Invoice_Line_Item__c objExistInvLiine = Null; 
                                     
                                     //checking as with which invoice this case is linked with
                                     if( caselist.Invoice_Line_Items__r.size() > 0 ){
                                         
                                         for( Invoice_Line_Item__c objInvLine : caselist.Invoice_Line_Items__r ){
                                             
                                             //not linked with current inv and its's record type is school that means this case is linked iwth other invoice, then skip
                                             //6 May 2020 as application can have more than one invoice and still need to see
                                             /*if( String.isNotBlank( objInvLine.Invoice__c ) && ( objInvLine.Invoice__c != recordid && 
                                                                                                objInvLine.Invoice__r.RecordTypeId == devschoolRecordTypeId )){ 
                                                                                                    isCaseValidtoShow = false;
                                                                                                    break; }*/
                                             
                                             //if linked with current invoice then fetch its invoice line item
                                             if( String.isNotBlank( objInvLine.Invoice__c ) && objInvLine.Invoice__c == recordid ){
                                                 isCaseValidtoShow = true;
                                                 objExistInvLiine = objInvLine;
                                                 break;
                                             }
                                             
                                         }//end of invoice line item loop
                                     }// end of invoice line item check
                                     
                                     //6 may 2020 as now other invoice can also add these application
                                     //if( !isCaseValidtoShow ) continue;   //incase if this case is not linked to current invoice ,then skip it.
                                     
                                     //showing current application ( Case ) in UI
                                     appwrapper app = new appwrapper(); 
                                     app.appnumber=caselist.CaseNumber;
                                     app.appid=caselist.id;
                                     app.studentId = caselist.Student__r.Student_ID__c;
                                     app.studentName = caselist.Student__r.Name;
                                     app.opportunityStage = caselist.Opportunity__r.StageName;
                                     app.opportunityName = caselist.Opportunity__r.Name;
                                     app.applicationStage = caselist.Status;
                                     app.curency = invoice[0].CurrencyIsoCode;
                                     app.commission = caselist.Commission__c;  
                                     app.existInvLineId = '';
                                     
                                     if( objExistInvLiine != Null ){
                                         
                                         app.amount = String.valueOf( objExistInvLiine.Amount__c );
                                         app.existInvLineId = objExistInvLiine.Id;
                                     }
                                     wraplist.add(app);
                                        }
                                     //end 3 may 2020
                                    
                                 }
            return wraplist;  
        }
        return null;
    }
    
    //--------------------------------------------------  Saving Invoice Line Item  ---------------------------------------------------------------------------
    @AuraEnabled
    public static  string saveinvoicelineitem(list<string> applicationids , list<string> amountwithid ,string invoice){
        
        list< AddInvoiceLineItemComp__mdt > listMetaData = [SELECT Id, Maxway_Profile_Name__c, Agent_Profile_Name__c, ApplicationType1__c, ApplicationType2__c, ApplicationType3__c, ApplicationType4__c, ApplicationStage1__c, ApplicationStage2__c, InvoiceType1__c, InvoiceSchoolRecTypeName__c, InvoiceAgentRecTypeName__c, InvoiceStatus__c, InvoiceLineItemRecType__c, ApplicationRecType1__c, ApplicationRecType2__c 
                                                            FROM AddInvoiceLineItemComp__mdt
                                                            WHERE MasterLabel = 'InvoiceMetaData' LIMIT 1 ];
        
        system.debug('applicationids---> ' + applicationids);
        system.debug('amountwithid---> ' + amountwithid);
        
        //incase if single record is beingn selected and no amount was there .
        if( amountwithid.isEmpty() ){ return ' Please fill amount.'; }
        
        String invCurrency = '';
        if( String.isNotBlank( invoice ) ){
            invCurrency = [ SELECT CurrencyIsoCode FROM Invoice__c WHERE Id =: invoice LIMIT 1 ][0].CurrencyIsoCode; 
        } 
        try{
            list<Invoice_Line_Item__c> invoicelineitem = new list<Invoice_Line_Item__c>();
            
            Id devRecordTypeId = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get( listMetaData[0].InvoiceLineItemRecType__c ).getRecordTypeId();
            for(string app : amountwithid ){
                
                if(invoice!= null ){
                    string[] appsplit = app.split(';');
                    if(applicationids.contains(appsplit[0])){
                        
                        if( String.isBlank( appsplit[1] )){ return ' Please enter a valid amount before saving'; }
                        
                        if( appsplit.size() > 2 ){
                            
                            invoicelineitem.add(new Invoice_Line_Item__c (Id = appsplit[2] ,CurrencyIsoCode =invCurrency, Application__c=appsplit[0],Invoice__c=invoice,Amount__c=decimal.valueof(appsplit[1]),recordtypeid=devRecordTypeId));  
                        }
                        else
                            
                            invoicelineitem.add(new Invoice_Line_Item__c (Application__c=appsplit[0],CurrencyIsoCode =invCurrency, Invoice__c=invoice,Amount__c=decimal.valueof(appsplit[1]),recordtypeid=devRecordTypeId));  
                    }
                    
                }
            }
            system.debug('invoicelineitem --> ' +invoicelineitem);
            //insert invoicelineitem;
            upsert invoicelineitem;
            return 'SUCCESS';
        }
        catch(exception e){
            return e.getMessage();   
        }
        
    }
    public class appwrapper{
        @AuraEnabled public string appnumber; 
        @AuraEnabled public string appid;
        @AuraEnabled public string amount;
        @AuraEnabled public string studentId;
        @AuraEnabled public string studentName;
        @AuraEnabled public string opportunityStage;
        @AuraEnabled public string opportunityName;
        @AuraEnabled public string applicationStage;
        @AuraEnabled public string curency;
        @AuraEnabled public string existInvLineId;
        @AuraEnabled public string commission;
        
    }
}