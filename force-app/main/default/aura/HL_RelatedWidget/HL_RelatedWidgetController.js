({
    doInit: function (component, event, helper) {
      helper.setupFooter(component);
      helper.loadData(component);
    },
  
    handleLoadData: function (component, event, helper) {
      helper.loadData(component);
    },
  
    handleNew: function (component, event, helper) {
      helper.createNewRecord(component);
    },
  
    handleFooterChange: function (component, event, helper) {
      helper.setupFooter(component);
    },
  
    handleFooterClick: function (component, event, helper) {
      var isExpanded = component.get("v.isExpanded");
  
      component.set("v.isExpanded", !isExpanded);
  
      event.preventDefault();
    },
  
    handleCalculateDisplayRows: function (component, event, helper) {
      helper.calculateDisplayRows(component);
    }
  });