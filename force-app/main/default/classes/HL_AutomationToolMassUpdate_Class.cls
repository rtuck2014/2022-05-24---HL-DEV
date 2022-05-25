public class HL_AutomationToolMassUpdate_Class {
    
    public Id vpId;
    public Id SourceId;
    public Id srcParentId;
    public list<Eng_VP_Position__c> VPPostionList{get;set;} 
    public Boolean isRequired{get;set;}
    
    public HL_AutomationToolMassUpdate_Class() {
        
        isRequired = true;
        vpId = ApexPages.currentPage().getParameters().get('id');
        String retUrl = ApexPages.currentPage().getParameters().get('retURL');
        system.debug('test' + retUrl);
        SourceId = ApexPages.currentPage().getParameters().get('srcId');
        srcParentId = ApexPages.currentPage().getParameters().get('srcParentId');
        if(retUrl == null)
        isRequired = false;
        system.debug('isRequired' + isRequired);
    }
    
    public PageReference SavePosition(){
        try{            
            for(Eng_VP_Position__c selectedEVPP : VPPostionList){
                if(selectedEVPP.Automation_Tool_Utilized__c == 'No' && selectedEVPP.Reason__c == null){
                    Apexpages.addMessage(new ApexPages.message(Apexpages.Severity.Error, 'Please select Reason for Position where Automation Tool Utilized is selected No')) ;
                    return null;
                }
            }
            update VPPostionList;
        }catch(Exception e )
        {
            ApexPages.addMessages(e);
            return null;
        }
        
        if(SourceId != null && srcParentId != null){  return new pageReference('/apex/HL_EngAddPositions?srcId='+SourceId+'&srcParentId='+srcParentId+'&redirectFrom=SaveButton');
        }
        else{ return new pageReference('/'+vpId);
        }
    }
    
    
    
    public PageReference CancelPosition(){
        if(SourceId != null && srcParentId != null){ return new pageReference('/apex/HL_EngAddPositions?srcId='+SourceId+'&srcParentId='+srcParentId+'&redirectFrom=CancelButton');
        }
        else{
            return new pageReference('/'+vpId);
        }
        
    }
    
}