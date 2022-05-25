({
    //This must be called after the time record period has been set
    initializePicklists: function(component, helper) {
        var loadedActivityTypes = false;
        var loadedCurrencyCodes = false;
        
        helper.callServer(component, "c.GetActivityTypes", function(response) {
            component.set("v.activityTypes", response);
            loadedActivityTypes = true;
            if (loadedActivityTypes && loadedCurrencyCodes)
                this.prepareGetTimeRecords(component, helper);
        });
        
        helper.callServer(component, "c.GetCurrencyCodes", function(response) {
            component.set("v.currencyCodes", response);
            loadedCurrencyCodes = true;
            if (loadedActivityTypes && loadedCurrencyCodes)
                this.prepareGetTimeRecords(component, helper);
        });
    },
    fireStaffTimeSheetLoaded: function(component) {
        //Check that all child components loaded
        if (component.get("v.areTimeRecordsLoaded") &&
            component.get("v.isMassEntryLoaded")) {
            var staffTimeSheetLoadedEvent = component.getEvent("staffTimeSheetLoadedEvent");
            staffTimeSheetLoadedEvent.fire();
        }
    },
    fireSuppressLoadingIndicatorEvent: function(component, suppress) {
        var suppressLoadingIndicator = component.getEvent("suppressLoadingIndicatorEvent");
        suppressLoadingIndicator.setParams({
            "suppress": suppress
        });
        suppressLoadingIndicator.fire();
    },
    fireTabSelectedEvent: function(component, helper, selectedTab) {
        var tabSelectedEvent = component.getEvent("tabSelectedEvent");
        var currentTab = component.get("v.activeTab");
        
        //For now we will always reload (if ((currentTab == 'tab-mass' && selectedTab != 'tab-mass') || (currentTab != 'tab-weekly' && selectedTab == 'tab-weekly') | (currentTab == 'tab-recorder' && selectedTab != 'tab-recorder'))
        this.prepareGetTimeRecords(component, helper);
        
        //Set the Active Tab
        component.set("v.activeTab", selectedTab);
        tabSelectedEvent.setParams({
            "selectedId": selectedTab
        });
        
        tabSelectedEvent.fire();
    },
    getTimeRecords: function(component, helper) {
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        this.fireSuppressLoadingIndicatorEvent(component, false);
        console.log('staffMember:'+JSON.stringify(timeRecordPeriodStaffMember));
        if(timeRecordPeriodStaffMember.Title__c.includes('Outsourced Contractor')){
            component.set("v.allowedHourEntry",1000);
        }
        helper.callServer(component, "c.GetTimeRecords", function(response) {
            var timeRecords = response;
            var sortField = component.get("v.sortField");
            if (sortField)
                this.performSort(component, timeRecords, sortField, true);
            else
                component.set("v.timeRecords", timeRecords);
            
        }, timeRecordPeriodStaffMember ? {
            "userId": timeRecordPeriodStaffMember.User__c,
            "startDate": startDate,
            "endDate": endDate
        } : {
            "startDate": startDate,
            "endDate": endDate
        });
        
        this.getTimeRecordsSummary(component, helper, startDate, endDate);
    },
    getTimeRecordsSummary: function(component, helper, startDate, endDate) {
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        
        helper.callServer(component, "c.GetTimeRecordDayRollups", function(response) {
            var timeRecordsSummary = response;
            component.set("v.timeRecordsSummary", timeRecordsSummary);
            
            component.set("v.areTimeRecordsLoaded", true);
            
        }, timeRecordPeriodStaffMember ? {
            "userId": timeRecordPeriodStaffMember.User__c,
            "startDate": startDate,
            "endDate": endDate
        } : {
            "startDate": startDate,
            "endDate": endDate
        });
        
    },
    getTimeRecordsWeekly: function(component, helper) {
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        if (staffMember && startDate && endDate) {
            endDate = this.getWeeklyEndDate(startDate, endDate);
            
            helper.callServer(component, "c.GetRollupGroupedByDayAndProject", function(response) {
                component.set("v.timeRecordsWeekly", response);
            }, {
                "userId": staffMember.User__c,
                "startDate": startDate,
                "endDate": endDate
            });
            
            this.getTimeRecordsWeeklyTotals(component, helper);
        }
    },
    getTimeRecordsWeeklyTotals: function(component, helper) {
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        if (staffMember && startDate && endDate) {
            endDate = this.getWeeklyEndDate(startDate, endDate);
            
            //Totals
            helper.callServer(component, "c.GetRollupGroupedByDay", function(response) {
                component.set("v.timeRecordWeeklyTotals", response);
            }, {
                "userId": staffMember.User__c,
                "startDate": startDate,
                "endDate": endDate
            });
        }
    },
    getWeeklyEndDate: function(startDate, endDate) {
        //Verify a week or more range has been selected
        var firstDate = new Date(startDate + ' 00:00:00');
        var secondDate = new Date(endDate + ' 00:00:00');
        var oneDay = 24 * 60 * 60 * 1000; // hours*minutes*seconds*milliseconds
        
        while (Math.round(Math.abs((firstDate.getTime() - secondDate.getTime()) / (oneDay))) < 6)
            secondDate.setDate(secondDate.getDate() + 1);
        
        return secondDate.getFullYear() + "-" + (secondDate.getMonth() + 1) + "-" + secondDate.getDate();
    },
    performSort: function(component, timeRecords, field, keepDirection) {
        var currentSortField = component.get("v.sortField");
        var currentDirection = component.get("v.sortDirection");
        var direction = keepDirection ? currentDirection : currentSortField === field ? (currentDirection === 'DESC' ? 'ASC' : 'DESC') : 'DESC';
        var greaterNumber = direction === 'DESC' ? -1 : 1;
        switch (field) {
            case 'Activity_Type__c':
                timeRecords.sort(function(a, b) {
                    return (a.Activity_Type__c > b.Activity_Type__c) ? greaterNumber : ((b.Activity_Type__c > a.Activity_Type__c) ? greaterNumber * -1 : 0);
                });
                break;
            case 'Project_Name__c':
                timeRecords.sort(function(a, b) {
                    return (a.Project_Name__c > b.Project_Name__c) ? greaterNumber : ((b.Project_Name__c > a.Project_Name__c) ? greaterNumber * -1 : 0);
                });
                break;
            case 'Hours_Worked__c':
                timeRecords.sort(function(a, b) {
                    return (a.Hours_Worked__c > b.Hours_Worked__c) ? greaterNumber : ((b.Hours_Worked__c > a.Hours_Worked__c) ? greaterNumber * -1 : 0);
                });
                break;
            default:
                timeRecords.sort(function(a, b) {
                    return (a.Activity_Date__c > b.Activity_Date__c) ? greaterNumber : ((b.Activity_Date__c > a.Activity_Date__c) ? greaterNumber * -1 : 0);
                });
        }
        component.set("v.sortField", field);
        component.set("v.sortDirection", direction);
        component.set("v.timeRecords", timeRecords);
    },
    performSummarySort: function(component, timeRecordsSummary, field, keepDirection) {
        var currentSortField = component.get("v.sortSummaryField");
        var currentDirection = component.get("v.sortSummaryDirection");
        var direction = keepDirection ? currentDirection : currentSortField === field ? (currentDirection === 'DESC' ? 'ASC' : 'DESC') : 'DESC';
        var greaterNumber = direction === 'DESC' ? -1 : 1;
        switch (field) {
            case 'Activity_Type__c':
                timeRecordsSummary.sort(function(a, b) {
                    return (a.Activity_Type__c > b.Activity_Type__c) ? greaterNumber : ((b.Activity_Type__c > a.Activity_Type__c) ? greaterNumber * -1 : 0);
                });
                break;
            case 'Project_Name__c':
                timeRecordsSummary.sort(function(a, b) {
                    return (a.Project_Name__c > b.Project_Name__c) ? greaterNumber : ((b.Project_Name__c > a.Project_Name__c) ? greaterNumber * -1 : 0);
                });
                break;
            case 'Hours_Worked__c':
                timeRecordsSummary.sort(function(a, b) {
                    return (a.Hours_Worked__c > b.Hours_Worked__c) ? greaterNumber : ((b.Hours_Worked__c > a.Hours_Worked__c) ? greaterNumber * -1 : 0);
                });
                break;
            default:
                timeRecordsSummary.sort(function(a, b) {
                    return (a.Activity_Date__c > b.Activity_Date__c) ? greaterNumber : ((b.Activity_Date__c > a.Activity_Date__c) ? greaterNumber * -1 : 0);
                });
        }
        component.set("v.sortSummaryField", field);
        component.set("v.sortSummaryDirection", direction);
        component.set("v.timeRecordsSummary", timeRecordsSummary);
    },
    prepareGetTimeRecords: function(component, helper) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        
        if (startDate && endDate && timeRecordPeriodStaffMember) {
            component.set("v.areTimeRecordsLoaded", false);
            component.set("v.timeRecords", null);
            this.getTimeRecords(component, helper);
            this.getTimeRecordsWeekly(component, helper);
        }
    },
    setActiveTab: function(component, helper, activeTab, inactiveTabs) {
        var elemTabHeadingActive = document.getElementById(activeTab);
        var elemTabActive = document.getElementById(activeTab.replace('-heading', ''));
        
        if (!$A.util.hasClass(elemTabHeadingActive, "slds-active"))
            $A.util.addClass(elemTabHeadingActive, "slds-active");
        
        inactiveTabs.forEach(function(tab) {
            var element = document.getElementById(tab);
            if ($A.util.hasClass(element, "slds-active"))
                $A.util.removeClass(element, "slds-active");
        });
        
        
        if (!$A.util.hasClass(elemTabActive, "slds-show")) {
            $A.util.addClass(elemTabActive, "slds-show");
            if ($A.util.hasClass(elemTabActive, "slds-hide"))
                $A.util.removeClass(elemTabActive, "slds-hide");
        }
        
        inactiveTabs.forEach(function(tab) {
            var element = document.getElementById(tab.replace('-heading', ''));
            
            if ($A.util.hasClass(element, "slds-show")) {
                $A.util.removeClass(element, "slds-show");
                
                if (!$A.util.hasClass(element, "slds-hide"))
                    $A.util.addClass(element, "slds-hide");
            }
        });
        
        this.fireTabSelectedEvent(component, helper, activeTab.replace('-heading', ''));
    },
    refreshSummaryData: function(component, helper) {
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        if (startDate && endDate && timeRecordPeriodStaffMember) {
            component.set("v.timeRecordsSummary", null);
            this.getTimeRecordsSummary(component, helper, startDate, endDate);
        }
    },
    sortRecords: function(component, field) {
        var timeRecords = component.get("v.timeRecords");
        this.performSort(component, timeRecords, field, false);
    },
    sortSummaryRecords: function(component, field) {
        var timeRecordsSummary = component.get("v.timeRecordsSummary");
        this.performSummarySort(component, timeRecordsSummary, field, false);
    },
    updateCurrency: function(component, helper, id, value) {
        var timeRecords = component.get('v.timeRecords');
        
        for (var i in timeRecords) {
            if (timeRecords[i].Id == id) {
                timeRecords[i].CurrencyIsoCode = value;
                break;
            }
        }
        helper.callServer(component, "c.UpdateCurrencyIsoCode", function(response) {
            helper.prepareGetTimeRecords(component, helper);
            component.set("v.timeRecords", timeRecords);
        }, {
            "recordId": id,
            "value": value
        });
    },
    updateValue: function(component, helper, method, id, value) {
        var category = component.get("v.category");
        
        //Suppress Loading Indicator
        this.fireSuppressLoadingIndicatorEvent(component, true);
        
        helper.callServer(component, method, function(response) {
            //Refresh the Summary Data
            if (category && (method === "c.UpdateActivityType" || method === "c.UpdateHoursWorked" || method === "c.UpdateCurrencyIsoCode" || method === "c.UpdateHourlyRate"))
                this.refreshSummaryData(component, helper);
            else
                this.fireSuppressLoadingIndicatorEvent(component, false);
        }, {
            "recordId": id,
            "value": value,
            "allowedHourEntry":component.get("v.allowedHourEntry")
        });
    },
        round: function(value, precision) {
        var multiplier = Math.pow(10, precision || 0);
        return Math.round(value * multiplier) / multiplier;
    }
})