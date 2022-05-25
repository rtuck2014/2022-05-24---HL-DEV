({
    doInit : function(component, event, helper) {
        var action = component.get("c.validateOpp");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if($A.util.isEmpty(response.getReturnValue())){
                      // Close the action panel
        			//var dismissActionPanel = $A.get("e.force:closeQuickAction");
        			//dismissActionPanel.fire();
        			component.set('v.isSuccess',true);
                }else{
                    component.set("v.validationMessage",response.getReturnValue());
                    component.set("v.hasLoaded",true);
                }
                console.log("From server: " + response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                
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
    },
    
    refresh : function(component, event, helper) {
        location.reload();
    }
})