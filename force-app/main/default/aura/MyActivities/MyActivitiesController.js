({
    activityAdded:function(component, event){
        component.set("v.isAdding", false);
        $A.get("e.force:refreshView").fire();
    },
    cancelAddActivity : function(component, event){
        $A.get("e.force:refreshView").fire();
    },
	doInit : function(component, event, helper) {
        var today = new Date();
        helper.selectedDateChanged(component,today);
    },
    navigateToAddActivity : function(component, event, helper) {
        component.set("v.isAdding", true); 
    },
    onAllClick:function(component, event, helper){
        var elem = component.find("rAllActivity").getElement();
        component.find("rTodayActivity").set("v.value","false");
        component.find("rUpcomingActivity").set("v.value","false");
        component.find("rAllActivity").set("v.value","true");
        helper.filterOptionChanged(component, helper, elem);
        
    },
    onTodayClick:function(component, event, helper){
        var elem = component.find("rTodayActivity").getElement();
        component.find("rAllActivity").set("v.value","false");
        component.find("rUpcomingActivity").set("v.value","false");
        component.find("rTodayActivity").set("v.value","true");
        helper.filterOptionChanged(component, helper, elem);
        
    },
    onUpcomingClick:function(component, event, helper){
        var elem = component.find("rUpcomingActivity").getElement();
        component.find("rAllActivity").set("v.value","false");
        component.find("rTodayActivity").set("v.value","false");
        component.find("rUpcomingActivity").set("v.value","true");
        helper.filterOptionChanged(component, helper, elem);   
    },
    onFilterOptionChanged:function(component,event, helper){
        var elem = event.getSource().getElement();
        helper.filterOptionChanged(component, helper, elem);       
    },
    onSelectedDateChanged:function(component,event,helper){
        var selectedDate = new Date(event.getParam("selectedDate"));
		helper.selectedDateChanged(component,selectedDate);
    },
    selectActivity: function(component, event){
        var element = event.currentTarget;
        var id = element.getAttribute('data-key'); 
        component.set("v.selectedActivityId", id);
        component.set("v.isViewing", true); 
        
    },
    showSpinner: function(component, event, helper){
        var spinner = component.find("spinner");
        if(spinner){
            var evt = spinner.get("e.toggle");
            evt.setParams({isVisible: true});
            evt.fire();
        }
        
    },
    hideSpinner: function(component, event, helper){
        var spinner = component.find("spinner");
        if(spinner){
            var evt = spinner.get("e.toggle");
            evt.setParams({isVisible:false});
            evt.fire();
        }
    }
})