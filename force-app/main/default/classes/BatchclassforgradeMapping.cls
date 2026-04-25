global class BatchclassforgradeMapping implements  Database.Batchable<sObject>{
    
      global final string query;
    
    global BatchclassforgradeMapping (String q)
    {
        query = q;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        map<integer,string> monthMap = new map<integer,string>();
        
        monthMap.put(1,'January');
        monthMap.put(2,'February');
        monthMap.put(3,'March');
        monthMap.put(4,'April');
        monthMap.put(5,'May');
        monthMap.put(6,'June');
        monthMap.put(7,'July');
        monthMap.put(8,'August');
        monthMap.put(9,'September');
        monthMap.put(10,'October');
        monthMap.put(11,'November');
        monthMap.put(12,'December');
        
        date todays = system.today(); 
        
        string months ='';
        
        if(monthMap.containskey(todays.month())){
            months = monthMap.get(todays.month());   
        }

        String currentYear = String.valueOf(todays.year());

        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id, Id> gradeMap = new Map<Id, Id>();
        for(Grade_Mapping__c g:[Select Id, Next_Year_Grade__c From Grade_Mapping__c]){
            gradeMap.put(g.Id, g.Next_Year_Grade__c);
        }
        system.debug('###before ACCOUNT ' + scope);
        for(Sobject s : scope){
            if(gradeMap.containsKey((Id)s.get('Current_Grade_Mapping__c'))) {
                if(gradeMap.get((Id)s.get('Current_Grade_Mapping__c')) != null)
                s.put('Current_Grade_Mapping__c',gradeMap.get((Id)s.get('Current_Grade_Mapping__c')));
                
                //added on 21 April 2020 as to update Current Academic year as per grade change
                if( s.get('Current_Academic_Year_Hidden__c') == Null ){
                    
                    s.put('Current_Academic_Year_Hidden__c', String.valueOf( Date.today().year() ));
                }else{
                 
                    s.put('Current_Academic_Year_Hidden__c', String.valueOf( Integer.valueOf( s.get('Current_Academic_Year_Hidden__c') ) + 1 ));
                }
                //end 21 April 2020
            }
        }
        system.debug('###after ACCOUNT ' + scope);
        update scope;
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}