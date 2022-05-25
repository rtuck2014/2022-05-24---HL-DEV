/*
    @author Graham MacRobie (graham.macrobie1129@hl.com)
    @date   February 2022
*/

({
	doInit : function(component, event, helper) {
        let reportDeveloperNames = component.get("v.reportDeveloperName").split(",");
        let titles = component.get("v.title").split(",");

        component.set("v.currentReportDeveloperName", reportDeveloperNames[0]);
        component.set("v.currentTitle", titles[0]);

        let reportMenuItems = [];

        for (let i = 0; i < reportDeveloperNames.length; i++) {
            reportMenuItems.push({
                label : titles[i],
                value : reportDeveloperNames[i] + "," + titles[i]
            });
        }

        component.set("v.reportMenuItems", reportMenuItems);

		helper.loadData(component);
	},

	handleViewButton : function(component, event, helper) {
		var mode = component.get("v.viewButtonMode");

		component.set("v.viewButtonMode", (mode == "All") ? "Less" : "All");

		helper.displayRows(component);
	},

	handleDetailsButton : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");

		urlEvent.setParams({
			url : '/' + component.get('v.reportId')
		});

		urlEvent.fire();
    },

    handleNewActivity : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");

		urlEvent.setParams({
            url : '/lightning/cmp/c__HL_ActivityEventAuraView'
		});

		urlEvent.fire();
    },

    handleSelect : function(component, event, helper) {
        let values = event.getParam("value").split(",");

        component.set("v.currentReportDeveloperName", values[0]);
        component.set("v.currentTitle", values[1]);

        helper.loadData(component);
    },
    
    // Client-side controller called by the onsort event handler
    updateColumnSorting : function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        console.log('update column sorting', fieldName, sortDirection);
        
        // assign the latest attribute with the sorted column fieldName and sorted direction
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        
        helper.sortData(component, fieldName, sortDirection);
    }
})