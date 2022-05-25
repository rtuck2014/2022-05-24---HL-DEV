({
	doInit : function(component, event, helper) { 
        var staffMember = component.get("v.timeRecordPeriodStaffMember");    
        var category = component.get("v.category");
        if(staffMember == null)
        {
            var getStaffMemberAction = component.get("c.GetCurrentTimeRecordPeriodStaffMemberRecord");
            getStaffMemberAction.setParams({"category":category});
            getStaffMemberAction.setCallback(this,function(result){
                component.set("v.timeRecordPeriodStaffMember", result.getReturnValue());
                helper.getTimeRecords(component);
            });
            $A.enqueueAction(getStaffMemberAction);
        }
        else
            helper.showComponent(component);
        
        helper.getActivityTypes(component);
    },
    onActivityTypeChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        helper.updateValue(component, "c.UpdateActivityType", id, value);
    },
    onCommentsChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        if(value != '')
        	helper.updateValue(component, "c.UpdateComments", id, value);
        else
            alert("Comment Required");
    },
    onHoursWorkedChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        helper.updateValue(component, "c.UpdateHoursWorked", id, value);
    },
    onHourlyRateChanged : function(component, event, helper){
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        helper.updateValue(component, "c.UpdateHourlyRate", id, value);
    },
    onDateRangeChanged : function(component, event, helper){
        var startDate = event.getParam("startDate");
        var endDate = event.getParam("endDate");
        helper.getTimeRecords(component, startDate, endDate);
    },
    onTimeRecordAdded : function(component, event, helper){
       var startDate = event.getParam("startDate");
       var endDate = event.getParam("endDate");
       helper.getTimeRecords(component, startDate, endDate);
    }
})