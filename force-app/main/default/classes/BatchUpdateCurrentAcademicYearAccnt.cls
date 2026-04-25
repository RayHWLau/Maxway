//3 June 2020 this batch will update the current academic year of the existing account records for one time only
//after that same functionality will be done from trigger on the case of insertion

//Test Class --> BatchUpdateCurrentAcademicYearAccntTest
global class BatchUpdateCurrentAcademicYearAccnt implements  Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String queryString = 'SELECT Id,CreatedDate,Current_Academic_Year_Hidden__c,Start_of_Academic_Month__c FROM Account ';
        queryString += ' WHERE Current_Academic_Year_Hidden__c = Null ';
        queryString += ' AND Start_of_Academic_Month__c != Null ';
        return database.getQueryLocator( queryString );
    }
    
    global void execute(Database.BatchableContext BC, List<Account> listAccountQueried){
        
        map< string, Integer > mapMonthToInteger= new map< string, Integer > { 'January' => 1,'February' => 2,'March' => 3,'April' => 4,'May' => 5,'June' => 6,'July' => 7,'August' => 8,'September' => 9,'October' => 10,'November' => 11,'December' => 12 };
            
            list< Account > listAccnt = new list< Account >();
        
        for( Account objAccnt : listAccountQueried){
            
            if( mapMonthToInteger.containsKey( objAccnt.Start_of_Academic_Month__c ) && string.isBlank( objAccnt.Current_Academic_Year_Hidden__c ) ){
                
                //if current month is less than start of academinc month
                if(  mapMonthToInteger.get( objAccnt.Start_of_Academic_Month__c ) > objAccnt.CreatedDate.month() ){
                    
                    objAccnt.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() -1);
                }
                else{
                    objAccnt.Current_Academic_Year_Hidden__c = String.valueOf( Date.today().year() );
                }
                
                listAccnt.add( objAccnt );
            }
        }//end of loop
        
        system.debug('listAccnt  --->  ' + listAccnt );
        update listAccnt;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}