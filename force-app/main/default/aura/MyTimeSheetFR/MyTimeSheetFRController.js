({
	doInit : function(component, event, helper) {
        //Currently only used for FR so no need to query the category
        var category = component.get("v.category");
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
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
            helper.getTimeRecords(component);
    },
    onDeleteClicked : function(component, event, helper){
      var source = event.getSource();
      if(confirm('Are you sure you want to delete this record?')){
            var deleteRecordAction = component.get("c.DeleteRecord");
            deleteRecordAction.setParams({"recordId":source.get("v.accesskey")});
          	deleteRecordAction.setCallback(this, function(result){
              	helper.getTimeRecords(component);
          	});
            $A.enqueueAction(deleteRecordAction);
      }
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
            helper.updateValue(component, "c.UpdateHoursWorkedWeekday", id, value);
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
            helper.updateValue(component, "c.UpdateHoursWorkedWeekend", id, value);
        }   
    },
    onTimeRecordAdded : function(component, event, helper){
       helper.getTimeRecords(component);
    },
   handleTimeRecordPeriodChangedEvent : function(component, event, helper){
       if(component.get("v.fireChangedEvents")){
           var timeRecordPeriod = component.get("v.timeRecordPeriod");
           //Get Staff Member
           var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
           if(timeRecordPeriod.Id && timeRecordPeriodStaffMember){
               var getTimeRecordPeriodStaffMemberAction = component.get("c.GetTimeRecordPeriodStaffMemberByPeriodAndUser");
               getTimeRecordPeriodStaffMemberAction.setParams({"timeRecordPeriodId":timeRecordPeriod.Id,
                                                               "userId":timeRecordPeriodStaffMember.User__c});
               getTimeRecordPeriodStaffMemberAction.setCallback(this, function(result){
                   var staffMembers = result.getReturnValue();
                   if(staffMembers.length > 0){
                       component.set("v.timeRecordPeriodStaffMember", staffMembers[0]);
                       helper.getTimeRecords(component);
                   }
                   else
                       component.set("v.timeRecords", []);
               });
               $A.enqueueAction(getTimeRecordPeriodStaffMemberAction);
           }
       }
    }
})