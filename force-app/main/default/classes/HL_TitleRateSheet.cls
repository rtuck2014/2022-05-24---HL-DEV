//This class is without sharing so that the code can query the data
//On the front-end, the object and fields are restricted to the appropriate staff
public without sharing class HL_TitleRateSheet {
    public HL_TitleRateSheet() {}

    public static List<Title_Rate_Sheet__c> GetActive(){
        return [SELECT Name FROM Title_Rate_Sheet__c WHERE Active__c = true ORDER BY Name];
    }

    public Title_Rate_Sheet__c GetByEngagementId(Id id){
        Date today = Date.today();
        List<Engagement_Title_Rate_Sheet__c> trList = [SELECT Title_Rate_Sheet__r.CurrencyIsoCode,
                                                    Title_Rate_Sheet__r.Senior_Managing_Director_Rate__c,
                                                    Title_Rate_Sheet__r.Managing_Director_Rate__c,
                                                    Title_Rate_Sheet__r.Director_Rate__c,
                                                    Title_Rate_Sheet__r.Senior_Vice_President_Rate__c,
                                                    Title_Rate_Sheet__r.Vice_President_Rate__c,
                                                    Title_Rate_Sheet__r.Associate_Rate__c,
                                                    Title_Rate_Sheet__r.Financial_Analyst_Rate__c,
                                                    Title_Rate_Sheet__r.Manager_Rate__C,
                                                    Title_Rate_Sheet__r.Executive_Administrator_Rate__c,
                                                    Title_Rate_Sheet__r.Para_Professional_Rate__c,
                                                    Title_Rate_Sheet__r.SrResearchLibrarianRate__c,
                                                    Title_Rate_Sheet__r.Outsourced_Contractor_Rate__c,
                                                    Title_Rate_Sheet__r.PresentationsGraphicsRate__c,
                                                    Title_Rate_Sheet__r.SpecialProjectsCoordinator__c                                                   
                                            FROM Engagement_Title_Rate_Sheet__c
                                            WHERE Engagement__c =: id AND Start_Date__c <=: today AND (End_Date__c = null OR End_Date__c >=: today)];
        return trList.size() > 0 ? trList[0].Title_Rate_Sheet__r : new Title_Rate_Sheet__c();
    }

    public Decimal GetRateByEngagementIdAndTitle(Id id, String title){
        Title_Rate_Sheet__c trs = GetByEngagementId(id);                       
        return HL_TitleRateSheet.ExtractTitleRate(trs, title);
    }

    public static Decimal ExtractTitleRate(Title_Rate_Sheet__c trs, String title){
        return trs == null || String.isBlank(trs.Id) ? 0.0 :
               (title == 'Senior Managing Director' ? trs.Senior_Managing_Director_Rate__c :
                title == 'Managing Director' ? trs.Managing_Director_Rate__c :
                title == 'Director' ? trs.Director_Rate__c :
                title == 'Senior Vice President' ? trs.Senior_Vice_President_Rate__c :
                title == 'Vice President' ? trs.Vice_President_Rate__c :
                title == 'Para-Professional' ? trs.Para_Professional_Rate__c :
                title == 'Special Projects Coordinator' ? trs.SpecialProjectsCoordinator__c :
                title.contains('Research Librarian') ? trs.SrResearchLibrarianRate__c :
                title.contains('P&G') ? trs.PresentationsGraphicsRate__c :
                title.contains('Associate') ? trs.Associate_Rate__c : 
                title.contains('Manager') ? trs.Manager_Rate__C :
                title.contains('Outsourced Contractor') ? trs.Outsourced_Contractor_Rate__c :                
                title.contains('Admin') || title.contains('Assistant') ? trs.Executive_Administrator_Rate__c :
                trs.Financial_Analyst_Rate__c);
    }
}