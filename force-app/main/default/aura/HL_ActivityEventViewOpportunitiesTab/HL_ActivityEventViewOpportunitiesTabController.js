({
    init: function (component, event, helper) {
      component.set("v.columns", [
        { label: "Opportunity", fieldName: "Name", type: "text" },
        { label: "Client Name", fieldName: "Client__r.Name", type: "text" }, // TODO won't work
        { label: "Subject Name", fieldName: "Subject__r.Name", type: "text" }, // TODO won't work
        {
          label: "Line of Business",
          fieldName: "Line_of_Business__c",
          type: "text"
        },
        { label: "Job Type", fieldName: "Job_Type__c", type: "text" },
        { label: "Industry Group", fieldName: "Industry_Group__c", type: "text" },
        { label: "Stage", fieldName: "Stage__c", type: "text" }
      ]);
    }
  });