({
    donint : function(component, event, helper) {
        // pagination ....
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 100;
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
                     var resultData = response.getReturnValue();
                    component.set('v.accountwrap',resultData.accWrp);
                    component.set('v.accountwrapmaster',resultData.accWrp);
                   component.set("v.isPage",true);
                    component.set("v.ContactList", resultData.contactList);
                    component.set("v.PageNumber", resultData.pageNumber);
                    component.set("v.TotalRecords", resultData.totalRecords);
                    component.set("v.RecordStart", resultData.recordStart);
                    component.set("v.RecordEnd", resultData.recordEnd);
                    component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
                   
                   
                } 
            }
        });
        $A.enqueueAction(action);
    },
    
    // Pagination
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 100;
        pageNumber++;
         helper.saveData(component,event,helper,component.get("v.setAccId"),component.get("v.delAccId"), pageNumber, pageSize);
        
    },
     
    handlePrev: function(component, event, helper) {
         
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = 100;
        pageNumber--;
        helper.saveData(component,event,helper,component.get("v.setAccId"),component.get("v.delAccId"), pageNumber, pageSize);
        //helper.getList(component,event);
    },
    // Pagination
    
    handleKeyUp: function (component, evt) {
        component.set('v.nocountryfound',false);
        var isEnterKey = evt.keyCode === 13;
        var queryTerm = component.find('enter-search').get('v.value');
        var schoollist = component.get('v.accountwrap');
        var searchschool=[];
        
        if (isEnterKey) {
            
            if(!$A.util.isEmpty(queryTerm)){
                if(queryTerm.length >=3){
                    var pageNumber = component.get("v.PageNumber");  
                    var pageSize = 100;
                    // Pagination.....
                    var recordid = component.get('v.accountId');
                    var action = component.get('c.getschoolPage');
                    action.setParams({
                        'contryname': component.get('v.contryname'),
                        'agentid': recordid,
                        'pageNumber':pageNumber,
                        'pageSize':pageSize,
                        'searchVal':queryTerm
                    });
                    action.setCallback(this,function(response){
                        
                        if(response.getState() === "SUCCESS") {
                            if(response.getReturnValue() != null){
                                var resultData = response.getReturnValue();
                                if(resultData.accWrp.length >0){
                                   component.set('v.accountwrap',resultData.accWrp);
                                    component.set("v.isPage",false);
                                }else{
                                    component.set("v.isPage",true);
                                }
                                
                                
                                component.set("v.ContactList", resultData.contactList);
                                component.set("v.PageNumber", resultData.pageNumber);
                                component.set("v.TotalRecords", resultData.totalRecords);
                                component.set("v.RecordStart", resultData.recordStart);
                                component.set("v.RecordEnd", resultData.recordEnd);
                                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
                                
                                
                            } 
                        }
                    });
                    $A.enqueueAction(action);   
                    var evt = $A.get("e.c:SearchvalueEvent");
                    evt.setParams({ "searchvalue": true});
                    evt.fire(); 
                }else{
                    alert('please input atleast 3 character');
                }
                
            }
            else{
                component.set('v.accountwrap',component.get('v.accountwrapmaster')); 
                
                var evt = $A.get("e.c:SearchvalueEvent");
                evt.setParams({ "searchvalue": false});
                evt.fire(); 
            }
        }
        
    },
    rerenderlist : function(component,event){
        var searchvalue  = event.getSource().get("v.value");
        if($A.util.isEmpty(searchvalue)){
            component.set('v.noschoolfound',false);
            component.set('v.accountwrap',component.get('v.accountwrapmaster')); 
            
            var evt = $A.get("e.c:SearchvalueEvent");
            evt.setParams({ "searchvalue": false});
            evt.fire(); 
        }
    },
    checkedaccounts : function(component,event,helper){
        var accids='';
        var newCheck='';
        if(event.getSource().get("v.checked")){
            if(!newCheck.includes(event.getSource().get("v.label"))){
                if(component.get("v.setAccId") != '' && component.get("v.setAccId") !=undefined){
                    newCheck= component.get("v.setAccId")+event.getSource().get("v.label")+';'; 
                }else{
                    newCheck=event.getSource().get("v.label")+';';
                }
                
            }
          
        }
        var delCheck='';
        if(event.getSource().get("v.checked")==false){
            if(!newCheck.includes(event.getSource().get("v.label"))){
                if(component.get("v.delAccId") != '' && component.get("v.delAccId") !=undefined){
                    delCheck= component.get("v.delAccId")+event.getSource().get("v.label")+';'; 
                }else{
                    delCheck=event.getSource().get("v.label")+';';
                }
                
            }
          
        }
        if(delCheck !=''){
            var evt = $A.get("e.c:AccountListPage");
            evt.setParams({ "accountidsPg": delCheck});
            evt.fire();
        }
        component.set("v.delAccId",delCheck);
        var accountlist = component.find('checked');
        if( !Array.isArray(accountlist)){
            if(accountlist.get('v.checked')==true){
                accountlist.get('v.label');
                accids = accids + accountlist.get('v.label') +';';
            }    
            
            console.log('166',component.get("v.setAccId"));
        }
        else{  
            for(var i =0 ;i<accountlist.length ; i++){
                var checkboxvalue = component.find('checked')[i];
                if(checkboxvalue.get('v.checked')==true){
                    checkboxvalue.get('v.label');
                    accids = accids + checkboxvalue.get('v.label') +';';
                }       
            }
        }
        component.set("v.setAccId",newCheck);
       /* if(newCheck != ''){
            accids =accids+ component.get("v.setAccId");
        }*/
        var evt = $A.get("e.c:AccountList");
        evt.setParams({ "accountids": newCheck});
        evt.fire();
    },
    closemodal : function(component,event,helper){
        component.find('overlayLib').notifyClose();
    }
})