public class InvoiceTriggerHelper {
    
    
    /**
		Name : Karan Singh Soni
		Company: Techmatrix
		Description: Method to rollup all Invoice amount for portal user ( Agent )
		Inputs: None
		Returns: void
		History:
		Test Class: InvoiceTriggerTest
		====================================================
		1.0 27 Jan 2020 Karan Singh Initial Version
			19 Mar 2020 added set for the staus field in Invoice as rollup functionality
	**/
    public static void rollupInvoiceAmount(){
        
        InvoiceTrigger_RollUpInvoiceAmount__c triggerSetting = InvoiceTrigger_RollUpInvoiceAmount__c.getValues('triggerSettings');
        Map < Id, Account > mapAccountwithRollUpAmnt = new Map < Id, Account >();
        List< String > listStatusForRollUp = new List< String >();
        
        //19 Mar 2020
        if( String.isNotBlank( triggerSetting.Status__c ) ){
            
            if( triggerSetting.Status__c.contains(',') ){
                
                listStatusForRollUp = triggerSetting.Status__c.split(',');
            }else{
                
			listStatusForRollUp.add( triggerSetting.Status__c );
            }
        }
        //19 Mar 2020
        Boolean isPrepaidFound = false;
        
        for( Invoice__c objInvoice : ( List < Invoice__c > ) Trigger.new ){
            
             if( triggerSetting.showDebugLogs__c ){ system.debug('objInvoice'+objInvoice); }
            
            //only if amount recieved is not null, type be = triggerSetting.Invoice_Type__c ( initial prepaid )
            if( objInvoice.Amount_Received__c <> Null && objInvoice.Company_Name__c <> Null  && objInvoice.Invoice_Type__c == triggerSetting.Invoice_Type__c ){
                
                if( trigger.isInsert ){
                    
                    mapAccountwithRollUpAmnt.put( objInvoice.Company_Name__c, Null );
                }
                //incase of update amount recieved should be changed and Invoice type will not get changed
                else if ( trigger.isUpdate && (( Map < Id,Invoice__c >)Trigger.oldMap).get(objInvoice.Id).Amount_Received__c <> objInvoice.Amount_Received__c ){
                    
                    mapAccountwithRollUpAmnt.put( objInvoice.Company_Name__c, Null );
                }
            }
        }//end of triggerNew loop
        
        //fetching all invoice for roll up of selected account
        for( Invoice__c objInvoice : [ SELECT Amount_Received__c,Company_Name__c,Status__c
                                      FROM Invoice__c 
                                      WHERE Amount_Received__c <> NULL AND Company_Name__c IN : mapAccountwithRollUpAmnt.keySet() 
                                      AND Invoice_Type__c = : triggerSetting.Invoice_Type__c AND Status__c = :listStatusForRollUp] ) //added 19march 2020 now rollup on more than status
        {
            isPrepaidFound = true;
            if( triggerSetting.showDebugLogs__c ){ system.debug('objInvoice'+objInvoice); }
            if( triggerSetting.showDebugLogs__c ){ system.debug('mapAccountwithRollUpAmnt'+mapAccountwithRollUpAmnt); }
            
            if( mapAccountwithRollUpAmnt.get( objInvoice.Company_Name__c ) == Null ){
                
                mapAccountwithRollUpAmnt.put( objInvoice.Company_Name__c, new Account( Id = objInvoice.Company_Name__c, Total_Actual_Amount__c = objInvoice.Amount_Received__c ));
            }
            else{
                
                Decimal rollUpAmnt = mapAccountwithRollUpAmnt.get( objInvoice.Company_Name__c ).Total_Actual_Amount__c + objInvoice.Amount_Received__c;
                mapAccountwithRollUpAmnt.get(objInvoice.Company_Name__c).Total_Actual_Amount__c = rollUpAmnt;
            }
           
        }//end of Invoice loop'
        
        if( triggerSetting.showDebugLogs__c ){ system.debug('mapAccountwithRollUpAmnt'+mapAccountwithRollUpAmnt); }
        
        if( isPrepaidFound )
            update mapAccountwithRollUpAmnt.values();
        
        //-------------------------------------------------------------- Clearing heap ------------------------------------------------------------------------------------------------
        mapAccountwithRollUpAmnt.clear();
        triggerSetting.clear();
        
    }
    
    
     /**
		Name : Karan Singh Soni
		Company: Techmatrix
		Description: When Status is iSsue then a task should be assign to Issuing Staff
		Inputs: None
		Returns: void
		History:
		Test Class: InvoiceTriggerTest
		====================================================
		1.0 22 Apr 2020 Karan Singh Initial Version
		1.1 12 may 2020 Karan Singh added task creation for the HQAdmin
			
	**/
    static set< Id > setRecursivecheckTask = new set< Id >();
    public static void createIssuedTask(){
        
        map< Id,RecordType > mapValidInvRecType =   new map< Id, RecordType > ([ SELECT Id ,name
                                                                 	FROM  RecordType 
                                                                 	WHERE SobjectType = 'Invoice__c' AND IsActive = true 
                                                                  	AND DeveloperName IN ( 'Agent', 'School', 'Student' ) ]) ;
        
        list< Staff__c > listHqStaffId = [ SELECT Id FROM Staff__c WHERE Name = 'HQ Admin' ];
        
        list< Task > listTask = new list< Task >();
        for( Invoice__c objInv : ( List< Invoice__c > ) trigger.new ){
            
            if( setRecursivecheckTask.contains( objInv.Id )) continue;
            if( !mapValidInvRecType.containsKey( objInv.RecordTypeId )) continue;
            if( String.isBlank( objInv.Issuing_Staff__c ) ) continue;
            
          
            if( ( trigger.isInsert && objInv.Status__c == 'Issued' ) ||
               ( trigger.isUpdate && objInv.Status__c == 'Issued' && objInv.Status__c != (( map < Id, Invoice__c > ) trigger.oldMap ).get(objInv.Id).Status__c )){
                   
                   setRecursivecheckTask.add( objInv.id );
                   listTask.add( TaskCreationClass.taskcreate('Chase Invoice', Date.today(), objInv.Id, objInv.OwnerId, objInv.Issuing_Staff__c ));
               }
            else if( ( objInv.Status__c == 'Paid' && ( objInv.Invoice_Type__c == 'Commission Payable To Agent' || objInv.Invoice_Type__c == 'Commission To School' ) &&
                      ( trigger.isInsert || ( trigger.isUpdate && objInv.Status__c != (( map < Id, Invoice__c > ) trigger.oldMap ).get(objInv.Id).Status__c || 
                                             objInv.Invoice_Type__c != (( map < Id, Invoice__c > ) trigger.oldMap ).get(objInv.Id).Invoice_Type__c ) ))
                     ){
                         setRecursivecheckTask.add( objInv.id );
                   		listTask.add( TaskCreationClass.taskcreate('Update Application Status.', Date.today(), objInv.Id, objInv.OwnerId, objInv.Issuing_Staff__c ));
                     }
            
            //added on 12 may 2020
            //task creation for the HqAdmin if status = paid, Type = license fee and recordtype = agent
            if( !listHqStaffId.isEmpty() &&  objInv.Status__c == 'Paid' && objInv.Invoice_Type__c == 'License Fee' && mapValidInvRecType.get( objInv.RecordTypeId ).Name == 'Agent' 
               && (trigger.isInsert ||  ( trigger.isUpdate && objInv.Status__c != (( map < Id, Invoice__c > ) trigger.oldMap ).get(objInv.Id).Status__c ) )){
                
                   setRecursivecheckTask.add( objInv.id );
                   
                   listTask.add( TaskCreationClass.taskcreate('Activate Contract and Configure account.', Date.today(), objInv.Id, objInv.OwnerId,listHqStaffId[0].Id ));
            }
            //end 12 may 2020
            
        }//end of Inv Loop
        
        if( listTask.size() > 0 ){
            insert listTask;
        }
        
        system.debug('listTask --> ' + listTask );
    }
    
    
    /**
		Name : Karan Singh Soni
		Company: Techmatrix
		Description: When currency of the invoice is changes, then it should change the related invoice line item currency.
		Inputs: None
		Returns: void
		History:
		Test Class: InvoiceTriggerTest
		====================================================
		1.0 6 May 2020 Karan Singh Initial Version
			
	**/
    static set< Id > setRecursivecheckCurr = new set< Id >();
    public static void isCurrencyChanged(){
        
        //as for now only in case of update, it should change currency
        if( trigger.isUpdate ){
           
            map< Id, String > mapValidInvId = new map< Id, String >();
            list< Invoice_Line_Item__c > listInvLineItem = new list< Invoice_Line_Item__c >();
            
            for( Invoice__c objInv : ( list< Invoice__c > ) trigger.new ){
                
                if( setRecursivecheckCurr.contains( objInv.Id )) continue;
                
                if( objInv.CurrencyIsoCode != ( ( map< Id, Invoice__c > ) trigger.oldMap ).get( objInv.Id ).CurrencyIsoCode ){
                    
                    mapValidInvId.put( objInv.Id, objInv.CurrencyIsoCode );
                    setRecursivecheckCurr.add( objInv.Id );
                }
            }// end of trigger.new
            
            if( !mapValidInvId.isEmpty() ){
                
               for( Invoice_Line_Item__c objInvLine : [ SELECT Id,CurrencyIsoCode,Invoice__c 
                                                      	FROM Invoice_Line_Item__c
                                                       WHERE Invoice__c In: mapValidInvId.keySet() ]){
                                                           
                                                           objInvLine.CurrencyIsoCode = mapValidInvId.get( objInvLine.Invoice__c );
                                                           listInvLineItem.add( objInvLine );
                                                       }
                
                if( !listInvLineItem.isEmpty() ){
                    
                    update listInvLineItem;
                }
            }
        }//end of isUpdate			
        
    }//end of isCurrencyChanged
    
    /**
		Name : Karan Singh Soni
		Company: Techmatrix
		Description: method to update date fields as per status
		Inputs: None
		Returns: void
		History:
		Test Class: InvoiceTriggerTest
		====================================================
		1.0 14 May 2020 Karan Singh Initial Version
			
	**/
    
    static set< Id > setRecursiveCheckDateUpt = new set< Id >();
    
    public static void updateDateAsPerStatus(){
        
        for( Invoice__c objInv : ( list< Invoice__c > ) trigger.new ) {
            
            setRecursiveCheckDateUpt.contains( objInv.Id );
            
            if( trigger.isInsert ){
                
                System.debug('objInv.Status__c==========>>>>>>>>>>'+objInv.Status__c);
                
                if( objInv.Status__c == 'Paid'){
                    
                    objInv.Invoice_Paid_Date__c = Date.today();
                    setRecursiveCheckDateUpt.add( objInv.Id );
                }
                else if( objInv.Status__c == 'Void'){
                    objInv.Invoice_Void_Date__c = Date.today();
                    setRecursiveCheckDateUpt.add( objInv.Id );
                }
                else if( objInv.Status__c == 'Outstanding'){
                    
                    objInv.Invoice_Paid_Date__c = Date.today();
                    setRecursiveCheckDateUpt.add( objInv.Id );
                }
                    
            }
            if( trigger.isUpdate ){
                
                Invoice__c objOldInv = ( ( map< Id, Invoice__c > ) trigger.oldMap ).get( objInv.Id );
                
                 if( objInv.Status__c != objOldInv.Status__c && objInv.Status__c == 'Paid'){
                    
                    objInv.Invoice_Paid_Date__c = Date.today();
                     setRecursiveCheckDateUpt.add( objInv.Id );
                }
                else if( objInv.Status__c != objOldInv.Status__c && objInv.Status__c == 'Void'){
                    objInv.Invoice_Void_Date__c = Date.today();
                    setRecursiveCheckDateUpt.add( objInv.Id );
                }
                else if( objInv.Status__c != objOldInv.Status__c && objInv.Status__c == 'Outstanding'){
                    
                    objInv.Invoice_Paid_Date__c = Date.today();
                    setRecursiveCheckDateUpt.add( objInv.Id );
                }
            }
            
        }
    }
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Method to share Invoice record to the other portal user.
		Inputs:None
		Returns: void
		Last Modified On :
		History:
		====================================================
		1.0 21 May 2020   Karan Singh 	Initial Version

	**/
    public static set< Id > setRecursiveCheckAddUser = new set< Id >();
    public static void shareInvoiceToOtherPortalUser(){
        
        list< Invoice__Share > listInvoiceShare = new  list< Invoice__Share >();
        map< Id, list< Id > > mapUserAccntwithContactIds = new map< Id, list< Id > >();
        set< Id > setUserContactIds = new set< Id > ();
        map< Id, User > mapUserContactToActiveUser = new map< Id, User >();
        
        //check if current user is portal user or not
        list< user > listCurrrentUser = [ SELECT Id,isPortalEnabled,contact.AccountId  FROM User WHERE Id =: UserInfo.getUserId() ];
        
        System.debug('listCurrrentUser+++++++++++++++>>>>>>>>>>>>>>>'+listCurrrentUser);
        
        //if the current user is portal user then only share the records
        if( listCurrrentUser[0].isPortalEnabled && String.isNotBlank( listCurrrentUser[0].contact.AccountId ) ){
            
            for( Account objAccnt : [ SELECT Id,( SELECT Id FROM Contacts ) FROM Account 
                                     WHERE Id =: listCurrrentUser[0].contact.AccountId ]){
                                        
                                         if( !mapUserAccntwithContactIds.containsKey( objAccnt.Id ) ){
                                             mapUserAccntwithContactIds.put( objAccnt.Id, new list< Id > () );
                                         }
                                         
                                         mapUserAccntwithContactIds.get( objAccnt.Id).addAll(( new map< Id, Contact > ( objAccnt.Contacts ) ).keySet());
                                         setUserContactIds.addAll( mapUserAccntwithContactIds.get( objAccnt.Id ));
                                     }//end of portal user account loop
            system.debug('@@@@@ mapUserAccntwithContactIds --> ' + mapUserAccntwithContactIds);
            system.debug('@@@@@ setUserContactIds --> ' + setUserContactIds);
            if( setUserContactIds.size() > 0  ){
            
                for( User objUser : [SELECT Id,ContactId FROM user WHERE ContactId IN: setUserContactIds AND isActive = true] ){
                    
                    mapUserContactToActiveUser.put( objUser.ContactId, objUser );
                        
                }//end of user loop
                system.debug('@@@@@ mapUserContactToActiveUser --> ' + mapUserContactToActiveUser);
                for( Invoice__c objInvoice : ( list< Invoice__c > ) trigger.new ){
                    
                    if( setRecursiveCheckAddUser.contains( objInvoice.id )) continue;
                    
                    if( objInvoice.ownerId == listCurrrentUser[0].Id 
                       && mapUserAccntwithContactIds.containsKey( listCurrrentUser[0].contact.AccountId )){
                        
                           for( Id contactId : mapUserAccntwithContactIds.get( listCurrrentUser[0].contact.AccountId )){
                               system.debug('@@@@@ contactId --> ' + contactId);
                               //if contact user is same as current User then we didnt need sharing for that.
                               
                               if( !mapUserContactToActiveUser.containskey(contactId)) continue;
                               if( mapUserContactToActiveUser.get( contactId ).Id == listCurrrentUser[0].Id )continue;
                               
                               Invoice__Share objInvoiceShare = new Invoice__Share();
                               objInvoiceShare.ParentId = objInvoice.Id;
                               objInvoiceShare.AccessLevel = 'Edit';
                               objInvoiceShare.UserOrGroupId = mapUserContactToActiveUser.get( contactId ).Id;
                               listInvoiceShare.add( objInvoiceShare );
                               setRecursiveCheckAddUser.add( objInvoice.Id );
                           }//end of Contact Id loop
                    }
                }//end of trigger.new loop
                
                if( listInvoiceShare.size() > 0 ){
                    insert listInvoiceShare; 
                    system.debug('@@@@@ listInvoiceShare --> ' + listInvoiceShare);
                }
            }//end of contact Ids check
        }//end of current portal user check
    }//end of shareInvoiceToOtherPortalUser
}