public with sharing class HL_OffsiteTemplate {
    public static List<Offsite_Template__c> PopulateSnapshotData(List<Offsite_Template__c> offsiteTemplateList){
        Set<Id> coverageTeamIdSet = new Set<Id>();
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList)
        {
            if(String.isBlank(offsiteTemplateRecord.Legacy_SLX_ID__c))
                coverageTeamIdSet.add(offsiteTemplateRecord.Coverage_Team__c);
        }
        
        if(coverageTeamIdSet.size() > 0){
            Map<Id, Coverage_Team__c> coverageTeamMap = HL_CoverageTeam.GetCoverageTeams(coverageTeamIdSet);
            Integer month = Date.Today().month();
            Integer year = Date.Today().year() + (month > 3 ? 1 : 0);
            
            for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList)
            {
                Coverage_Team__c coverageTeamRecord = coverageTeamMap.get(offsiteTemplateRecord.Coverage_Team__c);
                offsiteTemplateRecord.City__c = coverageTeamRecord.Company__r.BillingCity;
                offsiteTemplateRecord.Coverage_Team_Officer__c = coverageTeamRecord.Officer__r.Name;
                offsiteTemplateRecord.Coverage_Team_Officer_ID__c = coverageTeamRecord.Officer__c;
                offsiteTemplateRecord.Equity_Investment_Size_From__c = coverageTeamRecord.Company__r.CapIQ_Company__r.Equity_Investment_From__c;
                offsiteTemplateRecord.Equity_Investment_Size_To__c = coverageTeamRecord.Company__r.CapIQ_Company__r.Equity_Investment_To__c;
                offsiteTemplateRecord.Fund_Size__c = coverageTeamRecord.Company__r.CapIQ_Company__r.Most_Recent_Fund_Size_MM__c;
                offsiteTemplateRecord.FYE_Date__c = Date.newInstance(year, 3, 31);
                offsiteTemplateRecord.Sponsor__c = coverageTeamRecord.Company__r.CapIQ_Company__c;
                offsiteTemplateRecord.Sponsor_Company__c = coverageTeamRecord.Company__r.CapIQ_Company__r.Name;
                offsiteTemplateRecord.State__c = String.isBlank(coverageTeamRecord.Company__r.BillingState) ? coverageTeamRecord.Company__r.BillingCountry : coverageTeamRecord.Company__r.BillingState;
                offsiteTemplateRecord.Year__c = String.valueOf(year);  
            }
        }
        
        return offsiteTemplateList;
    }
    
    public static List<Offsite_Template__c> CreateRelatedRecords(List<Offsite_Template__c> offsiteTemplateList){
        List<Offsite_Template__c> offsiteTemplateNewList = new List<Offsite_Template__c>();
        
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList)
        {
            if(String.isBlank(offsiteTemplateRecord.Legacy_SLX_ID__c))
                offsiteTemplateNewList.add(offsiteTemplateRecord);
        }
        if(offsiteTemplateNewList.size() > 0)
        {
            CreateRelatedIndustryRecords(offsiteTemplateNewList);
            CreateRelatedInvestmentRecords(offsiteTemplateNewList);
            CreateRelatedCoverageContactRecords(offsiteTemplateNewList);
        }
        return offsiteTemplateNewList;
    }
    
    private static List<Offsite_Template_Industry__c> CreateRelatedIndustryRecords(List<Offsite_Template__c> offsiteTemplateList){
        List<Industry__c> industryList = new List<Industry__c>();
        Set<Id> industryIdSet = new Set<Id>();
        List<Offsite_Template_Industry__c> offsiteIndustryList = new List<Offsite_Template_Industry__c>();
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList)
        {
            if(offsiteTemplateRecord.isClone())
            {
                for(Offsite_Template_Industry__c offsiteTemplateIndustry : [SELECT Offsite_Template__c, Industry__c,Industry__r.Id, Focus__c, Meeting__c 
                                                                            FROM Offsite_Template_Industry__c
                                                                            WHERE Offsite_Template__c =: offsiteTemplateRecord.getCloneSourceId() 
                                                                            AND Industry__r.Active__c = true 
                                                                            AND Industry__r.FSC__c = true])
                {
                    Offsite_Template_Industry__c newOffsiteTemplateIndustryRecord = offsiteTemplateIndustry.clone();
                    newOffsiteTemplateIndustryRecord.Offsite_Template__c = offsiteTemplateRecord.Id;
                    offsiteIndustryList.add(newOffsiteTemplateIndustryRecord);
                    industryIdSet.add(offsiteTemplateIndustry.Industry__r.Id);
                }
                industryList = [SELECT Id FROM Industry__c WHERE Active__c = true AND FSC__c = true AND Id NOT IN: industryIdSet];
            }
            else
            {
                industryList = [SELECT Id FROM Industry__c WHERE Active__c = true AND FSC__c = true];
            }
            for(Industry__c i : industryList)
                offsiteIndustryList.add(new Offsite_Template_Industry__c(Industry__c = i.Id, Offsite_Template__c = offsiteTemplateRecord.Id));
        }
        
        if(offsiteIndustryList.size() > 0)
            insert offsiteIndustryList;
        
        return offsiteIndustryList;
    }
    
    public static List<Offsite_Template_Coverage_Contact__c> HandleInsertedContactRecords(Map<Id, Coverage_Contact__c> coverageContactMap){
        List<Offsite_Template_Coverage_Contact__c> insertList = new List<Offsite_Template_Coverage_Contact__c>();
        Map<Id, List<Coverage_Contact__c>> teamMap = new Map<Id, List<Coverage_Contact__c>>();
        for(Coverage_Contact__c coverageContact : coverageContactMap.values())
        {
            if(teamMap.containsKey(coverageContact.Coverage_Team_Member__c))
            {
                List<Coverage_Contact__c> contacts = teamMap.get(coverageContact.Coverage_Team_Member__c);
                contacts.add(coverageContact);
                teamMap.put(coverageContact.Coverage_Team_Member__c, contacts);
            }
            else
                teamMap.put(coverageContact.Coverage_Team_Member__c, new List<Coverage_Contact__c>{coverageContact});
        }
        
        for(Offsite_Template__c offsiteTemplate : [SELECT Coverage_Team__c FROM Offsite_Template__c WHERE Coverage_Team__c IN : teamMap.keySet() AND Archive__c = false])
        {
            for(Coverage_Contact__c coverageContact : teamMap.get(offsiteTemplate.Coverage_Team__c))
                insertList.add(new Offsite_Template_Coverage_Contact__c(Offsite_Template__c = offsiteTemplate.Id, Coverage_Contact__c = coverageContact.Id, Focus__c = coverageContact.Focus__c, Contact_Name__c = coverageContact.Coverage_Contact_Name_Formula__c));
        }
        
        if(insertList.size() > 0)
            insert insertList;
        
        return insertList;
    }
    
    public static List<Offsite_Template_Investment_Company__c> HandleInsertedInvestmentRecords(Map<Id, Investment__c> investMap){
        List<Offsite_Template_Investment_Company__c> insertList = new List<Offsite_template_Investment_Company__c>();
        Map<Id, List<Investment__c>> sponsorMap = new Map<Id, List<Investment__c>>();
        for(Investment__c i : investMap.values())
        {
            if(sponsorMap.containsKey(i.Sponsor_CapIQ_Company__c))
            {
                List<Investment__c> investments = sponsorMap.get(i.Sponsor_CapIQ_Company__c);
                investments.add(i);
                sponsorMap.put(i.Sponsor_CapIQ_Company__c, investments);
            }
            else
                sponsorMap.put(i.Sponsor_CapIQ_Company__c, new List<Investment__c>{i});
        }
        
        for(Offsite_Template__c offsiteTemplate : [SELECT Sponsor__c FROM Offsite_Template__c WHERE Sponsor__c IN : sponsorMap.keySet() AND Archive__c = false]){
            for(Investment__c i : sponsorMap.get(offsiteTemplate.Sponsor__c))
                insertList.add(UpdateInvestmentCompanyFieldsFromInvestment(new Offsite_Template_Investment_Company__c(Offsite_Template__c = offsiteTemplate.Id), i));
        }
        
        if(insertList.size() > 0)
            insert insertList;
        
        return insertList;
    }
    
    private static Map<Id, Set<Id>> GetSponsorOffsiteMap(List<Offsite_Template__c> offsiteTemplateList){
        Map<Id, Set<Id>> sponsorsToOffsite = new Map<Id,Set<Id>>();
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList){
            if(!String.isBlank(offsiteTemplateRecord.Sponsor__c)){
                if(sponsorsToOffsite.containsKey(offsiteTemplateRecord.Sponsor__c)){
                    Set<Id> offsiteTemplateIdSet = sponsorsToOffsite.get(offsiteTemplateRecord.Sponsor__c);
                    offsiteTemplateIdSet.add(offsiteTemplateRecord.Id);
                    sponsorsToOffsite.put(offsiteTemplateRecord.Sponsor__c, offsiteTemplateIdSet);
                }
                else
                    sponsorsToOffsite.put(offsiteTemplateRecord.Sponsor__c, new Set<Id>{offsiteTemplateRecord.Id});
            }
        }
        
        return sponsorsToOffsite;
    }
    
    private static List<Offsite_Template_Investment_Company__c> CreateRelatedInvestmentRecords(List<Offsite_Template__c> offsiteTemplateList){
        List<Offsite_Template_Investment_Company__c> offsiteInvestmentCompanyList = new List<Offsite_Template_Investment_Company__c>();
        Set<Id> investmentCompanyIdSet = new Set<Id>();
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList){
            if(offsiteTemplateRecord.isClone()){
                for(Offsite_Template_Investment_Company__c osInvestmentCompany : [SELECT Offsite_Template__c, Portfolio_Company__c, Description__c, HL_Industry__c, Industry__c, LTM_MM_EBITDA__c, 
                                                                                  LTM_MM_Revenue__c, Investment_Date__c, Prospect__c, Status__c, Service__c, Sort_Field__c, Include__c, 
                                                                                  Investment_Company__c,Investment_Company__r.Id 
                                                                                  FROM Offsite_Template_Investment_Company__c 
                                                                                  WHERE Offsite_Template__c =: offsiteTemplateRecord.getCloneSourceId()
                                                                                 ])
                {
                    Offsite_Template_Investment_Company__c newOffsiteTemplateCompanyRecord = osInvestmentCompany.clone();
                    newOffsiteTemplateCompanyRecord.Offsite_Template__c = offsiteTemplateRecord.Id;
                    offsiteInvestmentCompanyList.add(newOffsiteTemplateCompanyRecord);
                    investmentCompanyIdSet.add(osInvestmentCompany.Investment_Company__r.Id);
                }
            }
        }
        
        Map<Id, Set<Id>> sponsorsToOffsiteMap = GetSponsorOffsiteMap(offsiteTemplateList);

        for(Investment__c i : [SELECT Name, Amount_of_Investment__c, Date_Sold__c, Description__c,
                               EBITDA_CapIQ__c, EBITDA_HL__c,
                               HL_Industry_Sector__c, HL_Industry_LK__c, HL_Industry_LK__r.Industry_Group__c,
                               HL_Industry_LK__r.Industry_Sector__c, Industry__c, Investment_Date__c, Portfolio_CapIQ_Company__r.Name,
                               Expected_Exit_Date__c, Related_Fund__r.Name, Revenue_CapIQ__c, Revenue_HL__c, Status__c, Sponsor_CapIQ_Company__c,
                               Sponsor_CapIQ_Company__r.Name, Actual_Relationship_Type__c
                               FROM Investment__c
                               WHERE Sponsor_CapIQ_Company__c <> null AND Sponsor_CapIQ_Company__c IN:sponsorsToOffsiteMap.keySet() AND Id NOT IN:investmentCompanyIdSet])
        {
            offsiteInvestmentCompanyList.add(UpdateInvestmentCompanyFieldsFromInvestment(new Offsite_Template_Investment_Company__c(Investment_Company__c = i.Id, Offsite_Template__c = offsiteTemplateList[0].Id),i));
        }

        if(offsiteInvestmentCompanyList.size() > 0)
            insert offsiteInvestmentCompanyList;
        
        return offsiteInvestmentCompanyList;
    }
    
    private static Offsite_Template_Investment_Company__c UpdateInvestmentCompanyFieldsFromInvestment(Offsite_Template_Investment_Company__c offsiteTemplateInvestmentCompany, Investment__c investment){
        offsiteTemplateInvestmentCompany.Description__c = investment.Description__c;
        offsiteTemplateInvestmentCompany.HL_Industry__c = investment.HL_Industry_Sector__c;
        offsiteTemplateInvestmentCompany.Industry__c = investment.Industry__c;
        offsiteTemplateInvestmentCompany.Investment_Company__c = investment.Id;
        offsiteTemplateInvestmentCompany.Investment_Date__c = investment.Investment_Date__c;
        offsiteTemplateInvestmentCompany.LTM_MM_EBITDA__c = investment.EBITDA_HL__c;
        offsiteTemplateInvestmentCompany.LTM_MM_Revenue__c = investment.Revenue_HL__c;
        offsiteTemplateInvestmentCompany.Status__c = investment.Status__c;
        offsiteTemplateInvestmentCompany.Include__c = investment.Status__c == 'Current';
        return offsiteTemplateInvestmentCompany;
    }
    
    private static List<Offsite_Template_Coverage_Contact__c> CreateRelatedCoverageContactRecords(List<Offsite_Template__c> offsiteTemplateList){
        List<Offsite_Template_Coverage_Contact__c> offsiteCoverageContactList = new List<Offsite_Template_Coverage_Contact__c>();
        Map<Id, Set<Id>> sponsorsToOffsiteMap = GetSponsorOffsiteMap(offsiteTemplateList);
        Set<Id> coverageCompanyIdSet = new Set<Id>();
        Set<String> addedRecords = new Set<String>();
        
        for(Offsite_Template__c offsiteTemplateRecord : offsiteTemplateList){
            if(offsiteTemplateRecord.isClone()){
                for(Offsite_Template_Coverage_Contact__c offsiteCoverageContact : [SELECT Coverage_Contact__c,
                                                                                   Name,
                                                                                   CurrencyIsoCode,
                                                                                   Focus__c,
                                                                                   Offsite_Template__c,
                                                                                   Coverage_Contact__r.Coverage_Contact_Name_Formula__c
                                                                                   FROM Offsite_Template_Coverage_Contact__c
                                                                                   WHERE Offsite_Template__c =: offsiteTemplateRecord.getCloneSourceId()
                                                                                  ])
                {
                    offsiteCoverageContact.Contact_Name__c = offsiteCoverageContact.Coverage_Contact__r.Coverage_Contact_Name_Formula__c;
                    Offsite_Template_Coverage_Contact__c newOffsiteCoverageContact = offsiteCoverageContact.clone();
                    newOffsiteCoverageContact.Offsite_Template__c = offsiteTemplateRecord.Id;
                    offsiteCoverageContactList.add(newOffsiteCoverageContact);
                    coverageCompanyIdSet.add(offsiteCoverageContact.Coverage_Contact__c);
                    addedRecords.add(offsiteCoverageContact.Id + '_' + offsiteTemplateRecord.Id);
                }
            }
        }
        
        if(sponsorsToOffsiteMap.size() > 0){
            for(Coverage_Contact__c coverageContactRecord : [SELECT Coverage_Contact__r.Name, Coverage_Team_Member__r.Company__r.CapIQ_Company__c, 
                                                             Focus__c, 
                                                             Coverage_Contact_Name_Formula__c
                                                             FROM Coverage_Contact__c
                                                             WHERE Id NOT IN: coverageCompanyIdSet 
                                                             AND Coverage_Team_Member__r.Company__r.CapIQ_Company__c <> null
                                                             AND Coverage_Team_Member__r.Company__r.CapIQ_Company__c IN : sponsorsToOffsiteMap.keySet()])
            {
                for(Id offsiteTemplateId : sponsorsToOffsiteMap.get(coverageContactRecord.Coverage_Team_Member__r.Company__r.CapIQ_Company__c))
                {
                    if(!addedRecords.contains(coverageContactRecord.Id + '_' + offsiteTemplateId))
                    {
                        offsiteCoverageContactList.add(new Offsite_Template_Coverage_Contact__c(Coverage_Contact__c = coverageContactRecord.Id,
                                                                                                Contact_Name__c = coverageContactRecord.Coverage_Contact_Name_Formula__c,
                                                                                                Focus__c = coverageContactRecord.Focus__c,
                                                                                                Offsite_Template__c = offsiteTemplateId
                                                                                               ));
                        addedRecords.add(coverageContactRecord.Id + '_' + offsiteTemplateId);
                    }
                }
            }
        }

        if(offsiteCoverageContactList.size() > 0)
            insert offsiteCoverageContactList;
        
        return offsiteCoverageContactList;
    }
}