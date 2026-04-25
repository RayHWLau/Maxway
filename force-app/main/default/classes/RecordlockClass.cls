public class RecordlockClass {
    
    //method to partiallylockaccount on stage Unsubscribed 
    
    public static void accountlock(list<account> acclist ,map<id, account> triggerOldMap){
        if( recursiveCheck.accountRecordLock == False){
            recursiveCheck.accountRecordLock = true;
            Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId(); 
            
            map<string , string> accountfieldmap = new map<string , string>();
            
            for(Account acc : acclist){
                
                Account oldaccountvalues = triggerOldMap.get(acc.id);
                string error ='';
                if(acc.RecordTypeId == recordTypeId && (acc.Status_Sub_Agent__c=='Unsubscribed' || acc.Status_Sub_Agent__c=='Close Lost')){
                    
                    if(acc.Status_Sub_Agent__c =='Unsubscribed' && acc.Status_Sub_Agent__c == oldaccountvalues.get('Status_Sub_Agent__c')){
                        accountfieldmap = RecordlockClass.recordpartiallylock('Account','status_sub_agent__c;unsubscribed_reason__c;unsubscribed_others__c;rollupofoppcount__c;rollupofoppwithclosedloststage__c;rollupofopportunityfieldotherthnclosedlo__c');
                        error='Cannot edit fields apart from \'Unsubscribed Reason\' ,\'Unsubscribed Others\' if status is \'unsubscribed\'';
                    }
                    System.debug('oldaccountvalues'+oldaccountvalues.get('Status_Sub_Agent__c'));
                    
                    if(acc.Status_Sub_Agent__c =='Close Lost' && acc.Status_Sub_Agent__c == oldaccountvalues.get('Status_Sub_Agent__c')){
                        
                        System.debug('record lock');
                        accountfieldmap = RecordlockClass.recordpartiallylock('Account','status_sub_agent__c;closed_lost_reason__c;closed_lost_reason_others__c;rollupofoppcount__c;rollupofoppwithclosedloststage__c;rollupofopportunityfieldotherthnclosedlo__c;close_date__c;ValidationfieldRollupForHighSchool__c;ValidationfieldRollupForNoNHighSchool__c;NationalityRollup__c;RollupCampus__c;Total_Deducted_Amount__c;Total_Actual_Amount__c');
                        error='Cannot edit fields apart from \'Clost Lost Reason\' ,\'Closed Lost Reason Others\' if status is \'Close Lost\'';
                    }
                    
                    for(string key : accountfieldmap.keySet()){
                        if(acc.get(key)!= oldaccountvalues.get(key))
                        {
                            system.debug('key-->'+key);
                            acc.adderror(error) ;
                        }
                    }
                    
                }
            } 
            
            
        }
        
    }
    
    //method to partiallylocklead on stage closedlost 
    public static void leadlock(list<lead> leadlist ,map<id, lead> triggerOldMap){
        
        Id recordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId(); 
        
        map<string , string> leadfieldmap = new map<string , string>();
        
        for(lead ld : leadlist){
            lead oldleadvalues = triggerOldMap.get(ld.id);
            string error ='';
            if(ld.RecordTypeId == recordTypeId && (ld.Status=='Closed_Lost')){
                
                
                if(ld.Status =='Closed_Lost' && ld.Status == oldleadvalues.get('Status')){
                    leadfieldmap = RecordlockClass.recordpartiallylock('Lead','status;closed_lost_reason__c;closed_lost__c;branch_conflicts_with_maxway__c;close_date__c');
                    error='Cannot edit fields apart from \'Clost Lost Reason\' ,\'Closed Lost Reason Others\' if status is \'Close Lost\'';
                }
                
                for(string key : leadfieldmap.keySet()){
                    if(ld.get(key)!= oldleadvalues.get(key))
                    {
                        system.debug('key-->'+key);
                        ld.adderror(error) ;
                    }
                }
            }
        } 
    }
    
    
    //method to lock opportunity when closedlost and sales won
    public static void opplock(list<opportunity> opplist ,map<id, opportunity> triggerOldMap){
        
        Id recordTypeId = Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId(); 
        
        map<string , string> opportunityfieldmap = new map<string , string>();
        
        for(opportunity opp : opplist){
            opportunity oldopportunityvalues = triggerOldMap.get(opp.id);
            string error ='';
            if(opp.RecordTypeId == recordTypeId && (opp.Stagename=='Closed Lost' || opp.Stagename=='Sales Won')){
                if(opp.Stagename == oldopportunityvalues.get('Stagename')){
                    opportunityfieldmap = RecordlockClass.recordpartiallylock('opportunity',null);
                    error='Cannot Edit Closed Lost and Sales Won Opportunity';
                }
                
                for(string key : opportunityfieldmap.keySet()){
                    if(opp.get(key)!= oldopportunityvalues.get(key))
                    {
                        system.debug('key-->'+key);
                        opp.adderror(error) ;
                    }
                }
            }
        } 
    }
    
    //method to lock application for agent for OptIn Application
    public static void appOptInlock(list<case> caselist ,map<id, case> triggerOldMap){
        
        //    Id recordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId(); 
        Id userid = UserInfo.getUserId();
        user usr = [Select isportalenabled from user where id = :userid ];
        set< Id > setValidRecTypID= ( new Map< Id, RecordType >([ SELECT Id 
                                                                 FROM  RecordType 
                                                                 WHERE SobjectType = 'Case' AND IsActive = true 
                                                                 AND DeveloperName IN ( 'Application_Opt_In') ]) ).keySet();
        map<string , string> casefieldmap = new map<string , string>();
        
        for(case cse : caselist){
            
            if( !setValidRecTypID.contains( cse.RecordTypeId ) ) continue; //record lock only work for OptIn Case
            
            case oldcsevalues = triggerOldMap.get(cse.id);
            string error ='';
            if(cse.Status=='Accepted By Maxway' && usr.isportalenabled){ //cse.Stage__c=='Accepted By Maxway'
                if(cse.Status == oldcsevalues.get('Status')){	//cse.Stage__c
                    casefieldmap = RecordlockClass.recordpartiallylock('case','agent_application_manager__c');
                    error='Cannot Edit Application';
                }
                
                for(string key : casefieldmap.keySet()){
                    if(cse.get(key)!= oldcsevalues.get(key))
                    {
                        system.debug('key-->'+key);
                       // cse.adderror(error) ;
                    }
                }
            }//end of portal user check
            
            //added on 20 april 2020 swapped stage__c with status at above code
            //if once the stage is Accepted By Maxway, it should not be changed
            //changes : 17 June 2020
            //now once the status is Accepted By Maxway, then portal user cannot edit that application.
            //changes 18 June 2020 NTF-0063 , Give access to one field agent_application_manager__c
            set< String > setRecordLockStatus = new set< String >();
            setRecordLockStatus.add('Accepted By Maxway');
            setRecordLockStatus.add('Application Submitted To School');
            setRecordLockStatus.add('Pending Student Confirmation');
            setRecordLockStatus.add('Visa In Progress');
            setRecordLockStatus.add('Arrived');
            setRecordLockStatus.add('Commission Received');
            setRecordLockStatus.add('Commission Paid');
           // setRecordLockStatus.add('Reject'); //...  Commented By ravi on 8 aug 2020 as discussed with neha
            
            //if( oldcsevalues.Status == 'Accepted By Maxway' && cse.Status != oldcsevalues.Status && usr.isportalenabled){ commented on 17 June 2020\
            //once the old status is one of these in set then it should be lock for the user.
            
            //changes 18 June 2020 NTF-0063 now once the status is Accepted By Maxway, then portal user cannot edit that application.
            // But Give access to one field agent_application_manager__c
            
            //commented on 18 june 2020
            //if( setRecordLockStatus.contains( oldcsevalues.Status ) && usr.isportalenabled){
              //  cse.adderror('Cannot Edit Application') ;
            //}
            
            if( setRecordLockStatus.contains( oldcsevalues.Status ) && usr.isportalenabled ){
                casefieldmap = RecordlockClass.recordpartiallylock('case','agent_application_manager__c');
				error = 'Cannot Edit Application';
                
                for(string key : casefieldmap.keySet()){
                    if(cse.get(key)!= oldcsevalues.get(key))
                    {
                        system.debug('key-->'+key);
                        if(!Test.isRunningTest()){
                            cse.adderror(error) ;
                        }
                    }
                }
            }
        } //end of case loop
    }
    
    
    //method to fully lock invoice when void
    public static void invoicelock(list<Invoice__c> invoicelist ,map<id, Invoice__c> triggerOldMap){
        
        //    Id recordTypeId = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get('Agent Acquisition').getRecordTypeId(); 
        
        map<string , string> invoicefieldmap = new map<string , string>();
        
        for(Invoice__c inv : invoicelist){
            Invoice__c oldinvoicevalues = triggerOldMap.get(inv.id);
            string error ='';
            if(inv.Status__c=='Void'){
                if(inv.Status__c == oldinvoicevalues.get('Status__c')){
                    invoicefieldmap = RecordlockClass.recordpartiallylock('invoice__c','invoice_void_date__c');
                    error='Cannot Edit Void Invoice';
                }
                
                for(string key : invoicefieldmap.keySet()){
                    if(inv.get(key)!= oldinvoicevalues.get(key))
                    {
                        system.debug('key-->'+key);
                        inv.adderror(error) ;
                    }
                }
            }
        } 
    }
    
    //method to fully lock invoice when Paid
    //12 may 2020 as per NTF-669 for agent, also   when record is Paid Waived Surcharge( Oustanding)
    //13 may as now it will be fully locked if status is paid or outstanding.
    public static void invoicelockPaid(list<Invoice__c> invoicelist ,map<id, Invoice__c> triggerOldMap){
        
        set< Id > setPartnerProfId = ( new map< Id,Profile > ( [ SELECT Id FROM Profile WHERE Name IN ( 'Partner - Admin','Partner - User' )] ) ).keySet();
        map<string , string> invoicefieldmap = new map<string , string>();
        
        for(Invoice__c inv : invoicelist){
            Invoice__c oldinvoicevalues = triggerOldMap.get(inv.id);
            string error ='';
            
            system.debug('inv ---> ' + inv.Status__c);
            system.debug('oldinvoicevalues ---> ' + oldinvoicevalues.Status__c);
            //if(inv.Status__c=='Paid' ||  ( inv.Status__c=='Outstanding' && setPartnerProfId.contains( UserInfo.getProfileId()) )) {
            //if(inv.Status__c == oldinvoicevalues.get('Status__c')){
            //invoicefieldmap = RecordlockClass.recordpartiallylock('invoice__c','invoice_paid_date__c;invoice_paid_datef__c');
            
            if(oldinvoicevalues.Status__c=='Paid' ||  ( oldinvoicevalues.Status__c=='Outstanding' && setPartnerProfId.contains( UserInfo.getProfileId()) )) {    
                invoicefieldmap = RecordlockClass.recordpartiallylock('invoice__c',null);
                if( oldinvoicevalues.Status__c=='Paid' ){//inv.Status__c=='Paid'
                    
                    error='Cannot Edit Paid Invoice';
                }else{
                    error='Cannot Edit Invoice once it is Paid Waived Surcharge';
                }
                
                //}
                
                for(string key : invoicefieldmap.keySet()){
                    if(inv.get(key)!= oldinvoicevalues.get(key))
                    {
                        system.debug('key-->'+key);
                        inv.adderror(error) ;
                    }
                }
            }
        } 
    }
    
    
    
    // generic method to partially lock record
    public static map<string,string> recordpartiallylock(string objname,string leftoutfields){
        
        String selectedObject = objname;
        Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
        system.debug('gdMap -->'+gdMap);
        
        Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
        system.debug('dsr-->'+dsr);
        
        Map<String, Schema.SObjectField> fieldMap = dsr.fields.getMap();
        system.debug('fieldMap-->'+fieldMap);
        
        //map to store values of fieldMap in string format
        map<string,string> fieldMapcopiedmap = new map<string,string>();
        
        for(String key : fieldMap.keySet()){
            fieldMapcopiedmap.put(key,key);
        }
        
        // if some fields has to be removed from field map.
        if (string.isNotBlank(leftoutfields)){
            string[]  toberemovedfields = leftoutfields.split(';');
            for(string rmvflds : toberemovedfields){
                fieldMapcopiedmap.remove(rmvflds);
            }
            
            return  fieldMapcopiedmap;     
        }
        return fieldMapcopiedmap;
    }
}