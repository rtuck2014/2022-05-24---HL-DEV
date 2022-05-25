({
    init : function(component, event, helper) {
        /*Get workspace reference from component*/
        var pageRef = component.get('v.pageReference');
        var recordId = pageRef.state.c__recordId;
        var type = pageRef.state.c__type;

        component.set('v.recordId',recordId);
        component.set('v.recordType',type);
        var workspaceAPI = component.find("workspace");
        /*Set the Tab icon*/
        var varIcon = 'custom:custom24';
        
        /*Get Current tab info and add the sub tab in current tab redirect to compoent to show the data.*/
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.openTab({
               // parentTabId: focusedTabId,
                /*pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__showHL_InternalTeamView"
                    },
                    "state": {
                        c__recordId: component.get('v.recordId'),
                        c__type : component.get('v.recordType')
                    }
                    
                },*/
                url: '/lightning/cmp/c__showHL_InternalTeamView?c__recordId='+component.get('v.recordId')+'&c__type='+component.get('v.recordType'),
                focus: true
            }).then(function(subtabId) {
                console.log("The new subtab ID is:" , subtabId);
                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: 'Internal Team'
                });
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: 'utility:people',
                    iconAlt: "Internal Team"
                });
                
                workspaceAPI.closeTab({tabId:focusedTabId})
                 
                ///var dismissActionPanel = $A.get("e.force:closeQuickAction");
                //dismissActionPanel.fire()
                
            }).catch(function(error) {
                console.log("error"+JSON.stringify(error));
            });
            
            
        }).catch(function(error) {
            //when workspace api gives error then directly redirect to LWC Component.
            console.log("error"+JSON.stringify(error));
            var pageRef ={
                type: 'standard__component',
                attributes:{
                    componentName:'c__showHL_InternalTeamView'
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