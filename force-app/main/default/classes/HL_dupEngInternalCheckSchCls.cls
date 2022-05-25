global class HL_dupEngInternalCheckSchCls implements Schedulable{
    global void execute(SchedulableContext ctx){        
        List<DuplicateEngInternalWrapper> lstDuplicateEngInternal = new List<DuplicateEngInternalWrapper>();
        Set<String> setEngIds = new Set<String>();
        
        String htmlBody = '<html><head><style>table {font-family: arial, sans-serif; border-collapse: collapse; width: 100%;}td, th { border: 1px solid #dddddd;  text-align: left;  padding: 8px;}tr:nth-child(even) {  background-color: #dddddd;}</style></head><body> <P> This automated message is to inform you of the following duplicate records on Engagement Internal Team </p> <br/><table><tr><th>Engagement Number</th><th>Engagement</th><th>Line Of Business</th><th>Contact</th><th>Duplicate Staff Role Name</th></tr>';
        List<AggregateResult> grpInternalTeamRecords = [Select Engagement__r.Name EngName,Engagement__c EngId, Staff_Role__r.Name SName, Contact__r.Name conName, Contact__c ConId, count(Name) dupCount from Engagement_Internal_Team__c where End_Date__c = null AND CreatedDate = LAST_N_DAYS:365 group by Engagement__r.Name,Engagement__c, Staff_Role__r.Name, Contact__r.Name, Contact__c having count(Name) > 1 limit 200];
        if(grpInternalTeamRecords != null && grpInternalTeamRecords.size() > 0){
            for(AggregateResult ar : grpInternalTeamRecords){
                Integer recCount = Integer.valueOf(ar.get('dupCount'));
                if(recCount > 1){
                    DuplicateEngInternalWrapper objDuplicateEngInternal = new DuplicateEngInternalWrapper();
                    objDuplicateEngInternal.EngName = String.valueOf(ar.get('EngName'));
                    objDuplicateEngInternal.EngId = String.valueOf(ar.get('EngId'));
                    objDuplicateEngInternal.ContactName = String.valueOf(ar.get('conName'));
                    objDuplicateEngInternal.ContactId = String.valueOf(ar.get('ConId'));
                    objDuplicateEngInternal.StaffRole = String.valueOf(ar.get('SName'));
                    lstDuplicateEngInternal.add(objDuplicateEngInternal);
                    setEngIds.add(objDuplicateEngInternal.EngId);
                }
            }
            if(setEngIds.size() > 0){
                Map<String,Engagement__c> mapEng = new Map<String,Engagement__c>([SELECT Id, Engagement_Number__c, Line_Of_Business__c FROM Engagement__c WHERE Id in :setEngIds]);
                for(DuplicateEngInternalWrapper objDuplicateEngInternal : lstDuplicateEngInternal){
                    htmlBody = htmlBody + '<tr><td>'+ mapEng.get(objDuplicateEngInternal.EngId).Engagement_Number__c+'</td><td><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/' + objDuplicateEngInternal.EngId + '">' + objDuplicateEngInternal.EngName + '</a></td><td>' + mapEng.get(objDuplicateEngInternal.EngId).Line_Of_Business__c + '</td><td><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/' + objDuplicateEngInternal.ContactId + '">' + objDuplicateEngInternal.ContactName + '</a></td><td>'+objDuplicateEngInternal.StaffRole+'</td></tr>';
                }
                htmlBody = htmlBody + '</table> <br/> <p> Thanks and Regards, <br/> Salesforce Administrator. </p> </body></html>';
                List<String> userIdsToSendEmail = new List<String>();
                Map<String,User> mapGrpUsers = new Map<String,User>([Select Email from User where Id in (SELECT UserOrGroupId FROM GroupMember where Group.Name = 'InternalTeamDuplicateNotification')]);
                if(mapGrpUsers != null && mapGrpUsers.size() > 0){
                    userIdsToSendEmail.addAll(mapGrpUsers.keySet());        
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(userIdsToSendEmail);
                    mail.setSubject('Duplicate EngagementInternal Team Role ');
                    mail.setHTMLBody(htmlBody);
                    try{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
                    }
                    catch(Exception ex){
                        System.debug(ex);
                    }
                }
            }
            
        }
    }
    public class DuplicateEngInternalWrapper{
        public string EngName {get;set;}
        public string EngId {get;set;}
        public string ContactName {get;set;}
        public string ContactId {get;set;}
        public string StaffRole {get;set;}
    }
    
}