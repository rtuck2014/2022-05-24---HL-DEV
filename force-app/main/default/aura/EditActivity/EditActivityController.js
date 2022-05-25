({
    doInit:function(component, event, helper){
        var activityId = component.get("v.activityId");
        var getActivityAction = component.get("c.GetById");
        var primaryId;
        
        getActivityAction.setParams({eventId:activityId});
        getActivityAction.setCallback(this, function(a){
            var eventRecord = a.getReturnValue();
            component.set("v.activity", eventRecord);
            component.set("v.primaryAttendee", eventRecord.Primary_External_Contact_Id__c);
            component.set("v.primaryEmployee", eventRecord.Primary_Attendee_Id__c);
            primaryId = eventRecord.ParentId__c == null ? activityId : eventRecord.ParentId__c;
            var attendeesAction = component.get("c.GetAttendees");
            var employeesAction = component.get("c.GetEmployees");
            var companiesAction = component.get("c.GetComps");
            var oppsAction = component.get("c.GetOpps");
            var engsAction = component.get("c.GetEngs");
            var campAction = component.get("c.GetCamp"); 
            attendeesAction.setParams({"eventId":primaryId});
            employeesAction.setParams({"eventId":primaryId});
            companiesAction.setParams({"eventId":primaryId});
            oppsAction.setParams({"eventId":primaryId});
            engsAction.setParams({"eventId":primaryId});
            campAction.setParams({"eventId":primaryId});
            attendeesAction.setCallback(this,function(aa){component.set("v.relatedAttendees",aa.getReturnValue()); });
            employeesAction.setCallback(this,function(ea){component.set("v.relatedEmployees",ea.getReturnValue()); });
            companiesAction.setCallback(this,function(ca){component.set("v.relatedCompanies",ca.getReturnValue()); });
            oppsAction.setCallback(this,function(oa){component.set("v.relatedOpps",oa.getReturnValue()); });
            engsAction.setCallback(this,function(eng){component.set("v.relatedEngs",eng.getReturnValue()); });
            campAction.setCallback(this,function(cp){component.set("v.relatedCamp",cp.getReturnValue()); });
            $A.enqueueAction(attendeesAction);
            $A.enqueueAction(employeesAction);
            $A.enqueueAction(companiesAction);
            $A.enqueueAction(oppsAction);
            $A.enqueueAction(engsAction);
            $A.enqueueAction(campAction);
            helper.populateActivityTypes(component, helper);
        });
        $A.enqueueAction(getActivityAction);
        
        //Get the Activity Supplement Record
        var activitySupplementAction = component.get("c.GetActivitySupplement");
        activitySupplementAction.setParams({eventId:activityId});
        activitySupplementAction.setCallback(this, function(response){
            component.set("v.activitySupplement", response.getReturnValue());                                 
        });       
        $A.enqueueAction(activitySupplementAction);
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
    onFollowupStartDateChange : function(component){
        //component.find("followupEndDate").set("v.value", component.find("followupStartDate").get("v.value"));
    },
    onFollowupStartTimeChange : function(component){
        component.find("followupEndTime").set("v.value", component.find("followupStartTime").get("v.value"));
    },
    onFollowupSyncToOutlookClick : function(component){
        var followupSyncToOutlook = component.find("followupSyncToOutlook").get("v.value");
        component.find("followupSyncToOutlook").set("v.value", !followupSyncToOutlook);
    },
    onPrimaryEmployeeClick : function(component, event){
        var source = event.getSource();
        var id = source.get("v.buttonTitle");
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
    onNotifyCoverageTeamClick : function(component, event){
        var notifyCoverageTeam = component.find("notifyCoverageTeam").get("v.value");
        component.find("notifyCoverageTeam").set("v.value", !notifyCoverageTeam);
    },
    onRemoveExternalAttendeeClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.relatedAttendees");
        }  
    },
    onRemoveEmployeeClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.relatedEmployees");
        }  
    },
    onRemoveCompanyClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.relatedCompanies");
        }  
    },
    onRemoveOppClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.relatedOpps");
        }  
    },
    onRemoveEngClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.relatedEngs");
        }  
    },
    onRemoveCampClick : function(component, event, helper){
        if(confirm('Remove?')){
            helper.removeRelatedObject(component,event,"v.relatedCamp");
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
        helper.onTypeChanged(component, helper, true);
    },
    //onPfgClick : function(component){
    //    var pfg = component.find("pfg").get("v.value");
    //    component.find("pfg").set("v.value", !pfg);
    //    component.find("notifyCoverageTeam").set("v.value",pfg);
    //},
    noExternalContactClick : function(component,event, helper){
        var noExternalContact = event.getSource().get("v.checked");
        component.set("v.noExternalContact",noExternalContact);
    },
    handleSelectedExternalContact: function(component, event, helper){
        var selectedContact = event.getParam("selectedRecord");  
        var externalAttendees = component.get("v.relatedAttendees");
        if (!externalAttendees) externalAttendees = [];
        externalAttendees.push(selectedContact);
        component.set("v.relatedAttendees",externalAttendees);
    },
    
    /* handleExternalContactSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var externalAttendees = component.get("v.relatedAttendees");
        if (!externalAttendees) externalAttendees = [];
        externalAttendees.push(so);
        component.set("v.relatedAttendees",externalAttendees);
    },  
    handleHLEmployeeSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var emps = component.get("v.relatedEmployees");
        if (!emps) emps = [];
        emps.push(so);
        component.set("v.relatedEmployees",emps);
    },  
    handleCompanySelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var comps = component.get("v.relatedCompanies");
        if (!comps) comps = [];
        comps.push(so);
        component.set("v.relatedCompanies",comps);
    },  
    handleOpportunitySelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var opps = component.get("v.relatedOpps");
        if (!opps) opps = [];
        opps.push(so);
        component.set("v.relatedOpps",opps);
    },
    handleCampaignSelection:function(component, event, helper){
        var so = event.getParam("selectedOption");
        var camp = component.get("v.relatedCamp");
        if (!camp) camp = [];
        camp.push(so);
        component.set("v.relatedCamp",camp);
    }, */
    handleSelectedContact : function(component, event, helper){
        var selectedContact = event.getParam("selectedRecord");  
        console.log('selectedContact>>>>'+JSON.stringify(selectedContact));
        var emps = component.get("v.relatedEmployees");
        if (!emps) emps = [];
        emps.push(selectedContact);
        component.set("v.relatedEmployees",emps);
    },
    handleSelectedCompany :  function(component, event, helper){
        var selectedCompany = event.getParam("selectedRecord");  
        //   console.log('selectedContact>>>>'+JSON.stringify(selectedContact));
        var comps = component.get("v.relatedCompanies");
        if (!comps) comps = [];
        comps.push(selectedCompany);
        component.set("v.relatedCompanies",comps);
    }, 
    handleSelectedOpportunity :  function(component, event, helper){
        var selectedOpportunity = event.getParam("selectedRecord");  
        var opps = component.get("v.relatedOpps");
        if (!opps) opps = [];
        opps.push(selectedOpportunity);
        component.set("v.relatedOpps",opps);
    },
    handleSelectedEngagement :  function(component, event, helper){
        var selectedEngagement = event.getParam("selectedRecord");  
        var engs = component.get("v.relatedEngs");
        if (!engs) engs = [];
        engs.push(selectedEngagement);
        component.set("v.relatedEngs",engs);
    },
    handleSelectedCampaign :   function(component, event, helper){
        var selectedCampaign = event.getParam("selectedRecord");  
        var camp = component.get("v.relatedCamp");
        if (!camp) camp = [];
        camp.push(selectedCampaign);
        component.set("v.relatedCamp",camp);
    },
    saveActivity : function(component, event, helper){
        component.find("btnSave").set("v.disabled",true);
        var isValid = true;
        var activityId = component.get("v.activityId");
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
        var isComplete = false;
        if(component.find("isComplete"))
            isComplete = component.find("isComplete").get("v.value");
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
        var externalAttendees = component.get("v.relatedAttendees");
        var emps = component.get("v.relatedEmployees");
        var comps = component.get("v.relatedCompanies");
        var opps = component.get("v.relatedOpps");
        var engs = component.get("v.relatedEngs");
        var camp = component.get("v.relatedCamp");
        //var pfg = component.find("pfg").get("v.value");
        //var PfgNottificationChange = component.find("pfgNottification").get("v.value");
        //var clientParticipationChange = component.find("clientParticipation").get("v.value");
        var noExternalContact =component.find("noExternalContact").get("v.checked");
        //Call the Server-Side Save Activity Action
        var action = component.get("c.Save");
        //Validate required fields
        if(!type || !subject || !startDate || !endDate){
            isValid = false;
            alert('Type, Subject and Date Fields are Required');
        }
        //if(pfg && (PfgNottificationChange=='' || PfgNottificationChange == undefined || PfgNottificationChange == null)){
        //    isValid = false;
        //    alert('Please enter a value for PFG Notification.');
        //}
        //Needs to have both an External and Employee Specified
        if(isValid && noExternalContact && (emps == undefined  || emps == null || emps.length < 1)){
            isValid = false;
            alert('At least one HL Employee Required'); 
        }
        
        if(isValid &&  !noExternalContact && (externalAttendees == undefined || externalAttendees == null || externalAttendees.length < 1 || emps == undefined  || emps == null || emps.length < 1))
        {
            isValid = false;
            alert('At least one Attendee and HL Employee Required');
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
        //Validate Followup Date
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
            action.setParams({ activityId: activityId,
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
                              isComplete:isComplete,
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
                    var relatedRecordId = component.get("v.relatedRecordId");
                    if(relatedRecordId == '' || relatedRecordId == null || relatedRecordId == undefined){
                        var action = $A.get("e.force:navigateToComponent");
                        action.setParams({
                            componentDef: "c:MyActivities"
                        });
                        action.fire();
                    }else{
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": relatedRecordId,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                    }
                }
                else if (state === "ERROR"){
                    component.find("btnSave").set("v.disabled",false);
                    var errors = response.getError();
                    alert(errors[0].message);
                    if (errors) {
                        $A.logf("Errors", errors);
                        if (errors[0] && errors[0].message) {
                            $A.error("Error message: " + 
                                     errors[0].message);
                        }
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
        
    },
    scriptsLoaded: function(component, event, helper){
        if (typeof jQuery !== "undefined" && typeof $j === "undefined") {
            $j = jQuery.noConflict(true);
        } 
    }
})