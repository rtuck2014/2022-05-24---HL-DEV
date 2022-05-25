({
    doInit: function(component, event, helper) {
        helper.initializePicklists(component, helper);
        var startDate = Date.parse(component.get("v.startDate"));
        let currentDate = new Date();
        if(startDate > currentDate){
            component.set("v.isFutureWeek",true);
        }else{
            component.set("v.isFutureWeek",false);
        }        
    },
    onActivityTypeChanged: function(component, event, helper) {
        var timeRecords = component.get('v.timeRecords');
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        for (var i in timeRecords) {
            if (timeRecords[i].Id == id) {
                timeRecords[i].Activity_Type__c = value;
                break;
            }
        }
        helper.updateValue(component, helper, "c.UpdateActivityType", id, value);
        component.set("v.timeRecords", timeRecords);
    },
    onCommentsChanged: function(component, event, helper) {
        var source = event.getSource();
        var id = source.get("v.labelClass");
        var value = source.get("v.value");
        if (value != '')
            helper.updateValue(component, helper, "c.UpdateComments", id, value);
        else
            source.set("v.value", 'Comment Required');
    },
    onCurrencyChanged: function(component, event, helper) {
        var source = event.getSource();
        var id = source.get("v.class");
        var value = source.get("v.value");
        
        helper.updateCurrency(component, helper, id, value);
    },
    onDeleteClicked: function(component, event, helper) {
        var source = event.getSource();
        if (confirm('Are you sure you want to delete this record?')) {
            var deleteRecordAction = component.get("c.DeleteRecord");
            deleteRecordAction.setParams({
                "recordId": source.get("v.accesskey")
            });
            deleteRecordAction.setCallback(this, function(result) {
                var startDate = component.get("v.startDate");
                var endDate = component.get("v.endDate");
                helper.getTimeRecords(component, helper, startDate, endDate);
            });
            $A.enqueueAction(deleteRecordAction);
        }
    },
    onHoursWorkedChanged: function(component, event, helper) {
        var timeRecords = component.get('v.timeRecords');
        var hoursWorkedControl = event.getSource();
        var recordId = hoursWorkedControl.getElement().parentElement.getAttribute("data-key");
        var value = 0;
        
        //Research: Why this does not work
        //var value = hoursWorkedControl.get("v.value");
        for (var i in timeRecords) {
            if (timeRecords[i].Id == recordId) {
                value = helper.round(timeRecords[i].Hours_Worked__c, 1);
                break;
            }
        }

        if (isNaN(value) || value <= 0) {
            hoursWorkedControl.set("v.value", 0);
            alert('Invalid Number');
        } else {
            hoursWorkedControl.set("v.errors", null);
            helper.updateValue(component, helper, "c.UpdateHoursWorked", recordId, value);
            for (var i in timeRecords) {
                if (timeRecords[i].Id == recordId) {
                    timeRecords[i].Amount__c = value * timeRecords[i].Hourly_Rate__c;
                    break;
                }
            }
            component.set("v.timeRecords", timeRecords);
        }
    },
    onHourlyRateChanged: function(component, event, helper) {
        var timeRecords = component.get('v.timeRecords');
        var hourlyRateControl = event.getSource();
        var recordId = hourlyRateControl.getElement().parentElement.getAttribute("data-key");
        var value = 0;
        
        //Research: Why this does not work
        //var value = hourlyRateControl.get("v.value");
        for (var i in timeRecords) {
            if (timeRecords[i].Id == recordId) {
                value = timeRecords[i].Hourly_Rate__c;
                break;
            }
        }
        
        if (isNaN(value) || value <= 0) {
            hourlyRateControl.set("v.value", 0);
            alert('Invalid Number');
        } else {
            hourlyRateControl.set("v.errors", null);
            helper.updateValue(component, helper, "c.UpdateHourlyRate", recordId, value);
            for (var i in timeRecords) {
                if (timeRecords[i].Id == recordId) {
                    timeRecords[i].Amount__c = value * helper.round(timeRecords[i].Hours_Worked__c, 1);
                    break;
                }
            }
            component.set("v.timeRecords", timeRecords);
        }
    },
    onSuppressLoadingIndicatorFired: function(component, event, helper) {
        var suppress = event.getParam("suppress");
        helper.fireSuppressLoadingIndicatorEvent(component, suppress);
    },
    onTimeRecordAdded: function(component, event, helper) {
        helper.fireSuppressLoadingIndicatorEvent(component, false);
        helper.prepareGetTimeRecords(component, helper);
    },
    onTimeRecordUpdated: function(component, event, helper) {
        helper.fireSuppressLoadingIndicatorEvent(component, true);
        helper.getTimeRecordsWeeklyTotals(component, helper);
    },
    onTimeRecordDeleted: function(component, event, helper){
        helper.fireSuppressLoadingIndicatorEvent(component, false);
        helper.prepareGetTimeRecords(component, helper);
    },
    handleDateRangeSelectionEvent: function(component, event, helper) {
        helper.prepareGetTimeRecords(component, helper);
    },
    handleStaffMemberChangedEvent: function(component, event, helper) {
        helper.fireSuppressLoadingIndicatorEvent(component, false);
        helper.prepareGetTimeRecords(component, helper);
    },
    sortByActivityDate: function(component, event, helper) {
        helper.sortRecords(component, 'Activity_Date__c');
    },
    sortByActivityType: function(component, event, helper) {
        helper.sortRecords(component, 'Activity_Type__c');
    },
    sortByProjectName: function(component, event, helper) {
        helper.sortRecords(component, 'Project_Name__c');
    },
    sortByHoursWorked: function(component, event, helper) {
        helper.sortRecords(component, 'Hours_Worked__c');
    },
    sortByRate: function(component, event, helper) {
        helper.sortRecords(component, 'Hourly_Rate__c');
    },
    sortSummaryByActivityDate: function(component, event, helper) {
        helper.sortSummaryRecords(component, 'Activity_Date__c');
    },
    sortSummaryByActivityType: function(component, event, helper) {
        helper.sortSummaryRecords(component, 'Activity_Type__c');
    },
    sortSummaryByProjectName: function(component, event, helper) {
        helper.sortSummaryRecords(component, 'Project_Name__c');
    },
    sortSummaryByHoursWorked: function(component, event, helper) {
        helper.sortSummaryRecords(component, 'Hours_Worked__c');
    },
    sortSummaryByRate: function(component, event, helper) {
        helper.sortSummaryRecords(component, 'Hourly_Rate__c');
    },
    onTabSummaryClick: function(component, event, helper) {
        helper.setActiveTab(component, helper, "tab-heading-summary", ["tab-heading-view", "tab-heading-weekly", "tab-heading-mass", "tab-heading-recorder"]);
    },
    onTabViewClick: function(component, event, helper) {
        helper.setActiveTab(component, helper, "tab-heading-view", ["tab-heading-summary", "tab-heading-weekly", "tab-heading-mass", "tab-heading-recorder"]);
    },
    onTabWeeklyClick: function(component, event, helper) {
        helper.setActiveTab(component, helper, "tab-heading-weekly", ["tab-heading-summary", "tab-heading-view", "tab-heading-mass", "tab-heading-recorder"]);
    },
    onTabMassClick: function(component, event, helper) {
        helper.setActiveTab(component, helper, "tab-heading-mass", ["tab-heading-summary", "tab-heading-view", "tab-heading-weekly", "tab-heading-recorder"]);
    },
    onTabRecorderClick: function(component, event, helper) {
        helper.setActiveTab(component, helper, "tab-heading-recorder", ["tab-heading-summary", "tab-heading-view", "tab-heading-weekly", "tab-heading-mass"]);
    },
    onMassEntryLoaded: function(component, event, helper) {
        component.set("v.isMassEntryLoaded", true);
        helper.fireStaffTimeSheetLoaded(component);
    }
})