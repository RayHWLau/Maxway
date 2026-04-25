({
    doint : function(component, event, helper) {
      
       var action = component.get('c.alreadyexistingnationality');
        action.setParams({
            "accountid" : component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS") { 
                if(response.getReturnValue().status.includes('SUCCESS')){
                    var result = response.getReturnValue().CommissionTablecmap;
                    var comissiontable =[];
                    for(var key in result){
                        comissiontable.push(result[key]);
                    }
                    component.set('v.CommissionTableclist',comissiontable);
                    component.set('v.searchedcountry',comissiontable);
                    component.set('v.CommissionTableserverlist',response.getReturnValue().CommissionTablelist);
                    component.set('v.currencylist',response.getReturnValue().currencylist);
                    component.set('v.accountname',response.getReturnValue().accountname);
                    component.set('v.accountcurrency',response.getReturnValue().accountcurrency);
                    component.set('v.spinneristrue',false);  
                }   
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
    
    handleKeyUp: function (cmp, evt) {
        cmp.set('v.nocountryfound',false);
        var isEnterKey = evt.keyCode === 13;
        var queryTerm = cmp.find('enter-search').get('v.value');
        var nationalitylist = cmp.get('v.CommissionTableclist');
        var searchnationality=[];
        
        if (isEnterKey) {
            
            if(!$A.util.isEmpty(queryTerm)){
                
                cmp.set('v.issearching', true);
                for(var str of nationalitylist){
                    if(str.Nationality__c.toUpperCase().includes(queryTerm.toUpperCase())){
                        searchnationality.push(str);   
                    }
                }
                if(searchnationality.length >0) cmp.set('v.searchedcountry',searchnationality); 
                else cmp.set('v.nocountryfound',true);
                
                cmp.set('v.issearching', false);
                
            }
            else{
                cmp.set('v.searchedcountry',cmp.get('v.CommissionTableclist'));      
            }
        }
        else{
            if($A.util.isEmpty(queryTerm)){
                cmp.set('v.searchedcountry',cmp.get('v.CommissionTableclist'));    
            }   
        }
    },
    
    handlesave :function(component,event){
        
        component.set('v.finalsubmitcheck',false);
        component.set('v.spinneristrue',true); 
        var tobesavednationalitylist = [];
        var nationalitynames='';
        var msg = '';
        msg = (component.get('v.totalinsertedvalue')>0 && component.get('v.totalupdatedvalue')>0 ? component.get('v.totalinsertedvalue')+' records has been inserted and '+component.get('v.totalupdatedvalue')+' records has been updated successfully'
               :( component.get('v.totalinsertedvalue')>0 ? component.get('v.totalinsertedvalue')+' records has been inserted successfully' 
                 :( component.get('v.totalupdatedvalue')>0 ? component.get('v.totalupdatedvalue')+' records has been updated successfully'
                   : 'Neither records are Inserted Nor Edited')));
        
        for(var i =0; i< component.get('v.CommissionTableclist').length ;i++){
            if( !$A.util.isEmpty(component.get('v.CommissionTableclist')[i].Amount__c)
               && !$A.util.isEmpty(component.get('v.CommissionTableserverlist')[i].Amount__c)
               && component.get('v.CommissionTableclist')[i].Amount__c != component.get('v.CommissionTableserverlist')[i].Amount__c){
                
                tobesavednationalitylist.push(component.get('v.CommissionTableclist')[i]);
            }
            if(!$A.util.isEmpty(component.get('v.CommissionTableclist')[i].Amount__c) && component.get('v.CommissionTableserverlist')[i].Amount__c==null){
                tobesavednationalitylist.push(component.get('v.CommissionTableclist')[i]); 
            }
        }
        if (tobesavednationalitylist.length >0){
          //  alert('tobesavednationalitylist-->'+tobesavednationalitylist);
            var action = component.get('c.savenationality');
            action.setParams({
                'nationalitylist' : tobesavednationalitylist,
                'nationalitycurrency' : component.get('v.accountcurrency')
            });
            action.setCallback(this,function(response){
                if(response.getState() === "SUCCESS") { 
                    if(response.getReturnValue().includes('SUCCESS')){ 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": msg,
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
                       $A.get("e.force:closeQuickAction").fire();
                    }
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
        else{
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": 'Neither records are Inserted Nor Edited',
                "type" : "success"
            });
            toastEvent.fire();
            component.set('v.spinneristrue',false);
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
    savecheck :function(component,event){

        component.set('v.finalsubmitcheck',true);
        var newnationalitynames='';
        var oldnationalitynames='';
        var totalinsertedvalue= 0;
        var totalupdatedvalue= 0;
        for(var i =0; i< component.get('v.CommissionTableclist').length ;i++){
            if( !$A.util.isEmpty(component.get('v.CommissionTableclist')[i].Amount__c) && !$A.util.isEmpty(component.get('v.CommissionTableserverlist')[i].Amount__c)
               && component.get('v.CommissionTableclist')[i].Amount__c != component.get('v.CommissionTableserverlist')[i].Amount__c){
                totalupdatedvalue ++;
                if(oldnationalitynames.length>0) oldnationalitynames = oldnationalitynames + ' , '+component.get('v.CommissionTableclist')[i].Nationality__c;
                else oldnationalitynames = oldnationalitynames + component.get('v.CommissionTableclist')[i].Nationality__c;
            }
            if(!$A.util.isEmpty(component.get('v.CommissionTableclist')[i].Amount__c) && component.get('v.CommissionTableserverlist')[i].Amount__c==null){
                totalinsertedvalue ++;
                if(newnationalitynames.length>0) newnationalitynames = newnationalitynames + ' , '+component.get('v.CommissionTableclist')[i].Nationality__c;
                else newnationalitynames = newnationalitynames + component.get('v.CommissionTableclist')[i].Nationality__c;    
            }
        }
    
        component.set('v.nationalitynames',newnationalitynames);
        component.set('v.oldnationalitynames',oldnationalitynames);
        component.set('v.totalinsertedvalue',totalinsertedvalue);
        component.set('v.totalupdatedvalue',totalupdatedvalue);
    },
    
    reenternationality :function(component,event){
        component.set('v.finalsubmitcheck',false);
    },
    
    isNumber : function(component,event){
        var charCode = (event.which) ? event.which : event.keyCode;
        
        if (charCode!=46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
            event.preventDefault();
        }
        return true; 
    },
    
    handlePaste: function(component, event, helper) {
        event.preventDefault(); 
    },
    rerenderlist : function(component,event){
        var searchvalue  = event.getSource().get("v.value");
        if($A.util.isEmpty(searchvalue)){
            component.set('v.nocountryfound',false);
            component.set('v.searchedcountry',component.get('v.CommissionTableclist'));   
        }
    },
    cancelmodel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})