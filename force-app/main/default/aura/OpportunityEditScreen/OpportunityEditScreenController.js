({
    doint : function(component, event, helper) {
        var modalBody;
        var modalfooter;
        window.setTimeout(
            $A.getCallback(function() {
                //$A.get("e.force:closeQuickAction").fire(); 
                $A.createComponent("c:OpportunityScreen", {'oppId':component.get('v.recordId')},
                  
                                    function(content, status) {
                                        if (status === "SUCCESS") {
                                            
                                            
                                            component.find('overlayLib').showCustomModal({
                                                body: content,
                                                showCloseButton: true,
                                                cssClass: "mymodal slds-modal_medium",
                                                closeCallback: function() {
                                                    var navEvt = $A.get("e.force:navigateToSObject");
                                                    navEvt.setParams({
                                                        "recordId": component.get('v.recordId'),
                                                        "slideDevName": "related"
                                                    });
                                                    navEvt.fire();
                                                }
                                            })
                                        }
                                    }); 
            }), 500
        );   
    }
})