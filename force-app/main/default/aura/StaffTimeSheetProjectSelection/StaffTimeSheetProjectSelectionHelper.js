({
    buildSelections: function(component, helper) {
        var category = component.get("v.category");
    	var isDisabled = component.get("v.isDisabled");  
        var opportunities = component.get("v.selectableOpportunities");
        var engagements = component.get("v.selectableEngagements");
        var specialProjects = component.get("v.selectableSpecialProjects");
        var projectSelections = [];
        engagements.forEach(function(e) {
            var frClosed = false;
            if (e.Close_Date__c != undefined && category == 'FR') {
                var closeDate = new Date(e.Close_Date__c);
            	var twoMonthsAgo = new Date();
                twoMonthsAgo.setMonth(twoMonthsAgo.getMonth() - 2);
                if (closeDate >= twoMonthsAgo) {
                    frClosed = true;
                }
            }
            var name = e.Name + "-" + e.Line_of_Business__c + "-" + e.Engagement_Number__c;
            if (e.Engagement_Number__c == undefined) {
                name = e.Name + "-" + e.Line_of_Business__c;
            }
			if (!isDisabled && (e.Close_Date__c == undefined || frClosed)) {
                projectSelections.push({
                    Id: e.Id,
                    DisplayType: "Engagement",
                    DisplayTypeShort: "E -",
                    Type: "Engagement__c",
                    Name: name,
                    RequireComments: false
                }); 
            }
            else if (isDisabled)  {
                projectSelections.push({
                    Id: e.Id,
                    DisplayType: "Engagement",
                    DisplayTypeShort: "E -",
                    Type: "Engagement__c",
                    Name: name,
                    RequireComments: false
                }); 
            }
        });
        specialProjects.forEach(function(sp) {
          projectSelections.push({
            Id: sp.Id,
            DisplayType: "Special Project",
            DisplayTypeShort: "S -",
            Type: "Special_Project__c",
            Name: sp.Name,
            RequireComments: sp.Require_Comments__c
          });
        });
        opportunities.forEach(function(o) {
            if (!isDisabled && o.Status__c != 'Engaged') {
				projectSelections.push({
                    Id: o.Id,
                    DisplayType: "Opportunity",
                    DisplayTypeShort: "O -",
                    Type: "Opportunity__c",
                    Name: o.Name + "-" + o.Line_of_Business__c + "-" + o.Opportunity_Number__c,
                    RequireComments: false
                });  
            }
            else if (isDisabled) 
            {
                projectSelections.push({
                    Id: o.Id,
                    DisplayType: "Opportunity",
                    DisplayTypeShort: "O -",
                    Type: "Opportunity__c",
                    Name: o.Name + "-" + o.Line_of_Business__c + "-" + o.Opportunity_Number__c,
                    RequireComments: false
                });
            }
        });
        
    console.log('projectSelections',projectSelections)
        component.set("v.filteredProjectSelections", projectSelections);
	},
	onProjectSelected: function(component) {
		var projectControl = component.find("project");
		var selectionEvent = component.getEvent("projectSelectionEvent");

		//Fire the Selection Event
		selectionEvent.setParams({
			"selectedId": projectControl.get("v.value")
		});
		selectionEvent.fire();
	}
})