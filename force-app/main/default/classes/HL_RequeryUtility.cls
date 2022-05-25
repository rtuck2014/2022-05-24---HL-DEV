public with sharing class HL_RequeryUtility {
    public class HL_RequeryUtilityException extends Exception {
    }

    public class SObjectsMetadata {
        public String sobjType;
        public List<Id> objIds;
        public List<String> fields;

        public SObjectsMetadata() {
            sobjType = null;
            objIds = new List<Id>();
            fields = null;
        }
    }

    @TestVisible
    private static Set<String> getFieldNames(SObject sobj, String prefix) {
        Set<String> fields = new Set<String>();

        Map<String, Object> fieldsMap = sobj.getPopulatedFieldsAsMap();

        for (String fieldName : fieldsMap.keySet()) {
            Object obj = fieldsMap.get(fieldName);

            String fullFieldName = (prefix == null) ? fieldName : prefix + '.' + fieldName;

            if (obj instanceof SObject) {
                fields.addAll(getFieldNames((SObject) obj, fullFieldName));

            } else {
                fields.add(fullFieldName);
            }
        }

        return fields;
    }

    public static SObjectsMetadata getMetadata(List<SObject> lstSObject) {
        SObjectsMetadata results = new SObjectsMetadata();

        Set<String> fields = new Set<String>();

        for (SObject sobj : lstSObject) {
            if (sobj == null) {
                continue;
            }

            String newSobjType = sobj.getSObjectType().getDescribe().getName();

            if ((results.sobjType != null) && (results.sobjType != newSobjType)) {
                throw new HL_RequeryUtilityException('Mixed SObject types - ' + results.sobjType + ' - ' + newSobjType);
            }

            results.sobjType = newSobjType;

            results.objIds.add(sobj.Id);

            fields.addAll(getFieldNames(sobj, null));
        }

        results.fields = new List<String>(fields);

        return results;
    }

    // getPopulatedFieldsAsMap doesn't populate values that are null, even if they were queried.  The result
    // is that you get an error - SObject row was retrieved via SOQL without querying the requested field.
    // By cloning the sobject (not using the built-in clone method), the SObject doesn't seem to be marked as
    // having originated from a SOQL query, and you can then access fields that were null (and get null)

    @TestVisible
    private static SObject clone(SObject sobj) {
        if (sobj == null) {
            return null;
        }

        SObject result = sobj.getSObjectType().newSObject();

        Map<String, Schema.SObjectField> sobjFieldMap = sobj.getSObjectType().getDescribe().fields.getMap();

        // System.debug('sobjFieldMap - ' + sobjFieldMap);

        Map<String, Object> fieldsMap = sobj.getPopulatedFieldsAsMap();

        for (String fieldName : fieldsMap.keySet()) {
            // System.debug('fieldName - ' + fieldName);

            Object obj = fieldsMap.get(fieldName);

            if (obj instanceof SObject) {
                result.putSObject(fieldName, clone((SObject) obj));

            } else {
                Schema.SObjectField sobjField = sobjFieldMap.get(fieldName);

                if (fieldName.equalsIgnoreCase('Id') || sobjField.getDescribe().isUpdateable()) {
                    result.put(fieldName, obj);
                }
            }
        }

        return result;
    }

    public static List<SObject> requery(List<Id> objIds, String sobjType, List<String> fields) {
        String soql = 'SELECT ' + String.join(fields, ',') + ' FROM ' + sobjType + ' WHERE Id IN :objIds';
        Map<Id, SObject> resultMap = new Map<Id, SObject>(Database.query(soql));

        List<SObject> lstSObject = new List<SObject>();

        // this is to try to guarantee that the sobjects wind up in the same order that they were originally, 
        // and not in some arbitrary order returned by the SOQL query.  probably doesn't matter, but just 
        // trying to ensure that no bugs are introduced when requerying

        for (Id objId : objIds) {
            SObject sobj = resultMap.remove(objId);

            if (sobj != null) {
                lstSObject.add(clone(sobj));
            }
        }

        return lstSObject;
    }
}