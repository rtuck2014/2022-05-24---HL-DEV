global with sharing class HL_RelatedWidgetController {
    private static String getIconName(String sObjectName) {
      List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
  
      // TODO - this doesn't seem to work for objects in managed packages - look into it and fix
  
      for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
        for (Schema.DescribeTabResult tr : tsr.getTabs()) {
          if (sObjectName.equalsIgnoreCase(tr.getSobjectName())) {
            if (tr.isCustom()) {
              for (Schema.DescribeIconResult ir : tr.getIcons()) {
                if (ir.getContentType() == 'image/svg+xml') {
                  return 'custom:' +
                    ir.getUrl()
                      .substringBetween('custom/', '.svg')
                      .substringBefore('_');
                }
              }
            } else {
              return 'standard:' + sObjectName.toLowerCase();
            }
          }
        }
      }
  
      return null;
    }
  
    private static String trim(String value) {
      if (value == null) {
        return null;
      }
  
      String result = value.trim();
  
      if (result.equals('')) {
        return null;
      }
  
      return result;
    }
  
    private static HL_RelatedWidgetItemValue getField(
      String field,
      String fullPath,
      DescribeSObjectResult objResult
    ) {
      Map<String, Schema.SObjectField> mapFieldList = objResult.fields.getMap();
  
      // TODO - check field permissions and skip if user doesn't have permission?  return null?
  
      if (field.contains('.')) {
        String nextField = field.substringAfter('.');
        String relation = field.substringBefore('.');
  
        for (Schema.SObjectField sObjField : mapFieldList.values()) {
          Schema.DescribeFieldResult dfr = sObjField.getDescribe();
  
          if (relation.equalsIgnoreCase(dfr.getRelationshipName())) {
            return getField(
              nextField,
              fullPath,
              dfr.getReferenceTo().get(0).getDescribe()
            ); // call recursively
          }
        }
  
        return null; // TODO - maybe this should be an exception?  field not found
      }
  
      String label = mapFieldList.get(field).getDescribe().getLabel();
  
      return new HL_RelatedWidgetItemValue(fullPath, label);
    }
  
    private static Object getFieldValue(SObject sObj, String field) {
      if (sObj == null) {
        return null;
      }
  
      if (field.contains('.')) {
        String nextField = field.substringAfter('.');
        String relation = field.substringBefore('.');
  
        return getFieldValue((SObject) sObj.getSObject(relation), nextField);
      }
  
      return sObj.get(field);
    }
  
    @AuraEnabled
    global static HL_RelatedWidgetResponse loadData(String requestJson) {
      HL_RelatedWidgetRequest request = (HL_RelatedWidgetRequest) JSON.deserialize(
        requestJson,
        HL_RelatedWidgetRequest.class
      );
  
      HL_RelatedWidgetResponse response = new HL_RelatedWidgetResponse();
  
      String recordId = request.recordId;
      String objectApiName = trim(request.objectApiName);
      String relationshipFieldApiName = trim(request.relationshipFieldApiName);
      String fields = trim(request.fields);
      String userWhereClause = trim(request.whereClause);
      String userOrderByClause = trim(request.orderByClause);
      String titleField = trim(request.titleField);
  
      if (titleField == null) {
        titleField = 'name';
      }
  
      if (
        (objectApiName == null) ||
        (relationshipFieldApiName == null) ||
        (fields == null)
      ) {
        return response;
      }
  
      List<String> fieldList = new List<String>();
  
      List<String> fieldListTmp = fields.split(',');
  
      for (String field : fieldListTmp) {
        field = field.trim();
  
        if (field.equals('')) {
          continue;
        } else if (field.equalsIgnoreCase('Id')) {
          continue;
        }
  
        fieldList.add(field);
      }
  
      //if (fieldList.size() == 0) {
      //	return response;
      //}
  
      DescribeSObjectResult objResult = Schema.getGlobalDescribe()
        .get(objectApiName)
        .getDescribe();
  
      response.title = objResult.getLabelPlural();
      response.iconName = getIconName(objectApiName);
  
      String selectClause = 'SELECT id, ' + titleField;
  
      if (fieldList.size() > 0) {
        selectClause += ', ' + String.join(fieldList, ', ');
      }
  
      String fromClause = ' FROM ' + objectApiName;
  
      String whereClause = 'WHERE ' + relationshipFieldApiName + ' = :recordId';
  
      if (userWhereClause != null) {
        whereClause += ' AND (' + userWhereClause + ')';
      }
  
      String orderByClause = '';
  
      if (userOrderByClause != null) {
        orderByClause = 'ORDER BY ' + userOrderByClause;
      }
  
      String soql =
        selectClause +
        ' ' +
        fromClause +
        ' ' +
        whereClause +
        ' ' +
        orderByClause;
  
      System.debug('soql - ' + soql); // TODO - remove in production
  
      List<sObject> sobjList = Database.query(soql); // TODO - handle exception, or let it bubble back?
  
      for (sObject sobj : sobjList) {
        String itemId = String.valueOf(sobj.get('id'));
        String itemName = String.valueOf(sobj.get(titleField));
  
        HL_RelatedWidgetItem item = new HL_RelatedWidgetItem(itemId, itemName);
  
        for (String field : fieldList) {
          HL_RelatedWidgetItemValue newValue = getField(field, field, objResult);
  
          if (newValue != null) {
            String value = null;
  
            // TODO - maybe just return an object and let it get formatted on the client side
            Object fieldValue = getFieldValue(sobj, field);
  
            // TODO - make sure all field types are formatted correctly
            if (fieldValue instanceof Date) {
              value = ((Date) fieldValue).format();
            } else if (fieldValue instanceof Datetime) {
              value = ((Datetime) fieldValue).format();
            } else {
              value = String.valueOf(fieldValue);
            }
  
            newValue.value = value;
  
            item.addValue(newValue);
          }
        }
  
        response.addItem(item);
      }
  
      for (String field : fieldList) {
        HL_RelatedWidgetItemValue newField = getField(field, field, objResult);
  
        response.addField(newField);
      }
  
      return response;
    }
  }