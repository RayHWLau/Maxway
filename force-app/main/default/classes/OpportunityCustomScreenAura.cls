public without sharing class OpportunityCustomScreenAura {
    
    @AuraEnabled
    public static RecordType[] opportunityMainScreen(string objectname){
        RecordType[] RecType = [Select Id,name From RecordType  Where SobjectType = :objectname]; 
        if(RecType.size()>0)
            return RecType;
        return null;
    }
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =  [SELECT Id, Name FROM ListView WHERE SobjectType = 'Opportunity'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    @AuraEnabled
    public static wrapper getOnLoadData(){
        
        wrapper wrap = new wrapper();
        wrap.oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                      FROM User Where id =: userInfo.getUserId()];
        
        Schema.DescribeFieldResult result = Account.Source_Of_Referral__c.getDescribe();
        List<Schema.PicklistEntry> p = result.getPicklistValues();
        for( Schema.PicklistEntry fe : p){
            wrap.SourceOfReferral.add(fe.getValue());
        }
        for(CurrencyType currencyList : [SELECT Id, IsoCode, ConversionRate FROM CurrencyType]){
          wrap.currencylist.add(currencyList.IsoCode);  
        }
       /* Schema.DescribeFieldResult resultC = CurrencyType.IsoCode.getDescribe();
        List<Schema.PicklistEntry> plC = resultC.getPicklistValues();
        for( Schema.PicklistEntry fe : plC){
            wrap.currencylist.add(fe.getValue());
        }*/
        
        Schema.DescribeFieldResult result0 = Commission_Table__c.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> pl = result0.getPicklistValues();
        for( Schema.PicklistEntry fe : pl){
            wrap.nationality.add(fe.getValue());
        }
        
        
        Schema.DescribeFieldResult result1 = Account.Student_Status__c.getDescribe();
        List<Schema.PicklistEntry> pl1 = result1.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1){
            wrap.studentstatus.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result1k = Account.Data_Origin__c.getDescribe();
        List<Schema.PicklistEntry> plk = result1k.getPicklistValues();
        for( Schema.PicklistEntry fe : plk){
            wrap.accdataorigin.add(fe.getValue());
        }
        
        
        /*   Schema.DescribeFieldResult result2 = Account.Closed_Lost_Reason__c.getDescribe();
List<Schema.PicklistEntry> pl2 = result2.getPicklistValues();
for( Schema.PicklistEntry fe : pl2){
wrap.closeAccountreason.add(fe.getValue());
}*/
        for(StudentClosedLostReason__mdt ClosedLost : [SELECT MasterLabel,Value__c,DeveloperName FROM StudentClosedLostReason__mdt]){
            if(ClosedLost.MasterLabel == 'Account')
                wrap.closeAccountreason = ClosedLost.Value__c.split(',');
            if(ClosedLost.MasterLabel == 'Opportunity'){
                
                wrap.ClosedLostReason = ClosedLost.Value__c.split(',');
            }
            
        }
        
        for(OpportunityStage__mdt OpportunityStage : [SELECT MasterLabel,Stage__c,DeveloperName FROM OpportunityStage__mdt]){
            
            wrap.StageName = OpportunityStage.Stage__c.split(',');
            
        }
        
        
        
        Schema.DescribeFieldResult result3 = Account.Country_Code__c.getDescribe();
        List<Schema.PicklistEntry> pl3 = result3.getPicklistValues();
        for( Schema.PicklistEntry fe : pl3){
            wrap.countryCode.add(fe.getValue());
        }
        
        
        Schema.DescribeFieldResult result4 = Account.Social_Media__pc.getDescribe();
        List<Schema.PicklistEntry> pl4 = result4.getPicklistValues();
        for( Schema.PicklistEntry fe : pl4){
            wrap.socialmedia.add(fe.getValue());
        }
        
        
        Schema.DescribeFieldResult result5 = Account.Level_of_Education__c.getDescribe();
        List<Schema.PicklistEntry> pl5 = result5.getPicklistValues();
        for( Schema.PicklistEntry fe : pl5){
            wrap.levelofeducation.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result6 = Account.Total_Years_of_Education__c.getDescribe();
        List<Schema.PicklistEntry> pl6 = result6.getPicklistValues();
        for( Schema.PicklistEntry fe : pl6){
            wrap.totalyearofeduation.add(fe.getValue());
        }
        
        
        Schema.DescribeFieldResult result7 = Account.Student_at_What_Year__c.getDescribe();
        List<Schema.PicklistEntry> pl7 = result7.getPicklistValues();
        for( Schema.PicklistEntry fe : pl7){
            wrap.studentatwhatyear.add(fe.getValue());
        }
        
        
        Schema.DescribeFieldResult result8 = Account.Start_of_academic_month__c.getDescribe();
        List<Schema.PicklistEntry> pl8 = result8.getPicklistValues();
        for( Schema.PicklistEntry fe : pl8){
            wrap.startofacedmicyear.add(fe.getValue());
        }
        
        
        Schema.DescribeFieldResult result9 = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> pl9 = result9.getPicklistValues();
        for( Schema.PicklistEntry fe : pl9){
            wrap.salutation.add(fe.getValue());
        }
        
        //Added By Ravi on 19 march 2020
        Schema.DescribeFieldResult result01 = Account.Education_System__c.getDescribe();
        List<Schema.PicklistEntry> p20 = result01.getPicklistValues();
        for( Schema.PicklistEntry fe : p20){
            wrap.educationSystem.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result10 = Account.Country_Residing__c.getDescribe();
        List<Schema.PicklistEntry> pl10 = result10.getPicklistValues();
        for( Schema.PicklistEntry fe : pl10){
            wrap.country.add(fe.getValue());
        }
        Schema.DescribeFieldResult result1a = Account.Relationship__pc.getDescribe();
        List<Schema.PicklistEntry> pl1a = result1a.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1a){
            wrap.accRelationship.add(fe.getValue());
        }
        Schema.DescribeFieldResult result1b = Account.gender__c.getDescribe();
        List<Schema.PicklistEntry> pl1b = result1b.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1b){
            wrap.gender.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result1c = Account.eDM__c.getDescribe();
        List<Schema.PicklistEntry> pl1c = result1c.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1c){
            wrap.accedm.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result1d = Account.WeChat_Source__pc.getDescribe();
        List<Schema.PicklistEntry> pl1d = result1d.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1d){
            wrap.accwechatsource.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result1e = Account.Confirmed_client_in_Company_social_media__c.getDescribe();
        List<Schema.PicklistEntry> pl1e = result1e.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1e){
            wrap.accConfirmedclientinCompanysocialmedia.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result11 = Contact.Relationship__c.getDescribe();
        List<Schema.PicklistEntry> pl11 = result11.getPicklistValues();
        for( Schema.PicklistEntry fe : pl11){
            wrap.Relationship.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result1f = Contact.Confirmed_client_in_Company_social_media__c.getDescribe();
        List<Schema.PicklistEntry> pl1f = result1f.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1f){
            wrap.conConfirmedclientinCompanysocialmedia.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result2a = Contact.Social_Media__c.getDescribe();
        List<Schema.PicklistEntry> pl2a = result2a.getPicklistValues();
        for( Schema.PicklistEntry fe : pl2a){
            wrap.consocialmedia.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result2b = Contact.WeChat_Source__c.getDescribe();
        List<Schema.PicklistEntry> pl2b = result2b.getPicklistValues();
        for( Schema.PicklistEntry fe : pl2b){
            wrap.conwechatsource.add(fe.getValue());
        }
        
        
        
        /*      Schema.DescribeFieldResult result12 = Opportunity.Closed_Lost_Reason__c.getDescribe();
List<Schema.PicklistEntry> pl12 = result12.getPicklistValues();
for( Schema.PicklistEntry fe : pl12){
wrap.ClosedLostReason.add(fe.getValue());
} */
        
        
        Schema.DescribeFieldResult result13 = Opportunity.Preferred_School_Type__c.getDescribe();
        List<Schema.PicklistEntry> pl13 = result13.getPicklistValues();
        for( Schema.PicklistEntry fe : pl13){
            wrap.PreferredSchoolType.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result14 = Opportunity.For_HS_Preferred_Program__c.getDescribe();
        List<Schema.PicklistEntry> pl14 = result14.getPicklistValues();
        for( Schema.PicklistEntry fe : pl14){
            wrap.ForHSPreferredProgram.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result15 = Opportunity.For_CC_or_University__c.getDescribe();
        List<Schema.PicklistEntry> pl15 = result15.getPicklistValues();
        for( Schema.PicklistEntry fe : pl15){
            wrap.ForCCorUniversity.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result16 = Opportunity.For_CC_or_University_Preferred_Major__c.getDescribe();
        List<Schema.PicklistEntry> pl16 = result16.getPicklistValues();
        for( Schema.PicklistEntry fe : pl16){
            wrap.ForCCorUniversityPreferredMajor.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result17 = Opportunity.Housing_Option__c.getDescribe();
        List<Schema.PicklistEntry> pl17 = result17.getPicklistValues();
        for( Schema.PicklistEntry fe : pl17){
            wrap.HousingOption.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result18 = Opportunity.Preferred_Countrynew__c.getDescribe();
        List<Schema.PicklistEntry> pl18 = result18.getPicklistValues();
        for( Schema.PicklistEntry fe : pl18){
            wrap.opportunitycountry.add(fe.getValue());
        }
        Schema.DescribeFieldResult result19 = Opportunity.Follow_Up_Situation__c.getDescribe();
        List<Schema.PicklistEntry> pl19 = result19.getPicklistValues();
        for( Schema.PicklistEntry fe : pl19){
            wrap.FollowUpSituation.add(fe.getValue());
        }
        Schema.DescribeFieldResult result20 = Opportunity.Annual_Budget__c.getDescribe();
        List<Schema.PicklistEntry> pl20 = result20.getPicklistValues();
        for( Schema.PicklistEntry fe : pl20){
            wrap.AnnualBudget.add(fe.getValue());
        }
        
        //added on 18 may 2020 as for the multipicklist for the maxway User
        Schema.DescribeFieldResult result21 = Opportunity.Preferred_Country__c.getDescribe();
        List<Schema.PicklistEntry> pl21 = result21.getPicklistValues();
        for( Schema.PicklistEntry fe : pl21){
            wrap.preferredOppCountry.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result22 = Opportunity.Preferred_State__c.getDescribe();
        List<Schema.PicklistEntry> pl22 = result22.getPicklistValues();
        for( Schema.PicklistEntry fe : pl22){
            wrap.preferredOppState.add(fe.getValue());
        }
        
        Schema.DescribeFieldResult result23 = Opportunity.Preferred_City__c.getDescribe();
        List<Schema.PicklistEntry> pl23 = result23.getPicklistValues();
        for( Schema.PicklistEntry fe : pl23){
            wrap.preferredOppCity.add(fe.getValue());
        }
        //end
        
        Schema.sObjectType objType = Account.getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        Schema.SObjectField theField = objFieldMap.get('Come_From_Province__c');
        Schema.SObjectField ctrlField = objFieldMap.get('Country_Residing__c');
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry pled : contrEntries) {
            String label = pled.getLabel();
            wrap.objcountrywithstate.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    wrap.objcountrywithstate.get(controllingValues.get(i)).add(label);
                }
            }
        }
        Schema.SObjectField state = objFieldMap.get('Come_From_Province__c');
        Schema.SObjectField city = objFieldMap.get('Come_From_City__c');
        
        List<Schema.PicklistEntry> stateEntries = state.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> cityEntries = wrapPicklistEntries(city.getDescribe().getPicklistValues());
        List<String> controllingValuesstate = new List<String>();
        
        for (Schema.PicklistEntry ples : stateEntries) {
            String label = ples.getLabel();
            
            //16 June 2020 as this is added as Dependecy is removed from country residing( Also this field is removed from UI ) , 
            //but we need all state picklist value without changing much code,
            //so we added in the first country value then in js it will be added as list independent of country values
            wrap.objcountrywithstate.get(controllingValues.get(0)).add(label);
            
            wrap.objstatewithcity.put(label, new List<String>());
            controllingValuesstate.add(label);
        }
        
        for (PicklistEntryWrapper plew : cityEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    wrap.objstatewithcity.get(controllingValuesstate.get(i)).add(label);
                }
            }
        }
        
        return wrap;
    }
    
    @AuraEnabled
    public static string saveOpportunity( String AccObj,String part1Obj,String part2Obj,String OppObj,String closedlostreason,
                                         String major,String housing,String schooltype,String Country,
                                         String PreferCountry, String PreferState, String PreferCity ){
        system.debug('Country-->'+Country);
        System.debug('closedlostreason-->'+closedlostreason);
        System.debug('major-->'+major);
        System.debug('housing-->'+housing);
        System.debug('schooltype-->'+schooltype);
        
        //added on 18 may 2020 NTF-0709 in case any error found then it should rollback and  no record should be processed.
        Savepoint sp = Database.setSavepoint();
        
        try{
            Id recTypeaccId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
            Id recTypeoppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            Id recTypeconId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Primary Contact').getRecordTypeId();
            
            Account AccountInsert = (Account)JSON.deserialize(AccObj,Account.class);
            
            if(AccountInsert.Id == null){
                AccountInsert.RecordTypeId = recTypeaccId;
                if(AccountInsert.Expected_Graduation_Date__c != null)
                    AccountInsert.Close_Date__c = AccountInsert.Expected_Graduation_Date__c;
                AccountInsert.Student_Status__c='Prospective';
                insert AccountInsert;
            }
            
            
            Contact part1ObjInsert = (Contact)JSON.deserialize(part1Obj,Contact.class); 
            Contact part2ObjInsert = (Contact)JSON.deserialize(part2Obj,Contact.class);
            
            Schema.DescribeSObjectResult a_desc = Contact.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> a_fields = a_desc.fields.getMap();
            
            
            
            integer counter = 0; 
            integer counter1 = 0; 
            
            for(string fld:a_fields.keySet()){
                if(part1ObjInsert.get(fld) != null){
                    Schema.DisplayType fielddataType = a_fields.get(fld).getDescribe().getType();
                    if(fielddataType == Schema.DisplayType.PICKLIST){
                        if(string.isNotBlank((string)part1ObjInsert.get(fld))){
                            
                            counter ++;   
                            system.debug('contac1 -- ' + fld + ' '+part1ObjInsert.get(fld));
                        }
                            
                    }
                    
                }
                if(part2ObjInsert.get(fld)  != null){
                    Schema.DisplayType fielddataType = a_fields.get(fld).getDescribe().getType();
                    if(fielddataType == Schema.DisplayType.PICKLIST){
                        if(string.isNotBlank((string)part2ObjInsert.get(fld))){
                            system.debug('contac2  -- ' + fld + ' '+part1ObjInsert.get(fld));
                            counter1 ++;   
                        }
                            
                    }  
                }
                // system.debug(fld);
            }
            system.debug('counter ---> ' + counter );
            system.debug('counter1 ---> ' + counter1 );
            
            if(counter >0){
                if(part1ObjInsert.id == null){
                    part1ObjInsert.RecordTypeId = recTypeconId;
                    insert part1ObjInsert;
                    if(part1ObjInsert.Relationship__c == 'Father')
                    AccountInsert.Father__c = part1ObjInsert.id;
                    if(part1ObjInsert.Relationship__c == 'Mother')
                    AccountInsert.Mother__c = part1ObjInsert.id;
                    update AccountInsert;
                }
                //else if last name is blank that means all the fields in the Ui is Blank as there was an validation if any of the field is filled on contact then 
                //every contact detail is mandatory
                else if( part1ObjInsert.Id <> Null && String.isBlank( part1ObjInsert.LastName ) ){
                    system.debug('part1ObjInsert --> ' + part1ObjInsert);
                    
                    if( AccountInsert.Father__c == part1ObjInsert.id ){
                        
                        AccountInsert.Father__c = Null;
                    }
                    else if( AccountInsert.Mother__c == part1ObjInsert.id ){
                        
                        AccountInsert.Mother__c = Null;
                    }
                    delete part1ObjInsert;
                }
                else{
                    if( AccountInsert.Father__c == null){
                        if(part1ObjInsert.Relationship__c == 'Father')
                        AccountInsert.Father__c = part1ObjInsert.id;
                        update AccountInsert;    
                    }
                    update part1ObjInsert;  
                }
            }
            
            if(counter1 >0){
                if(part2ObjInsert.id == null){
                    part2ObjInsert.RecordTypeId = recTypeconId;
                    insert part2ObjInsert;
                    if(part2ObjInsert.Relationship__c == 'Father')
                    AccountInsert.Father__c = part2ObjInsert.id;
                    if(part2ObjInsert.Relationship__c == 'Mother')
                    AccountInsert.Mother__c = part2ObjInsert.id;
                    update AccountInsert;
                }
                //else if last name is blank that means all the fields in the Ui is Blank as there was an validation if any of the field is filled on contact then 
                //every contact detail is mandatory
                else if( part2ObjInsert.Id <> Null && String.isBlank( part2ObjInsert.LastName ) ){
                    system.debug('part2ObjInsert --> ' + part2ObjInsert);
                    
                    if( AccountInsert.Father__c == part2ObjInsert.id ){
                        
                        AccountInsert.Father__c = Null;
                    }
                    else if( AccountInsert.Mother__c == part2ObjInsert.id ){
                        
                        AccountInsert.Mother__c = Null;
                    }
                    delete part2ObjInsert;
                }
                else{
                    if( AccountInsert.Mother__c == null){
                         if(part2ObjInsert.Relationship__c == 'Mother')
                        AccountInsert.Mother__c = part2ObjInsert.id;
                        update AccountInsert;    
                    }
                    update part2ObjInsert;  
                }
            }
            
            Opportunity OppObjInsert = (Opportunity)JSON.deserialize(OppObj,Opportunity.class);
            string closedloststring ='';
            string majorstring ='';
            string schooltypestring ='';
            string housingstring ='';
            string countrystring ='';
            if(string.isNotBlank(closedlostreason)){
                list<string> closelostlist = (list<string>)JSON.deserialize(closedlostreason,list<string>.class);
                closedloststring = String.join(closelostlist,';');     
            } 
            if(string.isNotBlank(major)){
                list<string> majorlist = (list<string>)JSON.deserialize(major,list<string>.class);
                majorstring = String.join(majorlist,';');     
            }  
            if(string.isNotBlank(schooltype)){
                list<string> schooltypelist = (list<string>)JSON.deserialize(schooltype,list<string>.class);
                schooltypestring = String.join(schooltypelist,';');     
            }  
            if(string.isNotBlank(housing)){
                list<string> housinglist = (list<string>)JSON.deserialize(housing,list<string>.class);
                housingstring = String.join(housinglist,';');     
            }  
            if(string.isNotBlank(country)){
                list<string> countrylist = (list<string>)JSON.deserialize(country,list<string>.class);
                countrystring = String.join(countrylist,';');     
            }
            system.debug('countrystring ---> ' + countrystring);
            if(OppObjInsert.id == null){
                OppObjInsert.RecordTypeId = recTypeoppId;
                OppObjInsert.AccountId = AccountInsert.id;
                OppObjInsert.stagename='Prospective';
                
                if(OppObjInsert.Intended_Go_Abroad_Date__c != null){
                    OppObjInsert.CloseDate = OppObjInsert.Intended_Go_Abroad_Date__c;}  
               
                //if(string.isNotBlank(housingstring)){
                    OppObjInsert.Housing_Option__c = housingstring; 
                //}
                //if(string.isNotBlank(schooltypestring)){
                    OppObjInsert.Preferred_School_Type__c=schooltypestring;
                //}
                //if(string.isNotBlank(majorstring)){
                    OppObjInsert.For_CC_or_University_Preferred_Major__c= majorstring; 
                //}
                if(string.isNotBlank(countrystring)){
                    OppObjInsert.Preferred_Countrynew__c= countrystring; 
                }
                //added on 18 may 2020
                if( String.isNotBlank(PreferCountry)){
                    
                    list<string> preferlist = (list<string>)JSON.deserialize(PreferCountry,list<string>.class); 
                    OppObjInsert.Preferred_Country__c = String.join( preferlist,';' );  
                }
                else{
                    OppObjInsert.Preferred_Country__c = Null;
                }
                
                if( String.isNotBlank(PreferState)){
                    
                    list<string> preferlist = (list<string>)JSON.deserialize(PreferState,list<string>.class); 
                    OppObjInsert.Preferred_State__c = String.join( preferlist,';' );  
                }
                else{
                    OppObjInsert.Preferred_State__c = Null;
                }
                
                if( String.isNotBlank(PreferCity)){
                    
                    list<string> preferlist = (list<string>)JSON.deserialize(PreferCity,list<string>.class); 
                    OppObjInsert.Preferred_City__c = String.join( preferlist,';' );  
                }
                else{
                    OppObjInsert.Preferred_City__c = Null;
                }
                
                //end 18 may 2020
                if(OppObjInsert.Intended_Go_Abroad_Date__c == null){
                    OppObjInsert.CloseDate = system.today().addmonths(12);
                }
                insert OppObjInsert;
            }
            if(OppObjInsert.id != null){
                
                if(string.isnotblank(closedloststring) || string.isnotblank(OppObjInsert.Closed_Lost_Description__c)){
                    if(string.isNotBlank(housingstring)){
                        OppObjInsert.Housing_Option__c = housingstring; 
                    }
                    if(string.isNotBlank(schooltypestring)){
                        OppObjInsert.Preferred_School_Type__c=schooltypestring;
                    }
                    if(string.isNotBlank(majorstring)){
                        OppObjInsert.For_CC_or_University_Preferred_Major__c= majorstring; 
                    }
                    if(string.isNotBlank(countrystring)){
                        OppObjInsert.Preferred_Countrynew__c= countrystring; 
                    }
                    else{
                        OppObjInsert.Preferred_Countrynew__c= Null;
                    }
                    
                    //added on 18 may 2020
                    if( String.isNotBlank(PreferCountry)){
                        
                        list<string> preferlist = (list<string>)JSON.deserialize(PreferCountry,list<string>.class); 
                        OppObjInsert.Preferred_Country__c = String.join( preferlist,';' );  
                    }
                    else{
                        OppObjInsert.Preferred_Country__c = Null;
                    }
                    
                    if( String.isNotBlank(PreferState)){
                        
                        list<string> preferlist = (list<string>)JSON.deserialize(PreferState,list<string>.class); 
                        OppObjInsert.Preferred_State__c = String.join( preferlist,';' );  
                    }
                    else{
                        OppObjInsert.Preferred_State__c = Null;
                    }
                    
                    if( String.isNotBlank(PreferCity)){
                        
                        list<string> preferlist = (list<string>)JSON.deserialize(PreferCity,list<string>.class); 
                        OppObjInsert.Preferred_City__c = String.join( preferlist,';' );  
                    }
                    else{
                        OppObjInsert.Preferred_City__c = Null;
                    }
                    //end 18 may 2020
                    OppObjInsert.stagename='Closed Lost';
                    OppObjInsert.CloseDate = system.today();
                    if(string.isnotblank(OppObjInsert.Closed_Lost_Description__c)){
                        OppObjInsert.Closed_Lost_Description__c = OppObjInsert.Closed_Lost_Description__c;  
                    }
                    if(string.isnotblank(closedloststring)){
                        OppObjInsert.Closed_Lost_Reason__c=closedloststring;   
                    }
                }
                else{
                    //if(string.isNotBlank(housingstring)){
                        OppObjInsert.Housing_Option__c = housingstring; 
                    //}
                    //if(string.isNotBlank(schooltypestring)){
                        OppObjInsert.Preferred_School_Type__c=schooltypestring;
                    //}
                    //if(string.isNotBlank(majorstring)){
                    OppObjInsert.For_CC_or_University_Preferred_Major__c= majorstring; 
                    //}
                    if(string.isNotBlank(countrystring)){
                        OppObjInsert.Preferred_Countrynew__c= countrystring; 
                    }
                    else{
                        OppObjInsert.Preferred_Countrynew__c= Null;
                    }
                    if(OppObjInsert.Intended_Go_Abroad_Date__c != null){
                        OppObjInsert.CloseDate = OppObjInsert.Intended_Go_Abroad_Date__c;  
                    }
                    if(OppObjInsert.Intended_Go_Abroad_Date__c == null){
                        OppObjInsert.CloseDate = system.today().addmonths(12);
                    }
                    
                    //added on 18 may 2020
                    if( String.isNotBlank(PreferCountry)){
                        
                        list<string> preferlist = (list<string>)JSON.deserialize(PreferCountry,list<string>.class); 
                        OppObjInsert.Preferred_Country__c = String.join( preferlist,';' );  
                    }
                    else{
                        OppObjInsert.Preferred_Country__c = Null;
                    }
                    
                    if( String.isNotBlank(PreferState)){
                        
                        list<string> preferlist = (list<string>)JSON.deserialize(PreferState,list<string>.class); 
                        OppObjInsert.Preferred_State__c = String.join( preferlist,';' );  
                    }
                    else{
                        OppObjInsert.Preferred_State__c = Null;
                    }
                    
                    if( String.isNotBlank(PreferCity)){
                        
                        list<string> preferlist = (list<string>)JSON.deserialize(PreferCity,list<string>.class); 
                        OppObjInsert.Preferred_City__c = String.join( preferlist,';' );  
                    }
                    else{
                        OppObjInsert.Preferred_City__c = Null;
                    }
                    //end 18 May 2020
                }
                system.debug('OppObjInsert ---> ' + OppObjInsert.Preferred_Countrynew__c);
                update OppObjInsert;
            }
            if(AccountInsert.Id != null){
                if(AccountInsert.Expected_Graduation_Date__c != null)
                    AccountInsert.Close_Date__c = AccountInsert.Expected_Graduation_Date__c;
                update AccountInsert;   
            }
            
            return 'success;'+OppObjInsert.id;
        }
        catch(DmlException e) {
            //rollbacking in case if Dupplicate opportunity found then no Account and Contact
            Database.rollback( sp );
            system.debug('e.getMessage() ---> ' + e.getMessage());
            return e.getMessage().split(',')[1];
        }
        
        
    }
    @AuraEnabled
    public static oppacccon1con2Wrapclass prepopaccdetails(string accountid){
        system.debug('accountid-->'+accountid);
        string accfields ='';
        string confields ='';
        Schema.DescribeSObjectResult acc_desc = Account.sObjectType.getDescribe(); 
        Map<String, Schema.SObjectField> acc_fields = acc_desc.fields.getMap();
        
        
        for(Schema.sObjectField fld:acc_fields.values()){ 
            accfields = accfields + fld +',';
        }
        
        accfields = accfields.removeEnd(',') ;
        
        Schema.DescribeSObjectResult con1_desc = Contact.sObjectType.getDescribe(); 
        Map<String, Schema.SObjectField> con1_fields = con1_desc.fields.getMap();
        
        
        for(Schema.sObjectField fld:con1_fields.values()){ 
            
            confields = confields + fld +',';
        }
        
        confields = confields.removeEnd(',') ;
        
        
        string accid = accountid.trim();
        list<account> acc = Database.Query('select '+accfields +' from account where id = :accid');
        list<contact> con1 = new list<contact>();
        list<contact> con2 = new list<contact>();
        if(acc.size()>0){
            if(acc[0].father__c != null){
                string fatherid = acc[0].father__c;
                con1 = Database.Query('select '+confields +' from contact where id = :fatherid');
            }
            
            if(acc[0].Mother__c != null){
                string motherid = acc[0].Mother__c;
                con2 = Database.Query('select '+confields +' from contact where id = :motherid');
            }
            
            
            oppacccon1con2Wrapclass warp = new oppacccon1con2Wrapclass();
            warp.accountdetail = acc[0];
            if(con1.size()>0)
                warp.parent1 = con1[0];
            if(con2.size()>0)
                warp.parent2 = con2[0];
            
            return warp;  
        }
        return null;
    }
    @AuraEnabled
    public static oppacccon1con2Wrapclass prepopparentdetails(string parentid){
        system.debug('parentid-->'+parentid);
        string accfields ='';
        string confields ='';
        Schema.DescribeSObjectResult acc_desc = Account.sObjectType.getDescribe(); 
        Map<String, Schema.SObjectField> acc_fields = acc_desc.fields.getMap();
        
        
        for(Schema.sObjectField fld:acc_fields.values()){ 
            accfields = accfields + fld +',';
        }
        
        accfields = accfields.removeEnd(',') ;
        
        Schema.DescribeSObjectResult con1_desc = Contact.sObjectType.getDescribe(); 
        Map<String, Schema.SObjectField> con1_fields = con1_desc.fields.getMap();
        
        
        for(Schema.sObjectField fld:con1_fields.values()){ 
            
            confields = confields + fld +',';
        }
        
        confields = confields.removeEnd(',') ;
        
        
        string accid = parentid.trim();
        list<account> acc = Database.Query('select '+accfields +' from account where father__c = :accid or Mother__c =:accid');
        list<contact> con1 = new list<contact>();
        list<contact> con2 = new list<contact>();
        if(acc.size()>0){
            if(acc[0].father__c != null){
                string fatherid = acc[0].father__c;
                con1 = Database.Query('select '+confields +' from contact where id = :fatherid');
            }
            
            if(acc[0].Mother__c != null){
                string motherid = acc[0].Mother__c;
                con2 = Database.Query('select '+confields +' from contact where id = :motherid');
            }
            
            
            oppacccon1con2Wrapclass warp = new oppacccon1con2Wrapclass();
            warp.accountdetail = acc[0];
            if(con1.size()>0)
                warp.parent1 = con1[0];
            if(con2.size()>0)
                warp.parent2 = con2[0];
            
            return warp;  
        }
        else{
            con1 = Database.Query('select '+confields +' from contact where id = :accid'); 
            oppacccon1con2Wrapclass warp = new oppacccon1con2Wrapclass();
            
            if(con1.size()>0)
                warp.parent1 = con1[0];
            
            
            return warp;
        }
    }
    @AuraEnabled
    public static oppacccon1con2Wrapclass editopportunity(String oppid) {
        if(oppid != null){
            system.debug('oppid-->'+oppid);
            
            string oppfields = ''; 
            string accfields = ''; 
            string par1fields = ''; 
            string par2fields = ''; 
            
            Schema.DescribeSObjectResult opp_desc = Opportunity.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> opp_fields = opp_desc.fields.getMap();
            
            for(Schema.sObjectField fld:opp_fields.values()){ 
                oppfields = oppfields + fld +',';
                //  system.debug(fld);
            }
            
            oppfields = oppfields.removeEnd(',') ;
            
            Schema.DescribeSObjectResult acc_desc = Account.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> acc_fields = acc_desc.fields.getMap();
            
            for(Schema.sObjectField fld:acc_fields.values()){ 
                accfields = accfields + fld +',';
                // system.debug(fld);
            }
            
            accfields = accfields.removeEnd(',') ;
            
            Schema.DescribeSObjectResult con1_desc = Contact.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> con1_fields = con1_desc.fields.getMap();
            
            for(Schema.sObjectField fld:con1_fields.values()){ 
                par1fields = par1fields + fld +',';
                //   system.debug(fld);
            }
            
            par1fields = par1fields.removeEnd(',') ;
            
            Schema.DescribeSObjectResult con2_desc = Contact.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> con2_fields = con2_desc.fields.getMap();
            
            for(Schema.sObjectField fld:con2_fields.values()){ 
                par2fields = par2fields + fld +','; 
                //  system.debug(fld);
            }
            
            par2fields = par2fields.removeEnd(',') ;
            
            opportunity opp = Database.Query('select '+oppfields +' from opportunity where id = :oppid');
            string accountid = opp.AccountId;
            account acc = Database.Query('select '+accfields +' from account where id = :accountid');
            list<contact> con1 = new list<contact>();
            list<contact> con2 = new list<contact>();
            system.debug('acc --> ' + acc.Original_Grade_Mapping__c);
            if(acc.father__c != null){
                string fatherid = acc.father__c;
                con1 = Database.Query('select '+par1fields +' from contact where id = :fatherid');
            }
            
            if(acc.Mother__c != null){
                string motherid = acc.Mother__c;
                con2 = Database.Query('select '+par2fields +' from contact where id = :motherid');
            }
            list<case> applicationlist = [select id,Rejected_By__c from case where opportunity__c=:oppid];
            
            
            oppacccon1con2Wrapclass warp = new oppacccon1con2Wrapclass();
            warp.oppdetail = opp;
            system.debug('test-->'+opp.Preferred_School_Type__c);
            system.debug('test-->'+opp.For_CC_or_University_Preferred_Major__c);
            system.debug('test-->'+opp.Housing_Option__c);
            if(string.isNotblank(opp.Closed_Lost_Reason__c)){
                warp.oppcloselost = opp.Closed_Lost_Reason__c.split(';');
            }
            if(string.isNotBlank(opp.Housing_Option__c)){
                warp.housing = opp.Housing_Option__c.split(';');   
            }
            if(string.isNotBlank(opp.Preferred_School_Type__c)){
                warp.schooltype = opp.Preferred_School_Type__c.split(';');  
            }
            if(string.isNotBlank(opp.For_CC_or_University_Preferred_Major__c)){
                warp.major = opp.For_CC_or_University_Preferred_Major__c.split(';');   
            }
              if(string.isNotblank(opp.Preferred_Countrynew__c)){
                warp.country = opp.Preferred_Countrynew__c.split(';');
            }
            
            //added on 18 May 2020
            
            if( String.isNotBlank( opp.Preferred_Country__c )){
                warp.selectdOppCountry = opp.Preferred_Country__c.split(';');
            }
            
            if( String.isNotBlank( opp.Preferred_State__c )){
                warp.selectdOppState = opp.Preferred_State__c.split(';');
            }
            
            if( String.isNotBlank( opp.Preferred_City__c )){
                warp.selectdOppCity = opp.Preferred_City__c.split(';');
            }
            //end 18 May 2020
            warp.accountdetail = acc;
            if(string.isNotblank(acc.dont_contact_reason__C)){
                warp.accloselost = acc.dont_contact_reason__C.split(';');
            }
          
            
            
            if(applicationlist.size()==0) warp.cancloselost = true;
            
            integer counter = 0;
            if(applicationlist.size()>0){
                for(case app: applicationlist){
                    if(app.Rejected_By__c != 'Maxway' && string.isNotBlank(app.Rejected_By__c)){
                        counter++;   
                    }
                }
                if(counter==applicationlist.size()) warp.cancloselost = true;
            }
            if(con1.size()>0)
                warp.parent1 = con1[0];
            if(con2.size()>0)
                warp.parent2 = con2[0];
            
            warp.oUser = [select id,Name,TimeZoneSidKey,Username,Alias,Country,Email,FirstName,LastName,IsActive,IsPortalEnabled 
                      FROM User Where id =: userInfo.getUserId()];
            return warp;
        }
        return null;
    }
    @AuraEnabled
    //changed method name used in doinit
    public static  list<opplist> oppdisplay(string oppid){
        system.debug('nnh'+oppid);
        id userid = UserInfo.getUserId();
        list<opplist> wrapopptlist = new list<opplist>();  
        string oppfields = ''; 
        
        Schema.DescribeSObjectResult opp_desc = Opportunity.sObjectType.getDescribe(); 
        Map<String, Schema.SObjectField> opp_fields = opp_desc.fields.getMap();
        
        
        for(Schema.sObjectField fld:opp_fields.values()){ 
            oppfields = oppfields + fld +',';
            
        }
        
        oppfields = oppfields.removeEnd(',') ;
        account acc = [select recordtypeid from account where id =:oppid];
        system.debug('Account'+acc);
        //added on 21 may 2020 as dynamic query
        //also if current user is in the account team of the student record then it should be able to see the record.
        String query = 'select Account.OwnerId,Account.Name,Id,Status,ContractNumber from contract where accountid = :accountid';
        Boolean isCurrentUserAccountTeamMeember = false;
        for( AccountTeamMember objAccount : [ SELECT Id, UserId, AccountAccessLevel 
                                             FROM AccountTeamMember 
                                             WHERE AccountId =: acc.Id ] ){
                                                 
                                                 if( objAccount.UserId == userid ){
                                                     isCurrentUserAccountTeamMeember = true;
                                                 }
                                             }//end of loop       
        
        if(acc.recordtypeid != null){
            Id recordTypeIdOpp = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId(); 
            if(acc.recordtypeid==recordTypeIdOpp){
                opplist oppo = new opplist();
                oppo.Name ='show';
                oppo.show = true;
                wrapopptlist.add(oppo);
                
                //added 21 may 2020 added dynamic query according to the user
                String queryString = 'select '+oppfields +',Account.Name from opportunity where accountid = :oppid';
                
                if( !isCurrentUserAccountTeamMeember ){
                 queryString += ' and account.ownerid =:userid'   ;
                }
                
                for(opportunity  opp : Database.Query(queryString)){
                    opplist oppor = new opplist();
                    //oppor.oppId= 'https://tmcdev-maxway.cs74.force.com/s/detail/'+opp.Id;commented on 29 may 2020 as Url is different in each sandbox
                    oppor.oppId= label.CommunityDomainUrl+opp.Id;
                    oppor.Name =  opp.Name;
                    oppor.status= opp.Stagename;
                    oppor.accountname =  opp.Account.Name; 
                    wrapopptlist.add(oppor);
                    system.debug('nnh'+opp.Name);
                    system.debug('nnh'+oppor.Name);
                }
                return wrapopptlist;   
            }   
        }
        return null; 
        
        
    }
    
    public class opplist{
        @AuraEnabled public String oppId = '';
        @AuraEnabled public String Name = '';
        @AuraEnabled public String status = '';
        @AuraEnabled public String accountname = '';
        @AuraEnabled public boolean show ; 
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
    
    
    public class wrapper{
        @AuraEnabled public string recordtype = '';
        @AuraEnabled public list<string> salutation = new list<string>();  
        @AuraEnabled public list<string> studentstatus = new list<string>();
        @AuraEnabled public list<string> closeAccountreason = new list<string>();
        @AuraEnabled public list<string> SourceOfReferral = new list<string>();
        @AuraEnabled public list<string> countryCode = new list<string>();
        @AuraEnabled public list<string> socialmedia = new list<string>();
        @AuraEnabled public list<string> nationality = new list<string>();
        @AuraEnabled public list<string> levelofeducation = new list<string>();
        @AuraEnabled public list<string> totalyearofeduation = new list<string>();
        @AuraEnabled public list<string> studentatwhatyear = new list<string>();
        @AuraEnabled public list<string> startofacedmicyear = new list<string>();
        @AuraEnabled public list<string> country = new list<string>();
        @AuraEnabled public list<string> gender = new list<string>();
        @AuraEnabled public list<string> accdataorigin = new list<string>();
        @AuraEnabled public list<string> accRelationship = new list<string>();
        @AuraEnabled public list<string> accedm = new list<string>();
        @AuraEnabled public list<string> accwechatsource = new list<string>();
        @AuraEnabled public list<string> accConfirmedclientinCompanysocialmedia = new list<string>();
        @AuraEnabled public list<string> Relationship = new list<string>();
        @AuraEnabled public list<string> conConfirmedclientinCompanysocialmedia = new list<string>();
        @AuraEnabled public list<string> conwechatsource = new list<string>();
        @AuraEnabled public list<string> consocialmedia = new list<string>();
        @AuraEnabled public list<string> StageName = new list<string>();
        @AuraEnabled public list<string> ClosedLostReason = new list<string>();
        @AuraEnabled public list<string> FollowUpSituation = new list<string>();
        @AuraEnabled public list<string> AnnualBudget  = new list<string>();
        @AuraEnabled public list<string> PreferredSchoolType = new list<string>();
        @AuraEnabled public list<string> ForHSPreferredProgram = new list<string>();
        @AuraEnabled public list<string> ForCCorUniversity = new list<string>();
        @AuraEnabled public list<string> ForCCorUniversityPreferredMajor = new list<string>();
        @AuraEnabled public list<string> HousingOption = new list<string>();
        @AuraEnabled public list<string> opportunitycountry = new list<string>();
        @AuraEnabled public list<string> currencylist = new list<string>();
        // Added By Ravi on 19 march 2020
        @AuraEnabled public list<string> educationSystem = new list<string>();
        @AuraEnabled public user oUser = new user();
        @AuraEnabled public Map<String,List<String>> objcountrywithstate = new Map<String,List<String>>();
        @AuraEnabled public Map<String,List<String>> objstatewithcity = new Map<String,List<String>>();
        
        //added on 18 May 2020 As now Maxway user will see the multipicklist fields
        @AuraEnabled public list<string> preferredOppCountry = new list<string>();
        @AuraEnabled public list<string> preferredOppState = new list<string>();
        @AuraEnabled public list<string> preferredOppCity = new list<string>();
        
        
        
    }
    public class oppacccon1con2Wrapclass{
        @AuraEnabled public account accountdetail = new account();  
        @AuraEnabled public opportunity oppdetail = new opportunity();
        @AuraEnabled public contact parent1 = new contact();
        @AuraEnabled public contact parent2 = new contact();
        @AuraEnabled public boolean cancloselost = false; 
        @AuraEnabled public list<string> accloselost = new list<string>();
        @AuraEnabled public list<string> oppcloselost = new list<string>();
        @AuraEnabled public list<string> housing = new list<string>();
        @AuraEnabled public list<string> major = new list<string>();
        @AuraEnabled public list<string> schooltype = new list<string>();
        @AuraEnabled public list<string> country = new list<string>();
        
        //added on 18 May 2020 As now Maxway user will see the multipicklist fields
        @AuraEnabled public list<string> selectdOppCountry = new list<string>();
        @AuraEnabled public list<string> selectdOppState = new list<string>();
        @AuraEnabled public list<string> selectdOppCity = new list<string>();
         @AuraEnabled public user oUser = new user();
    }
    // Added By Ravi on 20th march 2020
    @AuraEnabled
    public static string getUser(string userId){
       return [select Id,Name,Email,Contact.Account.Agent_Code__c from user where Id=:userId].Contact.Account.Agent_Code__c;
    }
   
}