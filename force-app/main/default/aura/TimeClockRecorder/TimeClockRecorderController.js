({
    doInit: function(component, event, helper) {
        helper.doInit(component, helper);
	},
    afterScriptsLoaded : function(component, event, helper) {
        var $j = jQuery.noConflict();
        var clock = new FlipClock($j('.clock'), {autoStart:false});
        helper.getPendingRecords(component, event, helper);
    },
    onFinish : function(component, event, helper){
        helper.onFinish(component, event, helper);
        
    },
    onPause : function(component, event, helper){
        helper.onPause(component, event, helper);
        //helper.fetchTime(component, event, helper);
    },
    onActivitytChange: function(component, event, helper){
      component.set("v.disableStartButton", false);  
    },    
    onProjectSelection : function(component, event, helper){
         component.set("v.disableStartButton", false);
        helper.onProjectSelected(component, event, helper);
    },
    onResume : function(component, event, helper){
        var clock = new FlipClock($j('.clock'), {autoStart:false});
        helper.onResume(component, event, helper);
        helper.fetchTime(component, event, helper);
    },
    onReset : function(component, event, helper){
        helper.onReset(component, event, helper);
    },
    onStart : function(component, event, helper){
       
     helper.onStart(component, event, helper);	
    },
    onRefresh : function(component, event, helper){
         helper.showSpinner(component);
     helper.onStart(component, event, helper);	
    },
    onUpdateTime : function(component, event, helper){
         helper.showSpinner(component);
        helper.updateTime(component, event, helper);
        helper.fetchTime(component, event, helper);
    },
    onSaveComment : function(component, event, helper){
        
         component.set("v.disableStartButton", false);
        helper.saveTimeRecordWithComments(component, event, helper,'true');
        
    } ,  
})