public class EnquiryFormController {
    
    @AuraEnabled
    //changed method name used in doinit
    public static  wrapperPicklist getBranchPicklistvalues(){
        wrapperPicklist objWrappr = new wrapperPicklist();
        
        //########################### fetching branch PickList ############################
        Schema.DescribeFieldResult result = Lead.Number_Of_Branches__c.getDescribe();
        List<Schema.PicklistEntry> ple = result.getPicklistValues();
        for( Schema.PicklistEntry f : ple ){
            objWrappr.picklstNoOfBrnch.add( f.getValue() );
        } 
        
        //########################### fetching Country Code Picklist ###########################
        Schema.DescribeFieldResult result2 = Lead.Country_Code__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = result2.getPicklistValues();
        for( Schema.PicklistEntry f : ple2 ){
            objWrappr.picklstCountryCode.add( f.getValue() );
        } 
        
        //########################### fetching Where did you hear about us Picklist ###########################
        Schema.DescribeFieldResult result3 = Lead.Where_did_you_hear_about_us__c.getDescribe();
        List<Schema.PicklistEntry> ple3 = result3.getPicklistValues();
        for( Schema.PicklistEntry f : ple3 ){
            objWrappr.picklstWhrDiduFind.add( f.getValue() );
        } 
        
        //############################## fetching function ########################################
        Schema.DescribeFieldResult result4 = Lead.Function__c.getDescribe();
        List<Schema.PicklistEntry> ple4 = result4.getPicklistValues();
        for( Schema.PicklistEntry f : ple4 ){
            objWrappr.listFunction.add( f.getValue() );
        } 
      //############################## fetching salutation ########################################
        Schema.DescribeFieldResult result5 = Lead.Salutation.getDescribe();
        List<Schema.PicklistEntry> ple5 = result5.getPicklistValues();
        for( Schema.PicklistEntry f : ple5){
            objWrappr.picklstSalutation.add( f.getValue() );
        } 
       /*  Schema.DescribeFieldResult result6 = Lead.Head_Office_Country__c.getDescribe();
        List<Schema.PicklistEntry> ple6 = result6.getPicklistValues();
        for( Schema.PicklistEntry f : ple6){
            objWrappr.listHeadOffcCountry.add( f.getValue() );
        } */
        Schema.sObjectType objType = Lead.getSObjectType();
         Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
         Schema.SObjectField theField = objFieldMap.get('Head_Office_Province_State__c');
         Schema.SObjectField ctrlField = objFieldMap.get('Head_Office_Country__c');
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry pled : contrEntries) {
            String label = pled.getLabel();
            objWrappr.objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objWrappr.objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
         Schema.SObjectField state = objFieldMap.get('Head_Office_Province_State__c');
         Schema.SObjectField city = objFieldMap.get('Head_Office_City__c');
        
        List<Schema.PicklistEntry> stateEntries = state.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> cityEntries = wrapPicklistEntries(city.getDescribe().getPicklistValues());
        List<String> controllingValuesstate = new List<String>();
        
        for (Schema.PicklistEntry ples : stateEntries) {
            String label = ples.getLabel();
            objWrappr.objcitydependent.put(label, new List<String>());
            controllingValuesstate.add(label);
        }
        
        for (PicklistEntryWrapper plew : cityEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objWrappr.objcitydependent.get(controllingValuesstate.get(i)).add(label);
                }
            }
        }
        system.debug('objWrappr-->'+objWrappr.objResults);
        return objWrappr;
    }
    
 
 
    @AuraEnabled
    public static String saveLeadDetailsApex(String leadObj,List<String> functionString) {
        try {
            Lead leadInsert = (Lead)JSON.deserialize(leadObj,Lead.class);
            leadInsert.LeadSource = Label.Website;
            String functionStr = '';
            for(String str : functionString)
                functionStr += str + ';';
            functionStr = functionStr.removeEnd(';');
            leadInsert.Function__c = functionStr;
            String recordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(Label.SubAgency).getRecordTypeId();
            if(String.isNotBlank(recordTypeIdLead))
                leadInsert.recordTypeId = recordTypeIdLead;
            list<string> userids = new list<string>();
        list<task> tasktoinsert = new list<task>();
      /*  profile pro = [Select id from profile where name = 'Maxway System Administrator'];
        for(user userdetail : [select id from user where profileid = :pro.id and isactive = true]){
            userids.add(userdetail.id); 
        }
        Staff__c staftable = [Select name , id from Staff__c where name ='HQ Admin' and OwnerId in :userids LIMIT 1];
            if(staftable.id != null)
            leadInsert.Case_Manager__c ='a0E0p000000gZDWEA2';*/
            system.debug('leadInsert-->'+leadInsert);
            //insert leadInsert;
            //@addedBy Karan Singh Soni 11June19
            //############################################# [Start] invoking default assignment rule ###################################
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
           insert leadInsert;
            //############################################# [End] ######################################################################
            return 'SUCCESS';
        }
        catch(Exception e) {
            return e.getMessage();
        }
    }
    
     public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    public class wrapperPicklist{
         @AuraEnabled public list<String> picklstSalutation =  new list<String>();
        @AuraEnabled public list<String> picklstNoOfBrnch =  new list<String>();
        @AuraEnabled public list<String> picklstHeadCountry =  new list<String>();
        @AuraEnabled public list<String> picklstWhrDiduFind =  new list<String>();
        @AuraEnabled public list<String> picklstCountryCode =  new list<String>();
        @AuraEnabled public list<String> listHeadOffcCountry =  new list<String>();
        @AuraEnabled public list<String> listFunction =  new list<String>();
        @AuraEnabled public Map<String,String> mapCountryMetaData = new Map<String,String>();
        @AuraEnabled public Map<String,String> mapStateMetaData = new Map<String,String>();
         @AuraEnabled public Map<String,List<String>> objResults = new Map<String,List<String>>();
         @AuraEnabled public Map<String,List<String>> objcitydependent = new Map<String,List<String>>();
        
    }
    
}