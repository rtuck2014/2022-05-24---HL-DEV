/** @description CalendarAnything Describe Core
  * @author  Den Sorokin  
*/
global with sharing class SL_RTR_LIB16_ME_DescribeObject_Core {

    /**
    * @description instance for singletone pattern
    */
    private static SL_RTR_LIB16_ME_DescribeObject_Core m_instance =  null;
    
    /**  @description Compact mode */
    private Boolean bCompactMode = false;
    private Boolean bFullLoad = false;
     
    /**  @description Objects describe cache */    
    private Map<String, Schema.SObjectType> m_objects = new Map<String, Schema.SObjectType>();
    
    /**  @description map of objects describe info */
    private Transient Map<String, Schema.DescribeSObjectResult> m_described_objects = new Map<String, Schema.DescribeSObjectResult>();
    
    /**  @description map of objects prefix -> object name */
    private Transient Map<String, String> aPrefix2Name = new Map<String, String>();
    
    /**  @description  map of map of objects fields describe info */
    private Transient Map<String, Map<String, Schema.DescribeFieldResult>> m_described_fields_by_object = new Map<String, Map<String, Schema.DescribeFieldResult>>();
    
    /**  @description  list of all fields with OBJECTNAME##FIELDNAME serialization */
    private static Map <String, Schema.DescribeFieldResult> mapObjectField = new Map <String, Schema.DescribeFieldResult>();
    
    /**  @description  cache of getData results */
    private static Map <String, List<sObject>> aQueryCache= new Map <String, List <sObject>>();
    
    /**  @description  map of IsFieldUpdateable data for  OBJECTNAME###FIELDNAME serialization */
    private static Map <String, Boolean> aObjectFieldUpdateable = new Map <String, Boolean>();
    
    /**  @description   current project NameSpace (used for SLCA2 package)*/
    //public static String sNameSpace = Type.forName('SLCA2.CA_iCalWSDL') != null ? 'slca2__' : '';
    public static String sNameSpace = ''; 
    
    /**  @description   global describe*/
    private static Map<String, Schema.SObjectType> aGlobalDescribe = Schema.getGlobalDescribe();

    /**  @description map of restricted fields in queries*/
    private static Map <String, Set<String>> aRestrictedFields = new Map<String, Set<String>>{
        'event' => new Set<String>{'durationinminutes', 
            'activitydate', 
            'activitydatetime'
//          'recurrencedayofweekmask', 'recurrencestartdatetime', 'recurrenceinterval', 'recurrencetimezonesidkey',
//          'recurrenceactivityid', 'recurrenceenddateonly', 'recurrencetype', 'recurrencemonthofyear',
//          'recurrenceinstance', 'isrecurrence', 'recurrencedayofmonth'
        },
//        'task' => new Set<String>{'recurrencestartdateonly'},
//        'lead' => new Set<String>{'name'},
//        'contact' => new Set<String>{'name'},
        'partnernetworkconnection' => new Set<String>{'name'},
        'contract' => new Set<String>{'name', 'statuscode'},
        'orderitem' => new Set<String>{'name'},
        'solution' => new Set<String>{'name'},
        'collaborationgroupmemberrequest' => new Set<String>{'name'},
        'contracthistory' => new Set<String>{'name'},
        'crontrigger' => new Set<String>{'name'},
        'processinstancehistory' => new Set<String>{'name'},
        'caseteamtemplatemember' => new Set<String>{'name'},
        
        'orgwideemailaddress' => new Set<String>{'name'},
        'dashboardfeed' => new Set<String>{'name'},
        'emailservicesfunction' => new Set<String>{'name'},
        
        'campaign' => new Set<String>{'numberofconvertedleads', 'numberofresponses', 'numberofopportunities',
            'numberofwonopportunities', 'numberofleads', 'numberofcontacts', 
            'amountwonopportunities', 'amountallopportunities'}
    };
    /**  @description list of objects that have no name field */
    private static Set<String> aNoNamesObjects = new Set<String>{
        'accountcontactrole', 'accountfeed', 'accounthistory', 'accountpartner', 'accountshare', 'activityhistory', 
        'aggregateresult', 'apexlog', 'apextestqueueitem', 'apextestresult', 'approval', 'assetfeed', 
        'asyncapexjob', 'ca_calendar__share', 'ca_groups__share', 
        'ca_webcalendar__share', 'campaignfeed', 'campaignmember', 
        'campaignmemberstatus', 'campaignshare', 'case', 'casecomment', 
        'casecontactrole', 'casefeed', 'casehistory', 'caseshare', 'casesolution', 
        'casestatus', 'caseteammember', 'caseteamtemplatemember', 'caseteamtemplaterecord', 
        'categorynode', 'chatteractivity', 'collaborationgroupfeed', 'collaborationgroupmember', 'collaborationgroupmemberrequest', 
        'collaborationinvitation', 'contactfeed', 'contacthistory', 'contactshare', 'contentdocument', 
        'contentdocumentfeed', 'contentdocumenthistory', 'contentdocumentlink', 'contentversion', 'contentversionhistory', 
        'contract', 'categorydata', 'contractcontactrole', 'contractfeed', 'contracthistory', 'contractstatus', 
        'crontrigger', 'dashboard', 'dashboardcomponentfeed', 'dashboardfeed', 'documentattachmentmap', 
        'emailservicesaddress', 'emailservicesfunction', 'emailstatus', 'entitysubscription', 'event', 'eventattendee', 
        'eventfeed', 'feedcomment', 'feeditem', 'feedlike', 'feedtrackedchange', 'fieldpermissions', 'forecastshare', 
        'groupmember', 'icalendar_tester__share', 'idea', 'ideacomment', 'leadfeed', 'leadhistory', 'leadshare', 
        'leadstatus', 'loginhistory', 'newsfeed', 'note', 'noteandattachment', 'objectpermissions', 'openactivity', 
        'opportunitycompetitor', 'opportunitycontactrole', 'opportunityfeed', 'opportunityfieldhistory', 
        'opportunityhistory', 'opportunitylineitem', 'opportunitypartner', 'opportunityshare', 'opportunitystage', 
        'orgwideemailaddress', 'partner', 'partnerrole', 'period', 'permissionsetassignment', 
        'processinstance', 'processinstancehistory', 'processinstancestep', 'processinstanceworkitem', 
        'product2feed', 'queuesobject', 'reportfeed', 'sitedomain', 'sitefeed', 'sitehistory', 'solution', 
        'solutionfeed', 'solutionhistory', 'solutionstatus', 'task', 'taskfeed', 'taskpriority', 
        'taskrelation', 'taskstatus', 'userfeed', 'userpreference', 'userprofilefeed', 
        'userrecordaccess', 'vote', 'orderitem', 'partnernetworkconnection', 'question'
    };
    
    /**  @description list of fields that can be used as alternatrive name field */
    private static Map<String, String> aSpecialObjectNamesField = new Map<String, String>{
        'accountcontactrole' => 'id', 'accountfeed' => 'id', 'accounthistory' => 'id', 
        'accountpartner' => 'id', 'activityhistory' => 'subject', 
        'aggregateresult' => 'id', 'apexlog' => 'id', 'apextestqueueitem' => 'id', 
        'apextestresult' => 'id', 'approval' => 'id', 'assetfeed' => 'id', 
        'asyncapexjob' => 'id', 'campaignfeed' => 'id', 'campaignmember' => 'id', 
        'campaignmemberstatus' => 'id', 
        'case' => 'casenumber', 'casecomment' => 'id', 'casecontactrole' => 'id', 
        'casefeed' => 'id', 'casehistory' => 'id', 'casesolution' => 'id', 
        'casestatus' => 'id', 'caseteammember' => 'id', 'caseteamtemplatemember' => 'id',
        'caseteamtemplaterecord' => 'id', 'categorydata' => 'id', 'categorynode' => 'id', 
        'chatteractivity' => 'id', 'collaborationgroupfeed' => 'id', 'collaborationgroupmember' => 'id', 
        'collaborationgroupmemberrequest' => 'id', 'collaborationinvitation' => 'id', 'contactfeed' => 'id', 
        'contacthistory' => 'id', 
        'categorydata' => 'id', 'contentdocument' => 'title', 'contentdocumentfeed' => 'id', 
        'contentdocumenthistory' => 'id', 'contentdocumentlink' => 'id', 'contentversion' => 'title', 
        'contentversionhistory' => 'id', 'contract' => 'contractnumber', 'contractcontactrole' => 'id', 
        'contractfeed' => 'id',
        'contracthistory' => 'id', 'contractstatus' => 'id', 'crontrigger' => 'id', 
        'dashboard' => 'title', 'dashboardcomponentfeed' => 'id', 'dashboardfeed' => 'id', 
        'documentattachmentmap' => 'id', 'emailservicesaddress' => 'localpart', 'emailservicesfunction' => 'functionname', 
        'emailstatus' => 'id',
        'entitysubscription' => 'id', 'event' => 'subject', 'eventattendee' => 'id', 
        'eventfeed' => 'id', 'feedcomment' => 'id', 'feeditem' => 'id', 
        'feedlike' => 'id', 'feedtrackedchange' => 'id', 'fieldpermissions' => 'id',
        'groupmember' => 'id', 'idea' => 'title', 'ideacomment' => 'id', 
        'leadfeed' => 'id', 'leadhistory' => 'id', 'leadstatus' => 'id', 
        'loginhistory' => 'id', 'newsfeed' => 'id',
        'note' => 'title', 'noteandattachment' => 'id', 'objectpermissions' => 'id', 
        'openactivity' => 'subject', 'opportunitycompetitor' => 'id', 'opportunitycontactrole' => 'id', 
        'opportunityfeed' => 'id', 'opportunityfieldhistory' => 'id', 'opportunityhistory' => 'id', 
        'opportunitylineitem' => 'id',
        'opportunitypartner' => 'id', 'opportunitystage' => 'id', 'orgwideemailaddress' => 'id', 
        'partner' => 'id', 'partnerrole' => 'id', 'period' => 'id', 
        'permissionsetassignment' => 'id', 'processinstance' => 'id', 'processinstancehistory' => 'id',
        'orderitem' => 'id', 'partnernetworkconnection' => 'id', 'processinstancestep' => 'id', 
        'processinstanceworkitem' => 'id', 'product2feed' => 'id', 'queuesobject' => 'id', 
        'reportfeed' => 'id', 'sitedomain' => 'domain', 'sitefeed' => 'id', 'sitehistory' => 'id',
        'orderitem' => 'id', 'partnernetworkconnection' => 'id', 'solutionhistory' => 'id', 
        'solutionstatus' => 'id', 'task' => 'subject', 'taskfeed' => 'id', 
        'taskpriority' => 'id', 'taskrelation' => 'id', 'taskstatus' => 'id', 
        'userfeed' => 'id',
        'orderitem' => 'id', 'partnernetworkconnection' => 'id', 'userrecordaccess' => 'id', 'vote' => 'id',
        'question' => 'title'       
    }; 
    
    /**  @description list of relation fields for polymorphic fields */
    private static Map<String, String> aPolymorphicNameObject = new Map<String, String>{
        'name' => 'STRING', 'firstname' => 'STRING', 'lastname' => 'STRING', 'type' => 'PICKLIST', 
        'userroleid' => 'REFERENCE', 'alias' => 'STRING' 
    };
    
    
    
    /**
     * @return SL_RTR_LIB16_ME_DescribeObject_Core - Singletone base method
     */
    public static SL_RTR_LIB16_ME_DescribeObject_Core getInstance() { 
        if(m_instance == null) {
            m_instance = new SL_RTR_LIB16_ME_DescribeObject_Core();
        }
        return m_instance; 
    }
    
    /**
     * @description SL_RTR_LIB16_ME_DescribeObject_Core - Constructor
     */
    public SL_RTR_LIB16_ME_DescribeObject_Core() {
        //this.RefreshObjects();
    }
    
    /**
     * @param objectName String name of object
     * @return SObject new sObject for given object name
     */
    public sObject getRecordByTypeName(string objectName) {
        objectName = objectName != null ? objectName.toLowerCase() : null;
        this.checkObject(objectName);
        return m_objects.containsKey(objectName) ? m_objects.get(objectName).newsObject() : null;
    }
    
    /**
     * @description init list of objects with describe info 
     */
    public void RefreshObjects() {
        if (this.bFullLoad) {
            return;
        }
        this.bFullLoad = true;
        system.debug('=== loading all objects');
        for (String object_name : SL_RTR_LIB16_ME_DescribeObject_Core.aGlobalDescribe.keySet()) {
            if (this.m_described_objects.containskey(object_name)) {
                continue;
            }
            this.addObjInfo(SL_RTR_LIB16_ME_DescribeObject_Core.aGlobalDescribe.get(object_name));

        }
    }


    private Boolean checkObject(String sObjectName) {
    	if(sObjectName==null || sObjectName=='') return false;	

        if (this.m_described_objects.containskey(sObjectName)) {
            return true;
        }
        if (SL_RTR_LIB16_ME_DescribeObject_Core.aGlobalDescribe.containsKey(sObjectName)) {
            this.addObjInfo(SL_RTR_LIB16_ME_DescribeObject_Core.aGlobalDescribe.get(sObjectName));
            return true;
        }
        if (sObjectName.endsWith('__c')) {
            String[] aParts = sObjectName.split('__');
            if (aParts.size() == 3) {
                sObjectName = aParts[1] + '__c';
                if (SL_RTR_LIB16_ME_DescribeObject_Core.aGlobalDescribe.containsKey(sObjectName)) {
                    this.addObjInfo(SL_RTR_LIB16_ME_DescribeObject_Core.aGlobalDescribe.get(sObjectName));
                    return true;
                }
            }
        }

        this.refreshObjects();
        return false;
    }

    private Schema.DescribeSObjectResult addObjInfo(Schema.SObjectType oObjType) {
        Schema.DescribeSObjectResult oObjDescribe = oObjType.getDescribe();
        String sName = oObjDescribe.getName().toLowerCase();
        this.m_described_objects.put(sName, oObjDescribe);
        this.m_objects.put(sName, oObjType);
        this.aPrefix2Name.put(oObjDescribe.getKeyPrefix(), sName);
        return oObjDescribe;
    }

    /**
     * @description List of field describe info for some object  
     * @param objectName String - name of the object 
     * @return Map<String,Schema.DescribeFieldResult> list of fields with describe information 
     */
    public Map<String, Schema.DescribeFieldResult> getFieldsDescribesByObjectName(string objectName) {
        objectName = objectName != null ? objectName.toLowerCase() : null;
        
        if (m_described_fields_by_object == null) {
            m_described_fields_by_object = new Map<String, Map<String, Schema.DescribeFieldResult>>();
        }
        if (!m_described_fields_by_object.containsKey(objectName)) {
            objectName = this.getNSObjectName(objectName);
            if (!m_described_fields_by_object.containsKey(objectName)) {
                this.addFieldsForDefinedObjectToMap(objectName);
            } 
            
        }
        system.debug('=== objectName for fields ' + objectName
           + ' / ' + SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace.replace('__', '') + '.' + objectName
           + ' / ' 
           + this.isTypeExist(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + objectName));
        return m_described_fields_by_object.containsKey(objectName) 
            ? m_described_fields_by_object.get(objectName) 
            : null;
    }
    
    /**
     * @description List of field describe info for some object
     * @param objectName String name of object 
     * @param bHidden Boolean flag to indicate if hidden fields need to be included 
     * @return Map<String,Schema.DescribeFieldResult> list of fields with describe information 
     */
    public Map<String, Schema.DescribeFieldResult> getFieldsDescribesByObjectName(string objectName, Boolean bHidden) {
        if (bHidden == null || !bHidden) {
            return this.getFieldsDescribesByObjectName(objectName);
        }
         
        return this.getDecribedFieldsByObject(objectName, true);
        
    } 
    
    public static Boolean isStringNullOrEmpty(String value)
    {
        Boolean result = false;
        if(value == null || value == '' || value == 'null') {
            result = true; 
        }
        return result; 
    }
    
    //currently works only for textfields and for picklists, have no time to improve types support
    /**
     * @description Default value for some field
     * @param objectName String object name
     * @param FieldName String field name
     * @return String default value for given field
     */
    public string getDefaultFieldValueByName(string objectName, string FieldName) {
        objectName = objectName != null ? objectName.toLowerCase() : null;
        FieldName = FieldName != null ? FieldName.toLowerCase() : null;
        Map<String, Schema.DescribeFieldResult> FieldsForThisObject = this.getFieldsDescribesByObjectName(objectName);
        if (FieldsForThisObject == null || !FieldsForThisObject.containsKey(FieldName)) {
            return '';
        }
        Schema.DescribeFieldResult oField = FieldsForThisObject.get(FieldName); 
        if (oField.getType() == Schema.Displaytype.STRING 
            || oField.getType() == Schema.Displaytype.TEXTAREA
        ) {
            string retString = (string)(oField.getDefaultValue());
            if (!SL_RTR_LIB16_ME_DescribeObject_Core.isStringNullOrEmpty(retString)) {
                return retString;
            }
            // value is a simple string, so we should remove quotes if it isn't empty

            retString = (string)(oField.getDefaultValueFormula());
            //return empty string if default value isn't specified
            if(SL_RTR_LIB16_ME_DescribeObject_Core.isStringNullOrEmpty(retString)) {
                return '';
            }
                
            return retString.substring(1, retString.length() - 1);
        } else if (oField.getType() == Schema.Displaytype.PICKLIST) {
            List<Schema.Picklistentry> allValues = oField.getPicklistValues();
            
            for (Schema.Picklistentry curEntry:allValues) {
                if(curEntry.isDefaultValue()) {
                    return curEntry.getValue();
                }
            }
        } else if (oField.getType() == Schema.Displaytype.BOOLEAN) {
            return string.valueOf( (boolean)(oField.getDefaultValue()) );
        }
        
        return '';
    }
    
    /**
     * @param objectName String object name
     * @return void
     * @description Add describe info for object to cache
     */
    private void addFieldsForDefinedObjectToMap(string objectName)
    {
        m_described_fields_by_object.put(objectName, getDecribedFieldsByObject(objectName, false));
    }
    
    /**
     * @description Get Objects list as pairs [SF Name, Label]
     * @param selectedType String type of objects  
     * @return Map<String,String> list of objects (SF name => label) for given type
     */
    public Map<String, String> getObjects(String  sSelectedType) {
        Map<String, String> result = new Map<String, String>();
        this.refreshObjects();
        for (String object_name : m_described_objects.keySet()) {
            Schema.DescribeSObjectResult object_describe_result = m_described_objects.get(object_name);
            if (!object_describe_result.isAccessible()) {
                continue;
            }
            if (sSelectedType == 'All Objects' 
                || (sSelectedType == 'Standard Objects' && !object_describe_result.isCustom())
                || (sSelectedType == 'Custom Objects' && object_describe_result.isCustom() )
            ) {
                result.put(object_name, object_describe_result.getLabel());
            } 
        }
        return result;  
    }
    
    /**
     * @return Map<String,String> all objects  Name and Label 
     */
/*    public Map<String, String> getAllObjects() {
        return getObjects(CA_Options.ALL_OBJECT_TYPE_NAME);
    }
*/    
    /**
     * \return Map<String, String> custom objects  Name and Label 
     */
    /*public Map<String, String> getCustomObjects() {
        return getObjects(CA_Options.CUSTOM_OBJECT_TYPE_NAME);
    } 
    */
    /**
     * \return Map<String, String> Standard objects  Name and Label 
     */
/*    public Map<String, String> getStandardObjects() {
        return getObjects(CA_Options.STANDART_OBJECT_TYPE_NAME);
    } 
*/    
    
    /**
     * @param sObjectName String object type
     * @return Map<String, String> - list of objects with label
     */
    
/*    public Map<String, String> getFilteredObjects( String  sSelectedType ) {
        Map<String, String> aResult = new Map<String, String>();
        Map<String, String> aObjects = this.getObjects( sSelectedType );
        
        Set<String> aDefaultObjects = new Set<String>();
        for ( Default_Standard_Objects_List__c oItem : Default_Standard_Objects_List__c.getAll().values() ) {
            aDefaultObjects.add( oItem.Name.toLowerCase() );
        }
        
        for ( String sKey : aObjects.keySet() ) {
            if ( sKey.endsWith( '__c' ) || aDefaultObjects.contains( sKey ) ) {
                aResult.put( sKey, aObjects.get( sKey ) );
            }
        }
        
        return aResult;
    }
*/    
    /**
     * @param sObjectName String Object name
     * @return String Name of object with NameSpace
     * @description return Full SF object name 
     */
    public String getNSObjectName(String sObjectName) {
        if (SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace != '' 
                && sObjectName.indexOf(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace) == -1
                && sObjectName.indexOf('__c') > 0
//                && this.isTypeExist(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace.replace('__', '') + '.' + objectName)
                && this.isTypeExist(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + sObjectName)
        ) {
            sObjectName = SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + sObjectName;
        }
        return sObjectName;
    }
    
    /**
     * @param sObjectName String Object name
     * @return Boolean True uf if object exists in cache map
     * @description Checks for existing object
     */
    public Boolean isObjectExist(String sObjectName) {
        sObjectName = sObjectName != null ? sObjectName.toLowerCase() : null;
        this.checkObject(sObjectName);
        return this.m_described_objects.containsKey(this.getNSObjectName(sObjectName));
    }
    
    /**
     * @param sTypeName String SF type name
     * @return Boolean True if type exists (for checking types with NameSpace)
     * @description Checks for existing type
     */
    public Boolean isTypeExist(String sTypeName) {
        sTypeName = sTypeName != null ? sTypeName.toLowerCase() : null;
        if (sTypeName == null) {
            return false;
        }
        return Type.forName(sTypeName) != null;
    }
    
    public Map<String, Schema.DescribeFieldResult> getDecribedFieldsByObject(String p_object_name) {
    	return this.getDecribedFieldsByObject(p_object_name, false);
    }
    
    /**
     * @param p_object_name String Object name 
     * @param bIncludeHidden Boolean flag: include hidden fields 
     * @return Map<String,Schema.DescribeFieldResult> list of fields describe info
     * @description Get the list of fields for some object
     */
    private Map<String, Schema.DescribeFieldResult> getDecribedFieldsByObject(String p_object_name, Boolean bIncludeHidden) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        this.checkObject(p_object_name);
        Map<String, Schema.DescribeFieldResult> result = new Map<String, Schema.DescribeFieldResult>();
        bIncludeHidden = bIncludeHidden == null ? false : bIncludeHidden;
       
        if (p_object_name == null || p_object_name == '') {
            p_object_name = 'Opportunity';
        }
        
        Schema.DescribeSObjectResult object_describe_result =
           m_described_objects.containsKey(p_object_name)
           ? m_described_objects.get(p_object_name)
           : null;
        
        if (object_describe_result == null) {
            List<String> nameParts = p_object_name.split('__');
            if (nameParts.size() > 2) {
                p_object_name = nameParts[nameParts.size() - 2] + '__c';
                object_describe_result =
                    m_described_objects.containsKey(p_object_name)
                    ? m_described_objects.get(p_object_name)
                    : null;
            }
        }
        
        
        if (object_describe_result == null || object_describe_result.fields == null) {
            return result;
        }
        
        Map<String, Schema.SObjectField> object_fields = object_describe_result.fields.getMap();
        system.debug('==== prepare fields for object ' + p_object_name + ' / ' + object_fields.keySet());
        for (String field_name : object_fields.keySet()) {
            if (!bIncludeHidden 
               && SL_RTR_LIB16_ME_DescribeObject_Core.aRestrictedFields.containsKey(p_object_name) 
               && SL_RTR_LIB16_ME_DescribeObject_Core.aRestrictedFields.get(p_object_name).contains(field_name)
            ) {
                continue;
            }
            result.put(object_fields.get(field_name).getDescribe().getName().toLowerCase(), object_fields.get(field_name).getDescribe());          
        }
        system.debug('=== result ' + result.keySet());
        return result;
    }

    /**
     * @param p_field_type String Type of field  
     * @return Boolean True if field type is "stringable"
     * @description detects the text field
     */
    private boolean isTextType(String p_field_type) {
        p_field_type = p_field_type != null ? p_field_type.toLowerCase() : null;
        //PICKLIST STRING DATETIME REFERENCE BOOLEAN DOUBLE TEXTAREA ID ANYTYPE INTEGER EMAIL 
        return ( p_field_type == 'PICKLIST' ||
            p_field_type == 'STRING' ||
            p_field_type == 'EMAIL' ||     
            //p_field_type == 'TEXTAREA' ||  
            p_field_type == 'PHONE' ||
            p_field_type == 'COMBOBOX' ||
            p_field_type == 'URL');      
    }
    
    /**
     * @param p_field_type String Type of field  
     * @return Boolean True if field type is "dateable"
     * @description detects the date field
     */
    private boolean isTimeType(String p_field_type) {
        p_field_type = p_field_type != null ? p_field_type.toLowerCase() : null;
        return ( p_field_type == 'DATETIME' || p_field_type == 'DATE' );  
    }
    
    /**
     * @param p_object_name String Object name 
     * @param p_field_name String Field name 
     * @return String Field type
     * @description Get the type of a field
     */
    public String getFieldTypeByName(String p_object_name, String p_field_name) {
        String result = '';
        if (p_field_name == '' || p_object_name == '' || p_object_name == null || p_field_name == null) {
            return '';
        }
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        
        String[] aFieldName = p_field_name.split('\\.');
        String sRealFieldName = aFieldName[0];
        Schema.DescribeFieldResult described_field_result;
        
        Map<String, Schema.DescribeFieldResult> described_fields =
            SL_RTR_LIB16_ME_DescribeObject_Core.aRestrictedFields.containsKey(p_object_name) 
            && SL_RTR_LIB16_ME_DescribeObject_Core.aRestrictedFields.get(p_object_name).contains(sRealFieldName)
            ? this.getFieldsDescribesByObjectName(p_object_name, true)
            : this.getFieldsDescribesByObjectName(p_object_name, false);
        
        if (described_fields == null || described_fields.size() == 0 || !described_fields.containsKey(aFieldName[0])) {
            return result;
        }
        described_field_result = described_fields.get(aFieldName[0]);
        
        if (described_field_result == null && SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace != '') {
            String sNSName = p_field_name.toLowerCase();
            if (sNSName.indexOf(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace) == 0) {
               sNSName = sNSName.substring(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace.length());
            }
            if (described_fields.containsKey(sNSName)) {
                described_field_result = described_fields.get(sNSName);
            } else if (described_fields.containsKey(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + sNSName)) {
                described_field_result = described_fields.get(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + sNSName);
            }
        }
        if (described_field_result == null) {
            return '';
        }     
        result = described_field_result.getType().name();
        
        
        if (aFieldName.size() > 1  
            && described_fields.get(aFieldName[0]).getType().name() == 'Reference' 
            && described_fields.get(aFieldName[0]).getRelationshipName() != null
        ){
            String sRefObjectName = 
                 described_fields.get(aFieldName[0]).getReferenceTo().get(0).getDescribe().getName().toLowerCase();
            result = this.getFieldTypeByName(sRefObjectName, aFieldName[1]);
        }
        if (aFieldName[0] == 'recordtypeid') {
            result = 'PICKLIST';
        }
        
        /*if (described_field_result != null) {
            result = described_field_result.getType().name();
            system.debug('=== field type 1 ' + p_field_name + ' /  ' + result);
        } else if (p_field_name != null && SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace != '') {
            String sNSName = p_field_name.toLowerCase();
            if (sNSName.indexOf(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace) == 0) {
               sNSName = sNSName.substring(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace.length());
            }
            if (described_fields.containsKey(sNSName)) {
                described_field_result = described_fields.get(sNSName);
            } else if (described_fields.containsKey(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + sNSName)) {
                described_field_result = described_fields.get(SL_RTR_LIB16_ME_DescribeObject_Core.sNameSpace + sNSName);
            }
            if (described_field_result != null) {
                result = described_field_result.getType().name();
            }
            system.debug('=== field type 1 ' + p_field_name + ' NS ' + sNSName + ' /  ' + result);
        }
        
        if (p_field_name != null) {
            if (p_field_name == 'recordtypeid') {
                result = 'PICKLIST';
            }
        }*/
        
        return result;        
    }
    
    
    /**
     * @param p_object_name String - Object name 
     * @return Map<ID,String> list of record types for object
     * @description Get the Object record types of a field as pairs [Record ID, Record Name]
     */
    public Map<ID, String> getObjectRecordTypeValues(String p_object_name) {
        Map<ID, String> aResult = new Map<ID, String>(); 
        this.checkObject(p_object_name);
        List<Schema.RecordTypeInfo> aRT = new List<Schema.RecordTypeInfo>();
        if(this.m_described_objects!=null && this.m_described_objects.containsKey(p_object_name))
        {
        	aRT = this.m_described_objects.get(p_object_name).getRecordTypeInfos();
        }
        for (Schema.RecordTypeInfo aRow : aRT) {
            aResult.put(aRow.getRecordTypeId(), aRow.getName());
        }  
        return aResult;
    }
    
    
    /**
     * @param p_object_name String Object name 
     * @param p_field_name String Field name 
     * @return Boolean True if field presents in object
     * @description Checks for field in object
     */
    public Boolean hasField(String p_object_name, String p_field_name) {
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        Map<String, Schema.DescribeFieldResult> fields = this.getFieldsDescribesByObjectName(p_object_name);
        return (fields.get(p_field_name) != null); 
    }
    
    /**
     * @param p_object_name String Object name 
     * @param p_field_name String Field name  
     * @return Boolean True if field is accessible
     * @description Checks for  accessiblity of a field
     */
    public Boolean isFieldAccessible(String p_object_name, String p_field_name) {
         Boolean result = false;
         p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
         p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
         Map<String, Schema.DescribeFieldResult> described_fields = null;
         
         described_fields = getFieldsDescribesByObjectName(p_object_name);
         if (p_field_name.contains('.')) {
             String[] aTmpName = p_field_name.split('\\.'); 
             if (described_fields == null 
                 || !described_fields.containsKey(aTmpName[0]) 
                 || !described_fields.get(aTmpName[0]).isAccessible() 
             ) {
                 return false;
             }
             String sLinkedObject = described_fields.get(aTmpName[0])
                 .getReferenceTo().get(0).getDescribe().getName().toLowerCase();
             return this.isFieldAccessible(sLinkedObject, aTmpName[1]);
         }
         system.debug('=== fields for object ' + p_object_name 
            + ' (check ' + p_field_name + ') / ' 
            + String.join(new List<String>(described_fields.keySet()), ','));
         if (described_fields == null || !described_fields.containsKey(p_field_name)) {
            return false;
         }
         
         Schema.DescribeFieldResult described_field_result = described_fields.get(p_field_name);
         system.debug('==== if accessible field ' 
            + (described_field_result != null ? (described_field_result.isAccessible() ? 'true' : 'false') : ' NULL ')
         );
         result = described_field_result != null 
                ? described_field_result.isAccessible()
                : false;

         return result;
    }

    public Boolean isFieldCreateable(String p_object_name, String p_field_name) {
         Boolean result = false;
         if(p_object_name==null || p_field_name==null || p_object_name=='' || p_field_name=='') return result;
         
         p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
         p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
         Map<String, Schema.DescribeFieldResult> described_fields = null;
         
         described_fields = getFieldsDescribesByObjectName(p_object_name);
         if (p_field_name.contains('.')) {
             String[] aTmpName = p_field_name.split('\\.'); 
             if (described_fields == null 
                 || !described_fields.containsKey(aTmpName[0]) 
                 || !described_fields.get(aTmpName[0]).isAccessible() 
             ) {
                 return false;
             }
             String sLinkedObject = described_fields.get(aTmpName[0])
                 .getReferenceTo().get(0).getDescribe().getName().toLowerCase();
             return this.isFieldCreateable(sLinkedObject, aTmpName[1]);
         }
         if (described_fields == null || !described_fields.containsKey(p_field_name)) {
            return false;
         }
         
         Schema.DescribeFieldResult described_field_result = described_fields.get(p_field_name);
         result = described_field_result != null 
                ? described_field_result.isCreateable()
                : false;

         return result;
    }
    
    /**
     * @param p_object_name String Object name 
     * @return Boolean True if object is accessible
     * @description Checks for accessiblity of an object
     */
    public Boolean isObjectAccessable(String p_object_name) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null; 
        this.checkObject(p_object_name);
        return ( m_described_objects.containsKey(p_object_name)
           && m_described_objects.get(p_object_name) != null 
           && m_described_objects.get(p_object_name).queryable
           && m_described_objects.get(p_object_name).isAccessible()
//         && m_described_objects.get(p_object_name).retrieveable
        );
    }
    
    /**
     * @param p_object_name String Object name 
     * @return Boolean True if object is editable
     * @description Checks for editability of an object
     */
    public Boolean isObjectEditable(String p_object_name) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        this.checkObject(p_object_name);
        system.debug('=== is object updateable ' + p_object_name + ' / ' + m_described_objects.containsKey(p_object_name)); 
        return ( m_described_objects.containsKey(p_object_name)
           && m_described_objects.get(p_object_name) != null 
           && m_described_objects.get(p_object_name).isUpdateable()
        );
    }    
    
    /**
     * @param p_object_name String Object name 
     * @return Boolean true if object createable (has possibity to create new records)
     * @description Checks for createability of an object
     */
    
    public Boolean isObjectCreateable(String p_object_name) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        this.checkObject(p_object_name);
        return ( m_described_objects.containsKey(p_object_name)
           && m_described_objects.get(p_object_name) != null 
           && m_described_objects.get(p_object_name).isCreateable()
        );
    }
    /**
     * @param p_object_name String Object name
     * @param p_field_name String Field name 
     * @reutrn String Field label by name
     * @description get Field label by Object and Field name
     */
    public String getFieldLabelByName(String p_object_name, String p_field_name) {
        String result = p_field_name;
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        
        Map<String, Schema.DescribeFieldResult> described_fields = getFieldsDescribesByObjectName(p_object_name);
        String[] aFieldName = p_field_name.split('\\.');
        if (described_fields != null && described_fields.containsKey(aFieldName[0])) {
            result = described_fields.get(aFieldName[0]).getLabel();
            if (aFieldName.size() == 2  
                && described_fields.get(aFieldName[0]).getType().name() == 'Reference' 
                && described_fields.get(aFieldName[0]).getRelationshipName() != null
            ){
                String sRefObjectName = 
                     described_fields.get(aFieldName[0]).getReferenceTo().get(0).getDescribe().getName().toLowerCase();
                result += ' / ' + this.getFieldLabelByName(sRefObjectName, aFieldName[1]);
            }
        }
        

        return result;      
    }
    
    /**
     * @param p_object_name String Object name
     * @param p_field_name String Field name 
     * @return Schema.DescribeFieldResult Field describe info
     * @description Get Field Describe by Object and Field name
     */
    public Schema.DescribeFieldResult getFieldByName(String p_object_name, String p_field_name) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        if (mapObjectField.containsKey(p_object_name + '#_#' + p_field_name)) {
            return mapObjectField.get(p_object_name + '#_#' + p_field_name);
        }
        List<String> nameParts;
        if (p_field_name != null) {
            nameParts = p_field_name.split('__');
            if (nameParts.size() > 1) {
                p_field_name = nameParts[nameParts.size() - 2] + '__c';
            }
        }
        Schema.DescribeFieldResult result = null; 
        
        if (p_object_name != null 
            && p_field_name != null 
            && p_object_name.trim().length() != 0 
            && p_field_name.trim().length() != 0
            && p_object_name!=''
        ){
            Map<String, Schema.DescribeFieldResult> described_fields = getFieldsDescribesByObjectName(p_object_name);
            system.debug('=== !!! '  + p_object_name + ' / ' + p_field_name);
            if (described_fields == null || described_fields.size() < 1) {
                return result;
            }
            String fullFieldName = '';
            List<String> parts;
            String tmp = '';
            for (String item: described_fields.keyset()) {
                parts = item.split('__');

                if (parts.size() > 1) {
                    tmp = parts[parts.size() - 2] + '__c';
                } else {
                    tmp = item;
                }
                if (tmp.toLowerCase() == p_field_name) {
                    fullFieldName = item;
                    break;
                }
            }
            result = described_fields.containsKey(fullFieldName) 
               ? described_fields.get(fullFieldName)
               : null;
        }
        mapObjectField.put(p_object_name + '#_#' + p_field_name, result);
        
        return result;
    }
    
    
    /**
     * @param p_object_name String Object name
     * @return String Object label
     * @description Get Object label by name
     */
    public String getObjectLabelByName(String p_object_name) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        this.checkObject(p_object_name);
        String result = '';
        try {
            if (m_described_objects.containsKey(p_object_name)) {
                Schema.DescribeSObjectResult described_object = m_described_objects.get(p_object_name);
                result = described_object.getLabel();
            }
        } catch(Exception e) { }
        return result;
    }



    /** @description Fields by type cache */
    private Map<String, Map<String, String>> aFieldsByType;
    
    /**
     * @param aFieldsDesc Map<String,Schema.DescribeFieldResult> Fields info
     * @description Split fields by type (All / Text / Time)
     */
    private void initFieldsByType (Map<String, Schema.DescribeFieldResult> aFieldsDesc) {
        if (this.aFieldsByType != null) {
            return;
        }
        String sFieldType = '';
        String sFieldLabel = '';
        
        this.aFieldsByType = new Map<String, Map<String, String>>();
        this.aFieldsByType.put('ALL', new Map<String, String>()); 
        this.aFieldsByType.put('TEXT', new Map<String, String>());
        this.aFieldsByType.put('TIME', new Map<String, String>());
        
        for (String sFieldName : aFieldsDesc.keySet()) {
            Schema.DescribeFieldResult oFieldDesc = aFieldsDesc.get(sFieldName);
            if (oFieldDesc == null || !oFieldDesc.isAccessible()) {
                continue;
            }
            sFieldType = oFieldDesc.getType().name();
            sFieldLabel = oFieldDesc.getLabel();
            
            if (!this.aFieldsByType.containsKey(sFieldType)) {
                this.aFieldsByType.put(sFieldType, new Map<String, String>()); 
            }
            this.aFieldsByType.get('ALL').put(sFieldName, sFieldLabel);
            this.aFieldsByType.get(sFieldType).put(sFieldName, sFieldLabel);
            if (sFieldType != 'TEXT' && this.isTextType(sFieldType)) {
                this.aFieldsByType.get('TEXT').put(sFieldName, sFieldLabel);
            }
            if (sFieldType != 'TIME' && this.isTimeType(sFieldType) && sFieldName != 'recurrencestartdatetime' && sFieldName != 'recurrenceenddateonly' && sFieldName != 'recurrencestartdateonly') {
                this.aFieldsByType.get('TIME').put(sFieldName, sFieldLabel);
            }
        }   
         
    }
    
    /**
     * @param p_described_fields Map<String,Schema.DescribeFieldResult> Fields description
     * @param p_type String Field type
     * @return Map<String, String> Field labels and names
     * @description Filter the list of fields anmes and labels for some type  
     */
    private Map<String, String> getNeededTypeFields(Map<String, Schema.DescribeFieldResult> p_described_fields,  String p_type) {
        return this.getNeededTypeFields(p_described_fields, new List<String>{p_type});
    }
    
    /**
     * @param p_described_fields Map<String,Schema.DescribeFieldResult> Fields description
     * @param aTypes List<String> Field types
     * @return Map<String, String> Field labels and names
     * @description Filter the list of fields anmes and labels for some type  
     */
    private Map<String, String> getNeededTypeFields(Map<String, Schema.DescribeFieldResult> p_described_fields,  List<String> aTypes) { 
        Map<String, String> aResult = new Map<String, String>();
        if (this.aFieldsByType == null) {
            this.initFieldsByType(p_described_fields);
        }
        
        for (String sType : aTypes) {
            if (this.aFieldsByType.containsKey(sType)) {
                aResult.putAll(this.aFieldsByType.get(sType));
            }           
        }
        return aResult;
    }
    
    /**
     * @param p_object_name String object name 
     * @param p_type String Field type 
     * @return Map<String,String> Object fields by type
     * @description Filter the list of fields anmes and labels for some type
     */
    public Map<String, String> getObjectFieldsByType(String p_object_name, String p_type) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        return this.getNeededTypeFields(this.getFieldsDescribesByObjectName(p_object_name), p_type);
    }
    
    /**
     * @param p_object_name String object name 
     * @param aTypes List<String> Field type 
     * @return Map<String,String> Object fields by type
     * @description Filter the list of fields anmes and labels for some type
     */
    public Map<String, String> getObjectFieldsByType(String p_object_name, String[] aTypes) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        return this.getNeededTypeFields(this.getFieldsDescribesByObjectName(p_object_name), aTypes);
    }
    
    /**
     * @param p_object_name String object name
     * @param sField String Field name 
     * @return Boolean True if field updateable
     * @description Checks if field is updateable
     */
    public boolean isFieldUpdatable(string sObjectname, string sField) {
        sObjectname = sObjectname != null ? sObjectname.toLowerCase() : null;
        if (sObjectname == null) {
            return false;
        }
        String sCache = sObjectname + '###' + sField;
        if (SL_RTR_LIB16_ME_DescribeObject_Core.aObjectFieldUpdateable.containsKey(sCache)) {
            return SL_RTR_LIB16_ME_DescribeObject_Core.aObjectFieldUpdateable.get(sCache) ;
        }
        
        Schema.DescribeFieldResult dField = null; 
        if (mapObjectField.containsKey(sObjectname + '#_#' + sField)) {
            dField = mapObjectField.get(sObjectname + '#_#' + sField);
        } else {
            dField = getFieldByName(sObjectname, sField);
        }
        
        Boolean bUpdateable = dField != null ? dField.isUpdateable() : true;
        system.debug('=== get field updateable ' + sObjectname + ' / ' + sField + ' | RESULT : ' + bUpdateable + ' / ' + dField); 
        SL_RTR_LIB16_ME_DescribeObject_Core.aObjectFieldUpdateable.put(sCache, bUpdateable);
        return bUpdateable;
    }
    
    /**
     * @param p_object_name String object name 
     * @param p_fields String  field name 
     * @param p_terms String LIMIT or WHERE value 
     * @param filter String  WHERE value 
     * @return List<sObject> List of sObjects by criteria 
     * @description Loads the list of data from some table with criteria , fields , limits
     */
    public List<SObject> getData(String p_object_name, String p_fields, String p_terms, String filter) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        return getData(buildQuery(p_object_name, p_fields, p_terms, filter));   
    }
    /**
     * @param query String Query Body    
     * @return List<sObject> Return the list of sObject for query (with cache prechecking)
     * @description Loads the list of data from some table 
     */
    public List<SObject> getData(String query){
        String sHash = this.getMD5(query);
//      system.debug('==== sHash ' + sHash);
        if (SL_RTR_LIB16_ME_DescribeObject_Core.aQueryCache.containsKey(sHash) ){
            return SL_RTR_LIB16_ME_DescribeObject_Core.aQueryCache.get(sHash);
        }
        
        List<SObject> retVal = null;
        try{
            retVal = database.query(query);
        }
        catch(Exception ex){}
        SL_RTR_LIB16_ME_DescribeObject_Core.aQueryCache.put(sHash, retVal);
        return retVal; 
    }
    
    /**
     * @param sStr String Hash string 
     * @return String MD5 hash string
     * @description Get MD5 of some string
     */
    private String getMD5(String sStr) {
        Blob sBlob = Blob.valueof(sStr);
        return EncodingUtil.convertToHex(Crypto.generateDigest('MD5', sBlob));
    }
    
   /**
     * @param p_object_name String Object name 
     * @param p_fields String  field name 
     * @param p_terms String LIMIT or WHERE value 
     * @param filter String  WHERE value 
     * @return String Query body to be execute
     * @description Get the SOQL body by criteria
     */
    public String buildQuery(String p_object_name, String p_fields, String p_terms, String filter){
        String query_string = 'SELECT ' + p_fields + ' FROM ' + p_object_name ;
        if (p_terms != null && p_terms.length() > 2) {
            p_terms = p_terms.trim();
            if (p_terms.substring(0,5).toLowerCase() == 'limit' ) {
                query_string += ' ' + p_terms;
            } else {
                query_string += ' WHERE ' + p_terms;
            }
            if ((filter != null) && (filter.trim() != '')) {
                query_string += ' AND '+ filter;
            }
        }
        //query_string += ' LIMIT 600';
        return query_string;
    }

    /**
     * @param p_object_name String Object name
     * @param p_field_name String Field name 
     * @return String First linked object prefix (3 letters) by field name
     * @description return the first referenced object prefix 
     */
    public String getReferencedObjectPrefixByFieldName(String p_object_name, String p_field_name) {
        String result = '';
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        Map<String, Schema.DescribeFieldResult> described_fields = getFieldsDescribesByObjectName(p_object_name);
        if (described_fields.containsKey(p_field_name)) {
            List<SObjectType> lst = described_fields.get(p_field_name).getReferenceTo();
            if (lst != null && lst.size() > 0) {
                result = lst.get(0).getDescribe().getKeyPrefix();
            }
        }
        
        return result;
    }
    
    /**
     * @param prefix String Object prefix 
     * @return String Object name by prefix
     * @description Get the name of object by prefix
     */
    public String getObjectNameByPrefix(String prefix) {
        /*String result = '';
        if ()
        for(String object_name : m_described_objects.keySet()) {
            Schema.DescribeSObjectResult object_describe_result = m_described_objects.get(object_name);
            if (prefix.equals(object_describe_result.getKeyPrefix())) {
                return object_name;
            } 
        }*/
        this.RefreshObjects();
        return aPrefix2Name.containsKey(prefix) ? aPrefix2Name.get(prefix) : ''; 
    }
    
    /**
     * @param sID String  Some sObject record ID 
     * @return String Object name by ID
     * @description Get the name of object by record ID
     */
    public String getObjectNameByID(String sID) {
        String sSufix = '';
        if (sID.length() == 18 || sID.length() == 15) {
            sSufix = sID.substring(0, 3); 
        }
        return sSufix != '' ? this.getObjectNameByPrefix(sSufix) : null;
    }
    
    /**
     * @param prefix String Object prefix 
     * @return String Object label by prefix
     * @description Get the name of the object by prefix
     */
    public String getObjectLabelByPrefix(String prefix) {
        Schema.DescribeSObjectResult requiredObject = this.getObjectByPrefix(prefix);
        return requiredObject != null ? requiredObject.getLabel() : '';
    }
    
    /**
     * @param sID String sObject Record ID 
     * @return String Object label by ID
     * @description Get object label by somerecord id
     */
    public String getObjectLabelByID(String sID) {
        String sSufix = '';
        if (sID != null && sID.length() == 18) {
            sSufix = sID.substring(0, 3); 
        }
        return sSufix != '' ? this.getObjectLabelByPrefix(sSufix) : null;
    }
    
    /**
     * @param prefix String Object prefix 
     * @return Schema.DescribeSObjectResult Object describe by prefix
     * @description Get object description by prefix
     */
    private Schema.DescribeSObjectResult getObjectByPrefix(String prefix) {
        this.refreshObjects();
        return aPrefix2Name.containsKey(prefix) 
           ? m_described_objects.get(aPrefix2Name.get(prefix)) 
           : null;
        /*Schema.DescribeSObjectResult result = null;
        for(String object_name : m_described_objects.keySet()) {
            Schema.DescribeSObjectResult object_describe_result = m_described_objects.get(object_name);
            if (object_describe_result != null && prefix.equals(object_describe_result.getKeyPrefix())) {
                result = object_describe_result;
            } 
        }
        return result;*/  
    }
   
   /**
    * @param p_object_name String Object name 
    * @param p_field_name String Field name 
    * @return String Reference SOQL name for field
    * @description Get object description by prefix
    */
   public String getFieldReferenceByName(String p_object_name, String p_field_name) {
        String result = ''; 
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        if (p_object_name != null) {
            Map<String, Schema.DescribeFieldResult> described_fields = getFieldsDescribesByObjectName(p_object_name);
            if (described_fields != null && described_fields.containskey(p_field_name)) {
                Schema.DescribeFieldResult described_field_result = described_fields.get(p_field_name);
                if (described_field_result != null) {
                    List<SObjectType> lst = described_field_result.getReferenceTo();
                    result = (lst != null && lst.size() > 0) ? lst.get(0).getDescribe().getName() : '';
                }
            }
        }
        return result;
    }
    
    /**
     * @param p_object_name String Object name 
     * @param p_field_name String Field name 
     * @return Schema.DescribeFieldResult Field describe by name
     * @description Get object field description by name
     */
    public Schema.DescribeFieldResult getFieldDescriptionByName(String p_object_name, String p_field_name) {
        p_object_name = p_object_name != null ? p_object_name.toLowerCase() : null;
        p_field_name = p_field_name != null ? p_field_name.toLowerCase() : null;
        Map<String, Schema.DescribeFieldResult> described_fields = getFieldsDescribesByObjectName(p_object_name);
        return described_fields.containskey(p_field_name) ? described_fields.get(p_field_name) : null;
    }
    
    /**
     * @param sObjectName String - Object name 
     * @return Map<String,Schema.DescribeFieldResult> All object fields with describe
     * @description Get object fields description by name
     */
    public Map<String, Schema.DescribeFieldResult> getObjectAllFields(String sObjectName) {
        return this.getDecribedFieldsByObject(sObjectName, false);
    }
    
    
    /**
     * @param sObjectName String - Object name
     * @return List<String> All object fields for SOQL
     * @description Get all fields for SOQL query 
     */
    public List<String> getObjectAllQueryFields(String sObjectName) {
        List <String> aResult = new List <String>();
        List <Schema.DescribeFieldResult> aFields = this.getDecribedFieldsByObject(sObjectName, false).values();
        List<SObjectType> aLinksTo;
        String sLinkObjectName;
        Boolean bIsReferenceName ;
//        system.debug('=== prepare list of query fields ' + aFields.size() + ' / ' + sObjectName); 
        for (Schema.DescribeFieldResult aField : aFields){
//          system.debug('=== aField' + aField);
            if (!aField.isAccessible() || aField.getType().name() == 'LOCATION') {
                continue;
            }
            
            aResult.add(aField.getName().toLowerCase());
            if (aField.getType().name() == 'Reference' && aField.getRelationshipName() != null) {
                bIsReferenceName = true;
                aLinksTo = aField.getReferenceTo();
                if (aLinksTo == null || aLinksTo.size() == 0) {
                    continue;
                        //result = lst.get(0).getDescribe().getKeyPrefix();
                }
                for (SObjectType oLinkObject : aLinksTo) {
                    sLinkObjectName = oLinkObject.getDescribe().getName().toLowerCase();
/*                  system.debug('=== check name field present '
                           + aField.getName() + ' / ' 
                           + sLinkObjectName + ' / ' 
                           + ( SL_RTR_LIB16_ME_DescribeObject_Core.aNoNamesObjects.contains(sLinkObjectName) ? '+++' : '---')  + ' / '
                           + this.getFieldByName(sLinkObjectName, 'name'));*/
                    if (SL_RTR_LIB16_ME_DescribeObject_Core.aNoNamesObjects.contains(sLinkObjectName) 
                        || this.getFieldByName(sLinkObjectName, 'name') == null
                    ){
                        bIsReferenceName = false;
                        break;
                    } 
                }
//                system.debug('=== after checking ' + aField.getName() + ' / ' + bIsReferenceName);
                if (bIsReferenceName) {
                    aResult.add(aField.getRelationshipName().toLowerCase() + '.name' );
                }
            }
        }
//      system.debug('======TEST' + SL_RTR_LIB16_ME_DescribeObject_Core.getInstance().getFieldByName('Account', 'parentid').getReferenceTo());
        return aResult;
    }
    
    /**
     * @param sName String Object name 
     * @return Schema.SObjectType Object sObjectType
     * @description Get all fields for SOQL query
     */
    public Schema.SObjectType getObjectDescription (String sName) {
        sName = sName.toLowerCase();
        this.checkObject(sName);
        return m_objects.containsKey(sName) ? m_objects.get(sName) : null; 
    }
    
    /**
     * @param List <CA_Calendar__c> - list of calendars 
     * @description not used
     */
/*    public void initPreload(List <CA_Calendar__c> aCalendars) {
        this.bCompactMode = true;
        
    }
*/    
    /**
     * @return Map<String,Schema.DescribeSObjectResult> All objects describe info 
     */
    public Map<String, Schema.DescribeSObjectResult> getObjectsDescribe() {
        this.refreshObjects();
        return this.m_described_objects;
    }
    
    /**
     * @param sObjectName String Object name 
     * @return Schema.DescribeSObjectResult Object describe info
     * @description Get some object describe
     */
    public Schema.DescribeSObjectResult getObjectDescribe(String sName) {
        this.checkObject(sName);
        return this.m_described_objects.containsKey(sName) 
            ? this.m_described_objects.get(sName)
            : null;
    }
    
    /**
     * @param sObjectName String Object name 
     * @return Boolean True if object has no name field
     * @description Checks for objects with "no name field" criteria
     */
    public Boolean isNoNameField(String sObjectName) {
        if (SL_RTR_LIB16_ME_DescribeObject_Core.aNoNamesObjects.contains(sObjectName.toLowerCase())){
            return true;
        }
        return false;
    }
    
    /**
     * @param sObjectName String Object name 
     * @return String Object name field
     * @description Get Object name field
     */
    public String getObjectNameField(String sObjectName) {
        String sAuto = '', sUniq = ''; 
        if (SL_RTR_LIB16_ME_DescribeObject_Core.aSpecialObjectNamesField.containsKey(sObjectName)) {
            return SL_RTR_LIB16_ME_DescribeObject_Core.aSpecialObjectNamesField.get(sObjectName);
        }
        for (Schema.DescribeFieldResult aField : this.getDecribedFieldsByObject(sObjectName, false).values()){
            if (aField.isNameField()) {
                return aField.getName().toLowerCase();
            }
            if (sAuto == '' && aField.isAutoNumber()) {
                sAuto = aField.getName().toLowerCase(); 
            }
            if (sUniq == '' && aField.isUnique()) {
                sUniq = aField.getName().toLowerCase(); 
            }
        }
        return sAuto != '' ? sAuto : (sUniq != '' ? sUniq : 'id');
    }
    
    /**
     * @param sObjectName String Object name 
     * @param aFields List<String> Fields names
     * @return Map<String,String> List of fields names to be used in SOQL
     * @description Get Field names for SOQL
     */
    public Map<String,String> getFieldsInSOQL(String sObjectName, List<String> aFields){
        return getFieldsInSOQL(sObjectName, new Set<String>(aFields), true);
    }
    
    /**
     * @param sObjectName String Object name 
     * @param aFields Set<String> Fields names
     * @return Map<String,String> List of fields names to be used in SOQL
     * @description Get Field names for SOQL
     */
     public Map<String,String> getFieldsInSOQL(String sObjectName, Set<String> aFields){
        return getFieldsInSOQL(sObjectName, aFields, true);
    }
    
    /**
     * @param sObjectName String Object name 
     * @param aFields Set<String> Fields names
     * @param bCheckReferenceNames  Boolean Flag to check naming fields
     * @return Map<String,String> List of fields names to be used in SOQL
     * @description Get Field names for SOQL [field name => SOQL field name]
     */
    public Map<String,String> getFieldsInSOQL(String sObjectName, Set<String> aFields, Boolean bCheckReferenceNames){
        Map<String, Schema.DescribeFieldResult> aFieldsDescribe = this.getObjectAllFields(sObjectName);
        Schema.DescribeFieldResult aDescribe;
        Map<String,String> aResult = new Map<String,String>();  
        Boolean bSkip;
        String sLinledObject, 
            sFieldType;
        system.debug('=== aFields ' + aFields + ' / ' + aFieldsDescribe.keySet());

        for (String sField : aFields) {
            String[] aFieldName = sField.split('\\.');
            if (!aFieldsDescribe.containsKey(aFieldName[0])) {
                continue;
            }
            
            
            aDescribe = aFieldsDescribe.get(aFieldName[0]);
            sFieldType = aDescribe.getType().name().toUpperCase();
            if (sFieldType == 'LOCATION') {
                aResult.put(aFieldName[0].removeEnd('__c') + '__latitude__s', aFieldName[0].removeEnd('__c') + '__latitude__s');
                aResult.put(aFieldName[0].removeEnd('__c') + '__longitude__s', aFieldName[0].removeEnd('__c') + '__longitude__s');
                continue;
            }
//            system.debug('=== field ' + aFieldName[0] + ' / sFieldType ' + sFieldType + ' / ' + aDescribe.getRelationshipName());
//            system.debug('=== aDescribe ' + aDescribe);
            aResult.put(aFieldName[0], aFieldName[0]);
            if (aDescribe != null 
                && sFieldType == 'REFERENCE' 
                && aDescribe.getRelationshipName() != null
            ) {
                if (aFieldName.size() == 1) {
                    if (bCheckReferenceNames || aDescribe.getReferenceTo().size() == 1) {
                        bSkip = false;
                        for (Schema.sObjectType oLinkedObject : aDescribe.getReferenceTo()) {
                            sLinledObject = oLinkedObject.getDescribe().getName().toLowerCase();
                            if (aNoNamesObjects.contains(sLinledObject)) {
                                bSkip = true;
                                break;
                            }
                        }
                        if (bSkip) {
                            continue;
                        }
                    }
                }
                aResult.put(
                    aFieldName[0] + '.' + (aFieldName.size() > 1 ? aFieldName[1] : 'name'), 
                    aDescribe.getRelationshipName() + '.' 
                    + (aFieldName.size() > 1 ? aFieldName[1] : 'name')
                ); 
            }
        }
        system.debug('=== aResult ' + aResult);
        return aResult;
    }
    
    /**
     * @param sObjectName String Object name 
     * @param aFields Set<String> Fields names
     * @return Map<String,String> List of fields types [field name => field type]
     * @description Get Field types
     */
     
     public Map<String,String> getFieldsTypesInSOQL(String sObjectName, Set<String> aFields){
        Map<String, Schema.DescribeFieldResult> aFieldsDescribe = this.getObjectAllFields(sObjectName);
        Schema.DescribeFieldResult aDescribe;
        Map<String,String> aResult = new Map<String,String>();  
        for (String sField : aFields) {
            system.debug('=== sField ' + sField );
            String[] aFieldName = sField.split('\\.');
            aDescribe = aFieldsDescribe.containsKey(aFieldName[0])
                ? aFieldsDescribe.get(aFieldName[0])
                : null;
            if (aDescribe == null) {
                List<String> aParts = aFieldName[0].split('__');
                String sWONSlName = (aParts.size() > 2) ? aParts[1] + '__c' : '';
                aDescribe = aFieldsDescribe.containsKey(sWONSlName)
                    ? aFieldsDescribe.get(sWONSlName)
                    : null;
            }
            String sType = (aDescribe != null) 
                ? aDescribe.getType().name().toUpperCase() 
                : 'STRING';
            if (aDescribe != null && sType == 'REFERENCE' && aDescribe.getRelationshipName() == null) {
                sType = 'RECORDTYPE';
            }
            aResult.put(aFieldName[0], sType);
            system.debug('=== sField type ' + sField + ' / ' + sType);
            if (aDescribe != null 
                && aFieldName.size() > 1
                && sType == 'REFERENCE' 
                && aDescribe.getRelationshipName() != null
            ) {
                 if (aFieldName[0] == 'ownerid' && SL_RTR_LIB16_ME_DescribeObject_Core.aPolymorphicNameObject.containsKey(aFieldName[1])) {
                     aResult.put(sField, SL_RTR_LIB16_ME_DescribeObject_Core.aPolymorphicNameObject.get(aFieldName[1]));
                     continue;
                 }
                 String sRefObjectName = 
                     aDescribe.getReferenceTo().get(0).getDescribe().getName().toLowerCase(); 
                 aResult.put(
                     aFieldName[0] + '.' + (aFieldName.size() > 1 ? aFieldName[1] : 'name'),
                     this.getFieldTypeByName(sRefObjectName, (aFieldName.size() > 1 ? aFieldName[1] : 'name')) 
                 ); 
            }
        }
        return aResult;
    }
    
    /**
     * @param sObjectName String Object name 
     * @param sFieldName String Field name
     * @return Schema.DescribeFieldResult Describe info for reference field
     * @description Reference field description
     */    
    public Schema.DescribeFieldResult getReferenceField(String sObjectName, String sFieldName) {
        if (sFieldName.indexOf('.') < 0) {
            return null;
        }
        String[] aFieldName = sFieldName.split('\\.'); 
        Schema.DescribeFieldResult aField = this.getFieldByName(sObjectName, aFieldName[0]);
        if (aField == null ) {
            return null;
        }
        String sLinkedObject = aField.getReferenceTo().get(0).getDescribe().getName().toLowerCase();
        Schema.DescribeFieldResult oLinkedField = this.getFieldByName(sLinkedObject, aFieldName[1]);
        return oLinkedField;
    }
}