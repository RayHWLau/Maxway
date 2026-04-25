/**
* @File Name : AccountPrepaidCalculate.cls
* @Description : Tocheck if current agent has enough prepaid balence to create records
* @Author : Karan Singh Soni
* @Last Modified By : Karan Singh Soni
* @Last Modified On : 11 Feb 2020
* @Test Class : ApplicationTriggerTest
* @Modification Log :
*==============================================================================
* Ver Date Author Modification
*==============================================================================
* 1.0  27 Jan 2020 Initial Version
**/


public class AccountPrepaidCalculate {
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Method to calculate the record creation fee from the Agent's contract line item
		Inputs: None
		Returns: void
		Last Modified On : 11 Feb 2020
		History:
		====================================================
		1.0 24 Jan 2020 Karan Singh Initial Version
			1.1 23 may 2020 adding currency iso on contract item
	**/
    public Static Map< Id, AccountPrepaidWrapper > calculatePrepaidBalence( Id accntId, String objType ){
        
        String contractStatus;
        String Contract_Line_Item_Record_Name;
        Boolean showDebugLogs;
        String Application_Tariff_Type;
        String Student_Tariff_Type;
        String School_Tariff_Type;
        
        if( objType == 'Account' ){
            
            AccountTrigger_checkPrepaidBalence__c triggerSettings = AccountTrigger_checkPrepaidBalence__c.getValues('triggerSettings'); 
            contractStatus = triggerSettings.Contract_Status__c;
            Contract_Line_Item_Record_Name = triggerSettings.Contract_Line_Item_Record_Name__c;
            showDebugLogs = triggerSettings.showDebugLogs__c;
            Application_Tariff_Type = triggerSettings.Application_Tariff_Type__c;
            Student_Tariff_Type = triggerSettings.Student_Tariff_Type__c;
            School_Tariff_Type = triggerSettings.School_Tariff_Type__c;
            
        }
        else if( objType == 'Case' ){
            
           ApplicationTrigger_checkPrepaidBalence__c triggerSettings = ApplicationTrigger_checkPrepaidBalence__c.getValues('triggerSettings');
            contractStatus = triggerSettings.Contract_Status__c;
            Contract_Line_Item_Record_Name = triggerSettings.Contract_Line_Item_Record_Name__c;
            showDebugLogs = triggerSettings.showDebugLogs__c;
            Application_Tariff_Type = triggerSettings.Application_Tariff_Type__c;
            Student_Tariff_Type = triggerSettings.Student_Tariff_Type__c;
            School_Tariff_Type = triggerSettings.School_Tariff_Type__c;
        }
       
        Map< Id, AccountPrepaidWrapper > wrapAccntWithContractFees = new Map< Id, AccountPrepaidWrapper >();
        
        //------------------------------------------------------------- Fetching Agent's Active Contract ------------------------------------------------------------------------------------------------
        for( Contract objContract : [ SELECT Id, account.Total_Balance_Amount__c, accountId, ( SELECT CurrencyIsoCode,Unit_Price__c,Tariff_Type__c,Opt_In__c,Opt_Out_NIN__c FROM Contract_Items__r WHERE Tariff_Type__c <> Null AND RecordType.Name = : Contract_Line_Item_Record_Name)
                                     FROM Contract 
                                     WHERE ( StartDate <= Today AND EndDate >= Today ) AND Status = : contractStatus AND accountId =: accntId
                                     ORDER BY StartDate ])
        {
            
            if( showDebugLogs ){ system.debug('objContract'+objContract); }
            
            if( !wrapAccntWithContractFees.containsKey( objContract.accountId ) ){
                
                wrapAccntWithContractFees.put( objContract.accountId, new AccountPrepaidWrapper () );
            	wrapAccntWithContractFees.get( objContract.accountId ).isActiveContractFound = true;
            	wrapAccntWithContractFees.get( objContract.accountId ).totalPrepaidBalenceAvailable = objContract.account.Total_Balance_Amount__c;
            }
            
            //setting up record creation amount and should not be over write again if another contract line found with same record creation type ex.school creation
            //In that case, we will use first contract line item amount till it gets expired.
            if( objContract.Contract_Items__r.size() > 0 ){
                
                for( Contract_Item__c objContractItem : objContract.Contract_Items__r ){
                    
                    /*
                    if( objContractItem.Tariff_Type__c == Application_Tariff_Type && wrapAccntWithContractFees.get( objContract.accountId ).applicationFee == 0 )
                        wrapAccntWithContractFees.get( objContract.accountId ).applicationFee = objContractItem.Unit_Price__c;
                    
					 11 Feb 2020 Now application fee will be deducted on the basis of application type( optIn/ optOut ) */
                    
                    if( objContractItem.Tariff_Type__c == Application_Tariff_Type && wrapAccntWithContractFees.get( objContract.accountId ).applicationOptInFee == 0 ){
                        wrapAccntWithContractFees.get( objContract.accountId ).applicationOptInFee = objContractItem.Opt_In__c;
                        wrapAccntWithContractFees.get( objContract.accountId ).applicationOptInFeeCurrencyIso = objContractItem.CurrencyIsoCode;
                    }
                    if( objContractItem.Tariff_Type__c == Application_Tariff_Type && wrapAccntWithContractFees.get( objContract.accountId ).applicationOptOutFee == 0 ){
                        wrapAccntWithContractFees.get( objContract.accountId ).applicationOptOutFee = objContractItem.Opt_Out_NIN__c;
                        wrapAccntWithContractFees.get( objContract.accountId ).applicationOptOutFeeCurrencyIso = objContractItem.CurrencyIsoCode;
                    }
                    if( objContractItem.Tariff_Type__c == Student_Tariff_Type && wrapAccntWithContractFees.get( objContract.accountId ).studentfee == 0 ){
                        wrapAccntWithContractFees.get( objContract.accountId ).studentfee = objContractItem.Unit_Price__c;
                        wrapAccntWithContractFees.get( objContract.accountId ).studentfeeCurrencyIso = objContractItem.CurrencyIsoCode;
                    }
                    if( objContractItem.Tariff_Type__c == School_Tariff_Type && wrapAccntWithContractFees.get( objContract.accountId ).schoolfee == 0 ){
                        wrapAccntWithContractFees.get( objContract.accountId ).schoolfee = objContractItem.Unit_Price__c;
                        wrapAccntWithContractFees.get( objContract.accountId ).schoolfeeCurrencyIso = objContractItem.CurrencyIsoCode;
                    }
                    if( showDebugLogs ){ system.debug('wrapAccntWithContractFees'+wrapAccntWithContractFees); }        
                    
                }
            }
        }
        
        
        return wrapAccntWithContractFees;
    }
    
    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Method to check if the set of record id are updated from specified approval process
		Inputs: None
		Returns: void
		Last Modified On : 28 Jan 2020
		History:
		====================================================
		1.0 24 Jan 2020 Karan Singh Initial Version
	**/
    public Static Set< Id> isUpdatedFromApprovalProcess ( Set< Id > recordIds , String approvalProcessName ){
        
        Set< Id> setIsRecordApproved = new Set< Id>();
        
        //------------------------------------------  Checking if these records are updated from specific approval process  -------------------------------------------------------
        for( ProcessInstance objProcessInstance : [ SELECT Id,TargetObjectId,Status
                                                   FROM ProcessInstance 
                                                   WHERE ProcessDefinition.Name = : approvalProcessName AND TargetObjectId IN : recordIds AND CompletedDate = Today
                                                   Order By CompletedDate DESC Limit 1 ] ){
                                                       
                                                       //if the current approval process is approved from approver
                                                       if( objProcessInstance.Status == 'Approved')
                                                           setIsRecordApproved.add( objProcessInstance.TargetObjectId);
                                                       
                                                   }
        return setIsRecordApproved;
    }
   
    //------------------------------------------------------------------  AccountPrepaidWrapper ----------------------------------------------------------------------------------------------- 
    public class AccountPrepaidWrapper{
        
        public decimal schoolfee;								// Agent's Contract Item School Creation Fee
        public decimal studentfee;								// Agent's Contract Item Student Creation Fee
        public decimal applicationOptInFee;						// Agent's Contract Item Opt In Application Creation Fee
        public decimal applicationOptOutFee;					// Agent's Contract Item Opt Out Application Creation Fee
        public Boolean isActiveContractFound;					// used when an active contract found but no contract Item
        public decimal totalPrepaidBalenceAvailable;			// Agent's Total Available Balance 
        public decimal totalPrepaidBalenceRequired;				// Total amount required to create record
        public List< Sobject > recordWithApprovalProcess;		// Record's which required Approval Process Final Approval To create Transaction ( Trigger.IsUpdate ).
        public List< Sobject > recordWithoutApprovalProcess;	// Record's whose Transaction to be created without Approval Process Final Approval ( Trigger.isInsert ).
        public String schoolfeeCurrencyIso;
        public String studentfeeCurrencyIso;
        public String applicationOptInFeeCurrencyIso;
        public String applicationOptOutFeeCurrencyIso;
        
        //incase Agent's Contract found but no Contract Item not found, then no charge of record creation.
        //So initializing with zero.
        public AccountPrepaidWrapper(){
            
            schoolfee = 0;
            studentfee =   0;
            applicationOptInFee = 0;
            applicationOptOutFee = 0;
            isActiveContractFound = false;
            totalPrepaidBalenceAvailable = 0;
            totalPrepaidBalenceRequired = 0;
            recordWithApprovalProcess = new List< Sobject >();
            recordWithoutApprovalProcess = new List< Sobject >();
            schoolfeeCurrencyIso = '';
        	studentfeeCurrencyIso = '';
        	applicationOptInFeeCurrencyIso = '';
        	applicationOptOutFeeCurrencyIso = '';
        }
    }
}