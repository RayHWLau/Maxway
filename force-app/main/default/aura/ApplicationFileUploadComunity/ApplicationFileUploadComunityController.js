({
	doInit : function(component, event, helper){ 
            var action = component.get("c.doInitUploadApex");
            component.set('v.doclink',true);
            action.setParams({
                applicationid : component.get("v.recordId") 
            });
            action.setCallback(this,function(response){            
                if(response.getState() === "SUCCESS") { 
                    component.set('v.ismaxway',response.getReturnValue().ismaxway);
                    component.set('v.discriptionmap',response.getReturnValue().docdiscription);
                    
                    var result = response.getReturnValue().mapdocUploadToConDocLink;
                    var linkdisplay = response.getReturnValue().linkview;
                    var discripdisplay = response.getReturnValue().docdiscription;
                   // component.set('v.isdeletable',response.getReturnValue().deletedoc);
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
                            link : linkdisplay[key] ,
                            dis : discripdisplay[key] != undefined ? 'true' : null});
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
        },  
    handleUploadFinished : function(component,event,helper){
      
        var action = component.get("c.updatedoclist"); 
        action.setParams({
            docTypeId : event.getSource().get("v.recordId"),
            docId : event.getParam("files")[0].documentId
        });
        action.setCallback(this,function(response){            
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue().includes('success')){
                    if(component.get('v.ismaxway')){
                     $A.get('e.force:refreshView').fire();   
                    }
                    else{
                       window.location.reload(); 
                    }
                    
                }
                else if (response.getReturnValue().includes('error')){
                    component.set("v.errorMsg",'Some Error has occurred');    
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
                   
                    if(component.get('v.ismaxway')){
                     $A.get('e.force:refreshView').fire();   
                    }
                    else{
                       window.location.reload(); 
                    }
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
    },
    handleShowPopover : function(component, event, helper) {
        
        var discripdisplay = component.get('v.discriptionmap');
        var idx = event.target.getAttribute('data-index');
        var selectedItem = discripdisplay[idx];
        component.set('v.discription',selectedItem);
    },
    closeModel : function(component, event, helper) {
       
        component.set('v.discription',null);
    }
})