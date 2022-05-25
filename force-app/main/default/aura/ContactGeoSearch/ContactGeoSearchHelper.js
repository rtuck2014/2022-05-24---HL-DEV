({
	searchLocation : function(component, event, helper) {
        var cityName = component.find("cityName").get("v.value");        
            var zipCode = component.find("zipCode").get("v.value");              
            var action = component.get("c.geocodeAddress");
            action.setParams({ cityName : cityName , zipCode : zipCode });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if (state === "SUCCESS") {
                    // get the search coordinates and relocate the map                
                    var coordinates = response.getReturnValue();	                                        
                    var event = $A.get("e.c:searchMap");
                    event.setParams({"coordinates": coordinates});
                    event.fire();               
                }            
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            });
            $A.enqueueAction(action);
		
	}
})