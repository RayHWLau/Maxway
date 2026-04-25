({
    doInit : function(component,event,helper){
    var action = component.get("c.refreeemailpopulate");
        component.set("v.showSpinner",true); 
    action.setParams({
        "oppId" : component.get("v.recordId") 
    });
    action.setCallback(this,function(response){
        if(response.getState() === 'SUCCESS'){
           // $A.get('e.force:refreshView').fire();
            if(response.getReturnValue()!= null){
              if(response.getReturnValue().includes('closedlost'))
                
                  component.set('v.msg',"Opportunity is Closed Lost.");
                
                //aded on 8 may as validation
                else if( response.getReturnValue().includes('Only Maxway admin can verify reference')){
                  
                    var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "ERROR!",
                                    "message": "Only Maxway admin can verify reference",
                                    "type" : "error"
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();
                    
                }
                else{
                   component.set('v.msg',"An email will go to Refree email "+response.getReturnValue()+ "?");  
                }
            }
            else{
                component.set('v.msg',"Please Fill Refree Email");  
                component.set('v.conformation',false);
            }
            
        }
        component.set("v.showSpinner",false);
        
    });
    $A.enqueueAction(action);
    },
    
    ok : function(component, event, helper) {
     
        component.set('v.conformation',false); 
        component.set("v.showSpinner",true); 
        var action=component.get("c.agentVerification");
        action.setParams({
            "oppId":component.get("v.recordId")
        });
        
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                if(response.getReturnValue()=='SUCCESS'){ 
                     component.set('v.msg',"Reference check mail has been sent to Referee email successfully");
                   // $A.get("e.force:closeQuickAction").fire();                    
                 //   $A.get('e.force:refreshView').fire();                    
                } 
                else if(response.getReturnValue() == 'submittedDate'){
                     component.set('v.msg',"Reference Verification  is already done.");
                 /*   var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": "Reference Verification  is already done.",
                        "type" : "error"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire(); */
                }
                    else if(response.getReturnValue() == 'referencecheck'){
                        component.set('v.msg',"For Reference Verification, Reference Verification mail is already sent.");
                   /*     var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "ERROR!",
                            "message" : "For Reference Verification reference verification mail is already sent.",
                            "type" : "error" 
                        });
                        
                        toastEvent.fire();
                        $A.get("e.force:closeQuickAction").fire(); */
                    }
                        else if(response.getReturnValue() == 'stage'){
                             component.set('v.msg',"For Reference Verification Stage should not be sales won or closed lost.");
                          /*  var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "ERROR!",
                                "message": "For Reference Verification Stage should not be sales won or closed lost.",
                                "type" : "error"
                            });
                            toastEvent.fire();
                            $A.get("e.force:closeQuickAction").fire(); */
                        } 
                            else if(response.getReturnValue() == 'refreeemail'){
                                 component.set('v.msg',"Refree email should not be blank.");
                           /*     var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "ERROR!",
                                    "message": "Refree email should not be blank.",
                                    "type" : "error"
                                });
                                toastEvent.fire();
                                $A.get("e.force:closeQuickAction").fire();*/
                            } 
                
            }
          component.set("v.showSpinner",false);            
        });
        $A.enqueueAction(action);
    },
    closeaction : function(component,event){
      $A.get("e.force:closeQuickAction").fire();   
    }
})