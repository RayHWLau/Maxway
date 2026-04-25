({
    doinit : function(component, event, helper) {
        var action = component.get('c.taskcomponentOnLoad'); 
        action.setParams({
            'recodid' : component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            if (response.getState() === "SUCCESS"){
                if(response.getReturnValue() != null){
                    var opp = response.getReturnValue().opp;
                    component.set('v.oppvalue',opp.Name);
                    component.set('v.oppstage',opp.StageName);
                    var task = response.getReturnValue().tsk;
                    component.set('v.currentactivitydate',task.ActivityDate);
                    component.set('v.currentactivityfollowupsituation',task.Subject);
                    component.set('v.FollowUpSituationlist',response.getReturnValue().FollowUpSituation);
                    component.set('v.Closelostlist',response.getReturnValue().ClosedLostReason);
                    component.set('v.taskid',task.Id);
                }
            }
        });
        $A.enqueueAction(action);
    },
    save : function(component, event, helper) {
        var counter = 0 ;
        var  closedlostreasons ='';
        if($A.util.isEmpty(component.get('v.currentactivityfollowupremarks'))){
            component.set('v.error','Please fill Follow Up Remarks field');   
        }
        else{
           /* for(var i=0 ; i < component.find('closedlost').length ; i++){
                if(!$A.util.isEmpty(component.find('closedlost')[i].get('v.value'))){
                    counter++; 
                    closedlostreasons = component.find('closedlost')[i].get('v.value');
                } 
            }*/
            if(counter == 2){
                component.set('v.error','Please fill either Closed Lost Reason or Closed Lost Reason Others');
            }
            if(counter == 1){
                if(!$A.util.isEmpty(component.get('v.nextactivitydate')) || !$A.util.isEmpty(component.get('v.nextactivityfollowupsituation')) || !$A.util.isEmpty(component.get('v.onholdreason'))){
                    component.set('v.error','Please remove value from Next Follow up section');   
                }
                else{
                    component.set('v.error',null);
                    var action = component.get('c.savetask');
                    action.setParams({
                        'duedate' :null,
                        'subject' : null,
                        'closelostreason' : closedlostreasons,
                        'followupremarks' : null,
                        'onholdreason' : null,
                        'taskid' :component.get('v.taskid'),
                        'oppstagename':component.get('v.oppstage')
                    });
                    action.setCallback(this,function(response){
                        if (response.getState() === "SUCCESS"){
                            var returnvalue = response.getReturnValue();
                            if(returnvalue.str.includes('success')){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "message": "Opportunity has been Closed Lost successfully.",
                                    "type":"success"
                                });
                                toastEvent.fire();
                                $A.get('e.force:refreshView').fire();
                                if(returnvalue.tsk != null){
                                    component.set('v.currentactivityfollowupsituation',returnvalue.tsk.Subject);
                                    component.set('v.currentactivitydate',returnvalue.tsk.ActivityDate);
                                    component.set('v.taskid',returnvalue.tsk.Id);
                                    
                                }
                                else{
                                    component.set('v.currentactivityfollowupsituation',null);
                                    component.set('v.currentactivitydate',null);
                                    component.set('v.taskid',null);    
                                }
                                
                            }
                            else{
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Error!",
                                    "message": returnvalue.str,
                                    "type":"error",
                                    "mode":"sticky"
                                });
                                toastEvent.fire(); 
                                $A.get('e.force:refreshView').fire();
                            }
                            component.set('v.currentactivityfollowupremarks',null);
                            component.set('v.nextactivityfollowupsituation',null);
                            component.set('v.onholdreason',null);
                            component.set('v.nextactivitydate',null);
                        /*    for(var i=0 ; i < component.find('closedlost').length ; i++){
                                component.find('closedlost')[i].set('v.value',null); 
                            }*/
                        }
                    });
                    $A.enqueueAction(action);    
                }
            }
            if(counter == 0){
                if(($A.util.isEmpty(component.get('v.nextactivitydate')) || $A.util.isEmpty(component.get('v.nextactivityfollowupsituation')) || $A.util.isEmpty(component.get('v.currentactivityfollowupremarks'))) && (component.get('v.oppstage') === 'Prospective' || component.get('v.oppstage') === 'On Hold') ){
                    component.set('v.error','Please fill  Next Follow up section');   
                }  
                else{
                 /*   if((component.get('v.nextactivityfollowupsituation')==='Too Early To Go Abroad')){
                        if($A.util.isEmpty(component.get('v.onholdreason'))){
                            component.set('v.error','Please fill On Hold Reason');   
                        }
                        else{*/
                            component.set('v.error',null);
                            var action = component.get('c.savetask');
                            action.setParams({
                                'duedate' : component.get('v.nextactivitydate'),
                                'subject' : component.get('v.nextactivityfollowupsituation'),
                                'closelostreason' : null,
                                'followupremarks' : component.get('v.currentactivityfollowupremarks'),
                                'onholdreason' : component.get('v.onholdreason'),
                                'taskid' : component.get('v.taskid'),
                                'oppstagename':component.get('v.oppstage')
                            });
                            action.setCallback(this,function(response){
                                if (response.getState() === "SUCCESS"){
                                    var returnvalue = response.getReturnValue();
                                    if(returnvalue.str.includes('success')){
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "Success!",
                                            "message": "Task has been created sucessfully.",
                                            "type":"success"
                                        });
                                        toastEvent.fire();
                                        
                                        if(returnvalue.tsk != null){
                                            component.set('v.currentactivityfollowupsituation',returnvalue.tsk.Subject);
                                            component.set('v.currentactivitydate',returnvalue.tsk.ActivityDate);
                                            component.set('v.taskid',returnvalue.tsk.Id);
                                            
                                        }
                                        else{
                                            component.set('v.currentactivityfollowupsituation',null);
                                            component.set('v.currentactivitydate',null);
                                            component.set('v.taskid',null);    
                                        }
                                        
                                    }
                                    else{
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "Error!",
                                            "message": returnvalue.str,
                                            "type":"error",
                                            "mode":"sticky"
                                        });
                                        toastEvent.fire(); 
                                        $A.get('e.force:refreshView').fire();
                                    }
                                    component.set('v.currentactivityfollowupremarks',null);
                                    component.set('v.nextactivityfollowupsituation',null);
                                    component.set('v.onholdreason',null);
                                    component.set('v.nextactivitydate',null);
                                  /*  for(var i=0 ; i < component.find('closedlost').length ; i++){
                                        component.find('closedlost')[i].set('v.value',null); 
                                    }*/
                                }
                            });
                            $A.enqueueAction(action);   
                      //  }
                  //  }
                  /*  else{
                        if(!$A.util.isEmpty(component.get('v.onholdreason'))){
                            component.set('v.error','Please remove value from  On Hold Reason');   
                        }
                        else{
                            component.set('v.error',null);
                            var action = component.get('c.savetask');
                            action.setParams({
                                'duedate' : component.get('v.nextactivitydate'),
                                'subject' : component.get('v.nextactivityfollowupsituation'),
                                'closelostreason' : null,
                                'followupremarks' : component.get('v.currentactivityfollowupremarks'),
                                'onholdreason' :null,
                                'taskid' :component.get('v.taskid'),
                                'oppstagename':component.get('v.oppstage')
                            });
                            action.setCallback(this,function(response){
                                if (response.getState() === "SUCCESS"){
                                    
                                    var returnvalue = response.getReturnValue();
                                    
                                    if(returnvalue.str.includes('success')){
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "Success!",
                                            "message": "Task has been created sucessfully.",
                                            "type":"success"
                                        });
                                        toastEvent.fire();
                                        if(returnvalue.tsk != null){
                                            component.set('v.currentactivityfollowupsituation',returnvalue.tsk.Subject);
                                            component.set('v.currentactivitydate',returnvalue.tsk.ActivityDate);
                                            component.set('v.taskid',returnvalue.tsk.Id);
                                            
                                        }
                                        else{
                                            component.set('v.currentactivityfollowupsituation',null);
                                            component.set('v.currentactivitydate',null);
                                            component.set('v.taskid',null);    
                                        }
                                        
                                    }
                                    else{
                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            "title": "Error!",
                                            "message": returnvalue.str,
                                            "type":"error",
                                            "mode":"sticky"
                                        });
                                        toastEvent.fire(); 
                                        $A.get('e.force:refreshView').fire();
                                    }
                                    component.set('v.currentactivityfollowupremarks',null);
                                    component.set('v.nextactivityfollowupsituation',null);
                                    component.set('v.onholdreason',null);
                                    component.set('v.nextactivitydate',null);
                                    for(var i=0 ; i < component.find('closedlost').length ; i++){
                                        component.find('closedlost')[i].set('v.value',null); 
                                    }
                                }
                            });
                            $A.enqueueAction(action);
                        }
                    }*/
                }
            }
        }
    },
    cancel :function(component,event){
        component.set('v.error',null);
        component.set('v.currentactivityfollowupremarks',null);
        component.set('v.nextactivityfollowupsituation',null);
        component.set('v.onholdreason',null);
        component.set('v.nextactivitydate',null);
    /*    for(var i=0 ; i < component.find('closedlost').length ; i++){
            component.find('closedlost')[i].set('v.value',''); 
        }*/
    }
})