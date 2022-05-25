//This file holds the JS functions that could be shared between the mobile and VF pages
var $j = jQuery.noConflict();
var clock, _userId, _sObject, _sObjectId, _displayName;

AppendWidget = function(){
    var html = '<div id="recordingDialog" style="display: none"><div id="existingRecordWarning" style="display:none;"><p style="color: Red; font-weight: bold;">You have an existing time record that is not finished or still in progress.  Please take action below.</p><p id="existingProjectName" style="font-weight: bold;"></p></div><div style="padding-bottom:10px;"><p>Activity: <select id="activityType"><option></option></select></p></div><div class="clock"></div><div><p>Add Minutes: <input id="updateMinutes" type="number" style="width:50px;"></input><input id="updateTime" type="button" value="Update" style="padding-left:10px;"></input></p></div><input id="timePeriodId" type="hidden" /></div>';
    $j('body').append(html);
}

CreateEventHandlers = function(){
     $j("#updateTime").click(function(){
        UpdateTime($j("#updateMinutes").val() * 60);
      });
}

GetActivityTypesCB = function(result, event) { 
    var selectOptions;
    $j.each(result, function(key){
        selectOptions += '<option>' + result[key] + '</option>';
    });
    $j("#activityType").append(selectOptions);
}

GetCurrentPeriodCB = function(result,event){
    $j("#timePeriodId").val(result);
}


InstantiateClock = function(){
     clock = new FlipClock($j('.clock'), {callbacks:{interval: IntervalChanged}});
}

//We want to issue a save every 10th of an Hour (6 Minutes)
IntervalChanged = function(){
    if(clock){
        var minutes = clock.getTime().getMinutes(false);
        var seconds = clock.getTime().getSeconds(true); 
        if(minutes > 0 && minutes % 6 == 0 && seconds === 0){
            SaveTimeRecord(_userId, _sObject, _sObjectId, _displayName,'In Progress');
        }
    }
}

LaunchTimeTracker = function(userId, sObject, sObjectId, displayName, isPopup){  
    var pendingRecords = [];
    _userId = userId;
    _sObject = sObject;
    _sObjectId = sObjectId;
    _displayName = displayName;
    if(isPopup){
        pendingRecords = CheckForPendingRecords(userId);

        AppendWidget();
        GetActivityTypes();
        GetCurrentPeriodRecordId();

        if(pendingRecords.length > 0){
            $j("#existingRecordWarning").toggle();
            $j("#existingProjectName").text(pendingRecords[0].Project_Name__c);
            $j("#activityType").val(pendingRecords[0].Activity_Type__c);
            PopupDialog(userId, sObject, pendingRecords[0].Engagement__c, 'Pending Record Alert for: ' + pendingRecords[0].Project_Name__c);
        }
        else
            PopupDialog(userId, sObject, sObjectId, displayName);

        $j("#activityType").change(function(){
            if($j("#activityType").val() != '')
                SaveTimeRecord(userId, sObject, sObjectId, displayName, 'In Progress');
        });
    }
    else{
        GetActivityTypesRemote();
        GetCurrentPeriodRecordIdRemote();
    }

    InstantiateClock();
    CreateEventHandlers();

    //If Pending Record, We need to load the existing time after instantiation
    if(pendingRecords.length > 0)
        UpdateTime(pendingRecords[0].Hours_Worked__c * 60 * 60);
 }

CheckForPendingRecords = function(userId){
    return GetPendingRecords(userId);
}

LoadCSSFile = function(filename){
        var fileref = document.createElement('link');
        fileref.setAttribute('rel', 'stylesheet');
        fileref.setAttribute('type', 'text/css');
        fileref.setAttribute('href', filename);
        document.getElementsByTagName('head')[0].appendChild(fileref);
}

PopupDialog = function(userId, sObject, sObjectId, displayName){
        $j("#recordingDialog").dialog({ 
            dialogClass: "tracking-dialog",
            title: displayName,
            autoOpen: true, 
            modal: false,
            resizable: false, 
            width: 550, 
            height: 350, 
            buttons: { 
            "Cancel":function(){
                if(confirm('Are you sure you want to cancel any time tracked?')){
                    CancelTimeRecord(userId, sObject, sObjectId);
                    $j(this).dialog("destroy").remove(); 
                }
            },
            "Pause":function(){
                alert('Click "OK" to resume.');
            },
            "Finished": function() { 
                if(SaveTimeRecord(userId, sObject, sObjectId, displayName,'Complete'))
                    $j(this).dialog("destroy").remove();
            }
            } 
        });
}

RecordTimeCB = function(result, event){}

CancelTimeRecord = function(userId, sObject, sObjectId){
    var id = CancelRecord($j("#timePeriodId").val(), userId, $j("#activityType").val(), sObject, sObjectId);
    return id;
}

SaveTimeRecord = function(userId, sObject, sObjectId, displayName, recordingStatus){
        var valid = Validate();
        if(valid === 'Success'){
            var id = RecordTime($j("#timePeriodId").val(), userId, $j("#activityType").val(), sObject, sObjectId, clock.getTime().getMinutes(false), clock.getTime().getSeconds(false), recordingStatus);
            return true;
        }
        else
            alert(valid);
        return false;
 }

UpdateTime = function(seconds){
        if(!isNaN(seconds)){
    		//Validate we are not hitting negative time
    		var elapsed = clock.getTime().getSeconds(false);
    		if(elapsed + seconds >= 0)
            	clock.getTime().addSeconds(seconds);
    		else
    			alert("Invalid - Exceeds Elapsed Time");
    	}
        else
            alert("Invalid Number");
}

Validate = function(){
        return $j("#activityType").val() != '' ? 'Success' : 'Activity Type Required';
}