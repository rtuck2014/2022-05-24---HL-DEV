({
    doInit : function(component, event, helper) {
        var category = component.get("v.category");
        helper.getSecurity(component, helper, category);
    },
    onCommentsChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        if(value != '')
            helper.updateValue(component, helper, "c.UpdateComments", id, value);
        else
            alert("Comment Required");
    },
    onDeleteClicked : function(component, event, helper){
        var source = event.getSource();
        if(confirm('Are you sure you want to delete this record?'))
            helper.deleteRecord(component, helper, source.get("v.accesskey"));
    },
    onHoursWorkedWeekdayChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        // Check if input is numeric
        if (isNaN(value)) {
            source.set("v.value",0);
            alert('Invalid Number');
        } else {
            source.set("v.errors", null);
            helper.updateValue(component, helper, "c.UpdateHoursWorkedWeekday", id, value);
        }
    },
    onHoursWorkedWeekendChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        // Check if input is numeric
        if (isNaN(value)) {
            source.set("v.value",0);
            alert('Invalid Number');
        } else {
            source.set("v.errors", null);
            helper.updateValue(component, helper, "c.UpdateHoursWorkedWeekend", id, value);
        }
    },
    onSuppressLoadingIndicatorFired: function(component, event, helper){
      	var suppress = event.getParam("suppress");
        helper.fireSuppressLoadingIndicatorEvent(component, suppress);
    },
    onTimeRecordAdded : function(component, event, helper){
        helper.fireSuppressLoadingIndicatorEvent(component, true);
        helper.getTimeRecords(component, helper);
    },
    handleTimeRecordPeriodChangedEvent : function(component, event, helper){
        var timeRecordPeriod = component.get("v.timeRecordPeriod");
        //Get Staff Member
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        console.log('timeRecordPeriodStaffMember',timeRecordPeriodStaffMember);
        console.log('timeRecordPeriod',timeRecordPeriod)
        if(timeRecordPeriod.Id && timeRecordPeriodStaffMember){
            helper.getTimeRecordPeriodStaffMember(component, helper, timeRecordPeriod.Id, timeRecordPeriodStaffMember.User__c);
        }
        else
            helper.prepareGetTimeRecords(component, helper);

    },
    handleStaffMemberChangedEvent : function(component, event, helper){
        helper.prepareGetTimeRecords(component, helper);
    },
    sortByProjectName : function(component, event, helper){
        helper.sortRecords(component, 'Project_Name__c');
    },
    sortByHoursWorkedWeekday : function(component, event, helper){
        helper.sortRecords(component, 'Hours_Worked_Weekday__c');
    },
    sortByHoursWorkedWeekend : function(component, event, helper){
        helper.sortRecords(component, 'Hours_Worked_Weekend__c');
    },
    onTabViewClick : function(component, event, helper){
        helper.setActiveTab(component, "tab-heading-view", "tab-heading-summary", "tab-heading-add");
    },
    onTabAddClick : function(component, event, helper){
        helper.setActiveTab(component, "tab-heading-add", "tab-heading-summary", "tab-heading-view");
    }
})