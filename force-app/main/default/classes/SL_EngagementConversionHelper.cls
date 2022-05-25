public with sharing class SL_EngagementConversionHelper {

    private static Map<String, Id> developerNameToID { 
        get {
            if (developerNameToID==null){
                /*List<RecordType> recordTypes = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Engagement__c'];
                developerNameToID = new Map<String, Id>();
                for (RecordType rt: recordTypes){
                    developerNameToID.put(rt.DeveloperName, rt.Id);
                }*/
                developerNameToID = new Map<String, Id>();
                Map<String,Schema.RecordTypeInfo> rtInfoMap = Schema.SObjectType.Engagement__c.getRecordTypeInfosByDeveloperName();
                for(String devName : rtInfoMap.keySet()){
                    developerNameToId.put(devName,rtInfoMap.get(devName).getRecordTypeId());
                }
            }
            return developerNameToID;
        }
        set;
    }
    /*
        * MethodName        : createEngagementCounterpartyContacts
        * param             : Map<Id, Engagement_Counterparty__c>counterparties 
        * Description       : This function accepts the newly inserted counterparties and handles them to create their contacts
    */
    public static void createEngagementCounterpartyContacts(Map <Id, Engagement_Counterparty__c> counterparties){
        Map <Id, Engagement_Counterparty__c> convertedECs = new Map<Id, Engagement_Counterparty__c>();
        Map <Id, Engagement_Counterparty__c> clonedECs = new Map<Id, Engagement_Counterparty__c>();
        for (Engagement_Counterparty__c ecp: [SELECT Id, Engagement__r.Opportunity__c, Engagement__r.Engagement__c, Company__c FROM Engagement_Counterparty__c WHERE Id IN :counterparties.keySet()]){
            if (ecp.Engagement__r.Engagement__c!=null){
                clonedECs.put(ecp.Id, ecp);
            }
            else {
                convertedECs.put(ecp.Id, ecp);
            }
        }
        // Modified by Sandep Singhal on Date 10 Feb 2017 for SF-393
        convertEngagementCounterpartySubItems(convertedECs, 'Engagement_Counterparty_Contact__c');
        // Added by Sandep Singhal on Date 10 Feb 2017 for SF-393
        convertEngagementCounterpartySubItems(convertedECs, 'Engagement_Counterparty_Comment__c');
        cloneEngagementCounterpartyContacts(clonedECs);
                
    }
    /*
        * MethodName        : convertEngagementCounterpartyContacts
        * param             : Map<Id, Engagement_Counterparty__c>engagementCounterparties 
        * Description       : This function accepts the converted counterparties and inserts their counterparty contacts
    */
    private static void convertEngagementCounterpartySubItems(Map<Id, Engagement_Counterparty__c> engagementCounterparties, String typeofObj){
        Map<Id, List<Engagement_Counterparty__c>> oppsToEgmtCounterparties = new Map<Id, List<Engagement_Counterparty__c>>();
        for (Engagement_Counterparty__c ecp: engagementCounterparties.values()){
            if (!oppsToEgmtCounterparties.containsKey(ecp.Engagement__r.Opportunity__c)){
                oppsToEgmtCounterparties.put(ecp.Engagement__r.Opportunity__c, new List<Engagement_Counterparty__c>{ecp});
           }
           else {
                oppsToEgmtCounterparties.get(ecp.Engagement__r.Opportunity__c).add(ecp);
           }
        }
        // query the object relationship record and associated field mappings
        String Context_Relationship_Id_text;
        Map<String, Schema.SObjectField> opportunityCCFields;
        Map<String, Schema.SObjectField> engagementCCFields;
        if(typeofObj == 'Engagement_Counterparty_Contact__c'){
            Context_Relationship_Id_text = 'Opportunity_Counterparty_Contact__c';
            opportunityCCFields = Opportunity_Counterparty_Contact__c.getSObjectType().getDescribe().fields.getMap();
            engagementCCFields = Engagement_Counterparty_Contact__c.getSObjectType().getDescribe().fields.getMap();
        }           
        else if(typeofObj == 'Engagement_Counterparty_Comment__c'){
            Context_Relationship_Id_text = 'Opportunity_Counterparty_Comment__c';
            opportunityCCFields = Opportunity_Counterparty_Comment__c.getSObjectType().getDescribe().fields.getMap();
            engagementCCFields = Engagement_Counterparty_Comment__c.getSObjectType().getDescribe().fields.getMap();
        }

        Map<String, String> fieldNames = new Map<String, String>();
        
        for(SL_Convert__Field_Mapping__c objFM : [SELECT SL_Convert__Context_Field_Name__c,
                                                         SL_Convert__Target_Field_Name__c
                                                        FROM SL_Convert__Field_Mapping__c 
                                                        WHERE SL_Convert__Active__c = true 
                                                         AND SL_Convert__Object_Relationship__r.SL_Convert__Context_Relationship_Id__c =: Context_Relationship_Id_text
                                                         AND SL_Convert__Object_Relationship__r.SL_Convert__Target_Parent_Id__c = 'Engagement_Counterparty__c.Engagement__r.Opportunity__c']){
            if(objFM.SL_Convert__Context_Field_Name__c != null 
                && objFM.SL_Convert__Context_Field_Name__c != '' 
                && objFM.SL_Convert__Target_Field_Name__c != null 
                && objFM.SL_Convert__Target_Field_Name__c != ''
                && opportunityCCFields.keySet().contains(objFM.SL_Convert__Context_Field_Name__c.toLowerCase())
                && engagementCCFields.keySet().contains(objFM.SL_Convert__Target_Field_Name__c.toLowerCase())){
                fieldNames.put(objFM.SL_Convert__Target_Field_Name__c, objFM.SL_Convert__Context_Field_Name__c);
            }
        } 
        String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
        Set <Id> opps = new Set<Id>(oppsToEgmtCounterparties.keySet());
        if(typeofObj == 'Engagement_Counterparty_Contact__c'){
            strQuery = 'SELECT Id, Counterparty__r.Opportunity__c, Counterparty__r.Company__c' + strQuery + ' FROM Opportunity_Counterparty_Contact__c WHERE Counterparty__r.Opportunity__c IN :opps'; 
        
            // query the opportunity Counterparty Contacts
            List <Engagement_Counterparty_Contact__c> newEgmtCounterpartyContacts = 
                        generateNewEgmtCCs((List<Opportunity_Counterparty_Contact__c>)Database.query(strQuery), fieldNames, engagementCounterparties, oppsToEgmtCounterparties);
    system.debug(newEgmtCounterpartyContacts);
            if (!newEgmtCounterpartyContacts.isEmpty()){
                insert newEgmtCounterpartyContacts;
            }
        }
        
        else if(typeofObj == 'Engagement_Counterparty_Comment__c'){
            strQuery = 'SELECT Id, Related_Opportunity_Counterparty__r.Opportunity__c, Related_Opportunity_Counterparty__r.Company__c' + strQuery + ' FROM Opportunity_Counterparty_Comment__c WHERE Related_Opportunity_Counterparty__r.Opportunity__c IN :opps';
            
            // query the opportunity Counterparty Comments
           List <Engagement_Counterparty_Comment__c> newEgmtCounterpartyComments = 
                        generateNewEgmtCComments((List<Opportunity_Counterparty_Comment__c>)Database.query(strQuery), fieldNames, engagementCounterparties, oppsToEgmtCounterparties);
    
            if (!newEgmtCounterpartyComments.isEmpty()){
                insert newEgmtCounterpartyComments; 
            }
        }
    }
    
    /*
        * MethodName        : cloneEngagementCounterpartyContacts
        * param             : Map<Id, Engagement_Counterparty__c>engagementCounterparties 
        * Description       : This function accepts the cloned counterparties and inserts their counterparty contacts
    */
    private static void cloneEngagementCounterpartyContacts(Map<Id, Engagement_Counterparty__c> engagementCounterparties){
        Map<Id, List<Engagement_Counterparty__c>> egmtToEgmtCounterparties = new Map<Id, List<Engagement_Counterparty__c>>();
        for (Engagement_Counterparty__c ecp: engagementCounterparties.values()){
            if (!egmtToEgmtCounterparties.containsKey(ecp.Engagement__r.Engagement__c)){
                egmtToEgmtCounterparties.put(ecp.Engagement__r.Engagement__c, new List<Engagement_Counterparty__c>{ecp});
            }
           else {
                egmtToEgmtCounterparties.get(ecp.Engagement__r.Engagement__c).add(ecp);
            }
        }

        // query the object relationship record and associated field mappings

        Map<String, String> fieldNames = new Map<String, String>();
        Map<String, Schema.SObjectField> engagementCCFields = Engagement_Counterparty_Contact__c.getSObjectType().getDescribe().fields.getMap();
        for(SL_Convert__Field_Mapping__c objFM : [SELECT SL_Convert__Context_Field_Name__c,
                                                         SL_Convert__Target_Field_Name__c
                                                        FROM SL_Convert__Field_Mapping__c 
                                                       WHERE SL_Convert__Active__c = true 
                                                         AND SL_Convert__Object_Relationship__r.SL_Convert__Context_Relationship_Id__c = 'Engagement_Counterparty_Contact__c'
                                                         AND SL_Convert__Object_Relationship__r.SL_Convert__Target_Parent_Id__c = 'Engagement_Counterparty__c.Engagement__r.Engagement__c']){
            if(objFM.SL_Convert__Context_Field_Name__c != null 
                && objFM.SL_Convert__Context_Field_Name__c != '' 
                && objFM.SL_Convert__Target_Field_Name__c != null 
                && objFM.SL_Convert__Target_Field_Name__c != ''
                && engagementCCFields.keySet().contains(objFM.SL_Convert__Target_Field_Name__c.toLowerCase())){
                fieldNames.put(objFM.SL_Convert__Target_Field_Name__c, objFM.SL_Convert__Context_Field_Name__c);
            }
        } 
        String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
        Set <Id> egmts  = new Set<Id>(egmtToEgmtCounterparties.keySet());

        
        strQuery = 'SELECT Id, Counterparty__r.Engagement__c, Counterparty__r.Company__c' + strQuery + ' FROM Engagement_Counterparty_Contact__c WHERE Counterparty__r.Engagement__c IN :egmts'; 

        // query the opportunity Counterparty Contacts
        List <Engagement_Counterparty_Contact__c> newEgmtCounterpartyContacts = 
                    generateNewEgmtCCs((List<Engagement_Counterparty_Contact__c>)Database.query(strQuery), fieldNames, engagementCounterparties, egmtToEgmtCounterparties);

        if (!newEgmtCounterpartyContacts.isEmpty()){
            insert newEgmtCounterpartyContacts;
        }
    }
    
    // This method is for scenario when Engagement is getting converted from Opportunity
    private static List <Engagement_Counterparty_Contact__c> 
                generateNewEgmtCCs (List<Opportunity_Counterparty_Contact__c> oppCCs, 
                                    Map<String, String> fieldNames,
                                    Map<Id, Engagement_Counterparty__c> engagementCounterparties,
                                    Map<Id, List<Engagement_Counterparty__c>> oppsToEgmts){

        Map<String, Schema.SObjectField> eccFields = Engagement_Counterparty_Contact__c.sObjectType.getDescribe().fields.getMap();          
        List <Engagement_Counterparty_Contact__c> newECCs = new List <Engagement_Counterparty_Contact__c>();
        for (Opportunity_Counterparty_Contact__c oppCC: oppCCs){
            Engagement_Counterparty_Contact__c newECC = new Engagement_Counterparty_Contact__c();
            for (Engagement_Counterparty__c potentialParty: oppsToEgmts.get(oppCC.Counterparty__r.Opportunity__c)){
                if (oppCC.Counterparty__r.Company__c==potentialParty.Company__c){
                    newEcc.Counterparty__c = potentialParty.Id;
                }
            }
            for (String targetField: fieldNames.keySet()){
                newEcc = (Engagement_Counterparty_Contact__c) fieldTypeCasting(newEcc, eccFields, (String) oppcc.get(fieldNames.get(targetField)), targetField);
            }
            newEccs.add(newEcc);
        }
        return newEccs;
    }
    
    // This method is for scenario when Engagement is getting converted from Opportunity. 
    private static List <Engagement_Counterparty_Comment__c> 
                generateNewEgmtCComments (List<Opportunity_Counterparty_Comment__c> oppCCs, 
                                    Map<String, String> fieldNames,
                                    Map<Id, Engagement_Counterparty__c> engagementCounterparties,
                                    Map<Id, List<Engagement_Counterparty__c>> oppsToEgmts){

        Map<String, Schema.SObjectField> eccFields = Engagement_Counterparty_Comment__c.sObjectType.getDescribe().fields.getMap();          
        List <Engagement_Counterparty_Comment__c> newECCs = new List <Engagement_Counterparty_Comment__c>();
        for (Opportunity_Counterparty_Comment__c oppCC: oppCCs){
            Engagement_Counterparty_Comment__c newECC = new Engagement_Counterparty_Comment__c();
            for (Engagement_Counterparty__c potentialParty: oppsToEgmts.get(oppCC.Related_Opportunity_Counterparty__r.Opportunity__c)){
                if (oppCC.Related_Opportunity_Counterparty__r.Company__c==potentialParty.Company__c){
                    newEcc.Related_Engagement_Counterparty__c = potentialParty.Id;
                }
            }
            for (String targetField: fieldNames.keySet()){
                newEcc = (Engagement_Counterparty_Comment__c) fieldTypeCasting(newEcc, eccFields, String.valueof(oppcc.get(fieldNames.get(targetField))), targetField);
            }
            newEccs.add(newEcc);
        }
        return newEccs;
    }
    
    // This method is for scenario when Engagement is getting clonned. 
    private static List <Engagement_Counterparty_Contact__c> 
                generateNewEgmtCCs (List<Engagement_Counterparty_Contact__c> engCCs, 
                                    Map<String, String> fieldNames,
                                    Map<Id, Engagement_Counterparty__c> engagementCounterparties,
                                    Map<Id, List<Engagement_Counterparty__c>> egmtsToEgmts){

        Map<String, Schema.SObjectField> eccFields = Engagement_Counterparty_Contact__c.sObjectType.getDescribe().fields.getMap();          
        List <Engagement_Counterparty_Contact__c> newECCs = new List <Engagement_Counterparty_Contact__c>();
        for (Engagement_Counterparty_Contact__c engCC: engCCs){
            Engagement_Counterparty_Contact__c newECC = new Engagement_Counterparty_Contact__c();
            for (Engagement_Counterparty__c potentialParty: egmtsToEgmts.get(engCC.Counterparty__r.Engagement__c)){
                if (engCC.Counterparty__r.Company__c==potentialParty.Company__c){
                    newEcc.Counterparty__c = potentialParty.Id;
                }
            }
            for (String targetField: fieldNames.keySet()){
                newEcc = (Engagement_Counterparty_Contact__c) fieldTypeCasting(newEcc, eccFields, (String) engCC.get(fieldNames.get(targetField)), targetField);
            }
            newEccs.add(newEcc);
        }
        return newEccs;
    }

    /*!
        * MethodName : fieldTypeCasting
        * param      :     
        * Description: This method is called to do the type casting.
    */
   private static Sobject fieldTypeCasting(Sobject sObjTarget, Map<String, Schema.SObjectField> mapFieldDef, String fieldValue, String TargetFieldAPIName)
   {
        try
        {
            if(TargetFieldAPIName != null && TargetFieldAPIName != '' && mapFieldDef.containsKey(TargetFieldAPIName) && mapFieldDef.get(TargetFieldAPIName) != null)
            {
                Schema.SObjectField field = mapFieldDef.get(TargetFieldAPIName);
                Schema.DisplayType fieldType = field.getDescribe().getType();
                if(field.getDescribe().isCreateable() && fieldValue != null && fieldValue != '')
                {
                    if ((fieldType == Schema.DisplayType.DOUBLE) || (fieldType == Schema.DisplayType.CURRENCY) || (fieldType == Schema.DisplayType.PERCENT))
                    {
                        // Validating field is double or not else giving custom exception
                        if(fieldValue.remove('.').isNumeric())  
                            sObjTarget.put(TargetFieldAPIName,double.valueOf(fieldValue));
                        else
                            sObjTarget.addError('Incorrect value for decimal field');
                    }
                    else if (fieldType == Schema.DisplayType.BOOLEAN)
                        sObjTarget.put(TargetFieldAPIName,Boolean.valueOf(fieldValue));
                    else if (fieldType == Schema.DisplayType.INTEGER)
                        sObjTarget.put(TargetFieldAPIName,Integer.valueOf(fieldValue));
                    else if (fieldType == Schema.DisplayType.Date)
                    {
                        //Replacing '-' to '/'. Date.Parse() method take string in a specific format which takes '/' 
                        List<String> lstDate = new List<String>();
                        fieldValue = fieldValue.replace('00:00:00', '').replaceAll('-', '/').trim();
                        lstDate.addAll(fieldValue.split('/'));
                        Integer intYear = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[0]) :  Integer.valueOf(lstDate[2]);  
                        Integer intMonth = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[1]): Integer.valueOf(lstDate[0]);
                        Integer intDate = (lstDate[0].length() == 4) ? Integer.valueOf(lstDate[2]): Integer.valueOf(lstDate[1]);
                        
                        sObjTarget.put(TargetFieldAPIName, Date.newinstance(intYear,intMonth,intDate));
                    }
                    else if (fieldType == Schema.DisplayType.Id)
                    {
                        sObjTarget.put(TargetFieldAPIName,Id.valueOf(fieldValue));
                    }
                    else if(fieldType == Schema.DisplayType.DateTime)
                    {
                        fieldValue = fieldValue.replaceAll('/','-');
                        if(fieldValue.split('/')[0].length() == 4)
                        {
                            List<String> lstDate = new List<String>();
                            String strDate = fieldValue.split(' ')[0];
                            String strTime = (fieldValue.split(' ').size() > 1) ? fieldValue.split(' ')[1] : '00:00:00';
                            lstDate.addAll(strDate.split('-'));
                            fieldValue = lstDate[2] + '-' + lstDate[0] + '-' + lstDate[1] + ' ' + strTime;
                        }
                        
                        sObjTarget.put(TargetFieldAPIName,DateTime.valueOf(fieldValue));
                    }
                    else  { // Checking with field length and populating string with accommodate size
                        sObjTarget.put(TargetFieldAPIName,String.valueOf(fieldValue).length() > field.getDescribe().getLength() ? String.valueOf(fieldValue).substring(0,field.getDescribe().getLength()) :String.valueOf(fieldValue));      
                    }
                }
            }
            
        }
        catch(Exception ex)
        {
            sObjTarget.addError(''+ ex.getMessage());
        }
        return sObjTarget;
   }
    /* End */

    /*
        * MethodName        : populateRecordType
        * param             : List<Engagement__c> engagements
        * Description       : This accepts a list of Engagements and populates their Record Types
    */
    public static void populateRecordType(List <Engagement__c> engagements){
        Set<Id> OppIds = new Set<Id>();
        for (Engagement__c eng: engagements){
            OppIds.add(eng.Opportunity__c);
        }
        OppIds.remove(null);
        Map<Id, String> oppIdToJobType = new Map<Id, String>(); 
        for (Opportunity__c opp: [SELECT Id, Job_Type__c FROM Opportunity__c WHERE Id IN :OppIds]){
            oppIdToJobType.put(opp.Id, opp.Job_Type__c);
        }

        for(Engagement__c objInsertedEng : engagements) {
            if (objInsertedEng.Engagement__c==null){
                objInsertedEng.RecordTypeId = getRecordType(oppIdToJobType.get(objInsertedEng.Opportunity__c));
            }       
        }
    }
    /*
        * MethodName        : getRecordType
        * param             : String jobType
        * Description       : This accepts the jobType of the associated opportunity and returns the appropriate
                                Engagement record type ID
        2019-12-06 - Nara   : Added Job Type: FA - Portfolio LIBOR Advisory for Portfolio Valuation   
        2020-11-09 - Guru   : Add a new Job Type - "Discretionary Advisory" for Advisory CF for DMND0024751                    
    */
    private static Id getRecordType(String jobType){
        if (jobType=='Activism Advisory')
            return developerNameToID.get('Activism_Advisory');
        if(jobType=='Buyside'
            ||jobType=='Special Situations Buyside' )
            return developerNameToID.get('Buyside');
        if(jobType=='Corporate Alliances'
            ||jobType=='Exclusive Sale'
            ||jobType=='Going Private'
            ||jobType=='Merger'
            ||jobType=='Sellside'
            ||jobType=='Special Situations Sellside')
            return developerNameToID.get('Sellside');
        if(jobType=='Illiquid Financial Assets'
          ||jobType=='Tech+IP - Patent Sales'
          ||jobType=='Tech+IP - Tech+IP Sales'
          ||jobType=='Tech+IP - Buyside')
            return developerNameToID.get('Illiquid_Financial_Assets');
        if(jobType=='Debt Capital Markets'
            ||jobType=='Equity Capital Markets'
            ||jobType=='Financing'
            ||jobType=='Liability Management'
            ||jobType=='Partners'
            ||jobType=='Buyside & Financing Advisory'
            ||jobType=='Private Funds: Primary Advisory'
            ||jobType=='Private Funds: Secondary Advisory'
            ||jobType=='Private Funds: GP Stake Sale'
            ||jobType=='Private Funds: GP Advisory'
            ||jobType=='Syndicated Finance')
            return developerNameToID.get('Capital_Markets');
        if(jobType=='Negotiated Fairness')
            return developerNameToID.get('Fairness_CF');
        if(jobType=='ESOP Fairness'
            ||jobType=='Fairness')
            return developerNameToID.get('Fairness_FAS');
        if(jobType=='ESOP Capital Partnership'
            ||jobType=='ESOP Advisory'
            ||jobType=='Collateral Valuation'
            ||jobType=='Compensation/Formula Analysis'
            ||jobType=='Consulting'
            ||jobType=='ESOP Update'
            ||jobType=='Estate & Gift Tax'
            ||jobType=='FMV Non-Transaction Based Opinion'
            ||jobType=='Income Deposit Securities'
            ||jobType=='InSource'
            ||jobType=='Securities Design'
            ||jobType=='FA - Fund Opinions-Valuation'
            ||jobType=='FA - Fund Opinions-Transaction'
            ||jobType=='FA - Fund Opinions-Fairness'
            ||jobType=='FA - Fund Opinions-Non-Fairness')
            return developerNameToID.get('Other_FAS');
        if(jobType=='FA - Portfolio-Advis/Consulting'
            ||jobType=='FA - Portfolio-Auto Loans'
            ||jobType=='FA - Portfolio-Auto Struct Prd'
            ||jobType=='FA - Portfolio-Deriv/Risk Mgmt'
            ||jobType=='FA - Portfolio-Diligence/Assets'
            ||jobType=='FA - Portfolio-GP Interest'
            ||jobType=='FA - Portfolio-Real Estate'
            ||jobType=='FA - Portfolio-Valuation'
            ||jobType=='FA - Portfolio - SPAC'
            ||jobType=='FA - Portfolio-Funds Transfer'
            ||jobType=='FA - Portfolio LIBOR Advisory'
            ||jobType=='FA - Portfolio-BDC/Direct Lending')
            return developerNameToID.get('Portfolio_Valuation');
        if(jobType=='DRC - Exp Cons-Arbitrat\'n'
            ||jobType=='DRC - Exp Cons-Bankruptcy'
            ||jobType=='DRC - Exp Cons-Litigation'
            ||jobType=='DRC - Exp Cons-Mediation'
            ||jobType=='DRC - Exp Cons-Pre-Complt'
            ||jobType=='DRC - Exp Wit-Arbitration'
            ||jobType=='DRC - Exp Wit-Bankruptcy'
            ||jobType=='DRC - Exp Wit-Litigation'
            ||jobType=='DRC - Exp Wit-Mediation'
            ||jobType=='DRC - Exp Wit-Pre-Complnt'
            ||jobType=='DRC - Appointed Arbitrator/Mediator'
            ||jobType=='DRC - Ad Valorem Services'
            ||jobType=='DRC - Contract Compliance'
            ||jobType=='DRC - Post Transaction Dispute'
            ||jobType=='Litigation')
            return developerNameToID.get('Litigation');
        if(jobType=='Solvency')
            return developerNameToID.get('Solvency');
        if(jobType== 'Tech+IP - Patent Acquisition Support')
                return developerNameToID.get('Tech_IP_Advisory');
      /*  if(jobType== 'T+IP - Expert Report')
                return developerNameToID.get('T_IP_Expert_Report'); */
        if(jobType== 'Tech+IP - Strategic Advisory')
                return developerNameToID.get('T_IP_Patent_Strategy');
        if(jobType== 'Tech+IP - Valuation')
                return developerNameToID.get('T_IP_Patent_Valuation');
        if(jobType=='CVAS - Forensic Services'
            ||jobType=='CVAS - FV Opinion'
            ||jobType=='CVAS - Goodwill or Asset Impairment'
            ||jobType=='CVAS - Purchase Price Allocation'
            ||jobType=='CVAS - SFAS 123R/409A Stock, Option Valuation'
            ||jobType=='CVAS - SFAS 133 Derivatives, Liabilities Valuation'
            ||jobType=='CVAS - Sovereign Advisory'
            ||jobType=='CVAS - Tangible Asset Valuation'
            ||jobType=='CVAS - Tax Valuation'
            ||jobType=='CVAS - Transfer Pricing'
            ||jobType=='CVAS - Pre-Acq Val\'n Cons')
            return developerNameToID.get('TFR_TAX_and_Financial_Reporting');
        if(jobType=='TAS - Due Diligence Services'
            ||jobType=='TAS - Tax'
            ||jobType=='TAS - Lender Services'
            ||jobType=='TAS - Accounting and Financial Reporting Advisory'
            ||jobType=='TAS - Due Diligence-Sellside'
            ||jobType=='TAS - Due Diligence-Buyside'
            ||JobType=='TAS - DVC Business Analytics'
            ||JobType=='TAS - DVC Decision Modeling')
            return developerNameToID.get('TAS_Due_Diligence_Services');
        if(jobType=='Creditor Advisors'
            ||jobType=='Debtor Advisors'
            ||jobType=='Equity Advisors'
            ||jobType=='PBAS'
            ||jobType=='Sovereign Restructuring'
            ||jobType=='Portfolio Acquisition'
            ||jobType=='DM&A Buyside'
            ||jobType=='DM&A Sellside'
            ||jobType=='Liability Mgmt'
            ||jobType=='Regulator/Other')
            return developerNameToID.get('Restructuring');
        if(jobType=='Strategic Consulting')
            return developerNameToID.get('Strategic_Consulting');
        if(jobType=='FMV Transaction Based Opinion'
            ||jobType=='Board Advisory Services (BAS)')
            return developerNameToID.get('Transaction_Opinion');
        if(jobType=='Discretionary Advisory'
            ||jobType=='General Financial Advisory'
            ||jobType=='Strategy'
            ||jobType=='Post Merger Integration'
            ||jobType=='Valuation Advisory')
            return developerNameToID.get('Advisory_CF');
        return developerNameToID.get('Advisory_CF');
    }   
    /*
        * MethodName        : cloneEngagementCounterpartyContacts
        * param             : Map<Id, Engagement_Counterparty__c>engagementCounterparties 
        * Description       : This function accepts the cloned counterparties and inserts their counterparty contacts
    */  
    static Map<String, Schema.SObjectField> OppVPPosFields;
    static Map<String, Schema.SObjectField> EngVPPosFields;
    static Map<String, Schema.SObjectField> OppVpTeamMemberFields;
    static Map<String, Schema.SObjectField> EngVPTeamMemberFields;
    static Map<String, map<String, String>> AllFieldNamesMap;
    
    public static void ConvertOppVPs(Id EngagementId, Id OpportunityId){        
        // query the object relationship record and associated field mappings
        String Context_Relationship_Id_text = 'Opp_VP__c'; 
        Map<String, Set<String>> SrcObjFIeldSetMap = new Map<String, Set<String>>();
        Map<String, Set<String>> TrgtObjFIeldSetMap = new Map<String, Set<String>>();
        Map<String, Schema.SObjectField> OppVPfields = Opp_VP__c.getSObjectType().getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> EngVPFields = Eng_VP__c.getSObjectType().getDescribe().fields.getMap();
        
        OppVPPosFields = Opp_VP_Position__c.getSObjectType().getDescribe().fields.getMap();
        EngVPPosFields = Eng_VP_Position__c.getSObjectType().getDescribe().fields.getMap();
        
        OppVpTeamMemberFields = Opp_VP_TeamMember__c.getSObjectType().getDescribe().fields.getMap();
        EngVPTeamMemberFields = Eng_VP_TeamMember__c.getSObjectType().getDescribe().fields.getMap();
        SrcObjFIeldSetMap.put('Opp_VP__c', OppVPfields.KeySet());
        SrcObjFIeldSetMap.put('Opp_VP_Position__c', OppVPPosFields.KeySet());
        SrcObjFIeldSetMap.put('Opp_VP_TeamMember__c', OppVpTeamMemberFields.KeySet());
        
        TrgtObjFIeldSetMap.put('Opp_VP__c', EngVPFields.KeySet());
        TrgtObjFIeldSetMap.put('Opp_VP_Position__c', EngVPPosFields.KeySet());
        TrgtObjFIeldSetMap.put('Opp_VP_TeamMember__c', EngVPTeamMemberFields.KeySet());
        
        AllFieldNamesMap = new  Map<String, map<String, String>>();
        Map<String, String> fieldNames = new Map<String, String>();   
        List<String> Context_Relationship_Id_text_List = new List<String>{'Opp_VP__c', 'Opp_VP_Position__c', 'Opp_VP_TeamMember__c'};
        AllFieldNamesMap = buildFieldMap(Context_Relationship_Id_text_List,SrcObjFIeldSetMap , TrgtObjFIeldSetMap);
        fieldNames = (AllFieldNamesMap.containsKey(Context_Relationship_Id_text)? AllFieldNamesMap.get(Context_Relationship_Id_text):new Map<String, String>());
        
        String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
        Map <Id, Id> oppMap = new map<Id,Id>();  
        Set<Id> OppIdSet = new set<Id>();
        //for(Engagement__c Engg : EngagementList)//[Select Id, Opportunity__c FROM Engagement__c Where Id IN: EngagementIdSet])
        //{   
            oppMap.put(OpportunityId, EngagementId);
            OppIdSet.add(OpportunityId);
        //}    
        strQuery = 'SELECT Id, Opportunity__c  ' + strQuery + ' FROM Opp_VP__c WHERE IsConverted__c = False AND Opportunity__c IN : OppIdSet Limit 1';
                
        //List <Eng_VP__c> newEngVPs = new List <Eng_VP__c>();
        Eng_VP__c EngVP;
        map<Id, Eng_VP__c> OppVPTOEngVPMap = new map<Id, Eng_VP__c>();
        Opp_VP__c OppVpToUpdate = new Opp_VP__c();
        for (Opp_VP__c OppVp: (List<Opp_VP__C>)Database.query(strQuery)){
            OppVpToUpdate = OppVp; 
            EngVP = new Eng_VP__c();
            EngVP.Engagement__c = oppMap.get(OppVp.Opportunity__c);
            for (String targetField: fieldNames.keySet())
            {
                EngVP = (Eng_VP__c) fieldTypeCasting(EngVP, EngVPFields, String.valueof(OppVp.get(fieldNames.get(targetField))), targetField);
            }
            //newEngVPs.add(EngVP);
            OppVPTOEngVPMap.put(OppVp.Id,EngVP);
        }
        
        if (!OppVPTOEngVPMap.Values().isEmpty())
        {
            insert OppVPTOEngVPMap.Values();
            // To stop copying Company's name in to Position Name
            HL_ConstantsUtil.stopCopyingNameFromCompToPosition = true;
            // To stop unnecessary execution
            HL_ConstantsUtil.stopExecutionForPVConversion = true;
                ConvertOppVPPositions(OppVPTOEngVPMap); 
                OppVpToUpdate.IsConverted__c = True;
                Update OppVpToUpdate;
            HL_ConstantsUtil.stopCopyingNameFromCompToPosition = false; 
            HL_ConstantsUtil.stopExecutionForPVConversion = false;
        }
    }
    
    public static void ConvertOppVPPositions(map<Id, Eng_VP__c> OppVPToEngVPMap){        
        // query the object relationship record and associated field mappings
        String Context_Relationship_Id_text = 'Opp_VP_Position__c';        
        //Map<String, Schema.SObjectField> OppVPPosFields = Opp_VP_Position__c.getSObjectType().getDescribe().fields.getMap();
        //Map<String, Schema.SObjectField> EngVPPosFields = Eng_VP_Position__c.getSObjectType().getDescribe().fields.getMap();
        
        Map<String, String> fieldNames = new Map<String, String>();        
        //fieldNames = buildFieldMap(Context_Relationship_Id_text,OppVPPosFields.KeySet() , EngVPPosFields.KeySet() );
        fieldNames = (AllFieldNamesMap.containsKey(Context_Relationship_Id_text)? AllFieldNamesMap.get(Context_Relationship_Id_text):new Map<String, String>());
        String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
        Set<Id> OppVPIdSet = new set<Id>();
        OppVPIdSet = OppVPToEngVPMap.KeySet(); 
        strQuery = 'SELECT Id, Opportunity_VP__c  ' + strQuery + ' FROM Opp_VP_Position__c WHERE Opportunity_VP__c IN : OppVPIdSet ';
                
        Eng_VP_Position__c EngVPPos;
        map<Id, Eng_VP_Position__c> OppVPPosTOEngVPPosMap = new map<Id, Eng_VP_Position__c>();
        system.debug('--fieldNames--'+fieldNames);
        for (Opp_VP_Position__c OppVpPos: (List<Opp_VP_Position__c>)Database.query(strQuery)){
            EngVPPos = new Eng_VP_Position__c();
            EngVPPos.Engagement_VP__c = OppVPTOEngVPMap.get(OppVpPos.Opportunity_VP__c).Id;
            for (String targetField: fieldNames.keySet())
            {
               EngVPPos = (Eng_VP_Position__c) fieldTypeCasting(EngVPPos, EngVPPosFields, String.valueof(OppVpPos.get(fieldNames.get(targetField))), targetField);
            }
            OppVPPosTOEngVPPosMap.put(OppVpPos.id, EngVPPos);
        }
        
        if (!OppVPPosTOEngVPPosMap.Values().isEmpty()){
            insert OppVPPosTOEngVPPosMap.Values(); 
        }
        ConvertOppVPTeamMembers(OppVPPosTOEngVPPosMap);
    }
    
    public static void ConvertOppVPTeamMembers(map<Id, Eng_VP_Position__c> OppVPToEngVPTeamMemberMap){        
        // query the object relationship record and associated field mappings
        String Context_Relationship_Id_text = 'Opp_VP_TeamMember__c';        
        //Map<String, Schema.SObjectField> OppVpTeamMemberFields = Opp_VP_TeamMember__c.getSObjectType().getDescribe().fields.getMap();
        //Map<String, Schema.SObjectField> EngVPTeamMemberFields = Eng_VP_TeamMember__c.getSObjectType().getDescribe().fields.getMap();
        
        Map<String, String> fieldNames = new Map<String, String>();        
        //fieldNames = buildFieldMap(Context_Relationship_Id_text,OppVpTeamMemberFields.KeySet() , EngVPTeamMemberFields.KeySet() );
        fieldNames = (AllFieldNamesMap.containsKey(Context_Relationship_Id_text)? AllFieldNamesMap.get(Context_Relationship_Id_text):new Map<String, String>());
        
        String strQuery = !fieldNames.isEmpty() ? ', ' + String.join(fieldNames.values(), ', ') : '';
         
        Set<Id> OppVpTeamMemberitionIdSet = new set<Id>();
        OppVpTeamMemberitionIdSet = OppVPToEngVPTeamMemberMap.KeySet(); 
        strQuery = 'SELECT Id, Opportunity_VP_Position__c  ' + strQuery + ' FROM Opp_VP_TeamMember__c WHERE Opportunity_VP_Position__c IN : OppVpTeamMemberitionIdSet AND End_Date__c = Null';
                
        List <Eng_VP_TeamMember__c> newEngVPTeamMembers = new List <Eng_VP_TeamMember__c>();
        Eng_VP_TeamMember__c EngVPTeamMember;
        
        for (Opp_VP_TeamMember__c OppVpTeamMember: (List<Opp_VP_TeamMember__c>)Database.query(strQuery)){
            EngVPTeamMember = new Eng_VP_TeamMember__c();
            EngVPTeamMember.Engagement_VP_Position__c = OppVPToEngVPTeamMemberMap.get(OppVpTeamMember.Opportunity_VP_Position__c).Id;
            for (String targetField: fieldNames.keySet())
            {
                EngVPTeamMember = (Eng_VP_TeamMember__c) fieldTypeCasting(EngVPTeamMember, EngVPTeamMemberFields, String.valueof(OppVpTeamMember.get(fieldNames.get(targetField))), targetField);
            }
            newEngVPTeamMembers.add(EngVPTeamMember);
        }
        
        if (!newEngVPTeamMembers.isEmpty()){
            insert newEngVPTeamMembers; 
        }
    }
    
    private static Map<String, Map<String, String>> buildFieldMap(List<String> Context_Relationship_Id_text_List, map<String, Set<String>> sourceObjFieldSet, Map<String, Set<String>> targetObjFieldSet)
    {
        Map<String, String> fieldNames;
        Map<String, Map<String, String>>  MainfieldNamesMap = new Map<String, Map<String, String>>();        
        for(SL_Convert__Object_Relationship__c objRL : [ SELECT Id,SL_Convert__Context_Relationship_Id__c, (SELECT SL_Convert__Context_Field_Name__c,  SL_Convert__Target_Field_Name__c
                                                         FROM SL_Convert__Field_Mappings__r 
                                                         WHERE SL_Convert__Active__c = true) FROM SL_Convert__Object_Relationship__c WHERE SL_Convert__Context_Relationship_Id__c IN: Context_Relationship_Id_text_List])
        {
            fieldNames = new Map<String, String>();
            for(SL_Convert__Field_Mapping__c objFM : objRL.SL_Convert__Field_Mappings__r){              
                if(objFM.SL_Convert__Context_Field_Name__c != null   && objFM.SL_Convert__Context_Field_Name__c != '' 
                        && objFM.SL_Convert__Target_Field_Name__c != null    && objFM.SL_Convert__Target_Field_Name__c != ''
                        && sourceObjFieldSet.get(objRL.SL_Convert__Context_Relationship_Id__c).contains(objFM.SL_Convert__Context_Field_Name__c.toLowerCase())
                        && targetObjFieldSet.get(objRL.SL_Convert__Context_Relationship_Id__c).contains(objFM.SL_Convert__Target_Field_Name__c.toLowerCase()))
                {
                        fieldNames.put(objFM.SL_Convert__Target_Field_Name__c, objFM.SL_Convert__Context_Field_Name__c);
                }
            }
            MainfieldNamesMap.put(objRL.SL_Convert__Context_Relationship_Id__c,fieldNames);         
        }        
        return MainfieldNamesMap;
    }  
}