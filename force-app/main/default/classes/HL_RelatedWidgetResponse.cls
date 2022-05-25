global with sharing class HL_RelatedWidgetResponse {
    @AuraEnabled
    global String title { get; set; }
  
    @AuraEnabled
    global String iconName { get; set; }
  
    @AuraEnabled
    global List<HL_RelatedWidgetItem> items { get; set; }
  
    @AuraEnabled
    global List<HL_RelatedWidgetItemValue> fields { get; set; }
  
    global HL_RelatedWidgetResponse() {
    }
  
    global HL_RelatedWidgetResponse(String title, String iconName) {
      this.title = title;
      this.iconName = iconName;
    }
  
    global void addItem(HL_RelatedWidgetItem item) {
      if (items == null) {
        items = new List<HL_RelatedWidgetItem>();
      }
  
      items.add(item);
    }
  
    global void addField(HL_RelatedWidgetItemValue item) {
      if (fields == null) {
        fields = new List<HL_RelatedWidgetItemValue>();
      }
  
      fields.add(item);
    }
  }