({
    doInit : function(component, event) {
        var myPageRef = component.get("v.pageReference");
        if(myPageRef != undefined && myPageRef != null){
            var activityId = myPageRef.state.c__selectedActivityId;
            var relatedRecordId = myPageRef.state.c__relatedRecordId;
            var relatedParentAPI = myPageRef.state.c__relatedParentAPI;
            component.set("v.activityId", activityId);
            component.set("v.relatedRecordId", relatedRecordId);
            component.set("v.relatedParentAPI", relatedParentAPI);
        }
        var action = component.get("c.GetById");
        var eventId = component.get("v.activityId");
        var primaryId;
        action.setParams({eventId: eventId});
        
        action.setCallback(this, function(a) {
            var eventRecord = a.getReturnValue();
            component.set("v.activity", eventRecord);
            component.set("v.activityType", eventRecord.Type);
            primaryId = eventRecord.ParentId__c == null ? eventId : eventRecord.ParentId__c;
            component.set("v.primaryActivityId", primaryId);
            
            var deleteAction = component.get("c.HasDeleteRights");
            var attendeesAction = component.get("c.GetAttendees");
            var employeesAction = component.get("c.GetEmployees");
            var companiesAction = component.get("c.GetComps");
            var oppsAction = component.get("c.GetOpps");
            var engsAction = component.get("c.GetEngs");
            var campAction = component.get("c.GetCamp"); 
            
            deleteAction.setParams({"eventId":primaryId});
            attendeesAction.setParams({"eventId":primaryId});
            employeesAction.setParams({"eventId":primaryId});
            companiesAction.setParams({"eventId":primaryId});
            oppsAction.setParams({"eventId":primaryId});
            engsAction.setParams({"eventId":primaryId});
            campAction.setParams({"eventId":primaryId});
            
            deleteAction.setCallback(this,function(da){component.set("v.deleteEnabled",da.getReturnValue()); });
            attendeesAction.setCallback(this,function(aa){component.set("v.relatedAttendees",aa.getReturnValue()); });
            employeesAction.setCallback(this,function(ea){component.set("v.relatedEmployees",ea.getReturnValue()); });
            companiesAction.setCallback(this,function(ca){component.set("v.relatedCompanies",ca.getReturnValue()); });
            oppsAction.setCallback(this,function(oa){component.set("v.relatedOpps",oa.getReturnValue()); });
            engsAction.setCallback(this,function(eng){component.set("v.relatedEngs",eng.getReturnValue()); });
            campAction.setCallback(this,function(cp){component.set("v.relatedCamp",cp.getReturnValue()); });
            
            $A.enqueueAction(deleteAction);
            $A.enqueueAction(attendeesAction);
            $A.enqueueAction(employeesAction);
            $A.enqueueAction(companiesAction);
            $A.enqueueAction(oppsAction);
            $A.enqueueAction(engsAction);
            $A.enqueueAction(campAction);
        });
        $A.enqueueAction(action);
        
        //Get the Activity Supplement Record
        var activitySupplementAction = component.get("c.GetActivitySupplement");
        activitySupplementAction.setParams({eventId:eventId});
        activitySupplementAction.setCallback(this, function(response){
            console.log('Response');
            console.log(response.getReturnValue());
            component.set("v.activitySupplement", response.getReturnValue());                                 
        });       
        $A.enqueueAction(activitySupplementAction);
    },
    cancelSendEmail : function(component){
        component.set("v.isEmailing", false);
    },
    cancelEditActivity : function(component){
        component.set("v.isEditing", false);
    },
    confirmDelete : function(component, event){
        if(confirm('Are you sure?')){
            var eventRecord = component.get("v.activity");
            var primaryId = (eventRecord.ParentId__c == null) ? eventRecord.Id : eventRecord.ParentId__c;
            var action = component.get("c.DeleteRecord");
            action.setParams({"id":primaryId});
            action.setCallback(this,function(response){           
                var navAction = $A.get("e.force:navigateToComponent");
                navAction.setParams({
                    componentDef: "c:MyActivities"
                });
                navAction.fire();
            });
            $A.enqueueAction(action);
        }
    },
    emailSent : function(component, event){
        component.set("v.isEmailing", false);
    },
    navigateToEdit : function(component, event){
        //var action = $A.get("e.force:navigateToComponent");
        //var eventId = component.get("v.activityId");
        //action.setParams({
        //componentDef: "c:EditActivity",
        //componentAttributes: {
        // activityId:eventId   
        //}
        //});
        //action.fire();
        component.set("v.isEditing", true);
    },
    navigateToEmail : function(component, event){
        //var action = $A.get("e.force:navigateToComponent");
        //var eventId = component.get("v.activityId");
        //action.setParams({
        //componentDef: "c:SendEmail",
        //componentAttributes: {
        //templateId:'Event',
        //relatedId:eventId   
        //}
        //});
        //action.fire();
        component.set("v.isEmailing", true);
    },
    navigateToMyActivities : function(component, event){
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
})