({
	filterOptionChanged : function(component, helper, elem){
        var action = component.get("c.GetMyActivities");
        action.setAbortable();
        action.setParams({"filter": elem.textContent});
        action.setCallback(this, function(a) {
            component.set("v.myActivities", a.getReturnValue());
        });
        $A.enqueueAction(action);     
    },
    selectedDateChanged : function(component, selectedDate){
        var action = component.get("c.GetMyActivitiesByDate");
        selectedDate.setHours(0,0,0,0);
        component.set("v.selectedDate", selectedDate.getFullYear() + "-" + (selectedDate.getMonth() + 1) + "-" + selectedDate.getDate());
        action.setAbortable();
        action.setParams({"selectedDate": selectedDate.getFullYear() + "-" + ("0" + (selectedDate.getMonth() + 1)).slice(-2) + "-" + ("0" + selectedDate.getDate()).slice(-2)});
        action.setCallback(this, function(a) {
            component.set("v.myActivities", a.getReturnValue());
        });
        $A.enqueueAction(action); 
    }
})