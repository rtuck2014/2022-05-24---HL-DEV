({
    onInit: function(component, event, helper) {
        var selectedId = component.get("v.selectedProjectId");
        
        if (!selectedId) {
            var rowRecord = component.get("v.rowRecord");
            if (rowRecord && rowRecord.ProjectId)
                component.set("v.selectedProjectId", rowRecord.ProjectId);
        }
        
        helper.handleProjectRequirements(component);
        helper.showForecastActivityType(component,event,helper);
    },
    fireSaveSuccess: function(component, helper, saveOperation) {
        var saveSuccessEvent = component.getEvent("saveSuccessEvent");
        
        saveSuccessEvent.setParams({
            "saveOperation": saveOperation
        });
        
        saveSuccessEvent.fire();
    },
    handleProjectRequirements: function(component) {
        var selectedId = component.get("v.selectedProjectId");
        var projectSelections = component.get("v.projectSelections");
        var selectedProject;
        
        projectSelections.filter(function(p) {
            if (p.Id === selectedId) {
                selectedProject = p;
            }
        });
        
        if (selectedProject)
            component.set("v.selectedProject", selectedProject);
    },
    onProjectSelected: function(component, event, helper) {
        var rowRecord = component.get("v.rowRecord");
        var projectSelections = component.get("v.projectSelections");
        var selectedId = event.getParam("selectedId");
        var selectedProject;
        
        projectSelections.filter(function(p) {
            if (p.Id === selectedId) {
                selectedProject = p;
            }
        });
        
        if(selectedProject && rowRecord.OriginalProjectId != null){
            //Update the Project on the Activity Records
            var rowJSON = [];
            rowRecord.DateRecord.forEach(function(dateRecord){
                dateRecord.ActivityRecord.forEach(function(activityRecord){
                    if(activityRecord.Id != null){
                        rowJSON.push({
                            "sobjectType": "Time_Record__c",
                            "Id": activityRecord.Id,
                            "Activity_Type__c": (selectedProject.Type == "Special_Project__c" ? "" : activityRecord.ActivityType),
                            "Engagement__c": (selectedProject.Type == "Engagement__c" ? selectedProject.Id : null),
                            "Opportunity__c": (selectedProject.Type == "Opportunity__c" ? selectedProject.Id : null),
                            "Special_Project__c": (selectedProject.Type == "Special_Project__c" ? selectedProject.Id : null)
                        });
                    }
                });
            });
            if(rowJSON.length > 0){
                helper.callServer(component, "c.UpdateRecords", function(response) {
                    
                }, {
                    "timeRecords": rowJSON
                });
            }
            
        }
        
        rowRecord.ProjectId = selectedId;
        
        component.set("v.selectedProjectId", selectedId);
        component.set("v.rowRecord", rowRecord);
        if (selectedProject)
            component.set("v.selectedProject", selectedProject);
        helper.showForecastActivityType(component,event,helper);
    },
    
    showForecastActivityType : function(component, event, helper){
        let category = component.get("v.category");
        let dateValues = component.get("v.dateValues");
        let startDate = Date.parse(dateValues[0]);
        let currentDate = new Date();
        let projectSelections = component.get("v.projectSelections");
        let selectedId = component.get("v.selectedProjectId");
        let selectedProjectType;
        let selectedProjectRecordType;
        
        projectSelections.filter(function(p) {
            if (p.Id === selectedId) {
                selectedProjectType =  p.Type;
            }
        }); 
        if(category === 'Beta'
           &&(((selectedProjectType == 'Engagement__c' 
           || selectedProjectType == 'Opportunity__c')
           && startDate > currentDate)
              || selectedProjectType == 'Special_Project__c')){
            component.set("v.showForecastActivityType", true);
            console.log('insideif>>>');
        }else{
            component.set("v.showForecastActivityType", false);
        }
        
        if(selectedProjectType == 'Engagement__c' 
           || selectedProjectType == 'Opportunity__c'
           || (selectedProjectType == 'Special_Project__c' && category == 'Beta' )){
            component.set("v.showActivityType", true);
        }else{
            component.set("v.showActivityType", false);
        }
        
        if(category === 'Beta' && selectedProjectType == 'Special_Project__c' && startDate <= currentDate){
            component.set("v.currentOrPriorPeriod", true);
        }else{
            component.set("v.currentOrPriorPeriod", false);
        }
        
        /*  let bypassValidationString = $A.get("$Label.c.Bypass_Beta_Special_Project_Required_Validation");
        let bypassValidation = (bypassValidationString === 'true');
        let effectiveDate = $A.get("$Label.c.Beta_Special_Project_Required_Effective_Date");
        let activityTypeRequired = false;
        if(effectiveDate){
           effectiveDate = Date.parse(effectiveDate);
            console.log('effectiveDate>>>'+typeof(effectiveDate));
        }
        
        if(selectedProjectType == 'Engagement__c' 
           || selectedProjectType == 'Opportunity__c'){
            activityTypeRequired = true;
        }else if(category == 'Beta' && selectedProjectType == 'Special_Project__c'){
            if(!bypassValidation){
                activityTypeRequired = true;
            }else if(bypassValidation && startDate > effectiveDate){
                activityTypeRequired = true;
            }
        }
        component.set("v.activityTypeRequired",activityTypeRequired);   */     
    } 
})