public class SchoolSearchAura {
    
    
    @AuraEnabled
    //changed method name used in doinit
    //___________________________________________________________  Initialization  __________________________________________________________________--
    public static  wrapperPicklist getBranchPicklistvalues(){
        wrapperPicklist objWrappr = new wrapperPicklist();
        Id userid = UserInfo.getUserId();
        user usr = [Select contact.account.School_List_Purchased__c from user where id = :userid ];
        if(usr.contact.account.School_List_Purchased__c != null) objWrappr.countrynames = usr.contact.account.School_List_Purchased__c;
        
        system.debug('dsd-->'+objWrappr.countrynames);
        
        
        Schema.DescribeFieldResult result0 = Commission_Table__c.Nationality__c.getDescribe();
        List<Schema.PicklistEntry> pl = result0.getPicklistValues();
        for( Schema.PicklistEntry fe : pl){
            objWrappr.picklstnationality.add( fe.getValue() );
        }
        
        //########################### fetching program type  PickList ############################
        
        for(ProgramTypeForDifferentSchool__mdt programtype : [SELECT MasterLabel,ProgramType__c,DeveloperName FROM ProgramTypeForDifferentSchool__mdt]){
            if(programtype.masterlabel == 'HS'){
                string [] programtypeArray = programtype.ProgramType__c.split(',');
                objWrappr.picklstprogramtypeHS.addall(programtypeArray);
            }
            if(programtype.masterlabel == 'PS'){
                string [] programtypeArray = programtype.ProgramType__c.split(',');
                objWrappr.picklstprogramtypePS.addall(programtypeArray);
            }
            if(programtype.masterlabel == 'PG'){
                string [] programtypeArray = programtype.ProgramType__c.split(',');
                objWrappr.picklstprogramtypePG.addall(programtypeArray);
            }
            //added on 8 may 2020 as for dependent picklist
            objWrappr.mapProgramDependent.put( programtype.masterlabel, programtype.ProgramType__c.split(','));
        }
        
        //########################### fetching Housing Picklist ###########################
        /* Schema.DescribeFieldResult result2 = Campus__c.Housing_Option__c.getDescribe();
List<Schema.PicklistEntry> ple2 = result2.getPicklistValues();
for( Schema.PicklistEntry f : ple2 ){
objWrappr.picklsthousing.add( f.getValue() );
} */
        objWrappr.picklsthousing.add('Homestay');
        objWrappr.picklsthousing.add('Dorm');
        
        //############################## fetching Intended grade ########################################
        
        for(IntendedGradeHS__mdt intentendedgrade : [SELECT MasterLabel,IntendedGrade__c,DeveloperName FROM IntendedGradeHS__mdt]){
            
            string [] intentendedgradeArray = intentendedgrade.IntendedGrade__c.split(',');
            objWrappr.picklstintendedgrade.addall(intentendedgradeArray);
            
        }
        //############################## fetching countrywithcurrency ########################################
        
        for(CurrencyCountry__mdt countrywithcurrency : [SELECT MasterLabel,Active__c,Currency__c,DeveloperName FROM CurrencyCountry__mdt where Active__c=true]){
            
            objWrappr.mapcountrywithcurrency.put(countrywithcurrency.masterlabel,countrywithcurrency.currency__c);
        }
        
        //############################## fetching Student’s age when start postsecondary overseas (Admission Age)  ########################################
        Schema.DescribeFieldResult result5 = Program__c.Admission_Age__c.getDescribe();
        List<Schema.PicklistEntry> ple5 = result5.getPicklistValues();
        for( Schema.PicklistEntry f : ple5 ){
            objWrappr.picklstStudentAgeWhenStartpostsecondaryOverseas.add( f.getValue() );
        } 
        //############################## fetching high school grad ########################################
        Schema.DescribeFieldResult result6 = Program__c.High_School_Graduation_Needed__c.getDescribe();
        /* List<Schema.PicklistEntry> ple6 = result6.getPicklistValues();
for( Schema.PicklistEntry f : ple6 ){
objWrappr.picklstHighSchoolGrad.add( f.getValue() );
} */
        objWrappr.picklstHighSchoolGrad.add('Yes');
        objWrappr.picklstHighSchoolGrad.add('No');
        //############################## fetching program objective ########################################
        
        for(ProgramObjective__mdt programobjective : [SELECT MasterLabel,ProgramObjective__c,DeveloperName FROM ProgramObjective__mdt]){
            
            if(programobjective.masterlabel == 'PS'){
                string [] programObjectiveArray = programobjective.ProgramObjective__c.split(';');
                objWrappr.picklstProgramObjectivePS.addall(programObjectiveArray);
            }
            if(programobjective.masterlabel == 'PG'){
                string [] programObjectiveArray = programobjective.ProgramObjective__c.split(';');
                objWrappr.picklstProgramObjectivePG.addall(programObjectiveArray);
            }
        }
        
        //############################## fetching Bachelore ########################################
        Schema.DescribeFieldResult result8 = Program__c.Bachelor_Needed__c.getDescribe();
        /*  List<Schema.PicklistEntry> ple8 = result8.getPicklistValues();
for( Schema.PicklistEntry f : ple8 ){
objWrappr.picklstbachloreneeded.add( f.getValue() );
} */
        objWrappr.picklstbachloreneeded.add('Yes');
        objWrappr.picklstbachloreneeded.add('No');
        
        Schema.sObjectType objType = Campus__c.getSObjectType();
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        Schema.SObjectField theField = objFieldMap.get('Province_State_New__c');
        Schema.SObjectField ctrlField = objFieldMap.get('Country_New__c');
        
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
        Schema.SObjectField state = objFieldMap.get('Province_State_New__c');
        Schema.SObjectField city = objFieldMap.get('Nearest_Big_City_New__c');
        
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
        
        //_________________________________________________ Fetching Ielts PickList _______________________________________________________
        
        
        Schema.DescribeFieldResult result01 = Program__c.IELTS_Min__c.getDescribe();
        List<Schema.PicklistEntry> pl1 = result01.getPicklistValues();
        for( Schema.PicklistEntry fe : pl1){
            
            if( fe.getValue() != '0' )
                objWrappr.listIeltsOptions.add(String.valueOf( fe.getValue() ));
            
        }
        system.debug('objWrappr.listIeltsOptions --> ' + objWrappr.listIeltsOptions);
        system.debug('objWrappr-->'+objWrappr.objResults);
        return objWrappr;
    }
    
    
    //___________________________________________________________  High School Data Retrieve  __________________________________________________________
    @AuraEnabled
    public static list<HSschool> returnSearchedHighSchool( string nationality, string country , string programtype , string minbudget,
                                                          string maxbudget, string grade , string province , string city,
                                                          string housing,string currencycode ){
                                                              
                                                              system.debug('nationality-->'+nationality);system.debug('country-->'+country);system.debug('programtype-->'+programtype); 
                                                              system.debug('minbudget-->'+minbudget);system.debug('maxbudget-->'+maxbudget);system.debug('grade-->'+grade);system.debug('province-->'+province); 
                                                              system.debug('city-->'+city);system.debug('housing-->'+housing);system.debug('currencycode-->'+currencycode);
                                                              
                                                              //this is to show the total no of school found
                                                                 set< String > setSchoolName = new set< String >();
                                                              
                                                              map<String,HSschool> mapOfSchoolModal = new map<String,HSschool>();
                                                              
                                                              list<HSschool> schoolList = new list<HSschool>();
                                                              
                                                              set<string> schoolids = new set<string>();
                                                              set<string> programtypes = new set<string>();
                                                              //    programtypes.add('All Grades Offered');
                                                              programtypes.add(programtype);
                                                              decimal budgut = decimal.valueOf(maxbudget);
                                                              
                                                              /*   List<CurrencyType> currencyList = [SELECT Id, IsoCode, ConversionRate FROM CurrencyType];

Map<String,Decimal> IsoCode_cRate = new Map<String,Decimal>();

for(CurrencyType ct: currencyList){
IsoCode_cRate.put(ct.IsoCode,ct.ConversionRate);
}
if(IsoCode_cRate.containskey(currencycode)) budgut = budgut*(1 / IsoCode_cRate.get(currencycode));

system.debug('budgut-->'+budgut);

system.debug('IsoCode_cRate.get(currencycode)-->'+IsoCode_cRate.get(currencycode)); */
                                                              
                                                              Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - HS').getRecordTypeId();
                                                              
                                                              for(Commission_Table__c com :[select School__c from Commission_Table__c where Nationality__c=:nationality and School__r.RecordTypeId =:recTypeId and School__r.School_s_Country__c =:country AND Amount__c > 0]){
                                                                  schoolids.add(com.School__c);
                                                              } 
                                                              Id userid = UserInfo.getUserId();
                                                              boolean isportal = false;
                                                              user usr = [Select isportalenabled,contact.accountid from user where id = :userid ];  
                                                              
                                                              if(usr.IsPortalEnabled == true){
                                                                  isportal =true;
                                                                  for(opt_out_School__c oppoutlist : [select id,School__c from opt_out_School__c where agent__c = :usr.contact.accountid]) {
                                                                      if(schoolids.contains(oppoutlist.School__c)){
                                                                          schoolids.remove(oppoutlist.School__c);   
                                                                      }  
                                                                  }
                                                              }
                                                              
                                                              if(schoolids.size()>0){
                                                                  if(programtype == 'All Grades Offered'){
                                                                      system.debug('schoolids-->'+schoolids);
                                                                      string queryall = 'select Id,Name,CurrencyIsoCode,Campus__r.Student_taking_IB__c,Campus__r.ATAR__c,Campus__r.Account__r.Name,Campus__r.Account__r.School_s_Flyer__c,Campus__r.GCSE_Results_Grade_Range__c,Est_Annual_Cost__c ,Campus__r.GCSE_Results__c,Campus__r.A_Level_Results_Grade_Range__c,Campus__r.A_Level_Results_Numeric__c,Campus__r.School_Gender__c,Campus__r.ACT_Average_Score__c,Admission_Grade__c,Program_Type__c,Campus__r.Housing_Option__c, ';
                                                                      queryall += 'Campus__r.Province_State_New__c,Campus__r.Nearest_Big_City_New__c,Campus__r.Fraser_Institute__c,Campus__r.Account__r.Annual_Tuition_Fees__c ,Campus__r.IB_Average__c,Campus__r.SAT_Average_Score__c from Program__c where';
                                                                      queryall += ' Program_Type__c in :programtypes and Campus__r.Account__c in :schoolids and Est_Annual_Cost__c <=:budgut and CurrencyIsoCode = :currencycode';
                                                                      
                                                                      if(string.isNotBlank(province)){
                                                                          queryall += ' AND Campus__r.Province_State_New__c=:province';
                                                                      }
                                                                      if(string.isNotBlank(city)){
                                                                          queryall += ' AND Campus__r.Nearest_Big_City_New__c=:city';
                                                                      }
                                                                      
                                                                      if(string.isNotBlank(housing)){
                                                                          String housingHS = '';
                                                                          housingHS += '\'' + housing + '\'';
                                                                          queryall += ' AND Campus__r.Housing_Option__c includes ('+housingHS+')';    
                                                                      }
                                                                      if(string.isNotBlank(grade)){
                                                                          String admissiongrade = '';
                                                                          admissiongrade += '\'' + grade + '\'';
                                                                          queryall += ' AND Admission_Grade__c includes ('+admissiongrade+')';
                                                                      }
                                                                      
                                                                      system.debug('@@@@@queryall------> '+queryall);
                                                                      set<string> campusid = new set<string>();
                                                                      
                                                                      for(Program__c program : Database.Query(queryall)){
                                                                          
                                                                          HSschool schoolRec = new HSschool();
                                                                          if(isportal == true)
                                                                              schoolRec.SchoolId =  Label.CommunityDomainUrl+program.Id; //'https://tmcdev-maxway.cs74.force.com/s/detail/'+program.Id;
                                                                          else
                                                                              schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/program__c/'+program.Id+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/program__c/'+program.Id+'/view';
                                                                         
                                                                          setSchoolName.add( program.Campus__r.Account__r.Name );  
                                                                          //schoolRec.program = program.Name;
                                                                          schoolRec.program = program.Program_Type__c;
                                                                          schoolRec.Name = program.Campus__r.Account__r.Name ;
                                                                          schoolRec.Province = program.Campus__r.Province_State_New__c;
                                                                          schoolRec.City = program.Campus__r.Nearest_Big_City_New__c;
                                                                          schoolRec.Gender = program.Campus__r.School_Gender__c;
                                                                          schoolRec.flyerLink = program.Campus__r.Account__r.School_s_Flyer__c;
                                                                          system.debug('program.Est_Annual_Cost__c' +program.Est_Annual_Cost__c);
                                                                          system.debug('program.Id' +program.Id);
                                                                          string cur = string.valueOf(program.Est_Annual_Cost__c).removeEnd('.00');
                                                                          
                                                                           //added 18 june 2020 as if cur contains decimal value other than .00
                                                                                    if( cur.contains( '.' ) ){
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                        cur = cur.replace('.','#'); 
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                        system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                        cur = cur.split('#')[0]; 
                                                                                        // cur = cur.split('.')[0];
                                                                                    }
                                                                           
                                                                          string currf = formatCurr(integer.valueof(cur));
                                                                          system.debug( currf );
                                                                          if( currf == 'null' || String.isBlank( currf )){
                                                                              currf = cur;
                                                                          }
                                                                          system.debug( currf );
                                                                          schoolRec.Budget = program.CurrencyIsoCode +' ' +currf;
                                                                          system.debug( schoolRec.Budget );
                                                                          if(label.IBStudentHSFilter.contains(programtype)){
                                                                              if(program.Campus__r.Student_taking_IB__c != null)
                                                                                  schoolRec.IBStudent = string.valueOf(program.Campus__r.Student_taking_IB__c)+''+'%';
                                                                              schoolRec.IB = string.valueOf(program.Campus__r.IB_Average__c);
                                                                          }
                                                                          if(label.SATACTHSFilter.contains(country))
                                                                              schoolRec.SAT = string.valueOf(program.Campus__r.SAT_Average_Score__c);
                                                                          if(label.SATACTHSFilter.contains(country))
                                                                              schoolRec.ACT = string.valueOf(program.Campus__r.ACT_Average_Score__c);
                                                                          if(label.ATAR.contains(country))
                                                                              schoolRec.ATAR =string.valueOf(program.Campus__r.ATAR__c);
                                                                          if(label.ALevel.contains(programtype) || (label.All_Grades_Offered_United_Kingdom.contains(programtype) &&  label.All_Grades_Offered_United_Kingdom.contains(country)))
                                                                          {
                                                                              if(program.Campus__r.A_Level_Results_Numeric__c != null)
                                                                                  schoolRec.ALevel = string.valueOf(program.Campus__r.A_Level_Results_Numeric__c)+''+'%';}
                                                                          if(label.ALevel.contains(programtype) || (label.All_Grades_Offered_United_Kingdom.contains(programtype) &&  label.All_Grades_Offered_United_Kingdom.contains(country)))
                                                                              schoolRec.ALevelRange = program.Campus__r.A_Level_Results_Grade_Range__c;
                                                                          if(label.GCSE.contains(programtype)){
                                                                              if(program.Campus__r.GCSE_Results__c != null)
                                                                                  schoolRec.GCSE = string.valueOf(program.Campus__r.GCSE_Results__c)+''+'%';
                                                                          }
                                                                          if(label.GCSE.contains(programtype))
                                                                              schoolRec.GCSERange = program.Campus__r.GCSE_Results_Grade_Range__c;
                                                                          if(label.FraserinstituteHSFilter.contains(country))//&& label.FraserinstituteHSFilter.contains(province)  && string.isNotBlank(province)
                                                                              schoolRec.Fraserinstitute  = program.Campus__r.Fraser_Institute__c;
                                                                          mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);     
                                                                      }
                                                                  }
                                                                  else{
                                                                      
                                                                      string query = 'select Id,Name,CurrencyIsoCode,Campus__r.Student_taking_IB__c,Campus__r.ATAR__c,Campus__r.Account__r.Name,Campus__r.Account__r.School_s_Flyer__c,Campus__r.GCSE_Results_Grade_Range__c,Est_Annual_Cost__c ,Campus__r.GCSE_Results__c,Campus__r.A_Level_Results_Grade_Range__c,Campus__r.A_Level_Results_Numeric__c,Campus__r.School_Gender__c,Campus__r.ACT_Average_Score__c,Admission_Grade__c,Program_Type__c,Campus__r.Housing_Option__c, ';
                                                                      query += 'Campus__r.Province_State_New__c,Campus__r.Nearest_Big_City_New__c,Campus__r.Fraser_Institute__c,Campus__r.Account__r.Annual_Tuition_Fees__c ,Campus__r.IB_Average__c,Campus__r.SAT_Average_Score__c from Program__c where';
                                                                      query += ' Program_Type__c in :programtypes and Campus__r.Account__c in :schoolids and Est_Annual_Cost__c <=:budgut and CurrencyIsoCode = :currencycode';
                                                                      
                                                                      if(string.isNotBlank(province)){
                                                                          query += ' AND Campus__r.Province_State_New__c=:province';
                                                                      }
                                                                      if(string.isNotBlank(city)){
                                                                          query += ' AND Campus__r.Nearest_Big_City_New__c=:city';
                                                                      }
                                                                      
                                                                      if(string.isNotBlank(housing)){
                                                                          String housingHS = '';
                                                                          housingHS += '\'' + housing + '\'';
                                                                          query += ' AND Campus__r.Housing_Option__c includes ('+housingHS+')';    
                                                                      }
                                                                      //added on 12 may 2020
                                                                      if(string.isNotBlank(grade)){
                                                                          String admissiongrade = '';
                                                                          admissiongrade += '\'' + grade + '\'';
                                                                          query += ' AND Admission_Grade__c includes ('+admissiongrade+')';
                                                                      }
                                                                      
                                                                      system.debug('@@@@@query------> '+query);
                                                                      set<string> campusid = new set<string>();
                                                                      
                                                                      for(Program__c program : Database.Query(query)){
                                                                          
                                                                          if(string.isNotBlank(grade) && program.Admission_Grade__c.contains(grade)){
                                                                              HSschool schoolRec = new HSschool();
                                                                              if(isportal == true)
                                                                                  schoolRec.SchoolId =  Label.CommunityDomainUrl+program.Id;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+program.Id;
                                                                              else
                                                                                  schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/program__c/'+program.Id+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/program__c/'+program.Id+'/view';
                                                                              
                                                                              schoolRec.program = program.Program_Type__c;
                                                                              
                                                                              setSchoolName.add( program.Campus__r.Account__r.Name );  
                                                                              schoolRec.Name = program.Campus__r.Account__r.Name ;
                                                                              schoolRec.Province = program.Campus__r.Province_State_New__c;
                                                                              schoolRec.City = program.Campus__r.Nearest_Big_City_New__c;
                                                                              schoolRec.Gender = program.Campus__r.School_Gender__c;
                                                                              schoolRec.flyerLink = program.Campus__r.Account__r.School_s_Flyer__c;
                                                                              
                                                                              system.debug('program.Est_Annual_Cost__c1' +program.Est_Annual_Cost__c);
                                                                              system.debug('program.Id1 ' +program.Id);
                                                                              
                                                                              string cur = string.valueOf(program.Est_Annual_Cost__c).removeEnd('.00');
                                                                              
                                                                               //added 18 june 2020 as if cur contains decimal value other than .00
                                                                                    if( cur.contains( '.' ) ){
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                        cur = cur.replace('.','#'); 
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                        system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                        cur = cur.split('#')[0]; 
                                                                                        // cur = cur.split('.')[0];
                                                                                    }
                                                                              
                                                                              string currf = formatCurr(integer.valueof(cur));
                                                                              schoolRec.Budget = program.CurrencyIsoCode +' ' +currf;
                                                                              
                                                                              system.debug('label.IBStudentHSFilter'+label.IBStudentHSFilter);
                                                                              
                                                                              if(label.IBStudentHSFilter.contains(programtype)){
                                                                                  system.debug('label.IBStudentHSFilter'+label.IBStudentHSFilter);
                                                                                  if(program.Campus__r.Student_taking_IB__c != null)
                                                                                      schoolRec.IBStudent = string.valueOf(program.Campus__r.Student_taking_IB__c)+''+'%';
                                                                                  schoolRec.IB = string.valueOf(program.Campus__r.IB_Average__c);
                                                                              }
                                                                              
                                                                              if(label.SATACTHSFilter.contains(country))
                                                                                  schoolRec.SAT = string.valueOf(program.Campus__r.SAT_Average_Score__c);
                                                                              if(label.SATACTHSFilter.contains(country))
                                                                                  schoolRec.ACT = string.valueOf(program.Campus__r.ACT_Average_Score__c);
                                                                              if(label.ATAR.contains(country))
                                                                                  schoolRec.ATAR =string.valueOf(program.Campus__r.ATAR__c);
                                                                              
                                                                              if(label.ALevel.contains(programtype) || (label.All_Grades_Offered_United_Kingdom.contains(programtype) ||  label.All_Grades_Offered_United_Kingdom.contains(country)))// &&  label.All_Grades_Offered_United_Kingdom.contains(country)
                                                                              {
                                                                                  system.debug(programtype);
                                                                                  
                                                                                  if(program.Campus__r.A_Level_Results_Numeric__c != null)
                                                                                      schoolRec.ALevel = string.valueOf(program.Campus__r.A_Level_Results_Numeric__c)+''+'%';
                                                                              }
                                                                              
                                                                              if(label.ALevel.contains(programtype) || (label.All_Grades_Offered_United_Kingdom.contains(programtype) ||  label.All_Grades_Offered_United_Kingdom.contains(country)))// &&  label.All_Grades_Offered_United_Kingdom.contains(country)
                                                                                  schoolRec.ALevelRange = program.Campus__r.A_Level_Results_Grade_Range__c;
                                                                              
                                                                              if(label.GCSE.contains(programtype)){
                                                                                  
                                                                                  if(program.Campus__r.GCSE_Results__c != null)
                                                                                      
                                                                                      schoolRec.GCSE = string.valueOf(program.Campus__r.GCSE_Results__c)+''+'%';
                                                                              }
                                                                              
                                                                              if(label.GCSE.contains(programtype))
                                                                                  schoolRec.GCSERange = program.Campus__r.GCSE_Results_Grade_Range__c;
                                                                              
                                                                              if(label.FraserinstituteHSFilter.contains(country))//&& label.FraserinstituteHSFilter.contains(province)  && string.isNotBlank(province)
                                                                                  schoolRec.Fraserinstitute  = program.Campus__r.Fraser_Institute__c;
                                                                              
                                                                              mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);   
                                                                          }
                                                                          else{
                                                                              campusid.add(program.Campus__c);  
                                                                          }
                                                                          
                                                                      }
                                                                      if(campusid.size()>0){
                                                                          system.debug(campusid);
                                                                          string program = 'All Grades Offered';
                                                                          string query1 = 'select Id,Name,CurrencyIsoCode,Campus__r.Student_taking_IB__c,Campus__r.ATAR__c,Campus__r.Account__r.Name,Campus__r.Account__r.School_s_Flyer__c,Campus__r.GCSE_Results_Grade_Range__c,Est_Annual_Cost__c ,Campus__r.GCSE_Results__c,Campus__r.A_Level_Results_Grade_Range__c,Campus__r.A_Level_Results_Numeric__c,Campus__r.School_Gender__c,Campus__r.ACT_Average_Score__c,Admission_Grade__c,Program_Type__c,Campus__r.Housing_Option__c, ';
                                                                          query1 += 'Campus__r.Province_State_New__c,Campus__r.Nearest_Big_City_New__c,Campus__r.Fraser_Institute__c,Campus__r.Account__r.Annual_Tuition_Fees__c ,Campus__r.IB_Average__c,Campus__r.SAT_Average_Score__c from Program__c where';
                                                                          query1 += ' Program_Type__c = :program and Campus__c in :campusid and Est_Annual_Cost__c <=:budgut and CurrencyIsoCode = :currencycode';
                                                                          
                                                                          if(string.isNotBlank(province)){
                                                                              query1 += ' AND Campus__r.Province_State_New__c=:province';
                                                                          }
                                                                          if(string.isNotBlank(city)){
                                                                              query1 += ' AND Campus__r.Nearest_Big_City_New__c=:city';
                                                                          }
                                                                          
                                                                          if(string.isNotBlank(housing)){
                                                                              String housingHS = '';
                                                                              housingHS += '\'' + housing + '\'';
                                                                              query1 += ' AND Campus__r.Housing_Option__c includes ('+housingHS+')';    
                                                                          }
                                                                           //added on 12 may 2020
                                                                     	 if(string.isNotBlank(grade)){
                                                                          String admissiongrade = '';
                                                                          admissiongrade += '\'' + grade + '\'';
                                                                          query1 += ' AND Admission_Grade__c includes ('+admissiongrade+')';
                                                                      }
                                                                          /*  if(string.isNotBlank(grade)){
String admissiongrade = '';
admissiongrade += '\'' + grade + '\'';
query += ' AND Admission_Grade__c includes ('+admissiongrade+')';
}*/
                                                                          
                                                                          for(program__c program1 : Database.Query(query1)){
                                                                              if(string.isNotBlank(grade) && program1.Admission_Grade__c.contains(grade)){
                                                                                  HSschool schoolRec = new HSschool();
                                                                                  if(isportal == true)
                                                                                      schoolRec.SchoolId =  Label.CommunityDomainUrl+program1.Id;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+program1.Id;
                                                                                  else
                                                                                      schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/program__c/'+program1.Id+'/view';
                                                                                  
                                                                                  schoolRec.program = program1.Program_Type__c;
                                                                                  setSchoolName.add( program1.Campus__r.Account__r.Name );  
                                                                                  schoolRec.Name = program1.Campus__r.Account__r.Name ;
                                                                                  schoolRec.Province = program1.Campus__r.Province_State_New__c;
                                                                                  schoolRec.City = program1.Campus__r.Nearest_Big_City_New__c;
                                                                                  schoolRec.Gender = program1.Campus__r.School_Gender__c;
                                                                                  string cur = string.valueOf(program1.Est_Annual_Cost__c).removeEnd('.00');
                                                                                  
                                                                                   //added 18 june 2020 as if cur contains decimal value other than .00
                                                                                    if( cur.contains( '.' ) ){
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                        cur = cur.replace('.','#'); 
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                        system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                        cur = cur.split('#')[0]; 
                                                                                        // cur = cur.split('.')[0];
                                                                                    }
                                                                                  
                                                                                  string currf = formatCurr(integer.valueof(cur));
                                                                                  schoolRec.Budget = program1.CurrencyIsoCode +' ' +currf;
                                                                                  schoolRec.flyerLink = program1.Campus__r.Account__r.School_s_Flyer__c;
                                                                                  system.debug('label.IBStudentHSFilter'+label.IBStudentHSFilter);
                                                                                  
                                                                                  if(label.IBStudentHSFilter.contains(programtype)){
                                                                                      system.debug('label.IBStudentHSFilter'+label.IBStudentHSFilter);
                                                                                      if(program1.Campus__r.Student_taking_IB__c != null)
                                                                                          schoolRec.IBStudent = string.valueOf(program1.Campus__r.Student_taking_IB__c)+''+'%';
                                                                                      schoolRec.IB = string.valueOf(program1.Campus__r.IB_Average__c);
                                                                                  }
                                                                                  
                                                                                  if(label.SATACTHSFilter.contains(country))
                                                                                      schoolRec.SAT = string.valueOf(program1.Campus__r.SAT_Average_Score__c);
                                                                                  
                                                                                  if(label.SATACTHSFilter.contains(country))
                                                                                      schoolRec.ACT = string.valueOf(program1.Campus__r.ACT_Average_Score__c);
                                                                                  
                                                                                  if(label.ATAR.contains(country))
                                                                                      schoolRec.ATAR =string.valueOf(program1.Campus__r.ATAR__c);
                                                                                  
                                                                                  if(label.ALevel.contains(programtype) || (label.All_Grades_Offered_United_Kingdom.contains(programtype) ||  label.All_Grades_Offered_United_Kingdom.contains(country)))
                                                                                  {
                                                                                      system.debug(programtype);
                                                                                      
                                                                                      if(program1.Campus__r.A_Level_Results_Numeric__c != null)
                                                                                          schoolRec.ALevel = string.valueOf(program1.Campus__r.A_Level_Results_Numeric__c)+''+'%';
                                                                                  }
                                                                                  
                                                                                  if(label.ALevel.contains(programtype)  || (label.All_Grades_Offered_United_Kingdom.contains(programtype) ||  label.All_Grades_Offered_United_Kingdom.contains(country)))
                                                                                      schoolRec.ALevelRange = program1.Campus__r.A_Level_Results_Grade_Range__c;
                                                                                  
                                                                                  if(label.GCSE.contains(programtype)){
                                                                                      if(program1.Campus__r.GCSE_Results__c != null)
                                                                                          schoolRec.GCSE = string.valueOf(program1.Campus__r.GCSE_Results__c)+''+'%';
                                                                                  }
                                                                                  
                                                                                  if(label.GCSE.contains(programtype))
                                                                                      schoolRec.GCSERange = program1.Campus__r.GCSE_Results_Grade_Range__c;
                                                                                  
                                                                                  if(label.FraserinstituteHSFilter.contains(country) )//&& label.FraserinstituteHSFilter.contains(province)  && string.isNotBlank(province)
                                                                                      schoolRec.Fraserinstitute  = program1.Campus__r.Fraser_Institute__c;
                                                                                  mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);   
                                                                              }
                                                                          }   
                                                                      }
                                                                  }
                                                                  for(String schRec : mapOfSchoolModal.keyset()){
                                                                      schoolList.add(mapOfSchoolModal.get(schRec));
                                                                  }
                                                                  if( schoolList.size() > 0 ) {
                                                                
                                                                      schoolList[0].totalSchoolANdProg = setSchoolName.size() + ' Schools '+ schoolList.size() + ' Programs';
                                                                      
                                                                      for( Integer index = 0; index < schoolList.size(); index++ ){
                                                                          
                                                                          schoolList[ index ].sNo = String.valueOf( index + 1 );
                                                                      }
                                                                  }
																
                                                                  return schoolList; 
                                                              }
                                                              return null;
                                                          }
    
    //___________________________________________________________  Post Secondary Data Retrieve  __________________________________________________________
    @AuraEnabled
    public static list<PSschool> returnSearchedcollegeSchool( string nationality, string country , string programtype , string minbudget,
                                                             string maxbudget, string programobjective , string province , string city,
                                                             string Major,string currencycode,string highschoolgrad,string toefl,string ielts,string recordtype){
                                                                 
                                                                 system.debug('nationality-->'+nationality); system.debug('country-->'+country); system.debug('programtype-->'+programtype); 
                                                                 system.debug('minbudget-->'+minbudget); system.debug('maxbudget-->'+maxbudget); system.debug('programobjective-->'+programobjective); system.debug('province-->'+province); 
                                                                 system.debug('city-->'+city); system.debug('Major-->'+Major);
                                                                 system.debug('highschoolgrad-->'+highschoolgrad); system.debug('toefl-->'+toefl); system.debug('ielts-->'+ielts); system.debug('currencycode-->'+currencycode); 
                                                                 
                                                                 //this is to show the total no of school found
                                                                 set< String > setSchoolName = new set< String >();
                                                                 /*   list<string> addmissionagelist = new list<string>();map<string,list<string>> addmissionmap = new map<string,list<string>>();Schema.DescribeFieldResult result5 = Program__c.Admission_Age__c.getDescribe();List<Schema.PicklistEntry> ple5 = result5.getPicklistValues();for( Schema.PicklistEntry f : ple5 ){addmissionagelist.add(f.getValue());}for(integer i =0 ; i<addmissionagelist.size();i++){list<string> agelist = new list<string>();for(integer k = 0 ; k <= i ; k++){agelist.add(addmissionagelist[k]);}addmissionmap.put(addmissionagelist[i],agelist);}system.debug('mapp-->'+addmissionmap);*/
                                                                 /* List<CurrencyType> currencyList = [SELECT Id, IsoCode, ConversionRate FROM CurrencyType]; Map<String,Decimal> IsoCode_cRate = new Map<String,Decimal>(); for(CurrencyType ct: currencyList){ IsoCode_cRate.put(ct.IsoCode,ct.ConversionRate); } if(IsoCode_cRate.containskey(currencycode)){ maxbudgut = maxbudgut*(1 / IsoCode_cRate.get(currencycode)); minbudgut = minbudgut*(1 / IsoCode_cRate.get(currencycode)); } */
                                                                 //  system.debug('IsoCode_cRate.get(currencycode)-->'+IsoCode_cRate.get(currencycode));
                                                                 
                                                                 map<String,PSschool> mapOfSchoolModal = new map<String,PSschool>();
                                                                 list<PSschool> schoolList = new list<PSschool>();
                                                                 set<string> schoolids = new set<string>();
                                                                 
                                                                 decimal maxbudgut = decimal.valueOf(maxbudget);
                                                                 decimal minbudgut = decimal.valueOf(minbudget);
                                                                 
                                                                 system.debug('maxbudgut-->'+maxbudgut);
                                                                 system.debug('minbudgut-->'+minbudgut); 
                                                                 
                                                                 //minbudgut = 0;
                                                                 
                                                                 String queryString;
                                                                 
                                                                 if( String.isNotBlank( recordtype )){
                                                                     
                                                                     Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
                                                                     
                                                                      queryString = 'select School__c from Commission_Table__c where Nationality__c=:nationality and School__r.RecordTypeId =:recTypeId  and School__r.School_s_Country__c =:country AND Amount__c > 0';
                                                                     
                                                                 }else{
                                                                    
                                                                      queryString = 'select School__c from Commission_Table__c where Nationality__c=:nationality and School__r.School_s_Country__c =:country AND Amount__c > 0';
                                                                 }
                                                                 
                                                                 for(Commission_Table__c com : Database.query( queryString )){
                                                                     schoolids.add(com.School__c);
                                                                 }
                                                                 
                                                                 Id userid = UserInfo.getUserId();
                                                                 boolean isportal = false;
                                                                 
                                                                 user usr = [Select isportalenabled,contact.accountid from user where id = :userid ];  
                                                                 
                                                                 if(usr.IsPortalEnabled == true){
                                                                     
                                                                     isportal =true;
                                                                     
                                                                     for(opt_out_School__c oppoutlist : [select id,School__c from opt_out_School__c where agent__c = :usr.contact.accountid]) {
                                                                         
                                                                         if(schoolids.contains(oppoutlist.School__c)){
                                                                             
                                                                             schoolids.remove(oppoutlist.School__c);   
                                                                         }  
                                                                     }
                                                                 }//end of isPortal
                                                                 
                                                                 //7 may 2020( Changes as now ielts and toefl creteria are removed )
                                                                 if(schoolids.size()>0){
                                                                     
                                                                     String majorlike ='\'%' + Major  + '%\''; 
                                                                     string query = 'select Id,Name,Program__r.Month_s_of_Intake__c, Program__r.ielts_min_formula__c,Program__r.Program_Duration__c,Program__r.Program_Duration_Unit__c,Program__r.Campus__r.Account__r.Name,Program__r.Est_Annual_Cost__c ,Program__r.Program_Type__c,Program__r.Name,Program__r.High_School_Graduation_Needed__c,';
                                                                     query += 'Program__r.IELTS_Min__c,Program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c,Program__r.TOEFL_Min__c,Program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c,Program__r.CurrencyIsoCode,Program__r.Program_Objective__c,Program__r.Admission_Age__c,Program__r.Campus__r.Province_State_New__c,Program__r.Campus__r.Nearest_Big_City_New__c,Program__r.Campus__r.Account__r.RecordTypeId';
                                                                     
                                                                     //added on 7 may added to fields
                                                                     query += ',program__r.Campus__r.Name,Program__r.Campus__r.Account__r.School_s_Flyer__c,Program__r.Campus__r.World_Ranking__c,Program__r.IELTS_accepted_for_upgrade_ESL_EAP__c,Program__r.TOEFL_accepted_for_update_ESL_EAP__c from Major__c where';
                                                                     
                                                                     query += ' Program__r.Campus__r.Account__c in :schoolids and Program__r.Est_Annual_Cost__c <=:maxbudgut and Program__r.Est_Annual_Cost__c >=:minbudgut and Program__r.CurrencyIsoCode = :currencycode';
                                                                     query += ' and Name like'+majorlike;
                                                                     
                                                                     /*      if(addmissionmap.containskey(addmissionage)){list<string> agelist = addmissionmap.get(addmissionage);query += ' and Program__r.Admission_Age__c in :agelist';}*/
                                                                     
                                                                     if(string.isNotBlank(province)){
                                                                         
                                                                         query += ' AND Program__r.Campus__r.Province_State_New__c=:province';
                                                                     }
                                                                     
                                                                     if(string.isNotBlank(programobjective)){
                                                                         
                                                                         query += ' AND Program__r.Program_Objective__c = :programobjective';  
                                                                     }
                                                                     
                                                                     if(string.isNotBlank(programtype)){
                                                                         
                                                                         query += ' AND  Program__r.Program_Type__c =:programtype';  
                                                                     }
                                                                     
                                                                     if(string.isNotBlank(city)){
                                                                         
                                                                         query += ' AND Program__r.Campus__r.Nearest_Big_City_New__c=:city';
                                                                     }
                                                                     /* 7 may 2020 as now this will be filter as per TOEFL_accepted_for_update_ESL_EAP__c and IELTS_accepted_for_upgrade_ESL_EAP__c
if(string.isNotBlank(toefl)){

system.debug(toefl);

decimal toef = decimal.valueOf(toefl);

query += ' AND Program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c <= :toef';
}

if(string.isNotBlank(ielts)){

system.debug(ielts);

decimal ielt = decimal.valueOf(ielts);   

query += ' AND Program__r.ielts_min_formula__c  <= :ielt';    
}*/
                                                                     
                                                                     /*   Id userid = UserInfo.getUserId();boolean isportal = false;user usr = [Select isportalenabled from user where id = :userid ];  if(usr.IsPortalEnabled == true) isportal =true;*/
                                                                     
                                                                     system.debug('@@@@@query------> '+query);
                                                                     
                                                                     for(Major__c Majr : Database.Query(query)){
                                                                         
                                                                         system.debug('@@@@@Major------> '+Majr);
                                                                         system.debug('@@@@@@@Major ---> ' + Majr.Program__r.Campus__r.Account__r.Name);
                                                                         system.debug(Majr.program__r.ielts_min_formula__c);
                                                                         system.debug(Majr.program__r.TOEFL_Min__c);
                                                                         
                                                                         PSschool schoolRec = new PSschool();
                                                                         
                                                                         //added on 7 may 2020 ( new ielts and toefl creteria )
                                                                         if(string.isNotBlank(toefl)){
                                                                             
                                                                             decimal toef = decimal.valueOf(toefl);
                                                                             
                                                                             system.debug( toefl );
                                                                             system.debug( Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c );
                                                                             system.debug( Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c );
                                                                             system.debug( Majr.program__r.TOEFL_Min__c );
                                                                             
                                                                             
                                                                             if( Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c == 'Yes' && Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c > toef ) continue;
                                                                             
                                                                             if( Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c == 'No' && ( Majr.program__r.TOEFL_Min__c == 0 || Majr.program__r.TOEFL_Min__c > toef ) ) continue;
                                                                             
                                                                         }
                                                                         
                                                                         if(string.isNotBlank(ielts)){
                                                                             
                                                                             decimal ielt = decimal.valueOf(ielts);   
                                                                             
                                                                             if( Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c == 'Yes' && String.isNotBlank( Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c )
                                                                                && decimal.valueOf( Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c ) > ielt) {
                                                                                    system.debug('skipped');
                                                                                    continue;} //skip the record 
                                                                             
                                                                             if( Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c == 'No' && String.isNotBlank( Majr.program__r.IELTS_Min__c )
                                                                                && ( decimal.valueOf( Majr.program__r.IELTS_Min__c ) == 0 || decimal.valueOf( Majr.program__r.IELTS_Min__c ) > ielt)) continue;
                                                                         }
                                                                         //end 7may 2020
                                                                         
                                                                         if(highschoolgrad=='No'){
                                                                             
                                                                             //added moree filter other than No 7 may 2020
                                                                             if( Majr.Program__r.High_School_Graduation_Needed__c =='No' || Majr.Program__r.High_School_Graduation_Needed__c =='No if 18 or above' || Majr.Program__r.High_School_Graduation_Needed__c =='No if 19 or above' ||
                                                                                
                                                                                Majr.Program__r.High_School_Graduation_Needed__c =='No if 21 or above' ){
                                                                                    
                                                                                    if(isportal == true){
                                                                                        
                                                                                        schoolRec.majorLink =  Label.CommunityDomainUrl+Majr.program__c+'/Majors__r';//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.Id;
                                                                                        schoolRec.SchoolId =  Label.CommunityDomainUrl+Majr.program__c;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.program__c;
                                                                                    }
                                                                                    
                                                                                    else{
                                                                                        
                                                                                        schoolRec.majorLink =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.program__c+'/related/Majors__r/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Major__c/'+Majr.Id+'/view';
                                                                                        schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.program__c+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Major__c/'+Majr.program__c+'/view';
                                                                                    }
                                                                                    setSchoolName.add( Majr.program__r.Campus__r.Account__r.Name );    
                                                                                    schoolRec.Name = Majr.program__r.Campus__r.Name ;
                                                                                    schoolRec.Province = Majr.program__r.Campus__r.Province_State_New__c;
                                                                                    schoolRec.City = Majr.program__r.Campus__r.Nearest_Big_City_New__c;
                                                                                   // schoolRec.Program = Majr.program__r.Name;
                                                                                    schoolRec.Program = Majr.Program__r.Program_Type__c; 
                                                                                    schoolRec.Major = Majr.Name; 
                                                                                    schoolRec.worldRank = Majr.Program__r.Campus__r.World_Ranking__c;
                                                                                    string cur = string.valueOf(Majr.program__r.Est_Annual_Cost__c).removeEnd('.00');
                                                                                    
                                                                                    //added 18 june 2020 as if cur contains decimal value other than .00
                                                                                    if( cur.contains( '.' ) ){
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                        cur = cur.replace('.','#'); 
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                        system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                        cur = cur.split('#')[0]; 
                                                                                        // cur = cur.split('.')[0];
                                                                                    }
                                                                                    
                                                                                    string currf = formatCurr(integer.valueof(cur));
                                                                                    schoolRec.flyerLink = Majr.Program__r.Campus__r.Account__r.School_s_Flyer__c;
                                                                                    schoolRec.AnnualFees = Majr.program__r.CurrencyIsoCode +' ' +currf;
                                                                                    schoolRec.MonthsofIntake = Majr.program__r.Month_s_of_Intake__c;
                                                                                    schoolRec.ProgramDuration = Majr.program__r.Program_Duration__c;
                                                                                    schoolRec.DurationUnit = Majr.program__r.Program_Duration_Unit__c;
                                                                                    schoolRec.LowestIELTSforEnglishUpgrade = Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c;
                                                                                    schoolRec.IELTSMin = Majr.program__r.IELTS_Min__c;
                                                                                    schoolRec.LowestTOEFLforEnglishUpgrade =  string.valueof(Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c);
                                                                                    schoolRec.TOEFLMin  =  string.valueof(Majr.program__r.TOEFL_Min__c);
                                                                                    schoolRec.toeflUpgrade = string.valueof(Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c);
                                                                                    schoolRec.ieltsUpgrade = string.valueof(Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c);
                                                                                        
                                                                                    mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);    
                                                                                }//end of High_School_Graduation_Needed__c ==No
                                                                         }//end of highschoolgrad=='No'
                                                                         
                                                                         else if( highschoolgrad=='Yes' && Majr.Program__r.High_School_Graduation_Needed__c =='Yes'){ //highschoolgrad=='yes'
                                                                             
                                                                             if(isportal == true){
                                                                                 
                                                                                 schoolRec.majorLink =  Label.CommunityDomainUrl+Majr.Id;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.Id;
                                                                                 schoolRec.SchoolId =  Label.CommunityDomainUrl+Majr.program__c;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.program__c;
                                                                             }
                                                                                 
                                                                             else{
                                                                                 
                                                                                 schoolRec.majorLink =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.Id+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Major__c/'+Majr.Id+'/view';
                                                                                 schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.program__c+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Major__c/'+Majr.program__c+'/view';
                                                                             }
                                                                             setSchoolName.add( Majr.program__r.Campus__r.Account__r.Name );
                                                                             schoolRec.Name = Majr.program__r.Campus__r.Name ;//Majr.program__r.Campus__r.Account__r.Name
                                                                             schoolRec.Province = Majr.program__r.Campus__r.Province_State_New__c;
                                                                             schoolRec.City = Majr.program__r.Campus__r.Nearest_Big_City_New__c;
                                                                             //schoolRec.Program = Majr.program__r.Name;
                                                                             schoolRec.Program = Majr.Program__r.Program_Type__c; 
                                                                             schoolRec.Major = Majr.Name; 
                                                                             schoolRec.worldRank = Majr.Program__r.Campus__r.World_Ranking__c;
                                                                             string cur = string.valueOf(Majr.program__r.Est_Annual_Cost__c).removeEnd('.00');
                                                                             
                                                                             //added 18 june 2020 as if cur contains decimal value other than .00
                                                                             if( cur.contains( '.' ) ){
                                                                                 system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                 cur = cur.replace('.','#'); 
                                                                                 system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                  cur = cur.split('#')[0]; 
                                                                                // cur = cur.split('.')[0];
                                                                             }
                                                                             string currf = formatCurr(integer.valueof(cur));
                                                                             schoolRec.flyerLink = Majr.Program__r.Campus__r.Account__r.School_s_Flyer__c;
                                                                             schoolRec.AnnualFees = Majr.program__r.CurrencyIsoCode +' ' +currf;
                                                                             schoolRec.MonthsofIntake = Majr.program__r.Month_s_of_Intake__c;
                                                                             schoolRec.ProgramDuration = Majr.program__r.Program_Duration__c;
                                                                             schoolRec.DurationUnit = Majr.program__r.Program_Duration_Unit__c;
                                                                             schoolRec.LowestIELTSforEnglishUpgrade = Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c;
                                                                             schoolRec.IELTSMin = Majr.program__r.IELTS_Min__c;
                                                                             schoolRec.LowestTOEFLforEnglishUpgrade =  string.valueof(Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c);
                                                                             schoolRec.TOEFLMin  =  string.valueof(Majr.program__r.TOEFL_Min__c);
                                                                             schoolRec.toeflUpgrade = string.valueof(Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c);
                                                                                    schoolRec.ieltsUpgrade = string.valueof(Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c);
                                                                                    
                                                                             mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);   
                                                                         }//end of highschoolgrad=='yes'
                                                                         
                                                                     }//end of Major query
                                                                     
                                                                     for(String schRec : mapOfSchoolModal.keyset()){
                                                                         
                                                                         schoolList.add(mapOfSchoolModal.get(schRec));
                                                                     }
                                                                     
                                                                    if( schoolList.size() > 0 ) {
                                                                
                                                                      schoolList[0].totalSchoolANdProg = setSchoolName.size() + ' Schools '+ schoolList.size() + ' Programs';
                                                                      
                                                                      for( Integer index = 0; index < schoolList.size(); index++ ){
                                                                          
                                                                          schoolList[ index ].sNo = String.valueOf( index + 1 );
                                                                      }
                                                                  }
                                                                     
                                                                     return schoolList; 
                                                                 }
                                                                 return null;
                                                             }
    
    //___________________________________________________________  Post Graduate Data Retrieve  __________________________________________________________
    @AuraEnabled
    public static list<PGschool> returnSearcheduniversitySchool( string nationality, string country , string programtype , string minbudget,
                                                                string maxbudget, string programobjective , string province , string city,
                                                                string Major,string currencycode,string Bachloreneeded,string toefl,string ielts,string recordtype){
                                                                    
                                                                    //this is to show the total no of school found
                                                                    set< String > setSchoolName = new set< String >();
                                                                    
                                                                    system.debug('nationality-->'+nationality); 
                                                                    system.debug('country-->'+country); 
                                                                    system.debug('programtype-->'+programtype); 
                                                                    system.debug('minbudget-->'+minbudget); 
                                                                    system.debug('maxbudget-->'+maxbudget); 
                                                                    system.debug('programobjective-->'+programobjective); 
                                                                    system.debug('province-->'+province); 
                                                                    system.debug('city-->'+city); 
                                                                    system.debug('Major-->'+Major);
                                                                    system.debug('Bachloreneeded-->'+Bachloreneeded); 
                                                                    system.debug('toefl-->'+toefl);
                                                                    system.debug('ielts-->'+ielts); 
                                                                    
                                                                    map<String,PGschool> mapOfSchoolModal = new map<String,PGschool>();
                                                                    list<PGschool> schoolList = new list<PGschool>();
                                                                    set<string> schoolids = new set<string>();
                                                                    
                                                                    decimal maxbudgut = decimal.valueOf(maxbudget);
                                                                    decimal minbudgut = decimal.valueOf(minbudget);
                                                                    //minbudgut = 0;
                                                                    /* List<CurrencyType> currencyList = [SELECT Id, IsoCode, ConversionRate FROM CurrencyType]; Map<String,Decimal> IsoCode_cRate = new Map<String,Decimal>(); for(CurrencyType ct: currencyList){ IsoCode_cRate.put(ct.IsoCode,ct.ConversionRate); } if(IsoCode_cRate.containskey(currencycode)){ maxbudgut = maxbudgut*(1 / IsoCode_cRate.get(currencycode)); minbudgut = minbudgut*(1 / IsoCode_cRate.get(currencycode)); } system.debug('maxbudgut-->'+maxbudgut); system.debug('minbudgut-->'+minbudgut); system.debug('IsoCode_cRate.get(currencycode)-->'+IsoCode_cRate.get(currencycode));*/ 
                                                                    String queryString; 
                                                                    if( String.isNotBlank( recordtype )){
                                                                        
                                                                        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
                                                                        
                                                                        queryString = 'select School__c from Commission_Table__c where Nationality__c=:nationality and School__r.RecordTypeId =:recTypeId  and School__r.School_s_Country__c =:country AND Amount__c > 0';
                                                                        
                                                                    }else{
                                                                        
                                                                        queryString = 'select School__c from Commission_Table__c where Nationality__c=:nationality and School__r.School_s_Country__c =:country AND Amount__c > 0';
                                                                    }
                                                                 
                                                                 for(Commission_Table__c com : Database.query( queryString )){
                                                                     schoolids.add(com.School__c);
                                                                 }
                                                                    Id userid = UserInfo.getUserId();
                                                                    boolean isportal = false;
                                                                    
                                                                    user usr = [Select isportalenabled,contact.accountid from user where id = :userid ];  
                                                                    
                                                                    if(usr.IsPortalEnabled == true){
                                                                        
                                                                        isportal =true;
                                                                        
                                                                        for(opt_out_School__c oppoutlist : [select id,School__c from opt_out_School__c where agent__c = :usr.contact.accountid]) {
                                                                            
                                                                            if(schoolids.contains(oppoutlist.School__c)){
                                                                                
                                                                                schoolids.remove(oppoutlist.School__c);   
                                                                            }  
                                                                        }
                                                                    }
                                                                    
                                                                    system.debug('schoolids-->'+schoolids);
                                                                    
                                                                    if(schoolids.size()>0){
                                                                        
                                                                        String majorlike ='\'%' + Major  + '%\'';
                                                                        string query = 'select program__r.Campus__r.Account__r.recordtypeid,Id,Program__r.Bachelor_Needed__c,Name,Program__r.ielts_min_formula__c,Program__r.Month_s_of_Intake__c,Program__r.Program_Duration__c,Program__r.Program_Duration_Unit__c,Program__r.Campus__r.Account__r.Name,Program__r.Est_Annual_Cost__c ,Program__r.Program_Type__c,Program__r.Name,Program__r.High_School_Graduation_Needed__c,';
                                                                        query += 'Program__r.IELTS_Min__c,Program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c,Program__r.TOEFL_Min__c,Program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c, Program__r.Program_Objective__c,Program__r.Admission_Age__c,Program__r.Campus__r.Province_State_New__c,Program__r.Campus__r.Nearest_Big_City_New__c,Program__r.CurrencyIsoCode';
                                                                        
                                                                        //added on 7 may added to fields
                                                                     	query += ',program__r.Campus__r.Name,Program__r.Campus__r.Account__r.School_s_Flyer__c,Program__r.Campus__r.World_Ranking__c,Program__r.IELTS_accepted_for_upgrade_ESL_EAP__c,Program__r.TOEFL_accepted_for_update_ESL_EAP__c from Major__c where';
                                                                     
                                                                        
                                                                        query += ' Program__r.Campus__r.Account__c in :schoolids and Program__r.Est_Annual_Cost__c <=:maxbudgut and Program__r.Est_Annual_Cost__c >=:minbudgut and Program__r.CurrencyIsoCode = :currencycode';
                                                                        query += ' and Name like'+majorlike;
                                                                        
                                                                        if(string.isNotBlank(province)){
                                                                            
                                                                            query += ' AND Program__r.Campus__r.Province_State_New__c=:province';
                                                                        }
                                                                        /*   if(string.isNotBlank(Bachloreneeded)){query += ' and Program__r.Bachelor_Needed__c =:Bachloreneeded';}*/
                                                                        
                                                                        if(string.isNotBlank(city)){
                                                                            
                                                                            query += ' AND Program__r.Campus__r.Nearest_Big_City_New__c=:city';
                                                                        }
                                                                        
                                                                        if(string.isNotBlank(programobjective)){
                                                                            
                                                                            query += ' AND Program__r.Program_Objective__c = :programobjective';  
                                                                        }
                                                                        
                                                                        if(string.isNotBlank(programtype)){
                                                                            
                                                                            query += ' AND  Program__r.Program_Type__c =:programtype';  
                                                                        }
                                                                        /*
if(string.isNotBlank(toefl)){

system.debug(toefl);
decimal toef = decimal.valueOf(toefl);
query += ' AND Program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c <= :toef';
}

if(string.isNotBlank(ielts)){

system.debug(ielts);
decimal ielt = decimal.valueOf(ielts);   
query += ' AND Program__r.ielts_min_formula__c  <= :ielt';    
}*/
                                                                        
                                                                        /*    Id userid = UserInfo.getUserId();boolean isportal = false;user usr = [Select isportalenabled from user where id = :userid ];  if(usr.IsPortalEnabled == true) isportal =true;  */
                                                                        
                                                                        system.debug('@@@@@query------> '+query);
                                                                        list<string> bchneeded = new list<string>();
                                                                        
                                                                        bchneeded.add('No');
                                                                        bchneeded.add('No if have experience');
                                                                        
                                                                        for(Major__c Majr : Database.Query(query)){
                                                                            
                                                                            /* 7 may 2020 as now this will be filter as per TOEFL_accepted_for_update_ESL_EAP__c and IELTS_accepted_for_upgrade_ESL_EAP__c
if(string.isNotBlank(toefl)){

system.debug(toefl);

decimal toef = decimal.valueOf(toefl);

query += ' AND Program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c <= :toef';
}

if(string.isNotBlank(ielts)){

system.debug(ielts);

decimal ielt = decimal.valueOf(ielts);   

query += ' AND Program__r.ielts_min_formula__c  <= :ielt';    
}*/
                                                                            
                                                                            
                                                                            //added on 7 may 2020 ( new ielts and toefl creteria )
                                                                            if(string.isNotBlank(toefl)){
                                                                                
                                                                                decimal toef = decimal.valueOf(toefl);
                                                                                
                                                                                system.debug( toefl );
                                                                                system.debug( Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c );
                                                                                system.debug( Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c );
                                                                                system.debug( Majr.program__r.TOEFL_Min__c );
                                                                                
                                                                                
                                                                                if( Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c == 'Yes' && Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c > toef ) continue;
                                                                                
                                                                                if( Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c == 'No' && ( Majr.program__r.TOEFL_Min__c == 0 || Majr.program__r.TOEFL_Min__c > toef ) ) continue;
                                                                                
                                                                            }
                                                                            
                                                                            if(string.isNotBlank(ielts)){
                                                                                
                                                                                decimal ielt = decimal.valueOf(ielts);   
                                                                                
                                                                                if( Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c == 'Yes' && String.isNotBlank( Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c )
                                                                                   && decimal.valueOf( Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c ) > ielt) {
                                                                                       system.debug('skipped');
                                                                                       continue;} //skip the record 
                                                                                
                                                                                if( Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c == 'No' && String.isNotBlank( Majr.program__r.IELTS_Min__c )
                                                                                   && ( decimal.valueOf( Majr.program__r.IELTS_Min__c ) == 0 || decimal.valueOf( Majr.program__r.IELTS_Min__c ) > ielt)) continue;
                                                                            }
                                                                            //end 7may 2020
                                                                            
                                                                            PGschool schoolRec = new PGschool();
                                                                            
                                                                            if(Bachloreneeded=='No'){
                                                                                
                                                                                if(bchneeded.contains(Majr.Program__r.Bachelor_Needed__c)){
                                                                                    
                                                                                    if(isportal == true){
                                                                                        
                                                                                        schoolRec.SchoolId =  Label.CommunityDomainUrl+Majr.program__c;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.program__c;
                                                                                        schoolRec.majorLink = Label.CommunityDomainUrl+Majr.Id;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.Id;
                                                                                    }
                                                                                        
                                                                                        
                                                                                    else{
                                                                                        schoolRec.majorLink =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.Id+'/view';
                                                                                        schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.program__c+'/view';
                                                                                    }
                                                                                        
                                                                                    setSchoolName.add( Majr.program__r.Campus__r.Account__r.Name );
                                                                                    
                                                                                    schoolRec.Name = Majr.program__r.Campus__r.Name ;//Majr.program__r.Campus__r.Account__r.Name
                                                                                    schoolRec.Province = Majr.program__r.Campus__r.Province_State_New__c;
                                                                                    schoolRec.City = Majr.program__r.Campus__r.Nearest_Big_City_New__c;
                                                                                    //schoolRec.Program = Majr.program__r.Name;
                                                                                    schoolRec.Program = Majr.Program__r.Program_Type__c; 
                                                                                    schoolRec.Major = Majr.Name; 
                                                                                    schoolRec.worldRank = Majr.Program__r.Campus__r.World_Ranking__c;
                                                                                    string cur = string.valueOf(Majr.program__r.Est_Annual_Cost__c).removeEnd('.00');
                                                                                    
                                                                                    //added 18 june 2020 as if cur contains decimal value other than .00
                                                                                    if( cur.contains( '.' ) ){
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                        cur = cur.replace('.','#'); 
                                                                                        system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                        system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                        cur = cur.split('#')[0]; 
                                                                                        // cur = cur.split('.')[0];
                                                                                    }
                                                                                    
                                                                                    string currf = formatCurr(integer.valueof(cur));
                                                                                    schoolRec.flyerLink = Majr.Program__r.Campus__r.Account__r.School_s_Flyer__c;
                                                                                    schoolRec.AnnualFees = Majr.program__r.CurrencyIsoCode +' ' +currf;
                                                                                    schoolRec.MonthsofIntake = Majr.program__r.Month_s_of_Intake__c;
                                                                                    schoolRec.ProgramDuration = Majr.program__r.Program_Duration__c;
                                                                                    schoolRec.DurationUnit = Majr.program__r.Program_Duration_Unit__c;
                                                                                    schoolRec.LowestIELTSforEnglishUpgrade = Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c;
                                                                                    schoolRec.IELTSMin = Majr.program__r.IELTS_Min__c;
                                                                                    schoolRec.LowestTOEFLforEnglishUpgrade =  string.valueof(Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c);
                                                                                    schoolRec.TOEFLMin  =  string.valueof(Majr.program__r.TOEFL_Min__c);
                                                                                    schoolRec.toeflUpgrade = string.valueof(Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c);
                                                                                    schoolRec.ieltsUpgrade = string.valueof(Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c);
                                                                                    
                                                                                    mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);    
                                                                                }
                                                                                
                                                                            }//Bachloreneeded=='No'
                                                                            else if( Bachloreneeded=='Yes' && Majr.Program__r.Bachelor_Needed__c =='Yes'){	//Bachloreneeded=='Yes'
                                                                                
                                                                                if(isportal == true){
                                                                                    
                                                                                    schoolRec.majorLink = Label.CommunityDomainUrl+Majr.Id;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.Id;
                                                                                    schoolRec.SchoolId =  Label.CommunityDomainUrl+Majr.program__c;//'https://tmcdev-maxway.cs74.force.com/s/detail/'+Majr.program__c;
                                                                                }
                                                                                    
                                                                                else{
                                                                                    schoolRec.majorLink =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.Id+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Major__c/'+Majr.Id+'/view';
                                                                                    schoolRec.SchoolId =  Label.DomainUrl+'lightning/r/Major__c/'+Majr.program__c+'/view';//'https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Major__c/'+Majr.program__c+'/view';
                                                                                }
                                                                                    
                                                                                setSchoolName.add( Majr.program__r.Campus__r.Account__r.Name );
                                                                                schoolRec.Name = Majr.program__r.Campus__r.Name ;//Majr.program__r.Campus__r.Account__r.Name
                                                                                schoolRec.Province = Majr.program__r.Campus__r.Province_State_New__c;
                                                                                schoolRec.City = Majr.program__r.Campus__r.Nearest_Big_City_New__c;
                                                                                //schoolRec.Program = Majr.program__r.Name;
                                                                                schoolRec.Program = Majr.Program__r.Program_Type__c; 
                                                                                schoolRec.Major = Majr.Name; 
                                                                                schoolRec.worldRank = Majr.Program__r.Campus__r.World_Ranking__c; 
                                                                                string cur = string.valueOf(Majr.program__r.Est_Annual_Cost__c).removeEnd('.00');
                                                                                
                                                                                //added 18 june 2020 as if cur contains decimal value other than .00
                                                                                if( cur.contains( '.' ) ){
                                                                                    system.debug('@@@@@@@@@@@@ --> ' + cur );
                                                                                    cur = cur.replace('.','#'); 
                                                                                    system.debug('@@@@@@@@@@@@ --> ' + cur); 
                                                                                    system.debug('@@@@@@@@@ --> ' + cur.split('#')); 
                                                                                    cur = cur.split('#')[0]; 
                                                                                    // cur = cur.split('.')[0];
                                                                                }
                                                                                
                                                                                string currf = formatCurr(integer.valueof(cur));
                                                                                schoolRec.flyerLink = Majr.Program__r.Campus__r.Account__r.School_s_Flyer__c;
                                                                                schoolRec.AnnualFees = Majr.program__r.CurrencyIsoCode +' ' +currf;
                                                                                schoolRec.MonthsofIntake = Majr.program__r.Month_s_of_Intake__c;
                                                                                schoolRec.ProgramDuration = Majr.program__r.Program_Duration__c;
                                                                                schoolRec.DurationUnit = Majr.program__r.Program_Duration_Unit__c;
                                                                                schoolRec.LowestIELTSforEnglishUpgrade = Majr.program__r.Lowest_IELTS_to_start_upgrade_ESL_EAP__c;
                                                                                schoolRec.IELTSMin = Majr.program__r.IELTS_Min__c;
                                                                                schoolRec.LowestTOEFLforEnglishUpgrade =  string.valueof(Majr.program__r.Lowest_TOEFL_to_start_upgrade_ESL_EAP__c);
                                                                                schoolRec.TOEFLMin  =  string.valueof(Majr.program__r.TOEFL_Min__c);
                                                                                  schoolRec.toeflUpgrade = string.valueof(Majr.program__r.TOEFL_accepted_for_update_ESL_EAP__c);
                                                                                    schoolRec.ieltsUpgrade = string.valueof(Majr.program__r.IELTS_accepted_for_upgrade_ESL_EAP__c);
                                                                                      
                                                                                mapOfSchoolModal.put(schoolRec.schoolId,schoolRec);    
                                                                            }
                                                                            
                                                                        }//end of major query
                                                                        
                                                                        for(String schRec : mapOfSchoolModal.keyset()){
                                                                            
                                                                            schoolList.add(mapOfSchoolModal.get(schRec));
                                                                        }
                                                                        if( schoolList.size() > 0 ) {
                                                                
                                                                      schoolList[0].totalSchoolANdProg = setSchoolName.size() + ' Schools '+ schoolList.size() + ' Programs';
                                                                      
                                                                      for( Integer index = 0; index < schoolList.size(); index++ ){
                                                                          
                                                                          schoolList[ index ].sNo = String.valueOf( index + 1 );
                                                                      }
                                                                  }
                                                                        return schoolList; 
                                                                    }
                                                                    
                                                                    return null;
                                                                }
    
    @AuraEnabled
    public static  list<string> majorrecord(string country,string programtype,string programobjective,string recordtype,string Names){
        system.debug('country-->'+country);
        system.debug('programtype-->'+programtype);
        system.debug('recordtype-->'+recordtype);
        map<string,string> majorname = new map<string,string>();
        list<string> majorrecord = new list<string>();
        set<string> strName = new set<string>();
        
        string query ='select Name,program__r.Campus__r.Account__r.School_s_Country__c,program__r.Program_Type__c from major__c where program__r.Campus__r.Account__r.School_s_Country__c =:country';
        
        if( string.isNotBlank(recordtype)){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
            query +=' and program__r.Campus__r.Account__r.RecordTypeId =:recTypeId';
        }
        
        if(string.isNotBlank(programtype)){
            query +=' and program__r.Program_Type__c=:programtype';
        }
        if(string.isNotBlank(programobjective)){
            query +=' and program__r.Program_Objective__c=:programobjective';
        }
        // Added By Ravi... 11 aug as search were Not working 
        if(string.isNotBlank(Names)){
            query +=' and Name Like \'%' + Names + '%\'';
        }
        // End..Added By Ravi... 11 aug
        /* for(major__c maj : Database.Query(query)){
            strName.add(maj.Name);
        }
        majorrecord.addAll(strName);*/
       query += ' ORDER BY Name';
        for(major__c maj : Database.Query(query)){
            majorname.put(maj.Name,null);
        }
        for(string str : majorname.keyset()){
            majorrecord.add(str);
        }
        return majorrecord;
    }
    
    @AuraEnabled
    //changed method name used in doinit
    public static  list<contractlist> contractdisplay(string accountid){
        id userid = UserInfo.getUserId();
        list<contractlist> wrapcontractlist = new list<contractlist>();
        account acc = [select recordtypeid from account where id =:accountid];
        if(acc.recordtypeid != null){
            Id recordTypeIdhigh = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - HS').getRecordTypeId();
            Id recordTypeIdcol = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - CC').getRecordTypeId(); 
            Id recordTypeIduni = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Overseas School - University').getRecordTypeId(); 
            if(acc.recordtypeid==recordTypeIdhigh ||acc.recordtypeid==recordTypeIdcol || acc.recordtypeid==recordTypeIduni){
                contractlist cont = new contractlist();
                cont.Name ='show';
                cont.show = true;
                wrapcontractlist.add(cont);
                
                //added on 21 may 2020 as dynamic query
                //also if current user is in the account team of the student record then it should be able to see the record.
                String query = 'select Account.OwnerId,Account.Name,Id,Status,ContractNumber from contract where accountid = :accountid';
                Boolean isCurrentUserAccountTeamMeember = false;
                for( AccountTeamMember objAccount : [ SELECT Id, UserId, AccountAccessLevel 
                                                     FROM AccountTeamMember 
                                                     WHERE AccountId =: accountid ] ){
                                                         
                                                         if( objAccount.UserId == userid ){
                                                             isCurrentUserAccountTeamMeember = true;
                                                         }
                                                     }//end of loop
                
                if( !isCurrentUserAccountTeamMeember ){
                    query += ' and account.ownerid =:userid';
                 }
                for(contract  contractlist : Database.query(query)){
                    contractlist con = new contractlist();
                    //con.contractId= 'https://tmcdev-maxway.cs74.force.com/s/detail/'+contractlist.Id; commented on 29 may 2020 as Url is different in each sandbox
                    con.contractId=  label.CommunityDomainUrl+contractlist.Id;
                    con.Name =  contractlist.ContractNumber;
                    con.status= contractlist.Status;
                    con.accountname =  contractlist.Account.Name; 
                    wrapcontractlist.add(con);
                }
                return wrapcontractlist;
            }
            return wrapcontractlist;
        }
        return wrapcontractlist; 
    }
    @AuraEnabled
    public static string addRecomendedSchool(string studentid,list<String> programlist){
        try{
            Id userid = UserInfo.getUserId();
            set<string> accountid = new set<string>();
            list<Recommended_Schools__c> recommendedschoolist = new list<Recommended_Schools__c>();
            user usr = [Select isportalenabled,contact.accountid from user where id = :userid ];  
            set<string> programid = new set<string>();
            for(string str: programlist){
                String program ='';
                if(usr.IsPortalEnabled == true){
                    // Added By Ravi on 27 march 2020
                    program=str.right(18);
                    // program = str.substring(str.lastIndexOf('/')+18);
                }
                else{
                    program = str.substring(str.lastIndexOf('/')-18).removeEnd('/view');
                }
                programid.add(program);
            }
            for(string prog : programid){
                system.debug('prog--->'+prog);
                recommendedschoolist.add(new Recommended_Schools__c(Program__c=prog,Opportunity__c=studentid));
            }
            insert recommendedschoolist;
            return 'success';
        }
        catch(exception e){
            system.debug('--->'+e.getMessage() +'====>'+e.getLineNumber());
            return e.getMessage();
        }
        
    }
    public static string formatCurr(Integer yourInteger)
    {
        string regex = '(\\d)(?=(\\d{3})+(?!\\d))';
        Pattern objPt = Pattern.compile('(\\d)(?=(\\d{3})+(?!\\d))');
        Matcher regMatcher = objPt.matcher(String.valueOf(yourInteger));
        String formattedCur;
        if(regMatcher.find()) {
            formattedCur = String.valueOf(yourInteger).replaceAll(regex, '$1,');
        }
        return formattedCur;
        
    }
    
    
    //______________________________________________________  getOppRecDetails  _____________________________________________________________________________________
    //added on 8 may 2020 as to get selected opp record
    //14 May 2020 as now more than one opportunity to be fetch as per name
     @AuraEnabled
    public static list< OpprtRecdDetails > getOppRecDetails( string searchKey ){
        
        list< OpprtRecdDetails > listOpprtRecdDetails = new list< OpprtRecdDetails >();
         
        string searchKey1 = '%'+ searchKey +'%';
        set< Id > setOppStudntRecType =  ( new map< Id, RecordType > ( [ SELECT Id,DeveloperName 
                                                                      	FROM RecordType 
                                                                      	WHERE SobjectType = 'Opportunity' AND isActive = true AND DeveloperName = 'Student' ] ) ).keySet();
        try{
            for( Opportunity objOpp : [ SELECT Id,Name,StageName,Case_Manager__r.Name, Account.Student_ID__c,Account.Name 
                                       	FROM Opportunity 
                                       	WHERE Name Like :searchKey1
                                      	AND OwnerId =: UserInfo.getUserId() AND RecordTypeId IN : setOppStudntRecType ]){
                
                 OpprtRecdDetails objOpprtRec = new OpprtRecdDetails();
                objOpprtRec.studentId = objOpp.Account.Student_ID__c;
                objOpprtRec.studentName = objOpp.Account.Name;
                objOpprtRec.opportunityName = objOpp.Name;
                objOpprtRec.opportunityStage = objOpp.StageName;
                objOpprtRec.opportunityId = objOpp.Id;
                objOpprtRec.oppCaseManagerName = objOpp.Case_Manager__r.Name;
                listOpprtRecdDetails.add( objOpprtRec );
            }
            
        }catch( Exception objExp ){
            
            system.debug(' Exception ---> ' + objExp.getMessage());
        }
        
        return listOpprtRecdDetails;
        
    }
    
     @AuraEnabled
    public static void getVoid(){
        
    }
    public class OpprtRecdDetails{
        @AuraEnabled public String studentId = '';
        @AuraEnabled public String studentName = '';
        @AuraEnabled public String opportunityName = '';
        @AuraEnabled public String opportunityStage = '';
        @AuraEnabled public String opportunityId = '';
        @AuraEnabled public String oppCaseManagerName = '';
    }
    public class contractlist{
        @AuraEnabled public String contractId = '';
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
    
    public class wrapperPicklist{
        @AuraEnabled public list<String> picklstprogramtypeHS =  new list<String>();
        @AuraEnabled public list<String> picklstprogramtypePG =  new list<String>();
        @AuraEnabled public list<String> picklstprogramtypePS =  new list<String>();
        @AuraEnabled public list<String> picklsthousing =  new list<String>();
        @AuraEnabled public map<String,string> mapcountrywithcurrency =  new map<String,string>();
        @AuraEnabled public list<String> picklstintendedgrade =  new list<String>();
        @AuraEnabled public list<String> picklstnationality =  new list<String>();
        @AuraEnabled public list<String> picklstStudentAgeWhenStartpostsecondaryOverseas =  new list<String>();
        @AuraEnabled public list<String> picklstHighSchoolGrad =  new list<String>();
        @AuraEnabled public list<String> picklstProgramObjectivePG =  new list<String>();
        @AuraEnabled public list<String> picklstProgramObjectivePS =  new list<String>();
        @AuraEnabled public list<String> picklstbachloreneeded =  new list<String>();
        @AuraEnabled public String countrynames = '';
        @AuraEnabled public Map<String,List<String>> objResults = new Map<String,List<String>>();
        @AuraEnabled public Map<String,List<String>> objcitydependent = new Map<String,List<String>>();
        @AuraEnabled public list<String> listIeltsOptions =  new list<String>();
        @AuraEnabled public Map<String,List<String>> mapProgramDependent = new Map<String,List<String>>();
        
    }
    public class HSschool{
        @AuraEnabled public String SchoolId = '';
        @AuraEnabled public String Name = '';
        @AuraEnabled public String Province = '';
        @AuraEnabled public String City = '';
        @AuraEnabled public String Budget = '';
        @AuraEnabled public String Gender = '';
        @AuraEnabled public String IB = '';
        @AuraEnabled public String IBStudent = ''; 
        @AuraEnabled public String SAT = '';
        @AuraEnabled public String ACT = '';
        @AuraEnabled public String ATAR = '';
        @AuraEnabled public String ALevel = '';
        @AuraEnabled public String ALevelRange = ''; 
        @AuraEnabled public String GCSE = '';
        @AuraEnabled public String GCSERange = '';
        @AuraEnabled public String Fraserinstitute  = '';
        @AuraEnabled public String program  = '';
        @AuraEnabled public String flyerLink  = '';
             @AuraEnabled public String totalSchoolANdProg  = '';
        @AuraEnabled public String sNo  = '';
        @AuraEnabled public Boolean isChecked  = false;
    }
    public class PSschool{
        @AuraEnabled public String SchoolId = '';
        @AuraEnabled public String Name = '';
        @AuraEnabled public String Province = '';
        @AuraEnabled public String City = '';
        @AuraEnabled public String Program = '';
        @AuraEnabled public String Major = '';
        @AuraEnabled public String AnnualFees = ''; 
        @AuraEnabled public String MonthsofIntake = '';
        @AuraEnabled public String ProgramDuration  = '';
        @AuraEnabled public String DurationUnit = '';
        @AuraEnabled public String LowestIELTSforEnglishUpgrade  = '';
        @AuraEnabled public String IELTSMin = ''; 
        @AuraEnabled public String LowestTOEFLforEnglishUpgrade  = '';
        @AuraEnabled public String TOEFLMin = '';
        @AuraEnabled public String worldRank = '';
        @AuraEnabled public String majorLink = '';
        @AuraEnabled public String ieltsUpgrade = '';
        @AuraEnabled public String toeflUpgrade = '';
         @AuraEnabled public String flyerLink  = '';
        @AuraEnabled public String totalSchoolANdProg  = '';
		@AuraEnabled public String sNo  = '';
        @AuraEnabled public Boolean isChecked  = false;
        
    }
    public class PGschool{
        @AuraEnabled public String SchoolId = '';
        @AuraEnabled public String Name = '';
        @AuraEnabled public String Province = '';
        @AuraEnabled public String City = '';
        @AuraEnabled public String Program = '';
        @AuraEnabled public String Major = '';
        @AuraEnabled public String AnnualFees = ''; 
        @AuraEnabled public String MonthsofIntake = '';
        @AuraEnabled public String ProgramDuration  = '';
        @AuraEnabled public String DurationUnit = '';
        @AuraEnabled public String worldRank = '';
        @AuraEnabled public String majorLink = '';
        @AuraEnabled public String LowestIELTSforEnglishUpgrade  = '';
        @AuraEnabled public String IELTSMin = ''; 
        @AuraEnabled public String LowestTOEFLforEnglishUpgrade  = '';
        @AuraEnabled public String TOEFLMin = '';
        @AuraEnabled public String ieltsUpgrade = '';
        @AuraEnabled public String toeflUpgrade = '';
             @AuraEnabled public String flyerLink  = '';
        @AuraEnabled public String totalSchoolANdProg  = '';
        @AuraEnabled public String sNo  = '';
        @AuraEnabled public Boolean isChecked  = false;
        
    }
    
}