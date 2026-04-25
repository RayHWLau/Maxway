({
    setaccountids : function(component, event, helper) {
        component.set('v.accids',event.getParam("accountids"));  
    },
    setaccountidsPg : function(component, event, helper) {
        component.set('v.delids',event.getParam("accountidsPg"));  
    },
    handelsearchvalue : function(component, event, helper) {
        component.set('v.hassearchvalue',event.getParam("searchvalue"));  
    },
    save : function(component, event, helper) {
        
        /*if(component.get('v.hassearchvalue') == true){
            alert('Remove value from Search');
       
        }
        else{  */ 
            if( (component.get('v.accids')!='' && component.get('v.accids')!=undefined) || (component.get('v.delids') !='' && component.get('v.delids') != undefined)){
                var action = component.get('c.saveoptoutschoolPage');
                action.setParams({
                    'agentid': component.get('v.recordId'),
                    'schoolids' : component.get('v.accids'),
                    'contrynames' : component.get('v.countryname'),
                    'delCheck':component.get('v.delids')
                });
                
                action.setCallback(this,function(response){
                    
                    if(response.getState() === "SUCCESS") {
                        if(response.getReturnValue().includes('sucess')){
                            component.set('v.accids','');
                            component.set('v.delids','');
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "The record has been inserted successfully.",
                                "type":'success'
                            });
                            toastEvent.fire();  
                            var evt = $A.get("e.c:StatusAppEvent");
                            evt.setParams({ "Status": 'success;'+component.get('v.contryname')});
                            evt.fire();   
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
                            var evt = $A.get("e.c:StatusAppEvent");
                            evt.setParams({ "Status": 'error;'+component.get('v.contryname')});
                            evt.fire(); 
                        }  
                    }
                });
                $A.enqueueAction(action);
            }
            else{
                alert('No Opt Out School Added');
                component.find('overlayLib').notifyClose();   
            }     
        //}
        
    },
    closemodal :function(component, event, helper) {
        component.find('overlayLib').notifyClose();
        
    },
    handleCancel :function(component, event, helper) {
        var evt = $A.get("e.c:StatusAppEvent");
        evt.setParams({ "Status": 'closemodal'});
        evt.fire();   
    }
})