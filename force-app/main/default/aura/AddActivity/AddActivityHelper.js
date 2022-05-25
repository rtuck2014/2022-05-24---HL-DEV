({
    initHandlers: function(component) {
        var ready = component.get("v.ready");
        
        if (ready === false) {
            return;
        }
        
        var ctx = component.getElement();   
    },
    populateActivityTypes:function(component){
        //Get Internal Access
        var hasInternalAccessAction = component.get("c.HasInternalTypeAccess");
        
        hasInternalAccessAction.setCallback(this, function(hasInternalAccessResponse){
            var state = hasInternalAccessResponse.getState();
            if(state === "SUCCESS"){
                var hasInternalAccess = hasInternalAccessResponse.getReturnValue();
                component.set("v.hasInternalAccess", hasInternalAccess);
                var getActivityTypesAction = component.get("c.GetActivityTypes");
                getActivityTypesAction.setCallback(this, function(response){
                    var state = response.getState();
                    if(state === "SUCCESS"){
                        var options = [{class: "", label: "", value: "", selected: "true"}];
                        var activityTypes = response.getReturnValue();
                        activityTypes.forEach(function(activityType){
                            if(activityType == 'Internal')
                                options.push({class:"", label: activityType, value: activityType, disabled:!hasInternalAccess});
                            else
                                options.push({class:"", label: activityType, value: activityType});
                        });
                        component.set("v.activityTypes", activityTypes);
                        component.find("type").set("v.options", options);
                    }                           
                });
                $A.enqueueAction(getActivityTypesAction);
            }
        });
        $A.enqueueAction(hasInternalAccessAction);   
    },
    populateFollowupTypes:function(component){
        var hasInternalAccess = component.get("v.hasInternalAccess");
        var activityType = component.find("type").get("v.value");
        var getFollowupTypesAction = component.get("c.GetFollowupTypes");
        if(!activityType)
            activityType = '';
        
        getFollowupTypesAction.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var options = [{class: "", label: "", value: "", selected: "true"}];
                var followupTypes = response.getReturnValue();
                followupTypes.forEach(function(followupType){
                    if((hasInternalAccess && followupType === 'Internal') || 
                       (activityType !== 'Internal' && activityType !== 'Follow-up Internal' && followupType === 'External'))
                        options.push({class:"", label: followupType, value: followupType});
                });
                component.set("v.followupTypes", followupTypes);
                component.find("followupType").set("v.options", options);
            }                           
        });
        $A.enqueueAction(getFollowupTypesAction);
    },
    removeRelatedObject:function(component, event, attribute){
        var source = event.getSource();
        var id = source.get("v.buttonTitle");
        var relatedObjects = component.get(attribute);
        for (var i = 0; i < relatedObjects.length; i++) {
            if(relatedObjects[i].Id === id){
                relatedObjects.splice(i,1);
                break;
            }
        }
        //Re-assign the attribute with the attendee removed
        component.set(attribute, relatedObjects); 
    },
    showToast : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been saved successfully."
        });
        toastEvent.fire();
    }
})