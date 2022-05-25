({
	populateTable : function(component, helper){
        var timeRecordsExternal = component.get("v.timeRecordsExternal");
        if(timeRecordsExternal && timeRecordsExternal.length > 0)
        	component.set("v.timeRecords", timeRecordsExternal);
        else
        	this.getTimeRecords(component,helper);
    },
    getTimeRecords : function(component, helper){
        var category = component.get("v.category");
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        if(startDate && endDate){
            helper.callServer(component, "c.GetRollupGroupedByEngagement", function(response){
                   component.set("v.timeRecords", response); 
            },{"category":category,"startDate":startDate,"endDate":endDate});
        }
    },
    sendNotification : function(component, helper){
        var selections = component.get("v.selections");
        if(selections.length > 0){
            var category = component.get("v.category");
            var startDate = component.get("v.startDate");
        	var endDate = component.get("v.endDate");
            helper.callServer(component, "c.SendInvoiceNotification", function(response){
                console.log(response);
                component.set("v.showError", false);
                component.set("v.showSuccess", true);
            },{"category":category, "startDate":startDate, "endDate":endDate, "engagementIdList":selections});
        }
        else
            this.setError(component, "Please Select One or More Engagements");
    },
    setError : function(component, errorMsg){
        component.set("v.showSuccess", false);
        component.set("v.showError", true);
        
        var errorText = component.find("errorText");
        errorText.set("v.value", " " + errorMsg);
    }
})