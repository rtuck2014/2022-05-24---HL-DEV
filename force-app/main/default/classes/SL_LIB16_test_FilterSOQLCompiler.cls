@isTest
private class SL_LIB16_test_FilterSOQLCompiler
{
	public static testmethod void doTest()
    {
        Test.startTest();
        
        SL_LIB16_FilterSOQLCompiler fSOQLComp = new SL_LIB16_FilterSOQLCompiler();
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('account');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___equal___test##PICKLIST___type___excludes___Analyst##REFERENCE___parentid___notEqual___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('DATETIME___billingcity___notEqual___test##MULTIPICKLIST___type___excludes___Analyst##DATE___parentid___notEqual___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('TIME___billingcity___notEqual___test##DOUBLE___type___includes___Analyst##CURRENCY___parentid___lessThan___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('PERCENT___billingcity___greaterThan___test##INTEGER___type___excludes___Analyst##CURRENCY___parentid___notEqual___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___lessOrEqual___test','1');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___greaterOrEqual___test','1');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___startsWith___test','1');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___contains___test','1');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___notContain___test','1');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___includes___test','1');
        fSOQLComp = new SL_LIB16_FilterSOQLCompiler('STRING___billingcity___excludes___test','1');
        fSOQLComp.isTest = true;
        fSOQLComp.toTestHelp('val1,val2,val3');
        fSOQLComp.getReferenceId(fSOQLComp.m_filter_set.get(0));
        fSOQLComp.Initialize('STRING___billingcity___excludes___test','1','account');
        //fSOQLComp.parseFilter(null);
        String tpmStr = fSOQLComp.SOQL;
        //tpmStr = fSOQLComp.trace;     
        fSOQLComp.Filters = 'sdfg sdfg';
        fSOQLComp.Advenced = '1';
        
        Test.stopTest();
    }
    
    
    public static testmethod void doTest2()
    {
        Test.startTest();
        
        SL_LIB16_ME_MassEdit_FilterSOQLCompiler fSOQLComp = new SL_LIB16_ME_MassEdit_FilterSOQLCompiler();
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___equal___test##PICKLIST___type___excludes___Analyst##REFERENCE___parentid___notEqual___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('DATETIME___billingcity___notEqual___test##MULTIPICKLIST___type___excludes___Analyst##DATE___parentid___notEqual___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('TIME___billingcity___notEqual___test##DOUBLE___type___includes___Analyst##CURRENCY___parentid___lessThan___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('PERCENT___billingcity___greaterThan___test##INTEGER___type___excludes___Analyst##CURRENCY___parentid___notEqual___001T000000M0SZ4','1 AND 2 AND 3');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___lessOrEqual___test','1');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___greaterOrEqual___test','1');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___startsWith___test','1');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___contains___test','1');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___notContain___test','1');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___includes___test','1');
        fSOQLComp.getSOQL();
        fSOQLComp.Initialize('STRING___billingcity___excludes___test','1');
        fSOQLComp.isTest = true;
        fSOQLComp.getSOQL();
        fSOQLComp.toTestHelp('val1,val2,val3');
        fSOQLComp.getReferenceId(fSOQLComp.m_filter_set.get(0));
        fSOQLComp.Initialize('STRING___billingcity___excludes___test','1','account');
        //fSOQLComp.parseFilter(null);
        String tpmStr = fSOQLComp.SOQL;
        //tpmStr = fSOQLComp.trace;     
        fSOQLComp.Filters = 'sdfg sdfg';
        fSOQLComp.Advenced = '1';
        
        Test.stopTest();
    }
}