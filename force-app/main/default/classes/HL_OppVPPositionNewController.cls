public without sharing class HL_OppVPPositionNewController {
    
    Public Opp_VP_Position__c OppVPPositon {get; set;}
    Public List<Opportunity__c> OppList {get; set;}
	Public Account selectedAcc {get; set;}
    public Boolean isValidPVUser{get;set;}
    public Boolean IshavingValidRoleForRevAccrual{get;set;}
    //This parameter is determining for Opportunity conversion status or for status of Request  Engagement Number on opportunity
    public Boolean isOpportunityConverted {get;set;}
    public string MessageToShow{get;set;}
    
    public HL_OppVPPositionNewController(ApexPages.StandardController controller) {
        MessageToShow = '';
        OppVPPositon = new Opp_VP_Position__c();
        OppList = new List<Opportunity__c>();
        OppVPPositon = (Opp_VP_Position__c) controller.getRecord(); 
        OppVPPositon.Opportunity_VP__c = apexpages.currentPage().getParameters().get('VPId');   
        OppVPPositon.Status__c = 'In Progress';
        Opportunity__c Opp = new Opportunity__c();
        isOpportunityConverted  = false;
        for(Opp_VP__c opVP : [Select Opportunity__c, Opportunity__r.Converted_to_Engagement__c, Opportunity__r.Approval_Process__c, Opportunity__r.Engagement_Approval_Status__c  From Opp_VP__c Where Id =: OppVPPositon.Opportunity_VP__c])
        {
            Opp.id = opVP.Opportunity__c;
            isOpportunityConverted = opVP.Opportunity__r.Converted_to_Engagement__c;
            MessageToShow = Label.HL_OppPV_Is_Locked_NewPosition;
            if(opVP.Opportunity__r.Approval_Process__c == label.HL_AppProcessForEngNo && opVP.Opportunity__r.Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
            {
                isOpportunityConverted = true;
                MessageToShow = Label.HL_OppPV_Is_Locked_NewPosition_EngNoReqsted;
            }
        }
        if(Opp != null && Opp.id != null ){
            OppList = [Select Id, Client__c,Opportunity_Number__c From Opportunity__c Where Id =: Opp.id];
            isValidPVUser = HL_OpportunityViewController.VerifyUserforVP(Opp, 'PVPositionCreation');
            IshavingValidRoleForRevAccrual = HL_ConstantsUtil.IshavingValidRoleInInternTeamOpp(Opp.id); 
        }
    }
	
	//To get IG&S of associated Company
    public void CompanyIGSvalues(){
        if(OppVPPositon.Company__c != null){
            selectedAcc = [SELECT id,Industry_Group__c,Sector__c from Account WHERE id=:OppVPPositon.Company__c];
        }
    }
    
    public PageReference SaveData() {
        
		CompanyIGSvalues();
        try{ 
			if(((selectedAcc.Industry_Group__c == null || selectedAcc.Industry_Group__c == '') || (selectedAcc.Sector__c == null || selectedAcc.Sector__c == '')) && 
			   ((OppVPPositon.Industry_Group_Picklist__c == null || OppVPPositon.Industry_Group_Picklist__c == '') || (OppVPPositon.Sector__c == null || OppVPPositon.Sector__c == ''))){
				
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,Label.HL_No_IG_S_on_Position));
				return null;
			}
			
			
			if((selectedAcc.Industry_Group__c != null && selectedAcc.Industry_Group__c != '') && (selectedAcc.Sector__c != null && selectedAcc.Sector__c != '') &&
				(OppVPPositon.Industry_Group_Picklist__c == null || OppVPPositon.Industry_Group_Picklist__c == '') && (OppVPPositon.Sector__c == null || OppVPPositon.Sector__c == '')){
				
				OppVPPositon.Industry_Group_Picklist__c = selectedAcc.Industry_Group__c;
				OppVPPositon.Sector__c = selectedAcc.Sector__c;
			}
			
            insert OppVPPositon; 
            return new pageReference('/'+ apexpages.currentPage().getParameters().get('VPId'));
        }
        catch(Exception e) {
            Apexpages.addMessages(e);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getmessage()));
            return null;
        }       
        
    }
}