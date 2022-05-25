global without sharing class HL_MassRelationshipCreation
{
    public String HLContactId				{	get;set;	}
    public String HLContactName			{	get;set;	}
    public String ShowContact				{	get;set;	}
    public String EntityId					{	get;set;	}
    public String PicklistValue			{	get;set;	}
    private Map<String, Schema.SObjectType> GlobalDescribeMap;
    public String EntityType {get {if(entityType == null) {entityType = HL_Utility.GetObjectTypeById(EntityId);} return entityType; } set;}
    public String EntityBase {get{return EntityType.remove('__c');}}
    public HL_MassRelationshipCreation() {
        Initialization();
        PicklistValue = GetPicklistValue('Relationship__c', 'Strength_Rating__c');
        EntityId = HL_PageUtility.GetParameter('Id');
    }
    global class RelationshipWrapper
    {
        public String ContactName		{	get;set;	}
        public String ContactId			{	get;set;	}
        public String RelationshipId		{	get;set;	}
        public String CompanyName		{	get;set;	}
        public String AppearOn			{	get;set;	}
        public String StrenghScore		{	get;set;	}
        public Boolean SyncOutlook		{	get;set;	}

        public RelationshipWrapper(String ContactName, String ContactId, String RelationshipId,
                                   String CompanyName, String AppearOn, String StrenghScore, Boolean SyncOutlook)
        {
            this.ContactName = ContactName;
            this.ContactId = ContactId;
            this.RelationshipId = RelationshipId;
            this.CompanyName = CompanyName;
            this.AppearOn = AppearOn;
            this.StrenghScore = StrenghScore;
            this.SyncOutlook = SyncOutlook;
        }
    }

    private void Initialization()
    {
        GlobalDescribeMap = Schema.getGlobalDescribe();
        EntityId = HLContactId = HLContactName = PicklistValue = '';
        ShowContact = 'All_Contacts';
    }

    public List<SelectOption> GetContactOptions()
    {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new Selectoption('All_Contacts', 'All Contacts'));
        optionList.add(new Selectoption('External_Team', 'External Team'));
        optionList.add(new Selectoption('Client_Team', 'Client Team'));
        optionList.add(new Selectoption('Counterparty_Contacts', 'Counterparty Contacts'));
        return optionList;
    }

    @RemoteAction
    global static List<RelationshipWrapper> GetRelationshipRecords(String parentId, String hlContactId, String contactOption)
    {
        String entityType = HL_Utility.GetObjectTypeById(parentId);
        String entityBase = entityType.remove('__c');
        List<RelationshipWrapper> relationshipWrapperList = new List<RelationshipWrapper>();
        Set<String> clientContactIdSet = new Set<String>();
        Set<String> externalContactIdSet = new Set<String>();
        Set<String> counterpartyContactIdSet = new Set<String>();
        Map<String, Relationship__c> contactIdToRelationshipMap = new Map<String, Relationship__c>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        if(contactOption == 'All_Contacts')
        {
            clientContactIdSet = getContactIds(EntityBase + '_External_Team__c', entityType, parentId, 'Contact__c', 'Type__c', 'Client');
            externalContactIdSet = getContactIds(EntityBase + '_External_Team__c', entityType, parentId, 'Contact__c', 'Type__c', 'External');
            counterpartyContactIdSet = getContactIds(EntityBase + '_Counterparty_Contact__c', 'Counterparty__r.' + entityType, parentId, 'Contact__c', '', '');
        }
        else if(ContactOption == 'External_Team')
            externalContactIdSet = getContactIds(EntityBase + '_External_Team__c', entityType, parentId, 'Contact__c', 'Type__c', 'External');
        else if(ContactOption == 'Client_Team')
            clientContactIdSet = getContactIds(EntityBase + '_External_Team__c', entityType, parentId, 'Contact__c', 'Type__c', 'Client');
        else if(ContactOption == 'Counterparty_Contacts')
            counterpartyContactIdSet = getContactIds(EntityBase + '_Counterparty_Contact__c', 'Counterparty__r.' + entityType, parentId, 'Contact__c', '', '');

        contactMap = new Map<Id, Contact>([SELECT Id ,
                                               Name,
                                               Account.Name
                                               FROM Contact
                                               WHERE (Id IN:externalContactIdSet
                                                      OR Id IN:clientContactIdSet
                                                      OR Id IN:counterpartyContactIdSet)
                                               AND RecordType.DeveloperName = 'External_Contact']);

        for(Relationship__c objRelationship : [SELECT Id,
                                               HL_Contact__c,
                                               External_Contact__c,
                                               Sync_to_Outlook__c,
                                               Strength_Rating__c
                                               FROM Relationship__c
                                               WHERE External_Contact__c IN:contactMap.keySet()
                                               AND HL_Contact__c =: HLContactId ])
        {
            contactIdToRelationshipMap.put(objRelationship.HL_Contact__c + '=' + objRelationship.External_Contact__c, objRelationship);
        }

        for(Contact contactRecord : contactMap.values())
        {
            string appearOn = (clientContactIdSet.contains(contactRecord.Id)) ? 'Client Team'
                : (externalContactIdSet.contains(contactRecord.Id)) ? 'External Team': 'Counterparty Contact';

            if(contactIdToRelationshipMap.containskey(hlContactId + '=' + contactRecord.Id))
            {
                relationshipWrapperList.add(new RelationshipWrapper(contactRecord.Name, contactRecord.Id,
                                                  contactIdToRelationshipMap.get(HLContactId + '=' + contactRecord.Id).Id,
                                                  contactRecord.Account.Name, appearOn,
                                                  contactIdToRelationshipMap.get(HLContactId + '=' + contactRecord.Id).Strength_Rating__c,
                                                  contactIdToRelationshipMap.get(HLContactId + '=' + contactRecord.Id).Sync_to_Outlook__c));
            }
            else
            {
                relationshipWrapperList.add(new RelationshipWrapper(contactRecord.Name, contactRecord.Id,'', contactRecord.Account.Name, appearOn, '', false));
            }
        }

        return relationshipWrapperList;
    }

    private static Set<String> GetContactIds(string sObjectName, string parentRelationship,
                                             string parentId, string contactRelationship,
                                             string type, string typeValue)
    {
        Set<String> contactIdSet = new Set<String>();
        String query = 'SELECT Id, ' + contactRelationship + ' FROM '+ sObjectName + ' WHERE ' + parentRelationship + ' = \'' + parentId +'\'';
        query += (String.isNotBlank(type) && String.isNotEmpty(type) &&  String.isNotBlank(typeValue) && String.isNotEmpty(typeValue))
            ? 'AND ' + type + ' = \'' + typeValue + '\'' : '';

        for(Sobject sobj : Database.query(query))
        {
            if(sobj.get(contactRelationship) != null)
                contactIdSet.add(String.valueOf(sobj.get(contactRelationship)));
        }
        return contactIdSet;
    }

    @RemoteAction
    public static List<Relationship__c> UpsertRelationshipRecords(List<Relationship__c> relationshipRecords){
        upsert relationshipRecords;
        return relationshipRecords;
    }

    @RemoteAction
    public static string UpsertRelationshipRecord(string relationshipId, string hlContactId, string contactId, string strengthScore, boolean syncOutlook)
    {
        Relationship__c objRelationShip = new Relationship__c(HL_Contact__c = hlContactId,
                                                              External_Contact__c = contactId,
                                                              Strength_Rating__c = (strengthScore != 'none') ? strengthScore : '',
                                                              Sync_to_Outlook__c = syncOutlook);

        if(RelationshipId != '' && RelationshipId != null)
            objRelationShip.Id = RelationshipId;

        upsert 	objRelationShip;
        return objRelationShip.Id;
    }

    private string GetPicklistValue(string sObjectName, string fieldName)
    {
        Schema.SObjectType targetType = GlobalDescribeMap.get(sObjectName);
        Sobject sObjectClass = targetType.newSObject();
        Schema.sObjectType sObjectType = sObjectClass.getSObjectType();
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        String picklist = '';

        for (Schema.PicklistEntry a : picklistValues)
            picklist += (picklist == '') ? a.getValue():  ':' + a.getValue();

        return picklist;
    }

    public PageReference Cancel()
    {
        return new PageReference('/' + EntityId);
    }
}