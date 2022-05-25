public with sharing class OppConvertEngagement {
    @AuraEnabled
    public static String convertEngagement(String recordId){        
        List<Opportunity__c> oppList = new List<Opportunity__c>([SELECT Id,NBC_Approved__c,Line_of_Business__c,Converted_To_Engagement__c FROM Opportunity__c WHERE Id=:recordId]);
            
        Opportunity__c opp = oppList.get(0);
        if(opp.Line_of_Business__c=='CF' && !opp.NBC_Approved__c){
            throw new AuraHandledException('ERROR: NBC form approval is now required.');
        }
        if(opp.Converted_To_Engagement__c){
            throw new AuraHandledException('ERROR: Opportunity has already been converted to an Engagement!');
        }
        try { 
            return SL_Convert_Engagement.convertEngagement(opp.Id);
            //return convertToEngagement(recordId);            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }    
    }
/*
    private static String convertToEngagement(String oppId){
        Opportunity__c opp = [SELECT Id,
        Resulting_Egmt_Stage__c,
        EU_Initiatives__c,
        Fairness_Opinion_Component__c,
        One_Pager_File_Link__c,
        Pitch_Book_File_Link__c,
        Summary_File_Link__c,
        Background_Checks__c,
        Pitch_Date__c,
        TAS_Services__c,
        Authorized_By__c,
        Beneficial_Owner_Control_Person_form__c,
        Verified_by_Compliance_Date__c,
        Received_by_Compliance_Date__c,
        Transaction_Type_FAS__c,
        Other_Transaction_Type_Notes__c,
        Legal_Hold__c,
        Date_off_Hold__c,
        Taken_off_Hold_by__c,
        Known_File_Locations__c,
        Put_on_Hold_by__c,
        Date_on_Hold__c,
        Legal_Hold_Notes__c,
        //Subject_Company_OwnershipNew__C,
        //Client_OwnershipNew__C,
        Client_Ownership__c,
        Subject_Company_Ownership__c,
        ERP_Legislation_Code__c,
        ERP_Template__c,
        ERP_Legal_Entity_Id__c,
        Opportunity_Number_Suffix__c,
        ERP_Entity_Code__c,
        ERP_Business_Unit_Id__c,
        ERP_Business_Unit__c,
        Legal_Entity__c,
        ERP_ID__c,
        Opportunity_Number__c,
        Parent_Sponsor_Company__c,
        Discretionary_Fee__c,
        Client_Description__c,
        LegalAdvisorCompany__c,
        CompanyEUSecurities__c,
        LegalAdvisorCreditor__c,
        Total_Debt_HL_represents_MM__c,
        Success_Probability__c,
        Special_Project__c,
        Total_Anticipated_Revenue__c,
        Women_Led__c,
        Co_exist__c,
        Name,
        Client__c,
        Subject__c,
        Line_of_Business__c,
        Industry_Group__c,
        Sector__c,
        Retainer__c,
        Percentage_Retainer_Creditable__c,
        Fee_Notes_Description__c,
        Expense_Cap__c,
        Legal_Cap__c,
        Job_Type__c,
        Opportunity_Description__c,
        Primary_Office__c,
        HL_Entity__c,
        Estimated_Transaction_Size_MM__c,
        Estimated_Capital_Raised_MM__c,
        EBITDA_MM__c,
        Revenue_MM__c,
        Resulting_Egmt_Record_Type__c,
        Referral_Contact__c,
        Referral_Type__c,
        Confidentiality_Agreement__c,
        CA_Received_by_Legal__c,
        CA_Comments__c,
        Date_CA_Signed__c,
        Date_CA_Expires__c,
        Conflicts_Check__c,
        Conflicts_Check_Current_Processor__c,
        Conflicts_Check_Requestor__c,
        Conflicts_Check_Outcome_Processor__c,
        Conflicts_Check_Type__c,
        Conflicts_Check_Current_Status__c,
        Conflicts_Check_Request_Date__c,
        Conflicts_Check_Perform_Date__c,
        Conflicts_Check_Admin__c,
        Contingent_Fee__c,
        Fee__c,
        Estimated_Close_Date__c,
        Submitter__c,
        Third_Party_Fee__c,
        Percentage_Progress_Fee_Creditable__c,
        MNPI__c,
        ProgressMonthly_Fee__c,
        HL_Percent_of_Transaction__c,
        Total_Debt_Currency__c,
        One_Pager_Date__c,
        Total_Debt_MM__c,
        Conflicts_Check_Outcome__c,
        Conflicts_Check_Outcome_Date__c,
        One_Pager_Office__c,
        Date_Engaged__c,
        External_Disclosure_Status__c,
        DND_Status__c,
        SIC_Code__c,
        Tail_Expires__c,
        Available_In_Expense_Application__c,
        Valuation_Frequency__c,
        Valuation_Date__c,
        CurrencyIsoCode FROM Opportunity__c WHERE Id=:oppId];
        
        Engagement__c eng;
        
            eng = new Engagement__c();
            eng.Stage__c=opp.Resulting_Egmt_Stage__c;
            eng.EU_Initiatives__c=opp.EU_Initiatives__c;
            eng.Fairness_Opinion_Component__c=opp.Fairness_Opinion_Component__c;
            eng.One_Pager_File_Link__c=opp.One_Pager_File_Link__c;
            eng.Pitch_Book_File_Link__c=opp.Pitch_Book_File_Link__c;
            eng.Summary_File_Link__c=opp.Summary_File_Link__c;
            eng.Background_Checks__c=opp.Background_Checks__c;
            eng.Pitch_Book_Date__c=opp.Pitch_Date__c;
            eng.TAS_Services__c=opp.TAS_Services__c;
            eng.Authorized_By__c=opp.Authorized_By__c;
            eng.Beneficial_Owner_Control_Person_form__c=opp.Beneficial_Owner_Control_Person_form__c;
            eng.Verified_by_Compliance_Date__c=opp.Verified_by_Compliance_Date__c;
            eng.Received_by_Compliance_Date__c=opp.Received_by_Compliance_Date__c;
            eng.Transaction_Type_FAS__c=opp.Transaction_Type_FAS__c;
            eng.Other_Transaction_Type_Notes__c=opp.Other_Transaction_Type_Notes__c;
            eng.Legal_Hold__c=opp.Legal_Hold__c;
            eng.Date_off_Hold__c=opp.Date_off_Hold__c;
            eng.Taken_off_Hold_by__c=opp.Taken_off_Hold_by__c;
            eng.Known_File_Locations__c=opp.Known_File_Locations__c;
            eng.Put_on_Hold_by__c=opp.Put_on_Hold_by__c;
            eng.Date_on_Hold__c=opp.Date_on_Hold__c;
            eng.Legal_Hold_Notes__c=opp.Legal_Hold_Notes__c;
            //eng.Subject_Company_OwnershipNew__C=opp.Subject_Company_OwnershipNew__C;
            //eng.Client_OwnershipNew__C=opp.Client_OwnershipNew__C;
            eng.Client_Ownership__c=opp.Client_Ownership__c;
            eng.Subject_Company_Ownership__c=opp.Subject_Company_Ownership__c;
            eng.ERP_Legislation_Code__c=opp.ERP_Legislation_Code__c;
            eng.ERP_Template__c=opp.ERP_Template__c;
            eng.ERP_Legal_Entity_Id__c=opp.ERP_Legal_Entity_Id__c;
            eng.Engagement_Number_Suffix__c=opp.Opportunity_Number_Suffix__c;
            eng.ERP_Entity_Code__c=opp.ERP_Entity_Code__c;
            eng.ERP_Business_Unit_Id__c=opp.ERP_Business_Unit_Id__c;
            eng.ERP_Business_Unit__c=opp.ERP_Business_Unit__c;
            eng.Legal_Entity__c=opp.Legal_Entity__c;
            //eng.ERP_ID__c=opp.ERP_ID__c;
            eng.Engagement_Number__c=opp.Opportunity_Number__c;
            eng.Parent_Sponsor_Company__c=opp.Parent_Sponsor_Company__c;
            eng.Discretionary_Fee__c=opp.Discretionary_Fee__c;
            eng.FR_Client__c=opp.Client_Description__c;
            eng.LegalAdvisorCompany__c=opp.LegalAdvisorCompany__c;
            eng.CompanyEUSecurities__c=opp.CompanyEUSecurities__c;
            eng.LegalAdvisorCreditor__c=opp.LegalAdvisorCreditor__c;
            eng.Total_Debt_HL_represents_MM__c=opp.Total_Debt_HL_represents_MM__c;
            eng.Success_Probability__c=opp.Success_Probability__c;
            eng.Special_Project__c=opp.Special_Project__c;
            eng.Total_Anticipated_Revenue__c=opp.Total_Anticipated_Revenue__c;
            eng.Women_Led__c=opp.Women_Led__c;
            eng.Co_exist__c=opp.Co_exist__c;
            eng.Name=opp.Name;
            eng.Client__c=opp.Client__c;
            eng.Subject__c=opp.Subject__c;
            eng.Line_of_Business__c=opp.Line_of_Business__c;
            eng.Industry_Group__c=opp.Industry_Group__c;
            eng.Sector__c=opp.Sector__c;
            eng.Retainer__c=opp.Retainer__c;
            eng.Percentage_Retainer_Creditable__c=opp.Percentage_Retainer_Creditable__c;
            eng.Fee_Notes_Description__c=opp.Fee_Notes_Description__c;
            eng.Expense_Cap__c=opp.Expense_Cap__c;
            eng.Legal_Cap__c=opp.Legal_Cap__c;
            eng.Job_Type__c=opp.Job_Type__c;
            eng.Transaction_Description__c=opp.Opportunity_Description__c;
            eng.Primary_Office__c=opp.Primary_Office__c;
            eng.HL_Entity__c=opp.HL_Entity__c;
            eng.Est_Transaction_Size_MM__c=opp.Estimated_Transaction_Size_MM__c;
            eng.Capital_Raised__c=opp.Estimated_Capital_Raised_MM__c;
            eng.EBITDA_MM__c=opp.EBITDA_MM__c;
            eng.Target_Revenue_MM__c=opp.Revenue_MM__c;
            //eng.RecordType.DeveloperName=opp.Resulting_Egmt_Record_Type__c;
            eng.Referral_Contact__c=opp.Referral_Contact__c;
            eng.Referral_Type__c=opp.Referral_Type__c;
            eng.Confidentiality_Agreement__c=opp.Confidentiality_Agreement__c;
            eng.CA_Received_by_Legal__c=opp.CA_Received_by_Legal__c;
            eng.CA_Comments__c=opp.CA_Comments__c;
            eng.Date_CA_Signed__c=opp.Date_CA_Signed__c;
            eng.Date_CA_Expires__c=opp.Date_CA_Expires__c;
            eng.Conflicts_Check__c=opp.Conflicts_Check__c;
            eng.Conflicts_Check_Current_Processor__c=opp.Conflicts_Check_Current_Processor__c;
            eng.Conflicts_Check_Requestor__c=opp.Conflicts_Check_Requestor__c;
            eng.Conflicts_Check_Outcome_Processor__c=opp.Conflicts_Check_Outcome_Processor__c;
            eng.Conflicts_Check_Type__c=opp.Conflicts_Check_Type__c;
            eng.Conflicts_Check_Current_Status__c=opp.Conflicts_Check_Current_Status__c;
            eng.Conflicts_Check_Request_Date__c=opp.Conflicts_Check_Request_Date__c;
            eng.Conflicts_Check_Perform_Date__c=opp.Conflicts_Check_Perform_Date__c;
            eng.Conflicts_Check_Admin__c=opp.Conflicts_Check_Admin__c;
            eng.Contingent_Fee__c=opp.Contingent_Fee__c;
            eng.Total_Estimated_Fee__c=opp.Fee__c;
            eng.Estimated_Close_Date__c=opp.Estimated_Close_Date__c;
            eng.Submitter__c=opp.Submitter__c;
            //eng.Third_Party_Fee__c=opp.Third_Party_Fee__c;
            eng.Percentage_Progress_Fee_Creditable__c=opp.Percentage_Progress_Fee_Creditable__c;
            eng.MNPI__c=opp.MNPI__c;
            eng.ProgressMonthly_Fee__c=opp.ProgressMonthly_Fee__c;
            eng.HL_Percent_of_Transaction__c=opp.HL_Percent_of_Transaction__c;
            eng.Total_Debt_Currency__c=opp.Total_Debt_Currency__c;
            eng.One_Pager_Date__c=opp.One_Pager_Date__c;
            eng.Total_Debt_MM__c=opp.Total_Debt_MM__c;
            eng.Conflicts_Check_Outcome__c=opp.Conflicts_Check_Outcome__c;
            eng.Conflicts_Check_Outcome_Date__c=opp.Conflicts_Check_Outcome_Date__c;
            eng.One_Pager_Office__c=opp.One_Pager_Office__c;
            eng.Date_Engaged__c=opp.Date_Engaged__c;
            eng.External_Disclosure_Status__c=opp.External_Disclosure_Status__c;
            eng.DND_Status__c=opp.DND_Status__c;
            eng.SIC_Code__c=opp.SIC_Code__c;
            eng.Tail_Expires__c=opp.Tail_Expires__c;
            eng.Available_In_Expense_Application__c=opp.Available_In_Expense_Application__c;
            eng.Valuation_Frequency__c=opp.Valuation_Frequency__c;
            eng.Valuation_Date__c=opp.Valuation_Date__c;
            eng.CurrencyIsoCode=opp.CurrencyIsoCode;
            insert eng;

            opp.Converted_To_Engagement__c=true;            
            opp.Stage__c='Engaged';
            update opp;

            SL_Convert_EngagementQueueableClass queueableClass = new SL_Convert_EngagementQueueableClass(oppId);
            System.enqueueJob(queueableClass);  

            Set<Id> engagementSet = new Set<Id>{eng.Id};            
            HL_EngagementVatTreatmentHandler.updateTaxClassificationOnContracts(engagementSet);

            List<Engagement_Client_Subject__c> ecsList = new List<Engagement_Client_Subject__c>();
            Map<String,Schema.RecordTypeInfo> rtInfoMap = Schema.SobjectType.Engagement_Client_Subject__c.getRecordTypeInfosByDeveloperName();
            String rtId;
            for(Opportunity_Client_Subject__c ocs : [SELECT Id,LineofBusiness__c,
                                                    Notes__c,ClientHoldings__c,   DebtHoldingsMM__c,
                                                    Role__c,KeyCreditorCreated__c,ClientHoldingsMM__c,
                                                    KeyCreditorImportance__c,KeyCreditorWeighting__c,Legacy_SLX_Id__c,
                                                    Other_Related_Object_Id__c,Original_Name__c,RevenueAllocation__c,
                                                    Type__c,Primary__c,RecordType.DeveloperName,Client_Subject__c
                                                    FROM Opportunity_Client_Subject__c WHERE Opportunity__c=:opp.Id]){
                if(ocs.LineOfBusiness__c=='FR'){
                    rtId = rtInfoMap.get(ocs.RecordType.DeveloperName).getRecordTypeId();
                }
                else {
                    if(ocs.Type__c=='Client'){
                        rtId=rtInfoMap.get('Additional_Client').getRecordTypeId();
                    }else if(ocs.Type__c=='Subject'){
                        rtId=rtInfoMap.get('Additional_Subject').getRecordTypeId();
                    }else{
                        rtId=rtInfoMap.get('Additional_Other').getRecordTypeId();
                    }
                }
                ecsList.add(new Engagement_Client_Subject__c(Engagement__c=eng.Id,Type__c=ocs.Type__c,Client_Subject__c=ocs.Client_Subject__c,RecordTypeId=rtId,            
                                                    Notes__c=ocs.Notes__c,ClientHoldings__c=ocs.ClientHoldings__c,DebtHoldingsMM__c=ocs.DebtHoldingsMM__c,
                                                    Role__c=ocs.Role__c,KeyCreditorCreated__c=ocs.KeyCreditorCreated__c,ClientHoldingsMM__c=ocs.ClientHoldingsMM__c,
                                                    KeyCreditorImportance__c=ocs.KeyCreditorImportance__c,KeyCreditorWeighting__c=ocs.KeyCreditorWeighting__c,Legacy_SLX_Id__c=ocs.Legacy_SLX_Id__c,
                                                    Other_Related_Object_Id__c=ocs.Other_Related_Object_Id__c,Original_Name__c=ocs.Original_Name__c,CreditorRevenueAllocationPercentage__c=ocs.RevenueAllocation__c,
                                                    Primary__c=ocs.Primary__c));
            }
            insert ecsList;
            eng.co_exist__c = opp.co_exist__c;
            update eng;
        
        return eng.Id;
    }*/
}