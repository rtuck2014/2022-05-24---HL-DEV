public without sharing class HL_JSONUtility {
    public static List<SObject> ConvertJSONToListOfSObject(String sObjectType, String json) {
        List<SObject> newSObjectsList = new List<SObject>();
        Object[] values;
        values = (Object[])System.JSON.deserializeUntyped(json);
        
        for (Object v : values) {
            Map<String, Object> m = (Map<String, Object>)v;

            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType);

            SObject o = targetType.newSObject();
            
            Map<String, Schema.SObjectField> fields = targetType.getDescribe().fields.getMap();
            for (String fieldName : m.keySet()) {
                Schema.SObjectField fi = fields.get(fieldName);
                if (fi != null) {
                    if ((fi.getDescribe().isCreateable() && fi.getDescribe().isUpdateable()) || fi.getDescribe().isIdLookup()) {
                        o.put(fieldName, m.get(fieldName)); 
                    }
                }
            } 
            newSObjectsList.add(o);
        } 
        return newSObjectsList;
    }
}