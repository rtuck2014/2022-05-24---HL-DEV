({
    doInit: function(component, helper) {
        helper.callServer(component, "c.GetCategory", function(response) {
            var category = response;
            component.set("v.category", category);
            if (category == "SC") {
            	component.find("activityType").set("v.value", "Strategic Consulting");
        	}
        });
	},
    onProjectSelected: function(component, event, helper) {
        var selectedProjectId = component.get("v.selectedProjectId");
        var selectedId = event.getParam("selectedId");
        selectedProjectId = selectedId;
        component.set("v.selectedProjectId", selectedId);
        this.handleProjectRequirements(component, selectedId);
    },
    intervalCallback: function(component, event, helper) {
        //We want to issue a save every 10th of an Hour (6 Minutes)
        if (clock) {
            var minutes = clock.getTime().getMinutes(false);
            var seconds = clock.getTime().getSeconds(true);
            var selectedProjectId = component.get("v.selectedProjectId");
            if (selectedProjectId != null && seconds % 10 == 0) {
                component.helper.saveTimeRecord(component, event, helper, "In Progress");
            }
        }
    },
    getObjectType: function(id) {
        return id.startsWith('a0I') ? "Opportunity__c" : id.startsWith('a09') ? "Engagement__c" : "Special_Project__c";
    },
    getPendingRecords: function(component, event, helper) {
        helper.callServer(component, "c.GetPendingRecords", function(response) {
            if (response && response.length > 0) {
                var timeRecord = response[0];
                component.set("v.hasPendingRecord", true);
                component.set("v.showClock", false);
                component.set("v.timeRecord", timeRecord);
                component.set("v.comments", timeRecord.Comments__c);
                component.set("v.selectedProjectId", timeRecord.Opportunity__c ? timeRecord.Opportunity__c : timeRecord.Engagement__c ? timeRecord.Engagement__c : timeRecord.Special_Project__c);
            
                var selectedId = component.get("v.selectedProjectId");
                var requireComments = false;
                var projectSelections = component.get("v.projectSelections");
                var isSpecialProject = false;
                projectSelections.filter(function(p) {
                    if (p.Id === selectedId) {
                        isSpecialProject = p.Type === "Special_Project__c";
                        requireComments = p.RequireComments;
                    }
                });
                component.set('v.requireActivityTypes', !isSpecialProject);
                component.set('v.requireComments', requireComments);
            } else {
                component.set("v.hasPendingRecord", false);
            	component.set("v.showClock", true);
            }
        });
    },
    handleProjectRequirements: function(component) {
        var selectedId = component.get("v.selectedProjectId");
        var requireComments = false;
        var projectSelections = component.get("v.projectSelections");
        var isSpecialProject = false;
        projectSelections.filter(function(p) {
            if (p.Id === selectedId) {
                isSpecialProject = p.Type === "Special_Project__c";
                requireComments = p.RequireComments;
            }
        });
        component.set('v.requireActivityTypes', !isSpecialProject);
        component.set('v.requireComments', requireComments);
        component.set("v.updateTimeDisabled", false);
    },
    instantiateClock: function(component, event, helper) {
        clock = new FlipClock($j('.clock'), {
            callbacks: {
                interval: function() {
                    helper.intervalCallback(component, event, helper);
                   
                }
            }
        });
    },
    toggleTrackingFields: function(component, event, helper, toggle) {
        var activityType = component.find("activityType");
        component.set("v.isProjectSelectionDisabled", !toggle);
        if (activityType)
            activityType.set("v.disabled", !toggle);
    },
    onPause: function(component, event, helper) {
        helper.showSpinner(component);
         var timeRecord = component.get("v.timeRecord");
        timeRecord.Timer_Status__c='Pause';
        var action = component.get("c.UpdateRecordStatus");
        action.setParams({"tr" : timeRecord});
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            if (state === "SUCCESS") {
                var timeRec =response.getReturnValue();
                 component.set("v.timeVal",timeRec.Time__c);
                window.setTimeout(
                     $A.getCallback(function() {
                         helper.hideSpinner(component);
                     }), 
                     5000
                 );
                
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
       
        component.set("v.disableStartButton", false);
        console.log('pause...'+component.get("v.disableStartButton"));
       clock.stop();
        
    },
    onFinish: function(component, event, helper) {
        component.set("v.disableStartButton", false);
        console.log('finish...'+component.get("v.disableStartButton"));
        helper.saveTimeRecordWithComments(component, event, helper, 'Complete','False');
    },
    onResume: function(component, event, helper) {
     var timeRecord = component.get("v.timeRecord");
       helper.showSpinner(component);
      //Occasionally the Activity Types load late so reset here in case
        component.set("v.timeRecord", timeRecord);
		component.set("v.disableComments", false);
        component.set("v.updateTimeDisabled", false);
       /* 
        helper.instantiateClock(component, event, helper);
		
        clock.getTime().addSeconds(timeRecord.Hours_Worked__c * 60 * 60);

        component.set("v.hasPendingRecord", false);
        component.set("v.showClock", true);
        */
       timeRecord.Timer_Status__c='Pause';
        var action = component.get("c.UpdateRecordStatus");
        action.setParams({"tr" : timeRecord});
        action.setCallback(this, function(response) {
           
            var state = response.getState();
            if (state === "SUCCESS") {
                var timeRec =response.getReturnValue();
				helper.afterResumeClick(component, event, helper);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        helper.toggleTrackingFields(component, event, helper, false);
    },
    afterResumeClick :function(component, event, helper) {
         var timeRecord = component.get("v.timeRecord");
        if( timeRecord!=null && timeRecord!=undefined  && timeRecord.Id!=null && timeRecord.Id!=undefined){
              timeRecord.Add_Minute_Change__c=false;
              timeRecord.Add_Minute__c=0;
          timeRecord.Timer_Status__c='Start';
        var action = component.get("c.UpdateRecordStatus");
        action.setParams({"tr" : timeRecord});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
            var timeRec =response.getReturnValue(); 
             console.log('timeRecord...Id'+timeRec.Id);
             
			 helper.instantiateClock(component, event, helper);
             
             clock.getTime().addSeconds(timeRec.Seconds_Worked__c * 60 * 60);
             component.set("v.hasPendingRecord", false);
        	 component.set("v.showClock", true)
               window.setTimeout(
                     $A.getCallback(function() {
                         helper.hideSpinner(component);
                     }), 
                     8000
                 );
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        }
    },    
    onReset: function(component, event, helper) {
        var timeRecord = component.get("v.timeRecord");
		
        var action = component.get("c.DeleteRecord");
		action.setParams({ recordId : component.get("v.timeRecord.Id") });
		action.setCallback(this, function(response) {
            if (response) {
                if (clock != null) {
                    clock.reset();
                	clock.stop();
                }

                component.set("v.selectedProjectId", null);
                component.set("v.timeRecord", {
                    "sobjectType": "Time_Record__c"
                });
                helper.toggleTrackingFields(component, event, helper, true);
                clock = null;
                component.set("v.showError", false);      
                component.set("v.hasPendingRecord", false);
                component.set("v.showClock", true);
            } else {
                throw new Error("Unable to Delete Time Record");
        	}  
        });
        $A.enqueueAction(action);
    },
    onSaveSuccess: function(component, event, helper, recordingStatus) {
        if (recordingStatus === "Complete" || recordingStatus === "CompleteAndResume") {
            clock.reset();
            if (recordingStatus === "Complete") {
                component.set("v.disableComments", true);
                clock.stop();
                var updateMinutes = component.find("updateMinutes");
        		var minutes = updateMinutes.set("v.value", "");
                component.set("v.requireComments", false);
                component.set("v.requireActivityTypes", false);
                component.set("v.comments", "");
                component.set("v.selectedProjectId", null);
                component.set("v.timeRecord", {
                    "sobjectType": "Time_Record__c"
                });
                helper.toggleTrackingFields(component, event, helper, true);
                clock = null;
                var category = component.get("v.category");
                if (category == "SC") {
                    component.find("activityType").set("v.value", "Strategic Consulting");
                }
            } else {
                helper.instantiateClock(component, event, helper);
                helper.saveTimeRecord(component, event, helper, "In Progress");
            }
        }
    },
    onStart: function(component, event, helper) {
        component.set("v.disableStartButton", true);
        console.log('start...'+component.get("v.disableStartButton"));
        if (helper.validateStart(component, event, helper)) {
            component.set("v.disableComments", false);
            if (clock){
                 helper.showSpinner(component);
                var timeRecord = component.get("v.timeRecord");
         if( timeRecord!=null && timeRecord!=undefined  && timeRecord.Id!=null && timeRecord.Id!=undefined){
              timeRecord.Add_Minute_Change__c=false;
              timeRecord.Add_Minute__c=0;
         var action = component.get("c.fetchTime");
        action.setParams({"tr" : timeRecord});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
            var timeRec =response.getReturnValue();
            var Recsec=parseInt(timeRec.Seconds_Worked__c * 3600);
            var timersec=parseInt(timeRecord.Seconds_Worked__c * 3600);
            var Diffsec=0;
                //alert(parseInt(timeRec.Hours_Worked__c)+'...hour...'+parseInt(timeRecord.Hours_Worked__c));
                //alert(parseInt(timeRec.Seconds_Worked__c)+'...second...'+parseInt(timeRecord.Seconds_Worked__c));
                  if(parseInt(timeRecord.Hours_Worked__c)==0 && parseInt(timeRec.Hours_Worked__c)==10){
                   var minutes = clock.getTime().getMinutes(false);
                   var seconds = clock.getTime().getSeconds(true);
                    timeRecord.Hours_Worked__c = ((seconds / 60.0) + minutes) / 60.0;
                    Diffsec=parseInt(timeRecord.Hours_Worked__c * 3600);
                }    
           
              //  alert(parseInt(timersec)+'...timer...'+parseInt(Recsec));
                if(parseInt(timersec)>parseInt(Recsec)){
                 // Diffsec=parseInt(timersec - Recsec);
                    //alert('backend value is > front'+parseInt(timersec - Recsec));
                }
                else if(parseInt(timersec)<parseInt(Recsec)){
                   //  Diffsec=parseInt(Recsec - timersec);
                    //alert('fornt value is > backend'+parseInt(Recsec - timersec));
                }
             
            var Calsec=parseInt(Recsec+Diffsec);    
            console.log('timeRecord...Id'+timeRec.Id);
               window.setTimeout(
                     $A.getCallback(function() {
                         helper.hideSpinner(component);
                     }), 
                     8000
                 );
			 clock.start(Calsec);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        }
        }
        else {
			   helper.instantiateClock(component, event, helper);
                helper.saveTimeRecord(component, event, helper, "In Progress");
            }
			
            helper.toggleTrackingFields(component, event, helper, false);
        }
    },
    round: function(value, precision) {
        var multiplier = Math.pow(10, precision || 0);
        return Math.round(value * multiplier) / multiplier;
    },
    saveTimeRecordWithComments : function(component, event, helper, recordingStatus,onChangeComment) {
        var today = new Date();
        var selectedProjectId = component.get("v.selectedProjectId");
        var timeRecord = component.get("v.timeRecord");
        var category = component.get("v.category");
        var recordDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        var minutes = clock.getTime().getMinutes(false);
        var seconds = clock.getTime().getSeconds(true);
        var objectType = helper.getObjectType(selectedProjectId);
		
        if (recordingStatus == "Complete" && minutes != null && minutes < 6) {
            minutes = 6;
        }
        
        timeRecord.Opportunity__c = (objectType == "Opportunity__c" ? selectedProjectId : null);
        timeRecord.Engagement__c = (objectType == "Engagement__c" ? selectedProjectId : null);
        timeRecord.Special_Project__c = (objectType == "Special_Project__c" ? selectedProjectId : null);
        timeRecord.Comments__c = component.get("v.comments");
       
        if(onChangeComment == 'False'){
        timeRecord.Timer_Status__c ='Stop'; 
        }
       component.set("v.disableComments", true);
        console.log('comm...minutes...'+minutes);
         console.log('comm...seconds...'+seconds);
        if (recordingStatus == "Complete") {
            timeRecord.Hours_Worked__c = helper.round(minutes / 60.0, 1);
        }		
        else {
            timeRecord.Hours_Worked__c = ((seconds / 60.0) + minutes) / 60.0;
            timeRecord.Seconds_Worked__c = ((seconds / 60.0) + minutes) / 60.0;
        }
         console.log('comm...hours...'+timeRecord.Hours_Worked__c);
        timeRecord.Seconds_Worked_Actual__c = seconds;
        timeRecord.Recording_Status__c = recordingStatus;
        
        if (timeRecord.Id && timeRecord.Id != null) {
            //Check if Date has Changed (If So, Save off Yesterday's Record and Start New)
            if (recordDate == timeRecord.Activity_Date__c.slice(0, 10)) {
                helper.callServer(component, "c.UpdateRecord", function(response) {
                    if (response && response.Id != null) {
                        component.set("v.timeRecord", response);
                        component.set("v.showError", false);
                        component.set("v.disableComments", false);
                        helper.onSaveSuccess(component, event, helper, recordingStatus);
                    } else
                        throw new Error("Unable to Update Time Record");
                }, {
                    "tr": timeRecord
                });
            } else {
                //Time Record has crossed midnight
                timeRecord.Recording_Status__c = 'Complete';
                helper.callServer(component, "c.UpdateRecord", function(response) {
                    if (response && response.Id != null) {
                        timeRecord.Id = null;
                        timeRecord.sobjectType = "Time_Record__c";
                        timeRecord.Recording_Status__c = "Pending";

                        component.set("v.timeRecord", timeRecord);
                        component.set("v.showError", false);
						component.set("v.disableComments", false);
                        helper.onSaveSuccess(component, event, helper, "CompleteAndResume");
                    } else
                        console.log(response);
                }, {
                    "tr": timeRecord
                });
            }
        } else {
            helper.callServer(component, "c.InsertRecord", function(response) {
                if (response && response.Id != null) {
                    component.set("v.timeRecord", response);
                    component.set("v.showError", false);
                    component.set("v.disableComments", false);
                    helper.onSaveSuccess(component, event, helper, recordingStatus);
                } else
                    throw new Error("Unable to Insert Time Record");;
            }, {
                "tr": timeRecord,
                "recordDate": recordDate,
                "category": category,
                "allowedHourEntry": component.get("v.allowedHourEntry")
            });
        }
        component.set("v.disableComments", false);
    },
    saveTimeRecord: function(component, event, helper, recordingStatus) {
        var today = new Date();
        var selectedProjectId = component.get("v.selectedProjectId");
        var timeRecord = component.get("v.timeRecord");
        var category = component.get("v.category");
        var recordDate = today.getFullYear() + "-" + ("0" + (today.getMonth() + 1)).slice(-2) + "-" + ("0" + today.getDate()).slice(-2);
        var minutes = clock.getTime().getMinutes(false);
        var seconds = clock.getTime().getSeconds(true);
        var objectType = helper.getObjectType(selectedProjectId);
		
        if (recordingStatus == "Complete" && minutes != null && minutes < 6) {
            minutes = 6;
        }
        
        timeRecord.Opportunity__c = (objectType == "Opportunity__c" ? selectedProjectId : null);
        timeRecord.Engagement__c = (objectType == "Engagement__c" ? selectedProjectId : null);
        timeRecord.Special_Project__c = (objectType == "Special_Project__c" ? selectedProjectId : null);
        
        if (recordingStatus == "Complete") {
            timeRecord.Hours_Worked__c = helper.round(minutes / 60.0, 1);
        }		
        else {
            timeRecord.Seconds_Worked__c = ((seconds / 60.0) + minutes) / 60.0;
            timeRecord.Hours_Worked__c = ((seconds / 60.0) + minutes) / 60.0;
        }
         console.log('save...minutes...'+minutes);
         console.log('save...seconds...'+seconds);
        console.log('save...hours...'+timeRecord.Hours_Worked__c);
        timeRecord.Seconds_Worked_Actual__c = seconds;
        timeRecord.Recording_Status__c = recordingStatus;
       timeRecord.Add_Minute_Change__c=false;
            timeRecord.Timer_Status__c ='Start'; 
       
             if (timeRecord.Id && timeRecord.Id != null) {
            //Check if Date has Changed (If So, Save off Yesterday's Record and Start New)
            if (recordDate == timeRecord.Activity_Date__c.slice(0, 10)) {
                helper.callServer(component, "c.UpdateRecord", function(response) {
                    if (response && response.Id != null) {
                        component.set("v.timeRecord", response);
                        component.set("v.showError", false);
                        helper.onSaveSuccess(component, event, helper, recordingStatus);
                    } else
                        throw new Error("Unable to Update Time Record");
                }, {
                    "tr": timeRecord
                });
            } else {
                //Time Record has crossed midnight
                timeRecord.Recording_Status__c = 'Complete';
                helper.callServer(component, "c.UpdateRecord", function(response) {
                    if (response && response.Id != null) {
                        timeRecord.Id = null;
                        timeRecord.sobjectType = "Time_Record__c";
                        timeRecord.Recording_Status__c = "Pending";

                        component.set("v.timeRecord", timeRecord);
                        component.set("v.showError", false);

                        helper.onSaveSuccess(component, event, helper, "CompleteAndResume");
                    } else
                        console.log(response);
                }, {
                    "tr": timeRecord
                });
            }
        } else {
            helper.callServer(component, "c.InsertRecord", function(response) {
                if (response && response.Id != null) {
                    component.set("v.timeRecord", response);
                    component.set("v.showError", false);
                    helper.onSaveSuccess(component, event, helper, recordingStatus);
                } else
                    throw new Error("Unable to Insert Time Record");;
            }, {
                "tr": timeRecord,
                "recordDate": recordDate,
                "category": category,
                "allowedHourEntry":component.get("v.allowedHourEntry")
            });
        }
    },
    updateTime: function(component, event, helper) {
        
        component.set("v.updateTimeDisabled", true);
        var updateMinutes = component.find("updateMinutes");
        var minutes = updateMinutes.get("v.value");
		var timeRecord = component.get("v.timeRecord");
        timeRecord.Add_Minute__c=minutes;
       timeRecord.Add_Minute_Change__c=true;
         var action = component.get("c.UpdateRecordStatus");
        action.setParams({"tr" : timeRecord});
        action.setCallback(this, function(response) {
          
            var state = response.getState();
            if (state === "SUCCESS") {
                window.setTimeout(function(){ helper.hideSpinner(component)}, 5000);
               
                var timeRec =response.getReturnValue();
                 component.set("v.timeVal",timeRec.Time__c);
                timeRecord.Hours_Worked__c =timeRec.Hours_Worked__c;
                component.set("v.timeRecord", timeRecord);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        if (!isNaN(minutes)) {
            minutes = minutes * 60;
            //Validate we are not hitting negative time
            var elapsed = clock.getTime().getSeconds(false);
            if (elapsed + minutes >= 0) {
                clock.getTime().addSeconds(minutes);
                updateMinutes.set("v.value", null);
            } else
                alert("Invalid - Exceeds Elapsed Time");
        }
        component.set("v.updateTimeDisabled", false);
    }, 
 fetchTime: function(component, event, helper){
         var timeRecord = component.get("v.timeRecord");
        if( timeRecord!=null && timeRecord!=undefined  && timeRecord.Id!=null && timeRecord.Id!=undefined){
         var action = component.get("c.fetchTime");
        action.setParams({"tr" : timeRecord});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var timeRecord =response.getReturnValue();
                 component.set("v.timeVal",timeRecord.Time__c);
                console.log('ddss'+component.get("v.timeVal"));
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        }
 
else{
component.set("v.timeVal","0hr 0min 0sec");
}
 },
    validateStart: function(component, event, helper) {
        var selectedProjectId = component.get("v.selectedProjectId");
        var requireActivityTypes = component.get("v.requireActivityTypes");
        var requireComments = component.get("v.requireComments");
        var errorMsg = "";

        if (!selectedProjectId || selectedProjectId == "")
            errorMsg += "\r\nProject Selection Required";
        if (requireActivityTypes) {
            var activityType = component.find("activityType").get("v.value");
            if (!activityType || activityType == "")
                errorMsg += "\r\nActivity Required"
        }

        if (errorMsg != "") {
            isValid = false;
            component.set("v.showError", true);
            component.find("errorText").set("v.value", " " + errorMsg);
        } else
            component.set("v.showError", false);

        return errorMsg === "";
    },
        showSpinner: function (component, event, helper) {
       component.set("v.toggleSpinner", true);  
            
    },
     
    hideSpinner: function (component, event, helper) {
      component.set("v.toggleSpinner", false);
    }
 
})