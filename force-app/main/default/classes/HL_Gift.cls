public with sharing class HL_Gift {
	public HL_Gift() {
		
	}

	public static Gift__c GetById(Id id){
        List<Gift__c> giftList = Database.Query(GetFullSelect() + 
                                          'FROM Gift__c ' + 
                                          'WHERE Id =: Id');
        return giftList.size() > 0 ? giftList[0] : null;
    }
    
    public static string GetFullSelect(){
        Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Gift__c.fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
        String q = 'SELECT ';
        // Build dynamic query string
        for(Schema.SObjectField s : fldObjMapValues)
        q += s.getDescribe().getName() + ',';
        // Trim last comma
		q = q.subString(0, q.length() - 1);
        return q + ' ';
    }
}