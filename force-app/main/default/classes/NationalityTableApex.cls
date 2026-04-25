public class NationalityTableApex {
    @AuraEnabled
    public static wrapperclass alreadyexistingnationality(Id accountid){
        
        wrapperclass wrpcls = new wrapperclass();
        
        try{
            list<account> acc = [select name,CurrencyIsoCode from account where id = :accountid];
            if(acc.size() >0){
                wrpcls.accountname = acc[0].Name;
                wrpcls.accountcurrency = acc[0].CurrencyIsoCode;
            }
            wrpcls.status = 'SUCCESS';
            
            for(Commission_Table__c comisin :[Select Nationality__c,CurrencyIsoCode,Amount__c,School__c from Commission_Table__c where 
                                              School__c = :accountid]){ 
                                                  wrpcls.CommissionTablecmap.put(comisin.Nationality__c,comisin);
                                                  wrpcls.CommissionTablelist.add(comisin);
                                              }
            
            Schema.DescribeFieldResult countrylist = Commission_Table__c.Nationality__c.getDescribe();
            List<Schema.PicklistEntry> cList=countrylist.getPicklistvalues();
            for(Schema.PicklistEntry pkv:cList){
                Commission_Table__c comisiontable = new Commission_Table__c();
                comisiontable.Nationality__c = pkv.getLabel();
                comisiontable.School__c = accountid;
                if(!wrpcls.CommissionTablecmap.containsKey(pkv.getLabel())) {
                     wrpcls.CommissionTablecmap.put(pkv.getLabel(),comisiontable); 
                    wrpcls.CommissionTablelist.add(comisiontable);
                }
                
            }
            
            Schema.DescribeFieldResult currencyField = Account.CurrencyIsoCode.getDescribe();        
            List<Schema.PicklistEntry> picList=currencyField.getPicklistvalues();
            for(Schema.PicklistEntry plist:picList)
                wrpcls.currencylist.add(plist.getValue());
            
            return wrpcls;
        }
        
        catch(exception e){
            wrpcls.status = e.getMessage();
            return wrpcls;    
        }
        
    }
    @AuraEnabled
    public static string savenationality(list<Commission_Table__c> nationalitylist,string nationalitycurrency){
        system.debug('nationalitylist-->'+nationalitylist);
        try{
            for(Commission_Table__c con : nationalitylist){
                con.CurrencyIsoCode = nationalitycurrency; 
            }
            upsert nationalitylist;
            return 'SUCCESS';
        }
        catch(exception e){
            return e.getMessage();   
        }
        
        
    }
    public class wrapperclass{
        @AuraEnabled
        public map<string,Commission_Table__c> CommissionTablecmap = new map<string,Commission_Table__c>();
        @AuraEnabled
        public list<Commission_Table__c> CommissionTablelist = new list<Commission_Table__c>();
        @AuraEnabled
        public list<string> currencylist = new list<string>();
        @AuraEnabled
        public string accountname = '';
        @AuraEnabled
        public string accountcurrency = '';
        @AuraEnabled
        public string status ='';
    }
}