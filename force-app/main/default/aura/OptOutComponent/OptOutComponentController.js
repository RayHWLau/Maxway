({
    donint : function(component, event, helper) {
        var action = component.get('c.fetchschoollist');
        action.setParams({
            'agentId': component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            
            if(response.getState() === "SUCCESS") {
                if(response.getReturnValue() != null){
                    
                    component.set('v.countrylist',response.getReturnValue());
                }
               
            }
        });
        $A.enqueueAction(action);
    },
    createComponent : function(component,event,helper){
        
        var modalBody;
        var modalheader;
        var modalfooter;
        $A.createComponents(  [
            ["c:ChildheaderOptOutComp",{"contryname" : event.getSource().get("v.label")}],
            ["c:ChildContentOptOutComp",{"accountId" : component.get("v.recordId"),"contryname" : event.getSource().get("v.label")}],
            ["c:ChildfooterOptOutComp",{"recordId" : component.get("v.recordId"),"countryname" : event.getSource().get("v.label")}]
        ],
                            function(components, status) {
                                if (status === "SUCCESS") {
                                    modalheader = components[0];
                                    modalBody = components[1];
                                    modalfooter = components[2];
                                    
                                    component.find('overlayLib').showCustomModal({
                                        header:  modalheader,
                                        body: modalBody,
                                        footer :modalfooter,
                                        showCloseButton: true,
                                        cssClass :'Mymodal',
                                        closeCallback: function() {
                                            
                                        }
                                    });
                                }
                            });    
    },
    handleNotification : function(component,event,helper){
     var eventvalue= event.getParam("Status");
        var countryname = ''; 
        if(eventvalue.includes('success')){
         countryname =  eventvalue.split(';')[1]; 
        
        var countrylist =  component.get('v.countrylist');
        var finalcountrylist =[];
        for(var str of countrylist){
            if(str.countryname == countryname){
                str.hasoptout = true;
                finalcountrylist.push(str);
            }
            else{
              finalcountrylist.push(str);  
            }
            
        }
        component.set('v.countrylist',finalcountrylist);
        }
         
    }
})