({
	 getList : function(component, event, pageNumber,pageSize) {
        // pagination ....
        // Pagination.....
        var recordid = component.get('v.accountId');
        var action = component.get('c.schoolwithsamecountry');
        action.setParams({
            'contryname': component.get('v.contryname'),
            'agentid': recordid,
            'pageNumber':pageNumber,
            'pageSize':pageSize
        });
        action.setCallback(this,function(response){
            
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue() != null){
                    console.log('Pagination');
                        console.log(response.getReturnValue());
                    // Pagination
                    var resultData = response.getReturnValue();
                    component.set('v.accountwrap',resultData.accWrp);
                    component.set('v.accountwrapmaster',resultData.accWrp);
                    component.set("v.ContactList", resultData.contactList);
                    component.set("v.PageNumber", resultData.pageNumber);
                    component.set("v.TotalRecords", resultData.totalRecords);
                    component.set("v.RecordStart", resultData.recordStart);
                    component.set("v.RecordEnd", resultData.recordEnd);
                    component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
                    // Pagination
                    var accids='';
                    for(var str of resultData.accWrp){
                        if(str.isoptout==true){
                            accids = accids + str.sch.Id +';';   
                        }
                        if(component.get("v.setAccId") != '' && component.get("v.setAccId") != undefined && component.get("v.setAccId").includes(str.sch.Id)){
                           str.isoptout=true;
                        }
                    }
                    var evt = $A.get("e.c:AccountList");
                    evt.setParams({ "accountids": accids});
                    evt.fire();
                } 
            }
        });
        $A.enqueueAction(action);
    },
     
    saveData:function(component,event,helper,accids,delCheck, pageNumber, pageSize){
        if(accids !='' || delCheck != ''){
                var action = component.get('c.saveoptoutschoolPage');
                action.setParams({
                    'agentid': component.get('v.accountId'),
                    'schoolids' : accids,
                    'contrynames' : component.get('v.contryname'),
                    'delCheck':delCheck
                });
                
                action.setCallback(this,function(response){
                    
                    if(response.getState() === "SUCCESS") {
                        if(response.getReturnValue().includes('sucess')){
                            if((accids !='' && accids != undefined) && (delCheck == '' || delCheck == undefined)){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "message": "The record has been inserted successfully.",
                                    "type":'success'
                                });
                                toastEvent.fire();    
                            }
                            if((accids !='' && accids != undefined) && (delCheck != '' && delCheck != undefined)){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "message": "The record has been inserted successfully.",
                                    "type":'success'
                                });
                                toastEvent.fire();    
                            }
                            if((delCheck != '' && delCheck != undefined) && ((accids =='' || accids == undefined) )){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "message": "The record has been removed successfully.",
                                    "type":'error'
                                });
                                toastEvent.fire();    
                            }
                            helper.getList(component,event, pageNumber, pageSize);
                            /*var evt = $A.get("e.c:StatusAppEvent");
                            evt.setParams({ "Status": 'success;'+component.get('v.contryname')});
                            evt.fire(); */  
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
                           /* var evt = $A.get("e.c:StatusAppEvent");
                            evt.setParams({ "Status": 'error;'+component.get('v.contryname')});
                            evt.fire(); */
                        }  
                    }
                });
                $A.enqueueAction(action);
            }
    }
})