({
    loadData: function (component) {
      let objectApiName = component.get("v.objectApiName");
  
      if (!objectApiName) {
        component.set("v.isLoaded", true);
  
        return;
      }
  
      var request = {
        recordId: component.get("v.recordId"),
        sObjectName: component.get("v.sObjectName"),
        objectApiName: component.get("v.objectApiName"),
        relationshipFieldApiName: component.get("v.relationshipFieldApiName"),
        titleField: component.get("v.titleField"),
        fields: component.get("v.fields"),
        whereClause: component.get("v.whereClause"),
        orderByClause: component.get("v.orderByClause")
      };
  
      var action = component.get("c.loadData");
      action.setParams({ requestJson: JSON.stringify(request) });
  
      action.setCallback(this, function (response) {
        var state = response.getState();
  
        if (state === "SUCCESS") {
          var result = response.getReturnValue();
  
          var overrideTitle = component.get("v.overrideTitle");
          var overrideIconName = component.get("v.overrideIconName");
  
          component.set("v.title", overrideTitle ? overrideTitle : result.title);
          component.set(
            "v.iconName",
            overrideIconName ? overrideIconName : result.iconName
          );
  
          var rows = result.items;
          component.set("v.rows", rows);
  
          var columns = [{ label: "Name", fieldName: "name" }];
          columns = columns.concat(result.fields);
          component.set("v.columns", columns);
        } else if (state === "INCOMPLETE") {
          // TODO - handle this correctly
        } else if (state === "ERROR") {
          var errors = response.getError();
  
          if (errors) {
            if (errors[0] && errors[0].message) {
              console.log("Error message: " + errors[0].message);
            }
          } else {
            console.log("Unknown error");
          }
        }
  
        component.set("v.isLoaded", true);
      });
  
      component.set("v.isLoaded", false);
  
      $A.enqueueAction(action);
    },
  
    calculateDisplayRows: function (component) {
      var rows = component.get("v.rows");
      var isExpanded = component.get("v.isExpanded");
  
      if (rows) {
        component.set("v.totalRows", rows.length);
      } else {
        component.set("v.totalRows", 0);
      }
  
      if (isExpanded) {
        component.set("v.displayRows", rows);
      } else {
        var maximumDisplayRows = component.get("v.maximumDisplayRows");
  
        var displayRows = [];
  
        if (rows) {
          var i = 0;
          while (i < rows.length && i < maximumDisplayRows) {
            displayRows.push(rows[i++]);
          }
        }
  
        component.set("v.displayRows", displayRows);
      }
  
      let gridDisplayRows = [];
  
      let newDisplayRows = component.get("v.displayRows");
  
      for (let i = 0; i < newDisplayRows.length; i++) {
        let row = {};
  
        row.name = newDisplayRows[i].recordName;
  
        for (let j = 0; j < newDisplayRows[i].values.length; j++) {
          let cell = newDisplayRows[i].values[j];
  
          row[cell.fieldName] = cell.value;
        }
  
        gridDisplayRows.push(row);
      }
  
      component.set("v.gridDisplayRows", gridDisplayRows);
    },
  
    setupFooter: function (component) {
      var isExpanded = component.get("v.isExpanded");
      var displayRows = component.get("v.displayRows");
      var totalRows = component.get("v.totalRows");
  
      var displayRowsLength = displayRows ? displayRows.length : 0;
  
      if (displayRowsLength == totalRows) {
        component.set("v.footer", undefined);
      } else {
        if (isExpanded) {
          component.set("v.footer", "View Less");
        } else {
          component.set("v.footer", "View All");
        }
      }
    },
  
    createNewRecord: function (component) {
      var objectApiName = component.get("v.objectApiName");
      var relationshipFieldApiName = component.get("v.relationshipFieldApiName");
      var recordId = component.get("v.recordId");
  
      var createRelatedRecordEvent = $A.get("e.force:createRecord");
  
      var defaultFieldValues = {};
  
      defaultFieldValues[relationshipFieldApiName] = recordId;
  
      createRelatedRecordEvent.setParams({
        entityApiName: objectApiName,
        defaultFieldValues: defaultFieldValues
      });
  
      createRelatedRecordEvent.fire();
    }
  });