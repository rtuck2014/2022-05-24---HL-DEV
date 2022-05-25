({
	doInit : function(component, event, helper) {
        var category = component.get("v.category");
        var getCategoryAction = component.get("c.GetCategory");
        getCategoryAction.setCallback(this, function(a){
            category = a.getReturnValue();
            component.set("v.category", category);
            var staffMember = component.get("v.timeRecordPeriodStaffMember");    
            if(staffMember == null)
            {
                var getStaffMemberAction = component.get("c.GetCurrentTimeRecordPeriodStaffMemberRecord");
                getStaffMemberAction.setParams({"category":category});
                getStaffMemberAction.setCallback(this,function(result){
                    component.set("v.timeRecordPeriodStaffMember", result.getReturnValue());
                    helper.getCurrentPeriod(component, category);
                });
                $A.enqueueAction(getStaffMemberAction);
            }
            else
                helper.showComponent(component);
        });
        $A.enqueueAction(getCategoryAction);
    },
    onDateRangeChanged : function(component, event, helper){
        var startDate = event.getParam("startDate");
        var endDate = event.getParam("endDate");
    },
    onSelectedPeriodChanged : function(component, event){
        var selectedTimeRecordPeriod = event.getParam("timeRecordPeriod");
        component.set("v.timeRecordPeriod", selectedTimeRecordPeriod);
    }
})