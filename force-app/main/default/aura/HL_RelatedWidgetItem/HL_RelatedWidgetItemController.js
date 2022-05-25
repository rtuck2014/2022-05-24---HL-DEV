({
    handleLinkClick: function (component, event, helper) {
      helper.navigateToRecord(component);
  
      event.preventDefault();
    }
  });