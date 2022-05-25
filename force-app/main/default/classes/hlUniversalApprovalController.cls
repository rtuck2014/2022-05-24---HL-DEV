public with sharing class hlUniversalApprovalController {
    //===============================================================================================
    //Purpose: Controller for hlUniversalApproval (Lightning Web Components)
    //Author: Larry Leonidas - Invest Apex Solutions 7/13/2019
    //Description - Returns Tree Grid approval data set for a particular target Object Id
    //===============================================================================================
    @AuraEnabled(cacheable=true)
    public static List<ApprovalWrap> getApprovalHistory(String objectId){
        system.debug('getApprovalHistory--01-engageSumId: '+ String.escapeSingleQuotes(objectId));
        String oId = String.escapeSingleQuotes(objectId);
        String qry = 'SELECT Id, ProcessDefinition.name, CreatedDate, LastModifiedDate, CompletedDate, Status, ';
        qry += '(SELECT createddate, Id, ActorId, OriginalActorId, StepStatus, Comments FROM StepsAndWorkitems order by StepStatus ASC, createddate DESC) ';
        qry += 'FROM ProcessInstance where targetobjectId = :oId order by createddate DESC ';
        List<ApprovalWrap> aws = new List<ApprovalWrap>();
        List<Id> actorIds = new List<Id>();
        for(ProcessInstance pi: Database.query(qry)){
            for(ProcessInstanceHistory sw: pi.StepsAndWorkitems){
                actorIds.add(sw.ActorId);
                actorIds.add(sw.OriginalActorId);
            }
        }
        system.debug('getApprovalHistory--02-actorIds.size(): '+ actorIds.size());
        Map<Id, String> mapUserIdtoName = new Map<Id, String>();
        for(User u: [Select Id, Name FROM User WHERE Id IN :actorIds]){
            mapUserIdtoName.put(u.Id, u.Name);
        }
        system.debug('getApprovalHistory--03-mapUserIdtoName.size(): '+ mapUserIdtoName.size());
        List<ProcessInstance> epis = Database.query(qry);
        Integer submitCount = epis.size();
        for(ProcessInstance pi: epis){
            ApprovalWrap aw = new ApprovalWrap();
            aw.Id = pi.Id;
            aw.Submission = 'Submit ' + submitCount;
            if(pi.Status == 'Removed')
                aw.Status = 'Recalled';
            else aw.Status = pi.Status;
            aw.CreatedDate = pi.CreatedDate;
            aw.StepDate = pi.LastModifiedDate;
            Boolean latestActorSet = false;
            Boolean latestCommentSet = false;
            List<ApprovalChildWrap> awcList = new List<ApprovalChildWrap>();
            for(ProcessInstanceHistory sw: pi.StepsAndWorkitems){
                ApprovalChildWrap awc = new ApprovalChildWrap();
                awc.StepDate = sw.CreatedDate;
                awc.OriginalActorName = mapUserIdtoName.get(sw.OriginalActorId);
                awc.ActorName = mapUserIdtoName.get(sw.ActorId);
                awc.Comments = sw.Comments;
                if(latestCommentSet == false && sw.Comments != null){
                    aw.Comments = sw.Comments;
                    latestCommentSet = true;
                } 
                if(sw.StepStatus == 'Removed')
                    awc.Status = 'Recalled';
                else awc.Status = sw.StepStatus;
                awcList.add(awc);
            }
            aw.items = awcList;
            aws.add(aw);
            submitCount -= 1;
        }
        system.debug('getApprovalHistory--02-aws.size(): '+ aws.size());
        return aws;
    }
    public Class ApprovalWrap{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Submission {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public String OriginalActorName {get;set;}
        @AuraEnabled
        public String ActorName {get;set;}
        @AuraEnabled
        public Datetime StepDate{get;set;}
        @AuraEnabled
        public Datetime CreatedDate {get;set;}
        @AuraEnabled
        public String Comments {get;set;}
        @AuraEnabled
        public List<ApprovalChildWrap> items {get;set;}
    }
    public Class ApprovalChildWrap{
        @AuraEnabled
        public Datetime StepDate{get;set;}
        @AuraEnabled
        public String OriginalActorName {get;set;}
        @AuraEnabled
        public String ActorName {get;set;}
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public String Comments {get;set;}
    }
}