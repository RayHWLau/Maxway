({
    init: function (cmp, event, helper) {               
        cmp.set('v.mapMarkers', [
            {
                location: {                         
                    Latitude : $A.get("$Label.c.Latitude"),
    				Longitude : $A.get("$Label.c.Longitude")
                },
                
                title: $A.get("$Label.c.MarkupLocation")                      
            }
        ]);
        cmp.set('v.zoomLevel', 16);        
    }
})