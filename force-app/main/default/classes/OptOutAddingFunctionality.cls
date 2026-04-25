public class OptOutAddingFunctionality {
    @AuraEnabled
    public static list<countrylistclass> fetchschoollist(Id agentId){
        list<string> countrylist = new list<string>();
        set<string> countrynames = new set<string>();
        list<countrylistclass> wrapclas = new list<countrylistclass>();
        list<account> acc =[select School_List_Purchased__c from account where id = :agentId];
        if(acc.size()>0 && acc[0].School_List_Purchased__c != null){
            countrylist = acc[0].School_List_Purchased__c.split(';'); 
            for(Opt_Out_School__c opt : [select School__c,Agent__c,School__r.School_s_Country__c from  Opt_Out_School__c where Agent__c=:agentId and School__r.School_s_Country__c in :countrylist]){
                countrynames.add(opt.School__r.School_s_Country__c);     
            }
            for(string str : countrylist){
                countrylistclass wrapdata = new countrylistclass();
                wrapdata.countryname = str;
                if(countrynames.contains(str)) wrapdata.hasoptout=true;
                else wrapdata.hasoptout=false;
                wrapclas.add(wrapdata);
            }
            return wrapclas;
        }
        return null;
    }
    
    @AuraEnabled
    public static WrapperPagination schoolwithsamecountry(string contryname,string agentid,Integer pageNumber,Integer pageSize){
        pageSize=100;
        
        //map<string,list<wrapperclass>> schoolmap = new map<string,list<wrapperclass>>();
        set<id> schoolids = new set<id>();
        //list<wrapperclass> wrapclaslist = new list<wrapperclass>();
        Id recordTypeIdschool = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - CC').getRecordTypeId();
        Id recordTypeIdhighschool = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - HS').getRecordTypeId();
        Id recordTypeIduniversity = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - University').getRecordTypeId();
        for(Opt_Out_School__c opt : [select School__c,Agent__c from  Opt_Out_School__c where Agent__c=:agentid and School__r.School_s_Country__c=:contryname ]){
           
            schoolids.add(opt.School__c);    
        }
        WrapperPagination wrapclas = new WrapperPagination();
        wrapclas.accWrp = new List<WrapperPagination.wrpCl>();
        Integer accSize =[select Count() from account where School_s_Country__c = :contryname  and NIN__c !='Yes'];
         Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        
        //Total Records
        Integer totalRecords = accSize;
        Integer recordEnd = pSize * pNumber;
        for(account acc : [select Name,School_s_Country__c,RecordTypeId,RecordType.Name from account where School_s_Country__c = :contryname  and NIN__c !='Yes' LIMIT :pSize OFFSET :offset]){
            
            if(acc.RecordTypeId == recordTypeIdschool || acc.RecordTypeId == recordTypeIdhighschool || acc.RecordTypeId == recordTypeIduniversity){
                WrapperPagination.wrpCl wrp = new WrapperPagination.wrpCl();
                wrp.sch=acc;
                if(schoolids.size()>0 && schoolids.contains(acc.id)) wrp.isoptout = True;
                else wrp.isoptout = False;
                
                wrapclas.accWrp.add(wrp);
                
            }   
        }
        wrapclas.pageSize = pSize;
        wrapclas.pageNumber = pNumber;
        wrapclas.recordStart = offset + 1;
        wrapclas.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapclas.totalRecords = totalRecords;
        // Pagination 
        return wrapclas;   
    }
    
    
    @AuraEnabled
    public static string saveoptoutschool(string agentid , string schoolids ,string contrynames){
        //try{ 
            system.debug('contryname-->'+contrynames);
            list<Opt_Out_School__c> OptOutlisttodelete = new list<Opt_Out_School__c>();
            for(Opt_Out_School__c opt : [select School__c,Agent__c from  Opt_Out_School__c where Agent__c=:agentid and School__r.School_s_Country__c=:contrynames]){
                OptOutlisttodelete.add(new Opt_Out_School__c(id=opt.id));  
                system.debug('contryname-->'+opt.id);
            }
            if(OptOutlisttodelete.size()>0) delete OptOutlisttodelete;
            list<Opt_Out_School__c> OptOutlist = new list<Opt_Out_School__c>();
            string schlids = schoolids.removeEnd(';');
            string[] schlidlist = schlids.split(';');
            
            for(string str : schlidlist)  {
                system.debug('str'+str);
                Opt_Out_School__c opt = new Opt_Out_School__c();
                opt.Agent__c=agentid;
                opt.School__c = str;
                OptOutlist.add(opt);
            }
            system.debug('OptOutlist'+OptOutlist);
            insert OptOutlist;
            return 'sucess';               
       /* }
        catch ( exception e){
            return e.getMessage();   
        }*/
        
    }
    
    @AuraEnabled
    public static string saveoptoutschoolPage(string agentid , string schoolids ,string contrynames,string delCheck){
        try{ 
        string delId='';
        string[] delidlist;
        if(String.IsNotBlank(delCheck) && delCheck != NULL)  {
            delId = delCheck.removeEnd(';');
             delidlist = delId.split(';'); 
        } 
        
            list<Opt_Out_School__c> OptOutlisttodelete = new list<Opt_Out_School__c>();
        if(delidlist != NULL && delidlist.Size()>0){
            for(Opt_Out_School__c opt : [select School__c,Agent__c from  Opt_Out_School__c where Agent__c=:agentid and School__r.School_s_Country__c=:contrynames and School__c in:delidlist]){
                OptOutlisttodelete.add(new Opt_Out_School__c(id=opt.id)); 
            }  
        }
            
            if(OptOutlisttodelete.size()>0 && delidlist.size()>0) delete OptOutlisttodelete;
            list<Opt_Out_School__c> OptOutlist = new list<Opt_Out_School__c>();
            string schlids='';
            string[] schlidlist;
            set<Id> schoolId = new set<Id>();
            if(String.IsNotBlank(schoolids) && schoolids != NULL)  {
                schlids = schoolids.removeEnd(';');
                schlidlist = schlids.split(';');
                List<Opt_Out_School__c> optList =[select School__c,Agent__c from  Opt_Out_School__c where Agent__c=:agentid and School__r.School_s_Country__c=:contrynames and School__c in:schlidlist];
                for(Opt_Out_School__c opt:optList ){
                    schoolId.add(opt.School__c);
                }
            } 
            
            
        	if(schlidlist != NULL && schlidlist.size()>0 ){
                for(string str : schlidlist)  {
                    system.debug('str'+str);
                    if(!schoolId.contains(str)){
                        Opt_Out_School__c opt = new Opt_Out_School__c();
                        opt.Agent__c=agentid;
                        opt.School__c = str;
                        OptOutlist.add(opt);   
                    }
                }
            }
            
            if(OptOutlist.size()>0){
               insert OptOutlist; 
            }
            return 'sucess';               
        }
        catch ( exception e){
            return e.getMessage();   
        }
        
    }
    
   	 @AuraEnabled
    public static WrapperPagination getschoolPage(string contryname,string agentid,Integer pageNumber,Integer pageSize,string searchVal){
       pageSize=Integer.valueOf(System.Label.Pagination);
        
        //map<string,list<wrapperclass>> schoolmap = new map<string,list<wrapperclass>>();
        set<id> schoolids = new set<id>();
        //list<wrapperclass> wrapclaslist = new list<wrapperclass>();
        Id recordTypeIdschool = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - CC').getRecordTypeId();
        Id recordTypeIdhighschool = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - HS').getRecordTypeId();
        Id recordTypeIduniversity = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - University').getRecordTypeId();
        for(Opt_Out_School__c opt : [select School__c,Agent__c from  Opt_Out_School__c where Agent__c=:agentid and School__r.School_s_Country__c=:contryname ]){
           
            schoolids.add(opt.School__c);    
        }
        WrapperPagination wrapclas = new WrapperPagination();
        wrapclas.accWrp = new List<WrapperPagination.wrpCl>();
        Integer accSize =[select Count() from account where School_s_Country__c = :contryname  and NIN__c !='Yes'];
         Integer pSize = (Integer)pageSize;
        Integer pNumber = (Integer)pageNumber;
        
        //Offset for SOQL
        Integer offset = (pNumber - 1) * pSize;
        
        //Total Records
        Integer totalRecords = accSize;
        Integer recordEnd = pSize * pNumber;
        string tempInput =  searchVal + '%';
        for(account acc : [select Name,School_s_Country__c,RecordTypeId,RecordType.Name from account where School_s_Country__c = :contryname  and NIN__c !='Yes' and Name Like:tempInput ]){
            
            if(acc.RecordTypeId == recordTypeIdschool || acc.RecordTypeId == recordTypeIdhighschool || acc.RecordTypeId == recordTypeIduniversity){
                WrapperPagination.wrpCl wrp = new WrapperPagination.wrpCl();
                wrp.sch=acc;
                if(schoolids.size()>0 && schoolids.contains(acc.id)) wrp.isoptout = True;
                else wrp.isoptout = False;
                
                wrapclas.accWrp.add(wrp);
                
            }   
        }
        wrapclas.pageSize = pSize;
        wrapclas.pageNumber = pNumber;
        wrapclas.recordStart = offset + 1;
        wrapclas.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        wrapclas.totalRecords = totalRecords;
        // Pagination 
        return wrapclas;  
    }
    
    /* public class wrapperclass{
        @AuraEnabled
        public boolean isoptout = False;
        @AuraEnabled
        public Account sch = new Account(); 
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
    }*/
    
    public class countrylistclass{
        @AuraEnabled
        public boolean hasoptout = False;
        @AuraEnabled
        public string countryname  = ''; 
    }
}