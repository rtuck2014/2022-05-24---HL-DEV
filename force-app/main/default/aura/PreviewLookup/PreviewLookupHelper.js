({
    
    showSuccessToast : function(component, event ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "mode" : 'sticky',
            "type" : 'success',
            "message": "The records were created successfully"
            
        });
        toastEvent.fire();
    },
    
    fetchChildRecords: function(component, event ) {
        
        var action = component.get("c.fetchChildRecords");
        action.setParams({recordId : component.get("v.recordId"),//'00U53000001UzuuEAC',/
                          fieldApiName : component.get("v.eventFieldApi"),
                          objectApiName  :component.get("v.junctionObjectApiName"),
                          lookupFieldApiName : component.get('v.lookupFieldApiName')});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                console.log('Response From Server',response.getReturnValue());
                component.set('v.childRecords',response.getReturnValue());
               // console.log('childRecords',);
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
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
        
        // optionally set storable, abortable, background flag here
        
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
        
        
    }
})