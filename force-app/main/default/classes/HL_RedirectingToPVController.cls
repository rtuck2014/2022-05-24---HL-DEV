public class HL_RedirectingToPVController {

public boolean IsPVConversionCompeleted {get;set;}
public boolean isError{get;set;}
String EngRecordId;
String OppRecordId;   

Public String ErrorMessage{get;set;}

public HL_RedirectingToPVController()
{
    IsPVConversionCompeleted = false;
    isError = false;
    EngRecordId = apexpages.currentpage().getparameters().get('id');
    OppRecordId = apexpages.currentpage().getparameters().get('Oppid');
}
private List<Engagement__c> newEngagement;

Public Pagereference calculate(){
    Savepoint sp = Database.setSavepoint();
    try
    {            
        List<Opp_Vp__C> listofVP = new List<Opp_VP__c>();
        listofVP = [Select id From Opp_VP__c Where Isconverted__C = false AND Opportunity__c = : OppRecordId];    
        if(listofVP.size() > 0){ 
            // To stop un-necessary operations related to PV while converting opportunity in to engagement
            
            HL_ConstantsUtil.stopExecutionForPVConversion = true;
            PVConversion();              
            HL_ConstantsUtil.stopExecutionForPVConversion = false;            
            return null;  
        }
        else
        {
            IsPVConversionCompeleted = true;
            return new Pagereference('/apex/HL_Related_PortfolioValuations?id='+EngRecordId  +'&relatedObjType=EngVP');
        }       
    }
    catch(exception e)
    {
        Database.rollback( sp );
        isError = true;
        IsPVConversionCompeleted = true; 
        ErrorMessage  = e.getmessage();
        ApexPages.addmessages(e);
        return null;            
    }   
}

private void PVConversion(){
        try{
            system.debug('----'+limits.getQueries());            
            if(EngRecordId != null && Label.Allow_Portfolio_Valuation_Conversion == 'True')
                SL_EngagementConversionHelper.ConvertOppVPs(EngRecordId,OppRecordId);
            system.debug('----'+limits.getQueries());         
        }
        catch(Exception e){
            throw e;
        }
    }
public PageReference BackToEnagement() {
        return new PageReference('/'+EngRecordId);
    } 

}