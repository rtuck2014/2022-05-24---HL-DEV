({
    callServer: function(component, method, callback, params, cacheable) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        if (cacheable) {
            action.setStorable();
        }
        action.setAbortable();
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    //This has been changed in recent updates: $A.logf("Errors", errors);
                    console.log(errors);
                    this.fireCallbackErrorEvent(component, errors);
                } else
                    throw new Error("Unknown Error");
            }
        });

        //Fire the Before Server Call Event
        this.fireBeforeServerCallEvent(component);

        $A.enqueueAction(action);
    },
    fireBeforeServerCallEvent: function(component) {
        var beforeServerCallEvt = component.getEvent("beforeServerCallEvent");
        beforeServerCallEvt.fire();
    },
    fireCallbackErrorEvent: function(component, errors) {
        var callbackErrorEvt = component.getEvent("callbackErrorEvent");
        callbackErrorEvt.setParams({
            "errorObject": errors
        });
        callbackErrorEvt.fire();
    },
    fireComponentLoaded: function(component) {
        var componentLoaded = component.getEvent("componentLoadedEvent");
        componentLoaded.fire();
    }
})