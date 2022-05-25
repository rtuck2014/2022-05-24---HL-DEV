({
    fetchData: function (component) {
      console.log("fetchData begin");
  
      let recordId = component.get("v.recordId");
  
      console.log("recordId", recordId);

      if (!recordId) {
        let myPageRef = component.get("v.pageReference");
    	recordId = myPageRef.state.c__id;

        console.log("recordId from pageReference", recordId);
      }
  
      component.set("v.spinner", true);
  
      this.fetchAndAssign(
        component,
        "getModel",
        { recordId: recordId },
        "model",
        function (result) {
          component.set("v.spinner", false);
  
          if (result.Activity.Private__c) {
            result.Activity.Type = "private";
            result.Activity.Subject = "private";
            result.Activity.Description = "private";
            result.ActivitySupplement.Internal_Notes__c = "private";
            result.Activity.Industry_Group__c = "private";
            result.Activity.Product_Type__c = "private";
            result.Activity.Purpose__c = "private";
  
            component.set("v.model", result);
          }
  
          console.log("getModel", JSON.stringify(result)); // TODO - remove, security risk!
  
          // TODO - anything else?
        }
      );
    }
  });