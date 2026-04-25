({
	doint : function(component, event, helper) {
        component.set('v.ScheoolColumns', [
            {label: 'Name', fieldName: 'contractId',initialWidth:250, type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Status', fieldName: 'status',initialWidth:250, type: 'string'},
            {label: 'Account Name', fieldName: 'accountname',initialWidth:250, type: 'string'},
            
        ]);
		var action = component.get('c.contractdisplay');
        action.setParams({
            'accountid' : component.get('v.recordId')
        });
        action.setCallback(this,function(response) {
             //  alert(JSON.stringify(response.getReturnValue()));
            if (response.getState() === "SUCCESS"){
               var conlist =[];
                      if(response.getReturnValue() !== null){
            for(var data of response.getReturnValue()){
            if(data.Name=='show' && data.show==true){
                   component.set('v.showdata',true);
               }
            else{
                  conlist.push(data);
             
               }
              }
            component.set('v.ScheoolRecords', conlist); 
        var concount = 0 ;
        concount = response.getReturnValue().length;
        concount =concount-1;
            component.set('v.contract','Contract ('+concount +')');
            }
            }
        });
        $A.enqueueAction(action);
	},
            
    redirect : function(component,event,helper){
            var createAcountContactEvent = $A.get("e.force:createRecord");
            createAcountContactEvent.setParams({
                  "entityApiName": "Contract",
                  "defaultFieldValues": {
                                'AccountId' : component.get('v.recordId')
                                   }
                       });
            createAcountContactEvent.fire();
            }
})