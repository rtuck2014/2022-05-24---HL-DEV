({
    init: function (component, event, helper) {
      component.set("v.columns", [
        { label: "Company", fieldName: "Name", type: "text" },
        { label: "Billing City", fieldName: "BillingCity", type: "text" },
        { label: "Billing State", fieldName: "BillingState", type: "text" },
        { label: "Billing Country", fieldName: "BillingCountry", type: "text" }
      ]);
    }
  });