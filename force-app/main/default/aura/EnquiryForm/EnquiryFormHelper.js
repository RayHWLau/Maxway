({     
    getcountrycodewithstatecode :function(component,event){
        var action = component.get("c.getBranchPicklistvalues");
        action.setCallback(this,function(response) {
            // alert(JSON.stringify(response.getReturnValue().objResults));
            if (response.getState() === "SUCCESS"){
                
                component.set('v.salutationPicklist',response.getReturnValue().picklstSalutation);
                component.set("v.countryCodePicklist",response.getReturnValue().picklstCountryCode);
                component.set("v.whereDidYouPicklist",response.getReturnValue().picklstWhrDiduFind);
                var functions = response.getReturnValue().listFunction;
                var plValues = [];
                for (var i = 0; i < functions.length; i++) {
                    plValues.push({
                        label: functions[i],
                        value: functions[i]
                    });
                }
                component.set("v.functionPicklist", plValues);
                var result = response.getReturnValue().objResults;
                var citymap = response.getReturnValue().objcitydependent;
                //alert('result->'+JSON.stringify(citymap));
                var headOfficePicklist = [];
                var resultLen = result.length;
                headOfficePicklist.push({value:'',label:'--None--'});
                for(var key in result){
                    var statusOption = {
                        value:key,
                        label:key
                    }
                    headOfficePicklist.push(statusOption);
                }
                component.set('v.headOfficePicklist',headOfficePicklist);
                component.set('v.CountryWithStateMap',result);
                component.set('v.StateWithCityMap',citymap);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    onchangeofcountryvalue:function(component,event){
        var selectedValueOfStatus = component.get('v.EnquiryDetails.Head_Office_Country__c');
        var CountryWithStateMap = component.get('v.CountryWithStateMap');
        var headOfficeStatePicklist = [];
        if(selectedValueOfStatus){
            var action1List = CountryWithStateMap[selectedValueOfStatus];
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
        }else{
            component.set('v.EnquiryDetails.Head_Office_Country__c','');
            //component.set('v.EnquiryDetails.Head_Office_City__c','');
        }
        component.set('v.headOfficeStatePicklist',headOfficeStatePicklist);
  },
    
    OnChangeValueOfStates:function(component,event){
        var selectedValueOfAction1 = '';//commented on 21 april 2020component.get('v.EnquiryDetails.Head_Office_Province_State__c');
        var StateWithCityMap = component.get('v.StateWithCityMap');
        
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
        }
        component.set('v.headOfficeCityPicklist',headOfficeCityPicklist);
    }
    
    
})