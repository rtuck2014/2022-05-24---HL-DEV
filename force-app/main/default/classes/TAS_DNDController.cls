Global class TAS_DNDController {
   
    Webservice static string DnDOnOff(Id recordId){ 
        
        System.debug('recordId'+recordId);
        
       
        Opportunity__c opptyRecord = [Select id,TAS_DND__c, DND_Status__c, Opp_Name_Store__c,z_Principal_Aggregate_CHECK__c , Name, DND_Submitter_Email__c From Opportunity__c where id =:recordId];
        
        try{
            
            return updateOpportunity(opptyRecord);
            //return 'Successfully completed the operation';
           
        }
        catch(DMLException dmlEx){return dmlEx.getDMLMessage(0);}catch(Exception ex){return ex.getMessage();}
        

    
    }
    
    public static String updateOpportunity(Opportunity__c opptyRecord){
        if(opptyRecord.DND_Status__c != 'APPROVED'){
            opptyRecord.DND_Submitter_Email__c  = UserInfo.getUserEmail();
            opptyRecord.Opp_Name_Store__c = opptyRecord.Name;
            opptyRecord.Name = 'DND – '+opptyRecord.Id;
            opptyRecord.DND_Status__c = 'APPROVED';
            opptyRecord.TAS_DND__c = true;
            update opptyRecord;
            return System.label.HL_TASDNDON ;
        }else{
            opptyRecord.DND_Submitter_Email__c  = UserInfo.getUserEmail();
            opptyRecord.Name = opptyRecord.Opp_Name_Store__c;
            opptyRecord.DND_Status__c = 'RELEASED'; 
            opptyRecord.TAS_DND__c = false;
            update opptyRecord;
            return System.label.HL_TASDNDOFF  ;
        }
        
        
    }
    
    
}