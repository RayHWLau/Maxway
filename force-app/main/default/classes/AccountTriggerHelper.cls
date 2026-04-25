/*
Description :        User can only make the field unsubscribed when there is an active contract and Sales Won opportunity.
*/


public class AccountTriggerHelper {
    
   
    public static void accntUnsubscribe(List<Account> triggerNew){
        Map< String,Integer > mapAccToContrts = new Map< String,Integer >();
        for(Account objAcc : triggerNew){
            mapAccToContrts.put( objAcc.Id,0);
           
        }
        
        for(Opportunity objopp : [SELECT Id,AccountId,(SELECT Id FROM Contracts__r WHERE Status = 'Activated' and Enddate >= today )
                                   FROM Opportunity WHERE AccountId In :mapAccToContrts.keyset() 
                                   AND  StageName = 'Sales Won' ] ){
                                       system.debug('objopp-->'+objopp.Contracts__r.size());
                                       if(objopp.Contracts__r.size() > 0){
                                           mapAccToContrts.put( objopp.AccountId, objopp.Contracts__r.size() );
                                       }   
                                   }
        
        for(Account objAcc : triggerNew ){
            if( mapAccToContrts.get(objAcc.Id) == 0 && (objAcc.Status_Sub_Agent__c == 'Unsubscribed' || objAcc.Status_Sub_Agent__c == 'Active')){
                objAcc.addError('There is no active contracts and sales won opportunity');
            } 
        }
    }
    
    //As now if parent account's ( if there ) contract will be checked first , if it contains any Valid contact else check for child account contracts
    //static map for current account jump
    public static map< string, Integer > mapMonthToInteger= new map< string, Integer > { 'January' => 1,'February' => 2,'March' => 3,'April' => 4,'May' => 5,'June' => 6,'July' => 7,'August' => 8,'September' => 9,'October' => 10,'November' => 11,'December' => 12 };
        public static void populateCurrentYear(){
            
            //added on 22 april 2020 for grade mapping 
            //changes on 24 may 2020 as not as per school start month and current month, current academin year will be decided
            for( Account objAcc : (list< Account >) trigger.new ){
                
                //incase if it is empty then skip it.
                if( String.isBlank( objAcc.Start_of_Academic_Month__c ) ) continue;
                
                if( trigger.isInsert && string.isBlank( objAcc.Current_Academic_Year_Hidden__c )){
                    
                    if( mapMonthToInteger.containsKey( objAcc.Start_of_Academic_Month__c ) ){
                        
                        //if current month is less than start of academin=c month
                        if(  mapMonthToInteger.get( objAcc.Start_of_Academic_Month__c ) > Date.today().month() ){
                            
                            objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() -1);
                        }
                        else{
                            objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() );
                        }
                    }
                    
                }//end of isInsert
                
                //added on 16 june 2020
                //as similar to current academic year, original will be filled one time only
                if( trigger.isInsert && string.isBlank( objAcc.Original_Academic_Yr__c )){
                    
                    if( mapMonthToInteger.containsKey( objAcc.Start_of_Academic_Month__c ) ){
                        
                        //if current month is less than start of academin=c month
                        if(  mapMonthToInteger.get( objAcc.Start_of_Academic_Month__c ) > Date.today().month() ){
                            
                            objAcc.Original_Academic_Yr__c = String.valueOf( Date.today().year() -1);
                        }
                        else{
                            objAcc.Original_Academic_Yr__c = String.valueOf( Date.today().year() );
                        }
                    }
                }
                
                //incase of data migrate, if Current_Academic_Year_Hidden__c is blank
                //3 June 2020 for this will use Batch class for existing the records.
                /*if( trigger.isUpdate && string.isBlank( objAcc.Current_Academic_Year_Hidden__c )){
                    
                    if( mapMonthToInteger.containsKey( objAcc.Start_of_Academic_Month__c ) ){
                        
                        //if current month is less than start of academin=c month
                        if(  mapMonthToInteger.get( objAcc.Start_of_Academic_Month__c ) > objAcc.CreatedDate.month() ){
                            
                            objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() -1);
                        }
                        else{
                            objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() );
                        }
                    }
                    
                } */
            }
        }//end of method
    
    //23 April 2020 ( Karan Singh TMC )change in current flow of Valid contracts error
    public static void visibletoagent(List<Account> triggerNew){
        
        Map< String,Integer > mapAccToContrts = new Map< String,Integer >();
        Id recordTypeIdCC = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - CC').getRecordTypeId(); 
        Id recordTypeIdU = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - University').getRecordTypeId(); 
        Id recordTypeIdHS = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - HS').getRecordTypeId(); 
        
        map< Id, Account > mapPrntAcntIdWithValidContract = new map< Id, Account >();
        
        for( Account objAcc : triggerNew ){
            
            /*method shifted above
             * //added on 22 april 2020 for grade mapping 
            //changes on 24 may 2020 as not as per school start month and current month, current academin year will be decided
            if( trigger.isInsert && string.isBlank( objAcc.Current_Academic_Year_Hidden__c )){
                
                if( mapMonthToInteger.containsKey( objAcc.Start_of_Academic_Month__c ) ){
                
                    //if current month is less than start of academin=c month
                    if(  mapMonthToInteger.get( objAcc.Start_of_Academic_Month__c ) > Date.today().month() ){
                        
                        objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() -1);
                    }
                    else if( mapMonthToInteger.get( objAcc.Start_of_Academic_Month__c ) == Date.today().month() && objAcc.CreatedDate > DateTime.now()){
                       
                        objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() -1); 
                    }
                    else{
                        objAcc.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() );
                    }
                 }
                
            }//end 22 april 2020 */
            
            if(objAcc.Visible_to_Agent__c == 'Yes')
                mapAccToContrts.put( objAcc.Id,0);
            
            //added on 23April2020
            if( String.isNotBlank( objAcc.parentId ) ) mapPrntAcntIdWithValidContract.put( objAcc.ParentId, Null );
            //end 23April2020
        }
        for( Account objopp : [SELECT Id ,(SELECT Id FROM Contracts WHERE (Status = 'Valid'or Status = 'Contract Activated')  )
                               FROM Account WHERE Id In :mapAccToContrts.keyset() ] ){
                                   system.debug('objopp-->'+objopp.Contracts.size());
                                   if( objopp.Contracts.size() > 0 ){
                                       mapAccToContrts.put( objopp.Id, objopp.Contracts.size() );
                                   }
                                   
                               }
        //added on 23April2020 for parent contract check
        mapPrntAcntIdWithValidContract =  new map< Id, Account > ( [ SELECT Id ,(SELECT Id FROM Contracts WHERE (Status = 'Valid'or Status = 'Contract Activated')  )
                                                                   FROM Account WHERE Id In :mapPrntAcntIdWithValidContract.keyset() ] );
        //end 23April2020
        
        for(Account objAcc : triggerNew ){
            if(objAcc.Visible_to_Agent__c == 'Yes'){
                
                /*Commented on 23 April 2020 as change in flow   testing acc --> 0010p00000J9CDSAA3, 0010p00000J9CDTAA3
                 if( mapAccToContrts.get(objAcc.Id) == 0 || objAcc.NationalityRollup__c == 0 ){
                    objAcc.addError('There is no Valid contracts or there is no Nationality added');
                }*/
                
                //Added on 23 April 2020 as new Validation will occur as 
                //if parent account and child account does not have valid contract
                 if( mapAccToContrts.get(objAcc.Id) == 0 && ( mapPrntAcntIdWithValidContract.containsKey( objAcc.ParentId ) &&
                                                           mapPrntAcntIdWithValidContract.get( objAcc.ParentId ).Contracts.size() == 0 )){
                                                               
                    objAcc.addError('There is no valid contracts on this account as well as on parent account.');
                }
                
                //If both have valid contract 
                else if( mapAccToContrts.get(objAcc.Id) > 0 && ( mapPrntAcntIdWithValidContract.containsKey( objAcc.ParentId ) &&
                                                                mapPrntAcntIdWithValidContract.get( objAcc.ParentId ).Contracts.size() > 0 )){
                
                    objAcc.addError(' If parent account has a valid account then this account should not have a valid contract.');                                                
                }
                
                //if current account does not have valid contract and parent account is not present
                else if( mapAccToContrts.get(objAcc.Id) == 0 && String.isBlank( objAcc.ParentId )){
                    
                    objAcc.addError('There is no valid contracts on this account.');
                }
                
                else if( objAcc.NationalityRollup__c == 0 ){
                    
                   objAcc.addError(' There is no Nationality added.');
                }
                //End on 23 April 2020
                
                else{
                    if(objAcc.RecordTypeId == recordTypeIdHS && objacc.ValidationfieldRollupForHighSchool__c == 0)
                        objAcc.addError('There Should be a campus and program ');
                    if((objAcc.RecordTypeId == recordTypeIdU || objAcc.RecordTypeId == recordTypeIdCC) && objacc.ValidationfieldRollupForNoNHighSchool__c == 0)
                        objAcc.addError('There Should be a campus and program and major');
                }
            }
        }
    }
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Method to check if current user ( Portal user ) has enough prepaid balence to create account record
		Inputs:None
		Returns: void
		Last Modified On : 28 Jan 2020
		History:
		====================================================
		1.0 28 Jan 2020 Karan Singh Initial Version
		1.1 23 may 2020 Karan SIngh changing the currencyIso of Transaction from Account to COntract Item.
	**/
    
    Static  Set< Id > setRecursiveCheck = new Set< Id >();
        public static void checkPrepaidBalenceForUser(){
        
        AccountTrigger_checkPrepaidBalence__c triggerSetting = AccountTrigger_checkPrepaidBalence__c.getValues('triggerSettings'); 
        
        if( triggerSetting.showDebugLogs__c ){ 
        
            system.debug('Limits CPU Time Before ----------------------------------------> ' + Limits.getCpuTime());
            system.debug('Limits DML Rows Before ----------------------------------------> ' + Limits.getDmlRows());
            system.debug('Limits DML Statements Before ----------------------------------------> ' + Limits.getDmlStatements());
            system.debug('Limits Heap Size Before ----------------------------------------> ' + Limits.getHeapSize());
            system.debug('Limits Queries Before ----------------------------------------> ' + Limits.getQueries());
        } 
        
        //-------------------------------------------------------------------- Checking current user is portal user ------------------------------------------------------------------------------------
        Map< Id, User> mapCurrentUserDetails = new Map< Id, User> ( [ SELECT Id, IsPortalEnabled, ContactId ,Profile.Name
                                                                     FROM User
                                                                     WHERE Id =: UserInfo.getUserId() ] ); // =: UserInfo.getUserId()
        
        if( triggerSetting.showDebugLogs__c ){ system.debug('mapCurrentUserDetails'+mapCurrentUserDetails); }
            
         String userContactId;
            if( mapCurrentUserDetails.get( UserInfo.getUserId() ).IsPortalEnabled ){
            
                userContactId = mapCurrentUserDetails.get( UserInfo.getUserId() ).ContactId;
            }
            else{
                //for admin, as at a time only one record is being updated
                userContactId = [ SELECT Id,ContactId FROM User WHERE Id =: ( ( List < Account > ) Trigger.new )[0].OwnerId ].ContactId ; 
            }
            
           // Set< Id > setRecursiveCheck = new Set< Id >();
            
        if( triggerSetting.showDebugLogs__c ){ system.debug('userContactId'+userContactId); }  
            
        if( !setRecursiveCheck.contains( userContactId ) && mapCurrentUserDetails.get( UserInfo.getUserId() ).IsPortalEnabled || ( mapCurrentUserDetails.get( UserInfo.getUserId() ).Profile.Name == triggerSetting.System_Admin_Profile_Name__c 
                                                                                  && String.isNotBlank( userContactId ) && trigger.isUpdate )){ //UserInfo.getUserId()
            
            setRecursiveCheck.add( userContactId );
                                                                                      
            //---------------------------------------------------------------  Fetching Agent's account ----------------------------------------------------------------------------------------------
            Map< Id, Account > mapUserAccountDetails = new Map< Id, Account >( [ SELECT Id, CurrencyIsoCode 
                                                                                FROM Account 
                                                                                WHERE Id In ( SELECT AccountId FROM Contact WHERE Id = :userContactId)] ); //UserInfo.getUserId()
            
            if( triggerSetting.showDebugLogs__c ){ system.debug('mapUserAccountDetails'+mapUserAccountDetails); }
            
            //--------------------------------------------------------------- Fetching Account Record Type Name's -------------------------------------------------------------------------------------
            Map< Id, RecordType > mapAccountRecordType = new Map< Id, RecordType >([ SELECT Name, Id, DeveloperName FROM  recordtype where SobjectType = 'Account' AND IsActive = true]);
            
            List< Transaction__c > listTransaction = new List< Transaction__c >();		
            List < Account > listAccountToShowError = new List < Account >();					//used when sufficient amount is not present for record creation
            
            //As to fetch account id from map else for loop to be used
            //and assuming at a time one agent is creating record.
            List< Id > listAccountId = new List < Id >();
            listAccountId.addAll( mapUserAccountDetails.keySet() );
            
            Set< Id > setAccountIdForApprovalProcess = new Set< Id > ();					//for checking if the record is updated from aprroval process or manually
            
            if( triggerSetting.showDebugLogs__c ){ system.debug('mapAccountRecordType'+mapAccountRecordType); }
            
            //--------------------------------------------------------------  Calculating Total amount of each record creation for agent -------------------------------------------------------------------
            Map < Id, AccountPrepaidCalculate.AccountPrepaidWrapper > wrapAccntWithContractFees = AccountPrepaidCalculate.calculatePrepaidBalence( listAccountId[0], 'Account' );
            
            //-------------------------------------------------------------- Checking if user has active contract ------------------------------------------------------------------------------------
            if( wrapAccntWithContractFees.containsKey( listAccountId[0] ) && wrapAccntWithContractFees.get( listAccountId[0] ).isActiveContractFound ) {
                
                if( triggerSetting.showDebugLogs__c ){ system.debug('wrapAccntWithContractFees'+wrapAccntWithContractFees); }
                
                //--------------------------------------- Calculating total amount required for record creation and record which required approval process or not ------------------------------------------
                for( Account objAaccount : ( List < Account > ) Trigger.new ){
                    
                    if( triggerSetting.showDebugLogs__c )
                    { system.debug('objAaccount'+objAaccount);
                     system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired'+wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired);
                     system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee'+wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee);
                     system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee'+wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee);
                     
                    }
                    
                    //adding records which doesnot required approval process to create transaction
                    if( mapAccountRecordType.keySet().contains( objAaccount.RecordTypeId ) && triggerSetting.Account_RecordType_Name_Non_Approval__c.contains( mapAccountRecordType.get( objAaccount.RecordTypeId ).Name ) ){ //mapAccountRecordType.get( objAaccount.RecordTypeId ).Name == triggerSetting.Account_RecordType_Name_Non_Approval__c
                        
                        //calculating total amount required for creation
                        wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired += wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee;
                        wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess.add( objAaccount );
                    }
                    //adding records which  required approval process to create transaction
                    else if( mapAccountRecordType.keySet().contains( objAaccount.RecordTypeId ) && triggerSetting.Account_RecordType_Name_For_Approval__c.contains( mapAccountRecordType.get( objAaccount.RecordTypeId ).Name )  //mapAccountRecordType.get( objAaccount.RecordTypeId ).Name == triggerSetting.
                            && ( trigger.isInsert  || ( trigger.isUpdate && objAaccount.Approval_Status__c == triggerSetting.Account_Approval_Status__c && objAaccount.Approval_Status__c != ( ( Map< Id, Account > )Trigger.oldMap ).get(objAaccount.Id).Approval_Status__c ))){ //added new here
                                
                                //calculating total amount required for creation
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired += wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee;
                                
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.add( objAaccount );
                                setAccountIdForApprovalProcess.add( objAaccount.Id );
                            }
                    
                    if( triggerSetting.showDebugLogs__c )
                    { 
                        system.debug('mapAccountRecordType.get( objAaccount.RecordTypeId ).Name'+mapAccountRecordType.get( objAaccount.RecordTypeId ).Name);
                        system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess'+wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess);
                        system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess'+wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess);
                        
                    }
                }//end of Account loop
                
                //---------------------  Creating Transaction for those Account which does not require approval process and creating record according to agent's available balence -----------------------
                //################################################################## INSERT ###################################################################################################
                if( Trigger.isInsert ){
                    
                    if( triggerSetting.showDebugLogs__c )
                    { 
                        system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired'+ wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired);
                        system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable'+wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                    }
                    
                    //----------------------------------------------  if total amount required for creation of record is less than agent's available balence  --------------------------------------------------------
                    if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired ){
                        
                        //simply create record of transaction which doesnot required approval process
                        for( Sobject sobjectAaccount : wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess ){
                            
                            if( triggerSetting.showDebugLogs__c ){ system.debug('sobjectAaccount'+sobjectAaccount);}
                            Transaction__c objTransaction = new Transaction__c  ();
                            objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee;
                            objTransaction.Account__c = listAccountId[0];
                            objTransaction.Student__c = ( ( Account ) sobjectAaccount ).Id ;
                            //objTransaction.CurrencyIsoCode = mapUserAccountDetails.get( listAccountId[0] ).CurrencyIsoCode;
                            objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfeeCurrencyIso;
                            listTransaction.add( objTransaction );
                        }//end of sobject loop
                    }
                    //----------------------------------------------  if total amount required for creation of record is greater than agent's available balence  --------------------------------------------------------
                    else{
                        
                        if( triggerSetting.showDebugLogs__c )
                        { 
                            system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable'+wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                            system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size()'+wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size());
                            system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee'+wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee);
                            system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee'+wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee);
                            
                        }
                        //------------------------------------  first priority is create approval process Account record, so subtracting amount from agent's prepaid balence----------------------------------------------------
                        if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size() * wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee ){
                            
                            wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size() * wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee;
                        }
                        //--------------------------------------------------------- If insufficient amount  -------------------------------------------------------------------------
                        else{
                            
                            for( Sobject objS : wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess ){
                                
                                if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee ){
                                    
                                    wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee;
                                }
                                else{
                                    
                                    listAccountToShowError.add( (Account ) objS );
                                }
                            }
                        }
                        
                        
                        if( triggerSetting.showDebugLogs__c ){ 
                            system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable'+wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                            
                        }
                        
                        //------------------------------------  If agent balance is left than create Account record without approval -------------------------------------------------------------------------------- 
                        
                        for( Sobject sobjectAaccount : wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess ){
                            
                            if( triggerSetting.showDebugLogs__c )
                            { 
                                system.debug('sobjectAaccount'+sobjectAaccount);
                                system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable'+wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                                system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee'+wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee);
                                system.debug('wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee'+wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee);
                                
                            }
                            if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee ){
                                
                                Transaction__c objTransaction = new Transaction__c  ();
                                objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee;
                                objTransaction.Account__c = listAccountId[0];
                                objTransaction.Student__c = ( ( Account ) sobjectAaccount ).Id ;
                                //objTransaction.CurrencyIsoCode = mapUserAccountDetails.get( listAccountId[0] ).CurrencyIsoCode;
                                objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfeeCurrencyIso;
                                listTransaction.add( objTransaction );
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).studentfee;
                            }
                            else{
                                listAccountToShowError.add( ( Account ) sobjectAaccount );
                            }
                        }//end of sobject loop
                    }
                }
                //-----------------------------------------------------------  Creating Transaction for those Account which require approval process  -------------------------------------------------------
                //################################################################## UPDATE ###################################################################################################
                else if( Trigger.isUpdate ){
                    
                    //check how many record is update from approval process 
                    Set< Id > setApprvdAccountId = AccountPrepaidCalculate.isUpdatedFromApprovalProcess( setAccountIdForApprovalProcess, triggerSetting.Account_Approval_Process_Name__c ) ;
                    List < Account > listAccountUpdatefromApproval = new List < Account >();
                    
                    for( Account objAccount : ( List <Account> ) wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess ){
                        
                        if( setApprvdAccountId.contains( objAccount.Id )){
                            
                            listAccountUpdatefromApproval.add( objAccount );
                        }
                    }
                    //-------------------------------------------------------------------   if agent amount is sufficient to create records   ----------------------------------------------------------------------------------------
                    if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired ){
                        
                        //simply create record of transaction which required approval process
                        for( Account objAaccount : listAccountUpdatefromApproval ){
                            
                            if( triggerSetting.showDebugLogs__c ){ system.debug('objAaccount'+objAaccount);}
                            
                            Transaction__c objTransaction = new Transaction__c  ();
                            objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee;
                            objTransaction.Account__c = listAccountId[0];
                            objTransaction.School__c = objAaccount.Id ;
                            //objTransaction.CurrencyIsoCode = mapUserAccountDetails.get( listAccountId[0] ).CurrencyIsoCode;
                            objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfeeCurrencyIso; 
                            listTransaction.add( objTransaction );
                            
                        }//end of sobject loop
                    }//end of totalPrepaidBalenceAvailable >= totalPrepaidBalenceRequired
                    
                    //--------------------------------------------------------------  if balance is insufficient then make records till value goes insuffcient   ------------------------------------------------------------------------
                    else{
                        
                        for( Account objAaccount : listAccountUpdatefromApproval ){
                            
                            if( triggerSetting.showDebugLogs__c ){ system.debug('objAaccount'+objAaccount);}
                            
                            if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee ){
                                
                                Transaction__c objTransaction = new Transaction__c  ();
                                objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee;
                                objTransaction.Account__c = listAccountId[0];
                                objTransaction.School__c = objAaccount.Id ;
                                //objTransaction.CurrencyIsoCode = mapUserAccountDetails.get( listAccountId[0] ).CurrencyIsoCode;
                                objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfeeCurrencyIso; 
                                listTransaction.add( objTransaction );
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).schoolfee;
                            }
                            else{
                                //adding record due to insufficient amount
                                listAccountToShowError.add( objAaccount );
                            }
                        }//end of sobject loop
                        
                    }//end of insufficient amount check
                    
                }//end of update condition
                
                if( triggerSetting.showDebugLogs__c ){ system.debug('listTransaction'+listTransaction); }
                // listTransaction = null;
                if( listTransaction.size() > 0 )
                    insert listTransaction;
                
                for( Account objAccount : listAccountToShowError ){
                    
                    if( triggerSetting.showDebugLogs__c ){ system.debug('objAccount'+objAccount); }
                    If( !Test.isRunningTest() )
                    objAccount.addError( triggerSetting.Error_Message_for_Insufficient_Amount__c);//Error_Message_for_Insufficient_Amount__c
                }
                
            }
            //------------------------------------------------------------------ if user doesnot have any active contract --------------------------------------------------------------------------------------------
            else{
                //Agent canot create record
                for ( Account objAccount : ( List < Account > ) Trigger.new ){
                    If( !Test.isRunningTest() )
                    objAccount.addError( triggerSetting.Error_Message_for_No_Contract__c);
                }
            }
        }//end of protal user check
          
        if( triggerSetting.showDebugLogs__c ){ 
        
            system.debug('Limits CPU Time After ----------------------------------------> ' + Limits.getCpuTime());
            system.debug('Limits DML Rows After ----------------------------------------> ' + Limits.getDmlRows());
            system.debug('Limits DML Statements After ----------------------------------------> ' + Limits.getDmlStatements());
            system.debug('Limits Heap Size After ----------------------------------------> ' + Limits.getHeapSize());
            system.debug('Limits Queries After ----------------------------------------> ' + Limits.getQueries());
        } 
    }//end checkPrepaidBalenceForUser
    
     /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: to add user to account team only for portal user
		Inputs:None
		Returns: void
		Last Modified On : 20 May 2020
		History:
		====================================================
		1.0 20 May 2020 Karan Singh Initial Version
	**/
    //test record ---> TestTeamMember3
    public set< Id > setRecursiveCheckAccntTeam = new set< Id >();
    public static void addUserInAccountTeam(){
        
        set< String > setValidrecordType  = new set< String >();
        set< Id > setValidrecordTypeStu  = new set< Id >();
        map< Id, list< Account > > mapOwnerIdWithAccnts = new map< Id, list< Account > >();
        map< Id, Id > mapOwnerIdWithAccntId = new map< Id, Id >();
        map< Id, list< Contact >> mapAccntWithContacts =  new map< Id, list< Contact > >();
        map< Id,User > mapContactIdWithUser = new  map< Id,User >();
        map< Id, list< Id > > mapOwnerIdWithUserToAdd = new map< Id, list< Id > >();
        set< Id > setContactIds = new set< Id >();
        list< AccountTeamMember > listAccntTeamMember = new list< AccountTeamMember >();
        
        //check if current user is portal user or not
        list< user > listCurrrentUser = [ SELECT Id,isPortalEnabled  FROM User WHERE Id =: UserInfo.getUserId() ];
        
       if(String.isNotBlank(Label.SchoolRecordtypes) && Label.SchoolRecordtypes.contains(';') ){
            
            setValidrecordType.addAll( Label.SchoolRecordtypes.split(';') );
        }else if( String.isNotBlank(Label.SchoolRecordtypes) ){
            
            setValidrecordType.add( Label.SchoolRecordtypes );
        }
        setValidrecordType.add( 'Student Account' );
        
        for( RecordType objRecType : [ SELECT ID,Name FROM RecordType 
                                      WHERE  SobjectType = 'Account' AND Name IN: setValidrecordType ]){
                                          
                                          if( objRecType.Name == 'Student Account' ){
                                              setValidrecordTypeStu.add( objRecType.Id );
                                          }
                                          else{
                                              setValidrecordType.add( objRecType.Id );
                                          }
                                      }
        system.debug('@@@@@@@setValidrecordType  -->  ' + setValidrecordType);
        system.debug('@@@@@@@setValidrecordTypeStu  -->  ' + setValidrecordTypeStu);
        
        for( Account objAcc : ( list< Account > ) trigger.new ){
            
            //if protal user is making it , so he will be the owner, then it will adding accnt records with the owner id
            if( ( listCurrrentUser[0].isPortalEnabled && setValidrecordTypeStu.contains( objAcc.RecordTypeId )) 
              	|| ( listCurrrentUser[0].isPortalEnabled && setValidrecordType.contains( objAcc.RecordTypeId )) ){
                
                    if( !mapOwnerIdWithAccnts.containsKey( objAcc.OwnerId ) )                        
                        mapOwnerIdWithAccnts.put( objAcc.OwnerId, new list< Account > () );
                    
                    mapOwnerIdWithAccnts.get( objAcc.OwnerId ).add( objAcc );
            }
        }//end of triggger.new 
        
        system.debug('@@@@@@@mapOwnerIdWithAccnts  --> ' + mapOwnerIdWithAccnts);
        
        //fecthing the owner's account as Portal user --> contact --> Account
        for( User objUser : [ SELECT Id, contact.AccountId FROM User 
                             WHERE Id IN: mapOwnerIdWithAccnts.keySet() ]){
                                 
                                 if( String.isNotBlank( objUser.contact.AccountId ))
                                 mapOwnerIdWithAccntId.put( objUser.Id, objUser.contact.AccountId );
                             }
        
        system.debug('@@@@@@@mapOwnerIdWithAccntId  --> ' +  mapOwnerIdWithAccntId);
        
        //fetching the account contact's as these contact's user will be added in the Account team
        for( Account objAcc : [ SELECT Id, ( SELECT Id FROM Contacts ) FROM Account 
                               WHERE Id IN: mapOwnerIdWithAccntId.values() ]){
                                   
                                   if( !mapAccntWithContacts.containsKey( objAcc.Id ) )
                                       mapAccntWithContacts.put( objAcc.Id, new list< Contact > () );
                                   
                                   mapAccntWithContacts.get( objAcc.Id ).addAll( objAcc.Contacts );
                                   
                                   setContactIds.addAll( (new map< Id,Contact > (objAcc.Contacts)).keySet());
                               }
        
        system.debug('@@@@@@@mapAccntWithContacts   ->> ' + mapAccntWithContacts );
        
        //now check if those contact user is active or not
        for( User objUser : [ SELECT Id,ContactId from User where isActive = true  AND ContactId IN: setContactIds ] ){
        
            mapContactIdWithUser.put( objUser.ContactId, objUser );
        }//end of user loop
        
        system.debug('@@@@@@@mapContactIdWithUser  --> '+ mapContactIdWithUser);
        
        //now adding the valid COntract user in the map whihc is linked to the Portal user account
        for( Id accntOwnerId : mapOwnerIdWithAccnts.keySet() ){
            
            List< Id > listUserIds = new list< Id >();
            
            system.debug('@@@@@@@accntOwnerId  --> ' + accntOwnerId);
            
            if( mapOwnerIdWithAccntId.containskey( accntOwnerId ) ){
                
                String accountId = mapOwnerIdWithAccntId.get( accntOwnerId );
                system.debug('@@@@@@@accountId --->  ' + accountId);
                if( mapAccntWithContacts.containsKey( accountId ) ){
                    
                    for( Contact objCon : mapAccntWithContacts.get( accountId )){
                        
                        system.debug('@@@@@@@objCon --->  ' + objCon );
                        if( mapContactIdWithUser.containskey( objCon.Id )){
                            system.debug('@@@@@@@mapContactIdWithUser.get( objCon.Id )  --> '+ mapContactIdWithUser.get( objCon.Id ));
                            listUserIds.add( mapContactIdWithUser.get( objCon.Id ).Id );
                        }//end of objCon.Id check
                    }//end of contact loop
                }//end of accountId check
            }//end of accntOwnerId check
            
            mapOwnerIdWithUserToAdd.put( accntOwnerId, listUserIds );
            system.debug('@@@@@@@mapOwnerIdWithUserToAdd  --> ' + mapOwnerIdWithUserToAdd);
            
        }//end of accntOwnerId loop
        
        //now simply adding these user's as account team
        for( Id accntOwnerId : mapOwnerIdWithAccnts.keySet() ){
            
            for( Account objAcc : mapOwnerIdWithAccnts.get( accntOwnerId ) ){
                
                if( mapOwnerIdWithUserToAdd.containsKey( accntOwnerId ) ){
                    
                    for( Id userId : mapOwnerIdWithUserToAdd.get( accntOwnerId ) ){
                        
                        
                        AccountTeamMember objAccTeamMem = new AccountTeamMember();
                        
                        objAccTeamMem.AccountId = objAcc.Id;
                        objAccTeamMem.UserId = userId;
                        objAccTeamMem.TeamMemberRole = 'Sales Rep';
                        objAccTeamMem.AccountAccessLevel = 'Read';
                        objAccTeamMem.CaseAccessLevel = 'Edit';
                        objAccTeamMem.ContactAccessLevel = 'Read';
                        objAccTeamMem.OpportunityAccessLevel= 'Edit';
                        listAccntTeamMember.add(objAccTeamMem);
                        
                    }//end of  userId
                }//end of accntOwnerId check
            }//end of for loop
        }//end of accntOwnerId loop
        
        if( listAccntTeamMember.size() > 0 ){
            database.insert( listAccntTeamMember, false ) ;
            system.debug('@@@@@@@listAccntTeamMember   -->  '+ listAccntTeamMember);
        }
    }//end of method addacoountTeam
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: To populate the Total Actual Amount as per currenct currency rate when currency is changed or new invoice is created.
		Inputs:None
		Returns: void
		Last Modified On : 22 May 2020
		History:
		====================================================
		1.0 22 May 2020 Karan Singh Initial Version
	**/
    public static set< Id > setRecursiveCheckCurrency = new set< Id >();
    public static void checkCurrencyCheck(){
         
         InvoiceTrigger_RollUpInvoiceAmount__c triggerSetting = InvoiceTrigger_RollUpInvoiceAmount__c.getValues('triggerSettings');
        Id recTypAgent = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent_Acquisition').getRecordTypeId();
        map< string,double > mapCurrecyRate = new map< string,double >();
        map< Id,Account > mapValidAccount = new map< Id,Account >();
         List< String > listStatusForRollUp = new List< String >();
        String orgDefaultCurr = UserInfo.getDefaultCurrency();
        
        if( triggerSetting == Null ) return;
        //19 Mar 2020
        if( String.isNotBlank( triggerSetting.Status__c ) ){
            
            if( triggerSetting.Status__c.contains(',') ){
                
                listStatusForRollUp = triggerSetting.Status__c.split(',');
            }else{
                
			listStatusForRollUp.add( triggerSetting.Status__c );
            }
        }
        
        for( Account objAcc : ( List< Account > ) trigger.new ){
            
            //since roll up only work on agent only
            if( objAcc.RecordTypeId != recTypAgent ) continue;
            //for the first time update it should rollup the invoice amount
            if( !setRecursiveCheckCurrency.contains( objAcc.Id ) && String.isNotBlank( objAcc.CurrencyIsoCode )  ){
                
                mapCurrecyRate.put( objAcc.CurrencyIsoCode, Null );
                objAcc.Total_Actual_Amount__c = 0;
                mapValidAccount.put( objAcc.Id, objAcc );
                setRecursiveCheckCurrency.add(objAcc.Id);
            }
            
            else if(setRecursiveCheckCurrency.contains( objAcc.Id ) && String.isNotBlank( objAcc.CurrencyIsoCode )
                    && objAcc.CurrencyIsoCode != (( map< id,Account > )trigger.oldmap ).get( objAcc.Id ).CurrencyIsoCode){
                        
                        mapCurrecyRate.put( objAcc.CurrencyIsoCode, Null );
                        objAcc.Total_Actual_Amount__c = 0;
                        mapValidAccount.put( objAcc.Id, objAcc );
                        setRecursiveCheckCurrency.add(objAcc.Id);
                    }
        }//end of trigger.new Loop
        
        if( mapValidAccount.size() == 0 ) return;
        
        for( DatedConversionRate objConversionRate : [ SELECT Id, isoCode, Conversionrate, nextStartDate, startDate 
                                                      FROM DatedConversionRate   
                                                      ORDER BY NextStartDate DESC ]){ //WHERE isoCode = : mapCurrecyRate.keySet()
                                                          
                                                          if( mapCurrecyRate.containsKey( objConversionRate.IsoCode ))
                                                          if( mapCurrecyRate.get( objConversionRate.isoCode ) == NUll )
                                                              mapCurrecyRate.put( objConversionRate.isoCode,objConversionRate.Conversionrate );
                                                          
                                                      }//end of DatedConversionRate loop
        
        for( Invoice__c objInv : [ SELECT Name,convertCurrency(Amount_Received__c),Company_Name__c,CurrencyIsoCode
                               FROM Invoice__c 
                               WHERE Amount_Received__c <> NULL AND Company_Name__c IN : mapValidAccount.keySet() 
                               AND Invoice_Type__c = : triggerSetting.Invoice_Type__c AND Status__c = :listStatusForRollUp ]){
            
                                   system.debug('@@@@@@@ objInv.Name --> ' +objInv.Name );
                                   system.debug('@@@@@@@ objInv.CurrencyIsoCode --> ' +objInv.CurrencyIsoCode );
                                   system.debug('@@@@@@@ objInv.Company_Name__r.CurrencyIsoCode --> ' +mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode );
                                   system.debug('@@@@@@@ ' + mapCurrecyRate.get( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode ));
                                   system.debug('@@@@@@@ Inv amount' + objInv.Amount_Received__c);
                                   
                                   if(  mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode == orgDefaultCurr ){
                                       
                                       system.debug('@@@@@@@ objInv.Amount_Received__c --> ' +objInv.Amount_Received__c );
                                       
                                       mapValidAccount.get( objInv.Company_Name__c ).Total_Actual_Amount__c +=  objInv.Amount_Received__c;
                                       setRecursiveCheckCurrency.add( mapValidAccount.get( objInv.Company_Name__c ).Id );
                                   }else{
                                       
                                       system.debug('@@@@@@@ converted Amount --> ' +objInv.Amount_Received__c * mapCurrecyRate.get( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode ) );
                                       mapValidAccount.get( objInv.Company_Name__c ).Total_Actual_Amount__c +=  objInv.Amount_Received__c * mapCurrecyRate.get( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode );
                                       setRecursiveCheckCurrency.add( mapValidAccount.get( objInv.Company_Name__c ).Id );
                                   }
                                   system.debug('@@@@@@@ current Amount --> ' +mapValidAccount.get( objInv.Company_Name__c ).Total_Actual_Amount__c );
                                   /*
                                   if( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode == objInv.CurrencyIsoCode ){
                                       
                                       system.debug('@@@@@@@ objInv.Amount_Received__c --> ' +objInv.Amount_Received__c );
                                       
                                       mapValidAccount.get( objInv.Company_Name__c ).Total_Actual_Amount__c +=  objInv.Amount_Received__c;
                                       setRecursiveCheckCurrency.add( mapValidAccount.get( objInv.Company_Name__c ).Id );
                                   }
                                   else{ //mapCurrecyRate.get( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode )
                                       
                                       system.debug('@@@@@@@ converted Amount --> ' +objInv.Amount_Received__c * mapCurrecyRate.get( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode ) );
                                       mapValidAccount.get( objInv.Company_Name__c ).Total_Actual_Amount__c +=  objInv.Amount_Received__c * mapCurrecyRate.get( mapValidAccount.get( objInv.Company_Name__c ).CurrencyIsoCode );
                                       setRecursiveCheckCurrency.add( mapValidAccount.get( objInv.Company_Name__c ).Id );
                                   }
                                   system.debug('@@@@@@@ current Amount --> ' +mapValidAccount.get( objInv.Company_Name__c ).Total_Actual_Amount__c );
									*/
                               }
        
      
    }
    
    //added on 8 June 2020
    //to populate the Agent code from the custom setting.
    //this method is called on after insert as only populate the agent code when it is successFully insert as there might 
    //be case where if it was in before insert then some records are partial save( Database.insert or Dataloader ) then numbering will be wrong
    //change 18 june 2020 as now also create agent code when a sub-agent account to converted into Agent Account
    public static set< Id > setRecursiveCheckAgentCode = new set< Id >();
    public static void populateAgentCode(){

		Id agentrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent_Acquisition').getRecordTypeId();
        Id subAgentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Sub_agency').getRecordTypeId();
		list< Account > listValidAccnt = new list< Account >();
        list< Account > listValidAccntToUpdate = new list< Account >();
        Integer agentCodeCount = 0;
        for( Account objAcc : ( list< Account > ) trigger.new ){
            
            if( String.isNotBlank( objAcc.Id ) &&  setRecursiveCheckAgentCode.contains( objAcc.Id ) ){
            
                continue;
            }
            
            if( trigger.isInsert && String.isNotBlank( objAcc.RecordTypeId )
               && objAcc.RecordTypeId == agentrecordTypeId ){
                
                listValidAccnt.add( objAcc );
                   
            }
            
            //in case of update only once the agent code should be generated
            if( trigger.isUpdate && String.isNotBlank( objAcc.RecordTypeId ) && objAcc.RecordTypeId == agentrecordTypeId 
               && ((map< Id, account >) trigger.OldMap).get( objAcc.Id).RecordTypeId == subAgentRecordTypeId
              && String.isBlank( objAcc.Agent_Code__c ) && String.isBlank( ((map< Id, account >) trigger.OldMap).get( objAcc.Id).Agent_Code__c ) ){
                   
                 listValidAccnt.add( objAcc );  
                  setRecursiveCheckAgentCode.add( objAcc.Id);
               }
        }
        
        if( listValidAccnt.size() > 0 ){
            
            list< Agent_Code_For_Account__c > listAgentCode = [ SELECT Id, AgentCode__c 
                                                               FROM Agent_Code_For_Account__c 
                                                              WHERE Name = 'AccountAgentCode'  FOR UPDATE ];
            
            if( listAgentCode.size() > 0 && listAgentCode[0].AgentCode__c != Null ){
                
                agentCodeCount = Integer.valueOf( listAgentCode[0].AgentCode__c );
            }
            
            system.debug('@@@@ agentCodeCount ---> ' + agentCodeCount);
            for( Account objAccnt : listValidAccnt ){
                
                Account objAccntUpdate = new Account();
                objAccntUpdate.Id = objAccnt.Id;
                
                agentCodeCount = agentCodeCount + 1;

                if( String.valueOf( agentCodeCount ).length() > 4  ){
                    
                    objAccntUpdate.Agent_Code__c = 'A-{' + String.valueOf( agentCodeCount ) + '}';
                }else{
                    
                    String agentCodeTemp = '000'+ String.valueOf( agentCodeCount );
                    objAccntUpdate.Agent_Code__c = 'A-{' + agentCodeTemp.right( 4 ) + '}';
                }
                
                system.debug('@@@@ -->  ' + objAccntUpdate.Agent_Code__c );
                
                listValidAccntToUpdate.add( objAccntUpdate );
            }
            
            update listValidAccntToUpdate;
            
            if( listAgentCode.size() > 0 ){
                
                listAgentCode[0].AgentCode__c = agentCodeCount;
                update listAgentCode;
                
            }else{
                
                Agent_Code_For_Account__c objAgentCode = new Agent_Code_For_Account__c();
                objAgentCode.Name = 'AccountAgentCode';
                objAgentCode.AgentCode__c = agentCodeCount;
                listAgentCode.add( objAgentCode );
                
                insert listAgentCode;
            }
            system.debug('@@@@ ---> ' +listAgentCode );
        }//end of listValidAccnt size check
    }//end of populateAgentCode()
    
     /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: To auto populate the sub agent in Account ( School )in case Portal user is creating it
		Inputs:None
		Returns: void
		Last Modified On : 20 May 2020
		History:
		====================================================
		1.0 20 May 2020 Karan Singh Initial Version
		
	**/    
    public static void autoPopulateSubAgent( list< Account > triggerNew){
        
        list< User > listCurrentUser = [ SELECT Id,IsPortalEnabled,contact.AccountId 
                                        	FROM User 
                                        	WHERE Id = :UserInfo.getUserId() 
                                        	AND IsPortalEnabled = true
                                       	];
        
        if( listCurrentUser.size() > 0 ){
            
            system.debug('listCurrentUser[0].contact.AccountId  --> ' + listCurrentUser[0].contact.AccountId );
            
            
            set< Id > setValidRecTypeId = ( new map< Id, RecordType > ( [ SELECT Id FROM  RecordType WHERE SobjectType = 'Account' 
                                                                         AND DeveloperName In ( 'Overseas_School_CC', 'Overseas_School_HS','Overseas_School_University') 
                                                                         AND isActive = true ] ) ).keySet();
            for( Account objAccnt : triggerNew ){
                
                system.debug('setValidRecTypeId.contains( objCase.RecordTypeId ) ---> ' + setValidRecTypeId.contains( objAccnt.RecordTypeId ));
                if( setValidRecTypeId.contains( objAccnt.RecordTypeId ) ){
                    
                    objAccnt.Sub_agency__c = listCurrentUser[0].contact.AccountId;
                    
                }
            }
        }
    }
}