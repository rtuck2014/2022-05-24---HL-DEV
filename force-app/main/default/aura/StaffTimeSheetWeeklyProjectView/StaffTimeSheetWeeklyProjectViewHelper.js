({
    populateTable: function(component, helper) {
        var timeRecordsExternal = component.get("v.timeRecordsExternal");
        var timeRecordsTotalExternal = component.get("v.timeRecordsTotalExternal");

        this.getEngagements(component, helper);
        this.getOpportunities(component, helper);
        this.getSpecialProjects(component, helper);
        this.assignDisplayDates(component);

        component.set("v.timeRecords", timeRecordsExternal);
        component.set("v.timeRecordTotals", timeRecordsTotalExternal);
    },
    getEngagements: function(component, helper) {
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        var startDate = component.get("v.startDate");
        var endDate = component.get("v.endDate");
        if (staffMember && this.isValidDate(startDate) && this.isValidDate(endDate)) {
            helper.callServer(component, "c.GetEngagementsAtPointInTime", function(response) {
                component.set("v.engagements", response);
                this.generateProjectArray(component, "v.engagements");
            }, {
                "userId": staffMember.User__c,
                "startDate": startDate,
                "endDate": endDate
            });
        }
    },
    getOpportunities: function(component, helper) {
        var staffMember = component.get("v.timeRecordPeriodStaffMember");
        var category = component.get("v.category");
        if (staffMember) {
            helper.callServer(component, "c.GetOpportunities", function(response) {
                component.set("v.opportunities", response);
                this.generateProjectArray(component, "v.opportunities");
            }, {
                "category": category,
                "userId": staffMember.User__c
            });
        }
    },
    getSpecialProjects: function(component, helper) {
        helper.callServer(component, "c.GetSpecialProjects", function(response) {
            component.set("v.specialProjects", response);
            this.generateProjectArray(component, "v.specialProjects");
        });
    },
    getWeeklyTotals: function(component) {
        var timeRecordTotals = component.get("v.timeRecordTotals");
        var displayDates = component.get("v.displayDates");
        var totalHours = 0.0;
        var totalChargeableHours = 0.0;
        var totalNonChargeableHours = 0.0;
        console.error('timeRecordTotals1>>>'+JSON.stringify(component.get("v.timeRecordTotals")));

        timeRecordTotals.forEach(function(tr) {
            if (displayDates.indexOf(tr.Activity_Date__c) >= 0) {
                totalHours += tr.Hours;
                console.log('trBillable>>>'+tr.BillableHours);
                console.log('trNonBillable>>>'+tr.NonBillableHours);
                if(tr.BillableHours != undefined && tr.BillableHours != null){
                totalChargeableHours += tr.BillableHours;
                }
                if(tr.NonBillableHours != undefined && tr.NonBillableHours != null){
                totalNonChargeableHours += tr.NonBillableHours;
                }
            }
        });

        component.set("v.totalHours", totalHours.toFixed(1));
        component.set("v.totalChargeableHours", totalChargeableHours.toFixed(1));
        component.set("v.totalNonChargeableHours", totalNonChargeableHours.toFixed(1));
        this.generateTimeRecordTotalsArray(component);
    },
    isValidDate: function(dateValue) {
        if (Object.prototype.toString.call(dateValue) === "[object String]")
            dateValue = new Date(dateValue);
        return Object.prototype.toString.call(dateValue) === "[object Date]" && !isNaN(dateValue.getTime()) && dateValue.getFullYear() >= 2015;
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
        this.generateAllProjectArrays(component);

    },
    formatDate: function(dateValue) {
        //Format to pad with zero
        var monthAsString = (dateValue.getMonth() + 1).toString().length === 1 ? "0" + (dateValue.getMonth() + 1) : (dateValue.getMonth() + 1);
        var dayAsString = dateValue.getDate().toString().length === 1 ? "0" + dateValue.getDate() : dateValue.getDate();
        return dateValue.getFullYear() + "-" + monthAsString + "-" + dayAsString;
    },
    generateAllProjectArrays: function(component) {
        this.generateProjectArray(component, "v.opportunities");
        this.generateProjectArray(component, "v.engagements");
        this.generateProjectArray(component, "v.specialProjects");
    },
    generateProjectArray: function(component, projectProperty) {
        var displayDates = component.get("v.displayDates");
        var projects = component.get(projectProperty);
        var timeRecords = component.get("v.timeRecords");
        
        if (displayDates && projects && timeRecords) {
            var projectValues = [];
            projects.forEach(function(p) {
                var totalHours = 0;
                
                var projectObject = {
                    Name: p.Name,
                    LOB: p.Line_of_Business__c ? p.Line_of_Business__c : '',
                    Number: p.Engagement_Number__c ? p.Engagement_Number__c : p.Opportunity_Number__c ? p.Opportunity_Number__c : '',
                    Day01: null,
                    Day02: null,
                    Day03: null,
                    Day04: null,
                    Day05: null,
                    Day06: null,
                    Day07: null
                };
                for (i = 0; i < 7; i++) {
                    timeRecords.forEach(function(tr) {
                        if ((tr.Special_Project__c == p.Id || tr.Engagement__c == p.Id || tr.Opportunity__c == p.Id) && tr.Activity_Date__c == displayDates[i]) {
                            switch (i) {
                                case 0:
                                    projectObject.Day01 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                                case 1:
                                    projectObject.Day02 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                                case 2:
                                    projectObject.Day03 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                                case 3:
                                    projectObject.Day04 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                                case 4:
                                    projectObject.Day05 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                                case 5:
                                    projectObject.Day06 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                                default:
                                    projectObject.Day07 = tr.Hours;
                                    totalHours += (tr.Hours || 0);
                                    break;
                            }
                        }
                    });
                }
                if (totalHours > 0) {
                    projectValues.push(projectObject);
                }
            });
            switch (projectProperty) {
                case "v.engagements":
                    component.set("v.engagementValues", projectValues);
                    break;
                case "v.opportunities":
                    component.set("v.opportunityValues", projectValues);
                    break;
                default:
                    component.set("v.specialProjectValues", projectValues);
                    break;
            }
        }
    },
    generateTimeRecordTotalsArray: function(component) {
        var displayDates = component.get("v.displayDates");
        var totals = component.get("v.timeRecordTotals");
                console.error('timeRecordTotals>>>'+JSON.stringify(component.get("v.timeRecordTotals")));
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
            component.set("v.timeRecordTotalValues", timeRecordTotalValues);
        }
    }
})