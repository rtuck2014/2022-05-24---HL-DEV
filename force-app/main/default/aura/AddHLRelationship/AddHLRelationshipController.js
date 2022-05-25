({
	doInit : function(component, event, helper){
         var recordId = component.get("v.recordId");
        if(recordId != undefined && recordId != null && recordId !='' ){
            component.set("v.contactId",recordId);
        }
        var action = component.get("c.GetDefaultContact");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var employee = response.getReturnValue();
                component.set("v.employeeId", employee[0].Id);
                component.set("v.employeeName", employee[0].Name);
                var relCheck = component.get("c.DoesExist");
                var contactId = component.get("v.contactId");
                relCheck.setParams({empId:employee[0].Id, contactId:contactId});
                relCheck.setCallback(this, function(a){
                    var doesExist = a.getReturnValue();
                	component.set("v.mode", (doesExist ? 'Edit' : 'Add'));
                    
                    if(doesExist){
                        var recordAction = component.get("c.GetByEmployeeAndContact");
                        recordAction.setParams({empId:employee[0].Id, contactId:contactId});
                        recordAction.setCallback(this, function(b){
                            var record = b.getReturnValue();
                            component.find("rating").set("v.value",record.Strength_Rating__c);
                            component.find("type").set("v.value",record.Type__c);
                            component.find("description").set("v.value",record.Personal_Note__c);
                            component.find("outlookCategories").set("v.value", record.Outlook_Categories__c);
                            component.find("syncToOutlook").set("v.value",record.Sync_to_Outlook__c);
                            component.set("v.loaded",true);
                        });
                        $A.enqueueAction(recordAction);
                    }
                    else{
                        component.set("v.loaded",true);
                    }
                });
            	$A.enqueueAction(relCheck);
            }
        });
	 	$A.enqueueAction(action);
    },
    handleHLEmployeeSelection : function(component, event, helper){
    	var so = event.getParam("selectedOption");
        if(so){
        	component.set("v.employeeId",so.Id);
        	component.set("v.employeeName",so.Name);
        }
    },
    saveRecord : function(component, event, helper){
        component.find("btnSave").set("v.disabled",true);
        var isValid = true;
        var contactId = component.get("v.contactId");
        var empId = component.get("v.employeeId");
        var rating = component.find("rating").get("v.value");
        var type = component.find("type").get("v.value");
        var description = component.find("description").get("v.value");
        var outlookCategories = component.find("outlookCategories").get("v.value");
        var sync = component.find("syncToOutlook").get("v.value");
        var mode = component.get("v.mode");
        var saveAction = mode == 'Add' ? component.get("c.SaveRelationship") : component.get("c.UpdateRelationship");
        saveAction.setAbortable();
        saveAction.setParams({
            empId : empId,
            contactId : contactId,
            rating: rating,
            type: type,
            description: description,
            outlookCategories: outlookCategories,
            sync: sync
        });
        saveAction.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.showToast();
                var recordId = component.get("v.recordId");
                if(recordId == undefined || recordId == null && recordId ==''){
                var successEvent = component.getEvent("saveSuccessEvent");
                successEvent.fire();   
                }
                else{
                    $A.get("e.force:closeQuickAction").fire();
                }
                //var action = $A.get("e.force:navigateToSObject");
                //action.setParams({recordId:contactId});
                    //$A.get("e.force:navigateToComponent");
                //action.setParams({
                    //componentDef: "c:MyContacts"
                //});
                //action.fire();
            }  
            else if (state === "ERROR"){
                component.find("btnSave").set("v.disabled",false);
                var errors = response.getError();
                alert(errors[0].message);
                alert('Relationship Already Exists');
                if (errors) {
                    $A.logf("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        $A.error("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    $A.error("Unknown error");
                }
            }
        });
        $A.enqueueAction(saveAction);
    }
})