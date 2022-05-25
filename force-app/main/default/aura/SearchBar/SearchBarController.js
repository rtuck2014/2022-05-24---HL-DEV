({
    searchKeyChange: function(component, event, helper) {
        var searchEvent = component.getEvent("searchEvent");
        searchEvent.setParams({"searchTerm": event.target.value});
        searchEvent.fire();
    }
})