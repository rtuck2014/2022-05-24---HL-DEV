({
    getPeriods: function(component, helper) {
        var category = component.get("v.category");

        if (category) {
            helper.callServer(component, "c.GetPeriods", function(response) {
                var periods = response;
                var startDate = periods[0].Start_Date__c;
                component.set("v.periods", periods);
         
                if (category == 'FR' && periods.length > 1 && this.isPreviousWeekAvailable(new Date(periods[0].Start_Date__c), new Date(periods[1].Start_Date__c))) {
                    component.set("v.selectedPeriod", periods[1]);
                    component.set("v.startDate", periods[1].Start_Date__c);
                    component.set("v.endDate", periods[1].End_Date__c);
                    component.set("v.existingStartDate", periods[1].Start_Date__c);
                    component.set("v.existingEndDate", periods[1].End_Date__c);
                } else if(category == 'Beta' && periods.length > 3){
                    component.set("v.selectedPeriod", periods[3]);
                    component.set("v.startDate", periods[3].Start_Date__c);
                    component.set("v.endDate", periods[3].End_Date__c);
                    component.set("v.existingStartDate", periods[3].Start_Date__c);
                    component.set("v.existingEndDate", periods[3].End_Date__c);
                }
                else{
                    component.set("v.selectedPeriod", periods[0]);
                    component.set("v.startDate", periods[0].Start_Date__c);
                    component.set("v.endDate", periods[0].End_Date__c);
                    component.set("v.existingStartDate", periods[0].Start_Date__c);
                    component.set("v.existingEndDate", periods[0].End_Date__c);
                }
            }, {
                "category": category
            });
        }
    },
    onDateChanged: function(component) {
        var category = component.get("v.category");
        if (category != 'FR') {
            var startDateControl = component.find("startDate");
            var endDateControl = component.find("endDate");
            if (startDateControl && endDateControl) {
                
                var startDate = startDateControl.get("v.value");
                var endDate = endDateControl.get("v.value");
                var existingStartDate = component.get("v.existingStartDate");
                var existingEndDate = component.get("v.existingEndDate");
                var dateRangeSelectionEvt = component.getEvent("dateRangeSelectionEvent");
                //Only Fire the Event when Necessary
                if (existingStartDate != startDate || existingEndDate != endDate) {
                    component.set("v.existingStartDate", startDate);
                    component.set("v.existingEndDate", endDate);
                    dateRangeSelectionEvt.setParams({
                        "startDate": startDate,
                        "endDate": endDate
                    });
                    dateRangeSelectionEvt.fire();
                }
            }
        }
    },
    isPreviousWeekAvailable: function(a, b) {
        var _MS_PER_DAY = 1000 * 60 * 60 * 24;
        // Discard the time and time-zone information.
        var utc1 = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate());
        var utc2 = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate());
        
        return Math.floor((utc2 - utc1) / _MS_PER_DAY) <= 8; 
    }
})