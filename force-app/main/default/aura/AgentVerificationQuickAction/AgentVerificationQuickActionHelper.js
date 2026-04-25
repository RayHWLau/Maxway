({
    showToast : function(type,title,message,duration) {
        
        var toastEvent=$A.get("e.force:showToast");
        toastEvent.setParams({
            "title":title,
            "type":type,
            "message":message,
            "duration" : duration
        });
        toastEvent.fire();
    }, 
})