({
    doInit: function(component, event, helper) {
        helper.onInit(component, event, helper);
    },
    onProjectSelection: function(component, event, helper) {
        helper.onProjectSelected(component, event, helper);
    },
    onProjectSelectionsChanged: function(component, event, helper) {
        helper.handleProjectRequirements(component);
    },
    onSaveSuccessEvent: function(component, event, helper) {
        helper.fireSaveSuccess(component, helper, event.getParam("saveOperation"));
    }
})