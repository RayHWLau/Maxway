({
    doInit : function(component, event, helper) {
        helper.getcountrycodewithstatecode(component,event);
    },
    isNumber : function(component,event){
        var charCode = (event.which) ? event.which : event.keyCode;
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        return true; 
    },
    
    saveLeadDetails : function(component,event,helper) {
         var count = 0;
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Salutation"))) {
            component.find('salutation').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.EnquiryDetails.LastName"))) {
            component.find('lastName').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Company"))) {
            component.find('company').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Email"))) {
            component.find('emailId').showHelpMessageIfInvalid();
            count = 1;
        }
  /*      if($A.util.isEmpty(component.get("v.EnquiryDetails.MobilePhone")) && $A.util.isEmpty(component.get("v.EnquiryDetails.Phone"))){
            component.find('phoneId').setCustomValidity('Please mention either Mobile or Phone Number.');
            component.find('phoneId').reportValidity();
            component.find('mobileid').setCustomValidity('Please mention either Mobile or Phone Number.');
            component.find('mobileid').reportValidity();
            count = 1;
        } */
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Country_Code__c"))) {
            component.find('countryCode').showHelpMessageIfInvalid();
            count = 1;
        }
        /*
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Head_Office_Country__c"))) {
            component.find('headOfficeCountry').showHelpMessageIfInvalid();
            count = 1;
        }*/
        /* commented on 21 April 2020
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Head_Office_Province_State__c"))) {
            component.find('headOfficeState').showHelpMessageIfInvalid();
            count = 1;
        }*/
     /*   if($A.util.isEmpty(component.get("v.EnquiryDetails.Head_Office_City__c"))) {
            component.find('headOfficeCity').showHelpMessageIfInvalid();
            count = 1;
        } */
       /*   if($A.util.isEmpty(component.get("v.EnquiryDetails.Number_Of_Branches__c"))) {
            component.find('noOfBranch').showHelpMessageIfInvalid();
            count = 1;
        } */
        
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Website"))) {
            component.find('website').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Where_did_you_hear_about_us__c"))) {
            component.find('whereDidYou').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.EnquiryDetails.Title"))) {
            component.find('title').showHelpMessageIfInvalid();
            count = 1;
        }
         if($A.util.isEmpty(component.get("v.functionString"))) {
            component.find('function').showHelpMessageIfInvalid();
            count = 1;
        }
        if($A.util.isEmpty(component.get("v.EnquiryDetails.MobilePhone"))) {
            component.find('mobileid').showHelpMessageIfInvalid();
            count = 1;
        }
        if(count == 0) {
            component.set("v.showSpinner",true);
            var action = component.get("c.saveLeadDetailsApex");
            action.setParams({
                "leadObj" : JSON.stringify(component.get("v.EnquiryDetails")),
				  "functionString" : component.get("v.functionString")
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS') {
                    component.set("v.showSpinner",false);
                    if(response.getReturnValue().includes("SUCCESS")) {
                        component.set("v.showSuccess",true);
                    }
                    else {
                        component.set("v.errorMsg",response.getReturnValue());
                    }
                }	    
            });
            $A.enqueueAction(action);    
        }
    },
    
    isNumber : function(component,event){
        var charCode = (event.which) ? event.which : event.keyCode;
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        return true; 
    },
    OnChangeValueOfCountry : function(component, event, helper) {
        
        helper.onchangeofcountryvalue(component,event);
    },
    OnChangeValueOfState : function(component, event, helper) {
        
        helper.OnChangeValueOfStates(component,event);
        
    }
})