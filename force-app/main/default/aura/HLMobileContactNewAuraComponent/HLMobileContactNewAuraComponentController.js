({
	doInit : function(component, event, helper) {
	let recordId = 	component.get("v.recordId");
    if(recordId === undefined){
            component.set("v.showLookupField", true);
        }
	}
})