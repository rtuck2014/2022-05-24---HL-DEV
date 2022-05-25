/*
Created: Serg Brull
version: 1.0.2.010

Updated by Privlad
*/
public virtual with sharing class SL_RTR_LIB16_FilterSOQLCompiler {
    
    public class FilterSet {
        public String FilterType { get; set; }
        public String Field { get; set; }
        public String Operator { get; set; }
        public String Value { get; set; }
        public String ValueId { get; set; }
        public String Order { get; set; } 
        
        public String Compiled { get; set; }
    }
    
    public String sObjectName {get; set;}
    public List<FilterSet> m_filter_set = new List<FilterSet>();
    public String m_advenced;
    public String m_parse_result = null;
    public boolean isTest = false;
    
    protected String m_trace = '';
    public String trace {
        get {
            return m_trace;
        }
        set {
            m_trace += '\n' + value + ' |\n ';
        }
        
    }
    
    public String Filters  {
        set {
            parseFilter(value);
        }
    }

    public String Advenced  {
        set {
            m_advenced = value;
        }
    }
        
    public SL_RTR_LIB16_FilterSOQLCompiler() {}
    
    public SL_RTR_LIB16_FilterSOQLCompiler(String soName) {
        this.sObjectName = soName;
    }
    
    public SL_RTR_LIB16_FilterSOQLCompiler(String p_filters, String p_advenced) {
        Initialize(p_filters, p_advenced);
    }
    
    public void Initialize(String p_filters, String p_advenced) {
        m_advenced = p_advenced;
        parseFilter(p_filters);
    }
    
    public void Initialize(String p_filters, String p_advenced, String soName) {
        this.sObjectName = soName;
        m_advenced = p_advenced;
        parseFilter(p_filters);
    }
    
    public String SOQL {
        get {
            return getSOQL();
        }
        
    }
    
    protected Boolean checkingData(FilterSet filter) 
    {
        trace += 'SL_RTR_LIB16_FilterSOQLCompiler::started';

        if(filter.FilterType == 'DATE') 
        {
            try 
            {
                Date parsedDate = Date.parse(filter.Value);
            }
            catch(Exception e)
            {
                throw new FilterException('Date ( ' + filter.Value+ ' ) in filter creteria is incorrect.'); 
            }
        } 
        else if(filter.FilterType == 'DATETIME') 
        {
            String prepareDate = filter.Value.replace('T', ' ').replace('Z','');
            try 
            {
                Datetime parsedDatetime = Datetime.parse(prepareDate);
            }
            catch(Exception e)
            {
                throw new FilterException('Date and time ( ' + prepareDate + ' ) in filter creteria is incorrect.'); 
            }
        } 
        else if(filter.FilterType == 'ID') 
        {
            try 
            {
                ID parsedID = filter.Value;
            }
            catch(Exception e)
            {
                throw new FilterException('ID ( ' + filter.Value+ ' ) in filter creteria is incorrect.'); 
            }
        }
        else if(filter.FilterType == 'REFERENCE') 
        {
            String result = null;
            Boolean isException = false;
            try {
                result = getSrtReferenceIds(filter);
            } 
            catch(Exception ex) 
            {
                isException = true;
            }
            if( result== null || result == '000000000000000' || isException) 
            {
                throw new FilterException('Lookup value ( ' + filter.Value + ' ) in filter creteria is incorrect.'); 
            }
        }
        return true;
    }
    
    public String validate() 
    {
        String result = '';
        for( Integer i = 0; i < m_filter_set.size(); i++ ) 
        {
            try 
            {   
                checkingData(m_filter_set[i]);
            }
            catch(Exception fe) 
            {
                result += fe.getMessage() + '   ' ;
            }   
        }
        return result;
    }

    
    public void parseFilter(String p_filters) {
        m_filter_set = new List<FilterSet>();
        if(p_filters == null) return;
        //trace = p_filters;
        try {
            String[] filters = p_filters.split('##');
            //trace = 'parseFilter::filters size:: ' + filters.size();
            for(Integer i = 0; i < filters.size(); i++) {
                String[] field = (filters[i]).split('___');
                //trace = 'parseFilter::field size:: ' + field.size();
                Integer size = field.size();
                    if(size>= 3)
                    {
                        //trace = 'parseFilter::i:: ' + i;  
                        FilterSet filter_set = new FilterSet();
                        filter_set.FilterType = field[0].trim().toUpperCase(); 
                        filter_set.Field = field[1].trim();
                        filter_set.Operator = field[2].trim();
                        filter_set.Value = (size >= 4)? field[3]: '';
                        filter_set.Value = String.escapeSingleQuotes(filter_set.Value);
                        filter_set.Value = AddSlashesToSpecChar(filter_set.Value);
                        filter_set.ValueId = (size >= 5)? field[4]: '';
                        filter_set.Order = ''+(i+1);
                        
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Filter :: ' + field));

                        /*
                        trace = 'Field: ' + filter_set.Field + '; FilterType: ' + filter_set.FilterType + 
                                '; Operator: ' + filter_set.Operator + '; Value: ' + filter_set.Value + 
                                '; Order: ' + filter_set.Order;
                        */

                        m_filter_set.add(filter_set);
                    }
            }
        }
        catch (FilterException fe)
        {
            throw fe;
        }
        catch (Exception e) {
            trace = 'parseFilter1: ' + e.getMessage();
        }
        
        //System.debug(' ============= '+m_filter_set);
    }
    
    protected virtual String getSOQL() {
        m_parse_result = remapAdvanced(m_advenced);
        
        SoqlBuilder soqlB = new SoqlBuilder();
        
        //trace = 'remapAdvanced: ' + remapAdvanced(m_advenced);
        try {
            for( Integer i = 0; i < m_filter_set.size(); i++ ) {
                trace = 'getSOQL::['+ i +']::Compile...'; 
                trace = 'getSOQL::['+ i +']::Compile result: ' + m_filter_set[i].Compiled;
                m_filter_set[i].Compiled = compileFilter(m_filter_set[i]);
                m_parse_result = compileFilters(m_filter_set[i].Order, m_filter_set[i].Compiled);
            }
        }catch (Exception e) {
            trace = 'getSOQL error::' + e.getMessage();
        }
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'm_parse_result:: ' + m_parse_result));
        return m_parse_result;
        
    }
    
    protected virtual String remapAdvanced(String p_advenced) {
        return p_advenced.replaceAll('([0-9]+)', '{#$1}');
    }
    
    protected virtual String compileFilters(String p_filter_order, String p_filter_compiled) {
        //trace = 'compileFilters: ' + '{#'+ p_filter_order +'}' + '; filter: ' + p_filter_compiled;
        //System.debug('+++++++++++++++++++'+m_parse_result);
        //System.debug('==================compileFilters: ' + '{#'+ p_filter_order +'}' + '; filter: ' + p_filter_compiled);
        return m_parse_result.replaceAll('\\{#'+ p_filter_order +'\\}', p_filter_compiled);
    }
    
    protected virtual String compileFilter(FilterSet p_filter_set) {
        Condition result;
        Object value;
        Boolean is_multipicklist = isMultipicklist(p_filter_set);
        Boolean is_picklist = isPicklist(p_filter_set);
        Boolean is_number = isNumber(p_filter_set);
        Boolean is_boolean = isBoolean(p_filter_set);
        Boolean is_dateORtime = isDateOrTime(p_filter_set);
        Boolean is_reference = isReference(p_filter_set);
        
        if (p_filter_set.Field=='recordtypeid'){

 			String strValue = getSrtReferenceIds(p_filter_set);
			value = strValue;           

        } else if (is_reference){
        	
       		Id v = getReferenceId(p_filter_set);
            //if (v==null) value = null; else 
            value = v;
            p_filter_set.ValueId = value!=null?(String)value:null;
        
        } else if (is_dateORtime) {
        	String s = getFilterValue(p_filter_set);
        	Boolean isErrorByParsing = true;
        	//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'm_parse_result:: '+s));
        	if(s==null || s=='' || s=='null'){ }
        	else
        	{
	        	if (s.contains('T') && s.contains(':')) {
	        		s = s.replace('Z','');
	        		List<String> parts = s.split('T',0);
	        		try
	        		{
	        			Date preDT = Date.parse(parts[0]);
	        		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'combi data:: '+preDT.format()+' '+parts[1]));
	        			Datetime dt =  Datetime.valueOfGmt(preDT.year()+'-'+preDT.month()+'-'+preDT.day()+' '+parts[1]);
	        			value = dt;
	        			isErrorByParsing = false;
	        		}
	        		catch(Exception ex){}
	        		
	        	}
	        	else if (s.contains('T'))
	        	{
	        		s = s.replace('Z','');
	        		List<String> parts = s.split('T',0);
	        		try
	        		{
	        			Date preDT = Date.parse(parts[0]);
	        			value = preDT;
	        			isErrorByParsing = false;
	        		}
	        		catch(Exception ex){}
		        	
	        	}
        	}
        	
        	if(isErrorByParsing)
	        {
	        	Datetime dt = null;
	        	value = dt;
	        	if(p_filter_set.Operator!='equal' && p_filter_set.Operator != 'notEqual')
	        	{
	        		ID curElemID = null;
	        		p_filter_set.Operator = 'notEqual';
	        		p_filter_set.Field = 'ID';
	        		value = curElemID;
	        	}
	        }
        }
        else if(is_number)
        {
        	Double dbVal = null;
        	String s = getFilterValue(p_filter_set);
        	Boolean isErrorByParsing = true;
        	
        	if(s==null || s=='' || s=='null'){ }
        	else
        	{
	        	try
	        	{
	        		dbVal = Double.valueOf(getFilterValue(p_filter_set));
	        		isErrorByParsing = false;
	        	}
	        	catch(Exception ex){}
        	}
        	value = dbVal;
        	
        	if(isErrorByParsing)
	        {
	        	dbVal = null;
	        	value = dbVal;
	        	if(p_filter_set.Operator!='equal' && p_filter_set.Operator != 'notEqual')
        		{
        			ID curElemID = null;
        			p_filter_set.Operator = 'notEqual';
        			p_filter_set.Field = 'ID';
        			value = curElemID;
        		}
	        }
		}
		else if(is_boolean)
		{
        	String s = getFilterValue(p_filter_set);
        	if (s == 'true') {
        		value = true;
        	} else {
        		value = false;
        	}
		} else if(is_multipicklist){
            value = splitMultiPicklist2Equal(p_filter_set.Value);
            if(value!=null) value = QClear((String)value);
        } else {
	        value = getFilterValue(p_filter_set);
        }
        
        if (value == '\'null\'' || value == 'null') {
        	value = null;
        }
        
        if(p_filter_set.Operator == 'equal'){
           
            if((value != null) && !is_number && ((''+value).indexOf(',')!=-1)) { result = new SetCondition(p_filter_set.Field).inx(QClear((String)value).split(',',0));}
            else{ result = new FieldCondition(p_filter_set.Field).equals(value);}

        } else if(p_filter_set.Operator == 'notEqual') {
        	result = new FieldCondition(p_filter_set.Field).notEquals(value);
        } else if(p_filter_set.Operator == 'lessThan') {
        	result = new FieldCondition(p_filter_set.Field).lessThan(value);
        } else if(p_filter_set.Operator == 'greaterThan') {
        	result = new FieldCondition(p_filter_set.Field).greaterThan(value);
        } else if(p_filter_set.Operator == 'lessOrEqual') {
        	result = new FieldCondition(p_filter_set.Field).lessThanOrEqualTo(value);
        } else if(p_filter_set.Operator == 'greaterOrEqual') {
        	result = new FieldCondition(p_filter_set.Field).greaterThanOrEqualTo(value);
        }else if(p_filter_set.Operator == 'startsWith') {
        	result = new FieldCondition(p_filter_set.Field).likex(value+'%');
        }else if(p_filter_set.Operator == 'contains') {
        	result = new FieldCondition(p_filter_set.Field).likex('%' + value + '%');
        }else if(p_filter_set.Operator == 'notContain') {
        	result = new NotCondition(new FieldCondition(p_filter_set.Field).likex('%' + value + '%'));
        }else if(p_filter_set.Operator == 'includes' && p_filter_set.Field=='recordtypeid') {
        	result = new SetCondition(p_filter_set.Field).inx(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'excludes' && p_filter_set.Field=='recordtypeid') {
        	result = new SetCondition(p_filter_set.Field).notIn(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'includes' && !is_multipicklist && !is_picklist) {
        	result = new SetCondition(p_filter_set.Field).inx(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'excludes' && !is_multipicklist && !is_picklist) {
        	result = new SetCondition(p_filter_set.Field).notIn(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'includes' && is_picklist) {
        	result = new SetCondition(p_filter_set.Field).inx(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'excludes' && is_picklist) {
        	result = new SetCondition(p_filter_set.Field).notIn(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'includes' && is_multipicklist) {
        	result = new SetCondition(p_filter_set.Field).includes(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }else if(p_filter_set.Operator == 'excludes' && is_multipicklist) {
        	result = new SetCondition(p_filter_set.Field).excludes(value!=null?trimStrArr((QClear((String)value)).split(',',0)):new String[]{''});
        }
        // system.debug('Field!!!: ' + p_filter_set.Field + '; FilterType: ' + p_filter_set.FilterType +'!!!') ; 
		//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'result:: ' + result.toSoql()));
        
        return ' (' + result.toSoql() + ') ';
         
    }
    
    protected virtual String getFilterValue(FilterSet p_filter_set){
        String value = '';
        Boolean is_multipicklist = isMultipicklist(p_filter_set);
        Boolean is_picklist = isPicklist(p_filter_set);
        Boolean is_number = isNumber(p_filter_set);
        Boolean is_boolean = isBoolean(p_filter_set);
        Boolean is_dateORtime = isDateOrTime(p_filter_set);
        Boolean is_reference = isReference(p_filter_set);
        
        if (p_filter_set.Field=='recordtypeid'){
            value = getSrtReferenceIds(p_filter_set);
            /*
            String full_value = p_filter_set.Value;
            for (String val : full_value.split(',')){
                if (val==null || val.trim().length()==0) continue;
                p_filter_set.Value = val.trim();
                Id v = getReferenceId(p_filter_set);
                value += ','+v;
            }
            if (value.length()>0) value = value.substring(1);
            */
        }
        else if (is_reference){
            
            Id v = getReferenceId(p_filter_set);
            //if (v==null) value = null; else 
            value = v;
            p_filter_set.ValueId = value;
        }
        else if (isNotQuoteOperator(p_filter_set) || is_number || is_boolean || is_dateORtime) {
            value = p_filter_set.Value;
            if (value.trim().length()==0){
                value = 'null';
            }
        } else if (is_multipicklist) {
            value = splitMultiPicklist2Equal(p_filter_set.Value);
        } else {
            value = p_filter_set.Value;
        }
        
        if(is_number && value == '') {
            value = '0';
        }
        
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'value:: ' + value));
        return value;
    }
    
    public String getSrtReferenceIds(FilterSet p_filter_set){
    	
    	 try { // Check if the value is already an ID and return it, if not keep going.
            ID i = (ID) p_filter_set.Value;
            return i;
        }catch (Exception e) {}
        String res = null;
        if (p_filter_set.ValueId!='' && p_filter_set.ValueId.substring(0, 3)!='000'){
            res = p_filter_set.ValueId;
        } else if(p_filter_set.Value!=null && p_filter_set.Value!=''){
        	String so = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(this.SObjectName, p_filter_set.Field);
        	
        	String SOQLinVal = '';
        	String full_value = p_filter_set.Value;
            for (String val : full_value.split(',')){
                if (val==null || val.trim().length()==0) continue;
                SOQLinVal += ',\''+val.trim()+'\'';
            }
        	if (SOQLinVal.length()>0) SOQLinVal = SOQLinVal.substring(1);
        	
        	if(SOQLinVal!='' && so!=null && so!='')
        	{
	        	String query = 'SELECT Id, Name FROM ' + so + ' WHERE Name in ('+SOQLinVal+') ';
	        	if(so == 'RecordType' && this.SObjectName!=null && this.SObjectName!=''){ query += 'AND SobjectType=\''+this.SObjectName+'\'';}
	            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'id query:: ' + query));
	            try{
	                res = '';
	                for(SObject rt : Database.query(query))
	                {
	                	res += ','+rt.Id;
	                }
	                
	                if (res.length()>0) res = res.substring(1);
	                else res = null;
	            
	            } catch (Exception e){
	                trace = 'getReferenceId :: ' + e.getMessage() + '<br/>' +query;
	            }
			}
        }
    	return res;
    }
    
    
    
    public Id getReferenceId(FilterSet p_filter_set){
        //return '001P0000001Qfcz';
        try { // Check if the value is already an ID and return it, if not keep going.
            ID i = (ID) p_filter_set.Value;
            return i;
        }catch (Exception e) {} // this is intentional, just keep going.
        String res = null;
        trace = 'getReferenceId :: ' + p_filter_set.ValueId + '\n';
        if (p_filter_set.ValueId!='' && p_filter_set.ValueId.substring(0, 3)!='000'){
            res = p_filter_set.ValueId;
        } else {
            String so = SL_RTR_LIB16_ME_DescribeObject_Core.getInstance().getFieldReferenceByName(this.SObjectName, p_filter_set.Field);
            trace = 'SOName: '+this.SObjectName;
            trace = 'SOName: '+p_filter_set.Field;
            trace = 'SOName: '+so;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'trace:: ' + trace)); 
            String query = 'SELECT Id, Name FROM ' + so + ' WHERE Name=\''+p_filter_set.Value+'\' LIMIT 1';
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'id query:: ' + query));
            try{
                SObject rt = Database.query(query).get(0);
                res = rt.Id;
            } catch (Exception e){
                trace = 'getReferenceId :: ' + e.getMessage() + '<br/>' +query;
            }
        }
        return res;
    }
    
    protected Boolean isNotQuoteOperator(FilterSet p_filter_set) {
        return ((p_filter_set.Operator == 'includes')   || 
                (p_filter_set.Operator == 'excludes')   || 
                (p_filter_set.Operator == 'startsWith') || 
                (p_filter_set.Operator == 'contains')   ||
                (p_filter_set.Operator == 'notContain'));
    }
    
    protected Boolean isMultipicklist(FilterSet p_filter_set) {
        return (p_filter_set.FilterType == 'MULTIPICKLIST');
    }
    
    protected Boolean isPicklist(FilterSet p_filter_set) {
        return (p_filter_set.FilterType == 'PICKLIST');
    }
    
    protected Boolean isBoolean(FilterSet p_filter_set) {
        return (p_filter_set.FilterType == 'BOOLEAN');
    }
    
    protected Boolean isDateOrTime(FilterSet p_filter_set) {
        return (p_filter_set.FilterType == 'DATETIME' || 
                p_filter_set.FilterType == 'DATE' ||
                p_filter_set.FilterType == 'TIME');
    }
    
    protected Boolean isNumber(FilterSet p_filter_set) {
        return (p_filter_set.FilterType == 'DOUBLE' || 
                p_filter_set.FilterType == 'CURRENCY' ||
                p_filter_set.FilterType == 'PERCENT' ||
                p_filter_set.FilterType == 'INTEGER' );
    }
    
    protected Boolean isReference(FilterSet p_filter_set){
        return (p_filter_set.FilterType == 'REFERENCE');
    }
    
    protected String removeInvalidChars(String value) 
    {
        String result = value;
        value = value.replace('"', '');
        value = value.replace('\\', '');
        return value;
    }
    
    protected String[] trimStrArr(String[] inVal)
    {
    	if(inVal==null) return null;

    	String[] retVal = new String[]{};
    	for(string item:inVal){ if(item!=null) retVal.add(item.trim());}
    	return retVal;
    }

    protected String QClear(String p_str) {
        if(p_str!=null && p_str.length()>2 && p_str.left(1)=='\'' && p_str.right(1)=='\'')
        {
        	return p_str.substring(1,p_str.length()-1);
        }
        return p_str;
    }
    
    protected String Q(String p_str) {
    	if(p_str!=null && p_str.toLowerCase()=='null') return null;
        return '\'' + p_str + '\'';
    }
    
    public void toTestHelp(String inVal)
    {
        String retVal = splitMultiPicklist2Equal(inVal);
        retVal = splitMultiPicklist2Includes(inVal);
        retVal = removeInvalidChars(inVal);
        Boolean bolFlag = checkingData(m_filter_set.get(0));
        m_filter_set.get(0).FilterType = 'DATE';
        try{ bolFlag = checkingData(m_filter_set.get(0));}
        catch (Exception e){}
        m_filter_set.get(0).FilterType = 'DATETIME';
        try{ bolFlag = checkingData(m_filter_set.get(0));}
        catch (Exception e){}
        m_filter_set.get(0).FilterType = 'ID';
        try{ bolFlag = checkingData(m_filter_set.get(0));}
        catch (Exception e){}
        m_filter_set.get(0).FilterType = 'REFERENCE';
        try{ bolFlag = checkingData(m_filter_set.get(0));}
        catch (Exception e){}
        
        
    }
    
    protected String splitMultiPicklist2Equal(String p_str) {
        String retValue = '';
        if(p_str!=null && p_str!='')
        {
            String[] aSplitVal = p_str.split(',',0);
            for(string tmpVal:aSplitVal)
            {
                retValue = retValue+';'+tmpVal.trim();
            }
            if(retValue!='') retValue = retValue.substring(1);
        }
        
        
        return '\'' + retValue + '\'';
    }

    protected String splitMultiPicklist2Includes(String p_str) {
        String retValue = '';
        if(p_str!=null && p_str!='')
        {
            String[] aSplitVal = p_str.split(',',0);
            for(string tmpVal:aSplitVal)
            {
                retValue = retValue+',\''+tmpVal.trim()+'\'';
            }
            if(retValue!='') retValue = retValue.substring(1);
        }
        
        
        return retValue!=''?retValue:'\'\'';
    }

    
    protected String AddSlashesToSpecChar(String p_str)
    {
        return p_str.replaceAll('\\$', '\\\\\\$');
    }
    
    //"SearchQ": "STRING___billingcity___notEqual___test##PICKLIST___type___excludes___Analyst##REFERENCE___parentid___notEqual___001T000000M0SZ4" 
    // "SearchParam" :"1 AND 2 AND 3"
    
    class FilterException extends Exception{}   

}