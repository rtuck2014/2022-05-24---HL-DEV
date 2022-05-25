({
    addRecord: function(component, helper) {
        var engagementTitleRateSheet = component.get("v.engagementTitleRateSheet");
        var engagement = component.get("v.engagement");

        if (engagement)
            engagementTitleRateSheet.Engagement__c = engagement.Id;

        if (helper.validateInput(component, engagementTitleRateSheet)) {
            try {
                helper.callServer(component, "c.InsertRecord", function(response) {
                    if (response && response.Id != null) {
                        component.set("v.showError", false);

                        helper.showToast(component);

                        helper.clearFields(component);

                        var successEvent = component.getEvent("saveSuccessEvent");
                        successEvent.fire();
                    }
                }, {
                    "engagementTitleRateSheet": engagementTitleRateSheet
                });
            } catch (errors) {
                component.set("v.showError", true);

                if (errors[0].pageErrors && errors[0].pageErrors.length > 0)
                    component.set("v.errorMessage", errors[0].pageErrors[0].message);
                else if (errors[0].fieldErrors)
                    component.set("v.errorMessage", 'Invalid Field Value');
                else
                    component.set("v.errorMessage", 'Error Adding the Record');
            }
        }
    },
    clearFields: function(component) {
        component.set("v.engagementTitleRateSheet", {
            "sobjectType": "Engagement_Title_Rate_Sheet__c",
            "Title_Rate_Sheet__c": null,
            "Start_Date__c": null,
            "End_Date__c": null
        });

    },
    getTitleRateSheets: function(component, helper) {
        helper.callServer(component, "c.GetTitleRateSheets", function(response) {
            component.set("v.titleRateSheets", response);
        });
    },
    handleCallbackError: function(component, event, helper) {
        var errors = event.getParam("errorObject");
        var firstError = errors[0];

        component.set("v.showError", true);

        if (firstError.pageErrors && firstError.pageErrors.length > 0)
            component.set("v.errorText", firstError.pageErrors[0].message);
        else if (firstError.fieldErrors && firstError.fieldErrors.Start_Date__c)
            component.set("v.errorText", firstError.fieldErrors.Start_Date__c[0].message);
        else
            component.set("v.errorText", 'Unable to Add Record');
    },
    showToast: function(component) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent != null) {
            toastEvent.setParams({
                "title": "Success!",
                "message": "Rate Sheet Added."
            });
            toastEvent.fire();
        } else
            component.set("v.showSuccess", true);
    },
    validateInput: function(component, engagementTitleRateSheet) {
        var isValid = true;
        var msg = "";

        if (engagementTitleRateSheet.Engagement__c == null)
            msg += (msg === '' ? '' : '\r\n') + "Engagement Required";

        if (engagementTitleRateSheet.Title_Rate_Sheet__c == null)
            msg += (msg === '' ? '' : '\r\n') + "Title Rate Sheet Required";

        if (engagementTitleRateSheet.Start_Date__c == null)
            msg += (msg === '' ? '' : '\r\n') + "Start Date Required";

        if (msg != '') {
            isValid = false;
            component.set("v.showError", true);
            component.set("v.errorText", msg);
        } else
            component.set("v.showError", false);

        return isValid;
    }
})