({
	getTimeRecords : function(component) {
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        
        if(timeRecordPeriodStaffMember != null)
        {
            var getTimeRecordsAction = component.get("c.GetTimeRecordWeekRollups");
        	component.set("v.fireChangedEvents", false);
        	getTimeRecordsAction.setAbortable();
            getTimeRecordsAction.setParams({"timeRecordPeriodStaffMemberId":timeRecordPeriodStaffMember.Id});
            getTimeRecordsAction.setCallback(this, function(result) {
                var timeRecords = result.getReturnValue();
                component.set("v.timeRecords",timeRecords);
                component.set("v.fireChangedEvents", true);
                this.showComponent(component);
            });
            $A.enqueueAction(getTimeRecordsAction);
        }
	},
    updateValue: function(component, method, id, value){
        var category = component.get("v.category");
        var updateAction = component.get(method);
        updateAction.setParams({"recordId":id,"value":value});
        updateAction.setCallback(this, function(a){
          
        });
        $A.enqueueAction(updateAction);
    },
    showComponent: function(component){	
        var componentDiv = component.find("timesheetFR");
        $A.util.removeClass(componentDiv, "hidden");
    }
})