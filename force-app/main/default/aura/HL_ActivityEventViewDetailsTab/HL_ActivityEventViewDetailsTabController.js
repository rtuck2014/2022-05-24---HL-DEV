({
    handleEdit: function (component, event, helper) {
        component.set("v.currentState", "editing");
    },
  
    handleSave: function (component, event, helper) {
      let model = component.get("v.model");
  
    helper.fetchAndAssign(
        component,
        "saveRec",
        { jsonModel: JSON.stringify(model), retURL: "" },
        "model",
        function (result) {
          console.log("saveRec", JSON.stringify(result)); // TODO - remove, security risk!
  
          component.set("v.errors", result.apexMessages);
  
          // TODO - anything else?
        }
      );
  
    },
  
    handleCancel: function (component, event, helper) {
        console.log("cancel");
      component.set("v.currentState", "viewing");
    },
  
    handleEditInternalNotes: function (component, event, helper) {
      var modalBody;
  
      let model = component.get("v.model");
  
      $A.createComponent(
        "c:HL_ActivityEventViewInternalNotesEdit",
        { model: model },
        function (content, status) {
          if (status === "SUCCESS") {
            modalBody = content;
  
            component.find("overlayLib").showCustomModal({
              body: modalBody,
              showCloseButton: true
            });
          }
        }
      );
    },
  
    handleDelete: function (component, event, helper) {},
  
    handleSendNotification: function (component, event, helper) {},
  
    handleViewReport: function (component, event, helper) {}
  });