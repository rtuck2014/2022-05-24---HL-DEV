public with sharing class HL_Staff_Role {
    public enum RoleType {Opportunity, Engagement}
    public enum RoleLOB {CF, FVA, FR, SC}
    //Returns the possible roles by Opportunity/Engagement and Related LOB
    //Include FS__c for Business Rule Checks
    public static List<Staff_Role__c> GetRoles(RoleType rt, RoleLOB lob){
        Boolean opportunity = rt == RoleType.Opportunity;
        Boolean engagement = rt == RoleType.Engagement;
        Boolean CF = lob == RoleLOB.CF;
        Boolean FVA = lob == RoleLOB.FVA;
        Boolean FR = lob == RoleLOB.FR;
        Boolean SC = lob == RoleLOB.SC;
        List<Staff_Role__c> roleList = Database.query('SELECT Name, Display_Name__c, Display_Order__c, FS__c, Registered_Only__c, Non_Registered_Only__c, Registered_Excluded_Job_Codes__c, Fin_Only__c, Non_Fin_Only__c ' +
                                                      'FROM Staff_Role__c ' +
                                                      'WHERE ' + (opportunity ? 'Opportunity__c =: opportunity ' : 'Engagement__c =: engagement ') +
                                                      'AND ' + (CF ? 'CF__c =: CF ' : FVA ? 'FAS__c =: FVA ' : FR ? 'FR__c =: FR ' : 'SC__c =: SC ') +
                                                      'ORDER BY Display_Order__c');
        return roleList;
    }
    
    //Filters down the Selectable Staff Roles based on Custom Business Logic
    public static List<Staff_Role__c> FilterSelectableRoles(Contact c, String lob, String jobCode, Boolean bypassFS, Boolean isForeign, List<Staff_Role__c> roleList){
        Boolean isFS = c.Department == 'FS' || c.Department == 'FSCG';
        Set<String> stChecks = new Set<String> {'ADMIN','CORP','FIN',''}; //The rules are built around these staff types
            List<Staff_Role__c> finalList = roleList.clone();
        Staff_Role__c sr; //Current Role we are Looking At
        /*String pfaJobCode = HL_JobType.GetJobCode('Private Funds: Primary Advisory');
        String pfaJobCode1 = HL_JobType.GetJobCode('Private Funds: Secondary Advisory');
        String pfaJobCode2 = HL_JobType.GetJobCode('Private Funds: GP Stake Sale');
        String pfaJobCode3 = HL_JobType.GetJobCode('Private Funds: GP Advisory');*/
        Set<String> privateFundSet = new Set<String>();
        for(Job_Type__c jt : [SELECT Name, Job_Code__c FROM Job_Type__c WHERE Name like 'Private Funds:%']){
            privateFundSet.add(jt.Job_Code__c);
        }
        Integer offset = 0; //Because we are looping by index, when we remove, we have to take into account the new list size
        Boolean isRemoved;
        
        for(Integer i = 0; i<roleList.size(); i++){
            isRemoved = false;
            sr = roleList[i];
            
            if(sr.Name == 'PE/Hedge Fund' && isFS ){
                Continue;
            } 
            //If Job Type is Private Funds: Primary Advisory or Industry is PFG - Private Funds Group
            //if ((jobCode == pfaJobCode || jobCode == pfaJobCode1 || jobCode == pfaJobCode2 || jobCode == pfaJobCode3) || c.Industry_Group__C == 'PFG - Private Funds Group') {
            if (privateFundSet.contains(jobCode) || c.Industry_Group__C == 'PFG - Private Funds Group') {
                Boolean allowed = false;
                // Industry and Job Code are PFG/PFA and registered (7/63) financial; can be staffed as any role
                if (c.Industry_Group__C == 'PFG - Private Funds Group' && (privateFundSet.contains(jobCode)) && c.Staff_Type__c == 'FIN' && isForeign) {
                    allowed = true;
                }
                // Industry and Job Code are PFG/PFA and registered (7/63) financial; can be staffed as any role
                else if (c.Industry_Group__C == 'PFG - Private Funds Group' && (privateFundSet.contains(jobCode)) && c.Registered__c && c.Staff_Type__c == 'FIN' && !sr.Non_Registered_Only__c) {
                    allowed = true;
                }
                // Industry and Job Code are PFG/PFA and not registered foreign financial; can be staffed on a US deal any role
                else if (c.Industry_Group__C == 'PFG - Private Funds Group' && (privateFundSet.contains(jobCode)) && !c.Registered__c && c.Is_Foreign_Office__c && !isForeign && c.Staff_Type__c == 'FIN' && !sr.Non_Registered_Only__c) {
                    allowed = true;
                }
                // Industry and Job Code are PFG/PFA and not registered US financial; can be staffed on a foreign deal any role
                else if (c.Industry_Group__C == 'PFG - Private Funds Group' && (privateFundSet.contains(jobCode)) && !c.Registered__c && !c.Is_Foreign_Office__c && isForeign && c.Staff_Type__c == 'FIN' && !sr.Non_Registered_Only__c) {
                    allowed = true;
                }
                // Industry group is CM (They require 7/63/79 licenses) and registered financial staff; can be staffed as any role
                else if (c.Industry_Group__C == 'CM - Capital Markets' && (privateFundSet.contains(jobCode)) && c.Registered__c && c.Staff_Type__c == 'FIN' && !sr.Non_Registered_Only__c) {
                    allowed = true;
                }
                // Industry is PFG and other job code; CF/FR line of business and registered financial; can be staffed on only specific roles Seller/Initiator/Marketing/Specialty
                else if (c.Industry_Group__C == 'PFG - Private Funds Group' && (!privateFundSet.contains(jobCode)) && c.Registered__c && (lob == 'CF' || lob == 'FR' || lob == 'FVA' || lob == 'SC') && c.Staff_Type__c == 'FIN' && !sr.Non_Registered_Only__c && (sr.Name == 'Initiator' || sr.Name == 'Seller' || sr.Name == 'Marketing Team'  || sr.Name == 'Ind/Prod/Geog Person')) {
                    allowed = true;
                }
                // Industry group is any other and registered (63/79) financial staff; can be staffed on only specific roles Seller/Initiator/Marketing/Specialty
                else if (c.Industry_Group__C != 'CM - Capital Markets' && c.Industry_Group__C != 'PFG - Private Funds Group' && c.Registered__c && c.Staff_Type__c == 'FIN' && !sr.Non_Registered_Only__c && (sr.Name == 'Initiator' || sr.Name == 'Seller' || sr.Name == 'Marketing Team'  || sr.Name == 'Ind/Prod/Geog Person')) {
                    allowed = true;
                }
                // Financial unregistered; can be staffed as Non-Registered
                else if (!c.Registered__c && sr.Non_Registered_Only__c && c.Staff_Type__c == 'FIN') {
                    allowed = true;
                }
                // Non Financial Roles; can be staffed as Admin/Intern
                else if (c.Staff_Type__c != 'FIN' && sr.Name == 'Intern' && !((c.Registered__c && sr.Non_Registered_Only__c) || (!c.Registered__c && sr.Registered_Only__c))) {
                    allowed = true;
                }
                
                if (!allowed) {
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }
            }
            else {            
                //RB- If staff type is Intern or Admin and Role is not Admin, remove it
                if((c.Staff_Type__c == 'Admin' || c.Staff_Type__c == 'Intern') && sr.Name != 'Intern'){
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }  
                
                //If staff member is in FS and Role is not available for FS, remove it
                if(!isRemoved && isFS && !sr.FS__c && !bypassFS){
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }
                //If Staff Member is Registered (Domestic or Foreign) and Staff Type in ADMIN, CORP, FIN or BLANK, they cannot be in Non-Registered Roles (Intern for Examples)
                if(!isRemoved && c.Registered__c && (String.isBlank(c.Staff_Type__c) ||stChecks.contains(c.Staff_Type__c)) && sr.Non_Registered_Only__c){
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }
                //If Staff Member is Non Registered (Domestic) and the Deal is In the US
                if(!isRemoved && c.Staff_Type__c == 'FIN' && sr.Non_Fin_Only__c){//If staff member is FIN and role is Non-Fin Only
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }
                if(!isRemoved && c.Staff_Type__c != 'FIN' && sr.Fin_Only__c){//If staff member is Non-FIN and role is Fin Only
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }
                
                //If staff member is non-registered (U.S.) and deal is US based, they cannot be assigned to a registered only role (unless jobcode permits)
                if(!isRemoved && !c.Registered__c && !c.Is_Foreign_Office__c && !isForeign && sr.Registered_Only__c &&
                   (String.IsBlank(sr.Registered_Excluded_Job_Codes__c) || String.IsBlank(jobCode) || !sr.Registered_Excluded_Job_Codes__c.contains(jobCode))){
                       finalList.remove(i-offset);
                       offset++;
                       isRemoved = true;
                   }
                
                //If staff member is non-registered(Foreign) and not FIN, they cannot be staffed
                //FIN foreign non-registered staff can be staffed on any U.S. deals
                if(!isRemoved && !c.Registered__c && c.Is_Foreign_Office__c && !isForeign && c.Staff_Type__c <> 'FIN' && sr.Registered_Only__c){
                    finalList.remove(i-offset);
                    offset++;
                    isRemoved = true;
                }
            }
        }
        
        return finalList;
    }
    
    public static List<Staff_Role__c> GetByName(String name){
        return [SELECT Name, Display_Name__c, Display_Order__c, FS__c,
                Registered_Only__c, Non_Registered_Only__c, Registered_Excluded_Job_Codes__c, Fin_Only__c, Non_Fin_Only__c
                FROM Staff_Role__c
                WHERE Name =: name];
    }
    
    public static List<String> GetSortedRoles(Set<String> roles){
        List<String> results = new List<String>();
        for(Staff_Role__c sr : [SELECT Name
                                FROM Staff_Role__c
                                WHERE Name IN:roles ORDER BY Display_Order__c])
            results.add(sr.Name);
        
        return results;
    }
}