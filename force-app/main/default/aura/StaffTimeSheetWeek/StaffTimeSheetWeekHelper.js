({
    deleteRecord: function(component, helper, recordId){
        helper.callServer(component, "c.DeleteRecord", function(response){
            this.getTimeRecords(component, helper);
        }, {"recordId":recordId});
    },
    fireSuppressLoadingIndicatorEvent: function(component, suppress){
        var suppressLoadingIndicator = component.getEvent("suppressLoadingIndicatorEvent");
        suppressLoadingIndicator.setParams({"suppress":suppress});
        suppressLoadingIndicator.fire();
    },
    getSecurity : function(component, helper, category){
        helper.callServer(component, "c.IsSupervisor", function(response){
            component.set("v.isSupervisor", response);
        }, {"category":category});
    },
    getTimeRecordPeriodStaffMember: function(component, helper, timeRecordPeriodId, userId){
        helper.callServer(component, "c.GetTimeRecordPeriodStaffMemberByPeriodAndUser", function(response){
            var staffMembers = response;
            if(staffMembers.length > 0)
                component.set("v.timeRecordPeriodStaffMember", staffMembers[0]);
            else
                component.set("v.timeRecords", []);
        },{"timeRecordPeriodId":timeRecordPeriodId,"userId":userId});
    },
    getTimeRecords : function(component, helper) {
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        if(timeRecordPeriodStaffMember != null)
        {
            helper.callServer(component, "c.GetTimeRecordWeekRollups", function(response){
                var timeRecords = response;
                var sortField = component.get("v.sortField");
                if(sortField)
                    this.performSort(component, timeRecords, sortField, true);
                else
                    component.set("v.timeRecords",timeRecords);

                this.fireSuppressLoadingIndicatorEvent(component, false);
            }, {"timeRecordPeriodStaffMemberId":timeRecordPeriodStaffMember.Id});
        }
    },
    performSort: function(component, timeRecords, field, keepDirection){
        var currentSortField = component.get("v.sortField");
        var currentDirection = component.get("v.sortDirection");
        var direction = keepDirection ? currentDirection : currentSortField === field ? (currentDirection === 'DESC' ? 'ASC' : 'DESC') : 'DESC';
        var greaterNumber = direction === 'DESC' ? -1 : 1;
        switch(field){
            case 'Hours_Worked_Weekday__c':
                timeRecords.sort(function(a,b) {return (a.Hours_Worked_Weekday__c > b.Hours_Worked_Weekday__c) ? greaterNumber : ((b.Hours_Worked_Weekday__c > a.Hours_Worked_Weekday__c) ? greaterNumber * -1 : 0);});
                break;
            case 'Hours_Worked_Weekend__c':
                timeRecords.sort(function(a,b) {return (a.Hours_Worked_Weekend__c > b.Hours_Worked_Weekend__c) ? greaterNumber : ((b.Hours_Worked_Weekend__c > a.Hours_Worked_Weekend__c) ? greaterNumber * -1 : 0);});
                break;
            default:
                timeRecords.sort(function(a,b) {return (a.Project_Name__c > b.Project_Name__c) ? greaterNumber : ((b.Project_Name__c > a.Project_Name__c) ? greaterNumber * -1 : 0);});
        }
        component.set("v.sortField", field);
        component.set("v.sortDirection", direction);
        component.set("v.timeRecords", timeRecords);
    },
    prepareGetTimeRecords : function(component, helper){
        var timeRecordPeriodStaffMember = component.get("v.timeRecordPeriodStaffMember");
        if(timeRecordPeriodStaffMember){
            component.set("v.timeRecords", null);
            this.getTimeRecords(component, helper);
        }
    },
    setActiveTab : function(component, activeTab, inactiveTab01, inactiveTab02){
        var elemTabHeadingActive = document.getElementById(activeTab);
        var elemTabHeadingInactive01 = document.getElementById(inactiveTab01);
        var elemTabHeadingInactive02 = document.getElementById(inactiveTab02);
        var elemTabActive = document.getElementById(activeTab.replace('-heading',''));
        var elemTabInactive01 = document.getElementById(inactiveTab01.replace('-heading',''));
        var elemTabInactive02 = document.getElementById(inactiveTab02.replace('-heading',''));
        if(!$A.util.hasClass(elemTabHeadingActive,"slds-active"))
            $A.util.addClass(elemTabHeadingActive, "slds-active");
        if($A.util.hasClass(elemTabHeadingInactive01,"slds-active"))
            $A.util.removeClass(elemTabHeadingInactive01, "slds-active");
        if($A.util.hasClass(elemTabHeadingInactive02,"slds-active"))
            $A.util.removeClass(elemTabHeadingInactive02, "slds-active");
        if(!$A.util.hasClass(elemTabActive,"slds-show")){
            $A.util.addClass(elemTabActive, "slds-show");
            if($A.util.hasClass(elemTabActive,"slds-hide"))
                $A.util.removeClass(elemTabActive, "slds-hide");
        }
        if($A.util.hasClass(elemTabInactive01,"slds-show")){
            $A.util.removeClass(elemTabInactive01, "slds-show");
            if(!$A.util.hasClass(elemTabInactive01,"slds-hide"))
                $A.util.addClass(elemTabInactive01, "slds-hide");
        }
        if($A.util.hasClass(elemTabInactive02,"slds-show")){
            $A.util.removeClass(elemTabInactive02, "slds-show");
            if(!$A.util.hasClass(elemTabInactive02,"slds-hide"))
                $A.util.addClass(elemTabInactive02, "slds-hide");
        }
    },
    sortRecords: function(component, field){
        var timeRecords = component.get("v.timeRecords");
        this.performSort(component, timeRecords, field, false);
    },
    updateValue: function(component, helper, method, id, value){
        //Suppress Loading Indicator
        this.fireSuppressLoadingIndicatorEvent(component, true);
        helper.callServer(component, method, function(response){
            this.fireSuppressLoadingIndicatorEvent(component, false);
        }, {"recordId":id,"value":value});
    }
})