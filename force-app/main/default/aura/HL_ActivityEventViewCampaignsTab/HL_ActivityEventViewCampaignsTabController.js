({
    init: function (component, event, helper) {
      component.set("v.columns", [
        { label: "Campaign Name", fieldName: "Name", type: "text" },
        { label: "Campaign Type", fieldName: "RecordType.name", type: "text" }, // TODO won't work
        { label: "Sub-Type", fieldName: "Type", type: "text" }
      ]);
    }
  });