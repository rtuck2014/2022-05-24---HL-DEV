({
    doInit: function(component, helper) {
        helper.callServer(component, "c.GetCategory", function(response) {
            var category = response;
            component.set("v.category", category);
            if (category == "SC") {
                component.find("activityType").set("v.value", "Strategic Consulting");
            }
        });
    },
    addTimeRecord: function(component, helper) {
        var category = component.get("v.category");
        var today = new Date();
        var recordDate = component.find("recordDate") ? component.find("recordDate").get("v.value") : today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
        var timeRecord = component.get("v.timeRecord");
        var project = helper.getSelectedProject(component, helper);
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        
        let selectedDate = Date.parse(component.get("v.recordDate"));
        let lastdayOfWeek = new Date(today.setDate(today.getDate() - today.getDay()+6));
        
        // let saveActivityTypeSpecialProject = false;
        if(project){
            //Populate the Time Record
            timeRecord.Engagement__c = (project.Type == "Engagement__c" ? project.Id : null);
            timeRecord.Opportunity__c = (project.Type == "Opportunity__c" ? project.Id : null);
            timeRecord.Special_Project__c = (project.Type == "Special_Project__c" ? project.Id : null);
            timeRecord.Time_Record_Period_Staff_Member__c = staffMember.Id;
            if(category == 'Beta' && selectedDate > lastdayOfWeek){
                timeRecord.Activity_Type__c = 'Forecast';
            }else{
                timeRecord.Activity_Type__c = (category == 'Beta' || project.Type != "Special_Project__c" ? component.find("activityType").get("v.value") :  null);
                //timeRecord.Activity_Type__c = (project.Type != "Special_Project__c"  ? component.find("activityType").get("v.value") : null);
            }
            console.log('timeRecord.Activity_Type__c>>>'+timeRecord.Activity_Type__c);
            timeRecord.Hours_Worked__c = component.find("hoursWorked").get("v.value");
            timeRecord.Hours_Worked__c = helper.round(timeRecord.Hours_Worked__c, 1);
            if (component.find("comments")) timeRecord.Comments__c = component.find("comments").get("v.value");
            
            if (helper.validateInput(component, timeRecord, project)) {
                this.fireSuppressLoadingIndicatorEvent(component, true);
                
                helper.callServer(component, "c.InsertRecord", function(response) {
                    this.fireSuppressLoadingIndicatorEvent(component, false);
                    if (response && response.Id != null) {
                        component.set("v.showError", false);
                        
                        helper.showToast(component);
                        helper.clearFields(component);
                        //Fire the Success Event
                        var successEvent = component.getEvent("saveSuccessEvent");
                        successEvent.fire();
                    }
                }, {
                    "tr": timeRecord,
                    "recordDate": recordDate,
                    "userId": staffMember.User__c,
                    "category": category,
                    "allowedHourEntry":component.get("v.allowedHourEntry")
                });
            }
        }
    },
    clearFields: function(component) {
        var category = component.get("v.category");
        if (category == "SC") {
            component.find("activityType").set("v.value", "Strategic Consulting");
        }
        else {
            if (component.find("activityType")) component.find("activityType").set("v.value", "");
        }
        if (component.find("recordDate")) component.find("recordDate").set("v.value", "");
        if (component.find("hoursWorked")) component.find("hoursWorked").set("v.value", "");
        if (component.find("comments")) component.find("comments").set("v.value", "");
        component.set("v.selectedProjectId", null);
        component.set("v.requireComments", false);
    },
    fireSuppressLoadingIndicatorEvent: function(component, suppress) {
        var suppressLoadingIndicator = component.getEvent("suppressLoadingIndicatorEvent");
        suppressLoadingIndicator.setParams({
            "suppress": suppress
        });
        suppressLoadingIndicator.fire();
    },
    getSelectedProject: function(component, helper) {
        var selectedProjectId = component.get("v.selectedProjectId");
        var projectSelections = component.get("v.projectSelections");
        var selectedProject;
        
        projectSelections.filter(function(p) {
            if (p.Id === selectedProjectId) selectedProject = p;
        });
        
        return selectedProject;
    },
    handleProjectChanged: function(component, event, helper) {
        var selectedProjectId = event.getParam("selectedId");
        var requireComments = false;
        var projectSelections = component.get("v.projectSelections");
        var isSpecialProject = false;
        var selectedProject;
        
        component.set("v.selectedProjectId", selectedProjectId);
        
        //Get the Selected Project
        selectedProject = helper.getSelectedProject(component, helper);
        
        projectSelections.filter(function(p) {
            if (p.Id === selectedProject.Id) {
                component.set("v.selectedProjectType",p.Type);
                isSpecialProject = p.Type === 'Special_Project__c';
                requireComments = p.RequireComments;
            }
        });
        
        component.set("v.requireComments", requireComments);
        component.set("v.showError", false);
        component.set("v.showSuccess", false);
        
        
        helper.toggleActivityType(component, isSpecialProject);
        helper.modifyActivityTypeListValues(component,event,helper);
    },
    modifyActivityTypeListValues : function(component,event,helper){
        let selectedProjectType  = component.get("v.selectedProjectType");
        let category = component.get("v.category");
        let selectedDate = Date.parse(component.get("v.recordDate"));
        let today = new Date();
        let lastdayOfWeek = new Date(today.setDate(today.getDate() - today.getDay()+6));
        if(category === 'Beta'
           &&(((selectedProjectType == 'Engagement__c' 
                || selectedProjectType == 'Opportunity__c')
               && selectedDate > lastdayOfWeek)
              || selectedProjectType == 'Special_Project__c')){
            component.set("v.showForecastActivityType", true);
        }else{
            component.set("v.showForecastActivityType", false);
        }
        
        if(selectedProjectType == 'Special_Project__c' && category == 'Beta'){
           
            helper.toggleActivityType(component, false);
        }
         if(selectedProjectType == 'Special_Project__c' && category == 'Beta' && selectedDate <= lastdayOfWeek){
                component.set("v.currentOrPriorPeriod",true);
            }else{
                component.set("v.currentOrPriorPeriod",false);
            }
    },
    logError: function(response) {
        var errors = response.getError();
        alert(errors[0].message);
        if (errors) {
            $A.logf("Errors", errors);
            if (errors[0] && errors[0].message) {
                $A.error("Error message: " + errors[0].message);
            }
        } else {
            $A.error("Unknown error");
        }
    },
    showToast: function(component) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent != null) {
            toastEvent.setParams({
                "title": "Success!",
                "message": "Time Record Added."
            });
            toastEvent.fire();
        } else
            component.set("v.showSuccess", true);
    },
    toggleActivityType: function(component, toggle) {
        var activityType = component.find("activityType");
        if (toggle)
            $A.util.addClass(activityType, "slds-hide");
        else
            $A.util.removeClass(activityType, "slds-hide");
    },
    validateInput: function(component, timeRecord, project) {
        var isValid = true;
        var requireComments = component.get("v.requireComments");
        var isSupervisor = component.get("v.isSupervisor");
        var msg = '';
        var recordDate = new Date(component.find("recordDate").get("v.value"));
        
        if (isNaN(Date.parse(recordDate)))
            msg += (msg === '' ? '' : '\r\n') + 'Date Required';
        if (project.Type != "Special_Project__c" && timeRecord.Activity_Type__c == null)
            msg += (msg === '' ? '' : '\r\n') + 'Activity Type Required';
        if ((timeRecord.Opportunity__c == null || timeRecord.Opportunity__c === '') && (timeRecord.Engagement__c == null || timeRecord.Engagement__c === '') && (timeRecord.Special_Project__c == null || timeRecord.Special_Project__c === ''))
            msg += (msg === '' ? '' : '\r\n') + 'Project Selection Required';
        //Comments should be optional per John if (requireComments && (timeRecord.Comments__c == null || timeRecord.Comments__c.trim() === '')) msg += (msg === '' ? '' : '\r\n') + 'Comments Required';
        if (timeRecord.Hours_Worked__c == null || timeRecord.Hours_Worked__c <= 0.0)
            msg += (msg === '' ? '' : '\r\n') + 'Hours Required';
        //If not a supervisor, should now be able to log time for more than two weeks back
        if (!isSupervisor) {
            var today = new Date();
            var timeDiff = Math.abs(today.getTime() - recordDate.getTime());
            var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
            if (diffDays > 14)
                msg += (msg === '' ? '' : '\r\n') + 'Cannot log time for more than two weeks past';
        }
        
        if (msg != '') {
            isValid = false;
            component.set("v.showError", true);
            component.find("errorText").set("v.value", ' ' + msg);
        } else
            component.set("v.showError", false);
        
        return isValid;
    },
    round: function(value, precision) {
        var multiplier = Math.pow(10, precision || 0);
        return Math.round(value * multiplier) / multiplier;
    }
})