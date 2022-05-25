@IsTest
private class hlFieldSetWrapperClassTest {
    @IsTest static void myUnitTest(){
        hlFieldSetWrapperClass wrap = new hlFieldSetWrapperClass();
        wrap.hideDefaultActions=true;
        wrap.label='test';
        wrap.fieldName='test';
        wrap.editable=true;
        wrap.sortable=true;
        wrap.type='text';
        wrap.typeAttributes = new hlFieldSetWrapperClass.TypeAttributes();
        wrap.typeAttributes.label= new hlFieldSetWrapperClass.Label();
        wrap.typeAttributes.label.fieldName='test';
        wrap.typeAttributes.target='_blank';
        wrap.typeAttributes.tooltip='help';
        
    }
}