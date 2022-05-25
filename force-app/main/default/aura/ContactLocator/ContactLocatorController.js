({
	onMapLoaded : function(component, event, helper) {
		component.set("v.NElng",event.getParam("NElng"));
        component.set("v.NElat",event.getParam("NElat"));
        component.set("v.SWlng",event.getParam("SWlng"));
        component.set("v.SWlat",event.getParam("SWlat"));        
	}
})