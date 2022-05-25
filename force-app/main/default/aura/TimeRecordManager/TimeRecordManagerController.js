({
    doInit: function(component, event, helper) {
        helper.checkBrowser(component, helper);
        helper.getCategory(component, helper);
    },
    onSelectedStaffMemberChanged: function(component, event, helper) {
        var selectedStaffMember = event.getParam("timeRecordPeriodStaffMember");
        component.set("v.selectedTimeRecordPeriodStaffMember", selectedStaffMember);
        component.set("v.suppressSpinners", false);
        component.set("v.isStaffTimeSheetLoaded",false);
        component.set("v.renderPage", false);
        helper.getProjectSelectionObjects(component, helper);
    },
    onSelectedDateRangeChanged: function(component, event, helper) {
        var startDate = event.getParam("startDate");
        var endDate = event.getParam("endDate");
        component.set("v.suppressSpinners", false);
        component.set("v.startDate", startDate);
        component.set("v.endDate", endDate);
        component.set("v.dateRange", startDate + ' - ' + endDate);
    },
    onSelectedPeriodChanged: function(component, event, helper) {
        var selectedTimeRecordPeriod = event.getParam("timeRecordPeriod");
        component.set("v.suppressSpinners", false);
        component.set("v.isStaffTimeSheetLoaded",false);
        component.set("v.selectedTimeRecordPeriod", selectedTimeRecordPeriod);
        component.set("v.renderPage", false);
        helper.getPeriodTimeRecordStaffMember(component, helper);
    },
    onSuppressLoadingIndicatorFired: function(component, event, helper) {
        var suppress = event.getParam("suppress");
        component.set("v.suppressSpinners", suppress);
    },
    addDeleteTimeRecordSpinner: function(component,event,helper){
       component.set("v.isStaffTimeSheetLoaded", false);
        helper.hideSpinner(component,event,helper);
    },
    onStaffTimeSheetLoaded: function(component, event, helper) {
        component.set("v.isStaffTimeSheetLoaded", true);
        helper.hideSpinner(component,event,helper);
    },
    onStaffTimeSheetTabSelected: function(component, event, helper) {
        helper.staffTimeSheetTabSelected(component, event, helper);
    },
    onStaffTimeSheetWeekLoaded: function(component, event, helper) {
        component.set("v.isStaffTimeSheetWeekLoaded", true);
    },
    onTabStaffClick: function(component, event, helper) {
        helper.setActiveTab(component, "tab-heading-staff", ["tab-heading-billing", "tab-heading-ratesheet"]);
    },
    onTabBillingClick: function(component, event, helper) {
        helper.setActiveTab(component, "tab-heading-billing", ["tab-heading-staff", "tab-heading-ratesheet"]);
    },
    onTabRateSheetClick: function(component, event, helper) {
        helper.setActiveTab(component, "tab-heading-ratesheet", ["tab-heading-billing", "tab-heading-staff"]);
        component.set("v.periodPickerClass", "hidden");
    },
    onTimeRecordPeriodStaffMemberTileListLoaded: function(component, event, helper) {
        component.set("v.isTimeRecordPeriodStaffMemberTileListLoaded", true);
    },
    onTimeRecordPeriodPickerLoaded: function(component, event, helper) {
        component.set("v.isTimeRecordPeriodPickerLoaded", true);
    },
    showSpinner: function(component, event, helper) {
        if (!component.get("v.suppressSpinners"))
            helper.toggleSpinner(component, false);
    },
    hideSpinner: function(component, event, helper) {
        helper.hideSpinner(component,event,helper);
    }
})