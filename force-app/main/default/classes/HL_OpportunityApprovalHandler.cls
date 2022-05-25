public class HL_OpportunityApprovalHandler {
    public static Integer maxRelated = 5;
    
    public static Map<Id, String> GetRelatedTransactionData(List<Opportunity_Approval__c> oas, Boolean includeClient){
        List<Engagement__c> existing;
        
        //Create a Set of Opportunity IDs
        Set<Id> opps = New Set<Id>();
        for(Opportunity_Approval__c oa : oas)
            opps.add(oa.Related_Opportunity__c);    
        
        //Create a Set of Subject IDs and a Map of Opportunity to Subject Id
        Set<Id> subjects = new Set<Id>();
        for(Opportunity__c o : [SELECT ID, Subject__c FROM Opportunity__c WHERE ID IN: opps])
            subjects.add(o.Subject__c);
 
        //Create a Map of Subject and Client Ids with related Engagements
        List<Engagement__c> engagements = Database.Query('SELECT Id, Name, Engagement_Number__c, Stage__c, Job_Type__c, Close_Date__c, Subject__c, Client__c FROM Engagement__c WHERE Subject__c IN:subjects' + (includeClient?' OR Client__c IN:subjects ' : '') + ' ORDER BY Close_Date__c DESC, Date_Engaged__c DESC');
        Map<Id,List<Engagement__c>> engageMap = new Map<Id,List<Engagement__c>>();
        
        for(Engagement__c e : engagements){
            if(engageMap.get(e.Subject__c) == null)
                engageMap.put(e.Subject__c, new List<Engagement__c> {e});
            else
            {
               existing = engageMap.get(e.Subject__c);
               if(existing.size() < maxRelated)
               {
                    existing.add(e);
                    engageMap.put(e.Subject__c, existing);
               }
            }
            If(includeClient)
            {
                if(engageMap.get(e.Client__c) == null)
                    engageMap.put(e.Client__c, New List<Engagement__c>{e});
                else {
                    existing = engageMap.get(e.Client__c);
                    if(existing.size() < maxRelated){
                        existing.add(e);
                        engageMap.put(e.Client__c,existing);
                    }
                }  
            }
        }
        
        //Create Map of Subject Id/Client Ids with Related Transaction Text
        Map<Id, String> relatedTransactionMap = new Map<Id, String>();
        for(String key : engageMap.keySet())
        {
            String tt = '';
            List<Engagement__c> eList = engageMap.get(key);
            for(Engagement__c e:eList)
                tt += e.Name + ' - ' + (e.Job_Type__c <> null ? e.Job_Type__c:'N/A') + ' - ' + (e.Engagement_Number__c <> null ? e.Engagement_Number__c:'N/A') + ' - ' + (e.Stage__c <> null ? e.Stage__c : 'N/A') + ' - ' + (e.Close_Date__c <> null ? String.valueOf(e.Close_Date__c):'Active') + '\n';
            
            relatedTransactionMap.put(key, tt);
        }
        
        return relatedTransactionMap;
    }
    
    //Added by Shruthi on 3rd Mar 2022
    public static void UpdatevaluesforInsert(List<Opportunity_Approval__c> oas)
    {
    	list<id> oppids=new list<id>();
        map<id,Opportunity__c> mapopp=new map<id,Opportunity__c>();
        
        for(Opportunity_Approval__c oa : oas)
        {   
            oppids.add(oa.Related_Opportunity__c);
        }
        
        if(oppids.size()>0)
        {
            
            list<Opportunity__c> listop=[select id, Retainer__c ,ProgressMonthly_Fee__c  from Opportunity__c where id in: oppids];
            {
                for(Opportunity__c op:listop)
                {
                    mapopp.put(op.id,op);           
                }
            }
            
            if(mapopp.size()>0)
            {
                for(Opportunity_Approval__c oa : oas)
                {
                    oa.Retainer1__c = mapopp.get(oa.Related_Opportunity__c).Retainer__c ;
                    system.debug('testtesttest==='+oa.Retainer1__c );
                    oa.Progress_Fee__c =mapopp.get(oa.Related_Opportunity__c).ProgressMonthly_Fee__c ;
                    
                }
            }
        }
            
    }
    //Added by Shruthi on 3rd Mar 2022
    
    //Added by Shruthi on 22nd Mar 2022
    /*public static void Updatevalues_afterInsertupdate(List<Opportunity_Approval__c> oas)
    {
        list<Opportunity__c> updateOpportunitie = new list<Opportunity__c>();
        map<id,Opportunity_Approval__c> mapopp=new map<id,Opportunity_Approval__c>();
        
        for(Opportunity_Approval__c oa: oas)
        { 
            mapopp.put(oa.Related_Opportunity__c, oa);
        }
        
        list<Opportunity__c> listopp=[select Estimated_Transaction_Size_MM__c from Opportunity__c where id in: mapopp.keyset()];
        {
            if(listopp.size()>0)
            {
                for(Opportunity__c op:listopp)
                {
                    system.debug('op.Estimated_Transaction_Size_MM__c='+op.Estimated_Transaction_Size_MM__c);
                    if(mapopp.get(op.id).Estimated_Valuation__c==null)
                    //{
                        system.debug('op.mapopp.get(op.id).Estimated_Valuation__c='+mapopp.get(op.id).Estimated_Valuation__c);
                        op.Estimated_Transaction_Size_MM__c=mapopp.get(op.id).Estimated_Valuation__c;
                        updateOpportunitie.add(op);
                    //}
                }
            }
        }
        
        if(updateOpportunitie.size()>0)
        {
            update updateOpportunitie;
        }
    }*/
    //Added by Shruthi on 22nd Mar 2022
    
    //Added by Shruthi on 24th Feb 2022
    /*public static void updateestimatedtransactionsize(List<Opportunity_Approval__c> oas)
    {
        list<id> oppids=new list<id>();
        map<id,Opportunity__c> mapopp=new map<id,Opportunity__c>();
        
        for(Opportunity_Approval__c oa : oas)
        {  
                 
            oppids.add(oa.Related_Opportunity__c);
        }
        
        if(oppids.size()>0)
        {
            
            list<Opportunity__c> listop=[select id, Estimated_Transaction_Size_MM__c,CurrencyIsoCode from Opportunity__c where id in: oppids];
            {
                for(Opportunity__c op:listop)
                {
                    mapopp.put(op.id,op);           
                }
            }
            
            if(mapopp.size()>0)
            {
                for(Opportunity_Approval__c oa : oas)
                {
                    system.debug('mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c='+mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c);
                    if(mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c!=null)
                    {
                        system.debug('mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c'+ mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c);
                        oa.Estimated_Valuation__c=mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c;
                    	//oa.Transaction_Value_for_Fee_Calc__c=mapopp.get(oa.Related_Opportunity__c).Estimated_Transaction_Size_MM__c;
                    	oa.CurrencyIsoCode=mapopp.get(oa.Related_Opportunity__c).CurrencyIsoCode;
                    }
                }
            }
        }
        
            
    }*/
    public static void UpdateFormApproved(List<Opportunity_Approval__c> oas){
        List<Opportunity__c> oppsToUpdate = new List<Opportunity__c>();       
        Set<Id> nbcToCheck = new Set<Id>();
        Set<Id> feisToCheck = new Set<Id>();
        
        
        for(Opportunity_Approval__c oa : oas){
            if((oa.Form_Type__c == 'NBC' || oa.Form_Type__c == 'CNBC') && !String.IsBlank(oa.Grade__c) && oa.Grade__c <> 'F')
                nbcToCheck.Add(oa.Related_Opportunity__c);
            
            if(oa.Form_Type__c == 'FEIS' && oa.Reviewed__c)
                feisToCheck.Add(oa.Related_Opportunity__c);
            
            
        }
                
        
        if(nbcToCheck.size() > 0){
            for(Opportunity__c o : [SELECT NBC_Approved__c FROM Opportunity__c WHERE Id IN:nbcToCheck AND NBC_Approved__c =: false]){
                o.NBC_Approved__c = true;
                oppsToUpdate.Add(o);
            }
        }
        if(feisToCheck.size() > 0){
            for(Opportunity__c o : [SELECT FEIS_Approved__c FROM Opportunity__c WHERE Id IN:feisToCheck AND FEIS_Approved__c =: false]){
                o.FEIS_Approved__c = true;
                oppsToUpdate.Add(o);
            }
        }
        if(oppsToUpdate.size() > 0)
           update oppsToUpdate;
    }
    
    public void SubmitReviewCancel(List<Opportunity_Approval__c> newListoa)
    {
        //Added by Shruthi on 4th Dec 2021
        list<opportunity__c> updateopp=new list<opportunity__C>();
        list<Opportunity__c> listop;
        PageReference dest;
        Boolean hasEngagementTeamAssembled=false;
        boolean nofinances=false; 
        string oaoppid;
        string oppid;
        
         
        for(Opportunity_Approval__c oa: newListoa)  
        { 
            if(oa.Form_Type__c=='NBC')
            {
            	if(oa.Transaction_Fee_Type__c=='Incentive Structure') 
                {
                    //Ratcher FROM and TO amounts mandatory when respective percentage field non empty
                	if(oa.First_Ratchet_Percent__c!=null && oa.First_Ratchet_From_Amount__c==null)    
                        oa.First_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.First_Ratchet_Percent__c!=null &&  oa.First_Ratchet_To_Amount__c==null)    
                        oa.First_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation);
                    if(oa.Second_Ratchet_Percent__c!=null && oa.Second_Ratchet_From_Amount__c==null)
                        oa.Second_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Second_Ratchet_Percent__c!=null && oa.Second_Ratchet_To_Amount__c==null)
                        oa.Second_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Third_Ratchet_Percent__c!=null && oa.Third_Ratchet_From_Amount__c==null)
                        oa.Third_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Third_Ratchet_Percent__c!=null && oa.Third_Ratchet_To_Amount__c==null)
                        oa.Third_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Fourth_Ratchet_Percent__c!=null && oa.Fourth_Ratchet_From_Amount__c==null)
                        oa.Fourth_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Fourth_Ratchet_Percent__c!=null && oa.Fourth_Ratchet_To_Amount__c==null)
                        oa.Fourth_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation);
                    if(oa.Final_Ratchet_Percent__c!=null && oa.Final_Ratchet_Amount__c==null)
                        oa.Final_Ratchet_Amount__c.addError(Label.Ratchet_Validation);
                    //Ratcher validation for TO amount 
                    if(oa.First_Ratchet_To_Amount__c <= oa.First_Ratchet_From_Amount__c)
                        oa.First_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                    if(oa.Second_Ratchet_To_Amount__c <= oa.Second_Ratchet_From_Amount__c)
                        oa.Second_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                    if(oa.Third_Ratchet_To_Amount__c <= oa.Third_Ratchet_From_Amount__c)
                        oa.Third_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                    if(oa.Fourth_Ratchet_To_Amount__c <= oa.Fourth_Ratchet_From_Amount__c)
                        oa.Fourth_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                }
            }
            
            if(oa.Form_Type__c=='CNBC')
            {
            	if(oa.Job_Type__c=='Equity Capital Markets' && oa.Transaction_Fee_Type__c=='Incentive Structure') 
                {
                    //Ratcher FROM and TO amounts mandatory when respective percentage field non empty
                	if(oa.First_Ratchet_Percent__c!=null && oa.First_Ratchet_From_Amount__c==null)    
                        oa.First_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.First_Ratchet_Percent__c!=null &&  oa.First_Ratchet_To_Amount__c==null)    
                        oa.First_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation);
                    if(oa.Second_Ratchet_Percent__c!=null && oa.Second_Ratchet_From_Amount__c==null)
                        oa.Second_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Second_Ratchet_Percent__c!=null && oa.Second_Ratchet_To_Amount__c==null)
                        oa.Second_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Third_Ratchet_Percent__c!=null && oa.Third_Ratchet_From_Amount__c==null)
                        oa.Third_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Third_Ratchet_Percent__c!=null && oa.Third_Ratchet_To_Amount__c==null)
                        oa.Third_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Fourth_Ratchet_Percent__c!=null && oa.Fourth_Ratchet_From_Amount__c==null)
                        oa.Fourth_Ratchet_From_Amount__c.addError(Label.Ratchet_Validation); 
                    if(oa.Fourth_Ratchet_Percent__c!=null && oa.Fourth_Ratchet_To_Amount__c==null)
                        oa.Fourth_Ratchet_To_Amount__c.addError(Label.Ratchet_Validation);
                    if(oa.Final_Ratchet_Percent__c!=null && oa.Final_Ratchet_Amount__c==null)
                        oa.Final_Ratchet_Amount__c.addError(Label.Ratchet_Validation);
                    //Ratcher validation for TO amount 
                    if(oa.First_Ratchet_To_Amount__c <= oa.First_Ratchet_From_Amount__c)
                        oa.First_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                    if(oa.Second_Ratchet_To_Amount__c <= oa.Second_Ratchet_From_Amount__c)
                        oa.Second_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                    if(oa.Third_Ratchet_To_Amount__c <= oa.Third_Ratchet_From_Amount__c)
                        oa.Third_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                    if(oa.Fourth_Ratchet_To_Amount__c <= oa.Fourth_Ratchet_From_Amount__c)
                        oa.Fourth_Ratchet_To_Amount__c.addError(Label.Ratchets_validation_for_To_amount);
                }
            }
            
            Id id1 = UserInfo.getProfileId();
        	list<Profile_Ids__c> listprofileid=[select CAO__c,System_Administrator__c from Profile_Ids__c];
       
            if(listprofileid.size()>0)
            {
            	if(oa.Approved__c==true && (listprofileid[0].CAO__c !=id1 && listprofileid[0].System_Administrator__c!=id1 ))
                	Trigger.new[0].addError('Approved records can only edit by CAO/Admin profile users');  
            } 
            oppid=oa.Related_Opportunity__c;
            if(oa.onNBCViewAccess__c==false)
            {                                  
                list<Group> listg= [select Id from Group where Name='CF NBC Review Q' limit 1];
                oaoppid=oa.Related_Opportunity__c;
                listop =[SELECT  Opportunity_Review_Approval_Status__c,form_type1__c,ownerid FROM Opportunity__c WHERE Id=:oa.Related_Opportunity__c ];
                if(listop.size()>0)
                {
                    for(Opportunity__c op:listop)
                    {
                        op.Opportunity_Review_Approval_Status__c = oa.Approval_Status__c;
                        op.Form_Type1__c=oa.Form_Type__c;
                        if(oa.Approval_Status__c=='Submit_To_Committee ')
                            op.ownerid=listg[0].id;
                        updateopp.Add(op);
                    }
                }
            
                       
                if(oa.Submit_For_Review__c==true) 
                {                    
                    List<String> engagementTeamRolesList = new List<String> {'Principal','Manager','Initiator'};
                    Set<String> engagementTeamRolesSet = new Set<String>();
                    List<Opportunity_Internal_Team__c> oppInternalTeamList = [SELECT Id, Role__c FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: oaoppid AND  Staff_Role__r.Name IN : engagementTeamRolesList AND (End_Date__c = null OR End_Date__c > : date.today())];
                    for(Opportunity_Internal_Team__c oppInternalTeam : oppInternalTeamList){
                        if(!engagementTeamRolesSet.contains(oppInternalTeam.Role__c)){
                            engagementTeamRolesSet.add(oppInternalTeam.Role__c);
                            if(engagementTeamRolesSet.size() > 2){                                
                                hasEngagementTeamAssembled = true;
                                break;
                            }
                        }
                    }
                }
                    
                if(oa.No_Financials__c==false)
                {
                    system.debug('enterd yes1');
                    list<integer> listyear = new list<integer>();
                    list<Financials__c> listf= new list<Financials__c>();
                    list<Financials__c> listfinancials=[select id, Type__c,Revenue_MM__c,EBITDA__c,Year__c  from Financials__c where Related_Approval__c =:oa.id];
                    if(listfinancials.size()>=2)
                    {
                        system.debug('enterd yes2');
                        for(Financials__c  finance: listfinancials)
                        {
                            listf.add(finance);
                        }
                        
                        for(Financials__c  finance: listfinancials)
                        {
                            for(integer i=0; i<listf.size(); i++)  
                            {                                   
                                if((finance.Type__c!=listf[i].Type__c) || (finance.Revenue_MM__c !=listf[i].Revenue_MM__c ) || (finance.EBITDA__c !=listf[i].EBITDA__c ) )  
                                {
                                    system.debug('enterd yes3');
                                    listyear.add(integer.valueOf(finance.Year__c ))  ;  
                                }                                   
                            }
                        }
                
                        if(listyear.size()>=2)
                        {
                            system.debug('enterd yes4');
                            integer FY=0;
                            Integer CY=0;
                            Integer PY=0;
                            Integer currentYear = System.Today().year();
                            for(integer j=0; j<listyear.size(); j++)
                            {
                                if(listyear[j]>currentYear)                                    
                                    FY++;                                       
                                if(listyear[j]==currentYear)
                                    CY++;
                                if(listyear[j]<currentYear)
                                    PY++;
                            }
                            if ((PY>=2)||(CY>=1 && FY>=1) )
                            {
                                
                            }
                            else
                                nofinances=true;                                          
                        }
                        else
                           nofinances=true;                  
                    }
                    else
                        nofinances=true;                                                                      
                }
                
                List<Opportunity_Internal_Team__c> oitPublicList = [SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: oa.Related_Opportunity__c AND Role__c = 'Public Person' AND End_Date__c = null];
                 system.debug('oitPublicList=='+ oitPublicList.size());   
                if(oa.Submit_For_Review__c==true)
                {
                    if(oa.a__c == 'Yes' && oa.b__c == 'Yes' && oa.c__c == 'Yes' && oa.d__c == 'Yes')
                    {                        
                        HLTeamApproved(oa);
                        
                    }
                    //system.debug('checkEngagementTeamRoles='+checkEngagementTeamRoles);
                    system.debug('nofinances='+nofinances);
                    if(oa.Form_Type__c=='NBC')
                    {
                        if(hasEngagementTeamAssembled==false )
                        {  
                            if(!Test.isRunningTest())
                            Trigger.new[0].addError(Label.checkEngagementTeamRoles); 
                        }  
                        
                        if(oa.Head_Approval__c==false)
                            oa.Head_Approval__c.adderror(Label.GroupheadApproval );
                        //Tab 1 - Administrative 
                        if(oa.a__c == null)
                            oa.a__c.addError(Label.Is_Majority_Sale); 
                        if(oa.b__c == null)
                            oa.b__c.addError(Label.Is_Majority_Sale); 
                        if(oa.c__c == null)
                            oa.c__c.addError(Label.Is_Majority_Sale); 
                        if(oa.d__c == null)
                            oa.d__c.addError(Label.Is_Majority_Sale); 
                        //Opportunity Review
                        if(oa.Estimated_Valuation__c ==null)
                        	oa.Estimated_Valuation__c.addError(label.Estimated_Valuation);
                        if(String.isBlank(oa.Status__c))
                            oa.Status__c.addError(Label.Current_Status);
                        if(string.isBlank(oa.Company_Description__c))
                            oa.Company_Description__c.addError(Label.Company_Description);
                        if(oa.Client_Ownership__c == null)
                            Trigger.new[0].addError(Label.Client_Ownership);  
                        if(String.isBlank(oa.Ownership_and_Capital_Structure__c))
                            oa.Ownership_and_Capital_Structure__c.addError(Label.Ownership_and_Capital_Structure);                                                   
                        if(String.isBlank(oa.Valuation_Expectations__c))
                            oa.Valuation_Expectations__c.addError(Label.Valuation_Expectations);
                        if(oa.Total_Debt_MM__c==null)
                            oa.Total_Debt_MM__c.addError(Label.Total_Debt_MM);
                        if(String.isBlank(oa.Risk_Factors__c))
                            oa.Risk_Factors__c.addError(Label.Risk_Factors); 
                        if(String.isBlank(oa.Transaction_Overview__c))
                            oa.Transaction_Overview__c.addError(Label.Transaction_Overview); 
                        if(oa.International_Angle__c==null)
                                oa.International_Angle__c.addError(Label.International_Angle);
                        //If International Angle is 'Yes', Internation Angle Notes are Required
                        if(oa.International_Angle__c == 'Yes' && String.isBlank(oa.International_Angle_Notes__c ))
                            oa.International_Angle_Notes__c.addError(Label.International_Angle_Notes); 
                        if(oa.Asia_Angle__c==null)
                            oa.Asia_Angle__c.addError(label.Asia_Angle);
                        //If Asia Angle is 'Yes', Asia Angle Notes are Required
                        if(oa.Asia_Angle__c == 'Yes' && String.isBlank(oa.Asia_Angle_Notes__c ))
                            oa.Asia_Angle_Notes__c.addError(label.Asia_Angle_Notes);
                        
                        if(oa.Real_Estate_Angle__c==null)
                            oa.Real_Estate_Angle__c.addError(label.Real_Estate_Angle);
                        
                        if(oa.Real_Estate_Angle__c == 'Yes' && String.isBlank(oa.Real_Estate_Angle_Notes__c ))
                            oa.Real_Estate_Angle_Notes__c.addError(label.Real_Estate_Angle_Notes);

                        //Financials
                        if(oa.Capital_Markets_Consulted__c==null)
                            oa.Capital_Markets_Consulted__c.addError(Label.Capital_Markets_Consulted);                        
                        if(String.isBlank(oa.Existing_Financial_Arrangement_Notes__c))
                            oa.Existing_Financial_Arrangement_Notes__c.addError(LAbel.Existing_Financial_Arrangement_Notes);                           
                        system.debug('nofinances='+nofinances);
                        if(oa.No_Financials__c==false)
                        {
                            system.debug('nofinances='+nofinances);
                            //to velidate the Financials records.minimum of 2 entries (historical or current and future years )
                            if(nofinances==true)                           
                                oa.No_Financials__c.addError(Label.nofinances);     
                        }                        
                        if(oa.No_Financials__c==true && String.isBlank(oa.No_Financials_Explanation__c))
                            oa.No_Financials_Explanation__c.addError(Label.No_Financials_Explanation);
                        if(oa.Financials_Subject_to_Audit__c==null && !oa.No_Financials__c)
                            oa.Financials_Subject_to_Audit__c.addError(Label.Financials_Subject_to_Audit);
                        //If Subject to Edit is 'No', an explanation is required.
                        if(oa.Financials_Subject_to_Audit__c=='No' && String.isBlank(oa.Financials_Audit_Notes__c))
                            oa.Financials_Audit_Notes__c.addError(Label.Financials_Audit_Notes); 
                        if(oa.Capital_Markets_Consulted__c==null)
                        oa.Capital_Markets_Consulted__c.addError(Label.Capital_Markets_Consulted);
                        if(String.isBlank(oa.Existing_Financial_Arrangement_Notes__c))
                        oa.Existing_Financial_Arrangement_Notes__c.addError(label.Existing_Financial_Arrangement_Notes);
                        
                        //--Fees   
                        if(oa.Total_Otherfee__c==null  && oa.Transaction_Fee_Type__c=='other fee structure')
                        	oa.Total_Otherfee__c.adderror(label.Estimated_fee_MM );
                        if(oa.Transaction_Value_for_Fee_Calc__c ==null && oa.Transaction_Fee_Type__c=='Incentive Structure' )
                        	oa.Transaction_Value_for_Fee_Calc__c.adderror(label.Estimated_Transaction_Value_MM);
                        if(oa.Retainer1__c==null)
                            oa.Retainer1__c.addError(Label.Retainer);
                        if(oa.Estimated_Minimum_Fee__c > 100)
                            oa.Estimated_Minimum_Fee__c.addError(Label.Estimated_Minimum_Fee_c);
                        /*if(String.isBlank(oa.Fee_Structure__c))
                            oa.Fee_Structure__c.addError(Label.Fee_Structure);*/
                        if(oa.Lockups_on_Future_M_A_or_Financing_Work__c==null)
                            oa.Lockups_on_Future_M_A_or_Financing_Work__c.addError(Label.Lockups_on_Future_M_A_or_Financing_Work);                        
                        if(oa.Referral_Fee__c==null)
                            oa.Referral_Fee__c.addError(Label.Referral_Fee_Owed);
                        if(oa.Transaction_Fee_Type__c==null)
                            oa.Transaction_Fee_Type__c.adderror(Label.TransactionType);
                        
                        //Pitch
                        if(oa.Will_there_be_a_pitch__c == null)
                            oa.Will_there_be_a_pitch__c.addError(Label.Will_there_be_a_pitch);
                        if(String.isBlank(oa.Houlihan_Lokey_Competition__c))
                            oa.Houlihan_Lokey_Competition__c.addError(Label.Houlihan_Lokey_Competition);
                        if(oa.TAS_Assistance_Benefit__c==null)
                            oa.TAS_Assistance_Benefit__c.addError(Label.TAS_Assistance_Benefit);
                        if(String.isBlank(oa.OutsideCouncil__c))
                            oa.OutsideCouncil__c.addError(Label.OutsideCouncil); 
                         if(oa.Existing_or_Repeat_Client__c == null)
                            oa.Existing_or_Repeat_Client__c.addError(label.Existing_or_Repeat_Client);
                        //Existing or Repeat Client - Listing of Previous Transactions Required
                        if(oa.Existing_or_Repeat_Client__c == 'Yes' && 
                           String.isBlank(oa.Previous_Transactions__c))
                            oa.Previous_Transactions__c.addError(label.Previous_Transactions);
                        if(oa.Existing_Relationships__c==null)
                            oa.Existing_Relationships__c.addError(label.Existing_Relationships);               
                        //--Fairness Checklist
                        if(oa.Fairness_Opinion_Provided__c==null)
                            oa.Fairness_Opinion_Provided__c.addError(Label.Fairness_Opinion_Provided);                        
                        if(oa.Fairness_Opinion_Provided__c == 'Yes' && oa.Fairness_Opinion_Publicly_Disclosed__c==null)
                            oa.Fairness_Opinion_Publicly_Disclosed__c.addError(Label.Fairness_Opinion_Publicly_Disclosed);                        
                        if(oa.Fairness_Opinion_Provided__c == 'Yes' && oa.Shareholder_Vote__c==null)
                            oa.Shareholder_Vote__c.addError(Label.Shareholder_Vote);                        
                        if(oa.Fairness_Opinion_Provided__c == 'Yes' && String.isBlank(oa.Proposed_Fee_Range__c))
                            oa.Proposed_Fee_Range__c.addError(Label.Proposed_Fee_Range);                        
                        if(oa.Fairness_Opinion_Provided__c == 'Yes' && oa.Fairness_Fee_Inclusion__c==null)
                            oa.Fairness_Fee_Inclusion__c.addError(Label.Fairness_Fee_Inclusion);                        
                        if(oa.Fairness_Opinion_Provided__c == 'Yes' && String.isBlank(oa.Fairness_Opinion_Staffing_Notes__c))
                            oa.Fairness_Opinion_Staffing_Notes__c.addError(Label.Fairness_Opinion_Staffing_Notes);                  
                        //If Other Opine Option is Checked, Notes are Required
                        if(oa.FEIS_Opine_Option_6__c && String.isBlank(oa.Form_of_Opinion_Notes__c))
                            oa.FEIS_Opine_Option_6__c.addError(Label.FEIS_Opine_Option_6);                        
                        //If a Fairness Opinion was Provided, Related Party Transactions are Required
                        if(oa.Fairness_Opinion_Provided__c == 'Yes' && String.isBlank(oa.Related_Party_Transaction__c))
                            oa.Related_Party_Transaction__c.addError(Label.Related_Party_Transaction);                        
                        //If Related Party Transaction is Checked and Fairness Opinion was Provided, Related Party Affiliation Notes are Required
                        if(oa.Related_Party_Transaction__c == 'Yes' && oa.Fairness_Opinion_Provided__c == 'Yes' && 
                           String.isBlank(oa.Related_Party_Affiliation_Notes__c))
                            oa.Related_Party_Affiliation_Notes__c.addError(Label.Related_Party_Affiliation_Notes); 
                        
                        //--Administrative
                        if(oa.Restricted_List__c==null)
                            oa.Restricted_List__c.addError(Label.Restricted_List);
                        //If on Restricted List, the Date is Required
                        if(oa.Restricted_List__c == 'Yes' && oa.Restricted_List_Date__c == null)
                            oa.Restricted_List_Date__c.addError(Label.Restricted_List_Date);
                        //Conflict_Check_Status
                        if(oa.Conflict_Check_Date__c == null && !String.isBlank(oa.Id))
                            Trigger.new[0].addError(Label.Conflict_Check_Date);
                        //If Conflicts Check is Withdrawn/Dead/Expired
                        if((oa.Conflicts_Outcome__c=='Withdrawn' || oa.Conflicts_Outcome__c=='Dead' || oa.Conflicts_Outcome__c=='Expired') )
                            oa.Conflicts_Outcome__c.addError(Label.Conflicts_Outcome);
                        
                         //If Conflicts Check is True Conflict
                        if(oa.Conflicts_Outcome__c=='True Conflict' && !String.isBlank(oa.Id))
                            Trigger.new[0].addError('Administrative: Conflicts Check Outcome is True Conflict - Please contact Legal Department.');
                        
                                                
                        
                        //if Conflicts is Cleared/Managed and not all the cc questions are answered                       
                        if(oa.Conflicts_2a_Not_Listed__c==null && (oa.Conflicts_Outcome__c == 'Cleared' || oa.Conflicts_Outcome__c == 'Managed' || oa.Conflicts_Outcome__c == 'No Resolution Required' || (oa.Conflicts_Outcome__c==null && oa.Conflict_Check_Date__c != null)  ) )                 
                            oa.Conflicts_2a_Not_Listed__c.addError(Label.Conflicts_Check_Information_questions);
                        if(oa.Conflicts_3a_Related_to_Transaction__c==null && (oa.Conflicts_Outcome__c == 'Cleared' || oa.Conflicts_Outcome__c == 'Managed' || oa.Conflicts_Outcome__c == 'No Resolution Required' || (oa.Conflicts_Outcome__c==null && oa.Conflict_Check_Date__c != null) )) 
                            oa.Conflicts_3a_Related_to_Transaction__c.addError(Label.Conflicts_Check_Information_questions);
                        if(oa.Conflicts_35a_Related_to_Client__c==null && (oa.Conflicts_Outcome__c == 'Cleared' || oa.Conflicts_Outcome__c == 'Managed' || oa.Conflicts_Outcome__c == 'No Resolution Required' || (oa.Conflicts_Outcome__c==null && oa.Conflict_Check_Date__c != null) )) 
                            oa.Conflicts_35a_Related_to_Client__c.addError(Label.Conflicts_Check_Information_questions);
                        if(oa.Conflicts_4a_Conflict_of_Interest__c==null && (oa.Conflicts_Outcome__c == 'Cleared' || oa.Conflicts_Outcome__c == 'Managed' || oa.Conflicts_Outcome__c == 'No Resolution Required' || (oa.Conflicts_Outcome__c==null && oa.Conflict_Check_Date__c != null) )) 
                            oa.Conflicts_4a_Conflict_of_Interest__c.addError(Label.Conflicts_Check_Information_questions);
                        if(oa.Conflicts_5a_Other_Conflicts__c==null && (oa.Conflicts_Outcome__c == 'Cleared' || oa.Conflicts_Outcome__c == 'Managed' || oa.Conflicts_Outcome__c == 'No Resolution Required' || (oa.Conflicts_Outcome__c==null && oa.Conflict_Check_Date__c != null) )) 
                            oa.Conflicts_5a_Other_Conflicts__c.addError(Label.Conflicts_Check_Information_questions); 
                       
                        //If Any Conflict Check Questions under Conflicts Check Information are 'Yes', Details in Relevant Areas are Required                       
                        if(oa.Conflicts_2a_Not_Listed__c == 'Yes' && String.isBlank(oa.Conflicts_2b_Not_Listed_TXT__c)) 
                            oa.Conflicts_2a_Not_Listed__c.addError(Label.Conflicts_Yes);
                        if(oa.Conflicts_3a_Related_to_Transaction__c == 'Yes' && String.isBlank(oa.Conflicts_3b_Related_to_Transaction_TXT__c))
                            oa.Conflicts_3a_Related_to_Transaction__c.addError(Label.Conflicts_Yes);
                        if(oa.Conflicts_35a_Related_to_Client__c == 'Yes' && String.isBlank(oa.Conflicts_35a_Related_to_Client_TXT__c)) 
                            oa.Conflicts_35a_Related_to_Client__c.addError(Label.Conflicts_Yes);
                        if(oa.Conflicts_4a_Conflict_of_Interest__c == 'Yes' && String.isBlank(oa.Conflicts_4b_Conflict_of_Interest_TXT__c)) 
                            oa.Conflicts_4a_Conflict_of_Interest__c.addError(Label.Conflicts_Yes);
                        if(oa.Conflicts_5a_Other_Conflicts__c == 'Yes' && String.isBlank(oa.Conflicts_5b_Other_Conflicts_TXT__c))
                            oa.Conflicts_5a_Other_Conflicts__c.addError(Label.Conflicts_Yes);
                    
                        if(!oa.Req_feedback_prior_to_normal_sched_call__c && !oa.Next_Scheduled_Call__c) 
                            Trigger.new[0].addError(Label.Next_Scheduled_Call);
                        if(oa.Req_feedback_prior_to_normal_sched_call__c && oa.Next_Scheduled_Call__c) 
                            Trigger.new[0].addError(Label.Next_Scheduled_Call);
                        
                        if(oa.Retainer_Creditable__c == null )
                                oa.Retainer_Creditable__c.addError(Label.Is_Retainer_Fee_Creditable);
                        if(oa.Is_Progress_Fee_Creditable__c == null)
                            oa.Is_Progress_Fee_Creditable__c.adderror(Label.Is_Progress_Fee_Creditable);
                    }
                
                
                                                                
                                        
                    if(oa.Form_Type__c=='CNBC')
                    {  
                        
                        if(hasEngagementTeamAssembled==false )
                        { 
                            if(!Test.isRunningTest())
                            Trigger.new[0].addError(Label.checkEngagementTeamRoles); 
                        }    
                        
                        if(oa.Head_Approval__c==false)
                            oa.Head_Approval__c.adderror(Label.GroupheadApproval );

                        if(oa.Client_Ownership__c == null)
                            trigger.new[0].addError(Label.Client_Ownership);
                            
                        if(String.isBlank(oa.Status__c))
                            oa.Status__c.addError(Label.Current_Status);
                            
                            if(oa.Company_Ownership_Type__c == null)
                                trigger.new[0].addError(Label.Company_Ownership_Type);
            
                          
                            if(String.isBlank(oa.Houlihan_Lokey_Competition__c))
                                oa.Houlihan_Lokey_Competition__c.addError(Label.Houlihan_Lokey_Competition);
                            
                            if(oa.Use_of_Proceeds__c == null)
                                oa.Use_of_Proceeds__c.addError(label.Use_of_Proceeds);
                            //On CNBC forms, if Other Use of Proceeds is indicated, Use of Proceeds Details are Required
                            if(oa.Use_of_Proceeds__c != null && oa.Use_of_Proceeds__c.contains('Other') && String.isBlank(oa.Use_of_Proceeds_Detail__c))
                                oa.Use_of_Proceeds_Detail__c.addError(Label.Use_of_Proceeds);
                            
                           /* if(oa.Existing_Relationships__c==null)
                                oa.Existing_Relationships__c.addError(Label.Existing_Relationships);*/
            
            
                            //--Overview and Financials
                            if(String.isBlank(oa.Transaction_Overview__c))
                                oa.Transaction_Overview__c.addError(Label.Transaction_Overview);  
                            if(oa.Existing_or_Repeat_Client__c == null)
                                oa.Existing_or_Repeat_Client__c.addError(label.Existing_or_Repeat_Client);
                            //Existing or Repeat Client - Listing of Previous Transactions Required
                            if(oa.Existing_or_Repeat_Client__c == 'Yes' && 
                               String.isBlank(oa.Previous_Transactions__c))
                                oa.Previous_Transactions__c.addError(label.Previous_Transactions);
                            if(oa.Existing_Relationships__c==null)
                                oa.Existing_Relationships__c.addError(label.Existing_Relationships);               
                            //--Fairness Checklist
                            /*if(String.isBlank(oa.Current_Status__c))
                                oa.Current_Status__c.addError(Label.Current_Status);*/ 
                            if(oa.Total_Debt_MM__c==null)
                            oa.Total_Debt_MM__c.addError(Label.Total_Debt_MM);
                        
                            if(oa.International_Angle__c==null)
                                oa.International_Angle__c.addError(Label.International_Angle);
                            //If International Angle is 'Yes', Internation Angle Notes are Required
                            if(oa.International_Angle__c == 'Yes' && String.isBlank(oa.International_Angle_Notes__c ))
                                oa.International_Angle_Notes__c.addError(Label.International_Angle_Notes);                                                          
                            if(oa.Asia_Angle__c==null)
                                oa.Asia_Angle__c.addError(label.Asia_Angle);
                            //If Asia Angle is 'Yes', Asia Angle Notes are Required
                            if(oa.Asia_Angle__c == 'Yes' && String.isBlank(oa.Asia_Angle_Notes__c ))
                                oa.Asia_Angle_Notes__c.addError(label.Asia_Angle_Notes);
                            
                            if(oa.Real_Estate_Angle__c==null)
                                oa.Real_Estate_Angle__c.addError(label.Real_Estate_Angle);
                                                
                            if(oa.Real_Estate_Angle__c == 'Yes' && String.isBlank(oa.Real_Estate_Angle_Notes__c ))
                                oa.Real_Estate_Angle_Notes__c.addError(label.Real_Estate_Angle_Notes);
                            if(String.isBlank(oa.Ownership_and_Capital_Structure__c))
                                oa.Ownership_and_Capital_Structure__c.addError(Label.Ownership_and_Capital_Structure);
                            
                            if(oa.Total_Debt_MM__c==null)
                                oa.Total_Debt_MM__c.addError(Label.Total_Debt_MM);     
                            
                            //If No Financials are Available, an Explanation is Required.
                            if(oa.No_Financials__c && String.isBlank(oa.No_Financials_Explanation__c))
                                oa.No_Financials_Explanation__c.addError(Label.No_Financials_Explanation);
            
                            if(oa.Financials_Subject_to_Audit__c==null && !oa.No_Financials__c)
                                oa.Financials_Subject_to_Audit__c.addError(Label.Financials_Subject_to_Audit);
                            //If Subject to Edit is 'No', an explanation is required.
                            if(oa.Financials_Subject_to_Audit__c=='No' && String.isBlank(oa.Financials_Audit_Notes__c))
                                oa.Financials_Audit_Notes__c.addError(Label.Financials_Audit_Notes);
                            
                            if(oa.Capital_Raise__c==null)
                                oa.Capital_Raise__c.addError(Label.Capital_Raise);
                            
                            if(String.isBlank(oa.Structure_and_Pricing_Expectations__c))
                                oa.Structure_and_Pricing_Expectations__c.addError(Label.Structure_and_Pricing_Expectations);
                            
                            if(String.isBlank(oa.Risk_Factors__c))
                            oa.Risk_Factors__c.addError(Label.Risk_Factors);  
                            
                            if(oa.Financials_Subject_to_Audit__c==null && !oa.No_Financials__c)
                                oa.Financials_Subject_to_Audit__c.addError(LAbel.Financials_Subject_to_Audit);
                            //If Subject to Edit is 'No', an explanation is required.
                            if(oa.Financials_Subject_to_Audit__c=='No' && String.isBlank(oa.Financials_Audit_Notes__c))
                                oa.Financials_Audit_Notes__c.addError(Label.Financials_Audit_Notes); 
                            
                            //--Fees    
                            if(oa.Total_Otherfee__c==null && ((oa.Job_Type__c=='Equity Capital Markets' && oa.Transaction_Fee_Type__c=='Other Fee Structure') || (oa.Job_Type__c!='Equity Capital Markets')))
                                oa.Total_Otherfee__c.adderror(label.Estimated_fee_MM );
                        
                            // Error msg for new field Estimated_Minimum_Fee__C
                            if(oa.Transaction_Value_for_Fee_Calc__c ==null && oa.Transaction_Fee_Type__c=='Incentive Structure' && oa.Job_Type__c=='equity capital Market')
                        		oa.Transaction_Value_for_Fee_Calc__c.adderror(label.Estimated_Transaction_Value_MM);
                        
                            if(oa.Estimated_Minimum_Fee__c > 100)
                                oa.Estimated_Minimum_Fee__c.addError(Label.Estimated_Minimum_Fee_c);
                            
                            /*if(String.isBlank(oa.Fee_Structure__c))
                                oa.Fee_Structure__c.addError(Label.Fee_Structure); */
                            
                            if(oa.Lockups_on_Future_M_A_or_Financing_Work__c==null)
                                oa.Lockups_on_Future_M_A_or_Financing_Work__c.addError(Label.Lockups_on_Future_M_A_or_Financing_Work);
                            
                            if(oa.Referral_Fee__c==null)
                                oa.Referral_Fee__c.addError(Label.Referral_Fee_Owed);  
                            
                            //--Administrative
                            if(oa.Restricted_List__c==null)
                                oa.Restricted_List__c.addError(Label.Restricted_List);
                            //If on Restricted List, the Date is Required
                            if(oa.Restricted_List__c == 'Yes' && oa.Restricted_List_Date__c == null)
                                oa.Restricted_List_Date__c.addError(Label.Restricted_List_Date);
                            
                            //If Conflicts Check Requested Date is Blank, Explanation is Required
                            if(oa.Conflict_Check_Date__c == null && !String.isBlank(oa.Id))
                                trigger.new[0].addError(Label.Conflict_Check_Date);
                            
                            //If Conflicts Check is True Conflict
                            if(oa.Conflicts_Outcome__c=='True Conflict' && !String.isBlank(oa.Id))
                                oa.Conflicts_Outcome__c.addError(Label.Conflict_True);
                            
                            //If Conflicts Check is Withdrawn/Dead/Expired
                            if((oa.Conflicts_Outcome__c=='Withdrawn' || oa.Conflicts_Outcome__c=='Dead' || oa.Conflicts_Outcome__c=='Expired') && !String.isBlank(oa.Id))
                                oa.Conflicts_Outcome__c.addError(Label.Conflicts_Outcome);
            
							if(!oa.Req_feedback_prior_to_normal_sched_call__c && !oa.Next_Scheduled_Call__c) 
                            Trigger.new[0].addError(Label.Next_Scheduled_Call);
                        	if(oa.Req_feedback_prior_to_normal_sched_call__c && oa.Next_Scheduled_Call__c) 
                            Trigger.new[0].addError(Label.Next_Scheduled_Call1); 
                        	
                        	if(oa.Retainer_Creditable__c == null )
                                oa.Retainer_Creditable__c.addError(Label.Is_Retainer_Fee_Creditable);
                            if(oa.Is_Progress_Fee_Creditable__c == null)
                                oa.Is_Progress_Fee_Creditable__c.adderror(Label.Is_Progress_Fee_Creditable);
                    } 
                    
                
                    if(updateopp.size()>0)
                    {
                        update updateopp;
                    }
                }
            }
            else
                Trigger.new[0].addError(Label.readonly); 
                                              
        }
         
       
                
        //Added by Shruthi on 4th Dec 2021
    }  
    
    public boolean HLTeamApproved(Opportunity_Approval__c OA)
    {        
        if(oa.Is_Client_EU__c == 'FALSE'){
            HL_Group hlGroup = new HL_Group('NBC_Public_Deal_Team_Members');
            List<Contact> contactList = hlGroup.GetContacts();
            List<Opportunity_Internal_Team__c> oitList = [SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: oa.Related_Opportunity__c AND Contact__c IN:contactList AND Role__c = 'Public Person' AND End_Date__c = null];
            if(oitList.size() > 0)
                return true;
            else{
                String names = GetMajoritySaleContactNames(contactList);
                Trigger.new[0].addError('HL Internal Team: Please add ' + names + ' to the Public role in the HL Internal Team section.');
                return false;
            }
        }
        if(oa.Is_Client_EU__c == 'TRUE'){
            List<Opportunity_Internal_Team__c> oitPublicList = [SELECT Id FROM Opportunity_Internal_Team__c WHERE Opportunity__c =: oa.Related_Opportunity__c AND Role__c = 'Public Person' AND End_Date__c = null];
            if(oitPublicList.size() > 0)
                return true;
            else{
                Trigger.new[0].addError(Label.checkEngagementTeamRoles1);
                return false;
            }
        }
        return true;
    }    
   
    private String GetMajoritySaleContactNames(List<Contact> cList)
    {
        String names = '';
        if(cList.size() > 2){
            for(Integer i = 0; i<cList.size(); i++){
                Contact c = cList[i];
                if(i < cList.size() - 1)
                    names += c.Name + ', ';
                else
                {
                    names = names.left(names.length() - 2);
                    names += ', or ' + c.Name;
                }
            }
        }
        else
        {
            names = cList[0].Name + ' or ' + cList[1].Name;
        }
        return names;
    }    
}