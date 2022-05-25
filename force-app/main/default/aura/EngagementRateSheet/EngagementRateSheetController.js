({
    doInit: function(component, event, helper) {
        helper.getEngagementList(component, helper);
    },
    handleCallbackError: function(component, event, helper) {
        helper.handleCallbackError(component, event, helper);
    },
    onDeleteClicked: function(component, event, helper) {
        var source = event.getSource();
        if (confirm("Are you sure you want to delete this record?")) {
            helper.deleteRecord(component, helper, source.get("v.accesskey"));
        }
    },
    onEngagementChange: function(component, event, helper) {
        helper.onEngagementChange(component, helper);
    },
    onSaveSuccessEvent: function(component, event, helper) {
        helper.getEngagementTitleRateSheetList(component, helper);
    },
    onStartDateChange: function(component, event, helper) {
        var startDateControl = event.getSource();
        var recordId = startDateControl.getElement().parentElement.getAttribute("data-key");
        var originalValue = startDateControl.getElement().parentElement.getAttribute("data-value");
        var newValue = startDateControl.get("v.value");

        if (originalValue != newValue)
            helper.updateEngagementTitleRateSheet(component, helper, recordId, "Start_Date__c", newValue);
    },
    onEndDateChange: function(component, event, helper) {
        var endDateControl = event.getSource();
        var recordId = endDateControl.getElement().parentElement.getAttribute("data-key");
        var originalValue = endDateControl.getElement().parentElement.getAttribute("data-value");
        var newValue = endDateControl.get("v.value");

        if (originalValue != newValue)
            helper.updateEngagementTitleRateSheet(component, helper, recordId, "End_Date__c", newValue);
    }
})