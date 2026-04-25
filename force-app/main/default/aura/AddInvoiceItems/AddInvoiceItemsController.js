({
    doint : function(component, event, helper) {
        var action = component.get('c.getarrivedapplication');
        action.setParams({
            'recordid': component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            
            if(response.getState() === "SUCCESS") {
                component.set('v.spinneristrue',false);
                if(response.getReturnValue() != null){
                    
                    component.set('v.applicationlist',response.getReturnValue());
                    
                    if( response.getReturnValue().length > 0 )
                    component.set('v.curency',response.getReturnValue()[0].curency);
                    
                } 
            }
        });
        $A.enqueueAction(action);
    },
    savecheck : function(component,event,helper){
        var appids=[];
        var applist = component.find('checked');
        if( !Array.isArray(applist)){
            if(applist.get('v.checked')==true){
                appids.push(applist.get('v.label'));
        
            }    
        }
        else{  
            for(var i =0 ;i<applist.length ; i++){
                var checkboxvalue = component.find('checked')[i];
              if(checkboxvalue.get('v.checked')==true){
                    checkboxvalue.get('v.label');
                    appids.push(checkboxvalue.get('v.label'));
        
                }       
            }
        }
        
        var appidwithamount=[];
        var appwithamount = component.find('amount');
        if( !Array.isArray(appwithamount)){
            if(appwithamount.get('v.value')!=null){
                
                if( JSON.stringify(appwithamount.get('v.accesskey')).length > 2 ){
                        
                        appidwithamount.push(appwithamount.get('v.label')+';'+appwithamount.get('v.value') + ';' + appwithamount.get('v.accesskey'));
                }else{
                    appidwithamount.push(appwithamount.get('v.label')+';'+appwithamount.get('v.value'));
                }
                
            }    
        }
        else{  
            for(var i =0 ;i<appwithamount.length ; i++){
                var checkboxvalue = component.find('amount')[i];
                if(checkboxvalue.get('v.value')!=null){
                		
                    if( JSON.stringify(checkboxvalue.get('v.accesskey')).length > 2 ){
                        
                        appidwithamount.push(checkboxvalue.get('v.label')+';'+checkboxvalue.get('v.value')+';'+checkboxvalue.get('v.accesskey'));
                    }else{
                    
                        appidwithamount.push(checkboxvalue.get('v.label')+';'+checkboxvalue.get('v.value'));    
                    }
                    
                }       
            }
        }
        
        if (appids.length >0){
            component.set('v.spinneristrue',true);
            var action = component.get('c.saveinvoicelineitem');
            action.setParams({
                'applicationids' : appids,
                'amountwithid' : appidwithamount,
                'invoice' :component.get('v.recordId')
            });
            action.setCallback(this,function(response){
                if(response.getState() === "SUCCESS") { 
                    if(response.getReturnValue().includes('SUCCESS')){ 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'Application Added Successfully',
                            "type" : "success"
                        });
                        toastEvent.fire();
                        component.set('v.spinneristrue',false);
                        $A.get("e.force:closeQuickAction").fire();
                    } 
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "error!",
                            "message": response.getReturnValue(),
                            "type" : "error"
                        });
                        toastEvent.fire();
                        component.set('v.spinneristrue',false);
                       // $A.get("e.force:closeQuickAction").fire();
                    }
                }
                else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                            
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set('v.finalSubmitCheck',true);
        }
        
        
    },
     
    isNumber : function(component,event){
        var charCode = (event.which) ? event.which : event.keyCode;
        
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        return true; 
    },
    
     cancelmodel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    returnBack : function(component, event, helper) {
        component.set('v.finalSubmitCheck',false);
    }
})