({
    
    doInit: function(component, event, helper) {
        helper.fetchChildRecords(component, event);
    },
    
    
    lookupData : function(component, event, helper) {
        console.log('PARENT CALLED!',event.getParam("selectedRecords"),event.getParam("componentId"));
        var recordsIds = event.getParam("selectedRecords");
        var componentId = event.getParam("componentId");
        if(componentId){
            var attributeName = 'v.'+componentId;      
            component.set(attributeName,recordsIds);
        }
        
    },
    
    handleClick : function(component, event, helper) {
        console.log('Event RecordId',component.get('v.recordId'));
        console.log('LookupIds',component.get('v.accountIds'));
        var action = component.get("c.insertEventRecords");
        action.setParams({ 
            'eventId' : component.get("v.recordId"),//'00U53000001UzuuEAC',//
            'eventFieldApi' : component.get("v.eventFieldApi"),
            'junctionObjectName' : component.get("v.junctionObjectApiName"),
            'lookupFieldApi' : component.get("v.lookupFieldApiName"),
            'lookupRecords' : component.get('v.accountIds')});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                //alert("From server: " + response.getReturnValue());
                helper.showSuccessToast(component,event);
                helper.fetchChildRecords(component, event);
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