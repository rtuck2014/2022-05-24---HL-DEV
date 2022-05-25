public with sharing class HL_RelatedVPController {
    
    public  List<Schema.FieldSetMember> FieldsList {get; private set;}
    public  String childRelationShipName {get; private set;}
    public  String EngOppNumber {get; private set;}
    public  String EngOppId {get; private set;}
    public  String SelectedRecId {get; set;}
    public  string ButtonName {get; private set;}
    private String CurentFieldSetName;
    private String ParentObjField;
    Public String MainObjectName;
    private String RecordId;
    private String RelatedObjType;
    private String ParentObjFieldId;
    private String JobTypeFieldId;
    private SObject SourceObj;
    private String sortDirection = 'DESC';
    private String sortExp = 'Valuation_Date__c';
    public List<Sobject> Records{get;set;}
    public  string ReturnToObj {get; private set;}
    public  string ObjNumber {get; private set;}
    public Boolean isValidPVUser{get;set;}
    public Boolean isOpportunityConverted {get;set;}
    public Boolean IsSupervisorAdmin{get;set;}
    public Boolean IsEngagementStageClosed {get;set;}
    Public Boolean IsHavingPVPermissionSetOrIsSysAdmin{get;set;} 
    public String userProfileName {
        get {
            return [
                    select Profile.Name
                    from User
                    where Id = :Userinfo.getUserId() 
                    ].Profile.Name;
        }
    }

   public List<sobject> RecordList {
      get {
        List<sobject> tempRecordsList = new List<sobject>();
        FieldsList = new List<Schema.FieldSetMember>();
        String fieldsStr = '';
        if (MainObjectName != null) {
          for (Schema.FieldSetMember f : Schema.getGlobalDescribe().get(MainObjectName ).getDescribe().fieldSets.getMap().get(CurentFieldSetName).getFields()) {
            fieldsStr += f.getFieldPath() + ', ';   
            FieldsList.add(f);         
          }        
          if (fieldsStr != null && fieldsStr != '') {           
            fieldsStr = fieldsStr.removeEnd(', '); 
            tempRecordsList = Database.query('SELECT '+fieldsStr +' FROM '+ MainObjectName+' WHERE '+ ParentObjField + '=\''+RecordId+'\'');
          }
        }
        return tempRecordsList;
      }
      set; 
    } 
    public String sortExpression
       {
         get
         {
            return sortExp;
         }
         set
         {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
         }
       }
    
     public String getSortDirection()
     {
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
          return 'ASC';
        else
         return sortDirection;
     }
    
     public void setSortDirection(String value)
     {  
       sortDirection = value;
     }   
    String sourceObjectName;    
    public HL_RelatedVPController() {   
      IsSupervisorAdmin = HL_ConstantsUtil.IsSupervisorOrAdmin(); 
      IsEngagementStageClosed  = false;            
      RecordId = apexpages.currentpage().getparameters().get('id');
      RelatedObjType = apexpages.currentpage().getparameters().get('relatedObjType');         
      if (RecordId != null && RecordId != '') { 
        String preFix = String.valueOf(RecordId).substring(0,3);
        sourceObjectName = FindObjectNameFromRecordId(preFix);   
        SourceObj = Schema.getGlobalDescribe().get(sourceObjectName).newSObject() ;   
        isOpportunityConverted = false;        
        if(sourceObjectName  == 'Opportunity__c'){
            SourceObj = Database.query('SELECT Id, Name,Job_Type__c, Converted_to_Engagement__c, CurrencyIsoCode, Approval_Process__c, Engagement_Approval_Status__c, Opportunity_Number__c FROM '+sourceObjectName+' WHERE id '+ '=\''+RecordId+'\'')[0];
            isOpportunityConverted = ((Opportunity__c)SourceObj).Converted_to_Engagement__c;
            if(((Opportunity__c)SourceObj).Approval_Process__c == label.HL_AppProcessForEngNo && ((Opportunity__c)SourceObj).Engagement_Approval_Status__c == label.HL_Pending_EngReqNo)
            {
                isOpportunityConverted = true;
            }
            
            if(SourceObj.get('Opportunity_Number__c') != null)
                EngOppNumber  = SourceObj.get('Opportunity_Number__c')+'';
            ObjNumber = 'Opportunity Number :  ';
            
        }else if(sourceObjectName  == 'Engagement__c'){
            SourceObj = Database.query('SELECT Id, Name,Job_Type__c,Opportunity__c, CurrencyIsoCode, Stage__c,Engagement_Number__c FROM '+sourceObjectName+' WHERE id '+ '=\''+RecordId+'\'')[0];
            if(String.valueOF(SourceObj.get('Stage__c')) == 'Closed'|| String.valueOF(SourceObj.get('Stage__c')) == 'Dead')
                IsEngagementStageClosed = true;    
            
            if(SourceObj.get('Engagement_Number__c') != null)
                EngOppNumber  = SourceObj.get('Engagement_Number__c')+'';
            ObjNumber = 'Engagement Number :  ';
        }        
            
        EngOppId  = SourceObj.get('Id')+'';
        childRelationShipName  = SourceObj.get('Name')+' - Valuation Periods';
        
      }
      
      for(Valuation_Period__mdt vp : [SELECT id, DeveloperName, Create_Record_Button_Name__c,JobTypeFieldId__c, Field_Set_Name__c, Main_Object_API_Name__c, 
                                          Parent_Object_API_Name__c, Parent_Object_Field_Id__c 
                                         FROM Valuation_Period__mdt 
                                         WHERE DeveloperName = : RelatedObjType]) {             
        MainObjectName = vp.Main_Object_API_Name__c ;
        CurentFieldSetName = vp.Field_Set_Name__c;
        ParentObjField = vp.Parent_Object_API_Name__c;
        ButtonName = vp.Create_Record_Button_Name__c;
        ParentObjFieldId = vp.Parent_Object_Field_Id__c;
        JobTypeFieldId = vp.JobTypeFieldId__c;
      }   
      if(sourceObjectName == 'Opportunity__c'){      
      ReturnToObj  = 'Back To Opportunity';  
      Opportunity__c Opp = new Opportunity__c();
      Opp.id = RecordId;
      if(Opp != null)
            isValidPVUser = HL_OpportunityViewController.VerifyUserforVP(Opp, 'PVcreation'); 
     }
     if(sourceObjectName == 'Engagement__c') {
         ReturnToObj  = 'Back To Engagement'; 
         Engagement__c Eng = new Engagement__c();
      Eng.id = RecordId;
      if(Eng != null)
            isValidPVUser = HL_EngagementViewController.VerifyUserforVP(Eng, 'PVcreation'); 
     }
     IsHavingPVPermissionSetOrIsSysAdmin = HL_ConstantsUtil.IsHavingPVPermissionSetOrIsSysAdmin();
     ViewData();       
    }
     public void ViewData() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
       system.debug('sortFullExp ...'+sortFullExp);
       //query the database based on the sort expression
        List<sobject> tempRecordsList = new List<sobject>();
        FieldsList = new List<Schema.FieldSetMember>();
        String fieldsStr = '';
        system.debug('MainObjectName ...'+MainObjectName );
        if (MainObjectName != null) {
          for (Schema.FieldSetMember f : Schema.getGlobalDescribe().get(MainObjectName ).getDescribe().fieldSets.getMap().get(CurentFieldSetName).getFields()) {
            fieldsStr += f.getFieldPath() + ', ';   
            FieldsList.add(f);         
          }        
          if (fieldsStr != null && fieldsStr != '') {           
            fieldsStr = fieldsStr.removeEnd(', ');
            String query = 'SELECT '+fieldsStr +' FROM '+ MainObjectName+' WHERE '+ ParentObjField + '=\''+RecordId+'\'' +' order by ' + sortFullExp + ' NULLS LAST'; 
            system.debug('query ...'+query);
           
            Records =Database.query(query);
          }
        }
       
        
         system.debug('RecordList2....'+Records);
         
   }
    public pagereference DeleteRecord() {
        try{ 
            
            Delete Database.query('Select id from '+ MainObjectName+' where id =\''+SelectedRecId+'\'');    
            return null;
        }
        catch (Exception e){      
            if(e.getmessage().contains('insufficient access rights on object'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,Label.HL_No_Delete_Privilige_VP));   
            }      
            else
                Apexpages.addMessages(e);      
            /*else if(sourceObjectName == 'Opportunity__c')
            {     
                list<Opp_VP_Position__c> positions = new list<Opp_VP_Position__c>();
                positions = [Select id from Opp_VP_Position__c Where Opportunity_VP__c =: SelectedRecId];
                if(positions.size() > 0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please delete all position records prior to deleting the associated Valuation Period.'));
                else
                    Apexpages.addMessages(e);
                    
            }else if(sourceObjectName == 'Engagement__c')
            {
                list<Eng_VP_Position__c> positions = new list<Eng_VP_Position__c>();
                positions = [Select id from Eng_VP_Position__c Where Engagement_VP__c=: SelectedRecId];
                if(positions.size() > 0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please delete all position records prior to deleting the associated Valuation Period.'));
                else
                    Apexpages.addMessages(e);                    
            }*/
            return null;
       }     
    }
    
    public Pagereference CreateNewRecord() {
      
      if(sourceObjectName  == 'Engagement__c' && HL_Eng_VP_PositionTriggerHelper.IsReveneAccrualLocked())
      {
         ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.HL_VP_Not_Allowed_RevenueAcc_Locked);
         ApexPages.addMessage(myMsg);         
         return null;                   
      }
      PageReference pg = new PageReference('/'+Schema.getGlobalDescribe().get(MainObjectName).getDescribe().getKeyPrefix()+'/e?CF'+ParentObjFieldId+'='+ 
                                          SourceObj.get('Name')+'&CF'+ParentObjFieldId+'_lkid'+RecordId+'&CurrencyIsoCode='+SourceObj.get('CurrencyIsoCode')+'&'+JobTypeFieldId+'='+SourceObj.get('Job_Type__c'));
      
      if(sourceObjectName  == 'Engagement__c')
      {
          pg = new PageReference('/apex/HL_EngValuationPeriodNew?EngId='+RecordId);
      }
      else if(sourceObjectName  == 'Opportunity__c')
      {
          pg = new PageReference('/apex/HL_OppValuationPeriodNew?OppId='+RecordId);
      }
      String returlstr='apex/HL_Related_PortfolioValuations?id='+RecordId+'&relatedObjType='+RelatedObjType;
      pg.getParameters().put('retURL', returlstr);
      return pg;
    }
    public Pagereference CancelRecord() {          
      return new PageReference('/'+RecordId);
    }
    public Pagereference EditRecord() {
      PageReference pg = new PageReference('/'+SelectedRecId+'/e');
      String returlstr='apex/HL_Related_PortfolioValuations?id='+RecordId+'&relatedObjType='+RelatedObjType;
      pg.getParameters().put('retURL', returlstr);     
      return pg;
    }
    
    public static String FindObjectNameFromRecordId(String idPreFix) {
      String objectName = '';
      try {
        //Get schema information
        Map<String, Schema.SObjectType> gdMap =  Schema.getGlobalDescribe();              
        //Loop through all the sObject types returned by Schema
        for (Schema.SObjectType stype : gdMap.values()) {
          Schema.DescribeSObjectResult r = stype.getDescribe();
          String prefix = r.getKeyPrefix();                                 
          //Check if the prefix matches with requested prefix
          if (prefix!=null && prefix.equals(idPreFix)) {
            objectName = r.getName();
            break;
          }
        }
      }catch(Exception e){
        System.debug(e);
      }
      return objectName;
    } 
    /*public static PageReference FindURLId(ID idPreFix) {
    ID mysql = ApexPages.currentpage().getparameters().get('id');
      PageReference Result;
      List<Opp_VP__c> EngVP = [select id,IsConverted__c from Opp_VP__c where IsConverted__c = : False AND id =: mysql];
      if(EngVP.size()>0)
      {
       Result = new pagereference('/apex/HL_RedirectingToPV?id=');
       result.setRedirect(false);
       
      }
      return result;
    }*/      
    
    public PageReference redirectToPVConversion() {
        if(sourceObjectName == 'Opportunity__c')
            return null;
        else{
            if(sourceObjectName == 'Engagement__c' && RelatedObjType != null && RecordId != null && SourceObj != null && SourceObj.get('Opportunity__c') != null){
                boolean IsAllPVConverted = true;
                String OptyId = String.valueof(SourceObj.get('Opportunity__c'));
                for(Opp_VP__c relatedOppVP : [Select id from Opp_VP__c where IsConverted__c = false AND Opportunity__c =: OptyId])
                {
                    IsAllPVConverted = false;
                }
                if(!IsAllPVConverted)           
                    return new PageReference('/apex/HL_RedirectingToPV?id='+RecordId+'&Oppid='+OptyId);
                else
                    return null;
            }   
        }   
        return null;
    } 
}