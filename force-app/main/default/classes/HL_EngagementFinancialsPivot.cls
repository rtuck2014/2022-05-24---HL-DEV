public with sharing class HL_EngagementFinancialsPivot {
    Public Id EngagementFinancialsId {get; set;}
    public String FinancialType {get; set;}
    public String FY_Minus1 {get; set;}
    public String FY {get; set;}
    public String LTM {get; set;}
    public String FY_Plus1 {get; set;}
    public String FY_Plus2 {get; set;}
    public String FY_Plus3 {get; set;}
    public String FY_Plus4 {get; set;}
    public String FY_Plus5 {get; set;}
    
    public HL_EngagementFinancialsPivot(Id SourceId, String type, string FY_Minus1, string FY, string LTM, string FY_Plus1, string FY_Plus2, string FY_Plus3, string FY_Plus4, string FY_Plus5){
        EngagementFinancialsId = SourceId;
        FinancialType = type;   
        //if(!String.isBlank(FY_Minus1))
        	this.FY_Minus1 = FY_Minus1;
        //if(!String.isBlank(FY))
        	this.FY = FY;
        //if(!String.isBlank(LTM))
        	this.LTM = LTM;
        //if(!String.isBlank(FY_Plus1))
        	this.FY_Plus1 = FY_Plus1;
        //if(!String.isBlank(FY_Plus2))
        	this.FY_Plus2 = FY_Plus2;
        //if(!String.isBlank(FY_Plus3))
        	this.FY_Plus3 = FY_Plus3;
        //if(!String.isBlank(FY_Plus4))
        	this.FY_Plus4 = FY_Plus4;
       // if(!String.isBlank(FY_Plus5))
        	this.FY_Plus5 = FY_Plus5;
    }
    
    public static List<HL_EngagementFinancialsPivot> PivotFinancials(Engagement_Financials__c ef){
        List<HL_EngagementFinancialsPivot> results = new List<HL_EngagementFinancialsPivot>{
            new HL_EngagementFinancialsPivot(ef.Id, 'Revenue', String.valueOf(ef.Revenue_FY_minus1_MM__c),  String.valueOf(ef.Revenue_FY_MM__c),  String.valueOf(ef.Revenue_LTM_MM__c),  String.valueOf(ef.Revenue_FY_1_MM__c),  String.valueOf(ef.Revenue_FY_2_MM__c),  String.valueOf(ef.Revenue_FY_3_MM__c),  String.valueOf(ef.Revenue_FY_4_MM__c),  String.valueOf(ef.Revenue_FY_5_MM__c)), 
            new HL_EngagementFinancialsPivot(ef.Id, 'EBITDA',  String.valueOf(ef.EBITDA_FY_minus1_MM__c),  String.valueOf(ef.EBITDA_FY_MM__c),  String.valueOf(ef.EBITDA_LTM_MM__c),  String.valueOf(ef.EBITDA_FY_1_MM__c),  String.valueOf(ef.EBITDA_FY_2_MM__c),  String.valueOf(ef.EBITDA_FY_3_MM__c),  String.valueOf(ef.EBITDA_FY_4_MM__c),  String.valueOf(ef.EBITDA_FY_5_MM__c)), 
            new HL_EngagementFinancialsPivot(ef.Id, 'Capex',  String.valueOf(ef.Capex_FY_minus1_MM__c),  String.valueOf(ef.Capex_FY_MM__c),  String.valueOf(ef.Capex_LTM_MM__c),  String.valueOf(ef.Capex_FY_1_MM__c),  String.valueOf(ef.Capex_FY_2_MM__c),  String.valueOf(ef.Capex_FY_3_MM__c),  String.valueOf(ef.Capex_FY_4_MM__c),  String.valueOf(ef.Capex_FY_5_MM__c))};

        return results;
    }
}