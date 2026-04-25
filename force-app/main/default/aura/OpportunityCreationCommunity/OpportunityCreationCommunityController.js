({
    doinit : function(component,event,helper){
        
        helper.getLoginUser(component,event);
        if(component.get('v.oppId') == null){
            component.set('v.header','New Opportunity: Student');
            component.set('v.opportunity.Follow_Up_Situation__c','Need Appointment');
            component.set('v.opportunity.StageName','Prospective');
        }
        else{
            component.set('v.header','Edit Opportunity: Student');   
        }
        
        var action = component.get('c.getOnLoadData'); 
        action.setCallback(this,function(response){
            if (response.getState() === "SUCCESS"){
                if(response.getReturnValue() != null){
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
                    var result = response.getReturnValue().objcountrywithstate;
                    var citymap = response.getReturnValue().objstatewithcity;
                    //   alert('result->'+JSON.stringify(result));
                    var countrypicklist = [];
                    var resultLen = result.length;
                    
                    countrypicklist.push({value:'',label:'--None--'});
                    for(var key in result){
                        var statusOption = {
                            value:key,
                            label:key
                        }
                        countrypicklist.push(statusOption);
                        
                    }
                    component.set('v.countrylist',countrypicklist);
                    component.set('v.CountryWithStateMap',result);
                    component.set('v.StateWithCityMap',citymap);
                    component.set('v.recordtypename','Student Account');
                    
                }

            }
        });
        $A.enqueueAction(action);
        
        /*  if(component.get('v.oppId') != null){
            window.setTimeout(
                
                $A.getCallback(function() {
                    component.set('v.recordtypename','Student Account');
                    var action1 = component.get('c.editopportunity');
                    action1.setParams({
                        'oppid' : component.get('v.oppId')
                    });
                    action1.setCallback(this,function(response1){
                        if (response1.getState() === "SUCCESS"){
                            component.set('v.opportunity',response1.getReturnValue().oppdetail);
                            component.set('v.account',response1.getReturnValue().accountdetail);
                            component.set('v.Contact1',response1.getReturnValue().parent1);
                            component.set('v.Contact2',response1.getReturnValue().parent2);
                            component.set('v.cancloselost',response1.getReturnValue().cancloselost);
                            
                            component.set('v.showspinner',false); 
                        }
                    })
                    $A.enqueueAction(action1); 
                }), 5000
            ) 
        }*/
    } ,
    accStatusChange : function(component,event){
        if(event.getSource().get("v.value")=='Don\'t Contact'){
            alert('Cannot close account from here.');
            event.getSource().set("v.value",'Prospective');
        }
        
    },
    Onaccountmangerchange :function(component, event, helper) {
        var selectedValueOfStatus = component.get('v.account.Account_Manager__c');
        
        if(selectedValueOfStatus){
            component.set('v.opportunity.Case_Manager__c',selectedValueOfStatus);   
        }   
    },
    OnOriginalgradechange :function(component, event, helper) {
        var selectedValueOfStatus = component.get('v.account.Original_Grade_Mapping__c');
        
        
        if(selectedValueOfStatus){
            component.set('v.account.Current_Grade_Mapping__c',selectedValueOfStatus);  
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
    handleSave : function(component,event,helper) {
        var a = event.getSource();
        component.set('v.EmailValidation',0);
        var erroremailmsg = '';   
        var accountrequiredFieldLabels = '';
        var accountvalidationFieldLabels = '';
        var opportunityrequiredFieldLabels = '';
        var oncePartent1Fieldentered = '';
        var oncePartent2Fieldentered = '';
        var par1counter = 0 ;
        var par2counter = 0 ;
        var par1checkcounter = 0 ;
        var par2checkcounter = 0 ;
        var social = '';
        var socialaccountname = ''; 
        var socailaccountothers = '';
        var mobile = '';
        var email = '';
        var countrycode = '';
        var dontcontacterror='';
        var con1social = '';
        var con1socialaccountname = ''; 
        var con1socailaccountothers = '';
        var con1mobile = '';
        var con1email = '';
        var con1countrycode = '';
        var con1validationFieldLabels = '';
        var con2social = '';
        var con2socialaccountname = ''; 
        var con2socailaccountothers = '';
        var con2mobile = '';
        var con2email = '';
        var con2countrycode = '';
        var con2validationFieldLabels = '';
        
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        
        //30 apr 2020 as out of AccountContact, Parent 1 Contact, Parent 2 Contact, either one section should be completed
        //else show validation as per the flow
        var isValidAccountContactDataFill = false;
        var isValidParContact1DataFill = false;
        var isValidParContact2DataFill = false;
        
        for(var i = 0 ; i< component.find('acc').length ; i++){
            if(component.find('acc')[i].get('v.label') == 'Country Code') countrycode = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Social Media') social = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Social Media Others') socailaccountothers = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Social Media Account') socialaccountname = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Mobile(Student)') mobile = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Email(Student)') email = component.find('acc')[i].get('v.value');
            
            if(component.find('acc')[i].get('v.required') && !component.find('acc')[i].get('v.value')){
                if(accountrequiredFieldLabels.length == 0) accountrequiredFieldLabels = accountrequiredFieldLabels + component.find('acc')[i].get('v.label');
                else accountrequiredFieldLabels = accountrequiredFieldLabels +','+component.find('acc')[i].get('v.label');
                
            }
            
        }
        
        //if any one column of Account contact is filled that means he need to fill the section.
        if( !$A.util.isEmpty(countrycode) || !$A.util.isEmpty(social) || !$A.util.isEmpty(socailaccountothers) ||
          !$A.util.isEmpty(socialaccountname) || !$A.util.isEmpty(mobile) || !$A.util.isEmpty(email) ){
            isValidAccountContactDataFill = true;
        }
        
        // alert(countrycode +';'+ social+';'+ socailaccountothers+';'+ socialaccountname+';'+ mobile+';'+ email);
        if( ($A.util.isEmpty(socialaccountname) && $A.util.isEmpty(mobile)) && $A.util.isEmpty(email)){
            accountvalidationFieldLabels = 'Either fill Social Media and Social Media Account or Social Media others and Social Media Account or Mobile Or Email';  
        }
        if( !$A.util.isEmpty(socialaccountname)  &&  $A.util.isEmpty(social) && $A.util.isEmpty(socailaccountothers)){
            accountvalidationFieldLabels = 'Either fill Social Media  or Social Media others';    
        }
        if(!$A.util.isEmpty(mobile) && $A.util.isEmpty(countrycode)){
            accountvalidationFieldLabels = 'Please Fill country code';
        }
        if( (!$A.util.isEmpty(social) ||  !$A.util.isEmpty(socailaccountothers)) && $A.util.isEmpty(socialaccountname)){
            accountvalidationFieldLabels = 'Fill Social Media Account';    
        }
        if(!$A.util.isEmpty(email)){   
            if(!email.match(regExpEmailformat)){
                component.set('v.EmailValidation',1);
                erroremailmsg = 'Email(Student) format is not correct.'
            }
        }
        /*   if(component.get('v.account.Student_Status__c')=='Don\'t Contact'){
            if($A.util.isEmpty(component.get('v.account.Dont_Contact_Reason__c')) && $A.util.isEmpty(component.get('v.account.Dont_Contact_Reason_Others__c'))){
                dontcontacterror='Fill either Don\'t Contact reason or Don\'t Contact reason others'; 
            }
        }
        alert(component.get('v.account.Closed_Lost_Reason_Others__c'));
        if((!$A.util.isEmpty(component.get('v.account.Dont_Contact_Reason__c')) || !$A.util.isEmpty(component.get('v.account.Dont_Contact_Reason_Others__c'))) && component.get('v.account.Student_Status__c')!='Don\'t Contact'){
            dontcontacterror='Status should be Don\'t Contact ';   
        }*/
           
           
           for(var i = 0 ; i< component.find('opp').length ; i++){
               if(component.find('opp')[i].get('v.required') && !component.find('opp')[i].get('v.value')){
                   if(opportunityrequiredFieldLabels.length == 0) opportunityrequiredFieldLabels = opportunityrequiredFieldLabels + component.find('opp')[i].get('v.label');
                   else opportunityrequiredFieldLabels = opportunityrequiredFieldLabels +','+component.find('opp')[i].get('v.label');
               }
           }
           var con1validation;
           var con2validation;
           for(var i = 0 ; i< component.find('par1').length ; i++){
               if(component.find('par1')[i].get('v.label') == 'Country Code') con1countrycode = component.find('par1')[i].get('v.value');
               if(component.find('par1')[i].get('v.label') == 'Social Media') con1social = component.find('par1')[i].get('v.value');
               if(component.find('par1')[i].get('v.label') == 'Social Media Others') con1socailaccountothers = component.find('par1')[i].get('v.value');
               if(component.find('par1')[i].get('v.label') == 'Social Media Account') con1socialaccountname = component.find('par1')[i].get('v.value');
               if(component.find('par1')[i].get('v.label') == 'Mobile') con1mobile = component.find('par1')[i].get('v.value');
               if(component.find('par1')[i].get('v.label') == 'Email') con1email = component.find('par1')[i].get('v.value');
               
               if(component.find('par1')[i].get('v.label') == 'Last Name' && component.find('par1')[i].get('v.value')){
                   con1validation = true;
               }
               
               if(component.find('par1')[i].get('v.name') == 'reqiuredonceanyonevalueisfilled')
               {
                   par1counter ++ ;   
               }
               if(component.find('par1')[i].get('v.name') == 'reqiuredonceanyonevalueisfilled' && !component.find('par1')[i].get('v.value')){
                   par1checkcounter ++ ;
                   if(oncePartent1Fieldentered.length == 0) oncePartent1Fieldentered = oncePartent1Fieldentered + component.find('par1')[i].get('v.label');
                   else oncePartent1Fieldentered = oncePartent1Fieldentered +','+component.find('par1')[i].get('v.label');
                   
               }
               
               //30Apr 2020 as if any filed has any value, then it is eligible for validation
               if( !!component.find('par1')[i].get('v.value') ){
                   isValidParContact1DataFill = true;
               }
           }
           
           if( ($A.util.isEmpty(con1socialaccountname) && $A.util.isEmpty(con1mobile)) && $A.util.isEmpty(con1email)){
               con1validationFieldLabels = 'Either fill Social Media and Social Media Account or Social Media others and Social Media Account or Mobile Or Email';  
           }
           if( !$A.util.isEmpty(con1socialaccountname)  &&  $A.util.isEmpty(con1social) && $A.util.isEmpty(con1socailaccountothers)){
               con1validationFieldLabels = 'Either fill Social Media  or Social Media others';    
           }
           if(!$A.util.isEmpty(con1mobile) && $A.util.isEmpty(con1countrycode)){
               con1validationFieldLabels = 'Please Fill country code';
           }
           if( (!$A.util.isEmpty(con1social) ||  !$A.util.isEmpty(con1socailaccountothers)) && $A.util.isEmpty(con1socialaccountname)){
               con1validationFieldLabels = 'Fill Social Media Account';    
           }
           
           if(!$A.util.isEmpty(con1email)){   
               if(!con1email.match(regExpEmailformat)){
                   component.set('v.EmailValidation',1); 
                   erroremailmsg = 'Contact 1 : Email format is not correct.';
               }
           } 
           
           for(var i = 0 ; i< component.find('par2').length ; i++){
               if(component.find('par2')[i].get('v.label') == 'Country Code') con2countrycode = component.find('par2')[i].get('v.value');
               if(component.find('par2')[i].get('v.label') == 'Social Media') con2social = component.find('par2')[i].get('v.value');
               if(component.find('par2')[i].get('v.label') == 'Social Media Others') con2socailaccountothers = component.find('par2')[i].get('v.value');
               if(component.find('par2')[i].get('v.label') == 'Social Media Account') con2socialaccountname = component.find('par2')[i].get('v.value');
               if(component.find('par2')[i].get('v.label') == 'Mobile') con2mobile = component.find('par2')[i].get('v.value');
               if(component.find('par2')[i].get('v.label') == 'Email') con2email = component.find('par2')[i].get('v.value');
               
               if(component.find('par2')[i].get('v.label') == 'Last Name' && component.find('par2')[i].get('v.value')){
                   con2validation = true;
               }
               
               if(component.find('par2')[i].get('v.name') == 'reqiuredonceanyonevalueisfilled')
               {
                   par2counter ++ ;  
               }
               if(component.find('par2')[i].get('v.name') == 'reqiuredonceanyonevalueisfilled' && !component.find('par2')[i].get('v.value')){
                   par2checkcounter  ++;
                   if(oncePartent2Fieldentered.length == 0) oncePartent2Fieldentered = oncePartent2Fieldentered + component.find('par2')[i].get('v.label');
                   else oncePartent2Fieldentered = oncePartent2Fieldentered +','+component.find('par2')[i].get('v.label');
                   
               }
               
               //30Apr 2020 as if any filed has any value, then it is eligible for validation
               if( !!component.find('par2')[i].get('v.value') ){
                   isValidParContact2DataFill = true;
               }
           }
        
        if( ($A.util.isEmpty(con2socialaccountname) && $A.util.isEmpty(con2mobile)) && $A.util.isEmpty(con2email)){
               con2validationFieldLabels = 'Either fill Social Media and Social Media Account or Social Media others and Social Media Account or Mobile Or Email';  
           }
           if( !$A.util.isEmpty(con2socialaccountname)  &&  $A.util.isEmpty(con2social) && $A.util.isEmpty(con2socailaccountothers)){
               con2validationFieldLabels = 'Either fill Social Media  or Social Media others';    
           }
           if(!$A.util.isEmpty(con2mobile) && $A.util.isEmpty(con2countrycode)){
               con2validationFieldLabels = 'Please Fill country code';
           }
           if( (!$A.util.isEmpty(con2social) ||  !$A.util.isEmpty(con2socailaccountothers)) && $A.util.isEmpty(con2socialaccountname)){
               con2validationFieldLabels = 'Fill Social Media Account';    
           }
           if(!$A.util.isEmpty(con2email)){   
               if(!con2email.match(regExpEmailformat)){
                   component.set('v.EmailValidation',1);   
                   erroremailmsg = 'Contact 2 : Email format is not correct.';
               }
           } 
           
           var part1reqvalidation = '';
           var part2reqvalidation = '';
           
           if(par2checkcounter != 0 && par2checkcounter != par2counter){
               part2reqvalidation =oncePartent2Fieldentered;
           }
           
           if(par1checkcounter != 0 && par1checkcounter != par1counter){
               part1reqvalidation = oncePartent1Fieldentered;
           }
           
        //added on 11 may 2020 ( Contact relatiosnhip and lastname must be madatory if edit )
        if( isValidParContact1DataFill ){
            
            if( $A.util.isEmpty(component.get('v.Contact1.Relationship__c')) ){
                
                con1validationFieldLabels += '  Relationship';
            }
            
            if( $A.util.isEmpty(component.get('v.Contact1.LastName')) ){
                con1validationFieldLabels += '  LastName';
            }
        }
        if( isValidParContact2DataFill ){
            
            if( $A.util.isEmpty(component.get('v.Contact2.Relationship__c')) ){
                
                con2validationFieldLabels += '  Relationship';
            }
            
            if( $A.util.isEmpty(component.get('v.Contact2.LastName')) ){
                con2validationFieldLabels += '  LastName';
            }
        }
        //end 10 may 2020
           if(component.get('v.account.Student_Status__c')=='Don\'t Contact'){
               alert('Cannot Create or Edit Opportunity of Don\'t Contact Account');   
           }
           else if(component.get('v.EmailValidation')>0){
               alert(erroremailmsg); 
           }
               else if(!$A.util.isEmpty(opportunityrequiredFieldLabels)){
                   alert('Please Fill following fields of Opportunity '+opportunityrequiredFieldLabels);
               }
                   else if (!$A.util.isEmpty(accountrequiredFieldLabels)){
                       alert('Please Fill following fields of Account '+accountrequiredFieldLabels);   
                   }
        			//30Apr 2020 as either Account section, Parent 1 Contact, Parent 2 contact should be fill
        				else if( isValidAccountContactDataFill + isValidParContact1DataFill + isValidParContact2DataFill === 0 ){
                        
                         alert('Please fill either Account Contact or Parent 1 contact or Parent 2 Contact.');
                    }
        				//30Apr 2020 as if any filed has any value, then it is eligible for validation 
        				//else if (!$A.util.isEmpty(accountvalidationFieldLabels)){
                     else if (!$A.util.isEmpty(accountvalidationFieldLabels) && isValidAccountContactDataFill){
                           alert('Account : '+accountvalidationFieldLabels);
                       }
                           else if (!$A.util.isEmpty(part1reqvalidation)){
                               alert('Please Fill following fields of Parent 1 Contact '+part1reqvalidation);   
                           }
						        //30Apr 2020 as if any filed has any value, then it is eligible for validation 
        						//else if (!$A.util.isEmpty(con1validationFieldLabels) && con1validation == true){
                               else if (!$A.util.isEmpty(con1validationFieldLabels) && ( con1validation == true || isValidParContact1DataFill )){
                                   alert('Parent 1 Contact : '+con1validationFieldLabels);    
                               }
                                   else if (!$A.util.isEmpty(part2reqvalidation)){
                                       alert('Please Fill following fields of Parent 2 Contact '+part2reqvalidation);   
                                   }
        								//30Apr 2020 as if any filed has any value, then it is eligible for validation 
        								//else if (!$A.util.isEmpty(con2validationFieldLabels) && con2validation == true){
                                       else if (!$A.util.isEmpty(con2validationFieldLabels) && ( con2validation == true || isValidParContact2DataFill )){
                                           alert('Parent 2 Contact : '+con2validationFieldLabels);
                                       }
           
                                           else{
                                               component.set('v.showspinner',true); 
                                               var action = component.get('c.saveOpportunity');
                                               action.setParams({
                                                   
                                                   'AccObj': JSON.stringify(component.get('v.account')),
                                                   'part1Obj' : JSON.stringify(component.get('v.Contact1')),
                                                   'part2Obj' : JSON.stringify(component.get('v.Contact2')),
                                                   'OppObj' : JSON.stringify(component.get('v.opportunity')),
                                                   'closedlostreason' : JSON.stringify(component.get('v.selectedcloselostreason')),
                                                   'major' : JSON.stringify(component.get("v.selectedmajor")),
                                                   'housing' : JSON.stringify(component.get("v.selectedHousing")),
                                                   'schooltype' : JSON.stringify(component.get("v.selectedschooltype")),
                                                   'Country' : JSON.stringify(component.get("v.selectedCountry")),
                                                   
                                                    'PreferCountry' : JSON.stringify(component.get("v.selectedCountryOps")),
                                                    'PreferState' : JSON.stringify(component.get("v.selectedStateOps")),
                                                    'PreferCity' : JSON.stringify(component.get("v.selectedCityOps"))
                                                   
                                               });
                                               
                                               action.setCallback(this,function(response){
                                                   component.set('v.showspinner',false); 
                                                   if(response.getState() === "SUCCESS") {
                                                       if(response.getReturnValue().includes('success')){
                                                           var msg = 'The record has been inserted successfully.';
                                                           if(component.get('v.oppId') != null){
                                                               msg ='The record has been updated successfully.'   
                                                           } 
                                                           var toastEvent = $A.get("e.force:showToast");
                                                           toastEvent.setParams({
                                                               "title": "Success!",
                                                               "message": msg,
                                                               "type":'success'
                                                           });
                                                           toastEvent.fire(); 
                                                           helper.closecomponenthelper(component,event);
                                                           
                                                       }
                                                       else{
                                                           var toastEvent = $A.get("e.force:showToast");
                                                           toastEvent.setParams({
                                                               "title": "ERROR!",
                                                               "mode": 'sticky',
                                                               "type":'error',
                                                               "message":response.getReturnValue()   
                                                           });
                                                           toastEvent.fire(); 
                                                           //helper.closecomponenthelper(component,event);  as screen should persists
                                                       }  
                                                   }
                                               });
                                               $A.enqueueAction(action);
                                           }
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
    closemodal : function(component,event,helper){
        helper.closecomponenthelper(component,event);
        
        
    },
    hidenew : function(component,event){
        component.set('v.showbutton',false);
    },
    closelostaction :function(component,event){
        if(component.get('v.cancloselost') == false){
            alert('Cannot Close lost opportunity , has on going application associated with it');
            component.set('v.opportunity.Closed_Lost_Reason__c',null);
            component.set('v.opportunity.Closed_Lost_Description__c',null);
        }
    },
    getEdu:function(component,event,helper){
        if(component.get("v.account").Education_System__c != null && component.get("v.account").Education_System__c !=''){
            component.set("v.counVal",component.get("v.account").Education_System__c); 
        }else{
            component.set("v.counVal",null); 
        }
    }
})