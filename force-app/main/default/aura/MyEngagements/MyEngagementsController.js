({
    doInit : function(component, event, helper) {
        component.set("v.objectType", "Engagement");
        helper.getSearchResultsByName(component, event, helper); 
    }, 
    onSearchPerformed: function(component, event, helper) {
        var searchResult = event.getParam("searchResults");
        component.set("v.engagements", searchResult);
	},
    onEngagementSelection: function(component, event, helper){
        var element = event.currentTarget;
        var id = element.getAttribute('data-key');
        helper.navigateToObjectRecord(component, event, helper, id);
    }
})