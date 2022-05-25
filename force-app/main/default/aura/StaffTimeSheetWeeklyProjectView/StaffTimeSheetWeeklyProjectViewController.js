({
    doInit: function(component, event, helper){
        helper.populateTable(component, helper);
    },
    onDateChanged: function(component, event, helper) {
        helper.populateTable(component, helper);
    },
    onTimeRecordPeriodStaffMemberChanged: function(component, event, helper) {
        helper.populateTable(component, helper);
    },
    onTimeRecordsExternalChanged: function(component, event, helper) {
        console.error('timeRecordsExternal>>>'+JSON.stringify(component.get("v.timeRecordsExternal")));
        component.set("v.timeRecords", component.get("v.timeRecordsExternal"));
        helper.generateAllProjectArrays(component);
    },
    onTimeRecordsTotalExternalChanged: function(component, event, helper) {
        console.error('timeRecordsTotalExternal>>>'+JSON.stringify(component.get("v.timeRecordsTotalExternal")));
        component.set("v.timeRecordTotals", component.get("v.timeRecordsTotalExternal"));
        helper.getWeeklyTotals(component);
    }
})