public with sharing class HL_OpportunityApproval {
      public static Opportunity_Approval__c GetById(string Id){
        List<Opportunity_Approval__c> oa = Database.Query(GetFullSelect() + 
                                                          'FROM Opportunity_Approval__c ' + 
                                                          'WHERE Id =: Id');
        return oa.size() > 0 ? oa[0] : null;
    }
    
    public static string GetFullSelect(){
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Opportunity_Approval__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String q = 'SELECT Related_Opportunity__r.Name, ';
        // Build dynamic query string
        for(Schema.SObjectField s : fldObjMapValues)
           q += s.getDescribe().getName() + ',';
        // Trim last comma
		q = q.subString(0, q.length() - 1);
        return q + ' ';
    }
}