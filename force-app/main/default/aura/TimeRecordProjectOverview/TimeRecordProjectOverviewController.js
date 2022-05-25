({
    doInit : function(component, event, helper){
       helper.populateTable(component, helper);  
    },
	onDateChanged : function(component, event, helper){
       helper.populateTable(component, helper);  
    },
    onSelection : function(component, event, helper){
        var selections = component.get("v.selections");
        var key = event.target.getAttribute("data-key");
        if(event.target.checked)
            selections.push(key);
        else{
            var index = selections.indexOf(key);
            if(index >= 0)
                selections.splice(index, 1);
        }
        component.set("v.selections", selections);
    },
    onSendNotification : function(component, event, helper){
        helper.sendNotification(component, helper);
    },
    onTimeRecordsUpdated : function(component, event, helper){
        helper.populateTable(component, helper);
    }
})