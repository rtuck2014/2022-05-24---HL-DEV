({
  checkBrowser: function(component, helper) {
      var isChrome = !!window.chrome && !!window.chrome.webstore;
      component.set("v.isChrome", true); //Hardcoding for now as a temp fix to Chrome update
  },
  aggregateProjectSelections: function(component, helper) {
    var opportunities = component.get("v.opportunities");
    var engagements = component.get("v.engagements");
    var specialProjects = component.get("v.specialProjects");
    var projectSelections = [];
    engagements.forEach(function(e) {
      projectSelections.push({
        Id: e.Id,
        DisplayType: "Engagement",
        DisplayTypeShort: "E -",
        Type: "Engagement__c",
        Name: e.Name + "-" + e.Line_of_Business__c + "-" + e.Engagement_Number__c,
        RequireComments: false
      });
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
      projectSelections.push({
        Id: o.Id,
        DisplayType: "Opportunity",
        DisplayTypeShort: "O -",
        Type: "Opportunity__c",
        Name: o.Name + "-" + o.Line_of_Business__c + "-" + o.Opportunity_Number__c,
        RequireComments: false
      });
    });
    component.set("v.projectSelections", projectSelections); 
  },
  getCategory: function(component, helper) {
    helper.callServer(component, "c.GetCategory", function(response) {
      var category = response;
        console.log('category',category)
      component.set("v.category", category);
      helper.getIsSupervisor(component, helper, category);
    });
    helper.callServer(component, "c.GetCurrentUserId", function(response){
      component.set("v.userId", response);
    });
  },
  getIsSupervisor: function(component, helper, category) {
    helper.callServer(component, "c.IsSupervisor", function(response) {
      component.set("v.isSupervisor", response);
      helper.getCurrentTimeRecordStaffMember(component, helper, category);
    }, {
      "category": category
    });
  },
  // returns default Time_Record_Period_Staff_Member__c
  getCurrentTimeRecordStaffMember: function(component, helper, category) {
    helper.callServer(component, "c.GetCurrentTimeRecordPeriodStaffMemberRecord", function(response) {
      component.set("v.selectedTimeRecordPeriodStaffMember", response);
      helper.getProjectSelectionObjects(component, helper);
    }, {
      "category": category
    });
  },
  // returns Time_Record_Period_Staff_Member__c
  getPeriodTimeRecordStaffMember: function(component, helper) {
    var category = component.get("v.category");
    var timePeriod = component.get("v.selectedTimeRecordPeriod");

    helper.callServer(component, "c.GetTimeRecordPeriodStaffMemberRecord", function(response) {
      component.set("v.selectedTimeRecordPeriodStaffMember", response);
      helper.getProjectSelectionObjects(component, helper);
      component.set("v.renderPage", true);
    }, {
      "category": category,
      "timePeriod": timePeriod
    });
  },
  serverSideCall: function(action, component) {
      return new Promise(function(resolve, reject) {
          action.setCallback(this, function(response) {
              var state = response.getState();
                
              if (component.isValid() && state === "SUCCESS") {
                  resolve(response.getReturnValue());
              }
              else if (component.isValid() && state === "ERROR") {
                  reject(new Error(response.getError()));
              }
                    
            });
          	$A.enqueueAction(action);
      });                          
  },
  getProjectSelectionObjects: function(component, helper) {  
      var staffMember = component.get("v.selectedTimeRecordPeriodStaffMember");
      
      if (staffMember) {
        var category = component.get("v.category");
        var getEngagementsAction = component.get('c.GetEngagements');
        getEngagementsAction.setParams({
            category: category,
            userId: staffMember.User__c
        });  
        var getOpportunitiesAction = component.get('c.GetOpportunities');
        getOpportunitiesAction.setParams({
            category: category,
            userId: staffMember.User__c
        });  
        var getSpecialProjectsAction = component.get('c.GetSpecialProjects');
        getSpecialProjectsAction.setParams({category: category});  
          
		Promise.all([
            helper.serverSideCall(getEngagementsAction, component),
            helper.serverSideCall(getOpportunitiesAction, component),
            helper.serverSideCall(getSpecialProjectsAction, component)
        ]).then($A.getCallback(function(response) {
            //alert('then ' + response[0].length + ' ' + response[1].length + ' ' + response[2].length);
            component.set("v.engagements", response[0]);
            component.set("v.opportunities", response[1]);
            component.set("v.specialProjects", response[2]);
            component.set("v.renderPage", true);
            helper.aggregateProjectSelections(component, helper);
        }));
      }
  },
  setActiveTab: function(component, activeTab, inactiveTabs) {
    var elemTabHeadingActive = document.getElementById(activeTab);
    var elemTabActive = document.getElementById(activeTab.replace('-heading', ''));

    if (!$A.util.hasClass(elemTabHeadingActive, "slds-active"))
      $A.util.addClass(elemTabHeadingActive, "slds-active");

    inactiveTabs.forEach(function(tab) {
      var element = document.getElementById(tab);
      if ($A.util.hasClass(element, "slds-active"))
        $A.util.removeClass(element, "slds-active");
    });

    if (!$A.util.hasClass(elemTabActive, "slds-show")) {
      $A.util.addClass(elemTabActive, "slds-show");
      if ($A.util.hasClass(elemTabActive, "slds-hide"))
        $A.util.removeClass(elemTabActive, "slds-hide");
    }

    inactiveTabs.forEach(function(tab) {
      var element = document.getElementById(tab.replace('-heading', ''));

      if ($A.util.hasClass(element, "slds-show")) {
        $A.util.removeClass(element, "slds-show");

        if (!$A.util.hasClass(element, "slds-hide"))
          $A.util.addClass(element, "slds-hide");
      }

      component.set("v.activeTab", activeTab.replace('-heading', ''));
    });

    //Most Tabs will Show the Period Picker and Staff List so Default Here and the Exceptions will Handle on their own.
    component.set("v.periodPickerClass", "");
    component.set("v.staffListClass", "");
  },
  staffTimeSheetTabSelected: function(component, event, helper) {
    var staffTimeSheetActiveTab = event.getParam("selectedId");
    if (staffTimeSheetActiveTab === "tab-recorder") {
      component.set("v.periodPickerClass", "hidden");
      component.set("v.staffListClass", "hidden");
    } else {
      component.set("v.periodPickerClass", "");
      component.set("v.staffListClass", "");
    }
  },
  toggleSpinner: function(component, hide) {
    var m = component.find("modalspinner");

    if (hide) {
      $A.util.addClass(m, "slds-hide");
      component.set("v.suppressSpinners", true);
    } else
      $A.util.removeClass(m, "slds-hide");
    var spinner = component.find('spinner');
    var evt = spinner.get("e.toggle");
    evt.setParams({
      isVisible: !hide
    });
    evt.fire();
  },    
  hideSpinner: function(component, event, helper) {
        if (!component.get("v.suppressSpinners")) {
            if (component.get("v.isTimeRecordPeriodPickerLoaded") &&
                (!component.get("v.isSupervisor") || component.get("v.isTimeRecordPeriodStaffMemberTileListLoaded")) &&
                (component.get("v.isStaffTimeSheetLoaded") || component.get("v.isStaffTimeSheetWeekLoaded"))) {
                helper.toggleSpinner(component, true);
            }
        } else
            helper.toggleSpinner(component, true);
    }
})