({
    doInit: function(component, event, helper) {
        helper.doInit(component, helper);
    },
    addRecord: function(component, event, helper) {
        helper.addTimeRecord(component, helper);
    },
    onProjectChanged: function(component, event, helper) {
        helper.handleProjectChanged(component, event, helper);
    },
    handleDateChanged : function(component, event, helper){
        helper.modifyActivityTypeListValues(component, event, helper);
    }
})