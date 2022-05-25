public with sharing class HL_RevenueProjectionController {
    public List<Revenue_Projection__c> revenueProjectionList {get;set;}
    public integer numberOfMonths {get;set;}
    public integer month {get;set;}
    public integer year {get;set;}
    public integer recordCounter {get;set;}
    public string currencyISO {get;set;}
    private integer newRowMonth;
    private integer newRowYear;
    private integer createMonth;
    private integer createYear;
    private Id engId;
    private Map<string,Revenue_Projection__c> revMap;
    private ApexPages.standardController std;
    
    public HL_RevenueProjectionController(ApexPages.StandardController stdController){
        revenueProjectionList = new List<Revenue_Projection__c>();
        revMap = new Map<string,Revenue_Projection__c>();
        EngId =  stdController.getRecord().id;
        std = stdController;
        month = System.Today().Month();
        year = System.Today().Year();
        currencyISO =  string.valueOf(stdController.getRecord().get('CurrencyIsoCode'));
        numberOfMonths = 13;
        //apexpages.currentpage().getparameters().get('id');
        List<Revenue_Projection__c> rpList = [SELECT Month__c, Year__c, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Total__c, Archive__c, YearMonth__c FROM Revenue_Projection__c WHERE Engagement__c =: EngId ORDER BY Year__c, Month__C ASC];
        if(rpList.size() > 0){
            for(Revenue_Projection__C rp : rpList){
                if(integer.valueOf(rp.YearMonth__c) >= integer.valueOf(string.valueOf(year)+string.valueOf(month).leftPad(2).replace(' ','0')) && revenueProjectionList.size()<=24){
                    revenueProjectionList.add(rp);
                }
                //Make it so that if there are only archived records left current month and year blank entry are created.
                revMap.put(rp.Year__c+rp.Month__c, rp);
            }
        }
        else{
            Revenue_Projection__c newRev = new Revenue_Projection__c(Month__c = String.valueOf(month).leftpad(2).replace(' ','0'), Year__c = String.valueOf(System.Today().Year()), Engagement__c = EngId);
            revenueProjectionList.add(newRev);
            revMap.put(newRev.Year__c+newRev.Month__c, newRev);     
        }
        
        List<AggregateResult> maxYearMonth = [SELECT MAX(YearMonth__c) MaxYearMonth FROM Revenue_Projection__c WHERE Engagement__c =: EngId  GROUP BY Engagement__c LIMIT 13];
        
        newRowMonth = maxYearMonth.size() == 0 ? integer.valueOf(string.valueOf(System.Today().Month()).leftPad(2).replace(' ','0')) : integer.valueOf(((string)maxYearMonth[0].get('MaxYearMonth')).right(2));
        newRowYear = maxYearMonth.size() == 0 ? System.Today().Year() : integer.valueOf(((string)maxYearMonth[0].get('MaxYearMonth')).left(4));
        recordCounter = revenueProjectionList.size();      
        createRows();
    }
    
    public List<SelectOption> getMonthList(){
        List<SelectOption> monthList = new List<SelectOption>();
        Schema.DescribeFieldResult monthResults =  Revenue_Projection__c.month__c.getDescribe();
        List<Schema.PicklistEntry> monthListEntry = monthResults.getPicklistValues();
        for(Schema.PicklistEntry month : monthListEntry){
            monthList.add(new SelectOption(month.getLabel(), month.getValue()));
        }
        return monthList;
    } 
    
    public List<SelectOption> getYearList(){
        List<SelectOption> yearList = new List<SelectOption>();
        Schema.DescribeFieldResult yearResults =  Revenue_Projection__c.year__c.getDescribe();
        List<Schema.PicklistEntry> yearListEntry = yearResults.getPicklistValues();
        for(Schema.PicklistEntry year : yearListEntry){
            if(integer.valueOf(year.getValue()) >= System.Today().Year())
                yearList.add(new SelectOption(year.getLabel(), year.getValue()));
        }
        return yearList;
    }
    
    public void createRows(){
        createMonth = month;
        createYear = year;
        recordCounter = numberOfMonths;
        revenueProjectionList = new List<Revenue_Projection__c>();
        
        for(integer i=0; i<numberOfMonths;i++){
            Revenue_Projection__c revP = new Revenue_Projection__c(Month__c = string.valueOf(createMonth).leftPad(2).replace(' ','0'), Year__c = string.valueOf(createYear).leftPad(2).replace(' ','0'), Engagement__c = EngId);
            if(revMap.containsKey(revP.Year__c+revP.Month__c))
                revenueProjectionList.add(revMap.get(revP.Year__c+RevP.Month__c));
            else {
                revenueProjectionList.add(revP);
                revMap.put(revP.Year__c+revp.Month__c, revP);
            }
            
            if(i < numberOfMonths-1){
                createMonth = createMonth + 1 == 13 ? 1 : createMonth + 1;
                createYear = createMonth + 12 == 13 ? createYear + 1 : createYear;
            }
        }

        newRowYear = createYear;
        newRowMonth = createMonth;
    }
    
    public void addRows(){
        newRowMonth = newRowMonth + 1 == 24 ? 1 : newRowMonth + 1;
        newRowYear = newRowMonth + 12 == 24 ? newRowYear + 1 : newRowYear;
        String stringMonth = string.valueOf(newRowMonth).leftpad(2).replace(' ','0');
        String stringYear = string.valueOf(newRowYear);
        
        if(recordCounter < 24) {
            recordCounter = recordCounter + 1;
            if(!(revMap.containsKey(stringYear+stringMonth))) {
                Revenue_Projection__c revRow = new Revenue_Projection__c(Month__c = stringMonth, Year__c = stringYear, Engagement__c = EngId);
                revenueProjectionList.add(revRow);
            }
            else 
                revenueProjectionList.add(revMap.get(stringYear+stringMonth));
        }
    }
    
    public pageReference save(){
        try{
            List<Revenue_Projection__c> upsertList = new List<Revenue_Projection__c>();
            List<Revenue_Projection__c> deleteList = new List<Revenue_Projection__c>();
            for(Revenue_Projection__c rev : revenueProjectionList){
                if (!(rev.Projected_Transaction_Fee__c == null && rev.Projected_Monthly_Fee__c == null)){
                    rev.Line_of_Business__c = 'FR';
                    upsertList.add(rev); 
                }
                
                else if (rev.Projected_Transaction_Fee__c == null && rev.Projected_Monthly_Fee__c == null && rev.Id <> null){
                    deleteList.add(rev);
                    revMap.put(rev.Year__c+rev.Month__c, new Revenue_Projection__c(Month__c = rev.Month__c, Year__c = rev.Year__c, Engagement__c = EngId));
                    for(integer i=0;i<revenueProjectionList.size();i++){
                        if(revMap.containsKey(revenueProjectionList[i].Year__c+revenueProjectionList[i].Month__c))
                            revenueProjectionList[i] = revMap.get(revenueProjectionList[i].Year__c+revenueProjectionList[i].Month__c);
                    }
                }
            }
            
            if(upsertList.size() > 0)
                upsert upsertList;
            if(deleteList.size() > 0)
                delete deleteList;
            updateRevenueProjectionList();
            createRows();
            HL_PageUtility.ShowConfirm('Records Saved'); 
        }
        
        catch(DMLException e){
            ApexPages.addMessages(e);
        }
        
        
        return null;
    }
    
    public void clear(){
        integer indexVal = integer.valueOf(System.currentPageReference().getParameters().get('Index'));
        if(revenueProjectionList[indexVal-1].Archive__c <> true){
            revenueProjectionList[indexVal-1].Projected_Transaction_Fee__c = null;
            revenueProjectionList[indexVal-1].Projected_Monthly_Fee__c = null;
        }
    }
    
    public pageReference cancel(){
        return std.cancel();
    }
    
    public void updateRevenueProjectionList() {
        revenueProjectionList = new List<Revenue_Projection__c>();

        List<Revenue_Projection__c> rpList = [SELECT Month__c, Year__c, Projected_Monthly_Fee__c, Projected_Transaction_Fee__c, Total__c, Archive__c, YearMonth__c FROM Revenue_Projection__c WHERE Engagement__c =: EngId ORDER BY Year__c, Month__C ASC];
        if(rpList.size() > 0){
            for(Revenue_Projection__C rp : rpList){
                if(integer.valueOf(rp.YearMonth__c) >= integer.valueOf(string.valueOf(year)+string.valueOf(month).leftPad(2).replace(' ','0')) && revenueProjectionList.size()<=12){
                    revenueProjectionList.add(rp);
                }
                //Make it so that if there are only archived records left current month and year blank entry are created.
                revMap.put(rp.Year__c+rp.Month__c, rp);
            }
        }
        else{
            Revenue_Projection__c newRev = new Revenue_Projection__c(Month__c = String.valueOf(month).leftpad(2).replace(' ','0'), Year__c = String.valueOf(System.Today().Year()), Engagement__c = EngId);
            revenueProjectionList.add(newRev);
            revMap.put(newRev.Year__c+newRev.Month__c, newRev);
            
        }
    }
}