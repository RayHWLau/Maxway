({
    handlesubmithelper : function(component,event) {
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
            if(component.find('acc')[i].get('v.label') == 'Mobile') mobile = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Email') email = component.find('acc')[i].get('v.value');
            if(component.find('acc')[i].get('v.label') == 'Add client to Company social media') component.get('v.account').Add_client_to_Company_social_media__c = component.find('acc')[i].get('v.checked');
            
            if(component.find('acc')[i].get('v.required') && !component.find('acc')[i].get('v.value')){
                if(accountrequiredFieldLabels.length == 0) accountrequiredFieldLabels = accountrequiredFieldLabels + component.find('acc')[i].get('v.label');
                else accountrequiredFieldLabels = accountrequiredFieldLabels +','+component.find('acc')[i].get('v.label');
                
            }
            
        }
        
        //added on 9 may 2020 as when user select Data Origin as 'C' then these two fields should be mandatory
        if( component.get('v.account.Data_Origin__c') == 'C' &&  !component.get('v.isportal') &&
           ( $A.util.isEmpty( component.get('v.account.Come_From_Province__c') ) || $A.util.isEmpty( component.get('v.account.Come_From_City__c') ) )){
            
            accountrequiredFieldLabels = accountrequiredFieldLabels +','+'Come from Province,Come from City';
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
        		//else if (!$A.util.isEmpty(accountvalidationFieldLabels))
                else if (!$A.util.isEmpty(accountvalidationFieldLabels) && isValidAccountContactDataFill ){
                    alert('Account : '+accountvalidationFieldLabels);
                }
                    else if (!$A.util.isEmpty(part1reqvalidation)){
                        alert('Please Fill following fields of Parent 1 Contact '+part1reqvalidation);   
                    }
        				
        				//30Apr 2020 as if any filed has any value, then it is eligible for validation 
        				//else if (!$A.util.isEmpty(con1validationFieldLabels) && con1validation == true)
                        else if (!$A.util.isEmpty(con1validationFieldLabels) && ( con1validation == true || isValidParContact1DataFill )){
                            alert('Parent 1 Contact: '+con1validationFieldLabels);    
                        }
                            else if (!$A.util.isEmpty(part2reqvalidation)){
                                alert('Please Fill following fields of Parent 2 Contact '+part2reqvalidation);   
                            }
        						//30Apr 2020 as if any filed has any value, then it is eligible for validation
        						//else if (!$A.util.isEmpty(con2validationFieldLabels) && con2validation == true)
                                else if (!$A.util.isEmpty(con2validationFieldLabels) && ( con2validation == true || isValidParContact2DataFill )){
                                    alert('Parent 2 Contact: '+con2validationFieldLabels);
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
                                            
                                            if(response.getState() === "SUCCESS") {
                                                component.set('v.showspinner',false);
                                                if(response.getReturnValue().includes('success')){
                                                    
                                                    var oppid =  response.getReturnValue().split(';'); 
                                                    var url
                                                    
                                                    //added on 4 june 2020 url labels
                                                    var domainUrl = $A.get("$Label.c.DomainUrl");
        											var commDomainUrl = $A.get("$Label.c.CommunityDomainUrl");
                                                    if(component.get('v.iscommunity'))  url= commDomainUrl+oppid[1];
                                                    else   url= domainUrl+"lightning/r/Opportunity/"+oppid[1]+"/view"; 
                                                    
                                                    
                                                    //if(component.get('v.iscommunity'))  url= 'https://tmcdev-maxway.cs74.force.com/s/detail/'+oppid[1];
                                                    //else   url= "https://maxwayeducation--tmcdev.lightning.force.com/lightning/r/Opportunity/"+oppid[1]+"/view"; 
                                                    window.location = url;
                                                    
                                                }
                                                else{
                                                    component.set('v.error',response.getReturnValue());
                                                    component.set('v.haserror',true);
                                                    
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
                                        });
                                        $A.enqueueAction(action);
                                    }
        
    }
})