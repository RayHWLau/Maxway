({
    doInit : function(component, event, helper) {   
        
        if(component.get("v.btnVisible")){
            var action = component.get("c.doInitUploadApex");
            component.set('v.doclink',true);
            action.setParams({
                opportunityId : component.get("v.recordId") 
            });
            action.setCallback(this,function(response){            
                if(response.getState() === "SUCCESS") { 
                    var result = response.getReturnValue().mapdocUploadToConDocLink;
                    var linkdisplay = response.getReturnValue().linkview;
                    var ProcessDisplay = response.getReturnValue().ProcessDisplay;
                    component.set('v.isdeletable',response.getReturnValue().deletedoc);
                    var documentListMap = component.get("v.documentList");
                    var iteratorList = [];
                    for(var key in result){
                        documentListMap[key.replace('*','')] = result[key];
                    }                   
                    component.set("v.documentList",documentListMap);                                
                    for(var key in result){
                        iteratorList.push({
                            key :key.includes('*') ? key.replace('*',''):  key, 
                            value: result[key].includes('#') ? 'check' : '',
                            Id : result[key].includes('#') ? result[key].split('#')[0] : result[key] ,
                            docId : result[key].includes('#') ? result[key].split('#')[1] : null,
                            required :key.includes('*') ? 'required' :'',
                            link : linkdisplay[key],
                            process :ProcessDisplay[key] });
                    }
                    component.set("v.iteratorList",iteratorList);
                }
                else{
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            component.set("v.errorMsg",errors[0].message );//Fetching Custom Message.
                        }
                    }
                    
                }
            });
            $A.enqueueAction(action);    
        }
    },  
    handleUploadFinished : function(component,event,helper){
        
        event.getSource().set("v.label",event.getParam("files")[0].name);
        var businessvaliddate = null;
        if(event.getSource().get("v.title").includes('Business')){
            component.set("v.businessValidTillDate",true); 
            businessvaliddate = 'businessdate'
        }
        var action = component.get("c.updatedoclist"); 
        action.setParams({
            docTypeId : event.getSource().get("v.recordId"),
            docId : event.getParam("files")[0].documentId ,
            businessdatecheck :businessvaliddate 
        });
        action.setCallback(this,function(response){            
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().includes('success')){
                    $A.get('e.force:refreshView').fire();
                }
                else if (response.getReturnValue().includes('error')){
                    component.set("v.errorMsg",'Some Error has occurred');    
                }
                    else if (response.getReturnValue().includes('business')){
                        var business = response.getReturnValue().split('#');
                        component.set('v.businessvaliddate',business[1]);
                        
                    }
                        else{
                            component.set("v.errorMsg",response.getReturnValue());   
                        }
            }
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    component.set("v.errorMsg",errors[0].message );//Fetching Custom Message.
                }
            }
        });
        $A.enqueueAction(action); 
    },
    closeModelandsave : function(component,event,helper){
        
        var counter = 0;
        //  alert($A.util.isEmpty(component.find("licensedate").get("v.value")));
        if($A.util.isEmpty(component.find("licensedate").get("v.value"))){
            component.find('licensedate').showHelpMessageIfInvalid(); 
            counter =1;
        }
        if(counter==0){
            component.set("v.businessValidTillDate",false);
            var action = component.get("c.businesslicenceupdate"); 
            action.setParams({
                oppid : component.get("v.recordId"),
                businessdate : component.get('v.businessvaliddate')
            });
            action.setCallback(this,function(response){            
                if(response.getState() === "SUCCESS") {
                    if(response.getReturnValue().includes('success')){
                        $A.get('e.force:refreshView').fire();
                        //   window.location.reload();
                    }
                    else{
                        component.set("v.errorMsg",response.getReturnValue());   
                    }
                }
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsg",errors[0].message );//Fetching Custom Message.
                    }
                }
            });
            $A.enqueueAction(action); 
        }
    },
    deleltedoc :function(component,event,helper){
        
        var docTypeId = event.getSource().get("v.value");
        var docId = event.getSource().get("v.name"); 
        var action = component.get("c.deletedoc"); 
        action.setParams({
            docTypeId : docTypeId,
            docId : docId            
        });
        action.setCallback(this,function(response){            
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().includes('success')){
                    $A.get('e.force:refreshView').fire();
                    // window.location.reload();
                }
                else{
                    component.set("v.errorMsg",response.getReturnValue());   
                }
            }
            var errors = response.getError();
            if (errors) {
                if (errors[0] && errors[0].message) {
                    component.set("v.errorMsg",errors[0].message );//Fetching Custom Message.
                }
            }
        });
        $A.enqueueAction(action); 
    },
    handleClick : function(component, event, helper){
        var idx = event.target.getAttribute('data-index');
        window.open(event.target.getAttribute('data-index'));
    }
})