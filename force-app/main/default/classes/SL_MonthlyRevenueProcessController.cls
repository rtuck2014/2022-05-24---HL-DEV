public with sharing class SL_MonthlyRevenueProcessController {
   
    public String ProcessId {get;set;}
    public String Status {get;set;}
    public Boolean InitialReversalEnabled {get;set;}
    public Boolean LockAllEnabled {get;set;}
    public Boolean RevenueAccrualsLocked {get;set;}
    public Boolean FinalReversalEnabled {get;set;}
    public Boolean ExportRevenueEnabled {get;set;}
    public Boolean EarlyLookEnabled {get;set;}
    public Boolean CurrencyConversionEnabled {get;set;}
    public Boolean FinalReportEnabled {get;set;}
    public Boolean StaffSummaryEnabled {get;set;}
    public Boolean RefreshPage {get;set;}
    public String strRedirectUrl {get;set;}
    public Boolean GenerateRevenueEnabled {get;set;}

    public Monthly_Revenue_Process_Control__c process;
    public String buttonSelected;

    private Apexpages.StandardController stdController;
    private Monthly_Revenue_Process_Control__c thisProcess;
    private String IntranetURL {
        get{
            //Custom Setting 
            HL_General__c hg = HL_General__c.getOrgDefaults();
            return hg.IntranetURLStub__c;
        }
    }
    public SL_MonthlyRevenueProcessController(ApexPages.StandardController stdController) {
        RefreshPage=false;
        
        Date dateToday = Date.Today();
        system.debug('>>>>> Date Today = ' + dateToday);
        
        Integer currentMonth = dateToday.Month();
        system.debug('>>>>> Current Month = ' + currentMonth);

        String fullCurrentMonth;
        if(currentMonth == 1) fullCurrentMonth = 'January';
        if(currentMonth == 2) fullCurrentMonth = 'February';
        if(currentMonth == 3) fullCurrentMonth = 'March';
        if(currentMonth == 4) fullCurrentMonth = 'April';
        if(currentMonth == 5) fullCurrentMonth = 'May';
        if(currentMonth == 6) fullCurrentMonth = 'June';
        if(currentMonth == 7) fullCurrentMonth = 'July';
        if(currentMonth == 8) fullCurrentMonth = 'August';
        if(currentMonth == 9) fullCurrentMonth = 'September';
        if(currentMonth == 10) fullCurrentMonth = 'October';
        if(currentMonth == 11) fullCurrentMonth = 'November';
        if(currentMonth == 12) fullCurrentMonth = 'December';
        system.debug('>>>>> Full Current Month = ' + fullCurrentMonth);
        
        String currentYear = String.valueOf(dateToday.Year());
        system.debug('>>>>> Current Year = ' + currentYear);
        
        this.stdController = stdController;
        thisProcess = (Monthly_Revenue_Process_Control__c)stdController.getRecord();
        if (thisProcess.id == null) {
            // Set defaults for new records here
            process = new Monthly_Revenue_Process_Control__c(
                Status__c = '',
                Current_Month__c = fullCurrentMonth,
                Current_Year__c = currentYear,
                Initial_Reversal_Submitted__c = false,
                Initial_Reversal_Completed__c = false,
                Revenue_Accruals_Locked__c = false,
                Final_Reversal_Submitted__c = false,
                Final_Reversal_Completed__c = false,
                Currency_Conversion_Submitted__c = false,
                Currency_Conversion_Completed__c = false,
                Early_Look_Final_Report_Submitted__c = false,
                Early_Look_Final_Report_Sent__c = false,
                Export_Revenue_Submitted__c = false,
                Export_Revenue_Completed__c = false,
                Final_Report_Submitted__c = false,
                Final_Report_Sent__c = false,
                Staff_Summary_Report_Submitted__c = false,
                Staff_Summary_Report_Sent__c = false
                );
            system.debug('>>>>> Process = ' + process);
            ProcessId = null;
            system.debug('>>>>> Process Id = ' + processId);
        } else {
            // Existing Process
            process = [SELECT Id, 
                              Name, 
                              Status__c, 
                              Initial_Reversal_Submitted__c, 
                              Initial_Reversal_Completed__c, 
                              Revenue_Accruals_Locked__c, 
                              Final_Reversal_Submitted__c, 
                              Final_Reversal_Completed__c,
                              Currency_Conversion_Submitted__c,
                              Currency_Conversion_Completed__c,
                              Early_Look_Final_Report_Submitted__c,
                              Early_Look_Final_Report_Sent__c,
                              Export_Revenue_Submitted__c,
                              Export_Revenue_Completed__c,
                              Final_Report_Submitted__c,
                              Final_Report_Sent__c,
                              Staff_Summary_Report_Submitted__c,
                              Staff_Summary_Report_Sent__c,
                              Generate_Revenue_Submitted__c,  
                              Generate_Revenue_Completed__c 
                       FROM Monthly_Revenue_Process_Control__c 
                       WHERE Id = :thisProcess.id];
            system.debug('>>>>> Process = ' + process);
            ProcessId = process.Id;
            system.debug('>>>>> Process Id ' + processId);
        }
        Status = process.Status__c;
        InitialReversalEnabled = (!process.Initial_Reversal_Submitted__c);
        RevenueAccrualsLocked = (process.Revenue_Accruals_Locked__c);
        LockAllEnabled = ((process.Initial_Reversal_Completed__c) && (!process.Revenue_Accruals_Locked__c));
        FinalReversalEnabled = ((process.Revenue_Accruals_Locked__c) && (!process.Final_Reversal_Submitted__c));
        EarlyLookEnabled = ((process.Final_Reversal_Completed__c) && (!process.Early_Look_Final_Report_Submitted__c)); //((process.Export_Revenue_Completed__c) && (!process.Early_Look_Final_Report_Submitted__c));
        FinalReportEnabled = ((process.Early_Look_Final_Report_Sent__c) && (!process.Final_Report_Submitted__c));
        ExportRevenueEnabled = ((process.Final_Report_Sent__c) && (!process.Export_Revenue_Submitted__c));
        GenerateRevenueEnabled = ((process.Export_Revenue_Completed__c) && (!process.Generate_Revenue_Submitted__c));
        
        CurrencyConversionEnabled = ((process.Export_Revenue_Completed__c) && (!process.Currency_Conversion_Submitted__c));
       
        StaffSummaryEnabled = ((process.Currency_Conversion_Completed__c) && (!process.Staff_Summary_Report_Submitted__c));
    }

    public PageReference initialReversal() {
        process.Initial_Reversal_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
     //   strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=1&id='+ProcessId;
     //   system.debug('>>>>> Redirect URL = ' + strRedirectUrl);
        ButtonSelected = 'InitialReversal';
        return null;
    }   

    public PageReference lockAll() {
        HL_General__c hg = HL_General__c.getOrgDefaults();
        hg.Revenue_Accrual_Locked__c = true;
        update hg;
        process.Revenue_Accruals_Locked__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
        return null;
    }   
    
    public PageReference finalReversal() {
        process.Final_Reversal_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
      //  strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=2&id='+ProcessId;
        return null;
    }   

    public PageReference exportRevenue() {
        process.Export_Revenue_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
      //  strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=3&id='+ProcessId;
        return null;
    }   

    public PageReference earlyLook() {
        process.Early_Look_Final_Report_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
     //   strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=4&id='+ProcessId;
        return null;
    }   

    public PageReference currencyConversion() {
        process.Currency_Conversion_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
     //   strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=5&id='+ProcessId;
        return null;
    }   

    public PageReference finalReport() {
        process.Final_Report_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
      //  strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=6&id='+ProcessId;
        return null;
    }

    public PageReference staffSummary() {
        process.Staff_Summary_Report_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
      //  strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=7&id='+ProcessId;
        return null;
    }   
    
    public PageReference generateRevenue() {
        process.Generate_Revenue_Submitted__c = true;
        update process;
        RefreshPage=true;
        strRedirectUrl='/'+ProcessId;
      //  strRedirectUrl= IntranetURL + 'monthlyrevenueprocessing/default.aspx?action=8&id='+ProcessId;
        return null;
    }           
}