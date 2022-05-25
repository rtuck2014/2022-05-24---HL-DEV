({
    fireComponentLoaded : function(component){
        var componentLoaded = component.getEvent("componentLoadedEvent");
        componentLoaded.fire();
    },
    getCurrentTimeRecordPeriodStaffMemberRecord : function(component){
        var category = component.get("v.category");
 
        if(category){
        	var getCurrentRecordAction = component.get("c.GetCurrentRecord");
            var timeRecordPeriod = component.get("v.timeRecordPeriodDefault");
            getCurrentRecordAction.setParams({"category":category});
            getCurrentRecordAction.setCallback(this, function(response){
               var currentRecord = response.getReturnValue();
               timeRecordPeriod.Id = currentRecord.Time_Record_Period__c;
               timeRecordPeriod.Public_Group__c = currentRecord.Time_Record_Period__c.Public_Group__c;
               component.set("v.selectedTimeRecordPeriodStaffMember", currentRecord);
               component.set("v.timeRecordPeriod", timeRecordPeriod);
               this.getTimeRecordPeriodStaffMembers(component);
            });
            $A.enqueueAction(getCurrentRecordAction);
        }
    },
	getTimeRecordPeriodStaffMembers : function(component) {
		var getTimeRecordPeriodStaffMembersAction = component.get("c.GetByPeriodGroup");
        var timeRecordPeriod = component.get("v.timeRecordPeriod");
        var category = component.get("v.category");
        if(timeRecordPeriod)
        {
            getTimeRecordPeriodStaffMembersAction.setParams({"category":category});
            getTimeRecordPeriodStaffMembersAction.setParams({"timeRecordPeriod":timeRecordPeriod});
            getTimeRecordPeriodStaffMembersAction.setCallback(this, function(response){
                  component.set("v.staff",response.getReturnValue());
                  this.fireComponentLoaded(component);
            });
            $A.enqueueAction(getTimeRecordPeriodStaffMembersAction);
        }
	},
    selectStaffMember : function(component, staffId){
        var staff = component.get("v.staff");
        var selectedStaffRecord = staff.filter(function(s){return s.Id === staffId;})[0];
        var selectionEvent = component.getEvent("selectionEvent");
        selectionEvent.setParams({"timeRecordPeriodStaffMember": selectedStaffRecord});
        selectionEvent.fire();
        component.set("v.selectedTimeRecordPeriodStaffMember", selectedStaffRecord);
    }
})