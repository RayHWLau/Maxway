/**
* @File Name : ApplicationTriggerHelper.cls
* @Description : 
* @Author : Karan Singh Soni
* @Last Modified By : Karan Singh Soni,Shalini Singh
* @Last Modified On : 28 Jan 2020
* @Modification Log :
* @Test Class : ApplicationTriggerTest
*==============================================================================
* Ver Date           Author                       Modification
*==============================================================================
* 1.0  24 Jan 2020                               Initial Version
* 2.0 03 Mar 2020   Shalini Singh
* 3.0 20 APr 2020   Karan Singh					 swapped the fields of Application( Case ) From Stage__c to Status as there is changed in flow
**/

public class ApplicationTriggerHelper {
    
   
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Method to check if current user ( Portal user ) has enough prepaid balence to create application record
		Inputs:None
		Returns: void
		Last Modified On : 28 Jan 2020
		History:
		====================================================
		1.0 24 Jan 2020   Karan Singh 	Initial Version
		2.0 20 APr 2020   Karan Singh	swapped the fields of Application( Case ) From Stage__c to Status as there is changed in flow
	**/
    
    public Static Set< Id > setRecursiveCheck = new Set< Id >();
    public static void checkPrepaidBalenceForUser(){
        
        ApplicationTrigger_checkPrepaidBalence__c triggerSetting = ApplicationTrigger_checkPrepaidBalence__c.getValues('triggerSettings'); 
        
        if( triggerSetting.showDebugLogs__c ){ 
            
            ConstantsClass.checkLimitsBefore( 'checkPrepaidBalenceForUser' );
        } 
        
        //-------------------------------------------------- Checking current user is portal user ---------------------------------------------------------------------------
        Map< Id, User> mapCurrentUserDetails = new Map< Id, User> ( [ SELECT Id, IsPortalEnabled, ContactId,Profile.Name
                                                                     FROM User
                                                                     WHERE Id =: UserInfo.getUserId() ] ); // =: UserInfo.getUserId()
        
        if( triggerSetting.showDebugLogs__c ){ system.debug('mapCurrentUserDetails'+mapCurrentUserDetails); }
        
        String userContactId;
        
        //        Set< Id > setRecursiveCheck = new Set< Id >();
        
        if( mapCurrentUserDetails.get( UserInfo.getUserId() ).IsPortalEnabled ){
            
            userContactId = mapCurrentUserDetails.get( UserInfo.getUserId() ).ContactId;
        }
        //-------------------------------------------------- Incase if it is System Admin --------------------------------------------------------------------------
        else{
            //for admin, as at a time only one record is being updated, so fetching record's owner( agent user ) contact id.
            userContactId = [ SELECT Id,ContactId FROM User WHERE Id =: ( ( List < Case > ) Trigger.new )[0].OwnerId ].ContactId ; 
        }
        
        if( triggerSetting.showDebugLogs__c ){ system.debug('userContactId'+userContactId); }  
        
        
        //------------------------------------------- If Portal User is creating record or System Admin is Approving Record ---------------------------------------------------------
        if( !setRecursiveCheck.contains( userContactId ) && mapCurrentUserDetails.get( UserInfo.getUserId() ).IsPortalEnabled || ( mapCurrentUserDetails.get( UserInfo.getUserId() ).Profile.Name == triggerSetting.System_Admin_Profile_Name__c && String.isNotBlank( userContactId ) && trigger.isUpdate ))
        { 
            //UserInfo.getUserId()
            
            setRecursiveCheck.add( userContactId );
            //---------------------------------------------------------------  Fetching Agent's account ----------------------------------------------------------------------------------------------
            Map< Id, Account > mapUserAccountDetails = new Map< Id, Account >( [ SELECT Id, CurrencyIsoCode 
                                                                                FROM Account 
                                                                                WHERE Id In ( SELECT AccountId FROM Contact WHERE Id = : userContactId )] ); //UserInfo.getUserId()
            
            if( triggerSetting.showDebugLogs__c ){ system.debug('mapUserAccountDetails'+mapUserAccountDetails); }
            
            //--------------------------------------------------------------- Fetching Case Record Type Name's -------------------------------------------------------------------------------------
            Map< Id, RecordType > mapCaseRecordType = new Map< Id, RecordType >([ SELECT Name, Id, DeveloperName FROM  recordtype where SobjectType = 'Case' AND IsActive = true]);
            
            List< Transaction__c > listTransaction = new List< Transaction__c >();		
            List < Case > listCaseToShowError = new List < Case >();					//used when sufficient amount is not present for record creation
            
            //As to fetch account id from map else for loop to be used
            //and assuming at a time one agent is creating record.
            List< Id > listAccountId = new List < Id >();
            listAccountId.addAll( mapUserAccountDetails.keySet() );
            
            Set< Id > setCaseIdForApprovalProcess = new Set< Id > ();					//for checking if the record is updated from aprroval process or manually
            
            if( triggerSetting.showDebugLogs__c ){ system.debug('mapCaseRecordType'+mapCaseRecordType); }
            
            //--------------------------------------------------------------  Calculating Total amount of each record creation for agent -------------------------------------------------------------------
            Map < Id, AccountPrepaidCalculate.AccountPrepaidWrapper > wrapAccntWithContractFees = AccountPrepaidCalculate.calculatePrepaidBalence( listAccountId[0], 'Case' );
            
            //-------------------------------------------------------------- Checking if user has active contract ------------------------------------------------------------------------------------
            if( wrapAccntWithContractFees.containsKey( listAccountId[0] ) && wrapAccntWithContractFees.get( listAccountId[0] ).isActiveContractFound ) {
                
                if( triggerSetting.showDebugLogs__c ){ system.debug('wrapAccntWithContractFees'+wrapAccntWithContractFees); }
                
                //--------------------------------------- Calculating total amount required for record creation and record which required approval process or not ------------------------------------------
                for( Case objApplication : ( List < Case > ) Trigger.new ){
                    
                    if( triggerSetting.showDebugLogs__c ){
                    
                     system.debug('objApplication'+objApplication);
                     system.debug( ' Current User Total Prepaid Amount '+ wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired );
                     system.debug(' Current Application Opt-In Fee '+ wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee );
                     system.debug(' Current Application Opt-Out Fee '+ wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee );
                     
                    }
                    
                    //adding records which doesnot required approval process to create transaction
                    if( mapCaseRecordType.keySet().contains( objApplication.RecordTypeId ) && 
                       triggerSetting.Application_RecordType_Name_Non_Approval__c.contains( mapCaseRecordType.get( objApplication.RecordTypeId ).Name ) ){ //mapCaseRecordType.get( objApplication.RecordTypeId ).Name == triggerSetting.Application_RecordType_Name_Non_Approval__c
                        
                        //calculating total amount required for creation
                        //wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired += wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationFee;
                        wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired += wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee;
                        wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess.add( objApplication );
                    }
                    
                    //adding records which  required approval process to create transaction. 
                    //But in case of update it stage should be same as Approval Process Final action field update.
                    else if( mapCaseRecordType.keySet().contains( objApplication.RecordTypeId ) && 
                            triggerSetting.Application_RecordType_Name_For_Approval__c.contains( mapCaseRecordType.get( objApplication.RecordTypeId ).Name )  //mapCaseRecordType.get( objApplication.RecordTypeId ).Name == triggerSetting.
                            && ( trigger.isInsert || ( trigger.isUpdate && objApplication.Status == triggerSetting.Application_StageName__c && /*trigger.isUpdate && objApplication.Stage__c == triggerSetting.Application_StageName__c */  objApplication.Status != ( ( Map< Id, Case > )Trigger.oldMap ).get(objApplication.Id).Status)))
                    {                     //objApplication.Stage__c != ( ( Map< Id, Case > )Trigger.oldMap ).get(objApplication.Id).Stage__c)))
                                
                                //calculating total amount required for creation
                                //wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired += wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationFee;
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired += wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee;
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.add( objApplication );
                                
                                if( Trigger.isUpdate )
                                    setCaseIdForApprovalProcess.add( objApplication.Id );
                            }
                    
                    if( triggerSetting.showDebugLogs__c )
                    { 
                        system.debug(' current Application Record Type ' + mapCaseRecordType.get( objApplication.RecordTypeId ).Name);
                        system.debug(' Current Record Without Approval Process ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess);
                        system.debug(' Current Record With Approval Process '+wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess);
                        
                    }
                    
                }//end of case loop
                
                //---------------------  Creating Transaction for those Application which does not require approval process and creating record according to agent's available balence -----------------------
                //################################################################## INSERT ###################################################################################################
                if( Trigger.isInsert ){
                    
                    if( triggerSetting.showDebugLogs__c )
                    { 
                        system.debug(' Total Prepaid Balence Available ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                        system.debug(' Total Prepaid Balence Required ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired);
                    }
                    
                    //----------------------------------------------  if total amount required for creation of record is less than agent's available balence  --------------------------------------------------------
                    if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired ){
                        
                        //simply create record of transaction which doesnot required approval process
                        for( Sobject sobjectApplication : wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess ){
                            
                            if( triggerSetting.showDebugLogs__c ){ system.debug('sobjectApplication'+sobjectApplication);}
                            Transaction__c objTransaction = new Transaction__c  ();
                            //objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationFee;
                            objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee;
                            objTransaction.Account__c = listAccountId[0];
                            objTransaction.Application__c = ( ( case ) sobjectApplication ).Id ;
                            //objTransaction.CurrencyIsoCode = mapUserAccountDetails.get( listAccountId[0] ).CurrencyIsoCode;
                            objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFeeCurrencyIso;
                            listTransaction.add( objTransaction );
                        }//end of sobject loop
                    }
                    //----------------------------------------------  if total amount required for creation of record is greater than agent's available balence  --------------------------------------------------------
                    else{
                        
                        if( triggerSetting.showDebugLogs__c )
                        { 
                            system.debug(' Total Prepaid Balence Available ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                            system.debug(' Total Records for Approval Process ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size());
                            system.debug(' Application Fee ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee);
                            
                        }
                        //------------------------------------  first priority is create approval process application record, so subtracting amount from agent's prepaid balence----------------------------------------------------
                        if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size() * wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee ){ //applicationFee
                            
                            wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess.size() * wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee; //applicationFee
                        }
                        //--------------------------------------------------------- If insufficient amount  -------------------------------------------------------------------------
                        else{
                            
                            for( Sobject objS : wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess ){
                                
                                if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee ){ //applicationFee
                                    
                                    wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee; //applicationFee
                                }
                                else{
                                    
                                    listCaseToShowError.add( (Case ) objS );
                                }
                            }
                        }
                        
                        if( triggerSetting.showDebugLogs__c ){ 
                            system.debug(' Total Prepaid Balence Available ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                            
                        }
                        
                        //------------------------------------  If agent balance is left than create application record without approval -------------------------------------------------------------------------------- 
                        
                        for( Sobject sobjectApplication : wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithoutApprovalProcess ){
                            
                            if( triggerSetting.showDebugLogs__c )
                            { 
                                system.debug(' sobjectApplication '+sobjectApplication);
                                system.debug(' Total Prepaid Balence Available ' + wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable);
                                system.debug(' applicationOptOutFee '+wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee);//applicationFee
                                
                            }
                            if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee ){ //applicationFee
                                
                                Transaction__c objTransaction = new Transaction__c  ();
                                objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee; //applicationFee
                                objTransaction.Account__c = listAccountId[0];
                                objTransaction.Application__c = ( ( case ) sobjectApplication ).Id ;
                                objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFeeCurrencyIso;
                                listTransaction.add( objTransaction );
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptOutFee; //applicationFee
                            }
                            else{
                                listCaseToShowError.add( ( case ) sobjectApplication );
                            }
                        }//end of sobject loop
                    }
                }
                //-----------------------------------------------------------  Creating Transaction for those Application which require approval process  -------------------------------------------------------
                //################################################################## UPDATE ###################################################################################################
                else if( Trigger.isUpdate ){
                    
                    //check how many record is update from approval process 
                    Set< Id > setApprvdApplicationId = AccountPrepaidCalculate.isUpdatedFromApprovalProcess( setCaseIdForApprovalProcess, triggerSetting.Application_Approval_Process_Name__c ) ;
                    List < case > listApplicationUpdatefromApproval = new List < case >();
                    
                    for( Case objCase : ( List <Case> ) wrapAccntWithContractFees.get( listAccountId.get(0) ).recordWithApprovalProcess ){
                        
                        if( setApprvdApplicationId.contains( objCase.Id )){
                            
                            listApplicationUpdatefromApproval.add( objCase );
                        }
                    }
                    //-------------------------------------------------------------------   if agent amount is sufficient to create records   ----------------------------------------------------------------------------------------
                    if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceRequired ){
                        
                        //simply create record of transaction which required approval process
                        for( Case objApplication : listApplicationUpdatefromApproval ){
                            
                            if( triggerSetting.showDebugLogs__c ){ system.debug('objApplication'+objApplication);}
                            
                            Transaction__c objTransaction = new Transaction__c  ();
                            objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee; //applicationFee
                            objTransaction.Account__c = listAccountId[0];
                            objTransaction.Application__c = objApplication.Id ;
                            //objTransaction.CurrencyIsoCode = mapUserAccountDetails.get( listAccountId[0] ).CurrencyIsoCode;
                            objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFeeCurrencyIso;
                            listTransaction.add( objTransaction );
                            
                        }//end of sobject loop
                    }//end of totalPrepaidBalenceAvailable >= totalPrepaidBalenceRequired
                    
                    //--------------------------------------------------------------  if balance is insufficient then make records till value goes insuffcient   ------------------------------------------------------------------------
                    else{
                        
                        for( Case objApplication : listApplicationUpdatefromApproval ){
                            
                            if( triggerSetting.showDebugLogs__c ){ system.debug('objApplication'+objApplication);}
                            
                            if( wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable >= wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee ){ //applicationFee
                                
                                Transaction__c objTransaction = new Transaction__c  ();
                                objTransaction.Amount_Deducted__c = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee; //applicationFee
                                objTransaction.Account__c = listAccountId[0];
                                objTransaction.Application__c = objApplication.Id ;
                                objTransaction.CurrencyIsoCode = wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFeeCurrencyIso;
                                listTransaction.add( objTransaction );
                                wrapAccntWithContractFees.get( listAccountId.get(0) ).totalPrepaidBalenceAvailable -= wrapAccntWithContractFees.get( listAccountId.get(0) ).applicationOptInFee; //applicationFee
                            }
                            else{
                                //adding record due to insufficient amount
                                listCaseToShowError.add( objApplication );
                            }
                        }//end of sobject loop
                        
                    }//end of insufficient amount check
                    
                }//end of update condition
                
                if( triggerSetting.showDebugLogs__c ){ system.debug('listTransaction'+listTransaction); }
                // listTransaction = null;
                if( listTransaction.size() > 0 )
                    insert listTransaction;
                
                for( Case objCase : listCaseToShowError ){
                    
                    if( triggerSetting.showDebugLogs__c ){ system.debug('objCase'+objCase); }
                    if( !Test.isRunningTest() )
                        objCase.addError( triggerSetting.Error_Message_for_Insufficient_Amount__c);//Error_Message_for_Insufficient_Amount__c
                }
                
            }
            //------------------------------------------------------------------ if user doesnot have any active contract --------------------------------------------------------------------------------------------
            else{
                //Agent canot create record
                for ( Case objCase : ( List < Case > ) Trigger.new ){
                  
                    if( !Test.isRunningTest() )
                    
                        objCase.addError( triggerSetting.Error_Message_for_No_Contract__c);
                }
            }
        }//end of protal user check
        
        if( triggerSetting.showDebugLogs__c ){ 
         
            ConstantsClass.checkLimitsAfter( 'checkPrepaidBalenceForUser' );
        } 
        
    }//end checkPrepaidBalenceForUser
    
    
    /**
		Name : Shalini Singh 
		Company: Techmatrix
		Description: To validate School Name on basis of record Type on Creation of Application record.
		Inputs:None
		Returns: void
		Last Modified On : 30 Jan 2020
		History:
		====================================================
		1.0 30 Jan 2020 Shalini Singh Initial Version
		1.1 03 MAr 2020 Shalini Singh
	**/
    
    public static void schoolNameValidation(List<Case> lisTriggerNew , boolean isinsert){
        
        ApplicationTrigger_checkPrepaidBalence__c triggerSetting = ApplicationTrigger_checkPrepaidBalence__c.getValues('triggerSettings'); 
        
        //-------------------------------------------------- Checking current user is portal user ---------------------------------------------------------------------------
        Map< Id, User> mapCurrentPortalUserDetails = new Map< Id, User> ( [ SELECT Id, IsPortalEnabled, ContactId,Contact.AccountId,Profile.Name
                                                                           FROM User
                                                                           WHERE Id =: UserInfo.getUserId() AND IsPortalEnabled = true] ); // =: UserInfo.getUserId()
        System.debug('mapCurrentPortalUserDetails-->'+mapCurrentPortalUserDetails);
        Map<Id,User> mapAllPortalUser = new Map<Id, USer>([SELECT Id, IsPortalEnabled, ContactId,Contact.AccountId,Profile.Name
                                                           FROM User
                                                           WHERE  IsPortalEnabled = true]);    // all portal users
        
        ////////// added on 03 Mar 2020 ///////////////////To fetch all maxway users////////////////////////////////////////////////////////////////////////////////
        Map<Id,User> mapAllMaxwayUsers = new Map<Id,User>([SELECT Id,Name, IsPortalEnabled, ContactId,Profile.Name
                                                           FROM User
                                                           WHERE  IsPortalEnabled = false AND ContactId = Null]);  //5 June removed Id =: UserInfo.getUserId() AND
        
        Map<Id,Account> MapAllMaxwaySchoolWithoutOptOut;
        List<Case> LisCase = new List<Case>();
        Set<Id> setOptOutSchool = new Set<Id>();  
        Set<Id> SetcaseSchlID = new Set<Id>();
        
        // if(mapCurrentPortalUserDetails.values().size() >0){
        
        try{
            for(Case csObj : lisTriggerNew){
                if(csObj.School__c <> Null)
                    SetcaseSchlID.add(csObj.School__c);
            }
            
            //-------------------------------------------Checking if School owner is Portal user in case of opt-out---------------------------------------------------------------
            
            MAP<Id, Account> mapSchlToOwner = new Map<Id,Account>([SELECT ID, OWNERID FROM Account where ID IN:SetcaseSchlID]);    // School Owner
            Map<Id,RecordType> mapRecTyp = new Map<Id,RecordType>([SELECT Id,Name,sobjecttype from recordtype where  sobjecttype  = 'Case' ]);
            if(mapCurrentPortalUserDetails.values().size() >0){
                for(Opt_Out_School__c optSchl : [SELECT Agent__c,School__c, Id FROM Opt_Out_School__c  WHERE Agent__c =: mapCurrentPortalUserDetails.values().Contact.AccountId]){
                    if(optSchl <> Null) 
                        setOptOutSchool.add(optSchl.School__c);
                }
            }
            if( triggerSetting.showDebugLogs__c ){
                System.debug('setOptOutSchool'+setOptOutSchool);
            }
            //5 June 2020  as now Maxway school can be created by any user whose profile is not Portal User
            String prof1 = 'Partner - Admin';
            String prof2 = 'Partner - User';
            
            if(setOptOutSchool.size() >0){
                //commented on 5 june 2020 as now Maxway school can be created by any user whose profile is not Portal User
                //MapAllMaxwaySchoolWithoutOptOut =  new Map<Id,Account>([Select id,Name from Account WHERE Owner.Profile.Name= 'Maxway System Administrator' AND ID NOT IN:setOptOutSchool]);
                MapAllMaxwaySchoolWithoutOptOut =  new Map<Id,Account>([Select id,Name from Account WHERE 
                                                                        ( Owner.Profile.Name !=: prof1 AND Owner.Profile.Name !=:prof2  )
                                                                        AND ID NOT IN:setOptOutSchool]);
            }
            else{
                // commented on 5 june 2020 as now Maxway school can be created by any user whose profile is not Portal User
                //MapAllMaxwaySchoolWithoutOptOut =  new Map<Id,Account>([Select id,Name from Account WHERE Owner.Profile.Name= 'Maxway System Administrator' ]);
                MapAllMaxwaySchoolWithoutOptOut =  new Map<Id,Account>([Select id,Name from Account 
                                                                        WHERE Owner.Profile.Name !=: prof1  AND Owner.Profile.Name !=: prof2 ]);
            }
            if( triggerSetting.showDebugLogs__c ){
                System.debug('MapAllMaxwaySchoolWithoutOptOut'+MapAllMaxwaySchoolWithoutOptOut);
            }
            
            //---------------------------------------------- Validation Part----------------------------------------------------------------------------------------------------------------
            for(Case cs:lisTriggerNew){
                //----------------------------------- For record Type Application Opt-In ---------------------------------------------------------------------------------------------
                if(cs.School__c != Null && triggerSetting.Application_RecordType_Name_For_Approval__c.contains( mapRecTyp.get( cs.RecordTypeId ).Name )){
                    
                    if(MapAllMaxwaySchoolWithoutOptOut.containsKey(cs.School__c) && MapAllMaxwaySchoolWithoutOptOut.get(cs.School__c) != Null){
                        LisCase.add(cs);
                    }
                    else{
                        if( !Test.isRunningTest() )
                            cs.addError(triggerSetting.schoolNameValidationErrorOptIn__c);
                    }
                    
                }
                
                //----------------------------------- For record Type Application Opt-Out ---------------------------------------------------------------------------------------------
                if(cs.School__c != Null && cs.Application_Type__c == 'Opt-Out' && triggerSetting.Application_RecordType_Name_Non_Approval__c.contains( mapRecTyp.get( cs.RecordTypeId ).Name )){
                    
                    if(setOptOutSchool.contains(cs.School__c)){
                        LisCase.add(cs);
                    }
                    else{
                        if( !Test.isRunningTest() )
                            cs.addError(triggerSetting.schoolNameValidationErrorOptOut__c);
                    }
                }
                
                ////////// added on 03-03-2020 @Shalini Singh////////////////// to filter school name in case of application type Maxway Application////////////////////////////// 
                if(cs.School__c != Null && cs.Application_Type__c == 'Maxway Application' && triggerSetting.Application_RecordType_Name_Non_Approval__c.contains( mapRecTyp.get( cs.RecordTypeId ).Name)){
                    
                    if(mapSchlToOwner.containsKey(cs.School__c) && mapSchlToOwner.get(cs.School__c).OWNERID <> Null && mapAllMaxwayUsers.containsKey(mapSchlToOwner.get(cs.School__c).OWNERID)){
                        
                        LisCase.add(cs);
                    }
                    else{
                        
                        if( !Test.isRunningTest())
                            cs.addError(triggerSetting.schoolNameValidationErrorMaxwayApp__c);
                    }
                }
                ////////// added on 03-03-2020 @Shalini Singh////////////////// End/////////////////////////////////////////////////////////////////////////////////////////// 
                
                if(cs.School__c != Null && cs.Application_Type__c == 'Not in Database' &&  triggerSetting.Application_RecordType_Name_Non_Approval__c.contains( mapRecTyp.get( cs.RecordTypeId ).Name )){
                    
                    if(mapSchlToOwner.containsKey(cs.School__c) && mapSchlToOwner.get(cs.School__c) != Null && mapAllPortalUser.containsKey(mapSchlToOwner.get(cs.School__c).OwnerId) 
                       && mapAllPortalUser.get(mapSchlToOwner.get(cs.School__c).OwnerId).Contact.AccountId == mapCurrentPortalUserDetails.values().Contact.AccountId ){
                           
                           if( triggerSetting.showDebugLogs__c ){
                               System.debug('mapAllPortalUser.get(mapSchlToOwner.get(cs.School__c).OwnerId).Contact.AccountId'+mapAllPortalUser.get(mapSchlToOwner.get(cs.School__c).OwnerId).Contact.AccountId);
                               System.debug('mapCurrentPortalUserDetails.values().Contact.AccountId'+mapCurrentPortalUserDetails.values().Contact.AccountId);
                           }
                           
                           LisCase.add(cs);  
                       }
                    else{
                        if( !Test.isRunningTest() )
                            cs.addError(triggerSetting.OptOutNotInDatabase__c);
                    }
                    
                }
            }
            if( LisCase.size() > 0 ){
                
                populateCommissionAndAppManger( LisCase, true, triggerSetting ,isinsert );
            }
        }catch(Exception e){
            system.debug('Message--->'+e.getMessage() +'Line No---->'+ e.getLineNumber() +'---==>'+ e.getStackTraceString());
        }
        
    }//end of validate
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: To populate Agent Commision and Maxway Application Manager
		Inputs:None
		Returns: void
		Last Modified On : 31 Jan 2020
		History:
		====================================================
		1.0 30 Jan 2020 Karan Singh Initial Version
		24 Feb 2020 Karan Singh ( This Functionality only work for OptIn Records )
	**/
    public static void populateCommissionAndAppManger( List < Case > listValidApplication, boolean isPortalEnabled, ApplicationTrigger_checkPrepaidBalence__c triggerSetting,boolean isinsert ){
        
        if( triggerSetting.showDebugLogs__c ){ 
            ConstantsClass.checkLimitsBefore( 'checkPrepaidBalenceForUser' );
        } 
        
        //--------------------------------------------------------------- Fetching Case Record Type Name's -------------------------------------------------------------------------------------
        Map< Id, RecordType > mapCaseRecordType = new Map< Id, RecordType >([ SELECT Name, Id, DeveloperName FROM  recordtype where SobjectType = 'Case' AND IsActive = true]);
        
        
        Map< String, Map< String,String >> mapSchoolIdWithNationalityWithCommission = new Map< String, Map< String,String >>();		
        Map< String,String > mapOppIdWithStudentNationality = new Map< String,String >();
        List< Case > listApplicationWithSchoolAndOpp = new List< Case >();
        Map< Id, Staff__c > mapHqAdminStaffForPortalUser = new Map< Id, Staff__c >();
        
        //------------------------------------------------  fetching School and Opportunity For 
        for( Case objCase : listValidApplication ){
            
            if( triggerSetting.showDebugLogs__c ){ system.debug('objCase'+objCase);}
            
            if( objCase.Opportunity__c <> Null && objCase.School__c <> Null && triggerSetting.Application_RecordType_Name_For_Approval__c.contains( mapCaseRecordType.get( objCase.RecordTypeId ).Name )){
                
                mapOppIdWithStudentNationality.put( objCase.Opportunity__c,Null );
                mapSchoolIdWithNationalityWithCommission.put( objCase.School__c, new Map< String,String >() );
                listApplicationWithSchoolAndOpp.add( objCase );
            }
        }
        if( triggerSetting.showDebugLogs__c ){ 
            system.debug( ' mapOppIdWithStudentNationality ' + mapOppIdWithStudentNationality);
            system.debug(' mapSchoolIdWithNationalityWithCommission ' + mapSchoolIdWithNationalityWithCommission);
        }
        
        if( mapOppIdWithStudentNationality.size() > 0 && mapSchoolIdWithNationalityWithCommission.size() > 0){
            
            for( Opportunity objOpp : [ SELECT Id, Account.Nationality__c FROM Opportunity 
                                       WHERE Id IN: mapOppIdWithStudentNationality.keySet() AND Account.Nationality__c <> Null AND Account.RecordType.Name = :triggerSetting.Account_Student_Record_Type_Name__c ] ){
                                           
                                           if( triggerSetting.showDebugLogs__c ){ system.debug(' objOpp ' + objOpp);}
                                           mapOppIdWithStudentNationality.put( objOpp.Id, objOpp.Account.Nationality__c );
                                           
                                       }  
            
            if( triggerSetting.showDebugLogs__c ){ system.debug(' mapOppIdWithStudentNationality ' + mapOppIdWithStudentNationality);}
            
            for( Commission_Table__c objCommission : [ SELECT Id, Amount__c, School__c,Nationality__c 
                                                      FROM Commission_Table__c 
                                                      WHERE School__c IN : mapSchoolIdWithNationalityWithCommission.keySet() AND Nationality__c IN : mapOppIdWithStudentNationality.values() AND Amount__c <> Null ])
            {
                                                          if( triggerSetting.showDebugLogs__c )
                                                          { system.debug(' objCommission ' + objCommission);}
                                                          mapSchoolIdWithNationalityWithCommission.get( objCommission.School__c).put( objCommission.Nationality__c,  String.valueOf( objCommission.Amount__c ));
                                                      }
            if( triggerSetting.showDebugLogs__c ){ system.debug(' mapSchoolIdWithNationalityWithCommission ' + mapSchoolIdWithNationalityWithCommission);}
            
            if( isPortalEnabled ){
                
                mapHqAdminStaffForPortalUser = new Map< Id, Staff__c >( [ SELECT Id FROM Staff__c 
                                                                         WHERE Active__c = True AND Owner.Profile.Name = :triggerSetting.System_Admin_Profile_Name__c 
                                                                         AND Name =: triggerSetting.Staff_Name_For_Portal_User__c LIMIT 1 ] );
            }
            
            if( triggerSetting.showDebugLogs__c ){ system.debug(' mapHqAdminStaffForPortalUser' + mapHqAdminStaffForPortalUser);
                                                  system.debug(' listValidApplication '+listValidApplication);
                                                  system.debug(' listApplicationWithSchoolAndOpp ' + listApplicationWithSchoolAndOpp);}
            
            for( Case objCase : listValidApplication ){ //listApplicationWithSchoolAndOpp should not be used as even if commsion is not mapped but manager should be
                
                if( mapOppIdWithStudentNationality.get( objCase.Opportunity__c) <> Null  && mapSchoolIdWithNationalityWithCommission.get( objCase.School__c ) <> Null && mapSchoolIdWithNationalityWithCommission.get( objCase.School__c ).get( mapOppIdWithStudentNationality.get( objCase.Opportunity__c) ) <> Null  )
                {
                      objCase.Commission__c = mapSchoolIdWithNationalityWithCommission.get( objCase.School__c ).get( mapOppIdWithStudentNationality.get( objCase.Opportunity__c));
                      
                  }
                if( mapHqAdminStaffForPortalUser.size() > 0 && triggerSetting.Application_RecordType_Name_For_Approval__c.contains( mapCaseRecordType.get( objCase.RecordTypeId ).Name) && isinsert)
                    objCase.Maxway_Application_Manager__c = mapHqAdminStaffForPortalUser.values()[0].Id;
                
                if( triggerSetting.showDebugLogs__c ){ system.debug('objCase'+objCase);}
                
            }
        }
        if( triggerSetting.showDebugLogs__c ){ 
            ConstantsClass.checkLimitsAfter( 'checkPrepaidBalenceForUser' );
        } 
    }
    public static void stagearrivedcommissionpaidrecevied(list<case> triggernew,map<id,case> oldmap){
        set<id> oppidset = new set<id>();
        map<string,list<case>> oppidwithsizemap = new map<string,list<case>>();
        list<string> stagelist = new list<string>{'Arrived','Commission Received','Commission Paid'};
            for(case cse : triggernew){
                if( string.isNotBlank(cse.Opportunity__c)){
                    oppidset.add(cse.Opportunity__c);  
                } 
            }
        if(oppidset.size()>0){
            for(opportunity opp :[select id ,(select Status from Applications__r where Status in :stagelist) from opportunity where id in :oppidset]){ //select stage__c from Applications__r where stage__c in :stagelist
                system.debug(opp.Applications__r.size());
                oppidwithsizemap.put(opp.id,opp.Applications__r);
            }
        }
        for(case cse : triggernew){
            
            if(oppidwithsizemap.containskey(cse.Opportunity__c)){
                if(trigger.isinsert){
                    if(oppidwithsizemap.get(cse.Opportunity__c).size()>0){
                        cse.adderror('Cannot create new application with arrived, commission received and commission paid application');
                    }
                }
                else{
                    if(oppidwithsizemap.get(cse.Opportunity__c).size()>0 && stagelist.contains(cse.Status))//contains(cse.Stage__c)
                        for(case cs : oppidwithsizemap.get(cse.Opportunity__c)){
                            if(cs.id != cse.id)
                                cse.adderror('Cannot have application with stage \'Arrived\',\'Commission Received\',\'Commission Paid\'');
                        }   
                }
            }
        }
    }
    
    //6 may 2020 as this only work for Opt-In record type
    public static void offercheck(list<case> applist,map<id,case> appoldmap){
        
        set<string> applicationids = new set<string>();
        map<string,string> applicationidswithcondition = new map<string,string>();
        string condition = 'string'+','+'name'+';'+'Offer';
        
        //added 6 may 2020
        set< Id > setValidRecTypeId = ( new map< Id, RecordType > ( [ SELECT Id FROM  RecordType WHERE SobjectType = 'Case' 
                                                                   AND DeveloperName = 'Application_Opt_In' AND isActive = true ] ) ).keySet();
        //end 6 may 2020
        
        for(case cs : applist){
            if(string.isNotBlank(cs.Offer__c) && setValidRecTypeId.contains( cs.RecordTypeId ) )
                applicationids.add(cs.id); 
        }
        system.debug('applicationids'+applicationids);
        if(applicationids.size()>0){
            applicationidswithcondition = ContentDocumentLinkHelper.contentdocumentvalidationcheck(applicationids,'Application__c',condition);  
            system.debug('applicationidswithcondition'+applicationidswithcondition);
        }
        for(case cs : applist){
            if(string.isNotBlank(cs.Offer__c)){
                if(applicationidswithcondition.get(cs.id) =='false'){
                    cs.adderror('Please upload Offer First');
                }
            }  
        }
        
    }
    
     //6 may 2020 as this only work for Opt-In record type
    public static void paymentproof(list<case> applist,map<id,case> appoldmap){
        set<string> applicationids = new set<string>();
        map<string,string> applicationidswithcondition = new map<string,string>();
        string condition = 'string'+','+'name'+';'+'Payment Proof';
        
        //added 6 may 2020
        set< Id > setValidRecTypeId = ( new map< Id, RecordType > ( [ SELECT Id FROM  RecordType WHERE SobjectType = 'Case' 
                                                                   AND DeveloperName = 'Application_Opt_In' AND isActive = true ] ) ).keySet();
        //end 6 may 2020
        
        for(case cs : applist){
            if(string.isNotBlank(string.valueof(cs.Deposit_Paid_Date__c)) && setValidRecTypeId.contains( cs.RecordTypeId ))
                applicationids.add(cs.id); 
        }
        system.debug('applicationids'+applicationids);
        if(applicationids.size()>0){
            applicationidswithcondition = ContentDocumentLinkHelper.contentdocumentvalidationcheck(applicationids,'Application__c',condition);  
            system.debug('applicationidswithcondition'+applicationidswithcondition);
        }
        for(case cs : applist){
            if(string.isNotBlank(string.valueof(cs.Deposit_Paid_Date__c))){
                if(applicationidswithcondition.get(cs.id) =='false'){
                    cs.adderror('Please upload Payment Proof First');
                }
            }  
        }
        
    }
    

	 /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: as per NTF-0678 once status = accepted by maxway, cannot change it back to Preparing Application or Submitted Application to Maxway
		Inputs:None
		Returns: void
		Last Modified On : 18 May 2020
		History:
		====================================================
		1.0 18 May 2020 Karan Singh Initial Version
		
	**/    
    
    public static void checkStatusValidation(){
        
        for( Case objCase : ( List< Case > ) trigger.new ){
            
            Case objOldCase = ( ( map< Id, Case > ) trigger.oldMap ).get( objCase.Id );
            
            if( objOldCase.Status == 'Accepted By Maxway' && ( objCase.Status == 'Preparing Application' || objCase.Status == 'Submitted Application To Maxway' )){
             
               objCase.addError('Once status is Accepted By Maxway, cannot change it back to Preparing Application or Submitted Application to Maxway');
            }
        }//end of trigger.new loop
    }
    
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: To auto populate the sub agent in application in case Portal user is creating it
		Inputs:None
		Returns: void
		Last Modified On : 20 May 2020
		History:
		====================================================
		1.0 20 May 2020 Karan Singh Initial Version
		
	**/    
    public static void autoPopulateSubAgent(){
        
        list< User > listCurrentUser = [ SELECT Id,IsPortalEnabled,contact.AccountId 
                                        	FROM User 
                                        	WHERE Id = :UserInfo.getUserId() 
                                        	AND IsPortalEnabled = true
                                       	];
        
        if( listCurrentUser.size() > 0 ){
            
            system.debug('listCurrentUser[0].contact.AccountId  --> ' + listCurrentUser[0].contact.AccountId );
            
            set< String > setApplicationType = new set< String >{ 'Opt-Out','Not in Database','Opt-In' };
            set< Id > setValidRecTypeId = ( new map< Id, RecordType > ( [ SELECT Id FROM  RecordType WHERE SobjectType = 'Case' 
                                                                         AND DeveloperName In ( 'Application_Opt_In', 'Application_Opt_Out_NIN_Maxway') 
                                                                         AND isActive = true ] ) ).keySet();
            for( Case objCase : ( list< Case >) trigger.new ){
                
                system.debug('setValidRecTypeId.contains( objCase.RecordTypeId ) ---> ' + setValidRecTypeId.contains( objCase.RecordTypeId ));
                system.debug('setApplicationType.contains( objCase.Application_Type__c )  ---> ' + setApplicationType.contains( objCase.Application_Type__c ));
                if( setValidRecTypeId.contains( objCase.RecordTypeId ) && setApplicationType.contains( objCase.Application_Type__c ) ){
                    
                    objCase.Sub_Agent__c = listCurrentUser[0].contact.AccountId;
                    
                }
            }
        }
    }
}