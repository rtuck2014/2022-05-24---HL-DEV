public class HL_ValuationPeriodPositionCancel {
    private Id PositionId ;  
    public Eng_VP_Position__c EngVpPosition{get;set;}   
    public boolean isError{get;set;}
    
    // constructor
    public HL_ValuationPeriodPositionCancel(ApexPages.StandardController controller) {
        isError = false;
        PositionId = ApexPages.currentPage().getParameters().get('id');
        EngVpPosition = new Eng_VP_Position__c() ;
        for(Eng_VP_Position__c pos : [Select id,status__c,Engagement_VP__c from Eng_VP_Position__c where id =: PositionId]){
            EngVpPosition  = pos;                       
        }
    }
        
    Public PageReference CancelAccural(){
        PageReference pageRef = new PageReference('/'+PositionId);
        try{
            // To avoid validation (to avoid chaging status to cancelled on position directly)
            HL_ConstantsUtil.ToStopChangesStatusToCancelled = false;
            if(EngVpPosition.Status__c == System.Label.HL_Eng_VP_Status_Completed || EngVpPosition.Status__c == 'In Progress'){
                EngVpPosition.Status__c = 'Cancelled';
                update EngVpPosition;
            HL_ConstantsUtil.ToStopChangesStatusToCancelled = true;
            }               
        }
        catch(Exception e){
            isError = true;
            ApexPages.addMessages(e); 
            return null;
        }
        return pageRef;
  
  } 
  Public PageReference Back(){
    if(EngVpPosition.Engagement_VP__c != null)
        return new PageReference('/'+EngVpPosition.Engagement_VP__c);
    else 
        return null;
  }
  
   Public PageReference No(){
    if(PositionId != null)
        return new PageReference('/'+PositionId );
    else 
        return null;
  }

}