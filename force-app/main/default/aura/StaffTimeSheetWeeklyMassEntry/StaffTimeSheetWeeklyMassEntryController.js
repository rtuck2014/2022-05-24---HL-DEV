({
    doInit: function(component, event, helper) {
        helper.getExistingData(component, helper);
        helper.getWeeklyTotals(component, helper);
    },
    onBeforeServerCallEvent: function(component, event, helper) {
        helper.bubbleBeforeServerCall(component, helper);
    },
    onCalendarRowSaveSuccess: function(component, event, helper) {
        helper.onCalendarRowSaveSuccess(component, helper, event.getParam("saveOperation"));
    },
    onDateChanged: function(component, event, helper) {
        helper.getExistingData(component, helper);
    },
    onTimeRecordPeriodStaffMemberChanged: function(component, event, helper) {
        component.set("v.rowValues",null);
        helper.getExistingData(component, helper);
    },
    onTimeRecordDetailsChanged: function(component, event, helper) {
        helper.getExistingData(component, helper);
    },
    onTimeRecordTotalsChanged: function(component, event, helper) {
        helper.getWeeklyTotals(component, helper);
    }
    
})