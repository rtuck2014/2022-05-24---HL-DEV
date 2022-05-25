({
    init : function(component, event, helper) {
        /*Get workspace reference from component*/
        var workspaceAPI = component.find("workspace");
        /*Set the Tab icon*/
        var varIcon = 'custom:custom24';
        
        /*Get Current tab info and add the sub tab in current tab redirect to compoent to show the data.*/
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openSubtab({
                parentTabId: focusedTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__redirectCFEngagementSummary"
                    },
                    "state": {
                        c__recordId: component.get('v.recordId')
                    }
                    
                },
                focus: true
            }).then(function(subtabId) {
                console.log("The new subtab ID is:" , subtabId);
                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: 'Engagement Summary'
                });
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: 'standard:budget',
                    iconAlt: "Engagement Summary"
                });
                 
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire()
                
            }).catch(function(error) {
                console.log("error"+JSON.stringify(error));
            });
            
            
        }).catch(function(error) {
            //when workspace api gives error then directly redirect to LWC Component.
            console.log("error"+JSON.stringify(error));
            var pageRef ={
                type: 'standard__component',
                attributes:{
                    componentName:'c__redirectCFEngagementSummary'
                },
                state:{
                    c__recordId: component.get('v.recordId')
                }
            };
            var navService = component.find("navService");
            navService.navigate(pageRef);
        });
    },
    // function automatic called by aura:waiting event.
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner
        component.set("v.spinner", true);
    },
    // function automatic called by aura:doneWaiting event
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner
        component.set("v.spinner", false);
    },
})