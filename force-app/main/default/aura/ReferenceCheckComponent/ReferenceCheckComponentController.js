({
	doInit : function(component, event, helper) {
		component.set("v.showSpinner",true);
        var action = component.get("c.referenceCheckFunction");
        action.setParams({
            "oppId" : component.get("v.oppId"),
            "buttonLabel" : component.get("v.buttonLabel")
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS") {
                component.set("v.message",response.getReturnValue());
            }  
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	}
})