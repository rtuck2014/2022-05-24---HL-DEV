/**
 * \author Vladimir Dobrelya
 * \date Jan 16, 2015
 * \see https://silverline.jira.com/browse/HL-92
 */
public with sharing class SL_Approval { //rebuild

    private final Approval_Object__c initialApprovalObject;
    private final Schema.SObjectType approvalObjectToken;

    public PagePagination pagination { get; set; }

    private ID approvalObjectId;
    public Boolean access { get; set; } // indicates Opportunity Approval object accessibility

    public SObjectChangeTracker approvalObject { get; set; }

    private StandardFieldManager fieldManager;
    public List<Section> sections { get; set; } // the available sections on the current page
    public List<RelatedList> relatedLists { get; set; } // the available related lists on the current page

    public List<Instructional_Text__c> instructionalText { get; set; } // instructional text list - see: https://silverline.jira.com/browse/HL-60
    private DependentProperties dependentProperties;
    public String form { get; set; }

    public SL_Approval() {
        this.approvalObjectId = this.getApprovalObjectId();
        this.approvalObjectToken = this.getApprovalObjectToken();
        if ( this.approvalObjectToken == null ) {
            return;
        }
        this.access = this.getApprovalObjectAccessibility();
        if ( this.access ) {
            try {
                this.initialApprovalObject = this.getInitialApprovalObject( this.approvalObjectToken );
            } catch ( Exception e ) { 
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getMessage() ) ); //+ '; line: ' + e.getLineNumber()
                return;
            }
            //this.form = ApexPages.currentPage().getParameters().get( 'form' );
            this.pagination = this.getPagePagination( this.form );
            this.refreshSections(); 
        }
    }
    
    public String getApprovalObjectName() {
        if ( this.approvalObjectToken != null ) {
            return SL_Describe.getLabel( this.approvalObjectToken );
        }
        return 'New Approval Object';
    }

    private Schema.SObjectType getApprovalObjectToken() {
        if ( this.approvalObjectId != null ) {
            return this.approvalObjectId.getSObjectType();
        }
        return this.getApprovalObjectToken( ApexPages.currentPage().getParameters().get( 'approval_object' ) );
    }
    
    private Schema.SObjectType getApprovalObjectToken( String approvalObjectName ) {
        if ( SL_Describe.isExisting( approvalObjectName ) ) {
            return SL_Describe.getToken( approvalObjectName );
        } else {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Could not determine an Approval Object name. Pass a valid record id or object name as URL-param.' ) );
        }
        return null;
    }

    private ID getApprovalObjectId() {
        try {
            return ID.valueOf( ApexPages.currentPage().getParameters().get( 'id' ) );
        } catch ( Exception e ) {
            // ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Invalid Approval Object ID parameter.' ) );
        }
        return null;
    }

    private Boolean getApprovalObjectAccessibility() {
        if ( !SL_Describe.isAccessible( this.approvalObjectToken ) || !SL_Describe.isUpdateable( this.approvalObjectToken ) ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'You have no access to ' + SL_Describe.getLabel( this.approvalObjectToken ) + '.' ) );
            return false;
        }
        return true;
    }

    private PagePagination getPagePagination( String form ) {
        try {
            return new PagePagination( Integer.valueOf( ApexPages.currentPage().getParameters().get( 'p' ) ), this.approvalObjectToken, form );
        } catch ( Exception e ) { }
        return new PagePagination( this.approvalObjectToken, form );
    }

    private Approval_Object__c getInitialApprovalObject( Schema.SObjectType objectToken ) {
        return getInitialApprovalObject( String.valueOf( objectToken ) );
    }

    private Approval_Object__c getInitialApprovalObject( String baseObjectName ) {
        if ( baseObjectName != null ) {
            for ( Approval_Object__c record : [ SELECT Base_Object__c, Master_Detail_Field__c, Form__c FROM Approval_Object__c WHERE Base_Object__c = :baseObjectName ] ) {
                this.form = record.Form__c;
                return record;
            }
            throw new ApprovalObjectNotFoundException( 'Could not find an Approval Object record with \'' + baseObjectName + '\' name.' );
        }
        return null;
    }

    // ---- BUTTONS ---- //

    public PageReference Save() {
        if ( this.approvalObject == null ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, SL_Describe.getLabel( this.approvalObjectToken ) + ' is null. Please notify a developer: add a comment to https://silverline.jira.com/browse/HL-69 with your current page URL.' ) );
            return null;
        }

        if ( this.approvalObjectId == null || ( this.approvalObjectId != null && this.approvalObject.isChanged( this.fieldManager.getFieldTokens( this.approvalObjectToken ) ) ) ) {
            try {
                upsert this.approvalObject.obj;
                if ( this.approvalObjectId == null ) {
                    this.approvalObjectId = this.approvalObject.obj.Id;
                }
            } catch ( DmlException e ) {
                return addExceptionMessage( e );
            }
        }

        // Related list save
        List<SObject> toInsert = new List<SObject>();
        List<SObject> toUpdate = new List<SObject>();

        for ( RelatedList relatedList : this.relatedLists ) {
            toInsert.addAll( relatedList.getRecordsToInsert() );
            toUpdate.addAll( relatedList.getRecordsToUpdate() );
        }

        try {
            if ( !toInsert.isEmpty() ) {
                insert toInsert;
            }
            if ( !toUpdate.isEmpty() ) {
                update toUpdate;
            }
        } catch ( DmlException e ) {
            return addExceptionMessage( e );
        }
// DIFF COMMENT        return new PageReference( '/' + ( this.initialOpportunityApproval.Status__c == 'Approved' ? this.initialOpportunityApproval.Id : this.initialOpportunityApproval.Project__c ) );
        return new PageReference( '/' + this.approvalObjectId );
    }

    public PageReference Cancel() {
        if ( this.approvalObjectId != null ) {
             return new PageReference( '/' + this.approvalObjectId );
        }
        return new PageReference( '/' + this.approvalObject.obj.get( this.initialApprovalObject.Master_Detail_Field__c ) );
    }

    public PageReference Previous() {
        if ( this.Save() != null ) {
            this.pagination.previous();
            this.refreshSections();
            return this.getPageReference();
        }
        return null;
    }

    public PageReference Next() {
        if ( this.Save() != null ) {
            this.pagination.next();
            this.refreshSections();
            return this.getPageReference();
        }        
        return null;
    }

    public PageReference ChangePage() {
        if ( this.Save() != null ) {
            this.refreshSections();
            return this.getPageReference();
        }
        return null;
    }    

    private PageReference getPageReference() {
        PageReference result = new PageReference( '/apex/SL_Approval' );
        result.getParameters().put( 'id', this.approvalObjectId );
        result.getParameters().put( 'p', String.valueOf( this.pagination.getPage() ) );
        this.addParamIfExists( result, 'retURL' );
        result.setRedirect( true );
        return result;
    }

    private void addParamIfExists( PageReference pageReference, String paramName ) {
        if ( ApexPages.currentPage().getParameters().containsKey( paramName ) ) {
            pageReference.getParameters().put( paramName, ApexPages.currentPage().getParameters().get( paramName ) );
        }
    }

    // ---- UTILS ---- //

    public class ApprovalObjectNotFoundException extends Exception {}

    public static PageReference addExceptionMessage( DmlException e ) {
        for ( Integer idx = 0; idx < e.getNumDml(); idx++ ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, e.getDmlMessage( idx ) ) );
        }
        return null;
    }

    public void refreshSections() {
        List<Approval_Section__c> sectionsRelatedList = new List<Approval_Section__c>();
        this.sections = new List<Section>();

        if ( !this.pagination.hasPages ) {
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'There are no pages to display.' ) );
            return;
        }

        this.dependentProperties = new DependentProperties( this.approvalObjectToken, this.pagination.getCurrentPageObject().Id );

        for ( Approval_Section__c section : [ 
            SELECT Name, Object_API_Name__c, Relationship_Field__c, Parent_Relationship_Field__c, RecordType.DeveloperName, ( 
                SELECT Name, Field_API_Name__c, Text__c, Read_only__c, Required__c, Hidden__c, Parent_Property__c, Parent_Property_Values__c, Parent_Property__r.Field_API_Name__c,
                    Parent_Property__r.Section__r.Object_API_Name__c, Parent_Property__r.Section__r.Relationship_Field__c, Parent_Property__r.Section__r.Parent_Relationship_Field__c,
                    Parent_Property__r.Section__r.Approval_Page__c, Parent_Property__r.Section__r.RecordType.DeveloperName
                FROM Approval_Properties__r
                WHERE Form__c includes (:this.form)
                ORDER BY Order__c )
            FROM Approval_Section__c
            WHERE Approval_Page__r.Approval_Object__r.Base_Object__c = :String.valueOf( this.approvalObjectToken ) AND
                Approval_Page__r.Order__c = :this.pagination.getPageOrder()
            ORDER BY Approval_Page__r.Order__c, Order__c ]
        ) {
            if ( !section.Approval_Properties__r.isEmpty() ) {
                if ( section.RecordType.DeveloperName == 'Related_List' ) {
                    sectionsRelatedList.add( section );
                } else {
                    this.sections.add( new Section( section ) );
                }
                dependentProperties.add( section.Approval_Properties__r );
            }
        }

        this.initApprovalObject( this.approvalObjectId, sectionsRelatedList );
        this.dependentProperties.hideDependentProperties( this.approvalObject.obj );

        this.relatedLists = new List<RelatedList>();
        if ( this.approvalObject != null && this.approvalObject.obj.Id != null ) {
            for ( Approval_Section__c section : sectionsRelatedList ) {
                this.relatedLists.add( new RelatedList( section, this.approvalObject.obj ) );
            }
        }        
        this.instructionalText = this.getInstructionalText( this.pagination.getCurrentPageObject() );
    }

    public String getDependentPropertiesJSON() {
        return JSON.serialize( this.dependentProperties.getDependentProperties() );
    }

    private void initApprovalObject( ID approvalObjectId, List<Approval_Section__c> relatedListSections ) {
        if ( this.approvalObjectId == null ) {
            if ( this.approvalObject == null ) {
                this.approvalObject = new SObjectChangeTracker( this.approvalObjectToken.newSObject() );
                if ( this.initialApprovalObject.Master_Detail_Field__c != null ) {
                    this.approvalObject.obj.put( this.initialApprovalObject.Master_Detail_Field__c, ApexPages.currentPage().getParameters().get( 'oid' ) ); // TODO: handle exceptions
                }
            }
            return;
        }
        this.approvalObject = null;

        this.fieldManager = new StandardFieldManager( this.approvalObjectToken, this.sections, relatedListSections, this.dependentProperties.getParentFields() );
        if ( !this.fieldManager.isEmpty( this.approvalObjectToken ) ) {
            for ( SObject record : Database.query( 'SELECT ' + this.fieldManager.getFieldsJoined( this.approvalObjectToken ) + ' FROM ' +this.approvalObjectToken + ' WHERE Id = :approvalObjectId' ) ) {
                this.approvalObject = new SObjectChangeTracker( record );
            }
        }        
        if ( this.approvalObject == null ) {
            throw new ApprovalObjectNotFoundException( 'Could not find the ' + SL_Describe.getLabel( this.approvalObjectToken ) + ' record with \'' + this.approvalObjectId + '\'' );
        }
    }

    private List<Instructional_Text__c> getInstructionalText( Approval_Page__c page ) {
        return this.getInstructionalText( page.Id );
    }

    private List<Instructional_Text__c> getInstructionalText( ID pageId ) {
        return [ SELECT Text__c FROM Instructional_Text__c WHERE Approval_Page__c = :pageId ORDER BY Order__c ];
    }

    public virtual class Section {
        public Approval_Section__c obj { get; set; }
        public List<Approval_Properties__c> properties { get; set; }

        public Section( Approval_Section__c section ) {
            this.obj = section;
            this.properties = this.getSectionProperties( section );
        }

        private List<Approval_Properties__c> getSectionProperties( Approval_Section__c section ) {
            List<Approval_Properties__c> result = new List<Approval_Properties__c>();
            for ( Approval_Properties__c property : section.Approval_Properties__r ) {
                if ( String.isBlank( property.Field_API_Name__c ) || SL_Describe.isAccessible( section.Object_API_Name__c, property.Field_API_Name__c ) ) {
                    result.add( property );
                }
            }
            return result;
        }
    }


    // --- PAGE PAGINATION --- //

    public class PagePagination extends SL_Pagination {
        private List<Approval_Page__c> pages;
        public List<SelectOption> pageOptions { get; private set; }

        public PagePagination( Schema.SObjectType objectToken, String form ) {
            this( String.valueOf( objectToken ), form );
        }

        public PagePagination( String approvalObjectName, String form ) {
            this( 1, approvalObjectName, form );
        }

        public PagePagination( Integer page, Schema.SObjectType objectToken, String form ) {
            this( page, String.valueOf( objectToken ), form );
        }

        public PagePagination( Integer page, String approvalObjectName, String form ) {
            super();
            this.pages = this.getPages( approvalObjectName, form );
            this.pageOptions = this.getPageOptions( this.pages );
            this.setRecordCount( this.pages.size() );
            this.setPage( page );
        }

        private List<Approval_Page__c> getPages( String approvalObjectName, String form ) {
            List<Approval_Page__c> result = new List<Approval_Page__c>();
            if ( form != null ) {
                Set<Integer> addedPages = new Set<Integer>();
                Integer order;

                for ( Approval_Section__c section : [ 
                    SELECT Approval_Page__r.Name, Approval_Page__r.Order__c, Object_API_Name__c, ( 
                        SELECT Field_API_Name__c, Required__c 
                        FROM Approval_Properties__r 
                        WHERE Field_API_Name__c != null AND
                            Form__c includes (:form)
                        )
                    FROM Approval_Section__c 
                    WHERE Approval_Page__r.Approval_Object__r.Base_Object__c = :approvalObjectName
                    ORDER BY Approval_Page__r.Order__c ]
                ) {
                    if ( !section.Approval_Properties__r.isEmpty() && !new Section( section ).properties.isEmpty() ) {
                        order = (Integer)section.Approval_Page__r.Order__c;
                        if ( !addedPages.contains( order ) ) { // only unique values
                            result.add( section.Approval_Page__r );
                            addedPages.add( order );
                        }
                    }
                }
            }            
            return result;
        }

        private List<SelectOption> getPageOptions( List<Approval_Page__c> pages ) {
            List<SelectOption> result = new List<SelectOption>();
            for ( Integer i = 0; i < pages.size(); i++ ) {
                result.add( new SelectOption( String.valueOf( i + 1 ), pages.get( i ).Name ) );
            }
            return result;
        }

        public Boolean hasPages {
            get {
                return !this.pages.isEmpty();
            }
        }

        public Integer getPageOrder() {
            return (Integer)this.pages.get( this.getPage() - 1 ).Order__c;
        }

        public Approval_Page__c getCurrentPageObject() {
            return this.pages.get( this.getPage() - 1 );
        }

        public String getPageName() {
            return this.pages.get( this.getPage() - 1 ).Name;
        }
    }


    // --- RELATED LIST --- //

    public class RelatedList extends Section {
        private SObject approvalObject;
        private Schema.SObjectType approvalObjectToken; // main object token
        private RelatedListFieldManager fieldManager;
        public List<RelatedListRecord> wrappers { get; set; }
        public Boolean selected { get; set; }
        public String sortBy { get; set; }
        public String sortDirection { get; set; }
        public Map<String, DescribeInfo> describeInfo { get; set; }

        public List<SelectOption> limitOptions { get; set; }

        public SL_QueryBuilder queryRecords { get; set; }
        public RelatedListPagination pagination { get; set; }

        public RelatedList( Approval_Section__c section, SObject data ) {
            super( section );

            this.approvalObjectToken = data.Id.getSObjectType();
            this.approvalObject = data;
            this.fieldManager = new RelatedListFieldManager( section );
            List<String> fields = this.fieldManager.getFieldList();
            if ( fields.isEmpty() ) {
                return;
            }
            this.describeInfo = this.fieldManager.getDescribeInfo( section );

            this.selected = false;
            this.sortDirection = 'asc';

            this.limitOptions = new List<SelectOption>{
                new SelectOption( '1', '1' ),
                new SelectOption( '2', '2' ),
                new SelectOption( '5', '5' ),
                new SelectOption( '10', '10' ),
                new SelectOption( '50', '50' )
            };

            this.queryRecords = new SL_QueryBuilder( fields, section.Object_API_Name__c );

            if ( SL_Describe.getToken( section.Object_API_Name__c ) == this.approvalObjectToken ) {
                this.queryRecords.getWhereDefault().add( this.approvalObjectToken + '=\'' + this.approvalObject.Id + '\'' );
            } else if ( String.isBlank( section.Parent_Relationship_Field__c ) ) {
                this.queryRecords.getWhereDefault().add( section.Relationship_Field__c + '=\'' + this.approvalObject.Id + '\'' );
            } else {
                this.queryRecords.getWhereDefault().add( section.Relationship_Field__c + '=\'' + SL_SObjectDigger.get( this.approvalObject, section.Parent_Relationship_Field__c ) + '\'' );
            }
            
            this.pagination = new RelatedListPagination( this.queryRecords, 5 );

            this.refreshRecords();
        }

        public PageReference Save() {
            this.SaveInternal();
            return null;
        }

        private Boolean SaveInternal() {
            List<SObject> toInsert = this.getRecordsToInsert();
            List<SObject> toUpdate = this.getRecordsToUpdate();

            try {
                if ( !toInsert.isEmpty() ) {
                    insert toInsert;
                    this.pagination.refreshRecordCount();
                }
                if ( !toUpdate.isEmpty() ) {
                    update toUpdate;
                }
            } catch ( DmlException e ) {
                SL_Approval.addExceptionMessage( e );
                return false;
            }
            return true;
        }

        public void SaveAndRefresh() {
            if ( this.SaveInternal() ) {
                this.refreshRecords();
            }
        }

        public void Cancel() {
            this.refreshRecords();
        }

        public void Next() {
            if ( this.SaveInternal() ) {
                this.selected = false;
                this.pagination.next();
                this.refreshRecords();
            }
        }

        public void Previous() {
            if ( this.SaveInternal() ) {
                this.selected = false;
                this.pagination.previous();
                this.refreshRecords();
            }
        }

        public void AddRow() {
            SObject newRecord = (SObject)Type.forName( this.obj.Object_API_Name__c ).newInstance();

            if ( SL_Describe.isUpdateable( this.obj.Object_API_Name__c, String.valueOf( this.approvalObjectToken ) ) ) {
                newRecord.put( String.valueOf( this.approvalObjectToken ), this.approvalObject.Id );
            } else if ( String.isNotBlank( this.obj.Relationship_Field__c ) ) {
                if ( SL_Describe.isUpdateable( this.obj.Object_API_Name__c, this.obj.Relationship_Field__c ) ) {
                    if ( String.isBlank( this.obj.Parent_Relationship_Field__c ) ) {
                        newRecord.put( this.obj.Relationship_Field__c, this.approvalObject.Id );
                    } else {
                        newRecord.put( this.obj.Relationship_Field__c, SL_SObjectDigger.get( this.approvalObject, this.obj.Parent_Relationship_Field__c ) );
                    }
                }                
            }

            this.wrappers.add( new RelatedListRecord( newRecord ) );
        }

        public void RemoveRows() {
            List<SObject> recordsToDelete = new List<SObject>();
            List<RelatedListRecord> newWrappers = new List<RelatedListRecord>();
            for ( Integer i = 0; i < this.wrappers.size(); i++ ) {
                if ( this.wrappers[i].selected ) {
                    if ( this.wrappers[i].obj.Id != null ) {
                        recordsToDelete.add( this.wrappers[i].obj );
                    }
                    this.wrappers.remove( i-- );
                } else if ( this.wrappers[i].obj.Id == null ) {
                    newWrappers.add( this.wrappers[i] );
                }
            }

            this.selected = false;

            if ( !recordsToDelete.isEmpty() ) {
                delete recordsToDelete;
                this.pagination.refreshRecordCount();
            }

            if ( this.wrappers.isEmpty() ) {
                if ( this.pagination.getPage() >= this.pagination.getLastPage() - 1 ) {
                    this.pagination.setPage( this.pagination.getPage() - 1 );
                }
            }

            if ( !recordsToDelete.isEmpty() ) {
                this.refreshRecords();
                if ( !newWrappers.isEmpty() ) {
                    this.wrappers.addAll( newWrappers );
                }
            }
        }

        public List<SObject> getRecordsToInsert() {
            List<SObject> result = new List<SObject>();
            for ( RelatedListRecord record : this.wrappers ) {
                if ( record.isNew() ) {
                    record.validateRequiredFields( this.fieldManager.getRequiredFields() );
                    result.add( record.obj );
                }
            }
            return result;
        }

        public List<SObject> getRecordsToUpdate() {
            List<SObject> result = new List<SObject>();
            for ( RelatedListRecord record : this.wrappers ) {
               if ( !record.isNew() && record.isChanged( this.fieldManager.getFieldTokens() ) ) {
                    record.validateRequiredFields( this.fieldManager.getRequiredFields() );
                    result.add( record.obj );
                }
            }
            return result;
        }

        public void refreshRecordsAndPage() {
            this.pagination.setPage( 1 );
            this.refreshRecords();
        }

        public void refreshRecords() {
            this.selected = false;
            this.queryRecords.getOrderBy().clear();

            if ( this.sortBy != null ) {
                if ( SL_Describe.getType( this.obj.Object_API_Name__c, this.sortBy ) == DisplayType.Reference ) {
                    this.queryRecords.getOrderBy().add( SL_Describe.getRelationshipName( this.obj.Object_API_Name__c, this.sortBy ) + '.Name ' + this.sortDirection );
                } else {
                    this.queryRecords.getOrderBy().add( this.sortBy + ' ' + this.sortDirection );
                }
            }

            this.pagination.refreshRecordCount();
            this.wrappers = this.createRecordWrappers( Database.query( this.queryRecords.build() ) );
        }

        private List<RelatedListRecord> createRecordWrappers( List<SObject> records ) {
            List<RelatedListRecord> result = new List<RelatedListRecord>();
            if ( records == null ) {
                return result;
            }
            for ( SObject record : records ) {
                result.add( new RelatedListRecord( record ) );
            }
            return result;
        }

        public void selectAllRecords() {
            for ( RelatedListRecord wrapper : this.wrappers ) {
                wrapper.selected = this.selected;
            }
        }
    }

    public class DescribeInfo {
        public Boolean isSortable { get; set; }
        
        public DescribeInfo( Schema.DescribeFieldResult fieldDescribe ) {
            this.isSortable = fieldDescribe.isSortable();
        }
    }

    // --- RELATED LIST RECORD WRAPPER --- //

    public class RelatedListRecord {
        public Boolean selected { get; set; }
        public SObjectChangeTracker objectTracker { get; set; }

        public RelatedListRecord( SObject obj ) {
            this.objectTracker = new SObjectChangeTracker( obj );
            this.selected = false;
        }

        public void selectRecord() {
            //this.selected = !this.selected;
        }

        public void validateRequiredFields( Set<Schema.SObjectField> requiredFields ) {
            for ( Schema.SObjectField fieldToken : requiredFields ) {
                if ( this.obj.get( fieldToken ) == null ) {
                    this.obj.addError( SL_Describe.getLabel( fieldToken ) + ': You must enter a value.' );
                }
            }
        }

        public Boolean isNew() {
            return this.obj.Id == null;
        }

        public Boolean isChanged( Set<Schema.SObjectField> fields ) {
            return this.objectTracker.isChanged( fields );
        }

        public SObject obj {
            get {
                return this.objectTracker.obj;
            }
        }
    }


    // --- RELATED LIST PAGINATION --- //

    public class RelatedListPagination extends SL_Pagination {
        public SL_QueryBuilder queryRecordsCount { get; set; }
        private SL_QueryBuilder sourceQueryBuilder;

        public RelatedListPagination( SL_QueryBuilder queryBuilder, Integer itemsPerPage ) {
            super();
            this.sourceQueryBuilder = queryBuilder;
            this.queryRecordsCount = new SL_QueryBuilder( 'COUNT(Id) cnt', queryBuilder.sObjectName );
            this.queryRecordsCount.getWhereDefault().addAll( queryBuilder.getWhereDefault() );
            this.setItemsPerPage( itemsPerPage );
            this.refreshRecordCount();
        }

        public override void setPage( Integer value ) {
            super.setPage( value );
            this.sourceQueryBuilder.offsetCount = ( this.getPage() - 1 ) * this.getItemsPerPage();
        }

        public override void setItemsPerPage( Integer value ) {
            super.setItemsPerPage( value );
            this.sourceQueryBuilder.limitCount = this.getItemsPerPage();
        }

        public void refreshRecordCount() {
            this.queryRecordsCount.setWhere( this.sourceQueryBuilder.getWhere() );
            this.setRecordCount( Integer.valueOf( Database.query( this.queryRecordsCount.build() ).get( 0 ).get( 'cnt' ) ) );
        }
    }

    public class DependentProperties {
        private Schema.SObjectType approvalObjectToken;
        private Map<ID, Approval_Properties__c> properties; // map to exclude duplicates
        private ID currentPageId;

        public DependentProperties( Schema.SObjectType approvalObjectToken, ID currentPageId ) {
            this( approvalObjectToken, currentPageId, new List<Approval_Properties__c>() );
        }

        public DependentProperties( Schema.SObjectType approvalObjectToken, ID currentPageId, List<Approval_Properties__c> properties ) {
            this.approvalObjectToken = approvalObjectToken;
            this.currentPageId = currentPageId;
            this.properties = this.getProperties( properties );
        }

        public void add( List<Approval_Properties__c> properties ) {
            this.properties.putAll( this.getProperties( properties ) );
        }

        public void clear() {
            this.properties.clear();
        }

        private Map<ID, Approval_Properties__c> getProperties( List<Approval_Properties__c> properties ) {
            Map<ID, Approval_Properties__c> result = new Map<ID, Approval_Properties__c>();

            for ( Approval_Properties__c property : properties ) {
                if ( property.Parent_Property__c != null && property.Parent_Property__r.Section__r.Object_API_Name__c != null &&
                    SL_Describe.getToken( property.Parent_Property__r.Section__r.Object_API_Name__c ) == this.approvalObjectToken &&
                    property.Parent_Property__r.Field_API_Name__c != null // && property.Parent_Property_Values__c != null // fix for: https://silverline.jira.com/browse/HL-88?focusedCommentId=95844&page=com.atlassian.jira.plugin.system.issuetabpanels:comment-tabpanel#comment-95844
                ) {
                    result.put( property.Id, property );
                }
            }
            return result;
        }

        public Map<ID, List<Approval_Properties__c>> getDependentProperties() {
            Map<ID, List<Approval_Properties__c>> result = new Map<ID, List<Approval_Properties__c>>();

            for ( Approval_Properties__c property : this.properties.values() ) {
                if ( !result.containsKey( property.Parent_Property__c ) ) {
                    result.put( property.Parent_Property__c, new List<Approval_Properties__c>() );
                }
                result.get( property.Parent_Property__c ).add( property );
            }            
            return result;
        }

        public Set<String> getParentFields() {
            Set<String> result = new Set<String>();

            for ( Approval_Properties__c property : this.properties.values() ) {
                result.add( property.Parent_Property__r.Field_API_Name__c.toLowerCase() );
            }
            return result;
        }

        public void hideDependentProperties( SObject approvalObject ) {
            for ( Approval_Properties__c property : this.properties.values() ) {
                if ( !property.Hidden__c && property.Parent_Property__r.Section__r.Approval_Page__c != null && currentPageId != property.Parent_Property__r.Section__r.Approval_Page__c ) {
                    property.Hidden__c = isHidden( property, approvalObject );
                }
            }
        }

        private Boolean isHidden( Approval_Properties__c property, SObject approvalObject ) {
            if ( approvalObject.get( property.Parent_Property__r.Field_API_Name__c ) != null ) {
                DisplayType fieldType = SL_Describe.getType( approvalObject.getSObjectType(), property.Parent_Property__r.Field_API_Name__c );
                if ( fieldType == DisplayType.Date ) {
                    return isHidden( property, Date.valueOf( approvalObject.get( property.Parent_Property__r.Field_API_Name__c ) ).format() );
                } else if ( fieldType == DisplayType.DateTime ) {
                    return isHidden( property, DateTime.valueOf( approvalObject.get( property.Parent_Property__r.Field_API_Name__c ) ).format() );
                }
            }
            return isHidden( property, String.valueOf( approvalObject.get( property.Parent_Property__r.Field_API_Name__c ) ) );
        }

        private Boolean isHidden( Approval_Properties__c property, String parentValue ) {
            return !new Set<String>( property.Parent_Property_Values__c.split( ';' ) ).contains( parentValue );
        }

    }


    // --- util SObject wrapper class to check the object for changes --- //
    public virtual class SObjectChangeTracker {
        public SObject obj { get; set; }
        private SObject srcObj { get; set; }

        public SObjectChangeTracker() { }

        public SObjectChangeTracker( SObject obj ) {
            this.setObject( obj );
        }

        public void setObject( SObject obj ) {
            this.obj = obj;
            this.srcObj = obj.clone( true, true, true, true );
        }

        public Boolean isChanged( Set<Schema.SObjectField> fields ) {
            for ( Schema.SObjectField field : fields ) {
                if ( this.srcObj.get( field ) != this.obj.get( field ) ) {
                    return true;
                }
            }
            return false;
        }
    }

    // --- standard fields collecting logic --- //
    public class StandardFieldManager extends FieldManager {
        private Schema.SObjectType approvalObjectToken;

        public StandardFieldManager( Schema.SObjectType approvalObjectToken, List<SL_Approval.Section> sections, List<Approval_Section__c> relatedListSections, Set<String> dependentFields ) {
            super();
            this.approvalObjectToken = approvalObjectToken;
            this.add( approvalObjectToken, 'Name' ); // to display VF-page section header
            this.add( sections );
            this.add( this.approvalObjectToken, new List<String>( dependentFields ) );
            this.addRelatedListFields( relatedListSections );
        }

        public void add( List<SL_Approval.Section> sections ) {
            for ( SL_Approval.Section section : sections ) {
                for ( Approval_Properties__c property : section.properties ) {
                    if ( String.isNotBlank( property.Field_API_Name__c ) ) {
                        this.add( section.obj.Object_API_Name__c, property.Field_API_Name__c );
                    }
                }
            }
        }

        public void addRelatedListFields( List<Approval_Section__c> sections ) {
            for ( Approval_Section__c section : sections ) {
                if ( SL_Describe.isExisting( this.approvalObjectToken, section.Parent_Relationship_Field__c ) ) {
                    this.add( this.approvalObjectToken, section.Parent_Relationship_Field__c );
                }
            }
        }
    }


    // --- related list collecting logic --- //
    public class RelatedListFieldManager extends FieldManager {
        private Schema.SObjectType objectToken;
        private Set<Schema.SObjectField> requiredFields;

        public RelatedListFieldManager( Approval_Section__c section ) {
            super();
            this.objectToken = SL_Describe.getToken( section.Object_API_Name__c );
            this.requiredFields = new Set<Schema.SObjectField>();
            this.initFields( section );
        }

        public Set<Schema.SObjectField> getRequiredFields() {
            return this.requiredFields;
        }

        public Set<Schema.SObjectField> getFieldTokens() {
            return this.getFieldTokens( this.objectToken );
        }

        public List<String> getFieldList() {
            return new List<String>( this.getFieldSet( this.objectToken ) );
        }

        private void initFields( Approval_Section__c section ) {
            Schema.SObjectField fieldToken;
            for ( Approval_Properties__c property : section.Approval_Properties__r ) {
                if ( SL_Describe.isAccessible( section.Object_API_Name__c, property.Field_API_Name__c ) ) {
                    if ( SL_Describe.isRequired( section.Object_API_Name__c, property.Field_API_Name__c ) ) {
                        property.Required__c = true;
                    }
                    if ( property.Required__c ) {   
                        this.requiredFields.add( SL_Describe.getToken( this.objectToken, property.Field_API_Name__c ) );
                    }
                    this.add( this.objectToken, property.Field_API_Name__c );
                }
            }
        }

        private Map<String, DescribeInfo> getDescribeInfo( Approval_Section__c section ) {
            Map<String, DescribeInfo> result = new Map<String, DescribeInfo>();
            for ( Approval_Properties__c property : section.Approval_Properties__r ) {
                if ( SL_Describe.isAccessible( section.Object_API_Name__c, property.Field_API_Name__c ) ) {
                    if ( !result.containsKey( property.Field_API_Name__c ) ) {
                        result.put( property.Field_API_Name__c, new DescribeInfo( SL_Describe.getDescribe( section.Object_API_Name__c, property.Field_API_Name__c ) ) );
                    }
                }
            }
            return result;
        }
    }

    // --- low-level field collecting logic. should be extended with a new class to implement specific logic --- //
    public virtual class FieldManager {
        private Map<Schema.SObjectType, Set<Schema.SObjectField>> fields;

        public FieldManager() {
            this.fields = new Map<Schema.SObjectType, Set<Schema.SObjectField>>();
        }

        public void add( String sObjectName, String fieldName ) {
            this.add( SL_Describe.getToken( sObjectName ), fieldName );
        }

        public void add( Schema.SObjectType objectToken, String fieldName ) {
            this.add( objectToken, SL_Describe.getToken( objectToken, fieldName ) );
        }

        public void add( Schema.SObjectType objectToken, Schema.SObjectField fieldToken ) {
            if ( objectToken == null || fieldToken == null ) {
                return;
            }
            if ( !this.fields.containsKey( objectToken ) ) {
                this.fields.put( objectToken, new Set<Schema.SObjectField>() );
            }
            this.fields.get( objectToken ).add( fieldToken );
        }

        public void add( Schema.SObjectType objectToken, List<String> fieldNames ) {
            for ( String fieldName : fieldNames ) {
                this.add( objectToken, fieldName );
            }
        }

        public void add( Schema.SObjectType objectToken, List<Schema.SObjectField> fieldTokens ) {
            for ( Schema.SObjectField fieldToken : fieldTokens ) {
                this.add( objectToken, fieldToken );
            }
        }

        public Set<Schema.SObjectType> getObjectTokens() {
            return this.fields.keySet();
        }

        public Set<Schema.SObjectField> getFieldTokens( Schema.SObjectType objectToken ) {
            if ( this.fields.containsKey( objectToken ) ) {
                return this.fields.get( objectToken );
            }
            return new Set<Schema.SObjectField>();
        }

        public Set<String> getFieldSet( String sObjectName ) {
            return this.getFieldSet( SL_Describe.getToken( sObjectName ) );
        }

        public Set<String> getFieldSet( Schema.SObjectType objectToken ) {
            return this.getFieldSet( this.fields.get( objectToken ) );
        }

        public String getFieldsJoined( Schema.SObjectType objectToken ) {
            return String.join( new List<String>( this.getFieldSet( objectToken ) ), ',' ); 
        }

        public Set<String> getFieldSet( Set<Schema.SObjectField> fieldTokens ) {
            Set<String> result = new Set<String>();
            if ( fieldTokens == null ) {
                return result;
            }
            for ( Schema.SObjectField fieldToken : fieldTokens ) {
                result.add( String.valueOf( fieldToken ) );
            }
            return result;
        }

        public Boolean isEmpty( Schema.SObjectType objectToken ) {
            return this.getFieldSet( objectToken ).isEmpty();
        }
    }

    private class CustomException extends Exception { }
    private class UrlParamRequiredValueException extends Exception { }
}