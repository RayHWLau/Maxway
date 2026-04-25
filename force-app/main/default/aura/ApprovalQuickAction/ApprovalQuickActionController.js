({
    doInit : function(component, event, helper) {
        component.set('v.conformation',false); 
        component.set("v.showSpinner",true); 
        var action=component.get("c.lightningapproval");
        action.setParams({
            "oppId":component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                if(response.getReturnValue()=='SUCCESS'){ 
                     component.set('v.msg',"Approval has been sent successfully.");
                   // $A.get("e.force:closeQuickAction").fire();                    
                 //   $A.get('e.force:refreshView').fire();                    
                } 
                else{
                     component.set('v.msg',response.getReturnValue());
                 /*   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": "Reference Verification  is already done.",
                        "type" : "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire(); */
                }
                    
                
            }
          component.set("v.showSpinner",false);            
        });
        $A.enqueueAction(action);
    },
    closeaction : function(component,event){
      $A.get("e.force:closeQuickAction").fire(); 
        window.location.reload();
    }
})