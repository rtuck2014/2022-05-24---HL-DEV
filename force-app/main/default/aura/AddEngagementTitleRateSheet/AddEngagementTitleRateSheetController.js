({
    doInit: function(component, event, helper) {
        helper.getTitleRateSheets(component, helper);
    },
    addRecord: function(component, event, helper) {
        helper.addRecord(component, helper);
    },
    handleCallbackError: function(component, event, helper) {
        event.stopPropagation();
        helper.handleCallbackError(component, event, helper);
    }
})