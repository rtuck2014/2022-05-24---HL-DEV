({
    init: function (component, event, helper) {
      component.set("v.columns", [
        { label: "Primary", fieldName: "Primary", type: "boolean" },
        { label: "Employee", fieldName: "employeeName", type: "text" },
        { label: "Title", fieldName: "employeeTitle", type: "text" },
        { label: "Email", fieldName: "employeeEmail", type: "email" },
        { label: "Phone", fieldName: "employeePhone", type: "phone" }
      ]);
    },
  
    handleSelectedInternalContact: function(component, event, helper) {
      var selectedRecord = event.getParam("recordId"); 
      console.log("handle", selectedRecord, JSON.stringify(event)); 
      component.set("v.selectedRecord", selectedRecord);
    },
  
    handleRemoveAttendee: function(component, event, helper) {
      let id = event.srcElement.name;
  
      let relatedContacts = component.get("v.model.HLEmployees");
  
      for (let i = 0; i < relatedContacts.length; i++) {
          if (relatedContacts[i].contactId == id) {
              relatedContacts.splice(i, 1);
  
              break;
          }
      }
  
      component.set("v.model.HLEmployees", relatedContacts);
  
      console.log("Remove", id);
    },
  
    handlePrimaryChange: function(component, event, helper) {
      let id = event.srcElement.name;
  
      let model = component.get("v.model");
      let relatedContacts = model.HLEmployees;
  
      if (event.srcElement.checked) {
          for (let i = 0; i < relatedContacts.length; i++) {
              relatedContacts[i].Primary = (relatedContacts[i].contactId == id);
          }
  
          component.set("v.model", model);
      }
  
      console.log("primary change", id);
    },
  
    handleAddAttendee: function(component, event, helper) {
        let model = component.get("v.model");
  
        let selectedRecord = component.get("v.selectedRecord");
        console.log("selectedRecord", selectedRecord);
        model.SelectedContactId = selectedRecord;
  
        let lookup = component.find("contactLookup");
        lookup.handleRemove(event);
        //lookup.set("v.selectedRecord", undefined);
  
      helper.fetchAndAssign(
          component,
          "AddEmployee",
          { jsonModel: JSON.stringify(model) },
          "model",
          function (result) {
            console.log("getModel", JSON.stringify(result)); // TODO - remove, security risk!
  
            component.set("v.errors", result.apexMessages);
    
            // TODO - anything else?
          }
        );
    
    }  
  });