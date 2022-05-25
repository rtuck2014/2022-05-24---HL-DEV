({
    doInit:function(component, event, helper){
        // Default value of companies discussed if the page is opened from 'Add Actvity' quick action on  Account
        let sObjectName = component.get("v.sObjectName");
        console.log('sObjectName>>>'+sObjectName);
        if(sObjectName != undefined){
            let recordId  = component.get('v.recordId'); 
            var defaultAccountAction = component.get("c.getAccountData");
            defaultAccountAction.setParams({accountId:recordId});
            defaultAccountAction.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var data = response.getReturnValue();
                    let comps = component.get("v.companies");
                    comps.push(data);
                    component.set("v.companies",comps);
                }
            });
            $A.enqueueAction(defaultAccountAction);
        }
        var defaultValue = component.get('v.today');
        if(defaultValue == null)
        {
            //Default new activity to today's date if not specified
            var today = new Date();
            component.set('v.today',today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());
        }
        var action = component.get("c.GetDefaultContact");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var employees = response.getReturnValue();
                if(JSON.stringify(employees) != '[{}]'){
                    component.set("v.hlEmployees", employees);
                }
                component.set("v.primaryEmployee", employees[0].Id);
            }
        });
        $A.enqueueAction(action);
        var primaryAttendee = component.get("v.primaryAttendee");
        if(primaryAttendee){
            var paAction = component.get("c.GetDefaultAttendee");
            paAction.setParams({attendeeId:primaryAttendee});
            paAction.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.externalAttendees", response.getReturnValue());
                }
            });
            $A.enqueueAction(paAction);
        }
        helper.populateActivityTypes(component);
        helper.populateFollowupTypes(component);
    },
    onFollowupCheck : function(component, event, helper) {
        var followup = component.find("scheduleFollowup");
        //Toggle the Followup Fields
        component.set("v.hasFollowup",followup.get("v.value"));
    }, 
    onFollowupClick : function(component){
        var hasFollowup = component.find("scheduleFollowup").get("v.value");
        component.find("scheduleFollowup").set("v.value", !hasFollowup);
        component.set("v.hasFollowup",!hasFollowup);
    },
    onFollowupDateChange : function(component, event){
        //component.find("followupEndDate").set("v.value", component.find("followupStartDate").get("v.value"));
    },
    onFollowupTimeChange : function(component, event){
        component.find("followupEndTime").set("v.value", component.find("followupStartTime").get("v.value"));
    },
    onFollowupSyncToOutlookClick : function(component){
        var followupSyncToOutlook = component.find("followupSyncToOutlook").get("v.value");
        component.find("followupSyncToOutlook").set("v.value", !followupSyncToOutlook);
    },
    onPrimaryEmployeeClick : function(component, event){
        var source = event.getSource();
        var id = source.get("v.buttonTitle");
        console.log('primaryEmployee>>>'+id);
        component.set("v.primaryEmployee",id);
    },
    onPrimaryExternalAttendeeClick : function(component, event){
        var source = event.getSource();
        var id = source.get("v.buttonTitle");
        component.set("v.primaryAttendee",id);
    },
    onPrivateClick : function(component, event){
        var isPrivate = component.find("isPrivate").get("v.value");
        component.find("isPrivate").set("v.value", !isPrivate);
        if(isPrivate){
         component.find("notifyCoverageTeam").set("v.value", false);   
        }
        var toggle = component.find("notifyCoverageTeamLabel");
		$A.util.toggleClass(toggle, 'slds-hide');
    },
    //onPfgClick : function(component){
        //var pfg = component.find("pfg").get("v.value");
        //component.find("pfg").set("v.value", !pfg);
        //component.find("notifyCoverageTeam").set("v.value",pfg);
    //},
    clickNoExternalContact : function(component, event){
        var noExternalContact = event.getSource().get("v.checked");
        component.set("v.noExternalContact",noExternalContact);
    },
    onNotifyCoverageTeamClick : function(component, event){
        var notifyCoverageTeam = component.find("notifyCoverageTeam").get("v.value");
        component.find("notifyCoverageTeam").set("v.value", !notifyCoverageTeam);
    },
    onRemoveExternalAttendeeClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.externalAttendees");
        }  
    },
    onRemoveEmployeeClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.hlEmployees");
        }  
    },
    onRemoveCompanyClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.companies");
        }  
    },
    onRemoveOppClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.opportunities");
        }  
    },
    onRemoveEngClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.engagements");
        }  
    },
    onRemoveCampClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.campaign");
        }  
    },
    onStartDateChange : function(component){
        //component.find("endDate").set("v.value", component.find("startDate").get("v.value"));
    },
    onStartTimeChange : function(component){
        component.find("endTime").set("v.value", component.find("startTime").get("v.value"));
    },
    onSyncToOutlookClick : function(component){
        var syncToOutlook = component.find("syncToOutlook").get("v.value");
        component.find("syncToOutlook").set("v.value", !syncToOutlook);
    },
    onTypeChange : function(component, event, helper){
        var newActivityType = component.find("type").get("v.value");
        var oldActivityType = component.get("v.activityType");
        if(newActivityType == 'Internal' && oldActivityType != 'Internal'){
            component.set("v.externalAttendees",null);
            component.set("v.primaryAttendee", null);
            component.find("v.noExternalContact",false);
        }
        component.set("v.activityType", newActivityType);
        helper.populateFollowupTypes(component);
    },
    
    handleSelectedExternalContact: function(component, event, helper){
        var selectedContact = event.getParam("selectedRecord");  
        var externalAttendees = component.get("v.externalAttendees");
        var primaryAttendee = component.get("v.primaryAttendee");
        if (!externalAttendees) externalAttendees = [];
        externalAttendees.push(selectedContact);
        component.set("v.externalAttendees",externalAttendees);
        if(!primaryAttendee){
            component.set("v.primaryAttendee", selectedContact.Id);
        }
    },
    /*handleExternalContactSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var externalAttendees = component.get("v.externalAttendees");
        var primaryAttendee = component.get("v.primaryAttendee");
        if (!externalAttendees) externalAttendees = [];
        externalAttendees.push(so);
        component.set("v.externalAttendees",externalAttendees);
        if(!primaryAttendee)
            component.set("v.primaryAttendee", so.Id);
    },  
    handleHLEmployeeSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var emps = component.get("v.hlEmployees");
        if (!emps) emps = [];
        emps.push(so);
        component.set("v.hlEmployees",emps);
    }, */  
    handleSelectedContact : function(component, event, helper){
        var selectedContact = event.getParam("selectedRecord");  
        console.log('selectedContact>>>>'+JSON.stringify(selectedContact));
        var emps = component.get("v.hlEmployees");
        if (!emps) emps = [];
        emps.push(selectedContact);
        component.set("v.hlEmployees",emps);
    },
    handleSelectedCompany :  function(component, event, helper){
        var selectedCompany = event.getParam("selectedRecord");  
        //   console.log('selectedContact>>>>'+JSON.stringify(selectedContact));
        var comps = component.get("v.companies");
        if (!comps) comps = [];
        comps.push(selectedCompany);
        component.set("v.companies",comps);
    }, 
    handleSelectedOpportunity :  function(component, event, helper){
        var selectedOpportunity = event.getParam("selectedRecord");  
        var opps = component.get("v.opportunities");
        if (!opps) opps = [];
        opps.push(selectedOpportunity);
        component.set("v.opportunities",opps);
    },
    handleSelectedEngagement :  function(component, event, helper){
        var selectedEngagement = event.getParam("selectedRecord");  
        var engs = component.get("v.engagements");
        if (!engs) engs = [];
        engs.push(selectedEngagement);
        component.set("v.engagements",engs);
    },
    handleSelectedCampaign :   function(component, event, helper){
        var selectedCampaign = event.getParam("selectedRecord");  
       var camp = component.get("v.campaign");
        if (!camp) camp = [];
        camp.push(selectedCampaign);
        component.set("v.campaign",camp);
    },
   /* handleCompanySelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var comps = component.get("v.companies");
        if (!comps) comps = [];
        comps.push(so);
        component.set("v.companies",comps);
    },
    handleOpportunitySelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var opps = component.get("v.opportunities");
        if (!opps) opps = [];
        opps.push(so);
        component.set("v.opportunities",opps);
    },
    handleCampaignSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var camp = component.get("v.campaign");
        if (!camp) camp = [];
        camp.push(so);
        component.set("v.campaign",camp);
    }, */
    saveActivity : function(component, event, helper){
       // var btnSave = component.find("btnSave");
        //var buttonState = btnSave.get("v.disabled");
        
        //if(!buttonState)
      //  {
            component.find("btnSave").set("v.disabled",true);
            var isValid = true;
            var type = component.find("type").get("v.value");
            var subject = component.find("subject").get("v.value");
            var description = component.find("description").get("v.value");
            var internalNotes = component.find("internalNotes").get("v.value");
            var startDate = component.find("startDate").get("v.value");
            var startTime = component.find("startTime").get("v.value");
            var endDate = component.find("startDate").get("v.value");
            var endTime = component.find("endTime").get("v.value");
            var isPrivate = component.find("isPrivate").get("v.value");
            var syncToOutlook = component.find("syncToOutlook").get("v.value");
            var notify = component.find("notifyCoverageTeam").get("v.value");
            var hasFollowup = component.find("scheduleFollowup").get("v.value");
            var fuType = component.find("followupType").get("v.value");
            var fuStartDate = component.find("followupStartDate").get("v.value");
            var fuStartTime = component.find("followupStartTime").get("v.value");
            var fuEndDate = component.find("followupStartDate").get("v.value");
            var fuEndTime = component.find("followupEndTime").get("v.value");
            var fuSyncToOutlook = component.find("followupSyncToOutlook").get("v.value");
            var fuComments = component.find("followupComments").get("v.value");
            var pa = component.get("v.primaryAttendee");
            var pe = component.get("v.primaryEmployee");
            var externalAttendees = component.get("v.externalAttendees");
            var emps = component.get("v.hlEmployees");
            var comps = component.get("v.companies");
            var opps = component.get("v.opportunities");
            var engs = component.get("v.engagements");
            var camp = component.get("v.campaign");
            //var pfg = component.find("pfg").get("v.value");
            //var PfgNottificationChange = component.find("pfgNottification").get("v.value");
            //var clientParticipationChange = component.find("clientParticipation").get("v.value");
            var noExternalContact =component.find("noExternalContact").get("v.checked");
            
            //Call the Server-Side Save Activity Action
            var action = component.get("c.Save");
            action.setAbortable();
            //Validate required fields
            if(!type || !subject || !startDate || !endDate){
                isValid = false;
                alert('Type, Subject and Date fields are Required');
            }
            //console.log(pfg);
            //if(pfg && (PfgNottificationChange=='' || PfgNottificationChange == undefined || PfgNottificationChange == null)){
            //    isValid = false;
            //    alert('Please enter a value for PFG Notification.');
            //}
            console.log('externalAttendees>>>'+JSON.stringify(externalAttendees));
            //Needs to have both an External and Employee Specified
            if(noExternalContact){
                if(isValid && (emps == undefined  || emps == null || emps.length < 1)){
                    isValid = false;
                    alert('At least one HL Employee Required'); 
                }
            }
            else{
                if(isValid && (externalAttendees == undefined || externalAttendees == null || externalAttendees.length < 1 || emps == undefined  || emps == null || emps.length < 1))
                {
                    isValid = false;
                    alert('At least one Attendee and HL Employee Required');
                }
            }
            if(isValid && (pe == null || pe == undefined || pe == '')){
                isValid = false;
                alert('Please select a Primary Attendee');
            }
            
            if(isValid && noExternalContact && externalAttendees.length > 0 && type!="Internal" && type!="Internal Mentor Meeting"){
                isValid = false;
                alert('Please either remove external attendee or uncheck the No External Contact checkbox');    
            }
            
            if(isValid && noExternalContact && !comps.length > 0 && type!="Internal" && type!="Internal Mentor Meeting"){
                isValid = false;
                alert('If no external attendee is entered, then \'Companies Discussed\' is required to create an activity');    
            }
            
            if(isValid && hasFollowup){
                if(!fuStartDate){
                    isValid = false;
                    alert('Follow-up Date is Required');
                }
                if(!fuType){
                    isValid = false;
                    alert('Follow-up Type is Required');
                }
            }
            if(isValid){
                action.setParams({ activityId : null,
                                  type : type,
                                  subject: subject,
                                  description: description,
                                  internalNotes: internalNotes,
                                  startDate:startDate,
                                  startTime:startTime,
                                  endDate:endDate,
                                  endTime:endTime,
                                  isPrivate:isPrivate,
                                  sync:syncToOutlook,
                                  notify:notify,
                                  isComplete: false,
                                  hasFollowup:hasFollowup,
                                  fuType:fuType,
                                  fuStartDate:fuStartDate,
                                  fuStartTime:fuStartTime,
                                  fuEndDate:fuEndDate,
                                  fuEndTime:fuEndTime,
                                  fuSync:fuSyncToOutlook,
                                  fuDescription:fuComments,
                                  primaryAttendee:pa,
                                  primaryEmp:pe,
                                  attendeesJSON:JSON.stringify(externalAttendees),
                                  empsJSON:JSON.stringify(emps),
                                  compsJSON:JSON.stringify(comps),
                                  oppsJSON:JSON.stringify(opps),
                                  engsJSON:JSON.stringify(engs),
                                  campJSON:JSON.stringify(camp),
                                  //PfgClick:pfg,
                                  //PfgNottificationChange:PfgNottificationChange,
                                  //clientParticipationChange:clientParticipationChange,
                                  noExternalContactClick :noExternalContact});
                // Create a callback that is executed after 
                // the server-side action returns
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        helper.showToast();
                        var successEvent = component.getEvent("saveSuccessEvent");
                        successEvent.fire();
                        let sObjectName = component.get("v.sObjectName");
                        if(sObjectName != undefined)
                        $A.get("e.force:closeQuickAction").fire();
                    }
                    else if (state === "ERROR"){
                        component.find("btnSave").set("v.disabled",false);
                        var errors = response.getError();
                        
                        if (errors) {
                            alert(errors[0].message);
                        } else {
                            // $A.error("Unknown error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        else{
                component.find("btnSave").set("v.disabled",false);
        }
        //}
    },
    scriptsLoaded: function(component, event, helper){
        if (typeof jQuery !== "undefined" && typeof $j === "undefined") {
            $j = jQuery.noConflict(true);
        } 
    }
})