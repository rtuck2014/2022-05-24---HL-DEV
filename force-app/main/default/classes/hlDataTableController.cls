public with sharing class hlDataTableController {
    public static string getCurrencyWithComma(Decimal dec){
        List<String> args = new String[]{'0.0','number','###,###,##0.00'};
        String str = String.format( dec.format(), args);
         if(!str.contains('.')){
           str = str + '.0';
         }
         return  str;
    }
  @AuraEnabled
  public static List < TableRow > updatelookupToDisplayInTable(List < TableRow > recordDetail, String recordId, String objN, String newVal) {
    for (TableRow tr: recordDetail) {
      if (tr.RecordId == recordId) {
        for (Field f: tr.fields) {
          if (f.isLookup && f.lookupObjectApiName == objN) {
            f.Value = newVal;
          }
        }
      }
    }
    return recordDetail;
  }
  @AuraEnabled
  public static list < TableRow > getTotalAllocationValue(String sobject_name, String field_set_name, String where_clause, String engId) {
    Decimal totalVal = 0.0;
    Decimal otherCreditor = 0;
    Decimal clientHoldingsMM = 0.0;
    Decimal totalFreeAtt = 0.0;
    Decimal totalCH = 0.0;
    Decimal totalKeyCreditor = 0.0;
    Decimal totalDebtPercentage = 0.0;
    list < TableRow > totalRow = new list < TableRow > ();
    try {
        System.debug('field_set_name== ' + field_set_name);
      Schema.FieldSet field_set = getFieldSetForObject(sobject_name, field_set_name);
      String query = getQueryForOjbectFieldSetAndWhereClause(sobject_name, field_set, where_clause);
      System.debug('query== ' + query);
      System.debug('sobject_name== ' + sobject_name);
      if (sobject_name == 'Engagement_Client_Subject__c') {
        Engagement__c eng = [Select Id, Total_Debt_MM__c From Engagement__c Where Id =: engId];
        System.debug('enter if');
        Engagement_Client_Subject__c ecO = new Engagement_Client_Subject__c();
        TableRow table_rowO = new TableRow(ecO, field_set);

        Engagement_Client_Subject__c ec = new Engagement_Client_Subject__c();
        TableRow table_row = new TableRow(ec, field_set);
        System.debug('total table_row== ' + table_row.fields.size());
        List < Engagement_Client_Subject__c > table_records = Database.query(query);
        System.debug('alloctable_records== ' + table_records.size());
        for (Engagement_Client_Subject__c table_record: table_records) {
          if (query.contains('CreditorRevenueAllocationPercentage__c') && table_record.CreditorRevenueAllocationPercentage__c != null) {
            totalVal = totalVal + table_record.CreditorRevenueAllocationPercentage__c;
          }
          /*if (query.contains('FeeAttribution__c') && table_record.FeeAttribution__c != null) {
            totalFreeAtt = totalFreeAtt + table_record.FeeAttribution__c;
          }*/
          if (query.contains('ClientHoldings__c') && table_record.ClientHoldings__c != null) {
            totalCH = totalCH + table_record.ClientHoldings__c;
          }
          if (query.contains('DebtHoldingsMM__c') && table_record.DebtHoldingsMM__c != null) {
            otherCreditor = otherCreditor + table_record.DebtHoldingsMM__c;
          }
          if (query.contains('ClientHoldingsMM__c') && table_record.ClientHoldingsMM__c != null) {
            clientHoldingsMM = clientHoldingsMM + table_record.ClientHoldingsMM__c;
          }
          if (query.contains('KeyCreditorWeighting__c') && table_record.KeyCreditorWeighting__c != null) {
            totalKeyCreditor = totalKeyCreditor + table_record.KeyCreditorWeighting__c;
          }
          if (query.contains('DebtPercentage__c') && table_record.DebtPercentage__c != null) {
            totalDebtPercentage = totalDebtPercentage + table_record.DebtPercentage__c;
          }
        }

        if (eng.Total_Debt_MM__c == null)
          eng.Total_Debt_MM__c = 0;
        if (query.contains('DebtPercentage__c') || query.contains('DebtHoldingsMM__c')) {
          for (Field f: table_rowO.fields) {
            if (f.FirstField == true) {
              f.Value = 'Other Creditors';
            }
            if (f.FieldApiName == 'DebtHoldingsMM__c') {
              f.isCurrency = true;
              f.isPercentage = false;
              f.Value = otherCreditor != null ? String.valueOf(getCurrencyWithComma(eng.Total_Debt_MM__c.setScale(1) - otherCreditor.setScale(1))) : String.valueOf(getCurrencyWithComma(eng.Total_Debt_MM__c.setScale(1)));
            }
            if (f.FieldApiName == 'DebtPercentage__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              //f.Value = String.valueOf((100 - totalDebtPercentage).setScale(1));
              decimal d = (100 - totalDebtPercentage).setScale(1);
              d=d<0?0:d;
              f.Value = String.valueOf(d);
            }
          }
          totalRow.add(table_rowO);
        }

        if (query.contains('DebtPercentage__c') || query.contains('KeyCreditorWeighting__c') || query.contains('ClientHoldingsMM__c') || query.contains('ClientHoldings__c') || query.contains('CreditorRevenueAllocationPercentage__c') || query.contains('DebtHoldingsMM__c')) {
          for (Field f: table_row.fields) {
            if (f.FirstField == true) {
              f.Value = 'Total';
            }
            //RevenueAllocation__c
            if (f.FieldApiName == 'CreditorRevenueAllocationPercentage__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              f.Value = String.valueOf(totalVal.setScale(1));
              f.cssClass=getCssClass(totalVal);
            } else if (f.FieldApiName == 'KeyCreditorWeighting__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              f.Value = String.valueOf(totalKeyCreditor.setScale(1));
              f.cssClass=getCssClass(totalKeyCreditor);
            } else if (f.FieldApiName == 'DebtPercentage__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              Decimal totalNum = 100;
              f.Value = String.valueOf(totalNum.setScale(1));
              f.cssClass=getCssClass(totalNum);
            } else if (f.FieldApiName == 'DebtHoldingsMM__c') {
              f.isCurrency = true;
              f.isPercentage = false;
              f.Value = eng.Total_Debt_MM__c != null ? String.valueOf(getCurrencyWithComma(eng.Total_Debt_MM__c.setScale(1))) : '0.0';   
            } else if (f.FieldApiName == 'ClientHoldingsMM__c') {
                f.isCurrency = true;
                f.isPercentage = false;
                f.Value = String.valueOf(clientHoldingsMM.setScale(1));            
            } else if (f.FieldApiName == 'ClientHoldings__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              f.Value = String.valueOf(totalCH.setScale(1));
              f.cssClass=getCssClass(totalCH);
            }
          }
          totalRow.add(table_row);
        }
      }
 else {
        Opportunity__c opp = [Select Id, Total_Debt_MM__c From Opportunity__c Where Id =: engId];
        System.debug('enter ele');
        Opportunity_Client_Subject__c ecO = new Opportunity_Client_Subject__c();
        TableRow table_rowO = new TableRow(ecO, field_set);

        Opportunity_Client_Subject__c ec = new Opportunity_Client_Subject__c();
        TableRow table_row = new TableRow(ec, field_set);
        System.debug('total table_row== ' + table_row.fields.size());
        List < Opportunity_Client_Subject__c > table_records = Database.query(query);
        System.debug('alloctable_records== ' + table_records.size());
        for (Opportunity_Client_Subject__c table_record: table_records) {
            System.debug('table_record-- for 1'+JSon.serialize(table_record));
          if (query.contains('RevenueAllocation__c') && table_record.RevenueAllocation__c != null) {
            totalVal = totalVal + table_record.RevenueAllocation__c;
          }
          /*
          if (query.contains('FeeAttribution__c') && table_record.FeeAttribution__c != null) {
            totalFreeAtt = totalFreeAtt + table_record.FeeAttribution__c;
          }*/
          if (query.contains('ClientHoldings__c') && table_record.ClientHoldings__c != null) {
            totalCH = totalCH + table_record.ClientHoldings__c;
          }
          if (query.contains('DebtHoldingsMM__c') && table_record.DebtHoldingsMM__c != null) {
            otherCreditor = otherCreditor + table_record.DebtHoldingsMM__c;
          }
          if (query.contains('ClientHoldingsMM__c') && table_record.ClientHoldingsMM__c != null) {
            clientHoldingsMM = clientHoldingsMM + table_record.ClientHoldingsMM__c;
          }
          if (query.contains('KeyCreditorWeighting__c') && table_record.KeyCreditorWeighting__c != null) {
            totalKeyCreditor = totalKeyCreditor + table_record.KeyCreditorWeighting__c;
          }
          if (query.contains('DebtPercentage__c') && table_record.DebtPercentage__c != null) {
            totalDebtPercentage = totalDebtPercentage + table_record.DebtPercentage__c;
          }
        }

        if (opp.Total_Debt_MM__c == null)
          opp.Total_Debt_MM__c = 0;
        if (query.contains('DebtPercentage__c') || query.contains('DebtHoldingsMM__c')) {
          for (Field f: table_rowO.fields) {
              System.debug('table_record-- f1'+JSon.serialize(f));
            if (f.FirstField == true) {
              f.Value = 'Other Creditors';
            }
            if (f.FieldApiName == 'DebtHoldingsMM__c') {
              f.isCurrency = true;
              f.isPercentage = false;
              //f.Value = otherCreditor != null ? String.valueOf(opp.Total_Debt_MM__c.setScale(1) - otherCreditor.setScale(1)) : String.valueOf(opp.Total_Debt_MM__c.setScale(1));
              f.Value = otherCreditor != null ? String.valueOf(getCurrencyWithComma(opp.Total_Debt_MM__c.setScale(1) - otherCreditor.setScale(1))) : String.valueOf(getCurrencyWithComma(opp.Total_Debt_MM__c.setScale(1)));
            }
            if (f.FieldApiName == 'DebtPercentage__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              decimal d = (100 - totalDebtPercentage).setScale(1);
              d=d<0?0:d;
              f.Value = String.valueOf(d);
            }
          }
          totalRow.add(table_rowO);
        }

        if (query.contains('DebtPercentage__c') || query.contains('KeyCreditorWeighting__c') || query.contains('ClientHoldings__c') 
            || query.contains('ClientHoldingsMM__c') || query.contains('RevenueAllocation__c') || query.contains('DebtHoldingsMM__c')) {
          for (Field f: table_row.fields) {
              System.debug('table_record-- f2'+JSon.serialize(f));
            if (f.FirstField == true) {
              f.Value = 'Total';
            }
            //RevenueAllocation__c
            if (f.FieldApiName == 'RevenueAllocation__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              f.Value = String.valueOf(totalVal.setScale(1));
              f.cssClass=getCssClass(totalVal);
            } else if (f.FieldApiName == 'KeyCreditorWeighting__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              f.Value = String.valueOf(totalKeyCreditor.setScale(1));
              f.cssClass=getCssClass(totalKeyCreditor);
            } else if (f.FieldApiName == 'DebtPercentage__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              Decimal totalNum = 100;
              f.Value = String.valueOf(totalNum.setScale(1));
              f.cssClass=getCssClass(totalNum);
            } else if (f.FieldApiName == 'ClientHoldingsMM__c') {
              f.isCurrency = true;
              f.isPercentage = false;
              f.Value = String.valueOf(clientHoldingsMM.setScale(1));
              //f.Value = String.valueOf(getCurrencyWithComma(clientHoldingsMM.setScale(1))) : '0.0';
            } else if (f.FieldApiName == 'DebtHoldingsMM__c') {
              f.isCurrency = true;
              f.isPercentage = false;
              //f.Value = opp.Total_Debt_MM__c != null ? String.valueOf(opp.Total_Debt_MM__c.setScale(1)) : '0.0';
 				      f.Value = opp.Total_Debt_MM__c != null ? String.valueOf(getCurrencyWithComma(opp.Total_Debt_MM__c.setScale(1))) : '0.0';
                system.debug('DebtHoldingsMM__c-- '+f.Value);
            } else if (f.FieldApiName == 'ClientHoldings__c') {
              f.isCurrency = false;
              f.isPercentage = true;
              f.Value = String.valueOf(totalCH.setScale(1));
              f.cssClass=getCssClass(totalCH);
            }
          }
          totalRow.add(table_row);
        }
      }
    } catch (Exception e) {
      //dataTableMethodResult.handleException(e);
    }
    return totalRow;
  }
  private static String getCssClass(decimal d){
    String cssClass='';
    System.debug('d:'+d);
    if(d==null||d==0){
      cssClass='';
    }else if(d!=100){
      cssClass='slds-text-color_error';
    }
    return cssClass;
  }
  public static Map < String, String > getEditableFieldName(String sobject_name) {
    Map < String, String > allFieldName = new Map < String, String > ();

    SObjectType objToken = Schema.getGlobalDescribe().get(sobject_name);
    DescribeSObjectResult objDef = objToken.getDescribe();
    Map < String, Schema.SObjectField > allMap = objDef.fields.getMap();
    for (Schema.SobjectField field: allMap.values()) {
      Schema.DescribeFieldResult dfr = field.getDescribe();
      if ( /*dfr.isAccessible() && */ dfr.isUpdateable())
        allFieldName.put(dfr.getName(), dfr.getLabel());
    }
    return allFieldName;
  }
  @AuraEnabled
  public static List < TableRow > saveRecordsToDisplayInTable(List < TableRow > recordDetail, String sobject_name) {
    Map < String, String > allFieldName = getEditableFieldName(sobject_name);
    //system.debug('allFieldName-- '+JSON.serialize(allFieldName));
    List < sObject > table_records = new List < sObject > ();
    for (TableRow tr: recordDetail) {
      sObject obj = Schema.getGlobalDescribe().get(sobject_name).newSObject();
      obj.Id = tr.RecordId;
      for (Field f: tr.fields) {
        //system.debug('field-- '+allFieldName.get(f.FieldApiName));
        if (allFieldName.get(f.FieldApiName) != null && f.Value != null) {
          if (f.FieldType == 'CURRENCY' || f.FieldType == 'DECIMAL' || f.FieldType == 'PERCENT' || f.FieldType == 'DOUBLE') {
            system.debug('f.FieldType ' + f.FieldType);
            if (f.Value == null || f.Value == '')
              f.Value = string.valueOf(0);
            obj.put(f.FieldApiName, decimal.valueOf(f.Value.replaceAll(',','')));
          } else if (f.FieldType == 'BOOLEAN') {
            obj.put(f.FieldApiName, boolean.valueOf(f.boolVal));
          } else { //CURRENCY BOOLEAN
            obj.put(f.FieldApiName, string.valueOf(f.Value));
          }
        } else if (f.FieldApiName == 'KeyCreditorImportance__c' && (string.valueOf(f.Value) == '' || string.valueOf(f.Value) == null))
          obj.put(f.FieldApiName, 'Medium');
      }
      system.debug('obj-- ' + JSON.serialize(obj));
      table_records.add(obj);
    }
    if (table_records.size() > 0) {
      try {
        update table_records;
      } catch (DmlException e) {
        System.debug(Logginglevel.ERROR, e.getMessage());
        throw new AuraHandledException(e.getMessage());
      }
    }
    return recordDetail;
  }
  @AuraEnabled
  public static List < TableRow > updateRecordsToDisplayInTable(List < TableRow > recordDetail, String recordId, String fieldApiName, String newVal, Boolean boolVal) {
    for (TableRow tr: recordDetail) {
      if (tr.RecordId == recordId) {
        for (Field f: tr.fields) {
          if (f.FieldApiName == fieldApiName && f.FieldType == 'BOOLEAN') {
            f.boolVal = boolVal;
          }
          if (f.FieldApiName == fieldApiName) {
            f.Value = newVal;
          }
        }
      }
    }
    return recordDetail;
  }
  @AuraEnabled
  public static DataTableResult getRecordsToDisplayInTable(String sobject_name, String field_set_name, String where_clause, String engId) {

    //Properties
    DataTableResult dataTableMethodResult = new DataTableResult();

    try {
      Schema.FieldSet field_set = getFieldSetForObject(sobject_name, field_set_name);
      if (sobject_name == 'Engagement_Client_Subject__c') {
        Engagement__c eng = [Select Id, Total_Debt_Currency__c from Engagement__c Where Id =: engId limit 1];
        if (eng.Total_Debt_Currency__c != null) {
          String curVal = eng.Total_Debt_Currency__c;
          list < String > strLst = curVal.split('-');
          dataTableMethodResult.setFieldLabels(field_set, strLst[0]);
        } else {
          dataTableMethodResult.setFieldLabels(field_set);
        }
      } else {
        Opportunity__c opp= [Select Id,Total_Debt_Currency__c  from Opportunity__c Where Id =: engId limit 1];
        if (opp.Total_Debt_Currency__c != null) {
          String curVal = opp.Total_Debt_Currency__c;
          list < String > strLst = curVal.split('-');
          dataTableMethodResult.setFieldLabels(field_set, strLst[0]);
        } else {
          dataTableMethodResult.setFieldLabels(field_set);
        }
      }

      String query = getQueryForOjbectFieldSetAndWhereClause(sobject_name, field_set, where_clause);
      System.debug('query== ' + query);
      List < sObject > table_records = Database.query(query);

      for (sObject table_record: table_records) {
        TableRow table_row = new TableRow(table_record, field_set);
        dataTableMethodResult.tableRows.add(table_row);
      }
    } catch (Exception e) {
      dataTableMethodResult.handleException(e);
    }
    return dataTableMethodResult;
  }
  private static Schema.FieldSet getFieldSetForObject(String sobject_name, String field_set_name) {
    system.debug('sobject_name-- ' + sobject_name);
    system.debug('field_set_name-- ' + field_set_name);
    Map < String, Schema.SObjectType > global_describe = Schema.getGlobalDescribe();

    if (!global_describe.containsKey(sobject_name)) {
      throw new FlowTableSelectionException('Bad object specified ' + sobject_name);
    }

    Schema.SObjectType sobject_type = global_describe.get(sobject_name);
    Schema.DescribeSObjectResult sobject_type_describe = sobject_type.getDescribe();
    if (!sobject_type_describe.FieldSets.getMap().containsKey(field_set_name)) {
      throw new FlowTableSelectionException('Can\'t find fieldset ' + field_set_name);
    }
    return sobject_type_describe.FieldSets.getMap().get(field_set_name);
  }
  private static String getQueryForOjbectFieldSetAndWhereClause(String sobject_name, Schema.FieldSet field_set, String where_clause) {
    List < String > fields_api_name = new List < String > ();
    for (Schema.FieldSetMember fieldset_member: field_set.getFields()) {
      fields_api_name.add(fieldset_member.getFieldPath());
    }
    String query = 'SELECT RecordTypeId, ' + String.join(fields_api_name, ', ') + ' FROM ' + sobject_name;
    if (!String.isBlank(where_clause)) {
      query += ' WHERE ' + where_clause;
    }else{
      query+=' ORDER BY Client_Subject__r.Name';
    }
    return query;
  }
  public class DataTableResult {
    @AuraEnabled
    public List < TableRow > tableRows {
      get;
      set;
    }
    @AuraEnabled
    public List < TableHead > FieldLabels {
      get;
      set;
    }
    @AuraEnabled
    public Boolean Success {
      get;
      set;
    }
    @AuraEnabled
    public String ErrorMessage {
      get;
      set;
    }

    public DataTableResult() {
      this.Success = true;
      this.tableRows = new List < TableRow > ();
      this.FieldLabels = new List < TableHead > ();
    }

    public void handleException(Exception e) {
      this.Success = false;
      this.ErrorMessage = e.getMessage();
    }
    public void setFieldLabels(Schema.FieldSet field_set, String curVal) {
      Integer i = 0;
      for (Schema.FieldSetMember fieldset_member: field_set.getFields()) {
        //this.FieldLabels.add(fieldset_member.getLabel());
        //TableHead th = new TableHead();
        if (i == 0) {
          this.FieldLabels.add(new TableHead(fieldset_member.getLabel(), true,fieldset_member.getSObjectField().getDescribe().getInlineHelpText()));
        } else {
          if (fieldset_member.getLabel() == 'Debt Holdings (MM)' || fieldset_member.getLabel() == 'Client Holdings (MM)')
            this.FieldLabels.add(new TableHead(fieldset_member.getLabel() + ' - ' + curVal, false,fieldset_member.getSObjectField().getDescribe().getInlineHelpText()));
          else
            this.FieldLabels.add(new TableHead(fieldset_member.getLabel(), false,fieldset_member.getSObjectField().getDescribe().getInlineHelpText()));
        }
        i++;
      }
    }
    public void setFieldLabels(Schema.FieldSet field_set) {
      Integer i = 0;
      for (Schema.FieldSetMember fieldset_member: field_set.getFields()) {
        //this.FieldLabels.add(fieldset_member.getLabel());
        //TableHead th = new TableHead();
        if (i == 0) {
          this.FieldLabels.add(new TableHead(fieldset_member.getLabel(), true,fieldset_member.getSObjectField().getDescribe().getInlineHelpText()));
        } else {
          this.FieldLabels.add(new TableHead(fieldset_member.getLabel(), false,fieldset_member.getSObjectField().getDescribe().getInlineHelpText()));
        }
        i++;
      }
    }
  }
  public class TableHead {
    @AuraEnabled
    public String label {
      get;
      set;
    }
    @AuraEnabled
    public Boolean FirstField {
      get;
      set;
    }
    @AuraEnabled
    public String inlineHelpText{get;set;}

    public TableHead(String name, Boolean fField, String helpText) {
      this.label = name;
      this.FirstField = fField;
      this.inlineHelpText = helpText;
    }
  }
  public class TableRow {
    @AuraEnabled
    public List < Field > fields {
      get;
      set;
    }
    @AuraEnabled
    public Id RecordId {
      get;
      set;
    }
    @AuraEnabled
    public String RecordTypeId {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isChecked {
      get;
      set;
    }
    public TableRow() {

    }
    public TableRow(sObject record, Schema.FieldSet field_set) {
      this.isChecked = false;
      this.RecordId = record.Id;
      this.RecordTypeId = (Id) record.get('RecordTypeId');
      this.fields = new List < Field > ();
      for (Schema.FieldSetMember fieldset_member: field_set.getFields()) {
        Field table_row_field = new Field(record, fieldset_member, this.fields.isEmpty());
        this.fields.add(table_row_field);
      }
    }
  }

  public class Field {
    @AuraEnabled
    public String Value {
      get;
      set;
    }
    @AuraEnabled
    public String perValue {
      get;
      set;
    }
    @AuraEnabled
    public Boolean boolVal {
      get;
      set;
    }
    @AuraEnabled
    public String FieldType {
      get;
      set;
    }
    @AuraEnabled
    public String FieldApiName {
      get;
      set;
    }
    @AuraEnabled
    public Boolean FirstField {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isPicklist {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isString {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isLookup {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isPercentage {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isCurrency {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isFormula {
      get;
      set;
    }
    @AuraEnabled
    public Boolean isBoolean {
      get;
      set;
    }
    @AuraEnabled
    public String lookupObjectApiName {
      get;
      set;
    }
    @AuraEnabled
    public String cssClass{get;set;}
    

    public Field() {}
    public Field(sObject record, Schema.FieldSetMember fieldset_member, Boolean first_field) {

      this.FirstField = first_field;
      String field_api_name = fieldset_member.getFieldPath();
      this.FieldType = String.valueOf(fieldset_member.getType());
      this.FieldApiName = field_api_name;
      this.Value = null;
      if (record != null && record.Id != null) {
        Id recId = record.Id;
        String sObjName = recId.getSObjectType().getDescribe().getName();
        this.isFormula = field_api_name == 'DebtPercentage__c' ? true : false;
        this.isPicklist = FieldType == 'PICKLIST' ? true : false;
        this.isString = FieldType == 'STRING' ? true : false;
        this.isLookup = FieldType == 'REFERENCE' ? true : false;
        this.isPercentage = FieldType == 'PERCENT' ? true : false;
        this.isCurrency = FieldType == 'CURRENCY' ? true : false;
        this.isBoolean = FieldType == 'BOOLEAN' ? true : false;
        if (FieldType == 'REFERENCE') {
          this.lookupObjectApiName = getLookupFieldObjName(sObjName, field_api_name);
        }
        
      }
      if (record.get(field_api_name) != null) {
        if (this.FieldType == 'DATE') {
          this.Value = ((Date) record.get(field_api_name)).format();
        } else if (this.FieldType == 'BOOLEAN') {
          this.Value = String.valueOf(record.get(field_api_name));
          this.boolVal = Boolean.valueOf(record.get(field_api_name));
        } else if (this.FieldType == 'DATETIME') {
          this.Value = ((DateTime) record.get(field_api_name)).format();
        } else if (this.FieldType == 'PERCENT') {//.setScale(1)
          this.Value = String.valueOf((Decimal) record.get(field_api_name));
          if (String.valueOf((Decimal) record.get(field_api_name)) != null || String.valueOf((Decimal) record.get(field_api_name)) != '') {
            this.perValue = String.valueOf((Decimal) record.get(field_api_name)) + ' %';
          }
        } else if (this.FieldType == 'CURRENCY')  {
          Decimal cur = (Decimal) record.get(field_api_name);
          this.Value = String.valueOf(getCurrencyWithComma(cur.setScale(1)));
        }else {
          this.Value = String.valueOf(record.get(field_api_name));
        }
      }
    }

   
    public String getLookupFieldObjName(String objectName, String fieldName) {
      String lookupObjectApiName;
      Schema.DescribeFieldResult f = Schema.getGlobalDescribe()
        .get(objectName)
        .getDescribe()
        .fields
        .getMap()
        .get(fieldName)
        .getDescribe();

      for (Schema.SObjectType reference: f.getReferenceTo()) {
        lookupObjectApiName = reference.getDescribe().getName();
        System.debug('Lookup reference object name: ' + reference.getDescribe().getName());
        System.debug('Lookup reference object label: ' + reference.getDescribe().getLabel());
      }
      return lookupObjectApiName;
    }
  }
  //fetch picklist values from custom object in lwc
  @AuraEnabled(cacheable = true)
  public static List < customValueWrapper > pickListValueDynamically(sObject customObjInfo, string selectPicklistApi) {
    Schema.DescribeSObjectResult objDescribe = customObjInfo.getSObjectType().getDescribe();
    map < String, Schema.SObjectField > customFieldMap = objDescribe.fields.getMap();
    list < Schema.PicklistEntry > custPickValues = customFieldMap.get(selectPicklistApi).getDescribe().getPickListValues();
    list < customValueWrapper > customObjWrapper = new list < customValueWrapper > ();
    customValueWrapper selectOptionValueWrapperAll = new customValueWrapper();
    selectOptionValueWrapperAll.label = 'All';
    selectOptionValueWrapperAll.value = 'All';
    customObjWrapper.add(selectOptionValueWrapperAll);
    for (Schema.PicklistEntry myCustPick: custPickValues) {
      customValueWrapper selectOptionValueWrapper = new customValueWrapper();
      selectOptionValueWrapper.label = myCustPick.getLabel();
      selectOptionValueWrapper.value = myCustPick.getValue();
      customObjWrapper.add(selectOptionValueWrapper);
    }

    return customObjWrapper;

  }
  // wrapper class
  public with sharing class customValueWrapper {
    @auraEnabled public string label {
      get;
      set;
    }
    @auraEnabled public string value {
      get;
      set;
    }
  }
   
   
  @TestVisible
  private class FlowTableSelectionException extends Exception {}
}