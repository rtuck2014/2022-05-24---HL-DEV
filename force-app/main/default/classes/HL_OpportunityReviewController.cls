public with sharing class HL_OpportunityReviewController 
{
    public string classicURL;
    
    public HL_OpportunityReviewController() {
        
        oppId = HL_PageUtility.GetParameter('id');
        JobType = HL_PageUtility.GetParameter('JobType');
        IsNBC= HL_PageUtility.GetParameter('IsNBC');
            
    }

    public Boolean SelectionVisible{get;set;}
    public String frequency { get; set; }
    public Opportunity__c op{get;set;}
    public Boolean onNBCViewAccess;
    public Opportunity_Approval__c destRecord;
    public PageReference dest;      
    public List<Opportunity_Approval__c> existingRecords;
    public string action;
    public string JobType;
    public string FormType;
    public string parentcurrency;
    public string oppId ;
    public string FromType;
    public string RecTypeName;
    public Boolean onOIT;
    public string IsNBC;
    public boolean IsNBC1;
    
    public HL_OpportunityReviewController (ApexPages.StandardController controller) {
        SelectionVisible=true;  
        oppId = HL_PageUtility.GetParameter('id');
        //IsNBC1 = HL_PageUtility.GetParameter('IsNBC');
        op=[select id,form_type__c, Job_Type__c,CurrencyIsoCode,IsNBC_BasedOn_JobType__c FROM Opportunity__c WHERE id =:oppId limit 1];
        JobType=op.Job_Type__c;
        system.debug('op.Job_Type__c='+op.Job_Type__c);
        IsNBC1=op.IsNBC_BasedOn_JobType__c;
        system.debug('IsNBC1='+IsNBC1);
        parentcurrency=op.CurrencyIsoCode;
    }
   
    public PageReference Radioblock()
    {
         oppId = HL_PageUtility.GetParameter('id');
        
         onOIT=getonOIT(oppId,UserInfo.getUserId());
         //IsNBC1 =HL_PageUtility.GetParameter('IsNBC');
         onNBCViewAccess=getonNBCViewAccess(oppId,UserInfo.getUserId()); 
         classicURL=getclassicopporutnityURL();
          
         system.debug('oppId='+oppId);        
         system.debug('jobType='+JobType);
         system.debug('IsNBC1='+IsNBC1);
         system.debug('onOIT='+onOIT);
         system.debug('classicURL='+classicURL);
         system.debug('onNBCViewAccess='+onNBCViewAccess);
         
         if((onOIT==true || onNBCViewAccess==true) && (IsNBC1==true ))
         {
             if(JobType=='Illiquid Financial Assets' || JobType=='Buyside & Financing Advisory')
             {            
                if(op.form_type__c=='' || op.form_type__c==null)
                {
                    system.debug('form_type_c='+ op.form_type__c);
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'IFA Opportunities may utilize M&A or Capital Market New Business Committee forms.'));
                }
                else
                { 
                    system.debug('form_type_c='+ op.form_type__c);
                    if(op.form_type__c=='M&A')
                        action='NBC';
                    else if(op.form_type__c=='Capital Market')
                        action='CNBC';
                }
                if(action == 'FEIS'||action =='NBC' || action == 'CNBC')
                {                                
                    RecTypeName=action +' '+'L';  
                       
                    system.debug('==op.onNBCViewAccess==='+onNBCViewAccess);
                    system.debug('action='+action);
                    system.debug('RecTypeName='+RecTypeName);
                    
                    Id recordTypeId = Schema.SObjectType.Opportunity_Approval__c.getRecordTypeInfosByName().get(RecTypeName).getRecordTypeId();
                    existingRecords = [SELECT Id, Approved__c,onNBCViewAccess__c,Approval_Status__c,onOIT__c,form_type__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:oppId LIMIT 1];
                    system.debug('==existingRecords.size()==='+existingRecords.size());
                    
                    if(existingRecords.size() == 0 && onNBCViewAccess==false)
                    {
                        system.debug('existingRecords.size()='+existingRecords.size());
                        destRecord = new Opportunity_Approval__c(Related_Opportunity__c = oppID,Form_Type__c = action.toUpperCase(), CurrencyIsoCode = parentcurrency, recordTypeId =recordTypeId,onOIT__c=onOIT, onNBCViewAccess__c=onNBCViewAccess, Classic_URL__c=classicURL);
                        if(!Test.isRunningTest())
                        insert destRecord;            
                    }
                    else if(existingRecords.size() == 0 && onNBCViewAccess==true)
                    {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Current user doesnot have permission to create a Opportunity Review record' ));
                        
                    }
                    if(existingRecords.size() > 0 )
                    {
                        system.debug('existingRecords.size()='+existingRecords.size());
                        destRecord = existingRecords[0];  
                        destRecord.onNBCViewAccess__c=onNBCViewAccess;
                        destRecord.recordTypeId=recordTypeId;
                        destRecord.onOIT__c=onOIT;
                        destRecord.form_type__c=action;
                        destRecord.Classic_URL__c=classicURL;
                        if(( destRecord.Approval_Status__c=='Rejected') || (string.isblank(destRecord.Approval_Status__c)) && (destRecord.Submit_For_Review__c==false) && (onNBCViewAccess==false) && destRecord.Approved__c==false )
                            update  destRecord;  
                        else
                            destRecord = existingRecords[0];  
                    } 
                    
                    if((existingRecords.size() != 0 && onNBCViewAccess==false) || (existingRecords.size() != 0 && onNBCViewAccess==true) || (existingRecords.size() == 0 && onNBCViewAccess==false)) 
                    {
                        dest = new PageReference('/lightning/r/Opportunity_Approval__c/'+destRecord.Id+'/view?0.source=alohaHeader');
                        //dest = new PageReference('/lightning/r/Opportunity_Approval_c/'+destRecord.Id+'/edit?backgroundContext=%2Flightning%2Fr%2FOpportunity_Approval_c%2F'+destRecord.Id+'%2Fview%3F0.source%3DalohaHeader&count=4&0.source=alohaHeader');
                        dest.setRedirect(true); 
                    }
                    
                    else 
                    {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Current user doesnot have permission' ));
                        
                    }
                }                              
            }                
         }   
    else
          ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Logged in user does not have view/Edit permission on Opportunity Review record.'));
        return dest; 
    }
    
    public PageReference opportunityreview()
    {        
        oppId = HL_PageUtility.GetParameter('id');
        system.debug('oppId ='+oppId );
        oppId = HL_PageUtility.GetParameter('id');
        JobType = HL_PageUtility.GetParameter('JobType');
        IsNBC =HL_PageUtility.GetParameter('IsNBC');

        system.debug('FromType='+FromType);
        system.debug('JobType='+JobType);
        system.debug('IsNBC='+IsNBC);
        
        onOIT=getonOIT(oppId,UserInfo.getUserId());
        onNBCViewAccess=getonNBCViewAccess(oppId,UserInfo.getUserId()); 
        classicURL=getclassicopporutnityURL();
        system.debug('classicURL='+classicURL);
        system.debug('onOIT='+onOIT);
        system.debug('onNBCViewAccess='+onNBCViewAccess);
        
        
        try
        {
            if((onOIT==true || onNBCViewAccess==true) && (IsNBC =='1'|| IsNBC=='true' ))
            {
                if(JobType!='Illiquid Financial Assets' && JobType!='Buyside & Financing Advisory')
                {        
                    if(JobType=='Debt Capital Markets' || JobType=='Equity Capital Markets' || JobType=='Syndicated Finance' || JobType=='Private Funds: GP Advisory'|| JobType=='Private Funds: GP Stake Sale' || JobType=='Private Funds: Primary Advisory' || JobType=='Liability Management' || JobType=='Private Funds: Secondary Advisory')
                        action='CNBC';
                    else if(JobType=='Negotiated Fairness')
                        action='FEIS';
                    else 
                        action='NBC';
                }
            
                if(action == 'FEIS'||action =='NBC' || action == 'CNBC')
                { 
                                       
                    RecTypeName=action +' '+'L';                     
                   
                    system.debug('==op.onNBCViewAccess==='+onNBCViewAccess);
                    system.debug('action='+action);
                    system.debug('RecTypeName='+RecTypeName);
                    
                    Id recordTypeId = Schema.SObjectType.Opportunity_Approval__c.getRecordTypeInfosByName().get(RecTypeName).getRecordTypeId();
                    existingRecords = [SELECT Id, Approved__c, onNBCViewAccess__c,Approval_Status__c,Classic_URL__c,Submit_For_Review__c FROM Opportunity_Approval__c WHERE Related_Opportunity__c =:oppId LIMIT 1];
                        
                    if(existingRecords.size() == 0 && onNBCViewAccess==false)
                    {
                        system.debug('existingRecords.size()='+existingRecords.size());
                        destRecord = new Opportunity_Approval__c(Related_Opportunity__c = oppID,Form_Type__c = action.toUpperCase(), CurrencyIsoCode = parentcurrency, recordTypeId =recordTypeId ,onOIT__c=onOIT, Classic_URL__c=classicURL);
                        if(!Test.isRunningTest())
                        insert destRecord;            
                    }
                    else if (existingRecords.size() == 0 && onNBCViewAccess==true)
                    {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Current user doesnot have permission to create a Opportunity Review record' ));
                    }
                    if(existingRecords.size() > 0 )
                    {
                        destRecord = existingRecords[0];  
                        destRecord.onNBCViewAccess__c=onNBCViewAccess;
                        destRecord.recordTypeId=recordTypeId;
                        destRecord.onOIT__c=onOIT;
                        destRecord.form_type__c=action;
                        destRecord.Classic_URL__c=classicURL;
                        if(( destRecord.Approval_Status__c=='Rejected' || string.isempty(destRecord.Approval_Status__c)) && destRecord.Submit_For_Review__c==false && onNBCViewAccess==false && destRecord.Approved__c==false )
                            update  destRecord; 
                        else
                           destRecord = existingRecords[0];  
                    }  
                 
                    SelectionVisible=false; 
                    try
                    {
                        if((existingRecords.size() != 0 && onNBCViewAccess==false) || (existingRecords.size() != 0 && onNBCViewAccess==true) || (existingRecords.size() == 0 && onNBCViewAccess==false)) 
                        {
                            dest = new PageReference('/lightning/r/Opportunity_Approval__c/'+destRecord.Id+'/view?0.source=alohaHeader');
                            //dest = new PageReference('/lightning/r/Opportunity_Approval_c/'+destRecord.Id+'/edit?backgroundContext=%2Flightning%2Fr%2FOpportunity_Approval_c%2F'+destRecord.Id+'%2Fview%3F0.source%3DalohaHeader&count=4&0.source=alohaHeader');
                            dest.setRedirect(true);  
                            return dest ; 
                        }  
                    } 
                   /* else 
                    {
                        ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Current user doesnot have permission' ));
                        
                    }  */
                    catch(Exception ex)
                    {
                        
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Current user doesnot have permission');
                        ApexPages.addMessage(myMsg);
                        
                        return null;
                        
                    }        
                } 
              
            }
            else
            {
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Logged in user does not have view/Edit permission on Opportunity Review record.');
                ApexPages.addMessage(myMsg);
            
                return null;
            }
            return dest;   
        }
        catch(Exception ex)
        {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.severity.FATAL, 'Current user doesnot have permission');
            ApexPages.addMessage(myMsg);
            
            return null;
            
        }    
             
    }
    
    public boolean getonNBCViewAccess(string opid, string userid)
    {
         if(HL_OIT.IsActiveOnTeam(opid,userid))
         {
             onNBCViewAccess =false;
         }
         else
            onNBCViewAccess = HL_SecurityUtility.IsNBCViewGroup();  
        system.debug('onNBCViewAccess=' +onNBCViewAccess);
         return   onNBCViewAccess;                                                                    
    }
    
    public boolean getonOIT(string opid, string userid)
    {
        boolean bonOIT=(HL_Utility.IsSysAdmin() ||  (HL_Utility.IsCAO() && HL_SecurityUtility.IsCAOCF()) || HL_OIT.IsActiveOnTeam(OpId,userid) );  
                system.debug('onOIT='+bonOIT);
        return bonOIT;
    }
    
    public List<SelectOption> getItems() 
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('M&A','NBC')); 
        options.add(new SelectOption('Capital Market','CNBC')); 
        return options; 
    }                                      
    
    public List<SelectOption> getTypes()
    {
        Schema.sObjectType sobject_type = Opportunity__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();     
        List<Schema.PicklistEntry> pick_list_values = field_map.get('form_type__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pick_list_values) 
        {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
   } 
    
   public string getclassicopporutnityURL()
   {
       string str=System.Url.getSalesforceBaseUrl().toExternalForm() ; 
       System.debug('str: ' + str);
       string str1 = str.replace('my.salesforce.com','visualforce.com');
       string str2 = str1.remove('https://');
       System.debug('str2: ' + str2);
       return str2;
   }
}