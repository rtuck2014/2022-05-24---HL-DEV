({
    getActivityTypes : function(component){
        var getActivityTypesAction = component.get("c.GetActivityTypes");
        getActivityTypesAction.setCallback(this, function(a){
            component.set("v.activityTypes", a.getReturnValue());
        });
        $A.enqueueAction(getActivityTypesAction);
    },
	getTimeRecords : function(component, startDate, endDate) {
        var staffMember = component.get("v.timeRecordPeriodStaffMember"); 
        if(staffMember){
            var getTimeRecordsAction = component.get("c.GetTimeRecords");
            getTimeRecordsAction.setParams({"userId":staffMember.User__c, "startDate":startDate, "endDate":endDate});
            getTimeRecordsAction.setCallback(this, function(result) {
                component.set("v.timeRecords", result.getReturnValue());
                this.showComponent(component);
            });
            $A.enqueueAction(getTimeRecordsAction); 
        }
	},
    showComponent: function(component){	
        var componentDiv = component.find("timesheetLitigation");
        $A.util.removeClass(componentDiv, "hidden");
    },
    updateValue: function(component, method, id, value){
        var updateAction = component.get(method);
        updateAction.setParams({"recordId":id,"value":value});
        updateAction.setCallback(this, function(a){
          
        });
        $A.enqueueAction(updateAction);
    }
})