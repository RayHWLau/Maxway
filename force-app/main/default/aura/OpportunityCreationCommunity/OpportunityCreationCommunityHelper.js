({
    closecomponenthelper : function(component,event) {
           if(component.get('v.oppId') == null){
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
                "recordId": component.get('v.oppId'),
                "slideDevName": "related"
            });
            navEvt.fire();
        }
    },
    
    getLoginUser:function(component,event){
        var action= component.get("c.getUser");
        action.setParams({
            'userId':$A.get( "$SObjectType.CurrentUser.Id" ) 
        });
        action.setCallback(this,function(resp){
            if(resp.getState() === "SUCCESS"){
                component.set("v.account.Student_s_Agent_Code__c",resp.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
    
})