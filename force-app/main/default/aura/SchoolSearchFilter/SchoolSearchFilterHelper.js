({     
    getcountrycodewithstatecode :function(component,event){
        component.set('v.spinneristrue',true);
        var action = component.get("c.getBranchPicklistvalues");
        action.setCallback(this,function(response) {
            //  alert(JSON.stringify(response.getReturnValue().countrynames.split(';')));
            
            if (response.getState() === "SUCCESS"){
                component.set('v.selectedminBudget','10000');
                
                //added on 8 may 2020 for dependent picklist
                component.set('v.mapSchoolTypeWithProgram',response.getReturnValue().mapProgramDependent)
                
                if(response.getReturnValue().countrynames.includes(';'))
                    component.set('v.usercountrylist',response.getReturnValue().countrynames.split(';'));
                // Added By Ravi on 8 aug 2020...
                if(response.getReturnValue().countrynames != '' && response.getReturnValue().countrynames != null &&  !response.getReturnValue().countrynames.includes(';')){
                    component.set('v.usercountrylist',response.getReturnValue().countrynames); 
                }
                // End Added By Ravi on 8 aug 2020...
                component.set('v.programtypeHS',response.getReturnValue().picklstprogramtypeHS);
                component.set('v.programtypePS',response.getReturnValue().picklstprogramtypePS);
                component.set('v.programtypePG',response.getReturnValue().picklstprogramtypePG);
                component.set("v.housing",response.getReturnValue().picklsthousing);
                component.set("v.CountryWithcurrencyMap",response.getReturnValue().mapcountrywithcurrency);
                component.set("v.admissiongrade",response.getReturnValue().picklstintendedgrade);
                component.set("v.nationalitylist",response.getReturnValue().picklstnationality);
                component.set("v.addmissionage",response.getReturnValue().picklstStudentAgeWhenStartpostsecondaryOverseas);
                component.set("v.highschoolgrad",response.getReturnValue().picklstHighSchoolGrad);
                component.set("v.programobjectivePS",response.getReturnValue().picklstProgramObjectivePS);
                component.set("v.programobjectivePG",response.getReturnValue().picklstProgramObjectivePG);
                component.set("v.Bachloreneeded",response.getReturnValue().picklstbachloreneeded);
                
                
                var programtypepicklist = [];
                programtypepicklist.push({value:'All Grades Offered',label:'All Grades Offered'});
                var schooltypepicklist = [];
                schooltypepicklist.push({value:'College',label:'College'});
                schooltypepicklist.push({value:'University',label:'University'});
                
                component.set("v.schooltype",schooltypepicklist);
                
                for(var key of component.get("v.programtypeHS")){
                    if(key != 'All Grades Offered'){
                        var statusOption = {
                            value:key,
                            label:key
                        }
                        programtypepicklist.push(statusOption);    
                    }
                    
                }
                component.set("v.programtype",programtypepicklist);
                
                var schoollistuser = [];
                
                if(component.get('v.usercountrylist').length >0){
                    schoollistuser = component.get('v.usercountrylist');
                }
                
                var result = response.getReturnValue().objResults;
                var citymap = response.getReturnValue().objcitydependent;
                //   alert('result->'+JSON.stringify(result));
                var headOfficePicklist = [];
                var resultLen = result.length;
                headOfficePicklist.push({value:'',label:'--None--'});
                
                if(schoollistuser.length >0){
                    for(var key in result){
                        if(schoollistuser.includes(key)){
                            var statusOption = {
                                value:key,
                                label:key
                            }
                            headOfficePicklist.push(statusOption);
                        } 
                    }
                }
                else{
                    for(var key in result){
                        var statusOption = {
                            value:key,
                            label:key
                        }
                        headOfficePicklist.push(statusOption);
                    }
                } 
                var filterpills = [];
                /*     for(var i=0 ; i < component.find('filter').length ; i++){
                     var pills = {};
                     alert(component.find('filter')[i].get('v.name'));
                     pills.name = component.find('filter')[i].get('v.name');
                     pills.label ='';
                     pills.iconName = 'standard:task2';
                 filterpills.push(pills);
               }
               for(var i=0 ; i < component.find('addfilter').length ; i++){
                   var pills = {};
                     pills.name = component.find('addfilter')[i].get('v.name');
                     pills.label ='';
                     pills.iconName = 'standard:task2';
                 filterpills.push(pills);    
              } */
                
                filterpills = [
                    {
                        name: 'NationalityId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                    {
                        name: 'MajorId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'countryId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                    {
                        name: 'programTypeId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'programobjectiveId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                    {
                        name: 'admissionageId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'highschoolgradId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                    {
                        name: 'CurrencyId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'minid',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'maxid',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                    {
                        name: 'toeflid',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'GradeHSId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'iltesid',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'ProvinceId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                    {
                        name: 'CityId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'HousingId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    {
                        name: 'BachloreneededId',
                        label: '',
                        iconName:'standard:task2',
                    },
                    
                ];
                    
               var ieltsOptions = [];
                //console.log( response.getReturnValue().listIeltsOptions );
                for(var key in response.getReturnValue().listIeltsOptions){
                  
                        var Option = {
                            value:response.getReturnValue().listIeltsOptions[key],
                            label:response.getReturnValue().listIeltsOptions[key]
                        }
                        ieltsOptions.push(Option);
                    }
                component.set('v.listIeltsOptions',ieltsOptions);  
                component.set('v.filteritems',filterpills);    
                component.set('v.headOfficePicklist',headOfficePicklist);
                component.set('v.CountryWithStateMap',result);
                component.set('v.StateWithCityMap',citymap);
                component.set('v.spinneristrue',false);
                component.set('v.isHSButtonShow',true);
                component.set('v.isPSButtonShow',false);
                component.set('v.isPGButtonShow',false);
                component.set('v.selectedProgramType','All Grades Offered');
                    }//end of response budget
                    // component.set("v.showSpinner",false);
             });
  $A.enqueueAction(action);
  },
                    
 onchangeofcountryvalue : function(component,event){
           var selectedValueOfStatus = component.get('v.selectedCountry');
           var CountryWithStateMap = component.get('v.CountryWithStateMap');
           var CountryWithcurrencyMap = component.get('v.CountryWithcurrencyMap');
           var headOfficeStatePicklist = [];
                
                var a = event.getSource();
                var counter = 0 ;
                
                for(var i=0 ; i < component.find('filter').length ; i++){
                    if($A.util.isEmpty(component.find('filter')[i].get('v.value'))){
                        counter = 1; 
                    } 
                }
                if($A.util.isEmpty(component.get('v.inputValue'))){
                    counter = 1;    
                }
                if(counter == 0 ){
                    
                    var cmpTarget = component.find('SearchId');
                    $A.util.addClass(cmpTarget, 'buttonclass');
                    $A.util.removeClass(cmpTarget, 'buttonclassdis');
                }
                if(counter == 1 ){
                    
                    var cmpTarget = component.find('SearchId');
                    $A.util.removeClass(cmpTarget, 'buttonclass');
                    $A.util.addClass(cmpTarget, 'buttonclassdis');
                }
                
                if(selectedValueOfStatus){
                    var action1List = CountryWithStateMap[selectedValueOfStatus];
                    var currencyvalue = CountryWithcurrencyMap[selectedValueOfStatus];
                    component.set('v.selectedCurrency',currencyvalue);
                    if(action1List && action1List.length > 0){
                        var action1ListLen = action1List.length;
                        
                        for(var ii = 0; ii < action1ListLen; ii++){
                            var action1Option = {
                                value:action1List[ii] ,
                                label:action1List[ii]
                            }
                            headOfficeStatePicklist.push(action1Option);
                        }
                    }
                    var pilllist = [];
                    for(var pills of component.get('v.filteritems')){
                        if(pills.name === a.get('v.name')){
                            //    pills.label= 'Country : '+selectedValueOfStatus ;  
                            pills.label= selectedValueOfStatus ;
                            
                            pilllist.push(pills);
                        }
                        else{
                            pilllist.push(pills);     
                        }
                    }
                    component.set('v.filteritems',pilllist);
                    component.set('v.selectedState','');
                    component.set('v.selectedCity','');
                }else{
                    component.set('v.selectedCurrency','');
                    component.set('v.selectedCountry','');
                    component.set('v.selectedCity','');
                    var pilllist = [];
                    for(var pills of component.get('v.filteritems')){
                        if(pills.name === a.get('v.name')){
                            pills.label= '' ;  
                            pilllist.push(pills);
                        }
                        else{
                            pilllist.push(pills);     
                        }
                    }
                    component.set('v.filteritems',pilllist);
                    
                }
                component.set('v.headOfficeStatePicklist',headOfficeStatePicklist);
   },
                
 OnChangeValueOfStates : function(component,event){
                    var selectedValueOfAction1 = component.get('v.selectedState');
                    var StateWithCityMap = component.get('v.StateWithCityMap');
                    var a = event.getSource(); 
                    var headOfficeCityPicklist = [];
                    
                    if(selectedValueOfAction1 != ''){
                        var action2List = StateWithCityMap[selectedValueOfAction1];
                        if(action2List && action2List.length > 0){
                            var action2ListLen = action2List.length;
                            for(var ii = 0; ii < action2ListLen; ii++){
                                var action2Option = {
                                    value:action2List[ii] ,
                                    label:action2List[ii]
                                }
                                headOfficeCityPicklist.push(action2Option);
                            }
                        }
                        var pilllist = [];
                        for(var pills of component.get('v.filteritems')){
                            if(pills.name === a.get('v.name')){
                                //  pills.label= 'Province : '+selectedValueOfAction1 ;
                                pills.label= selectedValueOfAction1 ;   
                                
                                pilllist.push(pills);
                            }
                            else{
                                pilllist.push(pills);     
                            }
                        }
                        component.set('v.filteritems',pilllist);
                        
                        component.set('v.selectedCity','');
                    }
                    else{
                        var pilllist = [];
                        for(var pills of component.get('v.filteritems')){
                            if(pills.name === a.get('v.name')){
                                pills.label= '' ;  
                                pilllist.push(pills);
                            }
                            else{
                                pilllist.push(pills);     
                            }
                        }
                        component.set('v.filteritems',pilllist);
                    }
                    component.set('v.headOfficeCityPicklist',headOfficeCityPicklist);
    },
                    
  requiredCheckPillsDisplay : function(component,event){
     
                        component.set('v.minisgreaterthanmax',false);
                        var a = event.getSource(); 
                        
                        var selectedValue = a.get('v.value');
                        
                        var counter1 = 0 ;
                        var counter = 0 ;
                          if(component.get('v.isPSButtonShow')===true || component.get('v.isPGButtonShow')===true){
                        for(var i=0 ; i < component.find('ProgramTypeOrObjective').length ; i++){
                            if($A.util.isEmpty(component.find('ProgramTypeOrObjective')[i].get('v.value'))){
                                counter1 ++;   
                            } 
                        }
                          }
                        if(counter1 == 2){
                            document.getElementById('MajorId').value='';  
                        }
                        for(var i=0 ; i < component.find('filter').length ; i++){
                            if($A.util.isEmpty(component.find('filter')[i].get('v.value'))){
                                counter = 1; 
                            } 
                        }
                        if($A.util.isEmpty(document.getElementById('NationalityId').value)){
                            counter = 1;    
                        }
                        if(component.get('v.isPSButtonShow')===true || component.get('v.isPGButtonShow')===true){
                            if($A.util.isEmpty(document.getElementById('MajorId').value)){
                                counter = 1;    
                            }    
                        }
                        if(component.get('v.isPSButtonShow')===true || component.get('v.isPGButtonShow')===true){
                            if(!$A.util.isEmpty(component.get('v.selectedmaxBudget'))){
                                var min = Number(component.get('v.selectedminBudget'));
                                var max = Number(component.get('v.selectedmaxBudget'));
                                if(min >= max && max != null){
                                    component.set('v.minisgreaterthanmax',true);
                                    counter = 1;    
                                }    
                            }    
                        } 

                        if(counter == 0 ){
                            
                            var cmpTarget = component.find('SearchId');
                            $A.util.addClass(cmpTarget, 'buttonclass');
                            $A.util.removeClass(cmpTarget, 'buttonclassdis');
                        }
                        if(counter == 1 ){
                            
                            var cmpTarget = component.find('SearchId');
                            $A.util.removeClass(cmpTarget, 'buttonclass');
                            $A.util.addClass(cmpTarget, 'buttonclassdis');
                        }
                        
                        if(selectedValue){
                            var pilllist = [];
                            for(var pills of component.get('v.filteritems')){
                                if(pills.name === a.get('v.name')){
                                    
                                    //  pills.label= a.get('v.label')+': '+selectedValue ; 
                                    
                                    pills.label= selectedValue ; 
                                    
                                    pilllist.push(pills);
                                }
                                else{
                                    pilllist.push(pills);     
                                }
                            }
                            component.set('v.filteritems',pilllist);   
                        }  
                        else{
                            var pilllist = [];
                            for(var pills of component.get('v.filteritems')){
                                if(pills.name === a.get('v.name')){
                                    pills.label= '' ;  
                                    pilllist.push(pills);
                                }
                                else{
                                    pilllist.push(pills);     
                                }
                            }
                            component.set('v.filteritems',pilllist);   
                        }  
   }          
})