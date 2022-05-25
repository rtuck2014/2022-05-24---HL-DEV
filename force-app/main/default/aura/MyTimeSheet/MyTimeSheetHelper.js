({
    getCurrentPeriod : function(component, category){
		 var getPeriodAction = component.get("c.GetCurrentPeriod");
         getPeriodAction.setParams({"category":category});
         getPeriodAction.setCallback(this, function(a){
                var period = a.getReturnValue();
                component.set("v.timeRecordPeriod", period);
             	component.set("v.startDate", period.Start_Date__c);
             	component.set("v.endDate", period.End_Date__c);
          });
          $A.enqueueAction(getPeriodAction);        
    },
    showComponent: function(component){	
        var componentDiv = component.find("timesheet");
        $A.util.removeClass(componentDiv, "hidden");
    }
})