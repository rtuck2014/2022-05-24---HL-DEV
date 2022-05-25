({
    doInit: function(component, helper) {
        helper.callServer(component, "c.GetCategory", function(response) {
            var category = response;
            component.set("v.category", category);
            if (category == "SC" && component.find("activityType01")) {
                component.find("activityType01").set("v.value", "Strategic Consulting");
            }
        });
    },
    deleteActivityRecord: function(component, helper, recordId){
        helper.callServer(component, "c.DeleteRecord", function(response) {
            helper.fireSaveSuccess(component, "DeleteActivity");
        }, {"recordId": recordId}); 
    },
    fireSaveSuccess: function(component, saveOperation) {
        var saveSuccessEvent = component.getEvent("saveSuccessEvent");
        
        saveSuccessEvent.setParams({
            "saveOperation": saveOperation
        });
        
        saveSuccessEvent.fire();
    },
    fireSpinnerEvent: function(component){
        var spinnerEvent = component.getEvent("spinnerEvent");
        spinnerEvent.fire();        
    },
    getRowJSON: function(component, helper) {
        var rowJSON = [];
        var rowRecord = component.get("v.rowRecord");
        var dateRecord = component.get("v.dateRecord");
        var activityRecord = component.get("v.activityRecord");
        var selectedProject = component.get("v.selectedProject");
        var category = component.get("v.category");
        var requireActivityTypes = selectedProject.Type != "Special_Project__c";
       // var requireActivityTypes = (category == 'Beta' || selectedProject.Type != "Special_Project__c" ) && activityTypeRequired ;
        
        console.log('ROWJSON');
        console.log('rowRecord',rowRecord)
        console.log('dateRecord',dateRecord)
        console.log('activityRecord',activityRecord)
        console.log('selectedProject',selectedProject)
        console.log('requireActivityTypes',requireActivityTypes)
        console.log('category',category)
        if (rowRecord && dateRecord && activityRecord && selectedProject &&
            activityRecord.Hours > 0 && (!requireActivityTypes || activityRecord.ActivityType)) {
            
            //If the record exists (edit), verify some value has changed
            if (activityRecord.Id == null ||
                activityRecord.Id != null && (
                    activityRecord.Hours != activityRecord.OriginalHours ||
                    (activityRecord.ActivityType && activityRecord.ActivityType != activityRecord.OriginalActivityType) ||
                    (activityRecord.Comments && activityRecord.Comments != activityRecord.OriginalComments)
                )) {
                rowJSON.push({
                    "sobjectType": "Time_Record__c",
                    "Id": activityRecord.Id,
                    "Activity_Date__c": dateRecord.ActivityDate,
                    // "Activity_Type__c": (selectedProject.Type == "Special_Project__c" ? "" : activityRecord.ActivityType),
                    "Activity_Type__c": (category == 'Beta' || selectedProject.Type != "Special_Project__c"  ? activityRecord.ActivityType : ""),
                    "Comments__c": activityRecord.Comments,
                    "Hourly_Rate__c": activityRecord.Rate,
                    "cTitle__c": activityRecord.Title,
                    "Hours_Worked__c": helper.round(activityRecord.Hours, 1),
                    "Engagement__c": (selectedProject.Type == "Engagement__c" ? selectedProject.Id : null),
                    "Opportunity__c": (selectedProject.Type == "Opportunity__c" ? selectedProject.Id : null),
                    "Special_Project__c": (selectedProject.Type == "Special_Project__c" ? selectedProject.Id : null),
                    "Recording_Status__c": "Complete",
                    "Time_Record_Period_Staff_Member__c": rowRecord.Time_Record_Period_Staff_Member__c
                });
            }
        }
        
        return rowJSON;
    },
    onActivityRecordChanged: function(component, helper) {
        console.log('Input chnaged helper called')
        //Currently setup to save upon each entry change
        var category = component.get("v.category");
        component.set("v.disableInput", true);
        var activityRecord = component.get("v.activityRecord");
        if (activityRecord && helper.validateValues(component)) {
            var rowRecord = component.get("v.rowRecord");
            var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
            var action = activityRecord.Id ? "c.UpdateRecords" : "c.InsertRecords";
            var rowJSON = helper.getRowJSON(component, helper);
            console.log('Action',action);
            console.log('rowJSON',rowJSON)
            if(rowJSON.length > 0){
                if (action == "c.InsertRecords") {
                    helper.callServer(component, action, function(response) {
                        if (response && response.length > 0) {
                            activityRecord.Id = response[0].Id;
                            component.set("v.activityRecord", activityRecord);
                            if (rowRecord.IsNewRow)
                                helper.fireSaveSuccess(component, "NewRow");
                            else
                                helper.fireSaveSuccess(component, "NewActivity");
                        }
                        component.set("v.disableInput", false);
                    }, {
                        "timeRecords": rowJSON,
                        "userId": timeRecordPeriodStaffMember.User__c,
                        "category": category,
                        "allowedHourEntry": component.get("v.allowedHourEntry")
                    });
                } else {
                    helper.callServer(component, action, function(response) {
                        if (response && response.length > 0) {
                            activityRecord.Id = response[0].Id;
                            component.set("v.activityRecord", activityRecord);
                            if (rowRecord.IsNewRow)
                                helper.fireSaveSuccess(component, "NewRow");
                            else
                                helper.fireSaveSuccess(component, "NewActivity");
                        }
                        component.set("v.disableInput", false);
                    }, {
                        "timeRecords": rowJSON,
                        "allowedHourEntry":component.get("v.allowedHourEntry")
                    });
                }
            }
            else {
                component.set("v.disableInput", false);
            }
        }
        else {
            component.set("v.disableInput", false);
        }
    },
    validateValues: function(component) {
        var category = component.get("v.category");
        var selectedProject = component.get("v.selectedProject");
        var activityRecord = component.get("v.activityRecord");
        //var activityTypeRequired = component.get("v.activityTypeRequired");
        //Display any error messages before save attempt
        var isValid = true;
        var msg = "";
        var requireActivityTypes = selectedProject && selectedProject.Type != "Special_Project__c";
        //Validate a project was selected
        if(!selectedProject)
            msg += (msg === "" ? "" : "\r\n") + " Project Selection Needed";
        
        //Validate numeric hourly entries
        if (activityRecord.Hours && (!requireActivityTypes || activityRecord.ActivityType) && (isNaN(activityRecord.Hours) || activityRecord.Hours <= 0))
            msg += (msg === "" ? "" : "\r\n") + " Invalid Hour Entry - Must be a Positive Number";
        
        if (msg != "")
            isValid = false;
        
        return isValid;
    },
    round: function(value, precision) {
        var multiplier = Math.pow(10, precision || 0);
        return Math.round(value * multiplier) / multiplier;
    }
})