({
  onCategoryChanged: function(component, event, helper) {
    helper.getPeriods(component, helper);
  },
  onEndDateChanged: function(component, event, helper) {
    helper.onDateChanged(component);
  },
  onStartDateChanged: function(component, event, helper) {
    helper.onDateChanged(component);
  },
  onSelectionChanged: function(component, event) {

    var periodPicker = component.find("timePeriodPicker");
    var selectionEvent = component.getEvent("selectionEvent");
    var periodId = periodPicker.get("v.value");
    var periods = component.get("v.periods");
    var selectedPeriod = periods.filter(function(f) {
      return f.Id === periodId;
    })[0];
      
    if (selectedPeriod) {
      var dateRangeSelectionEvt = component.getEvent("dateRangeSelectionEvent");

      component.set("v.existingStartDate", selectedPeriod.Start_Date__c);
      component.set("v.existingEndDate", selectedPeriod.End_Date__c);
      selectedPeriod.Id = periodId;
      dateRangeSelectionEvt.setParams({
        "startDate": selectedPeriod.Start_Date__c,
        "endDate": selectedPeriod.End_Date__c
      });

      dateRangeSelectionEvt.fire();

      var selectionEvt = component.getEvent("timeRecordPeriodSelectionEvent");
      component.set("v.selectedPeriod", selectedPeriod);

      selectionEvt.setParams({
        "timeRecordPeriod": selectedPeriod
      });
      selectionEvt.fire();
    }
  }
})