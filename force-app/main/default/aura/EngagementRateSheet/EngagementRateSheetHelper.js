({
    deleteRecord: function(component, helper, id) {
        helper.callServer(component, "c.DeleteRecord", function(response) {
            this.getEngagementTitleRateSheetList(component, helper);
        }, {
            "id": id
        });
    },
    getEngagementList: function(component, helper) {
        var category = component.get("v.category");
        helper.callServer(component, "c.GetEngagements", function(response) {
            var engagementList = response;
            component.set("v.engagements", engagementList);
        }, {"category": category});
    },
    getEngagementTitleRateSheetList: function(component, helper) {
        var selectedEngagement = component.get("v.selectedEngagement");

        component.set("v.showError", false);

        if (selectedEngagement && selectedEngagement.Id) {
            helper.callServer(component, "c.GetEngagementTitleRateSheets", function(response) {
                component.set("v.engagementRateSheets", response);
                component.set("v.detailsClass", "");
            }, {
                "engagementId": selectedEngagement.Id
            });
        } else {
            component.set("v.engagementRateSheets", null);
            component.set("v.detailsClass", "hidden");
        }
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
            component.set("v.errorText", "Unable to Add Record");
    },
    onEngagementChange: function(component, helper) {
        var engagementList = component.find("engagementList");
        var engagementId = engagementList.get("v.value");
        var engagementName = engagementList.get("v.label");
        var selectedEngagement = component.get("v.selectedEngagement");

        selectedEngagement.Id = engagementId;
        selectedEngagement.Name = engagementName;

        component.set("v.selectedEngagement", selectedEngagement);

        this.getEngagementTitleRateSheetList(component, helper);
    },
    updateEngagementTitleRateSheet: function(component, helper, id, field, value) {
        var engagementTitleRateSheet = field === "Start_Date__c" ? {
            "sobjectType": "Engagement_Title_Rate_Sheet__c",
            "Id": id,
            "Start_Date__c": value
        } : {
            "sobjectType": "Engagement_Title_Rate_Sheet__c",
            "Id": id,
            "End_Date__c": value
        };

        helper.callServer(component, "c.UpdateRecord", function(response) {
            component.set("v.showError", false);
        }, {
            "engagementTitleRateSheet": engagementTitleRateSheet
        });
    }
})