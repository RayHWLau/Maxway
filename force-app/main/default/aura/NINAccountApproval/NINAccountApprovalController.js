({
    doInit : function(component, event, helper) {
        
        component.set("v.showSpinner",true); 
        var action=component.get("c.returnprice");
        action.setParams({
            "objectid":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){
                if(response.getReturnValue().msg == null){
                    component.set('v.msg',"User cannot send approval.");  
                    component.set('v.conformation',false);    
                }
                
                else if(response.getReturnValue().msg=='Either Account has been already apprroved or pending for approval'){
                    component.set('v.msg',response.getReturnValue().msg);
                    component.set('v.conformation',false); 
                } 
                    else if(response.getReturnValue().msg=='Cannot send school for approval'){
                        
                        component.set('v.msg',response.getReturnValue().msg);
                        component.set('v.conformation',false);    
                    } 
                        else if(response.getReturnValue().msg=='Please upload required document first'){
                            
                            component.set('v.msg',response.getReturnValue().msg);
                            component.set('v.conformation',false);    
                        } 
                            else if(response.getReturnValue().msg=='Cannot submit this application for approval, as there is another application with status Commission Paid/Commission Received/Arrived within same opportunity.'){
                                
                                component.set('v.msg',response.getReturnValue().msg);
                                component.set('v.conformation',false);    
                            } 
                                else if(response.getReturnValue().msg=='No Contract Item Found'){ 
                                    component.set('v.msg',"No money will be deducted from your prepaid balance.");
                                    
                                }
                
                                    else{
                                        
                                        var price = response.getReturnValue().msg;//.msg.split('.')
                                        
                                        component.set('v.msg','If this record is approved, '+response.getReturnValue().schoolcurrency+' '+price+' will get deducted from your prepaid balance.');
                                        
                                    }
                
            }
            component.set("v.showSpinner",false);            
        });
        $A.enqueueAction(action);
    },
    submit : function(component,event){
        //   alert('test'+component.get("v.recordId"));
        component.set('v.conformation',false); 
        component.set("v.showSpinner",true); 
        var action=component.get("c.lightningapproval");
        action.setParams({
            "accid":component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState()=='SUCCESS'){ 
                if(response.getReturnValue()=='SUCCESS'){ 
                    component.set('v.msg',"Approval Request has been sent successfully.");
                    
                } 
                else{
                    component.set('v.msg',response.getReturnValue());
                    
                }
                
                
            }
            component.set("v.showSpinner",false);            
        });
        $A.enqueueAction(action);
    },
    closeaction : function(component,event){
        //     alert('test'+component.get("v.recordId"));
        $A.get("e.force:closeQuickAction").fire(); 
        window.location.reload();
    }
})