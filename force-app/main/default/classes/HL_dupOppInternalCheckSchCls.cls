global class HL_dupOppInternalCheckSchCls implements Schedulable{
    global void execute(SchedulableContext ctx){        
List<DuplicateOppInternalWrapper> lstDuplicateOppInternal = new List<DuplicateOppInternalWrapper>();
Set<String> setOppIds = new Set<String>();

        String htmlBody = '<html><head><style>table {font-family: arial, sans-serif; border-collapse: collapse; width: 100%;}td, th { border: 1px solid #dddddd;  text-align: left;  padding: 8px;}tr:nth-child(even) {  background-color: #dddddd;}</style></head><body> <P> This automated message is to inform you of the following duplicate records on Opportunity Internal Team </p> <br/><table><tr><th>Opportunity Number</th><th>Opportunity</th><th>Line Of Business</th><th>Contact</th><th>Duplicate Staff Role Name</th></tr>';
        List<AggregateResult> grpInternalTeamRecords = [Select Opportunity__r.Name OppName,Opportunity__c oppId, Staff_Role__r.Name SName, Contact__r.Name conName, Contact__c ConId, count(Name) dupCount from opportunity_Internal_Team__c where End_Date__c = null AND CreatedDate = LAST_N_DAYS:365 group by Opportunity__r.Name,Opportunity__c, Staff_Role__r.Name, Contact__r.Name, Contact__c having count(Name) > 1 limit 200];
        if(grpInternalTeamRecords != null && grpInternalTeamRecords.size() > 0){
            for(AggregateResult ar : grpInternalTeamRecords){
                Integer recCount = Integer.valueOf(ar.get('dupCount'));
                if(recCount > 1){
DuplicateOppInternalWrapper objDuplicateOppInternal = new DuplicateOppInternalWrapper();
objDuplicateOppInternal.OppName = String.valueOf(ar.get('OppName'));
objDuplicateOppInternal.OppId = String.valueOf(ar.get('oppId'));
objDuplicateOppInternal.ContactName = String.valueOf(ar.get('conName'));
objDuplicateOppInternal.ContactId = String.valueOf(ar.get('ConId'));
objDuplicateOppInternal.StaffRole = String.valueOf(ar.get('SName'));
lstDuplicateOppInternal.add(objDuplicateOppInternal);
setOppIds.add(objDuplicateOppInternal.OppId);
                }
            }
if(setOppIds.size() > 0){
Map<String,Opportunity__c> mapOpp = new Map<String,Opportunity__c>([SELECT Id, Opportunity_Number__c, Line_Of_Business__c FROM Opportunity__c WHERE Id in :setOppIds]);
for(DuplicateOppInternalWrapper objDuplicateOppInternal : lstDuplicateOppInternal){
htmlBody = htmlBody + '<tr><td>'+ mapOpp.get(objDuplicateOppInternal.OppId).Opportunity_Number__c+'</td><td><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/' + objDuplicateOppInternal.OppId + '">' + objDuplicateOppInternal.OppName + '</a></td><td>' + mapOpp.get(objDuplicateOppInternal.OppId).Line_Of_Business__c + '</td><td><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/' + objDuplicateOppInternal.ContactId + '">' + objDuplicateOppInternal.ContactName + '</a></td><td>'+objDuplicateOppInternal.StaffRole+'</td></tr>';
}
htmlBody = htmlBody + '</table> <br/> <p> Thanks and Regards, <br/> Salesforce Administrator. </p> </body></html>';
List<String> userIdsToSendEmail = new List<String>();
Map<String,User> mapGrpUsers = new Map<String,User>([Select Email from User where Id in (SELECT UserOrGroupId FROM GroupMember where Group.Name = 'InternalTeamDuplicateNotification')]);
if(mapGrpUsers != null && mapGrpUsers.size() > 0){
userIdsToSendEmail.addAll(mapGrpUsers.keySet());        
Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
mail.setToAddresses(userIdsToSendEmail);
mail.setSubject('Duplicate Opportunity Internal Team Role ');
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
public class DuplicateOppInternalWrapper{
public string OppName {get;set;}
public string OppId {get;set;}
public string ContactName {get;set;}
public string ContactId {get;set;}
public string StaffRole {get;set;}
}
     
   }