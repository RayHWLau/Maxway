public class ContracttriggerHelper {
    public static final List<PicklistEntry> PROCESSED_CONTRACT_ENTRIES = (SObjectType.Account.fields.Latest_Marketing_Contract_Status__c.getSObjectField()).getDescribe().getPicklistValues();
    public static final Map<String, Schema.RecordTypeInfo> CONTRACT_RECORD_TYPE_INFO = Schema.SObjectType.Contract.getRecordTypeInfosByName();
    public static final String AGENT_CONTRACT_RECORD_TYPE_ID = CONTRACT_RECORD_TYPE_INFO.get('Agent').getRecordTypeId();
    public static final String SCHOOL_CONTRACT_RECORD_TYPE_ID = CONTRACT_RECORD_TYPE_INFO.get('School').getRecordTypeId();
    public static final String MARKETING_CONTRACT_RECORD_TYPE_ID = CONTRACT_RECORD_TYPE_INFO.get('Marketing Contract').getRecordTypeId();
    public static final Map<String, String> CONTRACT_ACCOUNT_STATUS_MAP = new Map<String, String> {
        AGENT_CONTRACT_RECORD_TYPE_ID => 'Latest_Agent_Contract_Status__c',
        SCHOOL_CONTRACT_RECORD_TYPE_ID => 'Latest_School_Contract_Status__c',
        MARKETING_CONTRACT_RECORD_TYPE_ID => 'Latest_Marketing_Contract_Status__c'
    };
    
    public static Set<String> getProcessedContractStatus() {
        Set<String> processedContractStatus = new Set<String>();
        for(PicklistEntry processedContractEntry : PROCESSED_CONTRACT_ENTRIES) {
            processedContractStatus.add(processedContractEntry.getValue());
        }
        return processedContractStatus;
    }
    
    public static void updateAccountLatestContractStatus(List<Contract> processedContracts) {
        Set<String> relatedAccountIds = new Set<String>();
        for(Contract processedContract : processedContracts) {
            relatedAccountIds.add(processedContract.AccountId);
        }
        
        List<Account> relatedAccountList = [SELECT Id, Latest_Marketing_Contract_Quota__c, Latest_School_Contract_Expiry_Date__c, Latest_Agent_Contract_Expiry_Date__c, Latest_Marketing_Contract_Expiry_Date__c, Latest_School_Contract_Status__c, Latest_Marketing_Contract_Status__c, Latest_Agent_Contract_Status__c, Latest_School_Contract_Modify_Date__c, Latest_Agent_Contract_Modify_Date__c, Latest_Marketing_Contract_Modify_Date__c FROM Account WHERE Id IN: relatedAccountIds];
        List<Contract> relatedContractList = [SELECT Id, RecordTypeId, Is_Effective_Contract__c, Status, AccountId, LastModifiedDate, Quota_Per_Contract__c, Contract_End_Date__c FROM Contract WHERE AccountId IN: relatedAccountIds AND Status IN: getProcessedContractStatus() ORDER BY LastModifiedDate DESC];
        
        for(Account relatedAccount : relatedAccountList) {
            List<Contract> accountRelatedContractList = getAccountRelatedContractList(relatedAccount.Id, relatedContractList);
            Map<String, Contract> latestContractMap = getLatestContractMap(accountRelatedContractList);
            relatedAccount.Latest_Agent_Contract_Status__c = latestContractMap.get(AGENT_CONTRACT_RECORD_TYPE_ID)?.Status;
            relatedAccount.Latest_Agent_Contract_Modify_Date__c = latestContractMap.get(AGENT_CONTRACT_RECORD_TYPE_ID) == null ? null : date.valueOf(latestContractMap.get(AGENT_CONTRACT_RECORD_TYPE_ID).LastModifiedDate);
            relatedAccount.Latest_Agent_Contract_Expiry_Date__c = latestContractMap.get(AGENT_CONTRACT_RECORD_TYPE_ID)== null ? null : date.valueOf(latestContractMap.get(AGENT_CONTRACT_RECORD_TYPE_ID).Contract_End_Date__c);
            relatedAccount.Latest_School_Contract_Status__c = latestContractMap.get(SCHOOL_CONTRACT_RECORD_TYPE_ID)?.Status;
            relatedAccount.Latest_School_Contract_Expiry_Date__c = latestContractMap.get(SCHOOL_CONTRACT_RECORD_TYPE_ID)== null ? null : date.valueOf(latestContractMap.get(SCHOOL_CONTRACT_RECORD_TYPE_ID).Contract_End_Date__c);
            relatedAccount.Latest_School_Contract_Modify_Date__c = latestContractMap.get(SCHOOL_CONTRACT_RECORD_TYPE_ID) == null ? null : date.valueOf(latestContractMap.get(SCHOOL_CONTRACT_RECORD_TYPE_ID).LastModifiedDate);
            relatedAccount.Latest_Marketing_Contract_Status__c = latestContractMap.get(MARKETING_CONTRACT_RECORD_TYPE_ID)?.Status;
            relatedAccount.Latest_Marketing_Contract_Modify_Date__c = latestContractMap.get(MARKETING_CONTRACT_RECORD_TYPE_ID) == null ? null : date.valueOf(latestContractMap.get(MARKETING_CONTRACT_RECORD_TYPE_ID).LastModifiedDate);
        	relatedAccount.Latest_Marketing_Contract_Expiry_Date__c = latestContractMap.get(MARKETING_CONTRACT_RECORD_TYPE_ID)== null ? null : date.valueOf(latestContractMap.get(MARKETING_CONTRACT_RECORD_TYPE_ID).Contract_End_Date__c);
           	relatedAccount.Latest_Marketing_Contract_Quota__c = latestContractMap.get(MARKETING_CONTRACT_RECORD_TYPE_ID)?.Quota_Per_Contract__c;
        }
        
        update relatedAccountList;
    }
    
    private static List<Contract> getAccountRelatedContractList(String accountId, List<Contract> contractList) {
        List<Contract> accountRelatedContractList = new List<Contract>();
        for(Contract con : contractList) {
            if(con.AccountId.equals(accountId)) {
                accountRelatedContractList.add(con);
            }
        }
        return accountRelatedContractList;
    }
    
    private static Map<String, Contract> getLatestContractMap (List<Contract> relatedContractList) {
        Map<String, Contract> latestContractMap = new Map<String, Contract> {
            AGENT_CONTRACT_RECORD_TYPE_ID => null,
            SCHOOL_CONTRACT_RECORD_TYPE_ID => null,
            MARKETING_CONTRACT_RECORD_TYPE_ID => null
        };
        for(Contract relatedContract : relatedContractList) {
            if(relatedContract.Is_Effective_Contract__c) {
                latestContractMap.put(relatedContract.RecordTypeId, relatedContract);
            }
        }
        
        for(Contract relatedContract : relatedContractList) {
            if(latestContractMap.get(relatedContract.RecordTypeId) == null) {
                latestContractMap.put(relatedContract.RecordTypeId, relatedContract);
            }
        }
        return latestContractMap;
    }
    
    
    public static void visibletoagentupdate(set<id> accountids){
        
        map<id,integer> mapaccidcontractsizesize = new map<id,integer>();
        list<account> accountlist = new list<account>();
        
        for( Account account : [SELECT Id,Nin__c,(SELECT Id,Status FROM Contracts where Status='Valid' or Status='Contract Activated') FROM Account WHERE Id In :accountids and Nin__c ='No']){
            mapaccidcontractsizesize.put(account.id,account.Contracts.size()) ;  
        } 
        
        for(string str : mapaccidcontractsizesize.keyset()){
            if(mapaccidcontractsizesize.get(str)==0){
                accountlist.add(new account(id = str , visible_to_agent__c = 'No'));  
            }
        }
        
        if(accountlist.size()>0) update accountlist;
    }
    
    public static void licencenumberupdate(set<id> accountids){
        map<string,list<decimal>> licencecount = new map<string,list<decimal>>();
        map<string,string> totaladminuserlicenceonOpp = new map<string,string>();
        map<string,list<date>> startdateenddate = new map<string,list<date>>();
        list<account> accountlist = new list<account>();
        list<opportunity> opportunitylist = new list<opportunity>();
        for( Account account : [SELECT Id,(SELECT Id,Opportunity__c,Total_User_License__c,Total_Admin_License__c,StartDate,enddate FROM Contracts WHERE Status = 'Activated'  and enddate >= Today )
                                FROM Account WHERE Id In :accountids 
                               ] ){
                                   decimal admincount = 0;
                                   decimal usercount = 0;
                                   date startdate = null;
                                   date endate = null;
                                   
                                   if( account.Contracts.size() > 0 ){
                                       
                                       list<date> startdateenddates = new list<date>();
                                       if(account.Contracts[0].startdate != null) startdate = account.Contracts[0].startdate;   
                                       if(account.Contracts[0].enddate != null) endate = account.Contracts[0].enddate;
                                       if(startdate != null)  startdateenddates.add(startdate);
                                       if(endate != null) startdateenddates.add(endate);
                                       if(startdateenddates.size()==2) startdateenddate.put( account.Id, startdateenddates);
                                       
                                       for(contract contrt : account.Contracts){
                                           if(contrt.Total_User_License__c!=null) usercount = usercount+contrt.Total_User_License__c;
                                           if(contrt.Total_Admin_License__c!=null) admincount = admincount+contrt.Total_Admin_License__c;
                                           if(string.isNotBlank(contrt.Opportunity__c) && contrt.Total_User_License__c!=null) totaladminuserlicenceonOpp.put(contrt.Opportunity__c,string.valueOf(contrt.Total_User_License__c));
                                           if(string.isNotBlank(contrt.Opportunity__c) && contrt.Total_Admin_License__c!=null){
                                               if(totaladminuserlicenceonOpp.containskey(contrt.Opportunity__c)) totaladminuserlicenceonOpp.put(contrt.Opportunity__c,totaladminuserlicenceonOpp.get(contrt.Opportunity__c)+'#'+string.valueOf(contrt.Total_Admin_License__c));
                                               else totaladminuserlicenceonOpp.put(contrt.Opportunity__c,'#'+string.valueOf(contrt.Total_Admin_License__c));
                                           }
                                       }
                                       list<decimal> licencecounts = new list<decimal>();
                                       
                                       if(admincount !=0)  licencecounts.add(admincount);
                                       if(admincount ==0)  licencecounts.add(0);    
                                       if(usercount !=0)  licencecounts.add(usercount);    
                                       if(usercount ==0)  licencecounts.add(0);
                                       
                                       licencecount.put( account.Id, licencecounts);
                                   }
                                   
                               }
        for(string str :licencecount.keyset()){
            Account acc = new Account();
            list<decimal> licencenumber =licencecount.get(str);
            acc.Total_Admin_License__c=licencenumber[0];
            acc.Total_User_License__c=licencenumber[1];
            if(startdateenddate.containskey(str)){ 
                list<date> datess = new list<date>();
                datess = startdateenddate.get(str);
                acc.License_Start_Date__c = datess[0];
                acc.License_End_Date__c = datess[1];
            }
            acc.id = str;
            accountlist.add(acc);
        }
        database.update(accountlist,false);
        for(string str :totaladminuserlicenceonOpp.keyset()){
            if(string.isNotBlank(totaladminuserlicenceonOpp.get(str))){
                if(totaladminuserlicenceonOpp.get(str).contains('#')) {
                    string[] adminanduser = totaladminuserlicenceonOpp.get(str).split('#');
                    if(adminanduser.size() == 2){
                        opportunity opp = new opportunity();
                        opp.id = str;
                        opp.Number_Of_Licence__c = string.isNotBlank(adminanduser[1]) ? decimal.valueof(adminanduser[1]) :0;
                        opp.Number_of_Admin_Licenses__c = string.isNotBlank(adminanduser[0]) ? decimal.valueof(adminanduser[0]) :0;
                        opportunitylist.add(opp);  
                    }
                    
                }
                else{
                    string totaluser = totaladminuserlicenceonOpp.get(str);
                    opportunity opp = new opportunity();
                    opp.id = str;
                    opp.Number_Of_Licence__c = decimal.valueof(totaluser);
                    opportunitylist.add(opp); 
                }
                database.update(opportunitylist,false); 
            }
        }
    }
    
    public static void morethn1activecontractunderacc(set<id> accountids,list<contract> triggernew){
        map<id,Contract> activecontractmap = new map<id,Contract>();
        
        //added on 22 april 2020
          set< Id > setValidRecTypID= ( new Map< Id, RecordType >([ SELECT Id 
                                                                 	FROM  RecordType 
                                                                 	WHERE SobjectType = 'Contract' AND IsActive = true 
                                                                		AND DeveloperName IN ( 'Agent' ) ]) ).keySet();
        
        for( Account account : [SELECT Id,(SELECT Id,startdate,enddate,ContractNumber,ContractTerm FROM Contracts WHERE Status = 'Activated' and enddate >= Today  
                                           AND RecordTypeId IN : setValidRecTypID order by createddate desc LIMIT 1) //added on 22 april 2020 added record type filter for agent only
                                FROM Account WHERE Id In :accountids] ){
                                   activecontractmap.put(account.Id,null);
                                   if(account.Contracts.size()>0){
                                       for(contract cntrt : account.Contracts){
                                           activecontractmap.put(account.Id,cntrt); 
                                           system.debug(activecontractmap.get(account.Id));
                                       }
                                   }
                                   
                               }
        
        for(contract contrt : triggernew){
            if(activecontractmap.containskey(contrt.accountid) && activecontractmap.get(contrt.accountid) !=null){
                boolean datecheck=ContracttriggerHelper.calculatedays(contrt.StartDate,contrt.ContractTerm,activecontractmap.get(contrt.accountid).EndDate);
                
                if(!datecheck && contrt.Status == 'Activated' && setValidRecTypID.contains( contrt.RecordTypeId )){  //added on 22 april 2020 as this error only work is contract is Activated and record Type Agent
                
                    contrt.adderror('Contract End Date should be equal to '+activecontractmap.get(contrt.accountid).ContractNumber+' Contract End Date i.e '+string.valueof(activecontractmap.get(contrt.accountid).Enddate).split(' ')[0]);  
                    contrt.RenewalOpp__c = false;
                } 
                else{
                    contrt.RenewalOpp__c = false;
                }
            }
        }
        
    }
    public static boolean calculatedays(date startdate , integer numbermonths ,date enddatecontrt){
        system.debug('startdate-->'+startdate);  
        system.debug('numbermonths-->'+numbermonths);
        system.debug('enddatecontrt-->'+enddatecontrt);
        
        integer resultantyear = 0;
        integer resultantmonth = 0;
        integer resultantdate = 0;
        integer monthstobeadded = 0;
        integer yearstobeadded = 0;
        
        integer totalmonths = startdate.month() + numbermonths;
        
        if(totalmonths >12 ){
            monthstobeadded = math.mod(totalmonths, 12);
            yearstobeadded = totalmonths/12;
            resultantyear = startdate.year() + yearstobeadded;
            resultantmonth =  monthstobeadded;
            
            if(startdate.day()==1){ 
                resultantdate = date.daysInMonth(resultantyear,resultantmonth-1);
                resultantmonth = resultantmonth-1; }
            else resultantdate = startdate.day()-1;
        }
        else{
            resultantyear = startdate.year() ;
            resultantmonth = startdate.month() + numbermonths; 
            
            if(startdate.day()==1){ 
                resultantdate = date.daysInMonth(resultantyear,resultantmonth-1);
                resultantmonth = resultantmonth-1; }
            else resultantdate = startdate.day()-1;
        } 
        
        date calculateddate = date.newinstance(resultantyear,resultantmonth,resultantdate); 
        
        if(enddatecontrt== calculateddate){
            return true;
        }
        return false;
    }
    
    public static void validateValidContarct(List<Contract> ListTriggerNew){
        
        Id schoolid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('School').getRecordTypeId();
        Id marketingCntrct = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Marketing Contract').getRecordTypeId();
        Map<String,string> MapKeyToCount = new Map<String,string>();
        Set<Id> setAccIds = new Set<Id>();
       
        for(Contract objCntrct : ListTriggerNew){
            if(objCntrct.AccountId != Null && objCntrct.Status != Null && (objCntrct.RecordTypeId == schoolid || objCntrct.RecordTypeId == marketingCntrct))
                setAccIds.add(objCntrct.AccountId);
        }
        
        if(setAccIds.size()>0){
            for(Contract cntrct : [SELECT Id , AccountId,Status,contractnumber  FROM Contract WHERE AccountId IN : setAccIds
                                   AND (Status = 'Valid' OR  Status = 'Contract Activated')]){
                                       if(cntrct != Null && cntrct.Status == 'Valid' ){
                                       
                                           MapKeyToCount.put(cntrct.AccountId+'#'+'Valid',cntrct.contractnumber);
                                           
                                       }
                                       
                                       if(cntrct != Null && cntrct.Status == 'Contract Activated'){
                                          
                                           MapKeyToCount.put(cntrct.AccountId+'#'+'Activated',cntrct.contractnumber);
                                       }
                                       
                                   }
        }
        
        for(Contract cntrctRec : ListTriggerNew){
            
            if( cntrctRec.Status == 'Valid' && MapKeyToCount.containsKey(cntrctRec.AccountId+'#'+'Valid') && MapKeyToCount.get(cntrctRec.AccountId+'#'+'Valid') != cntrctRec.contractnumber && cntrctRec.RecordTypeId == schoolid)
                cntrctRec.addError(Label.ValidationErrorValidContract);
            
            if( cntrctRec.Status == 'Contract Activated' && MapKeyToCount.containsKey(cntrctRec.AccountId+'#'+'Activated') && MapKeyToCount.get(cntrctRec.AccountId+'#'+'Activated')  != cntrctRec.contractnumber && cntrctRec.RecordTypeId == marketingCntrct)
                cntrctRec.addError(Label.ValidationErrorActivatedContract);
        }
        
        
        
    }


    /**
		Name : Karan Singh Soni	
		Company: Techmatrix
		Description: Create contract only if account linked to current contract( RecTyp - school ) have Parent account having no Valid contract.
		Inputs:None
		Returns: void
		Last Modified On : 23 Apr 2020
		History:
		====================================================
		1.0 23 Apr 2020   Karan Singh 	Initial Version
		
	**/
    public static void checkExistContractOnGrandParent(){
        
        String contractRecId = '';
        map< String, String > mapAccntWithParentAccnt = new map< String, String >();
        
        if( Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().containsKey('School')){
            
            contractRecId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('School').getRecordTypeId();
        }
        
        if( string.isBlank( contractRecId ) ){
            
            system.debug(' School recordtype not found, exiting.... ');
            mapAccntWithParentAccnt = Null;
            return;
        }
        
        for( Contract objContract : ( List< Contract > ) trigger.new ){
            
            if( objCOntract.RecordTypeId == contractRecId && String.isNotBlank( objContract.AccountId ) ){
                
                mapAccntWithParentAccnt.put( objContract.AccountId, '' );
            }
        }//end of trigger loop
        
        if( mapAccntWithParentAccnt.size() == 0 ){
            
            system.debug(' No contract found with Parent Account, exiting.... ');
            mapAccntWithParentAccnt = Null;
            return;
        }
        for( Account childAccnt : [ SELECT  Id,ParentId
                                  	FROM Account 
                                    WHERE Id IN: mapAccntWithParentAccnt.keySet() AND ParentId <> Null ]){
                                    
                                        mapAccntWithParentAccnt.put( childAccnt.Id, childAccnt.ParentId );
                                        mapAccntWithParentAccnt.put( childAccnt.ParentId, '' ); //accountId will give Grand Parent Id whihc will give valid contracts confimation
                                   }//end of child account
        
        for( Account parentAccnt : [ SELECT Id ,
                                    ( SELECT Id FROM Contracts
                                     	WHERE (Status = 'Valid'or Status = 'Contract Activated' ) AND RecordTypeId =:contractRecId 
                                     	LIMIT 1 )
                                    FROM Account WHERE Id In :mapAccntWithParentAccnt.values()  ]){
                                        
                                        if( parentAccnt.Contracts.size() > 0 )
                                            mapAccntWithParentAccnt.put( parentAccnt.Id, 'Valid' );
                                    }//end of parent account
        
        system.debug(' mapAccntWithParentAccnt -->  ' + mapAccntWithParentAccnt );
        
        for( Contract objContract : ( List< Contract > ) trigger.new ){
            
            if( objCOntract.RecordTypeId != contractRecId ) continue; 
            
            if( string.isNotBlank( objContract.AccountId ) && mapAccntWithParentAccnt.containsKey( objContract.AccountId )&&
               string.isNotBlank( mapAccntWithParentAccnt.get( objContract.AccountId ) ) && 
               mapAccntWithParentAccnt.get( mapAccntWithParentAccnt.get( objContract.AccountId ) ) == 'Valid' ){
                   
                   objContract.addError( Label.ValidationErrorContractExist );
               }
                
        }//end of grand parent record check
        
        
    }//end of checkExistContractOnGrandParent() 
}