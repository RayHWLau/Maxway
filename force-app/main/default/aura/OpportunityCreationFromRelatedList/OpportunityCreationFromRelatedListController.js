({
    doinit : function(component,event,helper){
        component.set("v.isOrignalChange",false);
        component.set('v.haserror',false); 
        var action = component.get('c.getOnLoadData'); 
        action.setCallback(this,function(response){
            if (response.getState() === "SUCCESS"){
                if(response.getReturnValue() != null){
                    
            component.set('v.opportunity.Follow_Up_Situation__c','Need Appointment');
            component.set('v.opportunity.StageName','Prospective');
                    component.set('v.currencylist',response.getReturnValue().currencylist);
                      component.set('v.genderlist',response.getReturnValue().gender);
                    component.set('v.accRelationshiplist',response.getReturnValue().accRelationship);
                    component.set('v.accedmlist',response.getReturnValue().accedm);
                    component.set('v.accwechatsourcelist',response.getReturnValue().accwechatsource);
                    component.set('v.accConfirmedclientinCompanysocialmedialist',response.getReturnValue().accConfirmedclientinCompanysocialmedia);
                    component.set('v.conwechatsourcelist',response.getReturnValue().conwechatsource);
                    component.set('v.conConfirmedclientinCompanysocialmedialist',response.getReturnValue().conConfirmedclientinCompanysocialmedia);
                    component.set('v.consocialmedialist',response.getReturnValue().consocialmedia);
                    component.set('v.accdataoriginlist',response.getReturnValue().accdataorigin);
                    component.set('v.salutationlist',response.getReturnValue().salutation); 
                    component.set('v.studentstatuslist',response.getReturnValue().studentstatus);
                    component.set('v.SourceOfReferrallist',response.getReturnValue().SourceOfReferral);
                    component.set('v.countryCodelist',response.getReturnValue().countryCode);
                    component.set('v.accsocialmedialist',response.getReturnValue().socialmedia);
                    component.set('v.nationalitylist',response.getReturnValue().nationality);
                    component.set('v.educationSystem',response.getReturnValue().educationSystem);
                    component.set('v.levelofeducationlist',response.getReturnValue().levelofeducation);
                    component.set('v.totalyearofeduationlist',response.getReturnValue().totalyearofeduation);
                    component.set('v.studentatwhatyearlist',response.getReturnValue().studentatwhatyear);
                    component.set('v.startofacedmicyearlist',response.getReturnValue().startofacedmicyear);
                    
                    component.set('v.ForCCorUniversitylist',response.getReturnValue().ForCCorUniversity);
                    component.set('v.ForHSPreferredProgramlist',response.getReturnValue().ForHSPreferredProgram);
                    component.set('v.FollowUpSituationlist',response.getReturnValue().FollowUpSituation);
                    component.set('v.StageNamelist',response.getReturnValue().StageName);
                    component.set('v.Relationshiplist',response.getReturnValue().Relationship);
                    component.set('v.AnnualBudgetlist',response.getReturnValue().AnnualBudget);
                    component.set('v.isportal',response.getReturnValue().oUser.IsPortalEnabled);
                    if(component.get('v.oppId') == null){
                        component.set('v.showspinner',false);   
                    } 
                    var closedlost = response.getReturnValue().ClosedLostReason;
                    var plValues = [];
                    for (var i = 0; i < closedlost.length; i++) {
                        plValues.push({
                            label: closedlost[i],
                            value: closedlost[i]
                        });
                    }
                    component.set('v.ClosedLostReasonlist',plValues);
                    var accclosedlost = response.getReturnValue().closeAccountreason;
                    var p2Values = [];
                    for (var i = 0; i < accclosedlost.length; i++) {
                        p2Values.push({
                            label: accclosedlost[i],
                            value: accclosedlost[i]
                        });
                    }
                    component.set('v.closeAccountreasonlist',p2Values);
                    
                    var HousingOption = response.getReturnValue().HousingOption;
                    var p3Values = [];
                    for (var i = 0; i < HousingOption.length; i++) {
                        p3Values.push({
                            label: HousingOption[i],
                            value: HousingOption[i]
                        });
                    }
                    component.set('v.HousingOptionlist',p3Values);
                    var ForCCorUniversityPreferredMajor =  response.getReturnValue().ForCCorUniversityPreferredMajor;
                    var p4Values = [];
                    for (var i = 0; i < ForCCorUniversityPreferredMajor.length; i++) {
                        p4Values.push({
                            label: ForCCorUniversityPreferredMajor[i],
                            value: ForCCorUniversityPreferredMajor[i]
                        });
                    }
                    component.set('v.ForCCorUniversityPreferredMajorlist',p4Values);
                    var PreferredSchoolType = response.getReturnValue().PreferredSchoolType;
                    var p5Values = [];
                    for (var i = 0; i < PreferredSchoolType.length; i++) {
                        p5Values.push({
                            label: PreferredSchoolType[i],
                            value: PreferredSchoolType[i]
                        });
                    }
                    component.set('v.PreferredSchoolTypelist',p5Values);
                    
                 
                    var opportunitycountry = response.getReturnValue().opportunitycountry;
                    var p6Values = [];
                    for (var i = 0; i < opportunitycountry.length; i++) {
                        p6Values.push({
                            label: opportunitycountry[i],
                            value: opportunitycountry[i]
                        });
                    }
                    component.set('v.opportunitycountry',p6Values);
                    
                    //added on 18May 2020 for Country Preferred (MaxWay User )
                    var preopportunitycountry = response.getReturnValue().preferredOppCountry;
                    var p7Values = [];
                    for (var i = 0; i < preopportunitycountry.length; i++) {
                        p7Values.push({
                            label: preopportunitycountry[i],
                            value: preopportunitycountry[i]
                        });
                    }
                    component.set('v.prefferedCountrylist',p7Values);
                    
                    preopportunitycountry = response.getReturnValue().preferredOppState;
                    p7Values = [];
                    for (var i = 0; i < preopportunitycountry.length; i++) {
                        p7Values.push({
                            label: preopportunitycountry[i],
                            value: preopportunitycountry[i]
                        });
                    }
                    component.set('v.prefferedStatelist',p7Values);
                    
                    preopportunitycountry = response.getReturnValue().preferredOppCity;
                    p7Values = [];
                    for (var i = 0; i < preopportunitycountry.length; i++) {
                        p7Values.push({
                            label: preopportunitycountry[i],
                            value: preopportunitycountry[i]
                        });
                    }
                    component.set('v.prefferedCitylist',p7Values);
                    
                    //end 18 may 2020
                    
                                       var result = response.getReturnValue().objcountrywithstate;
                    var citymap = response.getReturnValue().objstatewithcity;
                    //   alert('result->'+JSON.stringify(result));
                    var countrypicklist = [];
                    var resultLen = result.length;
                    
                    countrypicklist.push({value:'',label:'--None--'});
                    
                    var StatePicklist = [];								//added on 30 april 2020 as removed country residing from ui, so directly show Come from provinence
                    //StatePicklist.push({value:'',label:'--None--'});	//added on 30 april 2020 as removed country residing from ui, so directly show Come from provinence
                    
                    for(var key in result){
                        var statusOption = {
                            value:key,
                            label:key
                        }
                        countrypicklist.push(statusOption);
                        
                                                //added on 30 april 2020 as removed country residing from ui, so directly show Come from provinence
                        var action1List = result[key];
                        
                        if(action1List && action1List.length > 0){
                            var action1ListLen = action1List.length;
                            for(var ii = 0; ii < action1ListLen; ii++){
                                var action1Option = {
                                    value:action1List[ii] ,
                                    label:action1List[ii]
                                }
                                StatePicklist.push(action1Option);
                            }
                        }
                        //added on 30 april 2020
                        
                    }
                    component.set('v.countrylist',countrypicklist);
                    component.set('v.CountryWithStateMap',result);
                    component.set('v.StateWithCityMap',citymap);
                    
                    //added on 30 april 2020 as removed country residing from ui, so directly show Come from provinence
                    component.set('v.showstatecity',true);
                    component.set('v.account.Come_From_Province__c','');
                    component.set('v.account.Come_From_City__c','');
                    component.set('v.statelist',StatePicklist);
                    component.set('v.citylist',null);
                    //added on 30 april 2020
                }
            }
        });
        $A.enqueueAction(action);
        
        if(component.get('v.accId') != null){
            window.setTimeout(
                $A.getCallback(function() {
                    component.set('v.recordtypename','Student Account');
                    var action1 = component.get('c.prepopaccdetails');
                    action1.setParams({
                        'accountid' : component.get('v.accId')
                    });
                    action1.setCallback(this,function(response1){
                        if (response1.getState() === "SUCCESS"){
                            component.set('v.showspinner',false); 
                            if(response1.getReturnValue() != null){
                                
                                component.set('v.account',response1.getReturnValue().accountdetail);   
                                
                                
                                component.set('v.Contact1',response1.getReturnValue().parent1);
                                
                                
                                component.set('v.Contact2',response1.getReturnValue().parent2);
                                component.set("v.counVal",component.get("v.account").Education_System__c);
                                
                                //added 19 may 2020 as to auto populate the City List
                                if( !$A.util.isEmpty( component.get("v.account.Come_From_City__c")) ){
                                    
                                    var slectedCity = component.get("v.account.Come_From_City__c");
                                    
                                    var selectedValueOfStatus = component.get('v.account.Come_From_Province__c');
                                    var CountryWithStateMap = component.get('v.StateWithCityMap');
                                    var cityPicklist = [];
                                    
                                    if(selectedValueOfStatus){
                                        var action1List = CountryWithStateMap[selectedValueOfStatus];
                                        
                                        if(action1List && action1List.length > 0){
                                            var action1ListLen = action1List.length;
                                            for(var ii = 0; ii < action1ListLen; ii++){
                                                var action1Option = {
                                                    value:action1List[ii] ,
                                                    label:action1List[ii]
                                                }
                                                cityPicklist.push(action1Option);
                                            }
                                        }
                                    }
                                    component.set('v.citylist',cityPicklist);
                                    
                                }
                                //end 19 may 2020
                            }
                            
                        }
                        else{
                            component.set('v.showspinner',false); 
                            var errors = response1.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    alert(errors[0].message );//Fetching Custom Message.
                                }
                            }
                            
                        }
                    })
                    $A.enqueueAction(action1); 
                }), 5000)
        }
    }
    
    ,
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
    
    closeModel : function(component,event,helper){
        var url='';
        //added on 4 june 2020 url labels
        var domainUrl = $A.get("$Label.c.DomainUrl");
        var commDomainUrl = $A.get("$Label.c.CommunityDomainUrl");
        
        if(component.get('v.iscommunity'))  url= commDomainUrl+component.get('v.accId');
        else  url= domainUrl+"lightning/r/Account/"+component.get('v.accId')+"/view"; 
        
        
        //if(component.get('v.iscommunity'))  url= 'https://tmcdev-maxway.cs74.force.com/s/detail/'+component.get('v.accId');
        //else  url= "https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Account/"+component.get('v.accId')+"/view"; 
        window.location = url;  
        
    },
    showmainpage : function(component,event,helper){
        component.set('v.haserror',false);   
    },
    submitDetails : function(component,event,helper){
        helper.handlesubmithelper(component,event); 
        
    },
    Onaccountmangerchange :function(component, event, helper) {
        var selectedValueOfStatus = component.get('v.account.Account_Manager__c');
        
        if(selectedValueOfStatus){
            component.set('v.opportunity.Case_Manager__c',selectedValueOfStatus);   
        }   
    },
    OnOriginalgradechange :function(component, event, helper) {
        if(component.get("v.isOrignalChange")){
            var selectedValueOfStatus = component.get('v.account.Original_Grade_Mapping__c');
            
            
            if(selectedValueOfStatus){
                component.set('v.account.Current_Grade_Mapping__c',selectedValueOfStatus);  
            }       
        }else{
            component.set("v.isOrignalChange",true);
        } 
    },
      accStatusChange : function(component,event){
        if(event.getSource().get("v.value")=='Don\'t Contact'){
         alert('Cannot close account from here.');
            event.getSource().set("v.value",'Prospective');
        }
            
    },
    OnChangeValueOfCountry : function(component, event, helper) {
        component.set('v.showstatecity',true);
        var selectedValueOfStatus = component.get('v.account.Country_Residing__c');
        var CountryWithStateMap = component.get('v.CountryWithStateMap');
        var StatePicklist = [];
        
        if(selectedValueOfStatus){
            var action1List = CountryWithStateMap[selectedValueOfStatus];
            
            if(action1List && action1List.length > 0){
                var action1ListLen = action1List.length;
                
                for(var ii = 0; ii < action1ListLen; ii++){
                    var action1Option = {
                        value:action1List[ii] ,
                        label:action1List[ii]
                    }
                    StatePicklist.push(action1Option);
                }
            }
        }
        component.set('v.account.Come_From_Province__c','');
        component.set('v.account.Come_From_City__c','');
        component.set('v.statelist',StatePicklist);
        component.set('v.citylist',null);
    },
    OnChangeValueOfstate : function(component, event, helper) {
        var selectedValueOfStatus = component.get('v.account.Come_From_Province__c');
        var CountryWithStateMap = component.get('v.StateWithCityMap');
        var cityPicklist = [];
        
        if(selectedValueOfStatus){
            var action1List = CountryWithStateMap[selectedValueOfStatus];
            
            if(action1List && action1List.length > 0){
                var action1ListLen = action1List.length;
                
                for(var ii = 0; ii < action1ListLen; ii++){
                    var action1Option = {
                        value:action1List[ii] ,
                        label:action1List[ii]
                    }
                    cityPicklist.push(action1Option);
                }
            }
        }
        component.set('v.citylist',cityPicklist);
    },
      schooltypechange : function(component,helper){
        /*
        if(component.get('v.selectedschooltype').includes('High School')){
            component.set('v.schooltype','High School');
        }
        if(!component.get('v.selectedschooltype').includes('High School')){
           component.set('v.schooltype','College');
        }*/
          
         //incase nothing is selected
        if( component.get('v.selectedschooltype').length == 0 ){
            
            component.set('v.selectedmajor','');
            component.set('v.selectedHousing','');
        }
        //incase both are selected
        else if ( component.get('v.selectedschooltype').includes('High School') && (component.get('v.selectedschooltype').includes('College') || component.get('v.selectedschooltype').includes('University'))){
            
           
            for( var index = 0; index < component.find('opp').length; index ++ ){
                
                if( component.find('opp')[index].get('v.name') == 'Housing Option' ){
                
                    component.find("opp")[index].set("v.disabled", false); 
                }
                if( component.find('opp')[index].get('v.name') == 'Major category' ){
                    
                    component.find("opp")[index].set("v.disabled", false); 
                }
            }
         //incase anyone of them is selected   
        }
            else{
            
            if(component.get('v.selectedschooltype').includes('High School')){
                component.set('v.schooltype','High School');
            }else{
                
                component.set('v.selectedHousing','');
            }
            
            if( component.get('v.selectedschooltype').includes('College') || component.get('v.selectedschooltype').includes('University')){
                
                component.set('v.schooltype','College');
            }else{
                component.set('v.selectedmajor','');
            }
            
        }//end of else  
    },
    getEdu:function(component,event,helper){
        if(component.get("v.account").Education_System__c != null && component.get("v.account").Education_System__c !=''){
           component.set("v.counVal",component.get("v.account").Education_System__c); 
        }else{
            component.set("v.counVal",null); 
        }
    }
})