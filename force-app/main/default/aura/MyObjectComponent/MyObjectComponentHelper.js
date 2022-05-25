({
    getDefaultResultLimits: function(component, event, helper){
        helper.callServer(component, "c.GetMobileSearchResultDefault", function(result){
            component.set("v.resultsDefaultLimit", result);
        });
        helper.callServer(component, "c.GetMobileSearchResultLimit", function(result){
            component.set("v.resultsMaxLimit", result);
        });
    },
    getSearchResultsByName: function(component, event, helper){
        var searchObject = component.get("v.objectType");
        var searchTerm = component.get("v.searchTerm");
        var resultLimit = component.get("v.showingMaxRecords") ? component.get("v.resultsMaxLimit") : component.get("v.resultsDefaultLimit");
        var myOnly = !searchTerm || searchTerm.length < 2;
       
        this.setHeader(component, event, helper);
        
        helper.callServer(component, "c.FindByName", function(result){
            component.set("v.searchResults", result);
            var afterSearchEvent = component.getEvent("afterSearchEvent");
            afterSearchEvent.setParams({"searchResults":result});
            afterSearchEvent.fire();
        },{"objectType":searchObject,"searchTerm":searchTerm,"myOnly":myOnly,"resultLimit":resultLimit});
    },
    navigateToObjectRecord: function(component, event, helper, id){
        var navRecordEvent = $A.get("e.force:navigateToSObject");
        navRecordEvent.setParams({"recordId":  id});
        navRecordEvent.fire();
    },
    performMaxSearch:function(component, event, helper){
        var searchTerm = component.get("v.searchTerm");
        var toastEvent = $A.get("e.force:showToast");

        toastEvent.setParams({
                "title": "Loading",
                "message": "More Results..."
        });
        toastEvent.fire();

        component.set("v.showingMaxRecords",true);
        this.getSearchResultsByName(component, event, helper);
        component.set("v.showingMaxRecords",false);
    },
    setHeader: function(component, event, helper){
        var searchObject = component.get("v.objectType");
        var searchTerm = component.get("v.searchTerm");
        var myOnly = !searchTerm || searchTerm.length < 2;
        
        if(myOnly){
            searchObject = searchObject.replace(/y$/,"ie") + 's';
            component.set("v.resultsHeading","My " + searchObject);
        }  
        else
            component.set("v.resultsHeading",searchObject + " Search Results");
    },
    toggleSpinner: function(component, event, helper, isVisible){
        var spinner = component.find("spinner");
        var toggleEvent = spinner.get("e.toggle");
        toggleEvent.setParams({isVisible:isVisible});
        toggleEvent.fire();
    }
})