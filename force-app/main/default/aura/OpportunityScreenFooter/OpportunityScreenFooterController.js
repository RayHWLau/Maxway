({
    handlesave : function(component, event, helper) {
        component.set('v.opp',event.getParam("opportunity"));
        component.set('v.acc',event.getParam("account"));  
        component.set('v.con1',event.getParam("Contact1"));  
        component.set('v.con2',event.getParam("Contact2"));
        component.set('v.oppval',event.getParam("Oppfilter"));
        component.set('v.accval',event.getParam("accfilter"));
        component.set('v.con1val',event.getParam("con1filter"));
        component.set('v.con2val',event.getParam("con2filter"));
        component.set('v.acccustomval',event.getParam("accvalidationfilter"));
        component.set('v.savebuttonshow',event.getParam("showbutton"));
        
    },
    save : function(component, event, helper) {
        if(!$A.util.isEmpty(component.get('v.oppval'))){
            alert('Please Fill following fields of Opportunity '+component.get('v.oppval'));
        }
        else if (!$A.util.isEmpty(component.get('v.accval'))){
            alert('Please Fill following fields of Account '+component.get('v.accval'));   
        }
            else if (!$A.util.isEmpty(component.get('v.acccustomval'))){
                alert(component.get('v.acccustomval'));
            }
            else if (!$A.util.isEmpty(component.get('v.con1val'))){
                alert('Please Fill following fields of Parent 1 '+component.get('v.con1val'));   
            }
                else if (!$A.util.isEmpty(component.get('v.con2val'))){
                    alert('Please Fill following fields of Parent 2 '+component.get('v.con2val'));   
                }
                    else{
                        var action = component.get('c.saveAccountOppConApex');
                        action.setParams({
                            'AccObj': JSON.stringify(component.get('v.acc')),
                            'part1Obj' : JSON.stringify(component.get('v.con1')),
                            'part2Obj' : JSON.stringify(component.get('v.con2')),
                            'OppObj' : JSON.stringify(component.get('v.opp'))
                        });
                        
                        action.setCallback(this,function(response){
                            
                            if(response.getState() === "SUCCESS") {
                                if(response.getReturnValue().includes('success')){
                                    
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Success!",
                                        "message": "The record has been inserted successfully.",
                                        "type":'success'
                                    });
                                    toastEvent.fire(); 
                                    if(!$A.util.isEmpty(component.get('v.opp.Id'))){
                                        var evt = $A.get("e.c:StatusAppEvent");
                                        evt.setParams({ "Status": 'closeEdit'});
                                        evt.fire();  
                                    }
                                    else{
                                        var evt = $A.get("e.c:StatusAppEvent");
                                        evt.setParams({ "Status": 'close'});
                                        evt.fire();   
                                    }
                                    
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
                                    if(!$A.util.isEmpty(component.get('v.opp.Id'))){
                                        var evt = $A.get("e.c:StatusAppEvent");
                                        evt.setParams({ "Status": 'closeEdit'});
                                        evt.fire();  
                                    }
                                    else{
                                        var evt = $A.get("e.c:StatusAppEvent");
                                        evt.setParams({ "Status": 'close'});
                                        evt.fire();   
                                    }
                                }  
                            }
                        });
                        $A.enqueueAction(action);
                    }
    },
    
    handleCancel :function(component, event, helper) {
        if(!$A.util.isEmpty(component.get('v.opp.Id'))){
            var evt = $A.get("e.c:StatusAppEvent");
            evt.setParams({ "Status": 'closeEdit'});
            evt.fire();  
        }
        else{
            var evt = $A.get("e.c:StatusAppEvent");
            evt.setParams({ "Status": 'close'});
            evt.fire();   
        }  
    },
    closemodal :function(component, event, helper) {
        if(event.getParam("Status") == 'close'){
            var action = component.get("c.getListViews");
            action.setCallback(this, function(response){
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Opportunity"
                });
                navEvent.fire();
            });
            $A.enqueueAction(action);
        }
        
        else{
          
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.opp.Id'),
                "slideDevName": "related"
            });
            navEvt.fire();
        }
    }
})