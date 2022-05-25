public with sharing class HL_EngagementTitleRateSheetHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;

    public HL_EngagementTitleRateSheetHandler(boolean isExecuting, integer size) {
        isExecuting = isExecuting;
    batchSize = size;
    }

    public void onBeforeUpdate(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        ValidateRateSheets(rateSheetList);
    }

    public void onBeforeInsert(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        ValidateRateSheets(rateSheetList);
    }

    public void onAfterUpdate(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        UpdateTimeTrackingRateSheetRecords(rateSheetList);
    }

    public void onAfterInsert(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        UpdateTimeTrackingRateSheetRecords(rateSheetList);
    }

    //Prevent Rate Sheet Overlaps
    private List<Engagement_Title_Rate_Sheet__c> ValidateRateSheets(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        //Get the Engagement ID Set to Query Against for Existing Rate Sheets
        Set<Id> engagementIdSet = GetEngagementIdSet(rateSheetList);
        //Get Existing Rate Sheet Map
        Map<Id, List<Engagement_Title_Rate_Sheet__c>> existingRateSheetMap = GetEngagementRateSheetMap(engagementIdSet);

        //Validate The Rate Sheets to be sure no dates overlap
        for(Engagement_Title_Rate_Sheet__c etrs : rateSheetList)
        {
            List<Engagement_Title_Rate_Sheet__c> existingRateSheets = existingRateSheetMap.get(etrs.Engagement__c);
            if(existingRateSheets != null && existingRateSheets.size() > 0){
                for(Engagement_Title_Rate_Sheet__c existingRS : existingRateSheets)
                {
                    if((String.isBlank(etrs.Id) || etrs.Id != existingRS.Id) &&
                        (
                            (etrs.Start_Date__c >= existingRS.Start_Date__c && (etrs.Start_Date__c <= existingRS.End_Date__c || existingRS.End_Date__c == null)) ||
                            (existingRS.Start_Date__c >= etrs.Start_Date__c && (existingRS.Start_Date__c <= etrs.End_Date__c || etrs.End_Date__c == null))
                        ))
                        etrs.Start_Date__c.addError('Invalid Dates - Cannot Overlap with Existing Record.');
                }
            }
        }

        return rateSheetList;

    }

    private List<Time_Record__c> UpdateTimeTrackingRateSheetRecords(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        List<Time_Record__c> timeRecordUpdateList = new List<Time_Record__c>();

        //Get the Engagement ID Set to Pull the Time Records for
        Set<Id> engagementIdSet = GetEngagementIdSet(rateSheetList);

        //Get the Existing Rate Sheet Maps
        Map<Id, List<Engagement_Title_Rate_Sheet__c>> existingRateSheetMap = GetEngagementRateSheetMap(engagementIdSet);

        //Record Type Id
        Id timeRecordLitigationRT = Schema.SObjectType.Time_Record__c.getRecordTypeInfosByName().get('Litigation').getRecordTypeId();

        //Retrieve the Time Records
        for(Time_Record__c tr : HL_TimeRecord.GetByEngagementsOpportunities(timeRecordLitigationRT, engagementIdSet)){
            if (tr.Engagement__c != null && !String.isBlank(tr.Engagement__c)) {
                List<Engagement_Title_Rate_Sheet__c> existingRateSheetList = existingRateSheetMap.get(tr.Engagement__c);
                if(existingRateSheetList.size() > 0){
                    for(Engagement_Title_Rate_Sheet__c etrs : existingRateSheetList){
                        if(tr.Activity_Date__c >= etrs.Start_Date__c && (etrs.End_Date__c == null || tr.Activity_Date__c <= etrs.End_Date__c)){
                            Decimal newHourlyRate = HL_TitleRateSheet.ExtractTitleRate(etrs.Title_Rate_Sheet__r, tr.Time_Record_Period_Staff_Member__r.Title__c);
                            //If the Hourly Rate is now different, add to list to Update
                            if(newHourlyRate != tr.Hourly_Rate__c)
                            {
                                tr.Hourly_Rate__c = newHourlyRate;
                                //Keep Opportunity Records Engagement Id Blank
                                if (tr.Opportunity__c != null && !String.isBlank(tr.Opportunity__c)) {
                                    tr.Engagement__c = null;
                                }
                                timeRecordUpdateList.add(tr);
                            }
                        }
                    }
                }
            }
        }

        if(timeRecordUpdateList.size() > 0)
            update timeRecordUpdateList;

        return timeRecordUpdateList;
    }

  //Populates an EngagementID Set from a List of Engagement Title Rate Sheets
    private Set<Id> GetEngagementIdSet(List<Engagement_Title_Rate_Sheet__c> rateSheetList){
        Set<Id> engagementIdSet = new Set<Id>();

        for(Engagement_Title_Rate_Sheet__c etrs : rateSheetList){
            if(!String.isBlank(etrs.Engagement__c) && !engagementIdSet.contains(etrs.Engagement__c))
                engagementIdSet.add(etrs.Engagement__c);
        }

        return engagementIdSet;
    }

  //Retrieves a Map of Engagement Title Rate Sheets by Engagement ID
    private Map<Id, List<Engagement_Title_Rate_Sheet__c>> GetEngagementRateSheetMap(Set<Id> engagementIdSet){
        Map<Id, List<Engagement_Title_Rate_Sheet__c>> existingRateSheetMap = new Map<Id, List<Engagement_Title_Rate_Sheet__c>>();

        //Put the Existing Rate Sheets in a Map by Engagement ID
        for(Engagement_Title_Rate_Sheet__c etrs : [SELECT Engagement__c,
                                                   Start_Date__c,
                                                   End_Date__c,
                                                   Title_Rate_Sheet__r.Senior_Managing_Director_Rate__c,
                                                   Title_Rate_Sheet__r.Managing_Director_Rate__c,
                                                   Title_Rate_Sheet__r.Director_Rate__c,
                                                   Title_Rate_Sheet__r.Senior_Vice_President_Rate__c,
                                                   Title_Rate_Sheet__r.Vice_President_Rate__c,
                                                   Title_Rate_Sheet__r.Associate_Rate__c,
                                                   Title_Rate_Sheet__r.Financial_Analyst_Rate__c,
                                                   Title_Rate_Sheet__r.Manager_Rate__C,
                                                   Title_Rate_Sheet__r.Executive_Administrator_Rate__c,
                                                   Title_Rate_Sheet__r.SrResearchLibrarianRate__c,
                                                   Title_Rate_Sheet__r.PresentationsGraphicsRate__c,
                                                   Title_Rate_Sheet__r.Outsourced_Contractor_Rate__c,
                                                   Title_Rate_Sheet__r.Para_Professional_Rate__c,
                                                   Title_Rate_Sheet__r.SpecialProjectsCoordinator__c
                                                   FROM Engagement_Title_Rate_Sheet__c
                                                   WHERE Engagement__c IN: engagementIdSet])
        {
                List<Engagement_Title_Rate_Sheet__c> existingRateSheetList = existingRateSheetMap.get(etrs.Engagement__c);

                if(existingRateSheetList == null)
                    existingRateSheetMap.put(etrs.Engagement__c, new List<Engagement_Title_Rate_Sheet__c> {etrs});
                else
                {
                    existingRateSheetList.add(etrs);
                    existingRateSheetMap.put(etrs.Engagement__c, existingRateSheetList);
                }
        }

        return existingRateSheetMap;
    }

}