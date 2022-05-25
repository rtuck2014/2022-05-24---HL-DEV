({
	 locationChange : function(component, event, helper) {
        event.preventDefault;
        var token = event.getParam("token");
        if (token.indexOf('contact/') === 0) {
            var contactId = token.substr(token.indexOf('/') + 1);
            var action = component.get("c.GetById");
            action.setParams({
              "Id": contactId
            });
            action.setCallback(this, function(a) {
                component.set("v.contact", a.getReturnValue());
                 var selectionEvent = component.getEvent("selectionEvent");
                 selectionEvent.setParams({"selectedId": contactId});
                 selectionEvent.fire();
            });
            $A.enqueueAction(action);
        }
    }
})