({
    doInit : function(cmp, event, helper) {
        var workspaceAPI = cmp.find("workspace");
        var navService = cmp.find("navService");
        //console.log('navCmpController:'+cmp.get("v.recordId"));
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__hlEngagementCounterPartyContact'
            },
            state: {
                "c__id":cmp.get("v.recordId"),
                "c__recordId":cmp.get("v.recordId")
            }
        };
       // navService.navigate(pageReference);  
        workspaceAPI
        .isConsoleNavigation()
        .then(function(isConsole) {
            if (isConsole) {
                //  // in a console app - generate a URL and then open a subtab of the currently focused parent tab
                navService.generateUrl(pageReference).then(function(cmpURL) {
                    workspaceAPI
                    .getEnclosingTabId()
                    .then(function(tabId) {
                        return workspaceAPI.openSubtab({
                            parentTabId: tabId,
                            url: cmpURL,
                            focus: true
                        });
                    })
                    .then(function(subTabId) {
                        // the subtab has been created, use the Id to set the label
                        workspaceAPI.setTabLabel({
                            tabId: subTabId,
                            label: "Engagement Counterparty Contact"
                        });
                        workspaceAPI.setTabIcon({
                            tabId: subTabId,
                            icon: 'utility:groups',
                            iconAlt: "Engagement Counterparty Contact"
                        });
                    });
                });
            } else {
                // this is standard navigation, use the navigate method to open the component
                navService.navigate(pageReference, false);
            }
        })
        .catch(function(error) {
            console.log(error);
        });
        $A.get("e.force:closeQuickAction").fire();
    }     
})