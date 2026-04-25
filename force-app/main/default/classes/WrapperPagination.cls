public class WrapperPagination {
	@AuraEnabled
    public wrpCl[] accWrp {get;set;}
    public class wrpCl{
       @AuraEnabled
        public boolean isoptout = False;
        @AuraEnabled
        public Account sch = new Account();  
    }
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
       
}