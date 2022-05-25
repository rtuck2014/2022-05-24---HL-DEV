({
    doInit : function(component, event, helper) {
        helper.getDefaultResultLimits(component, event, helper);
    },
    onObjectTypeChanged : function(component, event, helper){
      helper.getSearchResultsByName(component, event, helper);  
    },
    onResultsDefaultLimitChanged : function(component, event, helper){
        helper.getSearchResultsByName(component, event, helper);
    },
    onResultsMaxLimitChanged : function(component, event, helper){
        helper.getSearchResultsByName(component, event, helper);
    },
    onSearchEvent: function(component, event, helper) {
        var searchTerm = event.getParam("searchTerm");
        component.set("v.searchTerm",searchTerm);
        helper.getSearchResultsByName(component, event, helper);
    },
    onShowMorePress:function(component, event, helper){
        helper.performMaxSearch(component, event, helper);
    },
    showSpinner: function(component, event, helper){
        helper.toggleSpinner(component, event, helper, true);
    },
    hideSpinner: function(component, event, helper){
        helper.toggleSpinner(component, event, helper, false);
    }
})