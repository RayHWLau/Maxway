({
	doint : function(component, event, helper) {
           window.setTimeout(
            $A.getCallback(function() {
                $A.createComponent(
                    "c:docUploadSecondPage", {'appid':component.get('v.recordId')},
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