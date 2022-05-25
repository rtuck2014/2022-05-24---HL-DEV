public with sharing class HL_CF_EngagementSummaryController {

    private Engagement__c Engagement {get{
            if(engagement == null)
                engagement = HL_Engagement.GetById(EngagementId);
            return engagement;
        } set;}
    public Id EngagementId {get; set;}
    public String DelId {get; set;}
    public String EngagementName {get; set;}
    public Boolean DisplayConfirmation {get; set;}
    public String ApprovalStatus {get{
        if(ApprovalStatus == null)
          ApprovalStatus = GetApprovalStatus();

        return ApprovalStatus;
      }set;}
    public String WarningMessage {get{
      return GetWarningMessage();
      } set;}
    private ApexPages.StandardController sc;
    //List of Engagement External Team (Management Contact Role)
    public List<Engagement_External_Team__c> ExternalTeam {get{
        if(externalTeam == null)
            externalTeam = [SELECT Name, Contact__r.AccountId, Role__c, Contact__c, Contact__r.Name, Equity_From_Transaction__c,
                                   Post_Transaction_Bonus__c, Post_Transaction_Employment_Agreement__c, Post_Transaction_New_Equity_Ownership__c,
                                   Post_Transaction_Options_Percent__c, Post_Transaction_Options_Vested_On__c, Post_Transaction_Rollover_Required__c,
                                   Post_Transaction_Salary__c, Post_Transaction_Title__c, Post_Transaction_Total_Comp__c,
                                   Pre_Transaction_Bonus__c, Pre_Transaction_Employment_Length__c, Pre_Transaction_Equity_Ownership__c,
                                   Pre_Transaction_Salary__c, Pre_Transaction_Title__c, Pre_Transaction_Total_Comp__c, Total_Proceeds_At_Close__c,
                                   Transaction_Incentives_At_Close__c
                                   FROM Engagement_External_Team__c
                                   WHERE Engagement__c =: EngagementId
                                         AND (
                                                Role__c = 'Management Contact'
                                                 OR (Engagement__r.RecordType.DeveloperName = 'Buyside' AND Contact__r.Account.Id =: Engagement.Subject__c)
                                                 OR (Engagement__r.RecordType.DeveloperName <> 'Buyside' AND Contact__r.Account.Id =: Engagement.Client__c)
                                              )
                                   ORDER BY Contact__r.Name];
        return externalTeam;
    } set;}
    public List<Engagement_External_Team__c> SellerContacts{
        get{
            if(sellerContacts == null){

                sellerContacts = [SELECT Name, Contact__r.AccountId, Role__c, Contact__c, Contact__r.Name
                                  FROM Engagement_External_Team__c
                                  WHERE Engagement__c =: EngagementId
                                        AND (
                                              Role__c = 'Management Contact'
                                              OR (Engagement__r.RecordType.DeveloperName = 'Buyside' AND Contact__r.Account.Id =: Engagement.Subject__c)
                                              OR (Engagement__r.RecordType.DeveloperName <> 'Buyside' AND Contact__r.Account.Id =: Engagement.Client__c)
                                            )
                                 ORDER BY Contact__r.Name];
            }

            return sellerContacts;
        }
        set;}
    private List<Engagement_External_Team__c> SellsideLegalCounsel{
        get {
            if(sellsideLegalCounsel == null)
                sellsideLegalCounsel = [SELECT Role__c
                                        FROM Engagement_External_Team__c WHERE Engagement__c =: EngagementId
                                        AND (Role__c = 'Legal Counsel' OR Role__c = 'Attorney (Acquirer)' OR Role__c = 'Attorney (Target)')];
            return sellsideLegalCounsel;
        }
        set;
    }

    private String GetApprovalStatus(){
        Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();

        ProcessInstance[] pi = [SELECT Status
                                FROM ProcessInstance
                                WHERE TargetObjectID =: es.Id
                                ORDER BY CreatedDate DESC];

        return pi.size() > 0 ? pi[0].Status : '';
    }

    public List<Engagement_Counterparty__c> WinningCounterparties{
        get{
            if(winningCounterparties == null)
            {
                winningCounterparties = [SELECT Id, Company__c, Company__r.Name, Platform_Type__c, Process_Type__c FROM Engagement_Counterparty__c WHERE Engagement__c =: EngagementId AND Closing_Round_Bid_Date__c <> null];
                if(winningCounterparties.size() > 0)
                    ActiveWinningCounterpartyId = winningCounterparties[0].Id;
            }
            return winningCounterparties;
        }
        set;
    }
    public Id ActiveWinningCounterpartyId {get; set;}
    public List<Engagement_Counterparty_Contact__c> CounterpartyContacts{get{
        if(counterpartyContacts == null)
            counterpartyContacts = [SELECT Id, Contact__c, Contact__r.Name, Type__c FROM Engagement_Counterparty_Contact__c WHERE Counterparty__c =: ActiveWinningCounterpartyId];
        return counterpartyContacts;
    } set;}
    public List<Debt_Structure__c> DebtStructures{get{
        if(debtStructures == null)
            debtStructures = [SELECT Id, Amoritization__c, Call_Provisions_Prepayment_Premiums__c, Constituent_Debt__c, Covenants__c, Engagement__c, Facility_Balance_MM__c, Fees_Expenses__c, Interest__c, Mandatory_Prepayments_ECF_Sweep__c, Maturity_Date__c, OID_Percent__c, Pre_Post_Transaction__c, Security_Type__c FROM Debt_Structure__c WHERE Engagement__c =: EngagementId];

        return debtStructures;
    }set;}
    public List<CapitalizationRecord> CapitalizationRecords{
        get{
            if(capitalizationRecords == null)
            {
                capitalizationRecords = new List<CapitalizationRecord>();
                for(Debt_Structure__c ds : DebtStructures)
                    capitalizationRecords.Add(New CapitalizationRecord(ds));
            }
            return capitalizationRecords;
        }
        set;
    }
    public Debt_Structure__c NewDebtStructure{get{
        if(newDebtStructure == null)
            newDebtStructure = New Debt_Structure__c(Engagement__c = EngagementId);
        return newDebtStructure;
    } set;}

    //The CAO/CF Users would like to be able to make edits after approval
    public Boolean ApprovedEditAccess {
        get{
            if (approvedEditAccess == null)
                approvedEditAccess = HL_Group.IsInGroup('CAO_CF') || HL_SecurityUtility.IsSysAdmin();

            return approvedEditAccess;
        }
        set;
    }

    public HL_CF_EngagementSummaryController(ApexPages.StandardController controller){
        Engagement_Summary__c es = (Engagement_Summary__c)controller.getRecord();
        EngagementId = es.Engagement__c;
        EngagementName = es.Engagement__r.Name;
        DisplayConfirmation = false;
        this.sc = controller;

        if(!String.isBlank(es.Summary_Status__c) && es.Summary_Status__c <> 'In Process')
          CheckForApprovalWarningPrompt(es);
    }

    // We want the approver to get the same warning list before approving
    private void CheckForApprovalWarningPrompt(Engagement_Summary__c es){
        Set<Id> approverList = new Set<Id> {es.Approver_01__c
                                            , es.Approver_02__c
                                            , es.Approver_03__c
                                            , es.Approver_04__c
                                            , es.Approver_05__c
                                            , es.Approver_06__c
                                            , es.Approver_07__c
                                            , es.Approver_08__c };

        if(approverList.contains(UserInfo.getUserId()))
            DisplayConfirmation = GetApprovalStatus() == 'Pending';
    }

    public void SaveNewDebtStructure(){
        insert NewDebtStructure;
        CapitalizationRecords = null;
        DebtStructures = null;
    }

    public void SaveAll(){
        try{
            if(Save())
                HL_PageUtility.ShowConfirm('Saved At: ' + System.now().format('HH:mm:ss a'));
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
    }

    public PageReference SaveAndReturn(){
        Save();
        return new PageReference('/' + EngagementId);
    }


    private void ValidateSellsideLegalCounsel(){
        Boolean hasTarget = false, hasAcquirer = false;
        for(Engagement_External_Team__c eet : SellsideLegalCounsel){
            if(eet.Role__c == 'Attorney (Target)')
                hasTarget = true;
            else
                hasAcquirer = true;
        }

        if(!hasTarget)
            AddError('Required: Add the Attorney (Target) under Engagement Contacts back on the Engagement View/Page. Specify Role as Attorney (Target).');
        if(!hasAcquirer)
            AddError('Required: Add Attorney (Acquirer)/Legal Counsel under Engagement Contacts back on the Engagement View/Page.  Specify Role as Attorney (Acquirer) or Legal Counsel.');
    }

     //Validate that at least one other contact, other than attorney/legal, has been added
    private void ValidateAdditionalContacts(){
        Boolean hasContactTarget = false, hasContactAcquirer = false;
        Set<String> legalRoleSet = new Set<String>{'Attorney (Target)','Attorney (Acquirer)','Legal Counsel'};
        Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();
        Boolean isBuyside = es.Engagement__r.RecordType.DeveloperName == 'Buyside';
        Boolean isValid = false;
        for(Engagement_External_Team__c eet : ExternalTeam){
            if(!legalRoleSet.contains(eet.Role__c))
            {
              if((isBuyside && eet.Contact__r.AccountId == Engagement.Subject__c)
                  || (!isBuyside && eet.Contact__r.AccountId == Engagement.Client__c)){
                isValid = true;
                break;
              }
            }
        }

       if(!isValid)
            AddError('Engagement - Add Additional Contact(s) under Engagement Contacts back on the Engagement View/Page. (At Least One other Contact other than Legal/Attorney is Required from the ' + (isBuyside ? 'Subject' : 'Client') + ' Company)');
    }

    private string GetWarningMessage(){
      Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();
      String warningMessage = '';

      //Seller Details
      if(es.Engagement__r.RecordType.DeveloperName == 'Buyside'){
         warningMessage = BlankValueFieldSetWarningCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Warning_Buyside_Seller_Detail_Fields.getFields(), 'Seller Details', warningMessage);
         warningMessage = warningMessage.replace('Pitch ','');

       }
      else
         warningMessage = BlankValueFieldSetWarningCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Warning_Seller_Detail_Fields.getFields(), 'Seller Details', warningMessage);

      //Public Company Process Tab
      if(!String.isBlank(es.Engagement__r.Subject_Company_Ownership__c) && es.Engagement__r.Subject_Company_Ownership__c.contains('Public'))
        warningMessage = BlankValueFieldSetWarningCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Warning_Public_Company_Fields.getFields(), 'Public Company Process', warningMessage);

      //Purchase Price and Structure Tab
      warningMessage = BlankValueFieldSetWarningCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Warning_Purchase_Price_Fields.getFields(), 'Purchase Price & Structure', warningMessage);

      if(es.Consideration_Seller_Notes__c != null && es.Consideration_Seller_Notes__c > 0){
          if(es.Seller_Notes_Term__c == null)
              warningMessage += AddWarning('Purchase Price & Structure - Seller Notes Term');
          if(es.Seller_Notes_Interest_Percent__c == null)
              warningMessage += AddWarning('Purchase Price & Structure - Seller Notes Interest');
          if(String.isBlank(es.Has_Seller_Note_Conversion_Rights__c))
             warningMessage += AddWarning('Purchase Price & Structure - Seller Notes Conversion Right');
      }

      //Key Contract Terms Tab
      if(es.Representations_and_Warranties_Insurance__c == 'Yes'){
          //if(es.Reps_and_Warranties_Insurance_Amount__c == null)
            //warningMessage += AddWarning('Key Contract Terms - R&W Insurance Policy Coverage Amount');
          if(es.Reps_and_Warranties_Insurance_Limit__c == null)
            warningMessage += AddWarning('Key Contract Terms - R&W Insurance Limit of the Insurance Coverage Purchased');
          if(es.Reps_and_Warranties_Insurance_Cost__c == null)
            warningMessage += AddWarning('Key Contract Terms - R&W Insurance Cost of the Insurance Policy');
          if(es.Reps_and_Warranties_Insurance_Retention__c == null)
            warningMessage += AddWarning('Key Contract Terms - R&W Insurance Retention Amount');
      }

      if(es.Indemnity_Basket_Type__c != 'N/A' && es.Indemnity_Basket_Type__c != 'No Basket') {

        if(es.Indemnity_Basket_Size__c == null)
        warningMessage += AddWarning('Key Contract Terms - Basket Size');
      }
      if(es.Indemnity_Caps_Type__c != 'N/A' && es.Indemnity_Caps_Size__c == null)
          warningMessage += AddWarning('Key Contract Terms - Caps Size');
      if((es.Indemnity_Escrow_Type__c != 'N/A' && es.Indemnity_Escrow_Type__c != 'None') && es.Indemnity_Escrow_Size__c == null)
          warningMessage += AddWarning('Key Contract Terms - Escrow/Holdbacks Size');
      if(es.Carveout_Environmental_Type__c != 'N/A' && es.Carveout_Environmental_CapSize__c == null)
          warningMessage += AddWarning('Key Contract Terms - Cap Carveout Environmental Cap Size');
      if(es.Carveout_Environmental_Type__c != 'N/A' && es.Carveout_Environmental_Type__c != 'No Basket' && es.Carveout_Environmental_BasketSize__c == null)
          warningMessage += AddWarning('Key Contract Terms - Cap Carveout Environmental Basket Size');
      if(es.Carveout_Environmental_Type__c != 'N/A' && es.Carveout_Environmental_SurvivalPeriod__c == null)
          warningMessage += AddWarning('Key Contract Terms - Cap Carveout Environmental Survival Period');
      if(String.isBlank(es.Key_Contract_Comments__c))
          warningMessage += AddWarning('Key Contract Terms - Key Contract Comments');

      //Employee Terms
      if(!String.isBlank(es.Seller_Had_Incentive_Plan__c) && es.Seller_Had_Incentive_Plan__c == 'Yes'){
          if(es.Employees_In_Incentive_Plan__c == null)
                  warningMessage += AddWarning('Employee Terms - Number of Employees Part of KERP Plan');
      }

      if(!String.isBlank(es.Implemented_New_Option_Pool_Equity_Plan__c) && es.Implemented_New_Option_Pool_Equity_Plan__c == 'Yes'){
          if(es.Total_Pool_Percent_Of_Equity__c == null)
                  warningMessage += AddWarning('Employee Terms - Total Pool/Plan as a % of Equity');
          if(String.isBlank(es.Is_Preferred_Equity__c))
                 warningMessage += AddWarning('Employee Terms - Is the Pool/Plan Preferred or Common Equity?');
          if(es.Employees_In_Option_Plan__c == null)
                  warningMessage += AddWarning('Employee Terms - Number of Employees Part of New Option Plan');
      }

      //Capitalization
      warningMessage = BlankValueFieldSetWarningCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Warning_Capitalization_Fields.getFields(), 'Capitalization', warningMessage);

      //EL/Engagement Dynamics Metrics
      warningMessage = BlankValueFieldSetWarningCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Warning_EL_Dynamics_Fields.getFields(), 'EL/Engagement Dynamics', warningMessage);
      if(es.First_Ratchet_Percent__c == null && es.First_Ratchet_From_Amount__c == null && es.First_Ratchet_To_Amount__c == null)
          warningMessage += AddWarning('EL/Engagement Dynamics - Ratchet Information');

      //Engagement Items
      if(es.Engagement__r.RecordType.DeveloperName == 'Sellside'){
        //For M&A (Sellside Deals), Require that the Attorney/Legal Counsel Fields are Populated on both sides
        Boolean hasTarget = false, hasAcquirer = false;
        for(Engagement_External_Team__c eet : SellsideLegalCounsel){
            if(eet.Role__c == 'Attorney (Target)')
                hasTarget = true;
            else
                hasAcquirer = true;
        }

        if(!hasTarget)
            warningMessage += AddWarning('Engagement - No Attorney (Target) was Specified - Under Engagement Contacts back on the Engagement View/Page. Specify Role as Attorney (Target).');
        if(!hasAcquirer)
            warningMessage += AddWarning('Engagement - No Attorney (Acquirer)/Legal Counsel Was Specified - Under Engagement Contacts back on the Engagement View/Page.  Specify Role as Attorney (Acquirer) or Legal Counsel.');
      }

      return warningMessage;
    }

    //Checks the FieldSet Fields for Blank Value(s)
    private String BlankValueFieldSetWarningCheck(Engagement_Summary__c es, List<FieldSetMember> fsmList, String warningPrefix, String existingWarningMsg){
        for(FieldSetMember fsm : fsmList)
        {
          if(fsm.getType() == Schema.DisplayType.String){
            if(String.isBlank((String)es.get(fsm.getFieldPath())))
                existingWarningMsg += AddWarning(warningPrefix + ' - ' + fsm.getLabel());
          }
          else if(es.get(fsm.getFieldPath()) == null)
            existingWarningMsg += AddWarning(warningPrefix + ' - ' + fsm.getLabel());
        }

        return existingWarningMsg;
    }

    private string AddWarning(string message){
      return message + '\r\n';
    }

    //Validate for Approval
    public void SubmitForApproval(){
        if(Save())
        {
            Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();

            //Validate Additional Contact(s)
            ValidateAdditionalContacts();

            //Seller Details
            BlankValueFieldSetErrorCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Seller_Detail_Fields.getFields(), 'Seller Details');

            //Require Winning Counterparty and Process Type
            if(WinningCounterparties.size() == 0)
                AddError((es.Engagement__r.RecordType.DeveloperName == 'Sellside' ? 'Winning Counterparty Details' : 'Buyer Details') + ' - Winning Counterparty Required (Return to the Engagement and use the Counterparties Button and Add a Closing Bid from the Details of the Respective Counterparty)');
            if(WinningCounterparties.size() > 0){
                for(Engagement_Counterparty__c ec : WinningCounterparties){
                    if(String.isBlank(ec.Process_Type__c) || String.isBlank(ec.Platform_Type__c))
                        AddError((es.Engagement__r.RecordType.DeveloperName == 'Sellside' ? 'Winning Counterparty Details' : 'Buyer Details') + ' - Process and Platform Type Required For All Winning Counterparties');
                }
            }

            //Public Company Process Tab
            if(String.isBlank(es.Engagement__r.Subject_Company_Ownership__c) || es.Engagement__r.Subject_Company_Ownership__c.contains('Public'))
              BlankValueFieldSetErrorCheck(es, SObjectTYpe.Engagement_Summary__c.FieldSets.CF_Required_Public_Company_Fields.getFields(), 'Public Company Process');

            //Purchase Price and Structure Tab
            BlankValueFieldSetErrorCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Purchase_Price_Fields.getFields(), 'Purchase Price & Structure');
            if(es.Was_Earnout_Included__c == 'Yes'){
                if(String.isBlank(es.Earnout_Metric__c))
                  AddError('Purchase Price & Structure - Earnout Metric');
                if(String.isBlank(es.Earnout_Period__c))
                  AddError('Purchase Price & Structure - Earnout Period');
                if(String.isBlank(es.Does_Earnout_Accelerate__c))
                  AddError('Purchase Price & Structure - Does Earnout Accelerate');
                if(String.isBlank(es.Is_Buyer_Able_To_Offset_Earnout__c))
                  AddError('Purchase Price & Structure - Is Buyer Able To Offset Earnout');
            }

            if(es.Consideration_Seller_Notes__c != null && es.Consideration_Seller_Notes__c > 0){
              if(es.Seller_Notes_Term__c == null)
                AddError('Purchase Price & Structure - Seller Notes Term');
              if(es.Seller_Notes_Interest_Percent__c == null)
                AddError('Purchase Price & Structure - Seller Notes Interest');
              if(String.isBlank(es.Has_Seller_Note_Conversion_Rights__c))
                AddError('Purchase Price & Structure - Seller Notes Conversion Right');
            }

            //Key Contract Terms Tab
            BlankValueFieldSetErrorCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Key_Contract_Fields.getFields(), 'Key Contract Terms');

            //Employee Terms
            BlankValueFieldSetErrorCheck(es, SObjectType.Engagement_Summary__c.FieldSets.CF_Required_Employee_Terms_Fields.getFields(), 'Employee Terms');
            if(!String.isBlank(es.Seller_Had_Incentive_Plan__c) && es.Seller_Had_Incentive_Plan__c == 'Yes'){
                if(String.isBlank(es.Incentive_Plan__c))
                  AddError('Employee Terms - Form of Incentive Plan');
            }

            //Require a Credit Facility Record or a No Data Response
            if(!es.No_Credit_Facility_Data__c && CapitalizationRecords.size() == 0)
                AddError('Credit Facility - Response Required');

            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR))
                DisplayConfirmation = true;
        }
    }

    //Checks the FieldSet Fields for Blank Value(s)
    private void BlankValueFieldSetErrorCheck(Engagement_Summary__c es, List<FieldSetMember> fsmList, String errorPrefix){
        for(FieldSetMember fsm : fsmList)
        {
          if(fsm.getType() == Schema.DisplayType.String){
            if(String.isBlank((String)es.get(fsm.getFieldPath())))
                  AddError(errorPrefix + ' - ' + fsm.getLabel());
          }
          else if(es.get(fsm.getFieldPath()) == null)
                  AddError(errorPrefix + ' - ' + fsm.getLabel());
        }
    }

    private void AddError(string error){
        HL_PageUtility.ShowError(error);
    }

    public void StepBack(){
      DisplayConfirmation = false;
    }

    public void PrepareApprovalSubmission(){
        Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();

        Set<Id> approvers = new Set<Id>(); //Store the Unique User Ids

        for(Engagement_Internal_Team__c eit : [SELECT Contact__c, Contact__r.User__c, Staff_Role__r.Name FROM Engagement_Internal_Team__c WHERE Engagement__c =: EngagementId AND (Staff_Role__r.Name =: 'Principal' OR Staff_Role__r.Name =: 'Manager') AND End_Date__c = null AND Contact__r.Status__c = 'Active'])
            approvers.add(eit.Contact__r.User__c);

        if(approvers.size() >= 1)
        {
            for(Id app : approvers)
                AssignApproverField(es,app, false);
            AssignApproverField(es,(new list<id>(approvers))[0],true);
            es.Summary_Status__c = 'In Review';
            update es;
            SubmitApprovalProcess();
            HL_PageUtility.ShowConfirm('Submitted for Review');
            DisplayConfirmation = false;
        }
        else
            HL_PageUtility.ShowError('No Principal or Manager Specified for the Engagement');
    }

    //All approver fields must contain a value to allow the process to kickoff
    private void AssignApproverField(Engagement_Summary__c es, String userId, Boolean allNulls){
        if(String.isBlank(es.Approver_01__c)){
            es.Approver_01__c = userId;
            if(!allNulls)
                return;
        }
        if(String.isBlank(es.Approver_02__c)){
            es.Approver_02__c = userId;
            if(!allNulls)
                return;
        }
        if(String.isBlank(es.Approver_03__c)){
            es.Approver_03__c = userId;
            if(!allNulls)
                return;
        }
        if(String.isBlank(es.Approver_04__c)){
            es.Approver_04__c = userId;
            if(!allNulls)
                return;
        }
        if(String.isBlank(es.Approver_05__c)){
            es.Approver_05__c = userId;
            if(!allNulls)
                return;
        }
        if(String.isBlank(es.Approver_06__c)){
            es.Approver_06__c = userId;
            if(!allNulls)
                return;
        }
        if(String.isBlank(es.Approver_07__c)){
            es.Approver_07__c = userId;
            if(!allNulls)
                return;
        }
         if(String.isBlank(es.Approver_08__c)){
            es.Approver_08__c = userId;
            if(!allNulls)
                return;
        }
    }
    private Boolean Save(){
        try{
             Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();
             boolean relock = false;

            //Check for Lock
            if(Approval.isLocked(es.Id) && ApprovedEditAccess){
              new CFEngagementSummaryUtility(es.Id).Unlock();
              relock = true;
            }

            //Auto-Select N/A for Took 338 Election when Asset Sale
            if(es.Purchase_Type__c == 'Asset')
              es.Took_338_Selection__c = 'N/A';

            sc.Save();
            if(ExternalTeam.size() > 0)
                update ExternalTeam;
            if(WinningCounterparties.size() > 0)
                update WinningCounterparties;

            if(relock)
              new CFEngagementSummaryUtility(es.Id).Lock();

            return true;
        }
        catch(DmlException ex){
            return false;
        }
    }

    public PageReference CancelAction(){
            return new PageReference('/' + EngagementId);
    }

    public void RefreshCreditFacilities(){
        CapitalizationRecords = null;
        DebtStructures = null;
    }

    public void RefreshSellerTeam(){
        externalTeam = null;
        sellerContacts = null;
    }

    public void DeleteDebtStructure(){
        if(!String.isBlank(DelId))
        {
            for(Debt_Structure__c ds : DebtStructures){
                if(ds.Id == DelId)
                {
                    delete ds;
                    break;
                }
            }
        }
        CapitalizationRecords = null;
        DebtStructures = null;
    }

    public PageReference ApproveProcess() {
        return ProcessApproval(true);
    }

    public PageReference RejectProcess() {
      PageReference result = ProcessApproval(false);
      //Reset the Status
      if(result != null){
        Engagement_Summary__c esUpdate = new Engagement_Summary__c(Id = sc.getId(), Summary_Status__c = 'In Process');
        update esUpdate;
      }
      return result;
    }

    private PageReference ProcessApproval(Boolean isApproved) {
        Engagement_Summary__c es = (Engagement_Summary__c)sc.getRecord();
        //Map to hold the Actor Id to the Work Items - We need to use the Work Item Associated to the Current User (Actor)
        Map<Id,Id> actorToWorkItemIdMap = new Map<Id,Id>();

        //Retrieve the Work Items
        for (List<ProcessInstance> pis : [SELECT (SELECT Id, ActorId FROM Workitems) FROM ProcessInstance p WHERE p.TargetObjectId =: es.Id AND p.Status = 'Pending']) {
            for (ProcessInstance pi : pis) {
                for (List<ProcessInstanceWorkitem> wis : pi.Workitems) {
                    for (ProcessInstanceWorkitem wi : wis ) {
                        actorToWorkItemIdMap.put(wi.ActorId, wi.Id);
                    }
                }
            }
        }

        if(actorToWorkItemIdMap.get(UserInfo.getUserId()) != null)
        {
          //Create the ProcessWorkitemRequest Record and Populate It
          Approval.ProcessWorkItemRequest req = new Approval.ProcessWorkItemRequest();
          if (isApproved) {
              req.setComments('Approving request.');
              req.setAction('Approve');
          } else {
              req.setComments('Rejecting request.');
              req.setAction('Reject');
          }
          req.setNextApproverIds(new Id[] {UserInfo.getUserId()});

          // Use the ID from the newly created item to specify the item to be worked
          req.setWorkitemId(actorToWorkItemIdMap.get(UserInfo.getUserId()));

          // Submit the request for approval
          Approval.ProcessResult result =  Approval.process(req);

          if(!isApproved)
            Approval.unlock(es.Id);

          if(result.isSuccess()){
            PageReference pr = new PageReference('/apex/HL_CF_EngagementSummary?id=' + es.Id);
            pr.setRedirect(true);
            return pr;
          }
          else
            return null;
        }

        return null;
    }

    public void SubmitApprovalProcess(){
        // Create the New Approval Request to Submit
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitted for approval. Please approve.');
        req.setObjectId(sc.getId());
        // Submit the approval request for processing
        Approval.ProcessResult result = Approval.process(req);
        Approval.lock(sc.getId());
    }

    //Used to hold the Capitalization (Debt_Structure__c) records with related Lenders
    public class CapitalizationRecord{
        public Debt_Structure__c DebtStructure {get; set;}
        public List<Engagement_Client_Subject__c> Lenders {get {
            if(lenders == null)
                lenders = [SELECT Client_Subject__r.Id, Client_Subject__r.Name FROM Engagement_Client_Subject__c WHERE Other_Related_Object_Id__c =: DebtStructure.Id AND Type__c =: 'Key Creditor' ORDER BY Client_Subject__r.Name];

            return lenders;
        } set;}

        public CapitalizationRecord(Debt_Structure__c ds){
            DebtStructure = ds;
        }
    }
    
    //Used to Lock/Unlock the Record without Sharing Worry
    private without sharing class CFEngagementSummaryUtility{
        private Id id {get; set;}
        public CFEngagementSummaryUtility(Id id){
            this.id = id;
        }
        public void Unlock(){
            Approval.unlock(this.id);
        }
        public void Lock(){
            Approval.lock(this.id);
        }
    }
}