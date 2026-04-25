({
    doinit : function(component, event, helper) {
        var action = component.get('c.docuploadmethod');
        action.setParams({
            'applicationid': component.get('v.recordId')  
        });
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                component.set('v.ismaxway',response.getReturnValue().ismaxway);
                if(response.getReturnValue().documentuploadlist != null){
                    component.set('v.existingdocList',response.getReturnValue().documentuploadlist);
                }
                if(response.getReturnValue().documentuploadlist != null){
                    component.set('v.masterdocList',response.getReturnValue().documentmasterlist);
                    component.set('v.mainmasterdocList',response.getReturnValue().documentmasterlist);
                }
                var addmoredocupload = component.get('v.docList');
                addmoredocupload.push({'sobjectType':'Document_Upload__c','Name':'','Document_Discription__c': '','Required__c':''});
                component.set('v.docList',addmoredocupload);
            }  
        });
        $A.enqueueAction(action);
        
    },
    checkeddoc : function(component,event,helper){
        var searchvalue  = event.getSource().get("v.checked");
        if(searchvalue){
            var doclist = component.find('add');
            if( !Array.isArray(doclist)){
                if(doclist.get('v.checked')!=true && doclist.get('v.label') == event.getSource().get("v.label")){
                    alert('Please choose document first');
                    event.getSource().set("v.checked",false);
                }    
            }
            else{  
                for(var i =0 ;i<doclist.length ; i++){
                    var checkboxvalue = component.find('add')[i];
                    if(checkboxvalue.get('v.checked')!=true && checkboxvalue.get('v.label') == event.getSource().get("v.label")){
                        alert('Please choose document first'); 
                        event.getSource().set("v.checked",false);
                    }       
                }
            }   
        }
    },
    handleKeyUp: function (cmp, evt) {
        //  cmp.set('v.nocountryfound',false);
        var isEnterKey = evt.keyCode === 13;
        var queryTerm = cmp.find('enter-search').get('v.value');
        var jsmainmasterdocList = cmp.get('v.mainmasterdocList');
        var searchmasterdoc=[];
        
        if (isEnterKey) {
            
            if(!$A.util.isEmpty(queryTerm)){
                
                cmp.set('v.issearching', true);
                for(var str of jsmainmasterdocList){
                    if(str.masterdoc.Name.toUpperCase().includes(queryTerm.toUpperCase())){
                        searchmasterdoc.push(str);   
                    }
                }
                if(searchmasterdoc.length >0) cmp.set('v.masterdocList',searchmasterdoc); 
                // else cmp.set('v.nocountryfound',true);
                
                cmp.set('v.issearching', false);
                
            }
            else{
                cmp.set('v.masterdocList',jsmainmasterdocList);      
            }
        }
        else{
            if($A.util.isEmpty(queryTerm)){
                cmp.set('v.masterdocList',jsmainmasterdocList);    
            }   
        }
    },
    rerenderlist : function(component,event){
        var searchvalue  = event.getSource().get("v.value");
        if($A.util.isEmpty(searchvalue)){
            // component.set('v.nocountryfound',false);
            component.set('v.masterdocList',component.get('v.mainmasterdocList'));   
        }
    },
    addmore : function(component,event,helper){
        // alert(JSON. stringify(component.get('v.docList')));
        var addmoredocupload = component.get('v.docList');
        addmoredocupload.push({'sobjectType':'Document_Upload__c','Name':'','Document_Discription__c': '','Required__c':''});
        component.set('v.docList',addmoredocupload);
    },
    remove : function(component,event,helper){
        var index = event.getSource().get("v.accesskey")
        var removedocupload = component.get('v.docList');
        removedocupload.splice(index,1);
        component.set('v.docList',removedocupload);
    },
    save : function(component,event,helper){
        var requiredoc =[];
        var docupload =[];
        var doclist = component.find('requireddoc');
        if( !Array.isArray(doclist)){
            if(doclist.get('v.checked')==true ){
                requiredoc.push('true');
            }
            else{
                requiredoc.push('false');  
            }         
        }
        else{  
            for(var i =0 ;i<doclist.length ; i++){
                var checkboxvalue = component.find('requireddoc')[i];
                if(checkboxvalue.get('v.checked') == true ){
                    requiredoc.push('true');
                }
                else{
                    requiredoc.push('false'); 
                }
            }  
        }
        docupload = component.get('v.docList');
        var action = component.get('c.savedocupload');
        // alert(JSON. stringify(component.get('v.docList')));
        action.setParams({
            'requirechecklist':requiredoc,
            'docuploadlist':docupload,
            'appid' : component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().msg.includes('success')){
                    var result=[];
                    result = response.getReturnValue().msg.split(';');
                    if(result[1] != "0"){
                        component.set('v.docList',"{'sobjectType':'Document_Upload__c','Name':'','Document_Discription__c': '','Required__c':''}");
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Document has been created.",
                            "type":"success"
                        });
                        toastEvent.fire();}
                    if(response.getReturnValue().documentuploadlist.length>0){
                        component.set('v.existingdocList',response.getReturnValue().documentuploadlist);   
                    }
                    else{
                        component.set('v.existingdocList',null);     
                    }
                }
                else{ 
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": response.getReturnValue().msg,
                        "type":"error",
                        "mode":"sticky"
                    });
                    toastEvent.fire(); 
                }
            }
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": errors[0].message, //Fetching Custom Message.
                        "type":"error",
                        "mode":"sticky"
                    });
                    toastEvent.fire(); 
                }
            }
        });
        $A.enqueueAction(action);
        
    },
    removeexisting : function(component,event,helper){
        if(event.getSource().get("v.checked")==true){
            var result = confirm("Are You Sure ? you want delete this document."); 
            if (result == true) { 
                
                var index = event.getSource().get("v.label");  
                var action = component.get("c.deletedocuploadrecord"); 
                action.setParams({
                    'docId' : index,
                    'applicationid': component.get('v.recordId') 
                });
                action.setCallback(this,function(response){            
                    if(response.getState() === "SUCCESS") {
                        if(response.getReturnValue().msg.includes('success')){
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Document has been deleted successfully.",
                                "type":"success"
                            });
                            toastEvent.fire();
                            if(response.getReturnValue().documentuploadlist.length>0){
                                component.set('v.existingdocList',response.getReturnValue().documentuploadlist);   
                            }
                            else{
                                component.set('v.existingdocList',null);     
                            }
                        }
                        else{ 
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": response.getReturnValue().msg,
                                "type":"error",
                                "mode":"sticky"
                            });
                            toastEvent.fire(); 
                        }
                    }
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": errors[0].message, //Fetching Custom Message.
                                "type":"error",
                                "mode":"sticky"
                            });
                            toastEvent.fire(); 
                        }
                    }
                });
                $A.enqueueAction(action);   
            }
            else{
                event.getSource().set("v.checked",false); 
            }   
        }
        
    },
    addmasterdoc :function(component,event,helper){ 
        var requiremasterdoc =[];
        var masterdoc =[];
        var doclist = component.find('add');
        if( !Array.isArray(doclist)){
            if(doclist.get('v.checked')==true ){
                masterdoc.push(requiredoclist.get('v.label'));
            }
            var requiredoclist = component.find('required');
            if(requiredoclist.get('v.checked')==true ){
                requiremasterdoc.push(requiredoclist.get('v.label'));
            }         
        }
        else{  
            for(var i =0 ;i<doclist.length ; i++){
                var checkboxvalue = component.find('add')[i];
                if(checkboxvalue.get('v.checked') == true ){
                    masterdoc.push(checkboxvalue.get('v.label'));
                }
            }
            var requiredoclist = component.find('required');
            for(var i =0 ;i<requiredoclist.length ; i++){
                var requiredvalue = component.find('required')[i];
                if(requiredvalue.get('v.checked') == true){
                    requiremasterdoc.push(requiredvalue.get('v.label'));   
                }
            }  
        }
        if(masterdoc.length>0 || requiremasterdoc.length >0 ){
            var action = component.get('c.addmasterdocupload');
            action.setParams({
                'mainmasterdoclist':masterdoc,
                'requiremasterdoc':requiremasterdoc,
                'appid' : component.get('v.recordId')
            });
            action.setCallback(this,function(response){
                if(response.getState() === "SUCCESS") {
                    if(response.getReturnValue().msg.includes('success')){
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Document has been created.",
                            "type":"success"
                        });
                        toastEvent.fire();
                        var jsmainmasterdocList = [];
                        for(var i=0;i<component.get('v.mainmasterdocList').length;i++){
                            if(component.get('v.mainmasterdocList')[i].add==true) {
                                component.get('v.mainmasterdocList')[i].add=false;
                            }
                            if(component.get('v.mainmasterdocList')[i].required==true) {
                                component.get('v.mainmasterdocList')[i].required=false;
                            }
                            jsmainmasterdocList.push(component.get('v.mainmasterdocList')[i]);
                        }
                        component.set('v.masterdocList',jsmainmasterdocList);
                        if(response.getReturnValue().documentuploadlist.length>0){
                            component.set('v.existingdocList',response.getReturnValue().documentuploadlist);   
                        }
                        else{
                            component.set('v.existingdocList',null);     
                        }
                    }
                    else{ 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": response.getReturnValue().msg,
                            "type":"error",
                            "mode":"sticky"
                        });
                        toastEvent.fire(); 
                    }
                }
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": errors[0].message, //Fetching Custom Message.
                            "type":"error",
                            "mode":"sticky"
                        });
                        toastEvent.fire(); 
                    }
                }  
            });
            $A.enqueueAction(action);
        }
        else{
            alert('Please choose document first');             
        }
    }
    
})