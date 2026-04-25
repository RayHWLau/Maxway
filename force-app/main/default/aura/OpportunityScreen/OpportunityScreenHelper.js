({
    closecomponenthelper : function(component,event) {
           if(component.get('v.oppId') == null){
               console.log('If')
               console.log(component.get("c.getListViews"))
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
            console.log('else')
            console.log('-->' + component.get('v.oppId'))
            /* Commented on 18 may 2020 as sometimes it is giving error Page Url DOesnot exist , so just refreshing it
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get('v.oppId'),
                "slideDevName": "related"
            });
            navEvt.fire();*/
            
            
            window.location.reload(false); 

        }
    }
    
})