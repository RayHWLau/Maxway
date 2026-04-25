({
    doint : function(component, event, helper) {
        helper.getcountrycodewithstatecode(component,event);
    },
    OnChangeValueOfCountry : function(component, event, helper) {
        helper.onchangeofcountryvalue(component,event);
    },
    OnChangeValueOfState : function(component, event, helper) {
        helper.OnChangeValueOfStates(component,event);  
    },
    handleHighSchoolClick : function(component, event, helper) {
        document.getElementById('tab-scoped-1__item').classList.add('slds-is-active');
        document.getElementById('tab-scoped-2__item').classList.remove('slds-is-active');
        document.getElementById('tab-scoped-3__item').classList.remove('slds-is-active');
        
        
        document.getElementById('tab-scoped-1__item').children[0].style = 'font-size:12px;background-color:#33334d;color:white;';
        document.getElementById('tab-scoped-2__item').children[0].style = 'font-size:12px;background-color:white;color:black;';
        document.getElementById('tab-scoped-3__item').children[0].style = 'font-size:12px;background-color:white;color:black;';
        
        var programtypepicklist = [];
        programtypepicklist.push({value:'All Grades Offered',label:'All Grades Offered'});
        
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
        
        var schoolPSEvt = $A.get("e.c:ClearSchoolResult");
        var clear = true;       
        schoolPSEvt.setParams({
            'clear': clear
        });
        schoolPSEvt.fire();
        
        for(var i=0 ; i < component.find('filter').length ; i++){
            component.find('filter')[i].set('v.value','');
        }
        for(var i=0 ; i < component.find('addfilter').length ; i++){
            component.find('addfilter')[i].set('v.value',''); 
        }
        
        component.set('v.inputValue','');    
        component.set('v.selectedMajor',''); 
        component.set('v.selectedminBudget','10000');
        component.set('v.selectedProgramType','All Grades Offered');
        component.set('v.isHSButtonShow',true);
        component.set('v.isPSButtonShow',false);
        component.set('v.isPGButtonShow',false);
        
        var pilllist =[];
        for(var pills of component.get('v.filteritems')){
            pills.label= '';  
            pilllist.push(pills);
            
        }
        
        component.set('v.filteritems',pilllist);
        
        var defaultoption = [];
       defaultoption.push({value:'',label:'--None--'});
        
        component.set('v.listProgramType',defaultoption);
    },
    
    handlePostSecondaryClick : function(component, event, helper) {
        document.getElementById('tab-scoped-2__item').classList.add('slds-is-active');
        document.getElementById('tab-scoped-1__item').classList.remove('slds-is-active');
        document.getElementById('tab-scoped-3__item').classList.remove('slds-is-active');	
        
        
        
        document.getElementById('tab-scoped-2__item').children[0].style = 'font-size: 12px;color:white;background-color:#33334d';
        document.getElementById('tab-scoped-1__item').children[0].style = 'font-size: 12px;background-color:white;color:black;';
        document.getElementById('tab-scoped-3__item').children[0].style = 'font-size: 12px;background-color:white;color:black;';
        
        component.set("v.programobjective",component.get("v.programobjectivePS"));
        
        var programtypepicklist = [];
        programtypepicklist.push({value:'',label:'--None--'});
        
        for(var key of component.get("v.programtypePS")){
            var statusOption = {
                value:key,
                label:key
            }
            programtypepicklist.push(statusOption); 
        }
        
        component.set("v.programtype",programtypepicklist);
        
        for(var i=0 ; i < component.find('filter').length ; i++){
            component.find('filter')[i].set('v.value','');
        }
        for(var i=0 ; i < component.find('addfilter').length ; i++){
            component.find('addfilter')[i].set('v.value',''); 
        }
        
        
        var schoolPSEvt = $A.get("e.c:ClearSchoolResult");
        var clear = true;       
        schoolPSEvt.setParams({
            'clear': clear
        });
        schoolPSEvt.fire();
        
        component.set('v.inputValue','');    
        component.set('v.selectedMajor',''); 
        component.set('v.selectedminBudget','10000');
        component.set('v.isHSButtonShow',false);
        component.set('v.isPSButtonShow',true);
        component.set('v.isPGButtonShow',false); 
        
        var pilllist =[];
        for(var pills of component.get('v.filteritems')){
            pills.label= '';  
            pilllist.push(pills);  
        }
        
        component.set('v.filteritems',pilllist);
          
        var defaultoption = [];
       defaultoption.push({value:'',label:'--None--'});
        
        component.set('v.listProgramType',defaultoption);
        
    },
    handlePostGraduateClick : function(component, event, helper) {
        document.getElementById('tab-scoped-3__item').classList.add('slds-is-active');
        document.getElementById('tab-scoped-1__item').classList.remove('slds-is-active');
        document.getElementById('tab-scoped-2__item').classList.remove('slds-is-active');
        
        
        document.getElementById('tab-scoped-3__item').children[0].style = 'font-size: 12px;background-color:#33334d;color: white;';
        document.getElementById('tab-scoped-1__item').children[0].style = 'font-size: 12px;background-color:white;color:black;';
        document.getElementById('tab-scoped-2__item').children[0].style = 'font-size: 12px;background-color:white;color:black;';
        
        component.set("v.programobjective",component.get("v.programobjectivePG"));
        
        var programtypepicklist = [];
        programtypepicklist.push({value:'',label:'--None--'});
        
        for(var key of component.get("v.programtypePG")){
            var statusOption = {
                value:key,
                label:key
            }
            programtypepicklist.push(statusOption); 
        }
        
        component.set("v.programtype",programtypepicklist);
        
        
        var schoolPSEvt = $A.get("e.c:ClearSchoolResult");
        var clear = true;       
        schoolPSEvt.setParams({
            'clear': clear
        });
        schoolPSEvt.fire();
        
        for(var i=0 ; i < component.find('filter').length ; i++){
            component.find('filter')[i].set('v.value','');
        }
        for(var i=0 ; i < component.find('addfilter').length ; i++){
            component.find('addfilter')[i].set('v.value',''); 
        }
        
        component.set('v.inputValue','');    
        component.set('v.selectedMajor',''); 
        component.set('v.selectedminBudget','10000');
        component.set('v.isHSButtonShow',false);
        component.set('v.isPSButtonShow',false);
        component.set('v.isPGButtonShow',true);
        
        var pilllist =[];
        for(var pills of component.get('v.filteritems')){
            pills.label= '';  
            pilllist.push(pills);  
        }
        
        component.set('v.filteritems',pilllist);
          
        var defaultoption = [];
       defaultoption.push({value:'',label:'--None--'});
        
        component.set('v.listProgramType',defaultoption);
    },
    
    toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    },
    searchHandler : function(component, event, helper) {
        var searchnationality=[];
        const searchString = event.target.value;
        var counter = 0 ;
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
        
        if (searchString.length >= 3) {
            component.set('v.inputValue',searchString);  
            for(var str of component.get("v.nationalitylist")){
                if(str.toUpperCase().includes(searchString.toUpperCase())){
                    searchnationality.push(str);   
                }
            }
            
            if(searchnationality.length >0) component.set("v.results",searchnationality); 
            if(searchnationality.length>0){
                component.set("v.openDropDown", true);
                
                var pilllist = [];
                for(var pills of component.get('v.filteritems')){
                    if(pills.name === event.target.name){
                        //  pills.label= 'Nationality : '+event.target.value ;  
                        pills.label= event.target.value ;  
                        pilllist.push(pills);
                    }
                    else{
                        pilllist.push(pills);     
                    }
                }
                component.set('v.filteritems',pilllist);
            }
            else{
                
                component.set("v.results", []);
                component.set("v.openDropDown", false);
                
                var pilllist = [];
                
                for(var pills of component.get('v.filteritems')){
                    if(pills.name === event.target.name){
                        //  pills.label= 'Nationality : '+event.target.value ;  
                        pills.label= event.target.value ; 
                        pilllist.push(pills);
                    }
                    else{
                        
                        pilllist.push(pills);    
                    }
                }
                component.set('v.filteritems',pilllist);
            }
        } 
        else{
            var pilllist = [];
            component.set('v.inputValue',searchString);  
            for(var pills of component.get('v.filteritems')){
                if(pills.name === event.target.name){
                    pills.label= '';  
                    pilllist.push(pills);
                }
                else{
                    
                    pilllist.push(pills);    
                }
            }
            
            component.set('v.filteritems',pilllist);
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },
    
    optionClickHandler : function (component, event, helper) {
        var counter = 0 ;
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
        
        const selectedValue = event.target.closest('li').dataset.value;
        
        var pilllist = [];
        
        for(var pills of component.get('v.filteritems')){
            if(pills.name === event.target.closest('li').dataset.id){
                // pills.label= 'Nationality : '+selectedValue ; 
                pills.label= selectedValue ;  
                pilllist.push(pills);
            }
            else{
                pilllist.push(pills);    
            }
        }
        
        component.set('v.filteritems',pilllist);
        component.set("v.inputValue", selectedValue);
        component.set("v.openDropDown", false);
    },
    
    programtypechange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);  
    },
    
    Currencychange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    minchange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    
    maxchange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    
    gradechange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    
    citychange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    
    housingchange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    admissionagechange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    programobjectivechange  : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    highschoolgradchange : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    Bachloreneededchange  : function (component, event, helper){
        helper.requiredCheckPillsDisplay(component, event);
    },
    
    toeflchange : function (component, event, helper){
        
        var charCode = (event.which) ? event.which : event.keyCode;
        
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        else if( Number(event.getSource().get("v.value")) > 0 && Number(event.getSource().get("v.value")) <= 120){
            
            //at a time only ielts or toefl to be entered
            if( !$A.util.isEmpty( component.get('v.selectediltes') )){
                
                alert(' Please enter either IELTS or TOEFL(1-120) ');
                
                component.set('v.selectedtoefl','');
            }else{
                helper.requiredCheckPillsDisplay(component, event);
            }
            
            
        }
        else if( !$A.util.isEmpty( event.getSource().get("v.value") )){
                alert('Please enter a valid TOEFL between 1 - 120 ');
                component.set('v.selectedtoefl','');
                helper.requiredCheckPillsDisplay(component, event);    
            }
            else{
               helper.requiredCheckPillsDisplay(component, event);  
            }
        
    },
    
    ilteschange : function (component, event, helper){
        
        //at a time only ielts or toefl to be entered
        if( !$A.util.isEmpty( component.get('v.selectedtoefl') )){
            
             alert(' Please enter either IELTS or TOEFL(1-120) ');
            
             component.set('v.selectediltes','');
        }else{
            helper.requiredCheckPillsDisplay(component, event);
        }
        
            
    },
    
    handleRemove : function (component, event, helper) {
        
        if(event.target.name === 'NationalityId'){
            component.set('v.inputValue','');   
            
        }
        else if(event.target.name === 'MajorId'){
            component.set('v.selectedMajor','');  
        }
            else{
                for(var i=0 ; i < component.find('filter').length ; i++){
                    if(component.find('filter')[i].get('v.name') === event.target.name ){
                        component.find('filter')[i].set('v.value','');
                    } 
                }
                for(var i=0 ; i < component.find('addfilter').length ; i++){
                    if(component.find('addfilter')[i].get('v.name') === event.target.name ){
                        component.find('addfilter')[i].set('v.value','');
                    } 
                }   
            }
        
        var pilllist = [];
        
        for(var pills of component.get('v.filteritems')){
            if(pills.name === event.target.name){
                pills.label= '';  
                pilllist.push(pills);
            }
            else{
                
                pilllist.push(pills);    
            }
        }
        component.set('v.filteritems',pilllist); 
        
        var counter = 0 ;
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
    },
    
    isNumber : function(component,event){
        var charCode = (event.which) ? event.which : event.keyCode;
        
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        return true; 
    },
    
    handlePaste: function(component, event, helper) {
        event.preventDefault(); 
    },
    
    handleSearch : function(component, event, helper){
       
        //  alert(component.get('v.selectedMajor'));
        var counter = 0 ;
        for(var i=0 ; i < component.find('filter').length ; i++){
            
            if( component.find('filter')[i].get('v.name') == 'SchoolTypeId' ){
              continue;  
            }
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
       
        if(counter == 0 ){
            var a = event.getSource(); 
            var recordtype='';
            if(component.get('v.selectedSchoolType')==='College'){
                    recordtype = 'Overseas School - CC';
                }
                if(component.get('v.selectedSchoolType')==='University'){
                    recordtype = 'Overseas School - University';
                }
            if(component.get('v.isHSButtonShow')===true){
                
                var schoolHSEvt = $A.get("e.c:SearchHighSchool");
                
                schoolHSEvt.setParams({
                    'nationality': document.getElementById('NationalityId').value,
                    'country': component.get('v.selectedCountry'),
                    'programtype' : component.get('v.selectedProgramType'),
                    'minbudget' : component.get('v.selectedminBudget'),
                    'maxbudget' : component.get('v.selectedmaxBudget'),
                    'grade' : component.get('v.selectedGrade'),
                    'province' : component.get('v.selectedState'),
                    'city' : component.get('v.selectedCity'),
                    'housing' : component.get('v.selectedHousing'),
                    'currencycode'  : component.get('v.selectedCurrency')
                });
                schoolHSEvt.fire();
            }
            
            if(component.get('v.isPSButtonShow')===true){
                
                var schoolPSEvt = $A.get("e.c:SearchPostSecondarySchool");
                
                schoolPSEvt.setParams({
                    'nationality': document.getElementById('NationalityId').value,
                    'country': component.get('v.selectedCountry'),
                    'programtype' : component.get('v.selectedProgramType'),
                    'minbudget' : component.get('v.selectedminBudget'),
                    'maxbudget' : component.get('v.selectedmaxBudget'),
                    'programobjective' : component.get('v.selectedprogramobjective'),
                    'province' : component.get('v.selectedState'),
                    'city' : component.get('v.selectedCity'),
                    'Major' : component.get('v.selectedMajor'),
                    'highschoolgrad' : component.get('v.selectedhighschoolgrad'),
                    'currencycode'  : component.get('v.selectedCurrency'),
                    'toefl':component.get('v.selectedtoefl'),
                    'ielts':component.get('v.selectediltes'),
                    'recordtype':recordtype
                });
                schoolPSEvt.fire(); 
            }
            
            if(component.get('v.isPGButtonShow')===true){
                
                var schoolPGEvt = $A.get("e.c:SearchPostGradSchool");
                
                schoolPGEvt.setParams({
                    'nationality': document.getElementById('NationalityId').value,
                    'country': component.get('v.selectedCountry'),
                    'programtype' : component.get('v.selectedProgramType'),
                    'minbudget' : component.get('v.selectedminBudget'),
                    'maxbudget' : component.get('v.selectedmaxBudget'),
                    'programobjective' : component.get('v.selectedprogramobjective'),
                    'province' : component.get('v.selectedState'),
                    'city' : component.get('v.selectedCity'),
                    'Major' : component.get('v.selectedMajor'),
                    'Bachloreneeded' : component.get('v.selectedBachloreneeded'),
                    'currencycode'  : component.get('v.selectedCurrency'),
                    'toefl':component.get('v.selectedtoefl'),
                    'ielts':component.get('v.selectediltes'),
                    'recordtype':recordtype
                });
                schoolPGEvt.fire(); 
            } 
        }else{
            alert('Please fill all required fields.');
        }
    },
    
    handleClearHS : function(component, event, helper){
        
        var schoolPSEvt = $A.get("e.c:ClearSchoolResult");
        var clear = true;       
        schoolPSEvt.setParams({
            'clear': clear
        });
        schoolPSEvt.fire();
        
        for(var i=0 ; i < component.find('filter').length ; i++){
            component.find('filter')[i].set('v.value','');
        }
        for(var i=0 ; i < component.find('addfilter').length ; i++){
            component.find('addfilter')[i].set('v.value',''); 
        }
        
        component.set('v.inputValue','');    
        component.set('v.selectedMajor','');   
        
        var pilllist = [];
        
        for(var pills of component.get('v.filteritems')){
            pills.label= '';  
            pilllist.push(pills);
        }
        component.set('v.filteritems',pilllist);   
    },
    
    MajorsearchHandler : function(component,event){
        var searchmajor=[];
        const searchString = event.target.value;
        if($A.util.isEmpty(component.get('v.selectedCountry'))){
            document.getElementById("MajorId").value='';
            alert('Please Choose Country first.');    
        } 
        /*else if($A.util.isEmpty(component.get('v.selectedProgramType')) ){ //&& $A.util.isEmpty(component.get('v.selectedprogramobjective'))
            document.getElementById("MajorId").value='';
            alert('Please Choose Program Type First.'); //or Program Objective first
             
        }*/
        else{
            var counter = 0 ;
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
            
            if (searchString.length >= 3) {
                component.set("v.selectedMajor", searchString);
                var recordtype = '';
                if(component.get('v.selectedSchoolType')==='College'){
                    recordtype = 'Overseas School - CC';
                }
                if(component.get('v.selectedSchoolType')==='University'){
                    recordtype = 'Overseas School - University';
                }
                var action = component.get('c.majorrecord');
                action.setParams({
                    'country':component.get('v.selectedCountry'),
                    'programtype':component.get('v.selectedProgramType'),
                    'programobjective':component.get('v.selectedprogramobjective'),
                    'recordtype' :recordtype,
                    'Names':component.get("v.selectedMajor")
                });
                action.setCallback(this,function(response){
                    if (response.getState() === "SUCCESS"){
                        if(response.getReturnValue() != null ){       
                            for(var str of  response.getReturnValue()){
                                
                                if(str.toUpperCase().includes(searchString.toUpperCase())){
                                    searchmajor.push(str);   
                                }
                            }
                            
                            if(searchmajor.length>0){
                                component.set("v.Majorresults",searchmajor); 
                                component.set("v.MajoropenDropDown", true);
                                var pilllist = [];
                                
                                for(var pills of component.get('v.filteritems')){
                                    if(pills.name === event.target.name){
                                        //    pills.label= 'Major : '+event.target.value ;
                                        pills.label= event.target.value ;   
                                        pilllist.push(pills);
                                    }
                                    else{
                                        pilllist.push(pills);     
                                    }
                                }
                                component.set('v.filteritems',pilllist);
                                
                            }
                            else{
                                
                                component.set("v.Majorresults", []);
                                component.set("v.MajoropenDropDown", false);
                                
                                var pilllist = [];
                                
                                for(var pills of component.get('v.filteritems')){
                                    if(pills.name === event.target.name){
                                        //   pills.label= 'Major : '+event.target.value ;
                                        pills.label= event.target.value ;   
                                        pilllist.push(pills);
                                    }
                                    else{
                                        pilllist.push(pills);    
                                    }
                                }
                                component.set('v.filteritems',pilllist);
                            }
                        }
                    }
                });
                $A.enqueueAction(action);
                
            } 
            else{
                component.set("v.selectedMajor", searchString);
                var pilllist = [];
                
                for(var pills of component.get('v.filteritems')){
                    if(pills.name === event.target.name){
                        pills.label= '';  
                        pilllist.push(pills);
                    }
                    else{
                        
                        pilllist.push(pills);    
                    }
                }
                
                component.set('v.filteritems',pilllist);
                component.set("v.Majorresults", []);
                component.set("v.MajoropenDropDown", false);
            }   
       }
      
    },
    MajoroptionClickHandler : function(component,event){
        const selectedValue = event.target.closest('li').dataset.value;
        
        var pilllist = [];
        
        for(var pills of component.get('v.filteritems')){
            if(pills.name === event.target.closest('li').dataset.id){
                //   pills.label= 'Major : '+selectedValue ; 
                pills.label= selectedValue ;  
                pilllist.push(pills);
            }
            else{
                pilllist.push(pills);    
            }
        }
        
        component.set('v.filteritems',pilllist);
        component.set("v.selectedMajor", selectedValue);
        component.set("v.MajoropenDropDown", false);   
    },
    schooltypechange : function(component,event,helper){
        
        var pilllist = component.get('v.filteritems');
        for(var pills of pilllist){
            
            if( pills.name == 'programTypeId'){
                pills.label = '';
            }
           
        }
        
        component.set('v.filteritems',pilllist );
        component.set('v.selectedProgramType','');
        
        if( component.get('v.isPGButtonShow') ){
            
            if( component.get('v.selectedSchoolType') == 'College' ){
                
                var listProgramType = [];
                listProgramType.push({value:'',label:'--None--'});
                var listProgramMetaData = component.get('v.mapSchoolTypeWithProgram')['PG-College'];
                for(var index = 0; index < listProgramMetaData.length; index++){
                    var programOpt = {
                        value:listProgramMetaData[index] ,
                        label:listProgramMetaData[index]
                    }
                    listProgramType.push(programOpt);
                }
                component.set('v.listProgramType',listProgramType);
            }
            else if ( component.get('v.selectedSchoolType') == 'University' ){
             
                var listProgramType = [];
                listProgramType.push({value:'',label:'--None--'});
                var listProgramMetaData = component.get('v.mapSchoolTypeWithProgram')['PG-Univeristy'];
                for(var index = 0; index < listProgramMetaData.length; index++){
                    var programOpt = {
                        value:listProgramMetaData[index] ,
                        label:listProgramMetaData[index]
                    }
                    listProgramType.push(programOpt);
                }
                component.set('v.listProgramType',listProgramType);
            }
            
        }//end of Post graduation
        
        else if( component.get('v.isPSButtonShow') ){
            
            if( component.get('v.selectedSchoolType') == 'College' ){
                
                var listProgramType = [];
                listProgramType.push({value:'',label:'--None--'});
                var listProgramMetaData = component.get('v.mapSchoolTypeWithProgram')['PS-College'];
                for(var index = 0; index < listProgramMetaData.length; index++){
                    var programOpt = {
                        value:listProgramMetaData[index] ,
                        label:listProgramMetaData[index]
                    }
                    listProgramType.push(programOpt);
                }
                component.set('v.listProgramType',listProgramType);
            }
            else if ( component.get('v.selectedSchoolType') == 'University' ){
                
                var listProgramType = [];
                listProgramType.push({value:'',label:'--None--'});
                var listProgramMetaData = component.get('v.mapSchoolTypeWithProgram')['PS-University'];
                for(var index = 0; index < listProgramMetaData.length; index++){
                    var programOpt = {
                        value:listProgramMetaData[index] ,
                        label:listProgramMetaData[index]
                    }
                    listProgramType.push(programOpt);
                }
                component.set('v.listProgramType',listProgramType);
            }
            
        }
        
       helper.requiredCheckPillsDisplay(component, event);  
    }
    
    
})