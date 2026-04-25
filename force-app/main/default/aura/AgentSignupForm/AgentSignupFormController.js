({
    doInit : function(component, event, helper) {
        
        var url = $A.get('$Resource.blueimage');
        component.set('v.backgroundImageURL', url);
        component.set("v.showSpinner",true);
        
        var action = component.get("c.checkComponentVisibility");
        action.setParams({
            "oppId" : component.get("v.oppId")
        });
        action.setCallback(this,function(response){            
            if(response.getState() === 'SUCCESS') {
                if(response.getReturnValue().message.includes("SUCCESS") || response.getReturnValue().message.includes("Already Submitted") || response.getReturnValue().message.includes("Expired")) {
                    component.set("v.CheckVisibility",response.getReturnValue());
                    component.set('v.renewal',response.getReturnValue().isrenewal);
                    component.set("v.acc",response.getReturnValue().accToReturn);
                    component.set("v.opp",response.getReturnValue().oppToReturn);
                    //For Document Upload Component
                    if(response.getReturnValue().message.includes("SUCCESS")){
                        var countrypurchase = response.getReturnValue().countrypurchaselist;
                       component.set('v.countrylistdata',response.getReturnValue().currencyListprepop);
                    //    alert(JSON.stringify(response.getReturnValue().countrypurchaselist));
                        var plValues = [];
                        for (var i = 0; i < countrypurchase.length; i++) {
                            plValues.push({
                                label: countrypurchase[i],
                                value: countrypurchase[i]
                            });
                        }
                        component.set("v.countrypurchaselist", plValues);
                        var result = component.get("v.CheckVisibility.mapdocUploadToConDocLink")                        
                        var documentListMap = component.get("v.documentList");
                        var iteratorList = [];
                        
                        for(var key in result){
                            documentListMap[key.replace('*','')] = result[key];
                        }                   
                        component.set("v.documentList",documentListMap);                                
                        for(var key in result){
                            iteratorList.push({key :key.includes('*') ? key.replace('*',''):  key,
                                               value: result[key].includes('#') ? 'check' : '',
                                               required :key.includes('*') ? 'required' :''});
                            
                        }
                        
                        component.set("v.iteratorList",iteratorList);
                    }                    
                }                
                else {
                    component.set("v.errorMsg",response.getReturnValue().message);
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
    },
    
    isNumber : function(component,event){
        var charCode = (event.which) ? event.which : event.keyCode;
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        return true; 
    },  
    
    saveAsDraft : function(component,event){
    //    alert(JSON.stringify(component.get("v.idandfilename")));
        
        if(event.getSource().get("v.label") == 'Submit'){
            var counter = 0;
            var bankvalidation = 0 
            var bankinfo = component.find('bank');
            //     alert(bankinfo.length );
            
            for(var i =0 ; i< bankinfo.length ; i++ ){
                if(!$A.util.isEmpty(component.find("bank")[i].get("v.value"))){
                    //    alert(component.find("bank")[i].get("v.value"));
                    bankvalidation ++ ;
                } 
            }
            //     alert(bankvalidation);
            var bankerror ='';
            if(bankvalidation != 0){
                if(bankvalidation != bankinfo.length){
                    counter=2;
                    bankerror = 'Please either fill all Bank Details or None.'; 
                }
            }
            
            //   alert(JSON.stringify(component.get("v.iteratorList")));
            var listiter = component.get("v.iteratorList");
            var errormsg ='';
            for(var i=0 ; i<listiter.length ; i++){
                if(!listiter[i].value.includes('check') && listiter[i].required.includes('required')){
                    if(errormsg.length>0) errormsg= errormsg+','
                    errormsg = errormsg+listiter[i].key+' ';
                    alert(errormsg);
                    counter = 3;
                }
            }
            if(errormsg.length > 0 ) errormsg = 'Please Upload: ' +errormsg; 
            
            if($A.util.isEmpty(component.get("v.acc.Referee_Institution__c"))) {
                component.find('refInstitution').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.countrylistdata"))) {
                component.find('countrylist').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.acc.Referee_Name__c"))) {
                component.find('refName').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.acc.Referee_Email__c"))) {
                component.find('refEmail').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.opp.Number_Of_Licence__c"))) {
                component.find('NumberOfLicenses').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.opp.Number_of_Admin_Licenses__c"))) {
                component.find('NumberofAdminLicenses').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.opp.Business_License_Valid_Till__c"))) {
                component.find('licenceexpirationdate').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.acc.CurrencyIsoCode"))) {
                component.find('currency').showHelpMessageIfInvalid();
                counter = 1;
            }
            if($A.util.isEmpty(component.get("v.opp.Portal_Admin_Email__c"))) {
                component.find('portalemail').showHelpMessageIfInvalid();
                counter = 1;
            }
        }
        
        if(counter == 0){
          //  alert(JSON.stringify(component.get("v.countrylistdata")));
            component.set("v.showSpinner",true);
            var action = component.get("c.saveAsDraftApex");
            action.setParams({
                "oppId" : component.get("v.oppId"),
                "acc"   : JSON.stringify(component.get("v.acc")),
                "buttonLabel" : event.getSource().get("v.label"),
                "uploadList" : JSON.stringify(component.get("v.uploadList")),
                 "idandfilename" : JSON.stringify(component.get("v.idandfilename")),
                "opp"   : JSON.stringify(component.get("v.opp")),
                "countrypurchasedlist" :component.get("v.countrylistdata")
            });
            
            action.setCallback(this,function(response){  
                if(response.getState() === 'SUCCESS') {
                    if(response.getReturnValue().includes("SUCCESS")){
                        if(event.getSource().get("v.label") == 'Save As Draft')
                            component.set("v.successMsg",$A.get("$Label.c.AgentSignupFormSaveAsDraft"));
                        else
                            component.set("v.successMsg",$A.get("$Label.c.AgentSignupFormSubmitted"));
                    }                
                    else {
                        component.set("v.errorMsgOnSave",response.getReturnValue());
                    }
                }
                else{
                    var vErrors = response.getError();
                    if (vErrors) {
                        if (vErrors[0] && vErrors[0].message) {
                            console.log("Error message: " + vErrors[0].message);
                            if(vErrors[0].message.includes('Regex too complicated')){
                                component.set("v.errorMsgOnSave",'Please Upload smaller file');
                            }
                            else{
                                component.set("v.errorMsgOnSave",vErrors[0].message);   
                            }
                        }
                    }
                    
                }
                component.set("v.showSpinner",false);            
            });
            $A.enqueueAction(action); 
        } 
        
        if(counter ==3 || counter ==2){
            var combinedeeror = '';
            combinedeeror = bankerror.includes('Please') ? (errormsg.includes('Upload') ? bankerror +'  '+errormsg  : bankerror) : (errormsg.includes('Upload') ? errormsg : '');
            if(combinedeeror.length >0)
                component.set("v.errorMsgOnSave",combinedeeror);  
        }
        
        
        
        
    },
    closeModel: function(component, event, helper) {
        // for Hide/Close Model
        component.set("v.errorMsgOnSave", '');
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
    }
})