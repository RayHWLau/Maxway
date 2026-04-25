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
                    //   alert(JSON.stringify(response.getReturnValue().mapdocUploadToConDocLink));
                    var result = response.getReturnValue().mapdocUploadToConDocLink;
                    var linkdisplay = response.getReturnValue().linkview;
                    var documentListMap = component.get("v.documentList");
                    var iteratorList = [];
                    for(var key in result){
                        
                        documentListMap[key.replace('*','')] = result[key];
                    }                   
                    component.set("v.documentList",documentListMap);                                
                    for(var key in result){
                        
                        iteratorList.push({key :key.includes('*') ? key.replace('*',''):  key, value: result[key].includes('#') ? 'check' : '',required :key.includes('*') ? 'required' :'',link : linkdisplay[key]});
                    }
                    component.set("v.iteratorList",iteratorList);
                }
            });
            $A.enqueueAction(action);    
        }
        
        
    },
    
    getFile : function(component, event, helper){  
        
        var fileList = event.getSource().get('v.files');
        if (fileList && fileList.length > 0){                       
            var listToSend = component.get("v.uploadList"); 
            var listTosendfornnameid = component.get("v.idandfilename"); 
            
            event.getSource().set('v.label',event.getSource().get('v.files')[0]['name']);
            
            var iterListTemp = component.get("v.iteratorList");
            
            iterListTemp[event.getSource().get('v.name')].value='check';
            component.set("v.iteratorList",iterListTemp);
            
            var reader = new FileReader();
            reader.onloadend = $A.getCallback(function() { 
                var resulttosent = reader.result.split(',');
                listToSend.push(resulttosent[1]);
                listTosendfornnameid.push({"key" : component.get("v.documentList")[event.getSource().get('v.title')],"filename" : event.getSource().get('v.files')[0]['name']});				
                component.set("v.uploadList",listToSend);
                component.set("v.idandfilename",listTosendfornnameid);
                
            }); 
            reader.readAsDataURL(fileList[0]);             
        }            
    },
    
    doSave : function(component, event, helper){ 		        
        if($A.util.isEmpty(component.get("v.uploadList"))){                        
            component.set("v.firstErrorMsg",$A.get("$Label.c.SelectSingleFileUpload"));             
            return;
        }
        
        component.set("v.showSpinner",true);                   
        var action = component.get("c.saveUploadDocFromChildComp");
        action.setParams({            
            "uploadList" : JSON.stringify(component.get("v.uploadList"))
        });
        
        action.setCallback(this,function(response){            
            if(response.getState() === 'SUCCESS') {
                if(response.getReturnValue().includes("SUCCESS")){                    
                    // alert($A.get("$Label.c.DocumentUploadSuccessAlert"));
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        
                        "title": "SUCCESS!",
                        "message": "File uploded successfully.",
                        "type" : "SUCCESS"
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire(); 
                }                    
                else
                    component.set("v.errorMsg",response.getReturnValue().message);
            }
            else{
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMsg",errors[0].message );//Fetching Custom Message.
                    }
                }
                
                
            }
            component.set("v.showSpinner",false);            
        });
        $A.enqueueAction(action);
    },
    handleClick : function(component, event, helper){
        var idx = event.target.getAttribute('data-index');
        
        window.open(event.target.getAttribute('data-index'));
    }
})