({
    addTimeRecord: function(component, helper){
        var insertRecordAction = component.get("c.InsertRollupWeekRecord");
        var opportunities = component.get("v.opportunities");
        var specialProjects = component.get("v.specialProjects");
        var isOpportunity = false;
        var isSpecialProject = false;
        var timeRecord = component.get("v.timeRecordRollupWeek");
        var projectId = component.find("project").get("v.value");
        var staffMember = component.get("v.timeRecordPeriodStaffMember");

        timeRecord.Time_Record_Period_Staff_Member__c = staffMember.Id;
        timeRecord.Hours_Worked_Weekday__c = component.find("hoursWorkedWeekday").get("v.value");
        timeRecord.Hours_Worked_Weekend__c = component.find("hoursWorkedWeekend").get("v.value");
        timeRecord.Opportunity__c = null;
        timeRecord.Engagement__c = null;
        timeRecord.Special_Project__c = null;
        if(component.find("comments")) timeRecord.Comments__c = component.find("comments").get("v.value");
        if(timeRecord.Hours_Worked_Weekday__c == null || timeRecord.Hours_Worked_Weekday__c == "")
            timeRecord.Hours_Worked_Weekday__c = 0;
        if(timeRecord.Hours_Worked_Weekend__c == null || timeRecord.Hours_Worked_Weekend__c == "")
            timeRecord.Hours_Worked_Weekend__c = 0;
        //Set the appropriate lookup Id
        opportunities.filter(function(o) {if(o.Id === projectId) isOpportunity = true;});
        specialProjects.filter(function(sp) {if(sp.Id === projectId) isSpecialProject = true;});
        if(isOpportunity)
            timeRecord.Opportunity__c = projectId;
        else{
            if(isSpecialProject)
                timeRecord.Special_Project__c = projectId;
            else
                timeRecord.Engagement__c = projectId;
        }

        if(this.validateInput(component, timeRecord)){
            this.fireSuppressLoadingIndicatorEvent(component, true);
            insertRecordAction.setParams({"tr":timeRecord});
            insertRecordAction.setCallback(this, function(response){
                this.fireSuppressLoadingIndicatorEvent(component, false);
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.showError", false);
                    this.showToast(component);
                    this.clearFields(component);
                    var successEvent = component.getEvent("saveSuccessEvent");
                    successEvent.fire();
                }
                else if(state === "ERROR"){
                    component.set("v.showError", true);
                    component.set("v.showSuccess",false);
                    component.find("errorText").set("v.value","-Record Already Exists for Project or Hours are Invalid");
                }
            });
            $A.enqueueAction(insertRecordAction);
        }
    },
	clearFields : function(component) {
        if(component.find("hoursWorkedWeekday")) component.find("hoursWorkedWeekday").set("v.value","");
        if(component.find("hoursWorkedWeekend")) component.find("hoursWorkedWeekend").set("v.value","");
        if(component.find("project")) component.find("project").set("v.value","");
        if(component.find("comments")) component.find("comments").set("v.value","");
	},
    fireSuppressLoadingIndicatorEvent: function(component, suppress){
        var suppressLoadingIndicator = component.getEvent("suppressLoadingIndicatorEvent");
        suppressLoadingIndicator.setParams({"suppress":suppress});
        suppressLoadingIndicator.fire();
    },
    getEngagements : function(component, helper){
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        var category = component.get("v.category");
        if(staffMember)
        {
            helper.callServer(component, "c.GetEngagements", function(response){
            	component.set("v.engagements", response);
                this.populateProjectSelection(component);
        	},{"category":category,"userId":staffMember.User__c});
        }
    },
    getOpportunities : function(component, helper){
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        var category = component.get("v.category");
        if(staffMember)
        {
            helper.callServer(component, "c.GetOpportunities", function(response){
            	component.set("v.opportunities", response);
                this.populateProjectSelection(component);
        	},{"category":category,"userId":staffMember.User__c});
        }
    },
    getSpecialProjects : function(component, helper){
        helper.callServer(component, "c.GetSpecialProjects", function(response){
            	component.set("v.specialProjects", response);
                this.populateProjectSelection(component);
        });
    },
    logError : function(response){
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
    populateProjectSelection : function(component){
        var opportunities = component.get("v.opportunities");
        var engagements = component.get("v.engagements");
        var specialProjects = component.get("v.specialProjects");
        var options = [{class: "", label: "(Select Project)", value: "", selected: "true"}];
        specialProjects.forEach(function(sp){
            if(sp.Location_Group__c == 'Top')
            	options.push({class:"selection_specialproject", label: 'Special Project: ' + sp.Name, value: sp.Id});
        });
        engagements.forEach(function(e){
            options.push({class:"selection_engagement", label: 'Engagement: ' + e.Name, value: e.Id});
        });
        opportunities.forEach(function(o){
            options.push({class:"selection_opportunity", label: 'Opportunity: ' + o.Name, value: o.Id});
        });
        specialProjects.forEach(function(sp){
            if(sp.Location_Group__c == 'Bottom')
            	options.push({class:"selection_specialproject", label: 'Special Project: ' + sp.Name, value: sp.Id});
        });
        component.find("project").set("v.options", options);
    },
    showToast : function(component) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent != null)
        {
            toastEvent.setParams({
            "title": "Success!",
            "message": "Time Record Added."
            });
            toastEvent.fire();
        }
        else
        	component.set("v.showSuccess", true);
    },
    validateInput : function(component, timeRecord){
        var isValid = true;
        var requireComments = component.get("v.requireComments");
        var msg = '';

        if((timeRecord.Opportunity__c == null || timeRecord.Opportunity__c == '') && (timeRecord.Engagement__c == null || timeRecord.Engagement__c == '') && (timeRecord.Special_Project__c == null || timeRecord.Special_Project__c == ''))
            msg += (msg === '' ? '' : '\r\n') + 'Project Selection Required';
        if(requireComments && timeRecord.Comments__c == null)
            msg += (msg === '' ? '' : '\r\n') + 'Comments Required';
        if(timeRecord.Hours_Worked_Weekday__c == null && timeRecord.Hours_Worked_Weekend__c == null)
            msg += (msg === '' ? '' : '\r\n') + 'Either Weekday or Weekend Hours Required';
        if(timeRecord.Hours_Worked_Weekday__c == 0 && timeRecord.Hours_Worked_Weekend__c == 0)
            msg += (msg === '' ? '' : '\r\n') + 'Either Weekday or Weekend Hours Required';

        if(msg != ''){
            isValid = false;
            component.set("v.showError", true);
            component.find("errorText").set("v.value", msg);
        }
        else
            component.set("v.showError", false);

        return isValid;
    }
})