public with sharing class HL_FR_DealInformationController {
    private ApexPages.StandardController sc;
    public Id EngagementId {get; set;}
    public String DelId {get; set;} 
    public Id CopyEHToPostID {get; set;}
    public Id CopyBMToPostID {get; set;}
    public Boolean FullAccess {get{
       return HL_Utility.IsSysAdmin() || HL_Utility.IsCAO();
    } set;}
    public Sale_Transaction__c NewSaleTransaction{get{
        if(newSaleTransaction == null)
            newSaleTransaction = new Sale_Transaction__c(Engagement__c = EngagementId);
        return newSaleTransaction;
    } set;}
    
    public List<Engagement_Internal_Team__c> InitiatorMarketingTeam{
        get{
            if(initiatorMarketingTeam == null)
                initiatorMarketingTeam = [SELECT Contact__r.Name FROM Engagement_Internal_Team__c WHERE Engagement__c =: EngagementId ORDER BY Contact__r.Name];
            
            return initiatorMarketingTeam;
        }
        set;}
    
    public Engagement_Financials__c EngagementFinancialsRecord{get{
        if(engagementFinancialsRecord == null){
            List<Engagement_Financials__c> efList = [SELECT CurrencyIsoCode FROM Engagement_Financials__c WHERE Related_Engagement__c =: EngagementId AND Type__c = 'Closing' LIMIT 1];
            if(efList.size() > 0)
                engagementFinancialsRecord = efList[0];
            else
                engagementFinancialsRecord = new Engagement_Financials__c(Related_Engagement__c = EngagementId, Type__c='Closing');      
        }
        return engagementFinancialsRecord;
    }
    set;}
    public List<HL_EngagementFinancialsPivot> EngagementFinancials{get {
        if(engagementFinancials == null){
            List<Engagement_Financials__c> efList = [SELECT Revenue_FY_minus1_MM__c, Revenue_FY_MM__c, Revenue_LTM_MM__c, Revenue_FY_1_MM__c, Revenue_FY_2_MM__c, Revenue_FY_3_MM__c, Revenue_FY_4_MM__c, Revenue_FY_5_MM__c, EBITDA_FY_minus1_MM__c, EBITDA_FY_MM__c, EBITDA_LTM_MM__c, EBITDA_FY_1_MM__c, EBITDA_FY_2_MM__c, EBITDA_FY_3_MM__c, EBITDA_FY_4_MM__c, EBITDA_FY_5_MM__c, Capex_FY_minus1_MM__c, Capex_FY_MM__c, Capex_LTM_MM__c, Capex_FY_1_MM__c, Capex_FY_2_MM__c, Capex_FY_3_MM__c, Capex_FY_4_MM__c, Capex_FY_5_MM__c FROM Engagement_Financials__c WHERE Related_Engagement__c =: EngagementId And Type__c = 'Closing' LIMIT 1];
            Engagement_Financials__c ef = (efList.size() > 0 ? efList[0] : new Engagement_Financials__c(Related_Engagement__c=EngagementId, Type__c='Closing'));
            engagementFinancials = HL_EngagementFinancialsPivot.PivotFinancials(ef);
        }
        return engagementFinancials;
    } set;}
    
    public HL_EngagementFinancialsPivot RevenueFinancials{get{
        return EngagementFinancials[0];
    }
    set;}
    public HL_EngagementFinancialsPivot EBITDAFinancials{get{
        return EngagementFinancials[1];
    }
    set;}
    public HL_EngagementFinancialsPivot CapexFinancials{get{
        return EngagementFinancials[2];
    }
    set;}
    public List<Sale_Transaction__c> SalesTransactions {get{
        if(salesTransactions == null)
            salesTransactions = [SELECT Name, Break_Up_Fee__c, Cash_Component__c, Claim_Conversion__c, Date_of_Sale__c, Deposit__c, Incremental_Overbid__c, Liability_Assumed__c, Minimum_Overbid__c, Stock_Component__c, Total_Sales_Price__c FROM Sale_Transaction__c WHERE Engagement__c =: EngagementId ORDER BY Name];
     
        return salesTransactions;
    }
    set;}
    
    public List<Financing__c> Financing {get{
        if(financing == null)
            financing = [SELECT Financing_Amount__c, Financing_Type__c, Notes__c, Security_Type__c FROM Financing__c WHERE Engagement__c =: EngagementId];
        
        return financing;
    } set;}
    
    public Financing__c NewFinancing {get{
        if(newFinancing == null)
            newFinancing = New Financing__c(Engagement__c = EngagementId);
        return newFinancing;
    } set;}
    public List<Engagement_Client_Subject__c> PreTransactionEquityHolders{
        get{
            if(preTransactionEquityHolders == null)
                preTransactionEquityHolders = [SELECT Client_Subject__r.Name, Percent_Ownership__c FROM Engagement_Client_Subject__c WHERE Type__c = 'Equity Holder' AND Role__c = 'Pre-Transaction' AND Engagement__c =: EngagementId ORDER BY Client_Subject__r.Name];
            return preTransactionEquityHolders;
        }
        set;
    }
    
    public List<Engagement_Client_Subject__c> PostTransactionEquityHolders{
        get{
            if(postTransactionEquityHolders == null)
                postTransactionEquityHolders = [SELECT Client_Subject__r.Name, Percent_Ownership__c FROM Engagement_Client_Subject__c WHERE Type__c = 'Equity Holder' AND Role__c = 'Post-Transaction' AND Engagement__c =: EngagementId ORDER BY Client_Subject__r.Name];
            return postTransactionEquityHolders;
        }
        set;
    }
    
    public List<aBoardMember> PreTransactionBoardMembers{
        get{
            if(preTransactionBoardMembers==null)
            {
               preTransactionBoardMembers = new List<aBoardMember>();
               for(Engagement_External_Team__c eet : HL_EET.GetByRole(EngagementId, 'Pre-Transaction Board Member'))
                 preTransactionBoardMembers.add(new aBoardMember(eet));
            }
            return preTransactionBoardMembers;
        }
        set;
    }
    
    public List<aBoardMember> PostTransactionBoardMembers{
        get{
            if(postTransactionBoardMembers==null){
                 postTransactionBoardMembers = new List<aBoardMember>();
                 for(Engagement_External_Team__c eet : HL_EET.GetByRole(EngagementId, 'Post-Transaction Board Member'))
                     postTransactionBoardMembers.add(new aBoardMember(eet));
            }
            return postTransactionBoardMembers;
        }
        set;
    }
    
    public List<Engagement_External_Team__c> PostTransactionStaffRoles{
        get{
            if(postTransactionStaffRoles == null)
                postTransactionStaffRoles = HL_EET.GetByRecordTypeId(EngagementId, HL_Utility.GetRecordTypeId('Engagement_External_Team__c','Liaison'));
            return postTransactionStaffRoles;
        }
        set;
    }
    
    public List<Engagement_External_Team__c> PostTransactionStaffRolesEXT{
        get{
            if(postTransactionStaffRolesEXT == null)
                postTransactionStaffRolesEXT = HL_EET.GetByRecordTypeIdFRExt(EngagementId, HL_Utility.GetRecordTypeId('Engagement_External_Team__c','FR'));
            return postTransactionStaffRolesEXT;
        }
        set;
    }
    
    public List<aDebtStructure> PreTransactionDebtStructures {get{
           if(preTransactionDebtStructures == null)
           {
                preTransactionDebtStructures = new List<aDebtStructure>();
                for(Debt_Structure__c ds : HL_DebtStructure.GetByPrePostTransaction(EngagementId, 'Pre-Transaction'))
                    preTransactionDebtStructures.add(new aDebtStructure(ds));
           }   
            return preTransactionDebtStructures;
        }
        set;
    }
    
    public Debt_Structure__c NewPreTransactionDebtStructure{get{
        if(newPreTransactionDebtStructure == null)
            newPreTransactionDebtStructure = new Debt_Structure__c(Engagement__c = EngagementId, Pre_Post_Transaction__c = 'Pre-Transaction');    
        return newPreTransactionDebtStructure;
        }
        set;
    }
    
    public List<aDebtStructure> PostTransactionDebtStructures {get{
        if(postTransactionDebtStructures == null){
                postTransactionDebtStructures = new List<aDebtStructure>();
                for(Debt_Structure__c ds : HL_DebtStructure.GetByPrePostTransaction(EngagementId, 'Post-Transaction'))
                    postTransactionDebtStructures.add(new aDebtStructure(ds));
        } 
        
        return postTransactionDebtStructures;
        }
        set;
    }
    
    public Debt_Structure__c NewPostTransactionDebtStructure{get{
        if(newPostTransactionDebtStructure == null)
            newPostTransactionDebtStructure = new Debt_Structure__c(Engagement__c = EngagementId, Pre_Post_Transaction__c = 'Post-Transaction');    
        return newPostTransactionDebtStructure;
        }
        set;
    }
    
    public HL_FR_DealInformationController(ApexPages.StandardController controller){
        sc = controller;
        EngagementId = controller.getId();
    }  
    
    public void UpdateRevenueFinancials(){
           List<Engagement_Financials__c> efList = HL_EngagementFinancial.GetByEngagementIdAndType(EngagementId,'Closing');
           Engagement_Financials__c ef = (efList.size() == 0?new Engagement_Financials__c(Related_Engagement__c = EngagementId, Type__c = 'Closing'):efList[0]);
           if(!String.isBlank(RevenueFinancials.FY_Minus1))
              ef.Revenue_FY_minus1_MM__c = Decimal.valueOf(RevenueFinancials.FY_Minus1);
           else
              ef.Revenue_FY_minus1_MM__c = null;
           if(!String.isBlank(RevenueFinancials.FY))
              ef.Revenue_FY_MM__c = Decimal.valueOf(RevenueFinancials.FY);
           else
              ef.Revenue_FY_MM__c = null;
           if(!String.isBlank(RevenueFinancials.LTM))
              ef.Revenue_LTM_MM__c = Decimal.valueOf(RevenueFinancials.LTM);
           else
              ef.Revenue_LTM_MM__c = null; 
           if(!String.isBlank(RevenueFinancials.FY_Plus1))
              ef.Revenue_FY_1_MM__c = Decimal.valueOf(RevenueFinancials.FY_Plus1);
           else
              ef.Revenue_FY_1_MM__c = null; 
           if(!String.isBlank(RevenueFinancials.FY_Plus2))
              ef.Revenue_FY_2_MM__c = Decimal.valueOf(RevenueFinancials.FY_Plus2);
           else
              ef.Revenue_FY_2_MM__c = null; 
           if(!String.isBlank(RevenueFinancials.FY_Plus3))
              ef.Revenue_FY_3_MM__c = Decimal.valueOf(RevenueFinancials.FY_Plus3);
           else
              ef.Revenue_FY_3_MM__c = null; 
           if(!String.isBlank(RevenueFinancials.FY_Plus4))
              ef.Revenue_FY_4_MM__c = Decimal.valueOf(RevenueFinancials.FY_Plus4);
           else
              ef.Revenue_FY_4_MM__c = null; 
           if(!String.isBlank(RevenueFinancials.FY_Plus5))
              ef.Revenue_FY_5_MM__c = Decimal.valueOf(RevenueFinancials.FY_Plus5);
           else
              ef.Revenue_FY_5_MM__c = null;
           upsert ef;
           UpdateProjectionsLastUpdated();
           engagementFinancials = null;
    }
    
     public void UpdateCapexFinancials(){
           List<Engagement_Financials__c> efList = HL_EngagementFinancial.GetByEngagementIdAndType(EngagementId, 'Closing');
           Engagement_Financials__c ef = (efList.size() == 0?new Engagement_Financials__c(Related_Engagement__c = EngagementId, Type__c = 'Closing'):efList[0]);
           if(!String.isBlank(CapexFinancials.FY_Minus1))
                ef.Capex_FY_minus1_MM__c = Decimal.valueOf(CapexFinancials.FY_Minus1);
           else
               ef.Capex_FY_minus1_MM__c = null;
           if(!String.isBlank(CapexFinancials.FY))
               ef.Capex_FY_MM__c = Decimal.valueOf(CapexFinancials.FY);
           else
               ef.Capex_FY_MM__c = null;
           if(!String.isBlank(CapexFinancials.LTM))
               ef.Capex_LTM_MM__c = Decimal.valueOf(CapexFinancials.LTM);
           else
               ef.Capex_LTM_MM__c = null;
           if(!String.isBlank(CapexFinancials.FY_Plus1))
               ef.Capex_FY_1_MM__c = Decimal.valueOf(CapexFinancials.FY_Plus1);
           else
               ef.Capex_FY_1_MM__c = null;
           if(!String.isBlank(CapexFinancials.FY_Plus2))
               ef.Capex_FY_2_MM__c = Decimal.valueOf(CapexFinancials.FY_Plus2);
           else
               ef.Capex_FY_2_MM__c = null;
           if(!String.isBlank(CapexFinancials.FY_Plus3))
               ef.Capex_FY_3_MM__c = Decimal.valueOf(CapexFinancials.FY_Plus3);
           else
               ef.Capex_FY_3_MM__c = null;
           if(!String.isBlank(CapexFinancials.FY_Plus4))
               ef.Capex_FY_4_MM__c = Decimal.valueOf(CapexFinancials.FY_Plus4);
           else
               ef.Capex_FY_4_MM__c = null;
           if(!String.isBlank(CapexFinancials.FY_Plus5))
               ef.Capex_FY_5_MM__c = Decimal.valueOf(CapexFinancials.FY_Plus5);
           else
               ef.Capex_FY_5_MM__c = null;
           upsert ef;
           UpdateProjectionsLastUpdated();
           engagementFinancials = null;
    }
    
     public void UpdateEBITDAFinancials(){
           List<Engagement_Financials__c> efList = HL_EngagementFinancial.GetByEngagementIdAndType(EngagementId, 'Closing');
           Engagement_Financials__c ef = (efList.size() == 0?new Engagement_Financials__c(Related_Engagement__c = EngagementId, Type__c = 'Closing'):efList[0]);
           if(!String.isBlank(EBITDAFinancials.FY_Minus1))  
                ef.EBITDA_FY_minus1_MM__c = Decimal.valueOf(EBITDAFinancials.FY_Minus1);
           else
               ef.EBITDA_FY_minus1_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.FY))  
                ef.EBITDA_FY_MM__c = Decimal.valueOf(EBITDAFinancials.FY);
           else
               ef.EBITDA_FY_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.LTM))  
                ef.EBITDA_LTM_MM__c = Decimal.valueOf(EBITDAFinancials.LTM);
           else
               ef.EBITDA_LTM_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.FY_Plus1))  
                ef.EBITDA_FY_1_MM__c = Decimal.valueOf(EBITDAFinancials.FY_Plus1);
           else
               ef.EBITDA_FY_1_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.FY_Plus2))  
                ef.EBITDA_FY_2_MM__c = Decimal.valueOf(EBITDAFinancials.FY_Plus2);
           else
               ef.EBITDA_FY_2_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.FY_Plus3))  
                ef.EBITDA_FY_3_MM__c = Decimal.valueOf(EBITDAFinancials.FY_Plus3);
           else
               ef.EBITDA_FY_3_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.FY_Plus4))  
                ef.EBITDA_FY_4_MM__c = Decimal.valueOf(EBITDAFinancials.FY_Plus4);
           else
               ef.EBITDA_FY_4_MM__c = null;
           if(!String.isBlank(EBITDAFinancials.FY_Plus5))  
               ef.EBITDA_FY_5_MM__c = Decimal.valueOf(EBITDAFinancials.FY_Plus5);
           else
               ef.EBITDA_FY_5_MM__c = null;
           upsert ef;
           UpdateProjectionsLastUpdated();
           engagementFinancials = null;
    }
    
    private void UpdateProjectionsLastUpdated()
    {
        Engagement__c e = (Engagement__c)sc.getRecord();
        e.Projections_Last_Updated_By__c = UserInfo.getName();
        update e;
    }
    
    public void AddNewSalesTransaction(){
        if(NewSaleTransaction.Name <> null){
             insert NewSaleTransaction;
             NewSaleTransaction = null;
             SalesTransactions = null;
        }       
    }
    
    public void RefreshFinancing(){
        Financing = null;
    }
    
    public void RefreshPreTransactionDebtStructures(){
        PreTransactionDebtStructures = null;
    }
    
    public void RefreshPostTransactionDebtStructures(){
        PostTransactionDebtStructures = null;
    }
    
    public void RefreshPreTransactionBoardMembers(){
        PreTransactionBoardMembers = null;
    }
    
    public void RefreshPreTransactionEquityHolders(){
        PreTransactionEquityHolders = null;
    }
    
    public void RefreshPostTransactionBoardMembers(){
        PostTransactionBoardMembers = null;
    }
    
    public void RefreshPostTransactionEquityHolders(){
        PostTransactionEquityHolders = null;
    }
    
    public void RefreshPostTransactionStaffRoles(){
        PostTransactionStaffRoles = null;
    }
    
    public void RefreshPostTransactionStaffRolesEXT(){
        PostTransactionStaffRolesEXT = null;
    }
    
    public void RefreshSalesTransactions(){
        SalesTransactions = null;
    }
    
    public void SaveNewPreTransactionDebtStructure(){
        if(NewPreTransactionDebtStructure.Security_Type__c <> null)
        {
            insert NewPreTransactionDebtStructure;
            NewPreTransactionDebtStructure = null;
            PreTransactionDebtStructures = null;
        }
    }
    
      public void SaveNewPostTransactionDebtStructure(){
        if(NewPostTransactionDebtStructure.Security_Type__c <> null)
        {
            insert NewPostTransactionDebtStructure;
            NewPostTransactionDebtStructure = null;
            PostTransactionDebtStructures = null;
        }
    }
    
    public void SaveNewFinancing(){
        if(NewFinancing.Financing_Type__c <> null){
            insert NewFinancing;
            NewFinancing = null;
            Financing = null;
        }
    }
    
    public void CopyEHToPost() {
        Engagement_Client_Subject__c eh = [SELECT Client_Subject__c, Client_Subject__r.Name, RecordTypeId, Percent_Ownership__c, Type__c, Role__c, Engagement__c FROM Engagement_Client_Subject__c WHERE Id =: CopyEHToPostID];
        //Verify record does not already exist in the Post List
        List<Engagement_Client_Subject__c> existingRecords = [SELECT Id FROM Engagement_Client_Subject__c WHERE Client_Subject__c =: eh.Client_Subject__c AND Role__c =: 'Post-Transaction' AND Engagement__c =: EngagementId];
        if(existingRecords.size() == 0)
        {
            Engagement_Client_Subject__c postEH = eh.clone();
            postEH.Role__c = 'Post-Transaction';
            insert postEH;  
            RefreshPostTransactionEquityHolders();
        }
    }
    
    public void CopyBMToPost() {
        Engagement_External_Team__c et = [SELECT Contact__c, Contact__r.Name, Contact__r.Account.Name, Primary__c, Role__c, Engagement__c FROM Engagement_External_Team__c WHERE Id =: CopyBMToPostID];
        //Verify record does not already exist in the Post List
        List<Engagement_External_Team__c> existingRecords = [SELECT Id FROM Engagement_External_Team__c WHERE Contact__c =: et.Contact__c AND Role__c =: 'Post-Transaction Board Member' AND Engagement__c =: EngagementId];
        if(existingRecords.size() == 0)
        {
            Engagement_External_Team__c postBM = et.clone();
            postBM.Role__c = 'Post-Transaction Board Member';
            insert postBM;  
            RefreshPostTransactionBoardMembers();
        }
    }
    
    public void SaveRecord(){
        try{
            Save();
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.CONFIRM, 'Saved At: ' + System.now().format('HH:mm:ss a')));
        }
        catch(DmlException ex){
             ApexPages.addMessages(ex);
        }
    }
    
    public PageReference SaveAndReturn(){
        PageReference pf = ApexPages.currentPage(); 
        try{
            Save();
            pf = new PageReference('/' + EngagementId);
        }
        catch(DmlException ex){
            ApexPages.addMessages(ex);
        }
        return pf; 
    }
    
    private void Save(){
        sc.Save();
        upsert(EngagementFinancialsRecord);
    }
    
    public PageReference CancelAction(){
            return new PageReference('/' + EngagementId);
    }
    
     public PageReference SubmitForm(){ 
        try{
            return new PageReference('/apex/HL_SendEmail?retURL=' + EngagementId + '&template=FR_Summary&ro=' + EngagementId);
        }
        catch(Exception ex){
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public void DeleteSalesTransaction(){
        if(!String.isBlank(DelId))
        {
            for(Sale_Transaction__c st : SalesTransactions){
                if(st.Id == DelId)
                {
                    delete st;
                    break;
                }
            }
        }
        RefreshSalesTransactions();
    }
    
    public void DeleteFinancing(){
        if(!String.isBlank(DelId))
        {
            for(Financing__c f : Financing){
                if(f.Id == DelId)
                {
                    delete f;
                    break;
                }
            }
        }
        RefreshFinancing();
    }
    
    //Delete Pre Transaction Equity Holder
    public void DeletePreEH(){
        if(!String.isBlank(DelId))
        {
            for(Engagement_Client_Subject__c ecs :  PreTransactionEquityHolders){
                if(ecs.Id == DelId)
                {
                    delete ecs;
                    break;
                }
            }
        }
        RefreshPreTransactionEquityHolders();
    }
    
    //Delete Post Transaction Equity Holder
    public void DeletePostEH(){
        if(!String.isBlank(DelId))
        {
            for(Engagement_Client_Subject__c ecs :  PostTransactionEquityHolders){
                if(ecs.Id == DelId)
                {
                    delete ecs;
                    break;
                }
            }
        }
        RefreshPostTransactionEquityHolders();
    }
    
    //Delete Pre Transaction Board Member
    public void DeletePreBM(){
        if(!String.isBlank(DelId))
        {
            for(aBoardMember bm : PreTransactionBoardMembers){
                if(bm.BoardMember.Id == DelId)
                {
                    delete bm.BoardMember;
                    break;
                }
            }
        }
        RefreshPreTransactionBoardMembers();
    }
    
    //Delete Post Transaction Board Member
    public void DeletePostBM(){
        if(!String.isBlank(DelId))
        {
            for(aBoardMember bm : PostTransactionBoardMembers){
                if(bm.BoardMember.Id == DelId)
                {
                    delete bm.BoardMember;
                    break;
                }
            }
        }
        RefreshPostTransactionBoardMembers();
    }
    
    //Delete Pre Transaction Debt Structure
    public void DeletePreDS(){
        if(!String.isBlank(DelId))
        {
            for(aDebtStructure ds : PreTransactionDebtStructures){
                if(ds.DebtStructure.Id == DelId)
                {
                    delete ds.DebtStructure;
                    break;
                }
            }
        }
        RefreshPreTransactionDebtStructures();
    }
    
    //Delete Post Transaction Debt Structure
    public void DeletePostDS(){
        if(!String.isBlank(DelId))
        {
            for(aDebtStructure ds : PostTransactionDebtStructures){
                if(ds.DebtStructure.Id == DelId)
                {
                    delete ds.DebtStructure;
                    break;
                }
            }
        }
        RefreshPostTransactionDebtStructures();
    }
    
    //Delete Post Transaction Staff Roles
    public void DeletePostSR(){
        if(!String.isBlank(DelId))
        {
            for(Engagement_External_Team__c eet : PostTransactionStaffRoles){
                if(eet.Id == DelId)
                {
                    delete eet;
                    break;
                }
            }
        }
        RefreshPostTransactionStaffRoles();
    }
    
     public void DeletePostSREXT(){
        if(!String.isBlank(DelId))
        {
            for(Engagement_External_Team__c eet : PostTransactionStaffRolesEXT){
                if(eet.Id == DelId)
                {
                    delete eet;
                    break;
                }
            }
        }
        RefreshPostTransactionStaffRolesEXT();
    }
    
    public class aBoardMember
    {
        public Engagement_External_Team__c BoardMember{get; set;}
        public Boolean HasRelationship {get; set;}
        public aBoardMember(Engagement_External_Team__c bm){
            BoardMember = bm;
            HasRelationship = ([SELECT Id FROM Relationship__c WHERE External_Contact__c =: BoardMember.Contact__c AND Status__c =: 'Current']).size() > 0;
        }
    }
    
    //Used to hold the (Debt_Structure__c) records with related Lenders
    public class aDebtStructure{
        public Debt_Structure__c DebtStructure {get; set;}
        public List<Engagement_Client_Subject__c> Lenders {get {
            if(lenders == null)
                lenders = [SELECT Client_Subject__r.Id, Client_Subject__r.Name FROM Engagement_Client_Subject__c WHERE Other_Related_Object_Id__c =: DebtStructure.Id AND Type__c =: 'Key Creditor' ORDER BY Client_Subject__r.Name];
            
            return lenders;
        } set;}
        
        public aDebtStructure(Debt_Structure__c ds){
            DebtStructure = ds;
        }
    }
    
    public void checkEngSendBTPEmail(){
        Engagement__c objEng = new Engagement__c(id = EngagementId);
        objEng.Sent_BTP_Email__c = System.Now();
        objEng.FR_Intro_Response_Date__c = System.Today();
        objEng.BTP_Send_by_User__c = UserInfo.getName();
        objEng.BTP_Send_User_EmailId__c = UserInfo.getUserEmail();
        update objEng;
        }
        
        
}