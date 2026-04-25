({
	doinit : function(component,event,helper){
                    component.set('v.recordtypename','Student Account');
                    var action1 = component.get('c.editopportunity');
                    action1.setParams({
                        'oppid' : component.get('v.recordId')
                    });
                    action1.setCallback(this,function(response1){
                        if (response1.getState() === "SUCCESS"){
                            component.set('v.opportunity',response1.getReturnValue().oppdetail);
                            component.set('v.account',response1.getReturnValue().accountdetail);
                            component.set('v.Contact1',response1.getReturnValue().parent1);
                            component.set('v.Contact2',response1.getReturnValue().parent2);
                            component.set('v.isportal',response1.getReturnValue().oUser.IsPortalEnabled);
                            //alert(component.get('v.opportunity.StageName'));
                           
                            component.set('v.showspinner',false); 
                        }
                    })
                    $A.enqueueAction(action1); 
             
        
    },
       toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    }
})