public class SL_MonthlyRevenueProcessControllerExt {

    private final ApexPages.StandardController controller;
    
    public SL_MonthlyRevenueProcessControllerExt(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference createRecord() {
        Boolean createNewRecord;
        Integer newMonthInt, newYearInt;
        String currMonth, currYear, newMonth, newYear, externalId, strURL, retURL;
        PageReference p;
        Monthly_Revenue_Process_Control__c newMrpc = new Monthly_Revenue_Process_Control__c();
        Monthly_Revenue_Process_Control__c currMrpc;
        
        // Set Database SavePoint
        Savepoint sp = Database.setSavepoint();
        
        // Obtain current month and year from Monthly_Revenue_Process_Control__c record
        Monthly_Revenue_Process_Control__c[] currMrpcs = [SELECT Id, IsCurrent__c, Current_Month__c, Current_Year__c, Current_Month_and_Year__c, Staff_Summary_Report_Sent__c FROM Monthly_Revenue_Process_Control__c WHERE IsCurrent__c = true LIMIT 1];
        if (currMrpcs.size() > 0) {
            currMrpc = currMrpcs[0];
            // Validate that current Mrpc record is ready to be closed
            if (currMrpc.Staff_Summary_Report_Sent__c != true) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'The current Monthly Revenue Process Control record is not ready to be closed.<br/><br/>You must progress through all steps until the Staff Summary Report has been sent.'));                
                // Set flag
                createNewRecord = false;
            } else {
                // Set isCurrent flag on existing record
                currMrpc.IsCurrent__c = false;
                try {
                    update currMrpc;
                    // Set Default Values for New Process Control Record
                    // Default Month and Year
                    currMonth = currMrpc.Current_Month__c;
                    currYear = currMrpc.Current_Year__c;
                    if (currMonth == '01') {
                        newMonth = '02';
                        newYear = currYear;
                    } else if  (currMonth == '02') {
                        newMonth = '03';
                        newYear = currYear;
                    } else if (currMonth == '03') {
                        newMonth = '04';
                        newYear = currYear;
                    } else if (currMonth == '04') {
                        newMonth = '05';
                        newYear = currYear;
                    } else if (currMonth == '05') {
                        newMonth = '06';
                        newYear = currYear;
                    } else if (currMonth == '06') {
                        newMonth = '07';
                        newYear = currYear;
                    } else if (currMonth == '07') {
                        newMonth = '08';
                        newYear = currYear;
                    } else if (currMonth == '08') {
                        newMonth = '09';
                        newYear = currYear;
                    } else if (currMonth == '09') {
                        newMonth = '10';
                        newYear = currYear;
                    } else if (currMonth == '10') {
                        newMonth = '11';
                        newYear = currYear;
                    } else if (currMonth == '11') {
                        newMonth = '12';
                        newYear = currYear;
                    } else if (currMonth == '12') {
                        newMonth = '01';
                        newYearInt = Integer.valueOf(currYear)+1;
                        newYear = newYearInt.format();
                        newYear = newYear.replace(',','');
                    }
                    newMrpc.Current_Month__c = newMonth;
                    newMrpc.Current_Year__c = newYear;
                    // Default External Id
                    externalId = newMonth+'|'+newYear;
                    newMrpc.Current_Month_and_Year__c = externalId;
                    // Set IsCurrent flag
                    newMrpc.IsCurrent__c = true;
                    // Set flag
                    createNewRecord = true;
                } catch (DmlException e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while updating the current Process Control record:<br/><br/>'+e.getMessage()));
                    createNewRecord = false;
                }
            }
        } else {
            // Default Month and Year
            Date today = Date.today();
            newMonthInt = today.month();
            if (newMonthInt < 10) {
                newMonth = '0'+newMonthInt.format();
            } else {
                newMonth = newMonthInt.format();
            }
            newYearInt = today.year();
            newYear = newYearInt.format();
            newMrpc.Current_Month__c = newMonth;
            newMrpc.Current_Year__c = newYear;
            // Default External Id
            externalId = newMonth+'|'+newYear;
            newMrpc.Current_Month_and_Year__c = externalId;
            // Set isCurrent flag
            newMrpc.IsCurrent__c = true;
            // Set flag
            createNewRecord = true;
        }
        if (createNewRecord) {
            // Save Monthly Revenue Process Control record
            try {
                insert newMrpc;
                // Set return URL
                retURL ='%2F'+newMrpc.Id;
                strURL = '/'+newMrpc.id+'/e?retURL='+retURL;
                system.debug('>>>>> strURL = ' + strURL);
                // Set page reference and return
                p = new PageReference(strURL);
                return p.setRedirect(true);
            } catch(DmlException e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred while saving the new Monthly Revenue Process Control record:<br/><br/>' + e.getMessage()));
                // Roll back to SavePoint
                Database.rollback(sp);
            }
        }
        return null;
    }
}