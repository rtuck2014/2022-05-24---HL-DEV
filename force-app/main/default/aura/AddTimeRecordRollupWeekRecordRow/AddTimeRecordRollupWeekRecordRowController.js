({
	doInit : function(component, event, helper) {
        helper.getOpportunities(component, helper);
        helper.getEngagements(component, helper);
        helper.getSpecialProjects(component, helper);
	},
    addRecord : function(component, event, helper){
        helper.addTimeRecord(component, helper);
    },
    handleStaffMemberChangedEvent : function(component, event, helper){
        helper.getOpportunities(component, helper);
        helper.getEngagements(component, helper);
    },
    onProjectChanged : function(component){
        var requireComments = false;
        var selectedProject = component.find("project").get("v.value");
        var specialProjects = component.get("v.specialProjects");
        specialProjects.filter(function(sp) {if(sp.Id === selectedProject && sp.Require_Comments__c) requireComments = true;});
        component.set("v.requireComments", requireComments);
        component.set("v.showError", false);
        component.set("v.showSuccess",false);
    }
})