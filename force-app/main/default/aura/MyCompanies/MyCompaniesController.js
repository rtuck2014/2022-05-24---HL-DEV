({
    doInit : function(component, event, helper) {
        component.set("v.objectType", "Company");
        helper.getSearchResultsByName(component, event, helper); 
    }, 
    onCompanySelection: function(component, event, helper){
        var element = event.currentTarget;
        var id = element.getAttribute('data-key');
        helper.navigateToObjectRecord(component, event, helper, id);
    },
    onSearchPerformed: function(component, event, helper) {
        var searchResult = event.getParam("searchResults");
        component.set("v.companies", searchResult);
	}
})