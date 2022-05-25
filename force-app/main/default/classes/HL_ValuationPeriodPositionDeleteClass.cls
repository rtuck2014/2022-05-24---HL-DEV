public class HL_ValuationPeriodPositionDeleteClass {
    public String PositionId; 
    public String sObjectName ; 
    public String returnID ;
    
    public HL_ValuationPeriodPositionDeleteClass() {
        
        PositionId = ApexPages.currentPage().getParameters().get('id');
        sObjectName = ApexPages.currentPage().getParameters().get('sObjectName');
        returnID = ApexPages.currentPage().getParameters().get('ReturnID');
    }
    
    
    Public PageReference Back(){
        return new PageReference('/'+(String.isBlank(PositionId)?returnID:PositionId));
    }
    
    
    Public PageReference onDelete(){
        if(String.isNotBlank(sObjectName) && String.isNotBlank(PositionId)){
            string querystring = 'SELECT id FROM '+sObjectName+' WHERE id =: PositionId';
            sObject recordToDelete = Database.query(querystring);
            Try{
                delete recordToDelete;
            }
            catch(Exception e){
                ApexPages.addmessages(e);
                return null;
            }
        }
        return new PageReference('/'+(String.isBlank(returnID)?null:returnID));
    }
    
}