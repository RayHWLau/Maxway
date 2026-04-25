({
    doInit : function(component,event,helper) {
        if($A.get("$Browser.formFactor")=='PHONE' || $A.get("$Browser.formFactor")=='TABLET')
            component.set("v.isDesktop",false);	
        
        var url = $A.get('$Resource.enquiryFormSiteBackgroundImage');
        component.set('v.backgroundImageURL', url);
    }
})