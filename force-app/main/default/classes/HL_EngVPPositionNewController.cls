public without sharing class HL_EngVPPositionNewController {
    
    Public Eng_VP_Position__c EngVPPositon {get; set;}
    Public Account selectedAcc {get; set;}
    Public List<Engagement__c> EngList {get; set;}
    public Boolean isValidPVUser{get;set;}
    public Boolean IshavingValidRoleForRevAccrual{get;set;}
    public HL_EngVPPositionNewController(ApexPages.StandardController controller) {
        
        EngVPPositon = new Eng_VP_Position__c();
        EngList = new List<Engagement__c>();
        EngVPPositon = (Eng_VP_Position__c) controller.getRecord(); 
        EngVPPositon.Engagement_VP__c = apexpages.currentPage().getParameters().get('VPId');   
        EngVPPositon.Status__c = 'In Progress';
        Engagement__c Eng = new Engagement__c();
        for(Eng_VP__c engVP : [Select Engagement__c From Eng_VP__c Where Id =: EngVPPositon.Engagement_VP__c])
        {
            Eng.id = engVP.Engagement__c;
        }
        if(Eng != null && Eng.id != null ){
            EngList = [Select Id, Client__c,Engagement_Number__c From Engagement__c Where Id =: Eng.id];
            isValidPVUser = HL_EngagementViewController.VerifyUserforVP(Eng, 'PVPositionCreation');  
            IshavingValidRoleForRevAccrual = HL_ConstantsUtil.IshavingValidRoleInInternTeamEng(Eng.id); 
        }
                               
    }
      //To ClearFeeApprovalDate on change of report fee
    public void ClearFeeApprovalDate(){
        EngVPPositon.Fee_Approval_Date__c=null;
        
     }
    //To get IG&S of associated Company
    public void CompanyIGSvalues(){
        if(EngVPPositon.Company__c != null){
            selectedAcc = [SELECT id,Industry_Group__c,Sector__c from Account WHERE id=:EngVPPositon.Company__c];
        }
    }
    
    public PageReference SaveData() {
        
        CompanyIGSvalues();
        try{ 
            if(EngVPPositon.Automation_Tool_Utilized__c == 'No' && (EngVPPositon.Reason__c == '' || EngVPPositon.Reason__c == null)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Reason: Please select a Reason because Automation Tool Utilized is selected as \'No\''));
                return null;
            }
            
            if(((selectedAcc.Industry_Group__c == null || selectedAcc.Industry_Group__c == '') || (selectedAcc.Sector__c == null || selectedAcc.Sector__c == '')) && 
               ((EngVPPositon.Industry_Group_Picklist__c == null || EngVPPositon.Industry_Group_Picklist__c == '') || (EngVPPositon.Sector__c == null || EngVPPositon.Sector__c == ''))){
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_No_IG_S_on_Position));
                return null;
            }
            
            if(EngVPPositon.Automation_Tool_Utilized__c == 'yes' && (EngVPPositon.Reason__c != '' && EngVPPositon.Reason__c != null)){
                EngVPPositon.Reason__c='';
            }
            
            if((selectedAcc.Industry_Group__c != null && selectedAcc.Industry_Group__c != '') && (selectedAcc.Sector__c != null && selectedAcc.Sector__c != '') &&
                (EngVPPositon.Industry_Group_Picklist__c == null || EngVPPositon.Industry_Group_Picklist__c == '') && (EngVPPositon.Sector__c == null || EngVPPositon.Sector__c == '')){
                
                EngVPPositon.Industry_Group_Picklist__c = selectedAcc.Industry_Group__c;
                EngVPPositon.Sector__c = selectedAcc.Sector__c;
            }
            
            insert EngVPPositon; 
            return new pageReference('/'+ apexpages.currentPage().getParameters().get('VPId'));
        }
        catch(Exception e) {
            Apexpages.addMessages(e);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getmessage()));
            return null;
        }       
        
    }
}