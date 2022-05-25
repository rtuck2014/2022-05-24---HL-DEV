public with sharing class HL_RelationshipController {
    private Contact CurrentContact{get; set;}
    private Id RelId {get; set;}
    public String SortDirection {get{return sortDirection == null ? 'ASC' : sortDirection;} set;}
    public Integer ActualCount{get; set;}
    public ApexPages.StandardController Controller {get; set;}
    public String NewSort {get; set;}
    public String SortField {get{return sortField == null ? CurrentContact.RecordType.DeveloperName == 'External_Contact' ? 'HL_Contact__r.Name' : 'External_Contact__r.Name' : sortField;} set{
        ToggleDirection(value);
        SortField = value;
    }}
    public Boolean HasNoteAccess{
        get{return HL_Relationship.HasFullAccess(RelId, UserInfo.getUserId());}
    }
    public Boolean IsS1{
        get{return HL_PageUtility.isS1();}
    }
    public List<Relationship__c> GetRelationships(){
        return setCon.getRecords();
    }
    public HL_RelationshipController(ApexPages.StandardController con){
        Controller = con;
        RelId = con.getId();
        if(HL_Utility.GetObjectTypeById(RelId) == 'Contact')
        	CurrentContact = (Contact)con.getRecord();
    }
    public PageReference SaveAndReturn(){
        PageReference pf = Controller.Save();
        if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
            Relationship__c r = (Relationship__c)Controller.getRecord();
            return new PageReference('/' + r.External_Contact__c);
        }
        else{
            return pf;
        }
    }
    
    public PageReference ReturnToContact(){
       Relationship__c r = (Relationship__c)Controller.getRecord();
       return new PageReference('/' + r.External_Contact__c);
    }
    
    public ApexPages.StandardSetController setCon {
        get{  
            if(setCon == null){
                setCon = new ApexPages.StandardSetController(Database.query(HL_Relationship.STANDARD_SELECT + 
                                                                            'FROM Relationship__c ' +
                                                                            'WHERE '  + GetWhereClause() +
                                                                            'ORDER BY ' + SortField + ' ' + SortDirection + ' ' +
                                                                            'LIMIT 1000'));
                ActualCount = Database.countQuery('SELECT COUNT() ' +
                                                  'FROM Relationship__c ' +
                                                  'WHERE ' + GetWhereClause()
                                           	      ); 
            }
            return setCon;
        }
        set;
    }
    
    public void ApplySort()
    {
        setCon = null;
        SortField = NewSort;
    }
    
    private string GetWhereClause(){
        return (CurrentContact.RecordType.DeveloperName == 'External_Contact' ? 'External_Contact__c' : 'HL_Contact__c') + ' =: RelId ';
    }
    public void ToggleDirection(string newSort){
        setCon = null;
        SortDirection = (SortField == newSort) ? (SortDirection == 'DESC' ? 'ASC' : 'DESC') : 'ASC';
    }
}