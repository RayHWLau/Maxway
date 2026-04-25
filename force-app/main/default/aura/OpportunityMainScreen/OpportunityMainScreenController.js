({
    doint : function(component, event, helper) {
        var action = component.get('c.opportunityMainScreen'); 
        action.setParams({
            'objectname' : 'Opportunity'
        });
        action.setCallback(this,function(response){
            var options = component.get('v.options');
            if (response.getState() === "SUCCESS"){
                if(response.getReturnValue() != null){
                    for(var record of response.getReturnValue()){
                        if($A.get("$Label.c.OpportunityRecordTypeForMaxwayAgent").includes(record.Name)){
                            var optionvalues = {};
                            optionvalues.label =  record.Name;
                            optionvalues.value = record.Id+';'+record.Name;
                            options.push(optionvalues);
                        }
                    }
                    component.set('v.options',options);
                    component.set('v.showspinner',false); 
                }
            }
        });
        $A.enqueueAction(action); 
    },
    handleChange: function (cmp, event) {
        var changeValue = event.getParam("value");
    },
    gotonextpage : function(component, event){
       if(component.get('v.value')){
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var separatenameandid = component.get('v.value').split(';');
                if($A.get("$Label.c.OppStudentCustomPage").includes(separatenameandid[1])){
                    var modalBody;
                    var modalfooter;
                    $A.createComponent("c:OpportunityScreen", {'recordtypename':separatenameandid[1],'recordtypeid':separatenameandid[0]},
                                        function(content, status) {
                                            if (status === "SUCCESS") {                                                
                                                component.find('overlayLib').showCustomModal({
                                                    body: content,
                                                    showCloseButton: true,
                                                    cssClass: "mymodal slds-modal_medium",
                                                    closeCallback: function() {
                                                        var listviews = response.getReturnValue();
                                                        var navEvent = $A.get("e.force:navigateToList");
                                                        navEvent.setParams({
                                                            "listViewId": listviews.Id,
                                                            "listViewName": null,
                                                            "scope": "Opportunity"
                                                        });
                                                        navEvent.fire();
                                                    }
                                                })
                                            }
                                        });   
                }
                else{
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Opportunity",
                        "recordTypeId" : separatenameandid[0]
                    });
                    createRecordEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
        }
        else{
            alert('Please choose recordtype');
        }
    },
    close : function(component, event){
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Opportunity"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }  
})