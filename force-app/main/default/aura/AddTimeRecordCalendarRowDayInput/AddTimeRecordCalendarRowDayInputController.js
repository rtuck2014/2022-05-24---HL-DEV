({
    doInit: function(component, event, helper) {
       // var showForecastActivityType = component.get("v.showForecastActivityType");
        //if(showForecastActivityType){
          //  component.find('activityType01').set("v.value",'Forecast')
       // }
        var activityRecord = component.get("v.activityRecord");
        helper.doInit(component, helper);
    },
    onActivityRecordChanged: function(component, event, helper) {
        console.log('Input chnaged Enter')
        var activityRecord = component.get("v.activityRecord");
        var showForecastActivityType = component.get("v.showForecastActivityType");
        var currentOrPriorPeriod = component.get("v.currentOrPriorPeriod");
        if(showForecastActivityType && !currentOrPriorPeriod){
              activityRecord.ActivityType = 'Forecast';
        }else{
        var selectList = component.find("activityType01");
        if(selectList != undefined || selectList != null){
            activityRecord.ActivityType = selectList.get("v.value");
        }  
        }
        activityRecord.Hours = helper.round(activityRecord.Hours, 1);
        console.log('Input chnaged Enter helper')
        helper.onActivityRecordChanged(component, helper);
    },
    onDeleteClicked: function(component, event, helper) {
        if (confirm('Are you sure you want to delete this record?')){
            var deleteControl = event.getSource();
            var recordId = deleteControl.getElement().parentElement.getAttribute("data-key");
            helper.deleteActivityRecord(component, helper, recordId);
            helper.fireSpinnerEvent(component, helper);
        }
    },
    
})