({
	doInit : function(cmp, event, helper) {
		 var workspaceAPI = cmp.find("workspace");
        // handles checking for console and standard navigation and then navigating to the component appropriately        
        var myPageRef = cmp.get("v.pageReference");
        var id = myPageRef.state.c__id;
        cmp.set("v.id", id);        
        workspaceAPI.isConsoleNavigation().then(function(isConsole) {
            if (isConsole) {            
                workspaceAPI.getEnclosingTabId().then(function(response){                    
                    workspaceAPI.setTabLabel({                    
                        tabId:response.tabId,
                        label:"Counterparty Editor"
                    });
                    workspaceAPI.focusTab({tabId : response.tabId});
                });
            }       
        });
	}
})