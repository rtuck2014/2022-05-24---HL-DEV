({
	doInit : function(component, event, helper) {
        var category = component.get("v.category");
        if(category == null){
            var getCategoryAction = component.get("c.GetCategory");
            getCategoryAction.setCallback(this, function(response){
                component.set("v.category",response.getReturnValue());
                helper.getCurrentTimeRecordPeriodStaffMemberRecord(component);
            });
            $A.enqueueAction(getCategoryAction);
        }
        else
            helper.getCurrentTimeRecordPeriodStaffMemberRecord(component);
    },
    locationChange : function(component, event, helper) {
        var token = event.getParam("token");
        if (token && token.indexOf('staff/') === 0) {
            var id = token.substr(token.indexOf('/') + 1);
            helper.selectStaffMember(component, id);
        }
    },
    onStaffMemberSelection : function(component, event, helper){
        var element = event.currentTarget;
        var id = element.getAttribute('data-key');
        helper.selectStaffMember(component, id);
    },
    onCategoryChanged : function(component, event, helper){
        helper.getTimeRecordPeriodStaffMembers(component);
    },
    onTimeRecordPeriodChanged : function(component, event, helper){
        helper.getTimeRecordPeriodStaffMembers(component);
    }
})