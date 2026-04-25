public class ProgramTriggerHelper {
	public static final List<CurrencyCountry__mdt> currencyCountrySettings = [SELECT Label, Currency__c FROM CurrencyCountry__mdt WHERE Active__c = TRUE];
    public static void ValidateCurrency(List<Program__c> prg){
        set<String> campId = new set<String>();
        map<String,String> mapToCountry = new map<String,String>();
        
        //added on 17 June 2020 as this validation should only work for CC,Hs,University
        Id HSProgram = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('HighSchool').getRecordTypeId();
        Id CCProgram = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('CC').getRecordTypeId();
        Id UniProgram = Schema.SObjectType.Program__c.getRecordTypeInfosByDeveloperName().get('Uni').getRecordTypeId();
        set< Id > setValidRecordType = new set< Id >();
        
        setValidRecordType.add( HSProgram );
        setValidRecordType.add( CCProgram );
        setValidRecordType.add( UniProgram );
        
        for(Program__c pr:prg){
            //if(pr.Campus__c != NULL){ commented on 17 june 2020
            if( pr.Campus__c != NULL && setValidRecordType.contains( pr.RecordTypeId ) ){
                campId.add(pr.Campus__c);   
            }
        }
        for(Campus__c csmp:[select Country_New__c,Id from Campus__c where Id in:campId]){
            mapToCountry.put(csmp.Id,csmp.Country_New__c);
        }
        //added on 17 APril 2020 as per Feedback NTF-0593 This validation should be for maxway user only
        Set< Id > setProfileData =  ( new Map< Id, Profile >( [ SELECT Id, Name FROM Profile WHERE Name Like 'Partner%' ] ) ).keySet();
        
        for(Program__c p:prg){
            
            if( setProfileData.contains( UserInfo.getProfileId() )) continue; // added on 17 APril 2020 if current is not Maxway User then skip it.
            
            if(mapToCountry.containsKey(p.Campus__c)){
                if(!checkCountry(p.CurrencyIsoCode,p.Campus__c,mapToCountry)){
                	p.AddError('Currency should be same as Campus Country');
                }
            }
        }
        
    }
    
    public static boolean checkCountry(string currencyCode ,string campId,map<string,string> mapToCon){
        String campusCountry =  mapToCon.get(campId);
        if(String.isBlank(campusCountry) && currencyCode != 'HKD') {
            return false;
        }
        
        for(CurrencyCountry__mdt currencyCountrySetting : currencyCountrySettings) {
            if(currencyCountrySetting.Label == campusCountry && currencyCode == currencyCountrySetting.Currency__c) {
                return true;
            }
        }
        
        return false;
        /*
        if(curency =='USD'){
            if(mapToCon.get(campId) =='United States'){
                return true;
            }else{
                return false;
            }       
        }
        if(curency =='NZD'){
            if(mapToCon.get(campId) =='New Zealand'){
                return true;
            }else{
                return false;
            }       
        }
         if(curency =='HKD'){
            if(mapToCon.get(campId) ==''){
                return true;
            }else{
                return false;
            }       
        }
        if(curency =='CNY'){
            if(mapToCon.get(campId) =='China'){
                return true;
            }else{
                return false;
            }       
        }
        if(curency =='CAD'){
            if(mapToCon.get(campId) =='Canada'){
                return true;
            }else{
                return false;
            }       
        }
        if(curency =='AUD'){
            if(mapToCon.get(campId) =='Australia'){
                return true;
            }else{
                return false;
            }       
        }
        if(curency =='GBP'){
            if(mapToCon.get(campId) =='United Kingdom'){
                return true;
            }else{
                return false;
            }       
        }
        return false;
*/
    }
}