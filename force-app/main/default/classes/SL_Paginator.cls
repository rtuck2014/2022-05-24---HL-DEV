/**
* @ClassName     : SL_Paginator
* @JIRATicket    : LIB-9
* @CreatedOn     : 31/Jan/13
* @ModifiedBy    : Rehan
* @Description   : This is the generic class for pagination.
  @Parameters to this Class:
   fieldDefinition    : Can accommodate Comma separated   fieldname or FieldSet Name of sObject.
   strObjectName      : This is the Sobject API Name.
   intPageSize        : This is the Number of records to be shown per Page.
   paramWhereCondition: Where condition of SOQL
   isFieldSet         : This argument determines which type of value is accommodating by above mentioned argument â€˜fieldDefinitionâ€™ in constructor. Since it is Boolean, it may contain true or false.
                            If true then fieldDefinition contains name of fieldSet of SObject.
                            If false then fieldDefinition contains Comma separated fieldname.
   
  @Example:
   SL_Paginator obj = new SL_Paginator();
   obj.setQueryString('Id,Name', 25, Account , 'Name=\'test\'',false);
   List<SL_Paginator.SobjectWrapper> lstWrapper = new List<SL_Paginator.SobjectWrapper>();
   lstWrapper = obj.gotoFirstPage();
*/

public class SL_Paginator
{
    /* Start - Variables */
	public  Integer intPageNumber       {get;set;}//To know the current Page no. 
    public  Integer intTotalPages       {get;set;}//To know the total page.
    public Boolean isPreviousDisabled   {get;set;}//To know if the Previous link/button is disabled or not.
    public Boolean isNextDisabled       {get;set;}//To know if the Next link/button is disabled or not.
    public List<SobjectWrapper> lstSObjectWrappers {get;set;}   // This will be local list where we will process all data and return back to main List
                                                                //  where ever it is required by get Method.
    public String strOrderByFieldName   {get;set;}//To set the field Name which will be used for Order By clause.
    public String strOrderByDirection   {get;set;}//To set the direction in which we want the query result.
                                                  // Expected Values : ASC DESC
    public String strWhereCondition;      //Where clause that will apply in SOQL.
    public boolean isValidParameters;    //Parameter will be used in controller where this class Instantiated.To ensure that parameter which is being passed in constructor is 
                                         //correct or not. 
    public Set<Id>  setSelectedIds;//To know the checked items while paginating.
    
    
    private String fieldDefinition;//Can contain Query String or fieldSet(sObject fieldSet) that needs to be queried against the Database.
    private String strObjectName;//API Name of the Sobject we are dealing with the above query string.
    private Map<Integer, Integer> mapPageNumber_StartIndex = new Map<Integer, Integer>();//This map is behaving just like an Index page for a Book.
                                                                                         //Like if you have the Chapter No, it tells you the page no you should be going to.
                                                                                         //Similarly in our case, just pass the Page No and get the exact starting record
    private Integer intPageSize;    //Number of records to be displayed in the grid per page.                                                                                    //for that page.
    private boolean isValueFromFieldSet ; 
    private Map<String, Schema.SObjectType> GlobalDescribeMap ; 
    private string strFieldsFromFieldSet;  //Comman seprated fieldNames of field which contains by fieldSet. 
    private string prevSortOrderField;    //Contains field Name which has been applied in order by clause in last sorting. 
    private Set<Id> setSobjectIdToQuery;
    private Boolean isIdFilter;
    
    /* End - Variables */


    /* Start - Wrapper Class
       Purpose: Using this Wrapper class we can keep a track of selected values while paginating through different pages
       It is generic enough to handle any Sobject */
    public class SobjectWrapper
    {
        public SObject sObjectRecord    {get;set;}
        public Boolean isChecked        {get;set;}
        public SObjectWrapper (SObject sObjectRecord,Boolean isChecked)
        {
           this.sObjectRecord = sObjectRecord;
           this.isChecked = isChecked;
        }
    }
    /* End - Wrapper Class */

    /*  Start - Constructor 
        Arguments: 1)String fieldDef           : Can accommodate Comma separated   fieldname or FieldSet Name of sObject.
                   2)Integer paramPageSize     : Records perPage.
                   3)String paramObjectName    : Name of sObject on which we want to apply pagination .
                   4)String paramWhereCondition: Where condition of SOQL.
                   5)Boolean isFieldSet        : This argument determines which type of value is accommodating by above mentioned argument â€˜fieldDefinitionâ€™ in constructor. Since it is Boolean, it may contain true or false.
                                                    If true then fieldDefinition contains name of fieldSet of SObject.
                                                    If false then fieldDefinition contains Comma separated fieldname.
         
    
    */
    public SL_Paginator(String fieldDef, Integer paramPageSize, String paramObjectName, String paramWhereCondition , boolean isFieldSet, Set<Id> setSobjectIdToQuery, Boolean isIdFilter)
    {
        this(fieldDef, paramPageSize, paramObjectName, paramWhereCondition , isFieldSet, setSobjectIdToQuery, isIdFilter, false);
    }

    public SL_Paginator(String fieldDef, Integer paramPageSize, String paramObjectName, String paramWhereCondition , boolean isFieldSet, Set<Id> setSobjectIdToQuery, Boolean isIdFilter, Boolean skipValidator)
    {
        init(); //Initialize all variables
        if(!skipValidator)
            isValidParameters = validateArguments(paramObjectName, fieldDef, isFieldSet);
        else
            isValidParameters = true;
            
        if(isValidParameters)
            setQueryString(fieldDef, paramPageSize, paramObjectName, paramWhereCondition , isFieldSet, setSobjectIdToQuery, isIdFilter);
        else
            return ;
    }
    /* End - Constructor */
	
	
	/*Start Constructor*/
	public SL_Paginator(ApexPages.StandardSetController setCon)
	{
		
	}
	/*End Constructor*/
	
    /* Start - Method
       Method Name: init
       Arguments: NONE
       Access: PRIVATE
       Return Type: NONE
       Purpose: To initialize all necessary variables.
    */
    private void init()
    {
        //Initializing variables
        isNextDisabled = isPreviousDisabled = false;
        setSelectedIds = new Set<Id>();
        lstSObjectWrappers = new List<SobjectWrapper>();
        GlobalDescribeMap = Schema.getGlobalDescribe(); 
        strFieldsFromFieldSet = '';
        isValidParameters = false;
    }
    /* End - Method */
    
   
    /* Start - Method
       Method Name: validateArguments
       Arguments: 1)paramObjectName : SObject Name
                  2)fieldDef        : Field defination .It may contain comma seprated field or fieldset Name
                  3)isFieldSet      : boolean variable which determines value contains by fieldDef .
                                        If true then fieldDefinition contains name of fieldSet of SObject.
                                        If false then fieldDefinition contains Comma separated fieldname.
       Access: PRIVATE
       Return Type: boolean
       Purpose: Validating argumnets supplying in the contructor wheathere they are correct or not.Supplied sObject Name may be incorrect or comma seprated field Name may contains 
                wrong field name. 
    */
    private boolean validateArguments(string paramObjectName , string fieldDef , boolean isFieldSet)
    {
        //set contains all fieldApiName of sObject
        set<string> setSObjectFields = getFields(paramObjectName);
        
        //Validating sObjectFields
        try
        {
            //Validating sObjectName. 
            if(!GlobalDescribeMap.keySet().Contains(paramObjectName.toLowerCase()))
            {
                throw new SL_MissingArgumentException('Incorrect SObject '+ paramObjectName + ' : Please supply specific SObject Name.');
            }
        }
        catch(SL_MissingArgumentException ex)
        {
            ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR , ex.getMessage());
            ApexPages.addMessage(msg);
            return false;
        }   
        
        // isFieldSet boolean paremeter coming from contructor determines which type of value is accommodating by fieldDef parameter.
        //If true then expected value will be fieldSetName of the sObject else comma seprated fieldName.
        if(isFieldSet == true && fieldDef != null && fieldDef != '')
        {
            //Getting all fieldApiName using describe call of fieldSet .
            set<string> setFieldsFromFieldSet = readFieldSet(fieldDef, paramObjectName);
            try
            {
                for(string field : setFieldsFromFieldSet)
                {
                    if(!setSObjectFields.contains(field) && !field.contains('__r.'))
                        throw new SL_MissingArgumentException('Incorrect SObjectField '+ field + ': Please supply specific SObjectField in FieldSet.');    
                    strFieldsFromFieldSet += field + ',';
                }
            }
            catch(SL_MissingArgumentException ex)
            {
                //Devolper can see the exception if supplied sObject name is incorrect
                system.debug('#######################EXCEPTION FOUND#################'+ex.getMessage());
                ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR , ex.getMessage());
                ApexPages.addMessage(msg);
                return false;
            }
            //stripping last ',' character 
            if(strFieldsFromFieldSet.contains(','))
            {
                strFieldsFromFieldSet = strFieldsFromFieldSet.subString(0,strFieldsFromFieldSet.lastIndexOf(','));              
            }
            return true;
        }
        else
        {
            //Validating each FieldName in the commaSepratedFieldName(fieldDef coming from constructor) wheather that is correct or not.
            List<string> setField = fieldDef.split(',');
            if(!setField.isEmpty())
            {
                try
                {
                    for(string field :setField)
                    {
                        if(!setSObjectFields.contains(field.trim()) && !field.contains('__r.'))
                            throw new SL_MissingArgumentException('Incorrect SObjectField :'+  field +' is an invalid field. Please supply correct field name in comma seprated string.');
                    }
                    
                }
                catch(SL_MissingArgumentException ex)
                {
                    //Devolper can see the exception which will come due to incorrect field in comma seprated fields supplying in construtor. 
                    system.debug('#######################EXCEPTION FOUND#################'+ex.getMessage());
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.Severity.ERROR , ex.getMessage());
                    ApexPages.addMessage(msg);
                    return false;
                }
            }
            return true;
        }
    }
    
    /* Start - Method
       Method Name: createQueryString
       Arguments: NONE
       Access: PRIVATE
       Return Type: STRING
       Purpose: To create dynamically Query String
    */
    private String createQueryString()
    {
        String strMainQuery = '';

        //If fieldSet is being supply in constructor then we are getting all feilds from fieldset using descible call in constructor.
        //isValueFromFieldSet boolean determines that is fieldSet is supply or not.
        if(this.isValueFromFieldSet == true)
        {
            strMainQuery =  ' SELECT ' + strFieldsFromFieldSet ;
        }
        else
        {
            strMainQuery =  ' SELECT ' + this.fieldDefinition ; 
        }
        String strSortFieldName = strOrderByFieldName;
        if(strObjectName != null && strOrderByFieldName != null && ! strOrderByFieldName.contains('__r.'))
        {
	        Schema.SObjectField objField = Schema.getGlobalDescribe().get(strObjectName).getDescribe().fields.getMap().get(strOrderByFieldName);
	  		if(objField.getDescribe().getType() == Schema.DisplayType.REFERENCE)
	  			strSortFieldName = objField.getDescribe().getRelationshipName() +'.Name';
        }
        
        strMainQuery += ' FROM ' + this.strObjectName;

        strMainQuery += (this.strWhereCondition != NULL && this.strWhereCondition != '') ? ' WHERE ' + this.strWhereCondition : '' ;
        
        strMainQuery += (this.isIdFilter && strWhereCondition != '') ? ' AND Id IN:setSobjectIdToQuery' : (this.isIdFilter) ? ' Id IN:setSobjectIdToQuery' : '';

        strMainQuery += (strSortFieldName != NULL && strSortFieldName != '') ? ' ORDER BY ' +  strSortFieldName : '';

        strMainQuery += (this.strOrderByDirection != NULL && this.strOrderByDirection != '') ? ' ' + this.strOrderByDirection + ' NULLS LAST ' : '';
        
        strMainQuery += (this.strObjectName == 'Opportunity__c' || this.strObjectName == 'Engagement__c') ? ' LIMIT 1000' : '';
        System.debug('============strMainQuery========='+strMainQuery);
        return strMainQuery;
    }
    /* End - Method */

    /* Start - Method
       Method Name: setQueryString
       Arguments:   fieldDef            - Can accommodate Comma separated   fieldname or FieldSet Name of sObject.
                    paramPageSize       - Number of records to be displayed in the grid per page.(Integer)
                    paramObjectName     - API Name of the Sobject we are dealing with the above query string.(String)
                    paramWhereCondition - Condition for Query String
                    isFieldSet          - This argument determines which type of value is accommodating by above mentioned argument â€˜fieldDefâ€™.
                                                If true then fieldDef contains name of fieldSet of SObject.
                                                If false then fieldDef contains Comma separated fieldname.
       Access: PRIVATE
       Return Type: NONE
       Purpose: To set the query and initial pagination parameters like Query String, Page Size, Object to be dealt with and Index Page designed within a Map.
    */
    private void setQueryString(String fieldDef, Integer paramPageSize, String paramObjectName, String paramWhereCondition , boolean isFieldSet, Set<Id> setSobjectIdToQuery, Boolean isIdFilter)
    {
        this.fieldDefinition = fieldDef;
        this.strObjectName = paramObjectName;
        this.intPageSize = paramPageSize;
        this.strWhereCondition = paramWhereCondition;
        this.isValueFromFieldSet = isFieldSet;
        this.isIdFilter = isIdFilter;
        this.setSobjectIdToQuery = setSobjectIdToQuery;
        //this.mapPageNumber_StartIndex = fillMapofPageIndexes();
    }
    /* End - Method */

    /* Start - Method
       Method Name: setSortingQueryString
       Arguments:   paramDirection - Direction of sort order.Expected value ASC or DESC.
                    paramFieldName - API Name of the Field we are using for ORDER BY Clause
       Access: PUBLIC
       Return Type: NONE
       Purpose: To set the sorting query and initial pagination parameters like Query String, Page Size, Object to be dealt with and Index Page designed within a Map.
    */
    public void setSortingQueryString(  String paramFieldName,
                                        String paramDirection 
                                    )
    {
        set<String> setSObjectFields = new set<String>();
        if(strObjectName != null && strObjectName != '')
        {
            setSObjectFields = getFields(strObjectName);
        }
        try
        {
            if(!paramFieldName.contains('__r.') && !setSObjectFields.contains(paramFieldName))
            {
                throw  new SL_MissingArgumentException('Incorrect SObjectField :'+  paramFieldName +' is an invalid field. Please supply correct field name in comma seprated string.');
            }
        }
        catch(SL_MissingArgumentException ex)
        {
            //Devolper can see the exception which will come due to incorrect field. 
            system.debug('#######################EXCEPTION FOUND#################'+ex.getMessage());
            return;
        }       
        
        this.strOrderByFieldName = paramFieldName;
        this.strOrderByDirection = paramDirection;
        this.prevSortOrderField = paramFieldName;
    }
    /* End - Method */

    /* Start - Method
       Method Name: fillMapofPageIndexes
       Arguments: NONE
       Access: PRIVATE
       Return Type: Map<Integer, Integer>
       Purpose: To maintain a Map storing Page Number as its Key and Start Index as its value. This would be used to derive the desired Page records.
    */
    private Map<Integer, Integer> fillMapofPageIndexes(List<Sobject> lstTotalRecords)
    {
        Map<Integer, Integer> mapPageNo_StartIndex = new Map<Integer, Integer>();
        Integer intTotalRecords = 0;
        Integer intStartIndex = 0;
        Integer intTotalNoOfPages = 0;
        //String strCreateQuery = createQueryString();
        //try
        //{
            //if(strCreateQuery != null && strCreateQuery != '')
                //lstTotalRecords = Database.query(strCreateQuery);//Query all the records.
        //}
        //catch(QueryException ex)
        //{
            //system.debug('#######################EXCEPTION FOUND#################'+ex.getMessage());
            //Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.ERROR, 'Found Some Exception while extracting records from database'));
            //return null;
        //}
        if(!lstTotalRecords.isEmpty())
            intTotalRecords = lstTotalRecords.size();//Total number of records retrieved.

        if(intPageSize > 0)
            intTotalNoOfPages = Math.mod(intTotalRecords, intPageSize) == 0 ? intTotalRecords / intPageSize : intTotalRecords / intPageSize + 1;

        for(Integer intPageNo = 1; intPageNo <= intTotalNoOfPages; intPageNo++)//Maintain a map which will keep Page No as the Key and Start Index of that page as its Value.
        {
            mapPageNo_StartIndex.put(intPageNo, intStartIndex);
            intStartIndex += intPageSize;
        }
        return mapPageNo_StartIndex;
    }
    /* End - Method */

    /* Start - Method
       Method Name: getPageRecords
       Arguments: NONE
       Access: PRIVATE
       Return Type: void
       Purpose: To retrieve the page records as a list.
    */
    private void getPageRecords()
    {
        List<Sobject> lstSobject = new List<Sobject>();
        lstSObjectWrappers = new List<SObjectWrapper>();
        Integer intStartIndex = 0;
        Integer intEndIndex = 0;
        Integer intTotalRecord = 0 ;
        Integer EndIndex = 0;

        try
        {
            if(createQueryString() != null)
            {
                lstSobject = Database.query(createQueryString());
                mapPageNumber_StartIndex = fillMapofPageIndexes(lstSobject);
            }
        }
        catch(QueryException ex)
        {
            Apexpages.addMessage(new apexpages.Message(ApexPages.Severity.ERROR, 'Found some exception while extracting records from database'));
            return;
        }
        try
        {
            if(!lstSobject.isEmpty())
            {
                if(!lstSobject.isEmpty())
                    intTotalRecord = lstSobject.size();
                    
                if(intPageSize > 0)
                    intTotalPages = Math.mod(intTotalRecord, intPageSize) == 0 ? intTotalRecord / intPageSize : intTotalRecord / intPageSize + 1;//Total number of pages.
                
                    
                intStartIndex = mapPageNumber_StartIndex.get(intPageNumber);//Retrieve the Start index for the related Page No.
                if(intStartIndex == null)
                    intStartIndex = 0;
                
                EndIndex = intStartIndex + intPageSize;//Based on the Start Index and Page Size decide the End index.
                
                Integer offset = 0;
                //Managing offset. 
                if(intTotalRecord < EndIndex)
                    offset = Math.mod(intTotalRecord, intPageSize); 
                else
                    offset = intPageSize ;
            
                intEndIndex = intStartIndex + offset ;
                for(Integer index = intStartIndex; index < intEndIndex; index++)//Now build the list to be shown as the current selected page.
                {
                    lstSObjectWrappers.add(new SobjectWrapper(lstSobject[index],true));
                }
                
                //Decide whether Previous link/button should be disabled or not.    
                isPreviousDisabled = (intPageNumber == 1) ? true : false;   
                
                //Decide whether Previous link/button should be disabled or not.    
                isNextDisabled  = (intPageNumber == intTotalPages) ? true : false;
            }
            else
            {
            	intTotalPages = intPageNumber = 0;
                isPreviousDisabled = isNextDisabled = true;
            }
        }
        catch(Exception ex)
        {
            System.debug('===========Exception========='+ex);
        }
    }
    /* End - Method */

    /* Start - Method
       Method Name: getPage
       Arguments: paramPageNo - Desired page no for which we need to fetch records for.
       Access: PUBLIC
       Return Type: void
       Purpose: To retrieve the desired page records as a list based on the Page No selected.
    */
    public void goToSpecificPage(Integer paramPageNo)
    {
        //setSelectedItemsAndMoveToOtherPage(); // Store the Selected Items for the Current Page.
        intPageNumber = paramPageNo;
        getPageRecords();
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoNextPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: void
       Purpose: To retrieve the current page records as a list based on the Next Page No.
    */
    public void gotoNextPage()
    {
        intPageNumber += 1;//Increase the Page no by 1.
        goToSpecificPage(intPageNumber);//Get the above page records.
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoPrevPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: Void
       Purpose: To retrieve the previous page records as a list and updating the Page number.
    */
    public void gotoPrevPage()
    {
        intPageNumber -= 1;//Reduce the Page no by 1.
        goToSpecificPage(intPageNumber);//Get the above page records.
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoFirstPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: Void
       Purpose: To retrieve the first page records as a list.
    */
    public void gotoFirstPage()
    {
        goToSpecificPage(1);
    }
    /* End - Method */

    /* Start - Method
       Method Name: gotoLastPage
       Arguments: NONE
       Access: PUBLIC
       Return Type: void
       Purpose: To retrieve the last page records as a list.
    */
    public void gotoLastPage()
    {
        goToSpecificPage(intTotalPages);
    }
    /* End - Method */

    /* Start - Method
       Method Name: getSelectedItems
       Arguments: NONE
       Access: PUBLIC
       Return Type:  Set<Id>
       Purpose: To get all Ids which were selected.
    */
    public Set<Id> getSelectedItems()
    {
        return setSelectedIds;
    }
    /* End - Method */

    /* Start - Method
       Method Name: clearSelectedItems
       Arguments: NONE
       Access: PUBLIC
       Return Type: Void
       Purpose: To .
    */
    public void clearSelectedItems()
    {
        setSelectedIds = new Set<Id>();
    }
    /* End - Method */

    /* Start - Method
       Method Name: getListSobjectWrappers
       Arguments: NONE
       Access: PUBLIC
       Return Type: NONE
       Purpose: To get all processed values in list.
    */
    public List<SobjectWrapper> getListSobjectWrappers()
    {
        return this.lstSObjectWrappers;
    }
    /* End - Method */

    /* Start - Method
       Method Name: getListSobjectWrappers
       Arguments: List<SobjectWrapper>
       Access: PUBLIC
       Return Type: Void
       Purpose: To set the list in local list for processing.
    */
    public void setListSobjectWrappers(List<SobjectWrapper> paramSobjectWrappers)
    {
        this.lstSObjectWrappers = paramSobjectWrappers;
    }
    /* End - Method */

    /* Start - Method
       Method Name: getSortingRecords
       Arguments: paramFieldName : 1) FieldName      : API Name of the Field we are using for ORDER BY Clause.
                                   2) paramDirection : Order of SOQL clause. Expected Value ASC DESC
       Access: PUBLIC
       Return Type: NONE
       Purpose: To retrive list for sorted records.
    */
    public void getSortingRecords(String paramFieldName, Integer pageNumber)
    {
        string paramDirection ='';
        if(prevSortOrderField == paramFieldName)
        {
            if(this.strOrderByDirection == 'ASC')
                paramDirection = 'DESC' ;
            else
                paramDirection = 'ASC' ;
        }
        else  
            paramDirection = 'ASC';
        
        prevSortOrderField = paramFieldName;
        setSortingQueryString(paramFieldName, paramDirection);
        intPageNumber = pageNumber; 
        getPageRecords();
    }
    /* End - Method */
    
    
    /* Start - Method
       Method Name: readFieldSet
       Arguments: 1)fieldSetName : FeildSetName
                  2)ObjectName   : sObjectName 
       Access: private
       Return Type: set<string>
       Purpose: Dynamically fetching fields from fieldSet using describe call.
    */
    private set<string> readFieldSet(String fieldSetName, String ObjectName)
    {
        set<string> setFields = new set<string>();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
        if(fieldSetObj != null)
        {
            for(Schema.FieldSetMember field : fieldSetObj.getFields())
            {
                setFields.add(field.getFieldPath());
            }
        }
        return setFields; 
    }
    /* End - Method */
    
        
    /* Start - Method
       Method Name: getFields
       Arguments: sObjectName : sObjectName
       Access: private
       Return Type: set<string>
       Purpose: fetching fields of sObject using describe call.
    */
    
    private set<String> getFields(String sObjectName)
    {
        set<string> setFields = new set<string>();
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(sObjectName);
        if(SObjectTypeObj != null)
        {
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Map<String, Schema.SObjectField> objectFields = DescribeSObjectResultObj.fields.getMap();
            //Preparing set of field's Name of sObject to identifying that given field in parameter is belonging to the sObject or not.
            for(string field : objectFields.keySet())
            {
                setFields.add(objectFields.get(field).getDescribe().getName());
            }
        }
        System.debug('====setFields===='+setFields);
        return setFields;
    }
    
    public void sortRecords()
    {
    	getSortingRecords(strOrderByFieldName, intPageNumber);
    }
    
    public void gotoPage()
    {
    	intPageNumber = (intPageNumber < 1) ? 1 : (intPageNumber > intTotalPages) ? intTotalPages : intPageNumber;
    	goToSpecificPage(intPageNumber);
    }

}