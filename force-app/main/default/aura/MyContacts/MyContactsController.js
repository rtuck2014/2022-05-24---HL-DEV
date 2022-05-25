({
    doInit : function(component, event, helper) {
        component.set("v.objectType", "Contact");
        helper.getSearchResultsByName(component, event, helper);
    },
    activityAdded:function(component, event){
        component.set("v.isAddingActivity", false);
        $A.get("e.force:refreshView").fire();
    },
    addActivity : function(component, event){
        var source = event.getSource();
        var attributes = source.get("v.buttonTitle");
        var id = attributes.split('|')[1];

        component.set("v.contactId", id);
        component.set("v.isAddingActivity", true);
        component.set("v.isInSearchMode", false);
    },
    addRelationship : function(component, event){
        var source = event.getSource();
        var attributes = source.get("v.buttonTitle");
        var name= attributes.split('|')[1];
        var id = attributes.split('|')[2];
        component.set("v.contactId", id);
        component.set("v.contactName", name);
        component.set("v.isAddingRelationship", true);
        component.set("v.isInSearchMode", false);
    },
    cancelAddActivity : function(component, event){
        $A.get("e.force:refreshView").fire();
    },
    cancelAddRelationship : function(component, event){
        $A.get("e.force:refreshView").fire();
    },
    clearSelection:function(component,event){
        component.set("v.contactId",null);
    },
    relationshipAdded : function(component, event){
        var contactId = component.get("v.contactId");
        component.set("v.isAddingRelationship", false);
        $A.get("e.force:refreshView").fire();
        var action = $A.get("e.force:navigateToSObject");
        action.setParams({recordId:contactId});
        action.fire();
    },
    onSearchPerformed: function(component, event, helper) {
        var searchResult = event.getParam("searchResults");
        component.set("v.contacts", searchResult);
    },
    onContactSelection: function(component, event, helper){
        var element = event.currentTarget;
        var id = element.getAttribute('data-key');
        helper.navigateToObjectRecord(component, event, helper, id);
    }
})