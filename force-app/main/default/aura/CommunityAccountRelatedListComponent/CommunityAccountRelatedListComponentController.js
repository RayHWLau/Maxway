({
    doint : function(component, event, helper) {
        component.set('v.oppcolumns', [
            {label: 'Name', fieldName: 'oppId',initialWidth:250, type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Status', fieldName: 'status',initialWidth:250, type: 'string'},
            {label: 'Account Name', fieldName: 'accountname',initialWidth:250, type: 'string'},
            
        ]);
            var action = component.get('c.oppdisplay');
            action.setParams({
            'oppid' : component.get('v.recordId')
            });
            action.setCallback(this,function(response) {
            // alert(JSON.stringify(response.getReturnValue()));
            if (response.getState() === "SUCCESS"){
            var opplist =[];
                      if(response.getReturnValue() !== null){
            for(var data of response.getReturnValue()){
                if(data.Name=='show' && data.show==true){
                    component.set('v.showdata',true);
                }
                else{
                    opplist.push(data);
                    
                }
            }
            component.set('v.oppdata', opplist); 
            var oppcount = 0 ;
            oppcount = response.getReturnValue().length;
            oppcount =oppcount-1;
            component.set('v.opp','Opportunity ('+oppcount +')');
        }
    }
});
$A.enqueueAction(action);
},
    
    redirect : function(component,event,helper){
        $A.createComponent("c:OpportunityCreationFromRelatedList", {'accId':component.get('v.recordId'),'iscommunity':true},
                           
                           function(content, status) { 
                               if (status === "SUCCESS") {
                                   component.find('overlayLib').showCustomModal({
                                       body: content,
                                       showCloseButton: true,
                                       cssClass: "mymodal slds-modal_medium",
                                       closeCallback: function() {
                                           var  url= 'https://tmcdev-maxway.cs74.force.com/s/detail/'+component.get('v.recordId');
                                           window.location = url;       
                                       }
                                   })
                               }
                           }); 
    }
})