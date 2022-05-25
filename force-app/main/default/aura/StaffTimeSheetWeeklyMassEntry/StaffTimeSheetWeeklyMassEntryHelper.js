({
    addNewRow: function(component) {
        var rowValues = component.get("v.rowValues");
        var displayDates = component.get("v.displayDates");
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        
        //There should be only one new/unsaved row at a time
        rowValues.forEach(function(rv) {
            if (rv.IsNewRow) {
                rv.IsNewRow = false;
                rv.OriginalProjectId = rv.ProjectId;
                rv.DateRecord.forEach(function(dr) {
                    dr.ActivityRecord.forEach(function(ar) {
                        if (ar.Id != null) {
                            ar.OriginalProjectId = rv.ProjectId,
                                ar.OriginalHours = ar.Hours;
                            ar.OriginalActivityType = ar.ActivityType;
                            ar.OriginalComments = ar.Comments;
                            ar.IsNew = false;
                        }
                    });
                });
            }
        });
        
        //Add a New/Blank Record
        rowValues.push({
            ProjectId: null,
            ProjectName: null,
            ProjectTypeSort: null,
            Time_Record_Period_Staff_Member__c: timeRecordPeriodStaffMember.Id,
            DateRecord: [],
            IsNewRow: true,
            OriginalProjectId: null
        });
        
        for (i = 0; i < 7; i++) {
            rowValues[rowValues.length - 1].DateRecord.push({
                ActivityDate: displayDates[i],
                ActivityRecord: []
            });
            rowValues[rowValues.length - 1].DateRecord[i].ActivityRecord.push({
                Id: null,
                OriginalProjectId: null,
                Hours: null,
                OriginalHours: null,
                ActivityType: null,
                OriginalActivityType: null,
                Comments: null,
                OriginalComments: null,
                IsNew: true
            });
        }
        
        component.set("v.rowValues", rowValues);
    },
    addNewActivity: function(component) {
        var rowValueArray = component.get("v.rowValues");
        var displayDates = component.get("v.displayDates");
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        
        rowValueArray.forEach(function(rv) {
            rv.DateRecord.forEach(function(dr) {
                dr.ActivityRecord.forEach(function(ar) {
                    if (ar.IsNew && ar.Hours > 0 && ar.ActivityType != null) {
                        ar.OriginalHours = ar.Hours;
                        ar.OriginalActivityType = ar.ActivityType;
                        ar.OriginalComments = ar.Comments;
                        ar.IsNew = false;
                        dr.ActivityRecord.push({
                            Id: null,
                            OriginalProjectId: null,
                            Hours: null,
                            OriginalHours: null,
                            ActivityType: null,
                            OriginalActivityType: null,
                            Comments: null,
                            OriginalComments: null,
                            IsNew: true
                        });
                    }
                });
            });
        });
        
        component.set("v.rowValues", rowValueArray);
        
    },
    assignDisplayDates: function(component) {
        var startDate = component.get("v.startDate");
        
        if (!startDate) {
            var today = new Date();
            startDate = today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate();
        }
        
        var dateRange = [];
        var startDate = new Date(startDate + "  00:00:00");
        
        dateRange.push(this.formatDate(startDate));
        for (i = 1; i < 7; i++) {
            var newDate = new Date(startDate);
            newDate.setDate(newDate.getDate() + i);
            dateRange.push(this.formatDate(newDate));
        }
        
        component.set("v.displayDates", dateRange);
    },
    bubbleBeforeServerCall: function(component, helper) {
        var beforeServerCallEvent = component.getEvent("beforeServerCallEvent");
        beforeServerCallEvent.fire();
    },
    bubbleCalendarRowSaveSuccess: function(component, helper) {
        var saveSuccessEvent = component.getEvent("calendarRowSaveSuccess");
        saveSuccessEvent.fire();
    },
    onCalendarRowSaveSuccess: function(component, helper, saveOperation) {
        if(saveOperation === "NewRow" || saveOperation === "NewActivity"){
            helper.bubbleCalendarRowSaveSuccess(component, helper);
            
            if (saveOperation === "NewRow") {
                helper.addNewActivity(component);
                helper.addNewRow(component);
            } 
            else if (saveOperation === "NewActivity"){
                helper.addNewActivity(component);
            }
        }
        else if(saveOperation === "DeleteActivity")
            component.getEvent("calendarDeleteRowSuccess").fire();   
    },
    formatDate: function(dateValue) {
        //Format to pad with zero
        var monthAsString = (dateValue.getMonth() + 1).toString().length === 1 ? "0" + (dateValue.getMonth() + 1) : (dateValue.getMonth() + 1);
        var dayAsString = dateValue.getDate().toString().length === 1 ? "0" + dateValue.getDate() : dateValue.getDate();
        return dateValue.getFullYear() + "-" + monthAsString + "-" + dayAsString;
    },
    getExistingData: function(component, helper) {
        helper.assignDisplayDates(component);
        
        helper.generateRowValuesArray(component, helper);
    },
    getWeeklyTotals: function(component, helper) {
        var timeRecordTotals = component.get("v.timeRecordTotals");
        var displayDates = component.get("v.displayDates");
        var totalHours = 0.0;
        var totalChargeableHours = 0.0;
        var totalNonChargeableHours = 0.0;
        //We re-use the time record totals for the summary stats, so the range may exceed the week
        timeRecordTotals.forEach(function(tr) {
            if (displayDates.indexOf(tr.Activity_Date__c) >= 0) {
                totalHours += tr.Hours;
                if(tr.BillableHours != undefined && tr.BillableHours != null){
                totalChargeableHours += tr.BillableHours;
                }
                if(tr.NonBillableHours != undefined && tr.NonBillableHours != null){
                totalNonChargeableHours += tr.NonBillableHours;
                }
                //totalChargeableHours += tr.BillableHours;
                //totalNonChargeableHours += tr.NonBillableHours;
            }
        });

        component.set("v.totalHours", totalHours.toFixed(1));
        component.set("v.totalChargeableHours", totalChargeableHours.toFixed(1));
        component.set("v.totalNonChargeableHours", totalNonChargeableHours.toFixed(1));
        helper.generateTimeRecordTotalsArray(component, helper);
    },
    generateTimeRecordTotalsArray: function(component, helper) {
        var displayDates = component.get("v.displayDates");
        var totals = component.get("v.timeRecordTotals");
        var timeRecordTotalValues = [];

        if (displayDates && totals) {
            displayDates.forEach(function(dd) {
                var totalObject = {
                    Date: dd,
                    TotalHours: 0.0,
                    BillableHours : 0.0,
                    NonBillableHours : 0.0
                };
                totals.forEach(function(t) {
                    if (t.Activity_Date__c == dd){
                        totalObject.TotalHours = t.Hours;
                        totalObject.BillableHours = t.BillableHours;
                        totalObject.NonBillableHours = t.NonBillableHours;
                    }
                });
                timeRecordTotalValues.push(totalObject);
            });
            console.log('timeRecordTotalValues',timeRecordTotalValues)
            component.set("v.timeRecordTotalValues", timeRecordTotalValues);
        }
    },
    generateRowValuesArray: function(component, helper) {
        var displayDates = component.get("v.displayDates");
        var timeRecords = component.get("v.timeRecordDetails");
        var rowValueArray = [];
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        
        if (displayDates && timeRecords && timeRecordPeriodStaffMember) {
            //Get Distinct Project List
            rowValueArray = helper.instantiateRowValueArray(component, helper, rowValueArray, timeRecordPeriodStaffMember, displayDates);
            
            //Populate Existing Time Record Log Values
            rowValueArray = helper.populateExistingRowValueArray(component, helper, rowValueArray, displayDates);
            
            component.set("v.rowValues", rowValueArray);
            
            //Add a New/Blank Record
            helper.addNewRow(component);
        }
    },
    instantiateRowValueArray: function(component, helper, rowValueArray, timeRecordPeriodStaffMember, displayDates) {
        var timeRecordDetails = component.get("v.timeRecordDetails");
        var projectIdArray = [];
        
        //Merge the records for a single project for the week into one row with the values aggregated by date
        timeRecordDetails.forEach(function(trd) {
            if (trd.Activity_Date__c >= displayDates[0] && trd.Activity_Date__c <= displayDates[6]) {
                var projectId = trd.Opportunity__c ? trd.Opportunity__c : (trd.Engagement__c ? trd.Engagement__c : trd.Special_Project__c);
                if (projectIdArray.indexOf(projectId) < 0) {
                    var rowValue = {
                        ProjectId: projectId,
                        ProjectName: trd.Project_Name__c,
                        ProjectTypeSort: trd.Opportunity__c ? 3 : (trd.Engagement__c ? 1 : 2),
                        Time_Record_Period_Staff_Member__c: timeRecordPeriodStaffMember.Id,
                        DateRecord: [],
                        IsNewRow: false,
                        OriginalProjectId: projectId
                    };
                    
                    for (i = 0; i < 7; i++) {
                        rowValue.DateRecord.push({
                            ActivityDate: displayDates[i],
                            ActivityRecord: []
                        });
                        rowValue.DateRecord[i].ActivityRecord.push({
                            Id: null,
                            OriginalProjectId: null,
                            Hours: null,
                            OriginalHours: null,
                            ActivityType: null,
                            OriginalActivityType: null,
                            Comments: null,
                            OriginalComments: null,
                            IsNew: true
                        });
                    }
                    
                    projectIdArray.push(projectId);
                    rowValueArray.push(rowValue);
                }
            }
        });
        
        //Sort the Array
        var greaterNumber = 1;
        rowValueArray.sort(function(a, b) {
            return (a.ProjectTypeSort > b.ProjectTypeSort) ? greaterNumber : ((b.ProjectTypeSort > a.ProjectTypeSort) ? greaterNumber * -1 : (a.ProjectName > b.ProjectName) ? greaterNumber : ((b.ProjectName > a.ProjectName) ? greaterNumber * -1 : 0));
        });
        return rowValueArray;
    },
    populateExistingRowValueArray: function(component, helper, rowValueArray, displayDates) {
        var timeRecordDetails = component.get("v.timeRecordDetails");
        
        if (!timeRecordDetails)
            timeRecordDetails = [];
        
        //Populate Existing Time Record Log Values
        timeRecordDetails.forEach(function(trd) {
            rowValueArray.forEach(function(rv) {
                var projectId = trd.Opportunity__c ? trd.Opportunity__c : (trd.Engagement__c ? trd.Engagement__c : trd.Special_Project__c);
                if (projectId == rv.ProjectId) {
                    //Populate Row Data
                    for (i = 0; i < 7; i++) {
                        if (displayDates[i] == trd.Activity_Date__c) {
                            var arIndex = rv.DateRecord[i].ActivityRecord.length - 1;
                            if(rv.DateRecord[i].ActivityRecord[arIndex].Id != null){
                                arIndex++;
                                rv.DateRecord[i].ActivityRecord.push({
                                    Id: null,
                                    OriginalProjectId: null,
                                    Hours: null,
                                    OriginalHours: null,
                                    ActivityType: null,
                                    OriginalActivityType: null,
                                    Comments: null,
                                    OriginalComments: null,
                                    IsNew: true
                                });
                            }
                            rv.DateRecord[i].ActivityRecord[arIndex].Id = trd.Id;
                            rv.DateRecord[i].ActivityRecord[arIndex].OriginalProjectId = projectId;
                            rv.DateRecord[i].ActivityRecord[arIndex].Hours = trd.Hours_Worked__c;
                            rv.DateRecord[i].ActivityRecord[arIndex].Rate = trd.Hourly_Rate__c;
                            rv.DateRecord[i].ActivityRecord[arIndex].OriginalHours = trd.Hours_Worked__c;
                            rv.DateRecord[i].ActivityRecord[arIndex].ActivityType = (typeof(trd.Activity_Type__c) != "undefined" ? trd.Activity_Type__c : "");
                            rv.DateRecord[i].ActivityRecord[arIndex].OriginalActivityType = (typeof(trd.Activity_Type__c) != "undefined" ? trd.Activity_Type__c : "");
                            rv.DateRecord[i].ActivityRecord[arIndex].Comments = (typeof(trd.Comments__c) != "undefined" ? trd.Comments__c : "");
                            rv.DateRecord[i].ActivityRecord[arIndex].OriginalComments = (typeof(trd.Comments__c) != "undefined" ? trd.Comments__c : "");
                            rv.DateRecord[i].ActivityRecord[arIndex].IsNew = false;
                            if (trd.Activity_Type__c) {
                                rv.DateRecord[i].ActivityRecord.push({
                                    Id: null,
                                    OriginalProjectId: null,
                                    Hours: null,
                                    OriginalHours: null,
                                    ActivityType: null,
                                    OriginalActivityType: null,
                                    Comments: null,
                                    OriginalComments: null,
                                    IsNew: true
                                });
                            }
                        }
                    }
                }
            });
        });
        
        return rowValueArray;
    }
})