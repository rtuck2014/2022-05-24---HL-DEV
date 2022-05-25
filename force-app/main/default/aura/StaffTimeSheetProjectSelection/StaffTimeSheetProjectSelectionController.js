({
    doInit : function(component, event, helper) {
        helper.buildSelections(component, helper);
	},
	onProjectChanged: function(component, event, helper) {
		helper.onProjectSelected(component, helper);
	}
})