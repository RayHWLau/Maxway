public without sharing class OpportunityTriggerHandler implements Triggers.Handler{
    
    public void handle() {
        if(Trigger.isBefore) {
            if(Trigger.isUpdate) {
                Set<Id> generateDraftInvOppIds = new Set<Id>();
                for (Opportunity opp : (List<Opportunity>) trigger.new) {
                    if(opp.StageName == 'Arrived' && ((Opportunity) trigger.oldMap.get(opp.Id)).StageName == 'Placed') {
                        //if(opp.StageName == 'Arrived') {
                        generateDraftInvOppIds.add(opp.Id);
                    }
                }
                if(generateDraftInvOppIds.size()>0) {
                    generateDraftInvoice(generateDraftInvOppIds);
                }
            }
        }
    }
    @TestVisible
    private static void generateDraftInvoice(Set<Id> oppIds){
        //Find out all applications
        List<Case> appls = [
            Select Id, Opportunity__c, Program__c,Term__c, Year__c, //Billing_Year__c
            School__c, Opportunity__r.Num_of_Year_to_Graduation__c
            From Case
            Where Opportunity__c In:oppIds 
        ];
        Map<Id, Case> appMap = new Map<Id,Case>();
        Set<Id> progIds = new Set<Id>();
        for(Case a: appls) {
            appMap.put(a.Id, a);
            progIds.add(a.Program__c);
        }
        //Find out all commission
        List<Commission__c> comms = [
            Select Id, Program__c, Commission_Order__c, 
            Billing_Frequency_Per_Year__c, Annual_Commission_Amount_Fixed__c,
            Annual_Commission_Amount_Percentage__c, 
            Commission_Percentage__c, Retainer_Year__c,
            Invoice_Contact__c
            From Commission__c
            Where Program__c In:progIds
            Order By Commission_Order__c
        ];
        Map<Id, List<Commission__c>> progId2Comms = new Map<Id, List<Commission__c>>();
        for(Commission__c c: comms) {
            if(progId2Comms.containsKey(c.Program__c)) {
                progId2Comms.get(c.Program__c).add(c);
            } else {
                List<Commission__c> tmp = new List<Commission__c>();
                tmp.add(c);
                progId2Comms.put(c.Program__c, tmp);
            }
        }
        //
        List<Commission_Config__c> commfigs = [
            Select Name, Billing_Frequency__c, Term__c, Next_Term__c, Start_Date__c
            From Commission_Config__c
        ];
        Map<String, Commission_Config__c> commConfigMap = new Map<String, Commission_Config__c>();
        for(Commission_Config__c c:commfigs) {
            commConfigMap.put(c.Name, c);
        }
        //
        System.debug('*** commConfigMap ' + commConfigMap);
        List<School_Invoice__c> newInvoices = new List<School_Invoice__c>();
        Boolean bStart = true;
        String nextTerm='';
        Integer year=0;
        Integer iTotalYears=0;
        for(Case a: appls) {
            bStart = true;
            if(progId2Comms.containsKey(a.Program__c)) {
                for(Commission__c c: progId2Comms.get(a.Program__c)) {					
                    for(Integer i=0; i<c.Retainer_Year__c; i++) {
                        iTotalYears++;
                        System.debug('*** c.Retainer_Year__c ' + c.Retainer_Year__c + '');
                        System.debug('*** a.Opportunity__r.Num_of_Year_to_Graduation__c ' + a.Opportunity__r.Num_of_Year_to_Graduation__c + '');
                        if(iTotalYears <=a.Opportunity__r.Num_of_Year_to_Graduation__c) {
                            for(Integer j=0; j<c.Billing_Frequency_Per_Year__c; j++) {								
                                School_Invoice__c p = new School_Invoice__c(
                                    School__c = a.School__c,
                                    Application__c = a.Id,
                                    Invoice_Status__c = 'Draft',
                                    Invoice_Contact__c = c.Invoice_Contact__c
                                );
                                Decimal amt=0.0;
                                if(c.Annual_Commission_Amount_Fixed__c >0) {
                                    amt = c.Annual_Commission_Amount_Fixed__c;
                                } else {
                                    if(c.Annual_Commission_Amount_Percentage__c >=0 && c.Commission_Percentage__c >=0) {
                                        amt = c.Annual_Commission_Amount_Percentage__c *c.Commission_Percentage__c/100;
                                    }
                                }
                                p.Invoice_Amount__c =amt/c.Billing_Frequency_Per_Year__c;
                                if(bStart) {
                                    System.debug('*** cp1: ');
                                    System.debug('*** 1 a.Term__c ' + a.Term__c + '');
                                    System.debug('*** 1 p.Term__c ' + p.Term__c + '');
                                    p.Term__c=a.Term__c;
                                    p.Year__c=a.Year__c;									
                                    System.debug('*** 2 a.Term__c ' + a.Term__c + '');
                                    System.debug('*** 2 p.Term__c ' + p.Term__c + '');
                                    if(commConfigMap.containsKey(c.Billing_Frequency_Per_Year__c+'-'+p.Term__c)){
                                        Date startDate = commConfigMap.get(c.Billing_Frequency_Per_Year__c+'-'+p.Term__c).Start_Date__c;								
                                        p.Target_Invoice_Issue_Date__c = Date.newInstance(Integer.valueOf(a.Year__c), startDate.month(), startDate.day());
                                        nextTerm = commConfigMap.get(c.Billing_Frequency_Per_Year__c+'-'+p.Term__c).Next_Term__c;
                                    }
                                    bStart = false;
                                    year = Integer.valueOf(p.Year__c);
                                    if(p.Target_Invoice_Issue_Date__c != null) {
                                        newInvoices.add(p);
                                    }									
                                    
                                } else {	
                                    if(nextTerm != null && nextTerm != '') {
                                        System.debug('*** cp2: ');
                                        System.debug('*** 2a nextTerm ' + nextTerm + '');
                                        System.debug('*** 2a p.Term__c ' + p.Term__c + '');						
                                        System.debug('*** year before ' + year + '');											
                                        
                                        if(commConfigMap.containsKey(nextTerm)) {
                                            Date startDate = commConfigMap.get(nextTerm).Start_Date__c;
                                            p.Term__c=commConfigMap.get(nextTerm).Term__c;								
                                            p.Year__c= String.valueOf(year);
                                            if(p.Term__c == 'Winter') {
                                                year++; 
                                            }																					
                                            System.debug('*** year after ' + year + '');										
                                            System.debug('*** p.Year__c ' + p.Year__c + '');	
                                            p.Target_Invoice_Issue_Date__c = Date.newInstance(year, startDate.month(), startDate.day());
                                            
                                        }
                                        System.debug('*** 2b a.Term__c ' + a.Term__c + '');
                                        System.debug('*** 2b p.Term__c ' + p.Term__c + '');
                                        if(p.Target_Invoice_Issue_Date__c != null) {
                                            newInvoices.add(p);
                                        }										
                                        if(commConfigMap.containsKey(c.Billing_Frequency_Per_Year__c+'-'+p.Term__c)) {
                                            nextTerm = commConfigMap.get(c.Billing_Frequency_Per_Year__c+'-'+p.Term__c).Next_Term__c;
                                        }
                                    }
                                }
                                //System.debug('*** iTotalYears ' + iTotalYears + '');
                                //System.debug('*** c.Billing_Frequency_Per_Year__c: ' + c.Billing_Frequency_Per_Year__c + '');
                                //System.debug('*** p.Term__c: ' + p.Term__c + '');
                                System.debug('*** nextTerm: ' + nextTerm + '');
                                //nextTerm = commConfigMap.get(c.Billing_Frequency_Per_Year__c+'-'+p.Term__c).Next_Term__c;
                                //newInvoices.add(p);
                            }
                        }
                    }
                    
                }
            }
        }
        System.debug('*** newInvoices: ' + newInvoices);
        insert newInvoices;
    }
    
    //TMC Lock the record if stage is Closed Lost
    
    public static void recordLock( List<Opportunity> triggerNew, map<id, opportunity> triggerOldMap ){
        
        //avoid recursive trigger from opprt name change process builder
        if( avoidRecursive.isFirstRunOpp ){
            avoidRecursive.isFirstRunOpp = false;
            for( Opportunity objOpp  : triggerNew ){
                if( objOpp.StageName == 'Closed Lost' || triggerOldMap.get(objOpp.id).StageName == 'Closed Lost' || objOpp.StageName == 'Sales Won' || triggerOldMap.get(objOpp.id).StageName == 'Sales Won' ){
                    
                    //if the record is locked and previous stagename was closed lost
                    if( Approval.isLocked(objOpp.id)  ){
                        objOpp.addError('please unlock the record first before editing!');
                    }else{
                        Approval.lock(objOpp.id); //lock the record
                    }
                }
            }
        }
        
    }
    
    public static void documentuploadcreation(list<string> oppaccids){
        list<Document_Upload__c> documenttoinsert = new list<Document_Upload__c>();
        list<Document_Master__c> docmaster =[select id,name,active__c,required__c,process__c from Document_Master__c where active__c =true AND process__c IN ('Quotation', 'Agent Signup Form')];
        map<string,list<Document_Master__c>> documentuploadmap = new map<string,list<Document_Master__c>>();
        for(string str : oppaccids){
            documentuploadmap.put(str,docmaster); 
        }
        
        for(string key : documentuploadmap.keyset()){
            string[] arrystr = key.split('#');
            for(Document_Master__c docmas : documentuploadmap.get(key)){
                Document_Upload__c docup = new Document_Upload__c();
                docup.Name=docmas.Name;
                docup.Account__c= arrystr[1];
                docup.Document_Master__c = docmas.id;
                docup.Opportunity__c =arrystr[0];
                documenttoinsert.add(docup);
            }
        }
        database.insert(documenttoinsert,false);
    }
    
    public static void documentuploadCreationForStudent(list<String> oppaccids,string sobjectname){
        list<Document_Upload__c> documenttoinsertForstu = new list<Document_Upload__c>();
        list<Document_Master__c> docmaster =[select id,name,active__c,required__c,process__c from Document_Master__c where active__c =true 
                                             AND default__c=true AND process__c = 'Application' AND level__c=:sobjectname];
        map<string,list<Document_Master__c>> documentuploadmap = new map<string,list<Document_Master__c>>();
        for(string str : oppaccids){
            if(docmaster <> Null )
                documentuploadmap.put(str,docmaster); 
        }
        
        for(string key : documentuploadmap.keyset()){
            string[] arrystr = key.split('#');
            for(Document_Master__c docmas : documentuploadmap.get(key)){
                Document_Upload__c docup = new Document_Upload__c();
                docup.Name=docmas.Name;
                docup.Document_Master__c = docmas.id;
                if(sobjectname=='Opportunity'){
                    docup.Account__c= arrystr[1] != Null ? arrystr[1] : Null;
                    docup.Opportunity__c =arrystr[0];
                }
                if(sobjectname=='Application'){
                    docup.Application__c =arrystr[0];    
                }
                if(docmas.Required__c==true)
                    docup.Required__c=true;
                documenttoinsertForstu.add(docup);
            }
        }
        database.insert(documenttoinsertForstu,false);
    }
    
    public static void accountstatustoclosedlost(set<string> accountid){
        if(accountid.size()>0){
            list<account> acclistinsert = new list<account>();
            for(account acc : [select id,(select id,accountid,StageName  from opportunities) from account where id in :accountid] ){
                integer oppsize = acc.opportunities.size();
                system.debug('opp'+oppsize);
                integer closedlostoppsize = 0;
                if(oppsize > 0){
                    for(opportunity opp : acc.opportunities){
                        if(opp.stagename=='Closed Lost'){
                            system.debug('opp.stagename'+opp.stagename);
                            closedlostoppsize ++;   
                        }
                    }
                    if(oppsize == closedlostoppsize){
                        system.debug('acc.id'+acc.id);
                        Account accountinsert =  new Account();
                        accountinsert.id = acc.id;
                        accountinsert.Status_Sub_Agent__c='Close Lost';
                        accountinsert.Closed_Lost_Reason__c='Others';
                        accountinsert.Closed_Lost_Reason_Others__c='All the opportunity under this account is closed lost';
                        acclistinsert.add(accountinsert);
                    }
                }
            }
            if(acclistinsert.size()>0){
                update acclistinsert;
            }
        }
    }
    public static void recordtypeupdate(set<string> accountid ,list<opportunity> opportunitynew){
        set<string> studentaccount = new set<string>();
      Id recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
         Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Student').getRecordTypeId();
        for(account acc :[select recordtypeid from account where id in :accountid and recordtypeid=:recordtypeid] ){
            studentaccount.add(acc.id);
        }
        for(opportunity opp : opportunitynew){
            if(studentaccount.contains(opp.AccountId))
               opp.RecordTypeId=opprecordtypeid; 
        }
    }  
    
    
}