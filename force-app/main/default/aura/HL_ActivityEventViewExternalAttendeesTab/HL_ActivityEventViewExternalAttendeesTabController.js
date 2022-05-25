({
    init: function (component, event, helper) {
      component.set("v.columns", [
        { label: "Primary", fieldName: "Primary", type: "boolean" },
        { label: "Contact Name", fieldName: "contactName", type: "text" },
        { label: "Account Name", fieldName: "accountName", type: "text" },
        { label: "Title", fieldName: "contactTitle", type: "text" },
        { label: "Email", fieldName: "contactEmail", type: "email" },
        { label: "Phone", fieldName: "contactPhone", type: "phone" },
        { label: "Mobile Phone", fieldName: "contactMobilePhone", type: "phone" }
      ]);
    },
  
    handleSelectedExternalContact: function(component, event, helper) {
      var selectedRecord = event.getParam("recordId"); 
      console.log("handle", selectedRecord, JSON.stringify(event)); 
      component.set("v.selectedRecord", selectedRecord);
    },
  
    handleRemoveAttendee: function(component, event, helper) {
      let id = event.srcElement.name;
  
      let relatedContacts = component.get("v.model.RelatedContacts");
  
      for (let i = 0; i < relatedContacts.length; i++) {
          if (relatedContacts[i].contactId == id) {
              relatedContacts.splice(i, 1);
  
              break;
          }
      }
  
      component.set("v.model.RelatedContacts", relatedContacts);
  
      console.log("Remove", id);
    },
  
    handlePrimaryChange: function(component, event, helper) {
      let id = event.srcElement.name;
  
      let model = component.get("v.model");
      let relatedContacts = model.RelatedContacts;
  
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
          "AddContact",
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