public with sharing class SL_LIB16_ME_MassEdit_FilterSOQLCompiler  extends SL_LIB16_FilterSOQLCompiler {
    public Id recordId {get; set;}
    public String targetObject {get; set;} 
    
    protected override String compileFilter(FilterSet p_filter_set) {
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'IN OVERRIDE'));
        
        Condition result;
        Object value;
        Boolean is_multipicklist = isMultipicklist(p_filter_set);
        Boolean is_picklist = isPicklist(p_filter_set);
        Boolean is_number = isNumber(p_filter_set);
        Boolean is_boolean = isBoolean(p_filter_set);
        Boolean is_dateORtime = isDateOrTime(p_filter_set);
        Boolean is_reference = isReference(p_filter_set);
        
        
        if(p_filter_set.Field=='recordtypeid')
        {
        	String strValue = getSrtReferenceIds(p_filter_set);
        	value = strValue;
        }
        else if (is_reference){
            Id v = getReferenceId(p_filter_set);
            //if (v==null) value = null; else 
            value = v;
            p_filter_set.ValueId = value!=null?(String)value:null;
        }
        else if (is_dateORtime) {
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
        } else if (is_number) {
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
        } else if (is_boolean) {
        	String s = getFilterValue(p_filter_set);
        	if (s == 'true') {
        		value = true;
        	} else {
        		value = false;
        	}
        } else if (is_multipicklist) {
            value = splitMultiPicklist2Equal(p_filter_set.Value);
            if(value!=null) value = QClear((String)value);
        } else {
	        value = getFilterValue(p_filter_set);
        }
        
        /*
        if(is_number && value == '') {
            value = '0';
        }
        */
        
        if (value == '\'null\'' || value == 'null') {
        	value = null;
        }
        
        //if((value==null || value.toLowerCase()=='null') && (p_filter_set.Operator == 'excludes' || p_filter_set.Operator == 'includes'))
        //{
        //	value = '';
        //}
        
        //value = null;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'value: ' + value));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'p_filter_set.Operator: ' + p_filter_set.Operator));
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'is_picklist: ' + is_picklist));
        
        if(p_filter_set.Operator == 'equal') {
            if((value != null) && !is_number && ((''+value).indexOf(',')!=-1)) {
            	
            	result = new SetCondition(p_filter_set.Field).inx(QClear((String)value).split(',',0));
            	
            } else {
            	
            	result = new FieldCondition(p_filter_set.Field).equals(value);
            }
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
        //system.debug('Field!!!: ' + p_filter_set.Field + '; FilterType: ' + p_filter_set.FilterType +'!!!') ; 
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Field!!!: ' + p_filter_set.Field + '; FilterType: ' + p_filter_set.FilterType +'!!!'));
        return ' (' + result.toSoql() + ') ';
        
    }
    
    public override String getSOQL() {
        m_parse_result = remapAdvanced(m_advenced);
        //trace = 'remapAdvanced: ' + remapAdvanced(m_advenced);
        try {
            for( Integer i = 0; i < m_filter_set.size(); i++ ) {
                trace = 'getSOQL::['+ i +']::Compile...';
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, trace));
                m_filter_set[i].Compiled = compileFilter(m_filter_set[i]);
                trace = 'getSOQL::['+ i +']::Compile result: ' + m_filter_set[i].Compiled;
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, trace));
                m_parse_result = compileFilters(m_filter_set[i].Order, m_filter_set[i].Compiled);
                //System.debug('m_parse_result______'+m_parse_result);
            }
        }catch (Exception e) {
            trace = 'getSOQL error::' + e.getMessage();
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error: ' + trace));
        }
        return m_parse_result;
    }
     
    protected override String remapAdvanced(String p_advenced) {
        return p_advenced!=null?p_advenced.replaceAll('([0-9]+)', '{#$1}'):null;
    }
    
    protected override String compileFilters(String p_filter_order, String p_filter_compiled) {
        //trace = 'compileFilters: ' + '{#'+ p_filter_order +'}' + '; filter: ' + p_filter_compiled;
        //System.debug('+++++++++++++++++++'+m_parse_result);
        //System.debug('==================compileFilters: ' + '{#'+ p_filter_order +'}' + '; filter: ' + p_filter_compiled);
        return m_parse_result.replaceAll('\\{#'+ p_filter_order +'\\}', p_filter_compiled);
    }
}