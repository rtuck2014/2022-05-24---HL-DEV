({
	doInit:function(component, event, helper){
        //Default to today's date
        var today = new Date();
        helper.setSelectedDate(component,today);
        helper.setWeek(component,today);
    },
    onNextClick:function(component, event, helper){
        var selectedDate = new Date(helper.formatDate(component.get("v.selectedDate")));
        var newSelectedDate = new Date(selectedDate);
        newSelectedDate.setDate(newSelectedDate.getDate() + 7);
        helper.setSelectedDate(component,newSelectedDate);
        helper.setWeek(component,newSelectedDate);
    },
    onPrevClick:function(component, event, helper){
        var selectedDate = new Date(helper.formatDate(component.get("v.selectedDate")));
        var newSelectedDate = new Date(selectedDate);
        newSelectedDate.setDate(newSelectedDate.getDate() - 7);
        helper.setSelectedDate(component,newSelectedDate);
        helper.setWeek(component,newSelectedDate);
    },
    onMondaySelect:function(component, event, helper){
    	helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.monday"))));
    },
    onTuesdaySelect:function(component, event, helper){
    	helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.tuesday"))));
    },
    onWednesdaySelect:function(component, event, helper){
    	helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.wednesday"))));
    },
    onThursdaySelect:function(component, event, helper){
    	helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.thursday"))));
    },
    onFridaySelect:function(component, event, helper){
		helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.friday"))));
    },
    onSaturdaySelect:function(component, event, helper){
        helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.saturday"))));
    },
    onSundaySelect:function(component, event, helper){
        helper.setSelectedDate(component,new Date(helper.formatDate(component.get("v.sunday"))));
    }
})