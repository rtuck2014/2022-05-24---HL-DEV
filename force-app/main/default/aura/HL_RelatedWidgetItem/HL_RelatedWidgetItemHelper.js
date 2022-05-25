({
    navigateToRecord: function (component) {
      var recordId = component.get("v.itemData.recordId");
      var isRedirect = component.get("v.isRedirect");
  
      var navEvt = $A.get("e.force:navigateToSObject");
  
      navEvt.setParams({
        recordId: recordId,
        isredirect: isRedirect // TODO - this doesn't seem to work as expected, may be a SF bug
      });
  
      navEvt.fire();
    }
  });