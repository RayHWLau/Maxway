({  doInit : function(component,event,helper){
    var action = component.get("c.agentemailpopulate");
    action.setParams({
        "oppId" : component.get("v.recordId") 
    });
    action.setCallback(this,function(response){
        if(response.getState() === 'SUCCESS'){
            if(response.getReturnValue()!= null){
                component.set('v.msg',"One email will go to "+response.getReturnValue()+ "?");}
            else{
                component.set('v.msg',"Fill in Email for quote Collect and Name for quote Collect");  
                component.set('v.conformation',false);
            }   
        }  
    });
    $A.enqueueAction(action);
    },
  
   ok : function(component, event, helper) {
      component.set('v.conformation',false);   
        component.set("v.showSpinner",true); 
      var action = component.get("c.checkSentAgentSignupQuickAction");
      action.setParams({
          "oppId" : component.get("v.recordId") 
      });
      action.setCallback(this,function(response){
          if(response.getState() === 'SUCCESS'){
              if(response.getReturnValue() == 'SUCCESS'){
                  component.set('v.msg',"Collect quotation variable form has been sent successfully");
                  /*       var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "title": "SUCCESS!",
                        "message": "Collect quotation variable form has been sent successfully",
                        "type" : "SUCCESS"
                    });
                    toastEvent.fire(); */
                  //    $A.get("e.force:closeQuickAction").fire();
                  //    $A.get('e.force:refreshView').fire();                    
              }
              else if(response.getReturnValue() == 'submittedDate'){
                  component.set('v.msg',"Collect Quotation Form Submitted Date should be blank.");
                  /*  var toastEvent = $A.get("e.force:showToast");
                   
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "title": "ERROR!",
                        "message": "Collect Quotation Form Submitted Date should be blank.",
                        "type" : "error"
                    });
                    toastEvent.fire();*/
                    //    $A.get("e.force:closeQuickAction").fire();
                }
                    else if(response.getReturnValue() == 'stage'){
                        component.set('v.msg',"For Collect Quotation Variable Stage should not be sales won or closed lost.");
                        /*  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "title": "ERROR!",
                        "message": "For Collect Quotation Variable Stage should not be sales won or closed lost",
                        "type" : "error"
                    });
                    toastEvent.fire();*/
                        //    $A.get("e.force:closeQuickAction").fire();
                    }  
                        else if(response.getReturnValue() == 'Alreadysent'){
                            component.set('v.msg',"Collect quotation variable form has been sent already.");
                            /*  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "mode": 'sticky',
                        "title": "ERROR!",
                        "message": "Collect quotation variable form has been sent already.",
                        "type" : "error"
                    });
                    toastEvent.fire();*/
                        //    $A.get("e.force:closeQuickAction").fire();   
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