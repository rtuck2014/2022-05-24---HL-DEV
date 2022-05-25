/* ============================================================
 * This code is part of the "apex-lang" open source project avaiable at:
 * 
 *      http://code.google.com/p/apex-lang/
 *
 * This code is licensed under the Apache License, Version 2.0.  You may obtain a 
 * copy of the License at:
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * ============================================================
 */
@IsTest
private class SL_LIB16_ApexLangTest {
     private static testmethod void testObjectToString(){ 
        //test: global static List<String> objectToString(List<Object> objectList){ 
        assertObjectToString(null, null);
        assertObjectToString(new List<Object>{}, new List<String>{});
        final String str1 = 'xyz';
        final String str2 = 'abc';
        assertObjectToString(new List<Object>{str1}, new List<String>{str1});
        assertObjectToString(new List<Object>{str1,str2}, new List<String>{str1,str2});
    }
    
    private static void assertObjectToString(List<Object> objectList, List<String> expected){
        ArrayUtils.assertArraysAreEqual(expected, ArrayUtils.objectToString(objectList));
    }

    private static testmethod void testLowerCase(){
        //test:  global static List<String> lowerCase(List<String> strs)
        ArrayUtils.assertArraysAreEqual(null,ArrayUtils.lowerCase(null)); 
        ArrayUtils.assertArraysAreEqual(new String[]{null},ArrayUtils.lowerCase(new String[]{null})); 
        ArrayUtils.assertArraysAreEqual(new String[]{' '},ArrayUtils.lowerCase(new String[]{' '})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'abc','xyz'},ArrayUtils.lowerCase(new String[]{'abc','xyz'})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'abc','xyz'},ArrayUtils.lowerCase(new String[]{'Abc','xYz'})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'abc','xyz'},ArrayUtils.lowerCase(new String[]{'ABC','XYZ'})); 
    }

    private static testmethod void testUpperCase(){
        //test:  global static List<String> upperCase(List<String> strs)
        ArrayUtils.assertArraysAreEqual(null,ArrayUtils.lowerCase(null)); 
        ArrayUtils.assertArraysAreEqual(new String[]{null},ArrayUtils.upperCase(new String[]{null})); 
        ArrayUtils.assertArraysAreEqual(new String[]{' '},ArrayUtils.upperCase(new String[]{' '})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'ABC','XYZ'},ArrayUtils.upperCase(new String[]{'abc','xyz'})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'ABC','XYZ'},ArrayUtils.upperCase(new String[]{'Abc','xYz'})); 
        ArrayUtils.assertArraysAreEqual(new String[]{'ABC','XYZ'},ArrayUtils.upperCase(new String[]{'ABC','XYZ'})); 
    }
    
    private static testmethod void testTrim(){
        //test:  global static List<String> trim(List<String> strs)
        ArrayUtils.assertArraysAreEqual(null,ArrayUtils.trim(null)); 
        ArrayUtils.assertArraysAreEqual(new String[]{null},ArrayUtils.trim(new String[]{null})); 
        ArrayUtils.assertArraysAreEqual(new String[]{''},ArrayUtils.trim(new String[]{' \n\t '})); 
    }

    private static testmethod void testReverseObject(){
        //test: global static Object[] reverse(Object[] anArray) 
        Object[] nullArray = null;
        ArrayUtils.assertArraysAreEqual(null,ArrayUtils.reverse(nullArray)); 
        ArrayUtils.assertArraysAreEqual(new String[]{},ArrayUtils.reverse(new String[]{}));
        ArrayUtils.assertArraysAreEqual(new String[]{'a'},ArrayUtils.reverse(new String[]{'a'}));
        ArrayUtils.assertArraysAreEqual(new String[]{'ab', 'c'},ArrayUtils.reverse(new String[]{'c','ab'}));
        ArrayUtils.assertArraysAreEqual(new String[]{'a', 'b', 'c'},ArrayUtils.reverse(new String[]{'c','b','a'}));
    }

    private static testmethod void testReverseSObject(){
        //test: global static SObject[] reverse(SObject[] anArray) 
        SObject[] nullArray = null;
        Account x = new Account(name='x');
        Account y = new Account(name='y');
        Account z = new Account(name='z');
        ArrayUtils.assertArraysAreEqual(null,ArrayUtils.reverse(nullArray)); 
        ArrayUtils.assertArraysAreEqual(new Account[]{},ArrayUtils.reverse(new Account[]{}));
        ArrayUtils.assertArraysAreEqual(new Account[]{x},ArrayUtils.reverse(new Account[]{x}));
        ArrayUtils.assertArraysAreEqual(new Account[]{x,y},ArrayUtils.reverse(new Account[]{y, x}));
        ArrayUtils.assertArraysAreEqual(new Account[]{x,y,z},ArrayUtils.reverse(new Account[]{z,y,x}));
    }

    private static testmethod void testIsEmpty(){
        //test: global static Boolean isEmpty(Object[] objectArray){
        String[] aNull = null;
        Account[] aNull2 = null;
        IntegerRange[] aNull3 = null;
        System.assertEquals(true,    ArrayUtils.isEmpty(aNull)); 
        System.assertEquals(true,    ArrayUtils.isEmpty(new String[]{})); 
        System.assertEquals(false,    ArrayUtils.isEmpty(new String[]{'a'})); 
        System.assertEquals(false,    ArrayUtils.isEmpty(new String[]{'a','b'})); 
        System.assertEquals(true,    ArrayUtils.isEmpty(new Integer[]{})); 
        System.assertEquals(false,    ArrayUtils.isEmpty(new Integer[]{1})); 
        System.assertEquals(false,    ArrayUtils.isEmpty(new Integer[]{1,2})); 
        System.assertEquals(true,    ArrayUtils.isEmpty(aNull2)); 
        System.assertEquals(true,    ArrayUtils.isEmpty(new Account[]{}));  
        System.assertEquals(false,    ArrayUtils.isEmpty(new Account[]{new Account(name='test')}));  
        System.assertEquals(true,    ArrayUtils.isEmpty(aNull3)); 
        System.assertEquals(true,    ArrayUtils.isEmpty(new IntegerRange[]{}));  
        System.assertEquals(false,    ArrayUtils.isEmpty(new IntegerRange[]{new IntegerRange(1,10)}));  
    }
    
    private static testmethod void testIsNotEmpty(){
        //test: global static Boolean isNotEmpty(Object[] objectArray){
        String[] aNull = null;
        Account[] aNull2 = null;
        IntegerRange[] aNull3 = null;
        System.assertEquals(false,    ArrayUtils.isNotEmpty(aNull)); 
        System.assertEquals(false,    ArrayUtils.isNotEmpty(new String[]{})); 
        System.assertEquals(true,    ArrayUtils.isNotEmpty(new String[]{'a'})); 
        System.assertEquals(true,    ArrayUtils.isNotEmpty(new String[]{'a','b'})); 
        System.assertEquals(false,    ArrayUtils.isNotEmpty(new Integer[]{})); 
        System.assertEquals(true,    ArrayUtils.isNotEmpty(new Integer[]{1})); 
        System.assertEquals(true,    ArrayUtils.isNotEmpty(new Integer[]{1,2})); 
        System.assertEquals(false,    ArrayUtils.isNotEmpty(aNull2)); 
        System.assertEquals(false,    ArrayUtils.isNotEmpty(new Account[]{}));  
        System.assertEquals(true,    ArrayUtils.isNotEmpty(new Account[]{new Account(name='test')}));  
        System.assertEquals(false,    ArrayUtils.isNotEmpty(aNull3)); 
        System.assertEquals(false,    ArrayUtils.isNotEmpty(new IntegerRange[]{}));  
        System.assertEquals(true,    ArrayUtils.isNotEmpty(new IntegerRange[]{new IntegerRange(1,10)}));  
    }
    
    private static testmethod void testPluck(){
        //test: global static Object[] pluck(SObject[] objectArray, String fieldName)
        assertPluck(null,'name',new Object[]{});
        assertPluck(new Account[]{new Account(name='abc123'),new Account(name='xyz456')},null,new Object[]{});
        assertPluck(new Account[]{new Account(name='abc123'),new Account(name='xyz456')},'name',
            new String[]{'abc123','xyz456'});
    }    
    
    private static void assertPluck(SObject[] objectArray, String fieldName, Object[] expected){
        Object[] actual = ArrayUtils.pluck(objectArray, fieldName);
        ArrayUtils.assertArraysAreEqual(expected, actual);    
    }

    private static testmethod void testMergeObjectArrays(){
        //test: global static Object[] mergex(Object[] array1, Object[] array2)
        Object[] nullArray = null;
        System.assertEquals(null,ArrayUtils.mergex(nullArray,nullArray));
        ArrayUtils.assertArraysAreEqual(new Object[]{},ArrayUtils.mergex(new Object[]{},nullArray));
        ArrayUtils.assertArraysAreEqual(new Object[]{},ArrayUtils.mergex(nullArray,new Object[]{}));
        Object x = 'x';
        Object y = 'y';
        Object z = 'z';
        Object ten = 10;
        ArrayUtils.assertArraysAreEqual(new Object[]{x,y,z,ten},ArrayUtils.mergex(new Object[]{x,y},new Object[]{z,ten}));
    }    
    
    private static testmethod void testMergeSObjectArrays(){
        //test: global static SObject[] mergex(SObject[] array1, SObject[] array2)
        SObject[] nullArray = null;
        System.assertEquals(null,ArrayUtils.mergex(nullArray,nullArray));
        ArrayUtils.assertArraysAreEqual(new Account[]{},ArrayUtils.mergex(new Account[]{},nullArray));
        ArrayUtils.assertArraysAreEqual(new Account[]{},ArrayUtils.mergex(new Account[]{},new Account[]{}));
        Account x = new Account(name='x');
        Account y = new Account(name='y');
        Account z = new Account(name='z');
        Account ten = new Account(name='10');
        ArrayUtils.assertArraysAreEqual(new Account[]{x,y,z,ten},ArrayUtils.mergex(new Account[]{x,y},new Account[]{z,ten}));
    }    
    
    private static testmethod void testCreateEmptySObjectList(){
        //test: global static List<SObject> createEmptySObjectList(SObject prototype)
        System.assertEquals(null,ArrayUtils.createEmptySObjectList(null));
        ArrayUtils.assertArraysAreEqual(new Account[]{},ArrayUtils.createEmptySObjectList(new Account()));
    }

    
    /*
    private static testmethod void testQSortSObjects(){
        List<Account> listToSort = new Account[]{new Account(name='test9'),
                                                 new Account(name='test5'),
                                                 new Account(name='test3'),
                                                 new Account(name='test7'),
                                                 new Account(name='test8'),
                                                 new Account(name='test1'),
                                                 new Account(name='test2')};
                                                    
        ArrayUtils.qsort(listToSort, new SObjectSortByNameComparator());
        System.assertNotEquals(null, listToSort);
        System.assertEquals(7, listToSort.size());
        System.assertEquals('test1', listToSort[0].Name);
        System.assertEquals('test2', listToSort[1].Name);
        System.assertEquals('test3', listToSort[2].Name); 
        
    }
    */
    private static testmethod void testQSortForceDotComPrimitives(){
        List<Double> listToSort = new Double[]{4,1.22,-5.4,1.22,3.2};
        ArrayUtils.qsort(listToSort);
        System.assertNotEquals(null, listToSort);
        System.assertEquals(5, listToSort.size());

        System.assertEquals(-5.4,     listToSort[0]);
        System.assertEquals(1.22,     listToSort[1]);
        System.assertEquals(1.22,    listToSort[2]);
        System.assertEquals(3.2,     listToSort[3]);
        System.assertEquals(4,         listToSort[4]);

        ArrayUtils.qsort(listToSort, false);
        System.assertNotEquals(null, listToSort);
        System.assertEquals(5, listToSort.size());

        System.assertEquals(4,         listToSort[0]);
        System.assertEquals(3.2,     listToSort[1]);
        System.assertEquals(1.22,     listToSort[2]);
        System.assertEquals(1.22,    listToSort[3]);
        System.assertEquals(-5.4,     listToSort[4]);
    }  
    
    /*
    private static testmethod void testQSortCustomClasses(){
        IntegerRange r1 = new IntegerRange(-10,10);
        IntegerRange r2 = new IntegerRange(1,2);
        IntegerRange r3 = new IntegerRange(3,10);
        List<IntegerRange> listToSort = new IntegerRange[]{r1,r2,r3};
        
        ArrayUtils.qsort(listToSort,new IntegerRangeComparator());
        System.assertNotEquals(null, listToSort);
        System.assertEquals(3, listToSort.size());
        System.assertEquals(r1.min(), listToSort.get(0).min());
        System.assertEquals(r2.min(), listToSort.get(1).min());
        System.assertEquals(r3.min(), listToSort.get(2).min());
    }
    */ 

    private static testmethod void testToString(){
        List<Object> aList = null;
        ArrayUtils.toString(aList);
        aList = new IntegerRange[]{};
        ArrayUtils.toString(aList);
        aList = new IntegerRange[]{new IntegerRange(12,15),new IntegerRange(12,15)};
        ArrayUtils.toString(aList);
    }

    private static testmethod void testMergeForceDotComPrimitives(){
        List<Object> l1 = new List<Object>();
        for(Integer i = 0; i < ArrayUtils.MAX_NUMBER_OF_ELEMENTS_IN_LIST; i++){
            l1.add(i);
        }
        Boolean exceptionThrown = false;
        try{
            ArrayUtils.merg(l1, new Integer[]{1});
        }catch(IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);

        Double[] d1 = new Double[]{1,2,3};
        Double[] d2 = new Double[]{4,5,6};
        List<Object> merged = ArrayUtils.merg(d1, d2);
        System.assertNotEquals(null,merged);
        System.assertEquals(6,merged.size());
        System.assertEquals(1,merged.get(0));
        System.assertEquals(4,merged.get(3));
    }
    
    private static testmethod void testSubsetCustomClasses(){
        Object[] iobjs = new IntegerRange[]{
            new IntegerRange(1,1),new IntegerRange(2,2),new IntegerRange(3,3)};
        List<Object> returned = ArrayUtils.subset(iobjs, 2);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals(1,((IntegerRange)returned.get(0)).min());
        System.assertEquals(2,((IntegerRange)returned.get(1)).min());
        
    }

    private static testmethod void testMergeCustomClasses(){
        List<Object> l1 = new List<Object>();
        for(Integer i = 0; i < ArrayUtils.MAX_NUMBER_OF_ELEMENTS_IN_LIST; i++){
            l1.add(new IntegerRange(i,i));
        }
        Boolean exceptionThrown = false;
        try{
            ArrayUtils.merg(l1, new IntegerRange[]{new IntegerRange(1,1)});
        }catch(IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);

        IntegerRange[] d1 = new IntegerRange[]{new IntegerRange(1,1),new IntegerRange(2,2)};
        IntegerRange[] d2 = new IntegerRange[]{new IntegerRange(3,3),new IntegerRange(4,4)};
        List<Object> merged = ArrayUtils.merg(d1, d2);
        System.assertNotEquals(null,merged);
        System.assertEquals(4,merged.size());
        System.assertEquals(1,((IntegerRange)merged.get(0)).min());
        System.assertEquals(3,((IntegerRange)merged.get(2)).min());
    }
    
    private static testmethod void testSubsetSObjects(){
        SObject[] sobjs = new Account[]{
            new Account(name='1'),
            new Account(name='2'),
            new Account(name='3')};
        List<SObject> returned = ArrayUtils.subset(sobjs, 2);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals('1',((Account)returned.get(0)).name);
        System.assertEquals('2',((Account)returned.get(1)).name);
    }

    private static testmethod void testMergeSObjects(){
        List<SObject> l1 = new List<Account>();
        for(Integer i = 0; i < ArrayUtils.MAX_NUMBER_OF_ELEMENTS_IN_LIST; i++){
            l1.add(new Account());
        }
        Boolean exceptionThrown = false;
        try{
            ArrayUtils.merg(l1, new Account[]{new Account()});
        }catch(IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
        l1 = null;
        List<SObject> merged = ArrayUtils.merg(l1,l1);
        System.assertEquals(null,merged);
        
        Account[] c1 = new Account[]{new Account(name='1'),new Account(name='2')};
        merged = ArrayUtils.merg(l1,c1);
        Account[] c2 = new Account[]{new Account(name='3'),new Account(name='4')};
        merged = ArrayUtils.merg(c1, c2);
        System.assertNotEquals(null,merged);
        System.assertEquals(4,merged.size());
        System.assertEquals('1',((Account)merged.get(0)).name);
        System.assertEquals('2',((Account)merged.get(1)).name);
        System.assertEquals('3',((Account)merged.get(2)).name);
        System.assertEquals('4',((Account)merged.get(3)).name);
    }
    
    private static testmethod void testSubsetForceDotComPrimitives(){
        Double[] prim = new Double[]{1,2,3};
        List<Object> returned = ArrayUtils.subset(prim, 3);
        System.assertNotEquals(null,returned);
        System.assertEquals(3,returned.size());
        System.assertEquals(1,returned.get(0));
        System.assertEquals(2,returned.get(1));
        System.assertEquals(3,returned.get(2));

        returned = ArrayUtils.subset(prim, 2);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals(1,returned.get(0));
        System.assertEquals(2,returned.get(1));

        returned = ArrayUtils.subset(prim, 1);
        System.assertNotEquals(null,returned);
        System.assertEquals(1,returned.size());
        System.assertEquals(1,returned.get(0));

        returned = ArrayUtils.subset(prim,1,3);
        System.assertNotEquals(null,returned);
        System.assertEquals(2,returned.size());
        System.assertEquals(2,returned.get(0));
        System.assertEquals(3,returned.get(1));

        returned = ArrayUtils.subset(prim,-1,2);
        System.assertNotEquals(null,returned);
        System.assertEquals(0,returned.size());

        returned = ArrayUtils.subset(prim,10,2);
        System.assertNotEquals(null,returned);
        System.assertEquals(0,returned.size());

        returned = ArrayUtils.subset(prim,0,20);
        System.assertNotEquals(null,returned);
        System.assertEquals(3,returned.size());

        prim = null;
        returned = ArrayUtils.subset(prim,0,2);
        System.assertNotEquals(null,returned);
        System.assertEquals(0,returned.size());


            //subset({1,2,3},0,3)={1,2,3}
    //subset({1,2,3},1,3)={2,3}
    //subset({1,2,3},2,3)={3}
    //subset({1,2,3},3,3)={}
    //subset({1,2,3},0,2)={1,2}
    //subset({1,2,3},1,2)={2,3}
    //subset({1,2,3},2,2)={3}
        
    }




    private static String CHARS_ASCII_CONTROL = '\n\t\r\f';        
    private static String CHARS_ASCII_DIGITS = '0123456789';
    private static String CHARS_ASCII_UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    private static String CHARS_ASCII_LOWER = 'abcdefghijklmnopqrstuvwxyz';
    private static String CHARS_ASCII_PRINTABLE = ' !"#$%&\'()*+,-./' + CHARS_ASCII_DIGITS + ':;<=>?@' + CHARS_ASCII_UPPER + '[\\]^_`' + CHARS_ASCII_LOWER + '{|}~';
    private static String CHARS_ALL_ASCII = CHARS_ASCII_CONTROL + CHARS_ASCII_PRINTABLE;
    private static String CHARS_NON_ASCII = 'â‚¬Â�â€šÆ’â€žâ€¦â€ â€¡Ë†â€°Å â€¹Å’Â�Å½Â�Â�â€˜â€™â€œâ€�â€¢â€“â€”Ëœâ„¢Å¡â€ºÅ“Â�Å¾Å¸Â Â¡Â¢Â£Â¤Â¥Â¦Â§Â¨Â©ÂªÂ«Â¬Â­Â®Â¯Â°Â±Â²Â³Â´ÂµÂ¶Â·Â¸Â¹ÂºÂ»Â¼Â½Â¾Â¿Ã€Ã�Ã‚ÃƒÃ„Ã…Ã†Ã‡ÃˆÃ‰ÃŠÃ‹ÃŒÃ�ÃŽÃ�Ã�Ã‘Ã’Ã“Ã”Ã•Ã–Ã—Ã˜Ã™ÃšÃ›ÃœÃ�ÃžÃŸÃ Ã¡Ã¢Ã£Ã¤Ã¥Ã¦Ã§Ã¨Ã©ÃªÃ«Ã¬Ã­Ã®Ã¯Ã°Ã±Ã²Ã³Ã´ÃµÃ¶Ã·Ã¸Ã¹ÃºÃ»Ã¼Ã½Ã¾';
    private static String CHARS_ASCII_NON_PRINTABLE = CHARS_ASCII_CONTROL + CHARS_NON_ASCII;

    private static testmethod void testValidateChar(){
        final String[] badCharStrings = new String[]{'','AB'};
        for(String badCharString : badCharStrings){
            try{
                Character.validateChar(badCharString);
                System.assert(false,'Exception should have been thrown for invalid char: ' + badCharString);
            } catch(Exception e){}
        }
        Character.validateChar('B');
    }
    
    private static testmethod void testIsUpperCase(){
        final String UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        for(Integer i = 0; i < UPPER.length(); i++){
            assertIsUpperCase(UPPER.substring(i,i+1), true);
        }
        final String LOWER = 'abcdefghijklmnopqrstuvwxyz';
        for(Integer i = 0; i < LOWER.length(); i++){
            assertIsUpperCase(LOWER.substring(i,i+1), false);
        }
    }    
    
    private static void assertIsUpperCase(String aCharacter, Boolean expected){
        Boolean actual = Character.isUpperCase(aCharacter);
        System.assert(actual==expected, 'Character.isUpperCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testToTitleCase(){
        assertToTitleCase('\t','\t');
        assertToTitleCase('\n','\n');
        assertToTitleCase('\f','\f');
        assertToTitleCase('\r','\r');
        assertToTitleCase(' ',' ');
        assertToTitleCase('!','!');
        assertToTitleCase('"','"');
        assertToTitleCase('#','#');
        assertToTitleCase('$','$');
        assertToTitleCase('%','%');
        assertToTitleCase('&','&');
        assertToTitleCase('\'','\'');
        assertToTitleCase('(','(');
        assertToTitleCase(')',')');
        assertToTitleCase('*','*');
        assertToTitleCase('+','+');
        assertToTitleCase(',',',');
        assertToTitleCase('-','-');
        assertToTitleCase('.','.');
        assertToTitleCase('/','/');
        assertToTitleCase('0','0');
        assertToTitleCase('1','1');
        assertToTitleCase('2','2');
        assertToTitleCase('3','3');
        assertToTitleCase('4','4');
        assertToTitleCase('5','5');
        assertToTitleCase('6','6');
        assertToTitleCase('7','7');
        assertToTitleCase('8','8');
        assertToTitleCase('9','9');
        assertToTitleCase(':',':');
        assertToTitleCase(';',';');
        assertToTitleCase('<','<');
        assertToTitleCase('=','=');
        assertToTitleCase('>','>');
        assertToTitleCase('?','?');
        assertToTitleCase('@','@');
        assertToTitleCase('A','A');
        assertToTitleCase('B','B');
        assertToTitleCase('C','C');
        assertToTitleCase('D','D');
        assertToTitleCase('E','E');
        assertToTitleCase('F','F');
        assertToTitleCase('G','G');
        assertToTitleCase('H','H');
        assertToTitleCase('I','I');
        assertToTitleCase('J','J');
        assertToTitleCase('K','K');
        assertToTitleCase('L','L');
        assertToTitleCase('M','M');
        assertToTitleCase('N','N');
        assertToTitleCase('O','O');
        assertToTitleCase('P','P');
        assertToTitleCase('Q','Q');
        assertToTitleCase('R','R');
        assertToTitleCase('S','S');
        assertToTitleCase('T','T');
        assertToTitleCase('U','U');
        assertToTitleCase('V','V');
        assertToTitleCase('W','W');
        assertToTitleCase('X','X');
        assertToTitleCase('Y','Y');
        assertToTitleCase('Z','Z');
        assertToTitleCase('[','[');
        assertToTitleCase('\\','\\');
        assertToTitleCase(']',']');
        assertToTitleCase('^','^');
        assertToTitleCase('_','_');
        assertToTitleCase('`','`');
        assertToTitleCase('a','A');
        assertToTitleCase('b','B');
        assertToTitleCase('c','C');
        assertToTitleCase('d','D');
        assertToTitleCase('e','E');
        assertToTitleCase('f','F');
        assertToTitleCase('g','G');
        assertToTitleCase('h','H');
        assertToTitleCase('i','I');
        assertToTitleCase('j','J');
        assertToTitleCase('k','K');
        assertToTitleCase('l','L');
        assertToTitleCase('m','M');
        assertToTitleCase('n','N');
        assertToTitleCase('o','O');
        assertToTitleCase('p','P');
        assertToTitleCase('q','Q');
        assertToTitleCase('r','R');
        assertToTitleCase('s','S');
        assertToTitleCase('t','T');
        assertToTitleCase('u','U');
        assertToTitleCase('v','V');
        assertToTitleCase('w','W');
        assertToTitleCase('x','X');
        assertToTitleCase('y','Y');
        assertToTitleCase('z','Z');
        assertToTitleCase('{','{');
        assertToTitleCase('|','|');
        assertToTitleCase('}','}');
        assertToTitleCase('~','~');
    }    
    
    private static void assertToTitleCase(String aCharacter, String expected){
        String actual = Character.toTitleCase(aCharacter);
        System.assert(actual==expected, 'Character.toTitleCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testToLowerCase(){
        assertToLowerCase('\t','\t');
        assertToLowerCase('\n','\n');
        assertToLowerCase('\f','\f');
        assertToLowerCase('\r','\r');
        assertToLowerCase(' ',' ');
        assertToLowerCase('!','!');
        assertToLowerCase('"','"');
        assertToLowerCase('#','#');
        assertToLowerCase('$','$');
        assertToLowerCase('%','%');
        assertToLowerCase('&','&');
        assertToLowerCase('\'','\'');
        assertToLowerCase('(','(');
        assertToLowerCase(')',')');
        assertToLowerCase('*','*');
        assertToLowerCase('+','+');
        assertToLowerCase(',',',');
        assertToLowerCase('-','-');
        assertToLowerCase('.','.');
        assertToLowerCase('/','/');
        assertToLowerCase('0','0');
        assertToLowerCase('1','1');
        assertToLowerCase('2','2');
        assertToLowerCase('3','3');
        assertToLowerCase('4','4');
        assertToLowerCase('5','5');
        assertToLowerCase('6','6');
        assertToLowerCase('7','7');
        assertToLowerCase('8','8');
        assertToLowerCase('9','9');
        assertToLowerCase(':',':');
        assertToLowerCase(';',';');
        assertToLowerCase('<','<');
        assertToLowerCase('=','=');
        assertToLowerCase('>','>');
        assertToLowerCase('?','?');
        assertToLowerCase('@','@');
        assertToLowerCase('A','a');
        assertToLowerCase('B','b');
        assertToLowerCase('C','c');
        assertToLowerCase('D','d');
        assertToLowerCase('E','e');
        assertToLowerCase('F','f');
        assertToLowerCase('G','g');
        assertToLowerCase('H','h');
        assertToLowerCase('I','i');
        assertToLowerCase('J','j');
        assertToLowerCase('K','k');
        assertToLowerCase('L','l');
        assertToLowerCase('M','m');
        assertToLowerCase('N','n');
        assertToLowerCase('O','o');
        assertToLowerCase('P','p');
        assertToLowerCase('Q','q');
        assertToLowerCase('R','r');
        assertToLowerCase('S','s');
        assertToLowerCase('T','t');
        assertToLowerCase('U','u');
        assertToLowerCase('V','v');
        assertToLowerCase('W','w');
        assertToLowerCase('X','x');
        assertToLowerCase('Y','y');
        assertToLowerCase('Z','z');
        assertToLowerCase('[','[');
        assertToLowerCase('\\','\\');
        assertToLowerCase(']',']');
        assertToLowerCase('^','^');
        assertToLowerCase('_','_');
        assertToLowerCase('`','`');
        assertToLowerCase('a','a');
        assertToLowerCase('b','b');
        assertToLowerCase('c','c');
        assertToLowerCase('d','d');
        assertToLowerCase('e','e');
        assertToLowerCase('f','f');
        assertToLowerCase('g','g');
        assertToLowerCase('h','h');
        assertToLowerCase('i','i');
        assertToLowerCase('j','j');
        assertToLowerCase('k','k');
        assertToLowerCase('l','l');
        assertToLowerCase('m','m');
        assertToLowerCase('n','n');
        assertToLowerCase('o','o');
        assertToLowerCase('p','p');
        assertToLowerCase('q','q');
        assertToLowerCase('r','r');
        assertToLowerCase('s','s');
        assertToLowerCase('t','t');
        assertToLowerCase('u','u');
        assertToLowerCase('v','v');
        assertToLowerCase('w','w');
        assertToLowerCase('x','x');
        assertToLowerCase('y','y');
        assertToLowerCase('z','z');
        assertToLowerCase('{','{');
        assertToLowerCase('|','|');
        assertToLowerCase('}','}');
        assertToLowerCase('~','~');
    }
    
    private static void assertToLowerCase(String aCharacter, String expected){
        String actual = Character.toLowerCase(aCharacter);
        System.assert(actual==expected, 'Character.toLowerCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testIsTitleCase(){
        //test: global static Boolean isTitleCase(String character){ 
        assertIsTitleCase('\t',FALSE);
        assertIsTitleCase('\n',FALSE);
        assertIsTitleCase('\f',FALSE);
        assertIsTitleCase('\r',FALSE);
        assertIsTitleCase(' ',FALSE);
        assertIsTitleCase('!',FALSE);
        assertIsTitleCase('"',FALSE);
        assertIsTitleCase('#',FALSE);
        assertIsTitleCase('$',FALSE);
        assertIsTitleCase('%',FALSE);
        assertIsTitleCase('&',FALSE);
        assertIsTitleCase('\'',FALSE);
        assertIsTitleCase('(',FALSE);
        assertIsTitleCase(')',FALSE);
        assertIsTitleCase('*',FALSE);
        assertIsTitleCase('+',FALSE);
        assertIsTitleCase(',',FALSE);
        assertIsTitleCase('-',FALSE);
        assertIsTitleCase('.',FALSE);
        assertIsTitleCase('/',FALSE);
        assertIsTitleCase('0',FALSE);
        assertIsTitleCase('1',FALSE);
        assertIsTitleCase('2',FALSE);
        assertIsTitleCase('3',FALSE);
        assertIsTitleCase('4',FALSE);
        assertIsTitleCase('5',FALSE);
        assertIsTitleCase('6',FALSE);
        assertIsTitleCase('7',FALSE);
        assertIsTitleCase('8',FALSE);
        assertIsTitleCase('9',FALSE);
        assertIsTitleCase(':',FALSE);
        assertIsTitleCase(';',FALSE);
        assertIsTitleCase('<',FALSE);
        assertIsTitleCase('=',FALSE);
        assertIsTitleCase('>',FALSE);
        assertIsTitleCase('?',FALSE);
        assertIsTitleCase('@',FALSE);
        assertIsTitleCase('A',TRUE);
        assertIsTitleCase('B',TRUE);
        assertIsTitleCase('C',TRUE);
        assertIsTitleCase('D',TRUE);
        assertIsTitleCase('E',TRUE);
        assertIsTitleCase('F',TRUE);
        assertIsTitleCase('G',TRUE);
        assertIsTitleCase('H',TRUE);
        assertIsTitleCase('I',TRUE);
        assertIsTitleCase('J',TRUE);
        assertIsTitleCase('K',TRUE);
        assertIsTitleCase('L',TRUE);
        assertIsTitleCase('M',TRUE);
        assertIsTitleCase('N',TRUE);
        assertIsTitleCase('O',TRUE);
        assertIsTitleCase('P',TRUE);
        assertIsTitleCase('Q',TRUE);
        assertIsTitleCase('R',TRUE);
        assertIsTitleCase('S',TRUE);
        assertIsTitleCase('T',TRUE);
        assertIsTitleCase('U',TRUE);
        assertIsTitleCase('V',TRUE);
        assertIsTitleCase('W',TRUE);
        assertIsTitleCase('X',TRUE);
        assertIsTitleCase('Y',TRUE);
        assertIsTitleCase('Z',TRUE);
        assertIsTitleCase('[',FALSE);
        assertIsTitleCase('\\',FALSE);
        assertIsTitleCase(']',FALSE);
        assertIsTitleCase('^',FALSE);
        assertIsTitleCase('_',FALSE);
        assertIsTitleCase('`',FALSE);
        assertIsTitleCase('a',FALSE);
        assertIsTitleCase('b',FALSE);
        assertIsTitleCase('c',FALSE);
        assertIsTitleCase('d',FALSE);
        assertIsTitleCase('e',FALSE);
        assertIsTitleCase('f',FALSE);
        assertIsTitleCase('g',FALSE);
        assertIsTitleCase('h',FALSE);
        assertIsTitleCase('i',FALSE);
        assertIsTitleCase('j',FALSE);
        assertIsTitleCase('k',FALSE);
        assertIsTitleCase('l',FALSE);
        assertIsTitleCase('m',FALSE);
        assertIsTitleCase('n',FALSE);
        assertIsTitleCase('o',FALSE);
        assertIsTitleCase('p',FALSE);
        assertIsTitleCase('q',FALSE);
        assertIsTitleCase('r',FALSE);
        assertIsTitleCase('s',FALSE);
        assertIsTitleCase('t',FALSE);
        assertIsTitleCase('u',FALSE);
        assertIsTitleCase('v',FALSE);
        assertIsTitleCase('w',FALSE);
        assertIsTitleCase('x',FALSE);
        assertIsTitleCase('y',FALSE);
        assertIsTitleCase('z',FALSE);
        assertIsTitleCase('{',FALSE);
        assertIsTitleCase('|',FALSE);
        assertIsTitleCase('}',FALSE);
        assertIsTitleCase('~',FALSE);
    }
    
    private static void assertIsTitleCase(String aCharacter, Boolean expected){
        Boolean actual = Character.isTitleCase(aCharacter);
        System.assert(actual==expected, 'Character.isTitleCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testToUpperCase(){
        //test: global static String toUpperCase(String ch){
        assertToUpperCase('\t','\t');
        assertToUpperCase('\n','\n');
        assertToUpperCase('\f','\f');
        assertToUpperCase('\r','\r');
        assertToUpperCase(' ',' ');
        assertToUpperCase('!','!');
        assertToUpperCase('"','"');
        assertToUpperCase('#','#');
        assertToUpperCase('$','$');
        assertToUpperCase('%','%');
        assertToUpperCase('&','&');
        assertToUpperCase('\'','\'');
        assertToUpperCase('(','(');
        assertToUpperCase(')',')');
        assertToUpperCase('*','*');
        assertToUpperCase('+','+');
        assertToUpperCase(',',',');
        assertToUpperCase('-','-');
        assertToUpperCase('.','.');
        assertToUpperCase('/','/');
        assertToUpperCase('0','0');
        assertToUpperCase('1','1');
        assertToUpperCase('2','2');
        assertToUpperCase('3','3');
        assertToUpperCase('4','4');
        assertToUpperCase('5','5');
        assertToUpperCase('6','6');
        assertToUpperCase('7','7');
        assertToUpperCase('8','8');
        assertToUpperCase('9','9');
        assertToUpperCase(':',':');
        assertToUpperCase(';',';');
        assertToUpperCase('<','<');
        assertToUpperCase('=','=');
        assertToUpperCase('>','>');
        assertToUpperCase('?','?');
        assertToUpperCase('@','@');
        assertToUpperCase('A','A');
        assertToUpperCase('B','B');
        assertToUpperCase('C','C');
        assertToUpperCase('D','D');
        assertToUpperCase('E','E');
        assertToUpperCase('F','F');
        assertToUpperCase('G','G');
        assertToUpperCase('H','H');
        assertToUpperCase('I','I');
        assertToUpperCase('J','J');
        assertToUpperCase('K','K');
        assertToUpperCase('L','L');
        assertToUpperCase('M','M');
        assertToUpperCase('N','N');
        assertToUpperCase('O','O');
        assertToUpperCase('P','P');
        assertToUpperCase('Q','Q');
        assertToUpperCase('R','R');
        assertToUpperCase('S','S');
        assertToUpperCase('T','T');
        assertToUpperCase('U','U');
        assertToUpperCase('V','V');
        assertToUpperCase('W','W');
        assertToUpperCase('X','X');
        assertToUpperCase('Y','Y');
        assertToUpperCase('Z','Z');
        assertToUpperCase('[','[');
        assertToUpperCase('\\','\\');
        assertToUpperCase(']',']');
        assertToUpperCase('^','^');
        assertToUpperCase('_','_');
        assertToUpperCase('`','`');
        assertToUpperCase('a','A');
        assertToUpperCase('b','B');
        assertToUpperCase('c','C');
        assertToUpperCase('d','D');
        assertToUpperCase('e','E');
        assertToUpperCase('f','F');
        assertToUpperCase('g','G');
        assertToUpperCase('h','H');
        assertToUpperCase('i','I');
        assertToUpperCase('j','J');
        assertToUpperCase('k','K');
        assertToUpperCase('l','L');
        assertToUpperCase('m','M');
        assertToUpperCase('n','N');
        assertToUpperCase('o','O');
        assertToUpperCase('p','P');
        assertToUpperCase('q','Q');
        assertToUpperCase('r','R');
        assertToUpperCase('s','S');
        assertToUpperCase('t','T');
        assertToUpperCase('u','U');
        assertToUpperCase('v','V');
        assertToUpperCase('w','W');
        assertToUpperCase('x','X');
        assertToUpperCase('y','Y');
        assertToUpperCase('z','Z');
        assertToUpperCase('{','{');
        assertToUpperCase('|','|');
        assertToUpperCase('}','}');
        assertToUpperCase('~','~');
    }    
    
    private static void assertToUpperCase(String aCharacter, String expected){
        String actual = Character.toUpperCase(aCharacter);
        System.assert(actual==expected, 'Character.toUpperCase(\'' + aCharacter + '\') returned ' + actual);
    }
    
    private static testmethod void testIsLowerCase(){
        final String UPPER = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        for(Integer i = 0; i < UPPER.length(); i++){
            assertIsLowerCase(UPPER.substring(i,i+1), false);
        }
        final String LOWER = 'abcdefghijklmnopqrstuvwxyz';
        for(Integer i = 0; i < LOWER.length(); i++){
            assertIsLowerCase(LOWER.substring(i,i+1), true);
        }
    }    
    
    private static void assertIsLowerCase(String aCharacter, Boolean expected){
        Boolean actual = Character.isLowerCase(aCharacter);
        System.assert(actual==expected, 'Character.isLowerCase(\'' + aCharacter + '\') returned ' + actual);
    }

    private static testmethod void testToAscii(){
        //test: global static Integer toAscii(String character){
        assertToAscii('\t',9);
        assertToAscii('\n',10);
        assertToAscii('\f',12);
        assertToAscii('\r',13);
        for(Integer i = 0; i < CHARS_ASCII_PRINTABLE.length(); i++){
            assertToAscii(StringUtils.charAt(CHARS_ASCII_PRINTABLE,i), i+32);
        }
    }
    
    private static void assertToAscii(String charactr, Integer expected){
        Integer actual = Character.toAscii(charactr); 
        System.assert(actual==expected, 'Character.toAscii(' + charactr + ') returned \'' 
            + actual + '\'; expected \'' +expected + '\'');
    }

    private static testmethod void testToChar(){
        //test: global static String toChar(Integer ascii){
        assertToChar(-1,null);
        assertToChar(0,null);
        assertToChar(128,null);
        assertToChar(9,'\t');
        assertToChar(10,'\n');
        assertToChar(12,'\f');
        assertToChar(13,'\r');
        for(Integer i = 32; i < 128; i++){
            assertToChar(i,StringUtils.charAt(CHARS_ASCII_PRINTABLE,i-32));
        }
    }

    private static void assertToChar(Integer ascii, String expected){
        String actual = Character.toChar(ascii); 
        System.assert(actual==expected, 'Character.toChar(' + ascii + ') returned \'' 
            + actual + '\'; expected \'' +expected + '\'');
    }

    private static testmethod void testIsAscii(){
        //test: global static boolean isAscii(String character) {
        for(Integer i = 0; i < CHARS_ALL_ASCII.length(); i++){
            assertIsAscii(StringUtils.charAt(CHARS_ALL_ASCII,i), true);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAscii(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsAscii(String charactr, Boolean expected){
        Boolean actual = Character.isAscii(charactr); 
        System.assert(actual==expected, 'Character.isAscii(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiPrintable(){
        //test: global static boolean isAsciiPrintable(String character) {
        for(Integer i = 0; i < CHARS_ASCII_PRINTABLE.length(); i++){
            assertIsAsciiPrintable(StringUtils.charAt(CHARS_ASCII_PRINTABLE,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_NON_PRINTABLE.length(); i++){
            assertIsAsciiPrintable(StringUtils.charAt(CHARS_ASCII_NON_PRINTABLE,i), false);        
        }
    }     

    private static void assertIsAsciiPrintable(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiPrintable(charactr); 
        System.assert(actual==expected, 'Character.isAsciiPrintable(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiControl(){
        //test: global static boolean isAsciiControl(String character) {
        for(Integer i = 0; i < CHARS_ASCII_CONTROL.length(); i++){
            asertIsAsciiControl(StringUtils.charAt(CHARS_ASCII_CONTROL,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_PRINTABLE.length(); i++){
            asertIsAsciiControl(StringUtils.charAt(CHARS_ASCII_PRINTABLE,i), false);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            asertIsAsciiControl(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void asertIsAsciiControl(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiControl(charactr); 
        System.assert(actual==expected, 'Character.isAsciiControl(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlpha(){
        //test: global static boolean isAsciiAlpha(String character) {
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(CHARS_ASCII_UPPER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(CHARS_ASCII_LOWER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(CHARS_ASCII_DIGITS,i), false);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAsciiAlpha(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsAsciiAlpha(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiAlpha(charactr); 
        System.assert(actual==expected, 'Character.isAsciiAlpha(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlphaUpper(){
        //test: global static boolean isAsciiAlphaUpper(String character) {
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(CHARS_ASCII_UPPER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(CHARS_ASCII_LOWER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(CHARS_ASCII_DIGITS,i), false);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAsciiAlphaUpper(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsAsciiAlphaUpper(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiAlphaUpper(charactr); 
        System.assert(actual==expected, 'Character.isAsciiAlphaUpper(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlphaLower(){
        //test: global static boolean isAsciiAlphaLower(String character) {
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(CHARS_ASCII_UPPER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(CHARS_ASCII_LOWER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(CHARS_ASCII_DIGITS,i), false);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAsciiAlphaLower(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsAsciiAlphaLower(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiAlphaLower(charactr); 
        System.assert(actual==expected, 'Character.isAsciiAlphaLower(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiNumeric(){
        //test: global static boolean isAsciiNumeric(String character) {
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(CHARS_ASCII_UPPER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(CHARS_ASCII_LOWER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(CHARS_ASCII_DIGITS,i), true);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAsciiNumeric(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsAsciiNumeric(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiNumeric(charactr); 
        System.assert(actual==expected, 'Character.isAsciiNumeric(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testIsAsciiAlphanumeric(){
        //test: global static boolean isAsciiAlphanumeric(String character) {
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(CHARS_ASCII_UPPER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(CHARS_ASCII_LOWER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(CHARS_ASCII_DIGITS,i), true);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAsciiAlphanumeric(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     
    
    private static void assertIsAsciiAlphanumeric(String charactr, Boolean expected){
        Boolean actual = Character.isAsciiAlphanumeric(charactr); 
        System.assert(actual==expected, 'Character.isAsciiAlphanumeric(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsDigit(){
        //test: global static Boolean isDigit(String character){ 
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(CHARS_ASCII_UPPER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(CHARS_ASCII_LOWER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(CHARS_ASCII_DIGITS,i), true);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsAsciiDigit(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsAsciiDigit(String charactr, Boolean expected){
        Boolean actual = Character.isDigit(charactr); 
        System.assert(actual==expected, 'Character.isDigit(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsLetter(){
        //test: global static Boolean isLetter(String character){ 
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsLetter(StringUtils.charAt(CHARS_ASCII_UPPER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsLetter(StringUtils.charAt(CHARS_ASCII_LOWER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsLetter(StringUtils.charAt(CHARS_ASCII_DIGITS,i), false);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsLetter(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     

    private static void assertIsLetter(String charactr, Boolean expected){
        Boolean actual = Character.isLetter(charactr); 
        System.assert(actual==expected, 'Character.isLetter(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsLetterOrDigit(){
        //test: global static Boolean isLetterOrDigit(String character){
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(CHARS_ASCII_UPPER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(CHARS_ASCII_LOWER,i), true);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(CHARS_ASCII_DIGITS,i), true);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsLetterOrDigit(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
    }     
    
    private static void assertIsLetterOrDigit(String charactr, Boolean expected){
        Boolean actual = Character.isLetterOrDigit(charactr); 
        System.assert(actual==expected, 'Character.isLetterOrDigit(\'' + charactr + '\') returned ' + actual);
    }

    private static testmethod void testIsWhitespace(){
        //test: global static Boolean isWhitespace(String character){
        for(Integer i = 0; i < CHARS_ASCII_UPPER.length(); i++){
            assertIsWhitespace(StringUtils.charAt(CHARS_ASCII_UPPER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_LOWER.length(); i++){
            assertIsWhitespace(StringUtils.charAt(CHARS_ASCII_LOWER,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_DIGITS.length(); i++){
            assertIsWhitespace(StringUtils.charAt(CHARS_ASCII_DIGITS,i), false);        
        }
        for(Integer i = 0; i < CHARS_NON_ASCII.length(); i++){
            assertIsWhitespace(StringUtils.charAt(CHARS_NON_ASCII,i), false);        
        }
        for(Integer i = 0; i < CHARS_ASCII_CONTROL.length(); i++){
            assertIsWhitespace(StringUtils.charAt(CHARS_ASCII_CONTROL,i), true);        
        }
    }     
    
    private static void assertIsWhitespace(String charactr, Boolean expected){
        Boolean actual = Character.isWhitespace(charactr); 
        System.assert(actual==expected, 'Character.isWhitespace(\'' + charactr + '\') returned ' + actual);
    }
            
    private static testmethod void testGetType(){
        //test: global static Integer getType(String character){
        //assertGetType('Â¿', Character.UNASSIGNED); 
        assertGetType(Character.toChar(0), Character.CONTROL); 
        assertGetType(Character.toChar(9), Character.CONTROL); 
        assertGetType(Character.toChar(10), Character.CONTROL); 
        assertGetType(Character.toChar(12), Character.CONTROL); 
        assertGetType(Character.toChar(13), Character.CONTROL); 
        assertGetType(Character.toChar(32), Character.SPACE_SEPARATOR); 
        assertGetType(Character.toChar(33), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(34), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(35), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(36), Character.CURRENCY_SYMBOL); 
        assertGetType(Character.toChar(37), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(38), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(39), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(40), Character.START_PUNCTUATION); 
        assertGetType(Character.toChar(41), Character.END_PUNCTUATION); 
        assertGetType(Character.toChar(42), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(43), Character.MATH_SYMBOL); 
        assertGetType(Character.toChar(44), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(45), Character.DASH_PUNCTUATION); 
        assertGetType(Character.toChar(46), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(47), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(48), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(49), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(50), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(51), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(52), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(53), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(54), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(55), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(56), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(57), Character.DECIMAL_DIGIT_NUMBER); 
        assertGetType(Character.toChar(58), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(59), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(60), Character.MATH_SYMBOL); 
        assertGetType(Character.toChar(61), Character.MATH_SYMBOL); 
        assertGetType(Character.toChar(62), Character.MATH_SYMBOL); 
        assertGetType(Character.toChar(63), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(64), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(65), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(66), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(67), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(68), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(69), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(70), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(71), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(72), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(73), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(74), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(75), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(76), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(77), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(78), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(79), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(80), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(81), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(82), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(83), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(84), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(85), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(86), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(87), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(88), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(89), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(90), Character.UPPERCASE_LETTER); 
        assertGetType(Character.toChar(91), Character.START_PUNCTUATION); 
        assertGetType(Character.toChar(92), Character.OTHER_PUNCTUATION); 
        assertGetType(Character.toChar(93), Character.END_PUNCTUATION); 
        assertGetType(Character.toChar(94), Character.MODIFIER_SYMBOL); 
        assertGetType(Character.toChar(95), Character.CONNECTOR_PUNCTUATION); 
        assertGetType(Character.toChar(96), Character.MODIFIER_SYMBOL); 
        assertGetType(Character.toChar(97), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(98), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(99), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(100), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(101), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(102), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(103), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(104), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(105), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(106), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(107), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(108), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(109), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(110), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(111), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(112), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(113), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(114), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(115), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(116), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(117), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(118), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(119), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(120), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(121), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(122), Character.LOWERCASE_LETTER ); 
        assertGetType(Character.toChar(123), Character.START_PUNCTUATION); 
        assertGetType(Character.toChar(124), Character.MATH_SYMBOL); 
        assertGetType(Character.toChar(125), Character.END_PUNCTUATION); 
        assertGetType(Character.toChar(126), Character.MATH_SYMBOL); 
        assertGetType(Character.toChar(127), Character.CONTROL); 
    }     
    
    private static void assertGetType(String charactr, Integer expected){
        Integer actual = Character.getType(charactr); 
        System.assert(actual==expected, 'Character.getType(\'' + charactr + '\') returned ' + actual
            + ', expected ' + expected);
    }


    
    
    
    
    
    
    
    
    
    
    
    private static testmethod void testInvalidField(){
        Boolean exceptionCaught = false;
        try{
            new FieldCondition('  ',null,null);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(
            exceptionCaught == true, 
            'empty field param to FieldCondition constructor did not throw IllegalArgumentException');
    }

    private static testmethod void testInvalidOperator_INCLUDES(){
        Boolean exceptionCaught = false;
        try{
            new FieldCondition('x',Operator.INCLUDES,null);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidOperator_EXCLUDES(){
        Boolean exceptionCaught = false;
        try{
            new FieldCondition('x',Operator.EXCLUDES,null);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidOperator_INX(){
        Boolean exceptionCaught = false;
        try{
            new FieldCondition('x',Operator.INX,null);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidOperator_NOT_IN(){
        Boolean exceptionCaught = false;
        try{
            new FieldCondition('x',Operator.NOT_IN,null);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testInvalidValue(){
        Boolean exceptionCaught = false;
        try{
            new FieldCondition('x',new IntegerRange(0,1)).toSoql();
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNullValue(){
        System.assertEquals('name = null',new FieldCondition('name',Operator.EQUALS,null).toSoql());   
    }

    private static testmethod void testStringValue(){
        System.assertEquals('name = \'acme\'',new FieldCondition().field('name').equals('acme').toSoql());   
        System.assertEquals('name = \'acme\'',new FieldCondition('name').equals('acme').toSoql());   
        System.assertEquals('name = \'acme\'',new FieldCondition('name',Operator.EQUALS,'acme').toSoql());   
        System.assertEquals('name like \'%acme%\'',new FieldCondition().field('name').likex('%acme%').toSoql());   
        System.assertEquals('name like \'%acme%\'',new FieldCondition('name').likex('%acme%').toSoql());   
        System.assertEquals('name like \'%acme%\'',new FieldCondition('name',Operator.LIKEX,'%acme%').toSoql());   
    }

    private static testmethod void testBooleanValue(){
        System.assertEquals('ispartner = true',new FieldCondition('ispartner',Operator.EQUALS,true).toSoql());   
        System.assertEquals('ispartner = false',new FieldCondition('ispartner',Operator.EQUALS,false).toSoql());   
    }

    private static testmethod void testIntegerValue(){
        System.assertEquals('employees = 1',new FieldCondition('employees',Operator.EQUALS,1).toSoql());   
        System.assertEquals('employees != 1',new FieldCondition('employees',Operator.NOT_EQUALS,1).toSoql());   
        System.assertEquals('employees < 1',new FieldCondition('employees',Operator.LESS_THAN,1).toSoql());   
        System.assertEquals('employees > 1',new FieldCondition('employees',Operator.GREATER_THAN ,1).toSoql());   
        System.assertEquals('employees <= 1',new FieldCondition('employees',Operator.LESS_THAN_OR_EQUAL_TO,1).toSoql());   
        System.assertEquals('employees >= 1',new FieldCondition('employees',Operator.GREATER_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testDoubleValue(){
        System.assertEquals('employees = 1.1',new FieldCondition('employees',Operator.EQUALS,1.1).toSoql());   
        System.assertEquals('employees != 1.1',new FieldCondition('employees',Operator.NOT_EQUALS,1.1).toSoql());   
        System.assertEquals('employees < 1.1',new FieldCondition('employees',Operator.LESS_THAN,1.1).toSoql());   
        System.assertEquals('employees > 1.1',new FieldCondition('employees',Operator.GREATER_THAN ,1.1).toSoql());   
        System.assertEquals('employees <= 1.1',new FieldCondition('employees',Operator.LESS_THAN_OR_EQUAL_TO,1.1).toSoql());   
        System.assertEquals('employees >= 1.1',new FieldCondition('employees',Operator.GREATER_THAN_OR_EQUAL_TO,1.1).toSoql());   
    }

    private static testmethod void testDateValue(){
        System.assertEquals('createddate < 1960-02-17',new FieldCondition('createddate',Operator.LESS_THAN,Date.newinstance(1960, 2, 17)).toSoql());   
    }

    private static testmethod void testDatetimeValue(){
        System.assertEquals('createddate >= 2008-12-01T00:00:00Z',new FieldCondition('createddate',Operator.GREATER_THAN_OR_EQUAL_TO,Datetime.newInstance(2008, 12, 1)).toSoql());   
    }

    private static testmethod void testOperatorMethod_equals(){
        System.assertEquals('x = 1',new FieldCondition().field('x').equals(1).toSoql());   
        System.assertEquals('x = 1',new FieldCondition('x').equals(1).toSoql());   
        System.assertEquals('x = 1',new FieldCondition('x',Operator.EQUALS,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_notEquals(){
        System.assertEquals('x != 1',new FieldCondition().field('x').notEquals(1).toSoql());   
        System.assertEquals('x != 1',new FieldCondition('x').notEquals(1).toSoql());   
        System.assertEquals('x != 1',new FieldCondition('x',Operator.NOT_EQUALS,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_lessThan(){
        System.assertEquals('x < 1',new FieldCondition().field('x').lessThan(1).toSoql());   
        System.assertEquals('x < 1',new FieldCondition('x').lessThan(1).toSoql());   
        System.assertEquals('x < 1',new FieldCondition('x',Operator.LESS_THAN,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_lessThanOrEqualTo(){
        System.assertEquals('x <= 1',new FieldCondition().field('x').lessThanOrEqualTo(1).toSoql());   
        System.assertEquals('x <= 1',new FieldCondition('x').lessThanOrEqualTo(1).toSoql());   
        System.assertEquals('x <= 1',new FieldCondition('x',Operator.LESS_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_greaterThan(){
        System.assertEquals('x > 1',new FieldCondition().field('x').greaterThan(1).toSoql());   
        System.assertEquals('x > 1',new FieldCondition('x').greaterThan(1).toSoql());   
        System.assertEquals('x > 1',new FieldCondition('x',Operator.GREATER_THAN,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_greaterThanOrEqualTo(){
        System.assertEquals('x >= 1',new FieldCondition().field('x').greaterThanOrEqualTo(1).toSoql());   
        System.assertEquals('x >= 1',new FieldCondition('x').greaterThanOrEqualTo(1).toSoql());   
        System.assertEquals('x >= 1',new FieldCondition('x',Operator.GREATER_THAN_OR_EQUAL_TO,1).toSoql());   
    }

    private static testmethod void testOperatorMethod_likex(){
        System.assertEquals('x like \'acme\'',new FieldCondition().field('x').likex('acme').toSoql());   
        System.assertEquals('x like \'acme\'',new FieldCondition('x').likex('acme').toSoql());   
        System.assertEquals('x like \'acme\'',new FieldCondition('x',Operator.LIKEX,'acme').toSoql());   

        System.assertEquals('x like \'%acme%\'',new FieldCondition().field('x').likex('acme').toSoql(new SoqlOptions().wildcardStringsInLikeOperators()));   
        System.assertEquals('x like \'%acme%\'',new FieldCondition('x').likex('acme').toSoql(new SoqlOptions().wildcardStringsInLikeOperators()));   
        System.assertEquals('x like \'%acme%\'',new FieldCondition('x',Operator.LIKEX,'acme').toSoql(new SoqlOptions().wildcardStringsInLikeOperators()));   
    }

    private static testmethod void testName(){
        Field field = new Field('test');
        System.assertNotEquals(null,field);
        System.assertEquals('test',field.toSoql());
    }

    private static testmethod void testToLabel(){
        Field field = new Field('test').toLabelx();
        System.assertNotEquals(null,field);
        System.assertEquals('toLabel(test)',field.toSoql());
    }


private static testmethod void testContains(){
        assertContains(new IntegerRange(0),0,true);
        assertContains(new IntegerRange(-1,1),-2,false);
        assertContains(new IntegerRange(-1,1),-0,true);
        assertContains(new IntegerRange(-1,1),0,true);
        assertContains(new IntegerRange(-1,1),2,false);
    }
    
    private static void assertContains(IntegerRange range1, Integer aNumber, Boolean expected){
        Boolean actual = range1.contains(aNumber);
        System.assert(actual==expected, 'IntegerRange(' + range1.toAString() 
            + ').contains(' + aNumber + ') returned ' + actual);
    }

    private static testmethod void testContainsRange(){
        assertContainsRange(new IntegerRange(0),new IntegerRange(0),true);
        assertContainsRange(new IntegerRange(0,1),new IntegerRange(0,1),true);
        assertContainsRange(new IntegerRange(1,2),new IntegerRange(4,5),false);
        assertContainsRange(new IntegerRange(1,2),new IntegerRange(2,5),false);
        assertContainsRange(new IntegerRange(1,2),new IntegerRange(1,2),true);
        assertContainsRange(new IntegerRange(1,2),new IntegerRange(2,2),true);
    }
    
    private static void assertContainsRange(IntegerRange range1, IntegerRange range2, Boolean expected){
        Boolean actual = range1.contains(range2);
        System.assert(actual==expected, 'IntegerRange(' + range1.toAString() 
            + ').contains(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testOverlaps(){
        assertOverlaps(new IntegerRange(0),new IntegerRange(0),true);
        assertOverlaps(new IntegerRange(-1,1),new IntegerRange(0,1),true);
        assertOverlaps(new IntegerRange(-1,1),new IntegerRange(2),false);
        assertOverlaps(new IntegerRange(-1,1),new IntegerRange(0,1),true);
        assertOverlaps(new IntegerRange(-1,1),new IntegerRange(-1,-0),true);
        assertOverlaps(new IntegerRange(-1,1),new IntegerRange(-3,-2),false);
    }
    
    private static void assertOverlaps(IntegerRange range1, IntegerRange range2, Boolean expected){
        Boolean actual = range1.overlaps(range2);
        System.assert(actual==expected, 'IntegerRange(' + range1.toAString() 
            + ').overlaps(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testMin(){
        assertMin(new IntegerRange(0),0);
        assertMin(new IntegerRange(-1,1),-1);
        assertMin(new IntegerRange(1,-1),-1);
    }
    
    private static void assertMin(IntegerRange range1, Integer expected){
        Integer actual = range1.min();
        System.assert(actual==expected, 'IntegerRange(' + range1.toAString() 
            + ').getMinimum() returned ' + actual);
    }

    private static testmethod void testMax(){
        assertMax(new IntegerRange(0),0);
        assertMax(new IntegerRange(-1,1),1);
        assertMax(new IntegerRange(1,-1),1);
    }
    
    private static void assertMax(IntegerRange range1, Integer expected){
        Integer actual = range1.max();
        System.assert(actual==expected, 'IntegerRange(' + range1.toAString() 
            + ').getMaximum() returned ' + actual);
    }

    private static testmethod void testNullsConstructor1(){
        Boolean exceptionCaught = false;
        try{ new IntegerRange(null); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new IntegerRange(null)\' did not throw IllegalArgumentException');
    }
    
    private static testmethod void testNullsConstructor2(){
        Boolean exceptionCaught = false;
        try{ new IntegerRange(null,null); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new IntegerRange(null,null)\' did not throw IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new IntegerRange(null,0); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new IntegerRange(null,0)\' did not throw IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new IntegerRange(0,null); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new IntegerRange(0,null)\' did not throw IllegalArgumentException');
    }
    
    
     private static testmethod void testContainsLong(){
        assertContainsLong(new LongRange(0),0,true);
        assertContainsLong(new LongRange(-1,1),-2,false);
        assertContainsLong(new LongRange(-1,1),-0,true);
        assertContainsLong(new LongRange(-1,1),0,true);
        assertContainsLong(new LongRange(-1,1),2,false);
    }
    
    private static void assertContainsLong(LongRange range1, Long aNumber, Boolean expected){
        Boolean actual = range1.contains(aNumber);
        System.assert(actual==expected, 'LongRange(' + range1.toAString() 
            + ').contains(' + aNumber + ') returned ' + actual);
    }

    private static testmethod void testContainsRangeLong(){
        assertContainsRange(new LongRange(0),new LongRange(0),true);
        assertContainsRange(new LongRange(0,1),new LongRange(0,1),true);
        assertContainsRange(new LongRange(1,2),new LongRange(4,5),false);
        assertContainsRange(new LongRange(1,2),new LongRange(2,5),false);
        assertContainsRange(new LongRange(1,2),new LongRange(1,2),true);
        assertContainsRange(new LongRange(1,2),new LongRange(2,2),true);
    }
    
    private static void assertContainsRange(LongRange range1, LongRange range2, Boolean expected){
        Boolean actual = range1.contains(range2);
        System.assert(actual==expected, 'LongRange(' + range1.toAString() 
            + ').contains(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testOverlapsLong(){
        assertOverlapsLong(new LongRange(0),new LongRange(0),true);
        assertOverlapsLong(new LongRange(-1,1),new LongRange(0,1),true);
        assertOverlapsLong(new LongRange(-1,1),new LongRange(2),false);
        assertOverlapsLong(new LongRange(-1,1),new LongRange(0,1),true);
        assertOverlapsLong(new LongRange(-1,1),new LongRange(-1,-0),true);
        assertOverlapsLong(new LongRange(-1,1),new LongRange(-2),false);
    }
    
    private static void assertOverlapsLong(LongRange range1, LongRange range2, Boolean expected){
        Boolean actual = range1.overlaps(range2);
        System.assert(actual==expected, 'LongRange(' + range1.toAString() 
            + ').overlaps(' + (range2==null ? '' : range2.toAString()) + ') returned ' + actual);
    }

    private static testmethod void testMinLong(){
        assertMinLong(new LongRange(0),0);
        assertMinLong(new LongRange(-1,1),-1);
        assertMinLong(new LongRange(1,-1),-1);
    }
    
    private static void assertMinLong(LongRange range1, Long expected){
        Long actual = range1.min();
        System.assert(actual==expected, 'LongRange(' + range1.toAString() 
            + ').getMinimum() returned ' + actual);
    }

    private static testmethod void testMaxLong(){
        assertMaxLong(new LongRange(0),0);
        assertMaxLong(new LongRange(-1,1),1);
        assertMaxLong(new LongRange(1,-1),1);
    }
    
    private static void assertMaxLong(LongRange range1, Long expected){
        Long actual = range1.max();
        System.assert(actual==expected, 'LongRange(' + range1.toAString() 
            + ').getMaximum() returned ' + actual);
    }
    
    private static testmethod void testNullsConstructor1Long(){
        Boolean exceptionCaught = false;
        try{ new LongRange(null); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new LongRange(null)\' did not throw IllegalArgumentException');
    }
    
    private static testmethod void testNullsConstructor2Long(){
        Boolean exceptionCaught = false;
        try{ new LongRange(null,null); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new LongRange(null,null)\' did not throw IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new LongRange(null,0); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new LongRange(null,0)\' did not throw IllegalArgumentException');
        
        exceptionCaught = false;
        try{ new LongRange(0,null); }catch(IllegalArgumentException e){ exceptionCaught = true; }
        System.assert(exceptionCaught,'Call to \'new LongRange(0,null)\' did not throw IllegalArgumentException');
    }

    private static testmethod void testNot1(){
        System.assertEquals(
            '(NOT name = \'acme\')',
            new NotCondition()
                .add(new FieldCondition('name ',Operator.EQUALS,'acme'))
                .toSoql()
        );
    }



 private static testmethod void testMaxIntegerValue(){
        System.assert(NumberUtils.MAX_INTEGER == 2147483647);
    }
    private static testmethod void testlgerValue(){
        System.assert(NumberUtils.MIN_INTEGER == -2147483647);
    }
    
    private static testmethod void testParseIntBadRadix(){
        //test: global static Integer parseInt(String str, Integer radix){
        Boolean exceptionCaught = false;
        try{
            NumberUtils.parseInt('01',1);    
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.parseInt(\'01\',1) did not throw IllegalArgumentException'); 
        exceptionCaught = false;
        try{
            NumberUtils.parseInt('01',37);    
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.parseInt(\'01\',37) did not throw IllegalArgumentException'); 
    }
    
    private static testmethod void testParseIntEmptyNumber(){
        //test: global static Integer parseInt(String str, Integer radix){
        Boolean exceptionCaught = false;
        try{
            NumberUtils.parseInt(null,2);    
        }catch(NumberFormatException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.parseInt(null,2) did not throw NumberFormatException'); 
        exceptionCaught = false;
        try{
            NumberUtils.parseInt('  ',2);    
        }catch(NumberFormatException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.parseInt(\'  \',2) did not throw NumberFormatException'); 
    }
    
    private static testmethod void testParseIntInvalidNumber(){
        //test: global static Integer parseInt(String str, Integer radix){
        for(Integer i = 2; i < 37; i++){
            assertParseIntNumberFormatException(
                '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ$'.substring(0,i+1)
                ,i);
        }        
    }

    private static void assertParseIntNumberFormatException(String str, Integer radix){
        Boolean exceptionCaught = false;
        try{
            NumberUtils.parseInt(str,radix);    
        }catch(NumberFormatException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.parseInt(\'' + str + '\',' + radix + ') did not throw NumberFormatException'); 
    }
    
    private static testmethod void testParseIntBase2(){
        //test: global static Integer parseInt(String str, Integer radix){
        assertParseInt('0',2,0);
        assertParseInt('00',2,0);
        assertParseInt('1',2,1);
        assertParseInt('10',2,2);
        assertParseInt('11',2,3);
        assertParseInt('100',2,4);
    }
    
    private static testmethod void testParseIntBase10(){
        //test: global static Integer parseInt(String str, Integer radix){
        assertParseInt('0',10,0);
        assertParseInt('-0',10,0);
        assertParseInt('473',10,473);
    }
    
    private static testmethod void testParseIntOtherBases(){
        //test: global static Integer parseInt(String str, Integer radix){
        assertParseInt('1100110',2,102);
        assertParseInt('-FF',16,-255);
        assertParseInt('12',8,10);
        assertParseInt('az',36,395);
     }
    
    private static void assertParseInt(String str, Integer radix, Integer expected){
        Integer actual = NumberUtils.parseInt(str,radix);
        System.assert(actual==expected, 'NumberUtils.parseInt(\'' + str + '\',' + radix + ') returned ' 
            + actual + '; expected ' + expected + '');
    }
    
    private static testmethod void testIntegerToBinary(){
        //test: global static String toBinaryString(Integer i){
        assertIntegerToBinary(-2147483647,'-1111111111111111111111111111111');
        assertIntegerToBinary(-2147483646,'-1111111111111111111111111111110');
        assertIntegerToBinary(-4,'-100');
        assertIntegerToBinary(-3,'-11');
        assertIntegerToBinary(-2,'-10');
        assertIntegerToBinary(-1,'-1');
        assertIntegerToBinary(0,'0');
        assertIntegerToBinary(1,'1');
        assertIntegerToBinary(2,'10');
        assertIntegerToBinary(3,'11');
        assertIntegerToBinary(4,'100');
        assertIntegerToBinary(2147483646,'1111111111111111111111111111110');
        assertIntegerToBinary(2147483647,'1111111111111111111111111111111');
         
    }
    
    private static void assertIntegerToBinary(Integer i, String expected){
        String actual = NumberUtils.toBinaryString(i);
        System.assert(actual==expected, 'NumberUtils.toBinary(' + i + ') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testIntegerToOctal(){
        //test: global static String toOctalString(Integer i){
        assertIntegerToOctal(-2147483647,'-17777777777');
        assertIntegerToOctal(-2147483646,'-17777777776');
        assertIntegerToOctal(-9,'-11');
        assertIntegerToOctal(-8,'-10');
        assertIntegerToOctal(-7,'-7');
        assertIntegerToOctal(-6,'-6');
        assertIntegerToOctal(-5,'-5');
        assertIntegerToOctal(-4,'-4');
        assertIntegerToOctal(-3,'-3');
        assertIntegerToOctal(-2,'-2');
        assertIntegerToOctal(-1,'-1');
        assertIntegerToOctal(0,'0');
        assertIntegerToOctal(1,'1');
        assertIntegerToOctal(2,'2');
        assertIntegerToOctal(3,'3');
        assertIntegerToOctal(4,'4');
        assertIntegerToOctal(5,'5');
        assertIntegerToOctal(6,'6');
        assertIntegerToOctal(7,'7');
        assertIntegerToOctal(8,'10');
        assertIntegerToOctal(9,'11');
        assertIntegerToOctal(2147483646,'17777777776');
        assertIntegerToOctal(2147483647,'17777777777');
         
    }
    
    private static void assertIntegerToOctal(Integer i, String expected){
        String actual = NumberUtils.toOctalString(i);
        System.assert(actual==expected, 'NumberUtils.toOctal(' + i + ') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testIntegerToHex(){
        //test: global static String toHexString(Integer i){
        assertIntegerToHex(-2147483647,'-7FFFFFFF');
        assertIntegerToHex(-2147483646,'-7FFFFFFE');
        assertIntegerToHex(-19,'-13');
        assertIntegerToHex(-18,'-12');
        assertIntegerToHex(-17,'-11');
        assertIntegerToHex(-16,'-10');
        assertIntegerToHex(-15,'-F');
        assertIntegerToHex(-14,'-E');
        assertIntegerToHex(-13,'-D');
        assertIntegerToHex(-12,'-C');
        assertIntegerToHex(-11,'-B');
        assertIntegerToHex(-10,'-A');
        assertIntegerToHex(-9,'-9');
        assertIntegerToHex(-8,'-8');
        assertIntegerToHex(-7,'-7');
        assertIntegerToHex(-6,'-6');
        assertIntegerToHex(-5,'-5');
        assertIntegerToHex(-4,'-4');
        assertIntegerToHex(-3,'-3');
        assertIntegerToHex(-2,'-2');
        assertIntegerToHex(-1,'-1');
        assertIntegerToHex(0,'0');
        assertIntegerToHex(1,'1');
        assertIntegerToHex(2,'2');
        assertIntegerToHex(3,'3');
        assertIntegerToHex(4,'4');
        assertIntegerToHex(5,'5');
        assertIntegerToHex(6,'6');
        assertIntegerToHex(7,'7');
        assertIntegerToHex(8,'8');
        assertIntegerToHex(9,'9');
        assertIntegerToHex(10,'A');
        assertIntegerToHex(11,'B');
        assertIntegerToHex(12,'C');
        assertIntegerToHex(13,'D');
        assertIntegerToHex(14,'E');
        assertIntegerToHex(15,'F');
        assertIntegerToHex(16,'10');
        assertIntegerToHex(17,'11');
        assertIntegerToHex(2147483646,'7FFFFFFE');
        assertIntegerToHex(2147483647,'7FFFFFFF');
         
    }
    
    private static void assertIntegerToHex(Integer i, String expected){
        String actual = NumberUtils.toHexString(i);
        System.assert(actual==expected, 'NumberUtils.toHex(' + i + ') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
 
    private static testmethod void testIntegerToStringNullInput(){
        //test: global static String toString(Integer i, Integer radix){
        Integer i = null;
        System.assertEquals(null,NumberUtils.toString(i,2));
    }    
    
    private static testmethod void testIntegerToStringBadRadix(){
        //test: global static String toString(Integer i, Integer radix){
        Boolean exceptionCaught = false;
        try{
            NumberUtils.toString(0,1);    
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.toString(null,1) did not throw IllegalArgumentException'); 
        exceptionCaught = false;
        try{
            NumberUtils.toString(0,37);    
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.toString(null,1) did not throw IllegalArgumentException'); 
    }
    
    private static testmethod void testLongToBinary(){
        //test: global static String toBinaryString(Long i){
        /*
        //can't do these tests b/c hitting System.Exception: Maximum stack depth reached: 66 
        assertLongToBinary(-9223372036854775807L,'-111111111111111111111111111111111111111111111111111111111111111');
        assertLongToBinary(-9223372036854775806L,'-111111111111111111111111111111111111111111111111111111111111110');
        */
        assertLongToBinary(-4L,'-100');
        assertLongToBinary(-3L,'-11');
        assertLongToBinary(-2L,'-10');
        assertLongToBinary(-1L,'-1');
        assertLongToBinary(0L,'0');
        assertLongToBinary(1L,'1');
        assertLongToBinary(2L,'10');
        assertLongToBinary(3L,'11');
        assertLongToBinary(4L,'100');
        /*
        //can't do these tests b/c hitting System.Exception: Maximum stack depth reached: 66 
        assertLongToBinary(9223372036854775806L,'111111111111111111111111111111111111111111111111111111111111110');
        assertLongToBinary(9223372036854775807L,'111111111111111111111111111111111111111111111111111111111111111');
        */
    }
    
    private static void assertLongToBinary(Long l, String expected){
        String actual = NumberUtils.toBinaryString(l);
        System.assert(actual==expected, 'NumberUtils.toBinary(' + l + ') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
    
    private static testmethod void testLongToOctal(){
        //test: global static String toOctalString(Long l){
        assertLongToOctal(-9223372036854775807L,'-777777777777777777777');
        assertLongToOctal(-9223372036854775806L,'-777777777777777777776');
        assertLongToOctal(-9L,'-11');
        assertLongToOctal(-8L,'-10');
        assertLongToOctal(-7L,'-7');
        assertLongToOctal(-6L,'-6');
        assertLongToOctal(-5L,'-5');
        assertLongToOctal(-4L,'-4');
        assertLongToOctal(-3L,'-3');
        assertLongToOctal(-2L,'-2');
        assertLongToOctal(-1L,'-1');
        assertLongToOctal(0L,'0');
        assertLongToOctal(1L,'1');
        assertLongToOctal(2L,'2');
        assertLongToOctal(3L,'3');
        assertLongToOctal(4L,'4');
        assertLongToOctal(5L,'5');
        assertLongToOctal(6L,'6');
        assertLongToOctal(7L,'7');
        assertLongToOctal(8L,'10');
        assertLongToOctal(9L,'11');
        assertLongToOctal(9223372036854775806L,'777777777777777777776');
        assertLongToOctal(9223372036854775807L,'777777777777777777777');
         
    }
    
    private static void assertLongToOctal(Long l, String expected){
        String actual = NumberUtils.toOctalString(l);
        System.assert(actual==expected, 'NumberUtils.toOctal(' + l + ') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }

    private static testmethod void testLongToHex(){
        //test: global static String toHexString(Long l){
        assertLongToHex(-9223372036854775807L,'-7FFFFFFFFFFFFFFF');
        assertLongToHex(-9223372036854775806L,'-7FFFFFFFFFFFFFFE');
        assertLongToHex(-19L,'-13');
        assertLongToHex(-18L,'-12');
        assertLongToHex(-17L,'-11');
        assertLongToHex(-16L,'-10');
        assertLongToHex(-15L,'-F');
        assertLongToHex(-14L,'-E');
        assertLongToHex(-13L,'-D');
        assertLongToHex(-12L,'-C');
        assertLongToHex(-11L,'-B');
        assertLongToHex(-10L,'-A');
        assertLongToHex(-9L,'-9');
        assertLongToHex(-8L,'-8');
        assertLongToHex(-7L,'-7');
        assertLongToHex(-6L,'-6');
        assertLongToHex(-5L,'-5');
        assertLongToHex(-4L,'-4');
        assertLongToHex(-3L,'-3');
        assertLongToHex(-2L,'-2');
        assertLongToHex(-1L,'-1');
        assertLongToHex(0L,'0');
        assertLongToHex(1L,'1');
        assertLongToHex(2L,'2');
        assertLongToHex(3L,'3');
        assertLongToHex(4L,'4');
        assertLongToHex(5L,'5');
        assertLongToHex(6L,'6');
        assertLongToHex(7L,'7');
        assertLongToHex(8L,'8');
        assertLongToHex(9L,'9');
        assertLongToHex(10L,'A');
        assertLongToHex(11L,'B');
        assertLongToHex(12L,'C');
        assertLongToHex(13L,'D');
        assertLongToHex(14L,'E');
        assertLongToHex(15L,'F');
        assertLongToHex(16L,'10');
        assertLongToHex(17L,'11');
        assertLongToHex(9223372036854775806L,'7FFFFFFFFFFFFFFE');
        assertLongToHex(9223372036854775807L,'7FFFFFFFFFFFFFFF');
         
    }
    
    private static void assertLongToHex(Long l, String expected){
        String actual = NumberUtils.toHexString(l);
        System.assert(actual==expected, 'NumberUtils.toHex(' + l + ') returned \'' 
            + actual + '\'; expected \'' + expected + '\'');
    }
      
    private static testmethod void testLongToStringNullInput(){
        //test: global static String toString(Long l, Long radix){
        Long l = null;
        System.assertEquals(null,NumberUtils.toString(l,2));
    }    
    
    private static testmethod void testLongToStringBadRadix(){
        //test: global static String toString(Long l, Integer radix){
        Boolean exceptionCaught = false;
        try{
            NumberUtils.toString(0L,1);    
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.toString(null,1) did not throw IllegalArgumentException'); 
        exceptionCaught = false;
        try{
            NumberUtils.toString(0L,37);    
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught,'NumberUtils.toString(null,1) did not throw IllegalArgumentException'); 
    }
    
    
    
    
    private static testmethod void testNullFieldName(){
        assertIllegalArgumentThrown(null);
    }

    private static testmethod void testBlankFieldName(){
        assertIllegalArgumentThrown(' ');
    }

    private static void assertIllegalArgumentThrown(final String name){
        Boolean exceptionCaught = false;
        try{
            new OrderBy(name);
        }catch(IllegalArgumentException e){
            exceptionCaught = true;
        }
        System.assert(exceptionCaught == true,'IllegalArgumentException not thrown');
    }

    private static testmethod void testNameOnly(){
        final OrderBy orderBy = new OrderBy('name');
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name',orderBy.toSoql());
    }

    private static testmethod void testAscendingNullsLast(){
        OrderBy orderBy = new OrderBy('name').ascending().nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS LAST',orderBy.toSoql());

        orderBy = new OrderBy('name').nullsLast().ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS LAST',orderBy.toSoql());
    }

    private static testmethod void testDescendingNullsFirst(){
        OrderBy orderBy = new OrderBy('name').descending().nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS FIRST',orderBy.toSoql());

        orderBy = new OrderBy('name').nullsFirst().descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testAscendingNullsFirst(){
        OrderBy orderBy = new OrderBy('name').ascending().nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS FIRST',orderBy.toSoql());

        orderBy = new OrderBy('name').nullsFirst().ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals('name ASC NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testDescendingNullsLast(){
        OrderBy orderBy = new OrderBy('name').descending().nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS LAST',orderBy.toSoql());

        orderBy = new OrderBy('name').nullsLast().descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name DESC NULLS LAST',orderBy.toSoql());
    }


    private static testmethod void testAscending(){
        OrderBy orderBy = new OrderBy('name').ascending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals('name ASC',orderBy.toSoql());
    }

    private static testmethod void testDescending(){
        final OrderBy orderBy = new OrderBy('name').descending();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.ascending);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name DESC',orderBy.toSoql());
    }

    private static testmethod void testNullsFirst(){
        final OrderBy orderBy = new OrderBy('name').nullsFirst();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(true,orderBy.nullsFirst);
        System.assertEquals(false,orderBy.nullsLast);
        System.assertEquals('name NULLS FIRST',orderBy.toSoql());
    }

    private static testmethod void testNullsLast(){
        final OrderBy orderBy = new OrderBy('name').nullsLast();
        System.assertNotEquals(null,orderBy);
        System.assertEquals(true,orderBy.ascending);
        System.assertEquals(false,orderBy.descending);
        System.assertEquals(false,orderBy.nullsFirst);
        System.assertEquals(true,orderBy.nullsLast);
        System.assertEquals('name NULLS LAST',orderBy.toSoql());
    }




    private static testmethod void testNulls(){
        String aNull = null;
        Object aNullO = aNull;
        Object xyz = 'xyz';
        System.assertEquals(-1,(new PrimitiveComparator()).compare(aNullO,xyz));
        System.assertEquals(0,(new PrimitiveComparator()).compare(aNullO,aNullO));
        System.assertEquals(1,(new PrimitiveComparator()).compare(xyz,aNullO));
    }
    
    private static testmethod void testBlob(){
        Object b1 = Blob.valueOf('123');
        Object b2 = Blob.valueOf('abc');
        Boolean exceptionThrown = false;
        try{
            (new PrimitiveComparator()).compare(b1,b2);
        }catch(IllegalArgumentException e){
            exceptionThrown = true;
        }
        System.assert(exceptionThrown);
    }

    private static testmethod void testBoolean(){
        assertCompareBoolean(false,true,-1);
        assertCompareBoolean(true,true,0);
        assertCompareBoolean(false,false,0);
        assertCompareBoolean(true,false,1);
    }
    private static void assertCompareBoolean(Object b1, Object b2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(b1,b2));}

    private static testmethod void testDate(){
        assertCompareDate(date.newinstance(1980, 2, 17),date.newinstance(1981, 2, 17),-1);
        assertCompareDate(date.newinstance(1981, 2, 17),date.newinstance(1981, 2, 17),0);
        assertCompareDate(date.newinstance(1981, 2, 17),date.newinstance(1980, 2, 17),1);
    }
    private static void assertCompareDate(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testDatetime(){ 
        Object d1 = datetime.newInstance(2008, 12, 1, 12, 30, 1);
        Object d2 = datetime.newInstance(2008, 12, 1, 12, 30, 2);
        assertCompareDatetime(d1,d2,-1);
        assertCompareDatetime(d1,d1,0);
        assertCompareDatetime(d2,d1,1);
    }
    private static void assertCompareDatetime(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testDecimal(){ 
        Decimal d1 = 123.123;
        Decimal d2 = 125.125;
        assertCompareDecimal(d1,d2,-1);
        assertCompareDecimal(d1,d1,0);
        assertCompareDecimal(d2,d1,1);
    }
    private static void assertCompareDecimal(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testDouble(){ 
        Double d1 = 123.123;
        Double d2 = 125.125;
        assertCompareDouble(d1,d2,-1);
        assertCompareDouble(d1,d1,0);
        assertCompareDouble(d2,d1,1);
    }
    private static void assertCompareDouble(Object d1, Object d2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(d1,d2));}
    
    private static testmethod void testInteger(){ 
        Integer i1 = -10;
        Integer i2 = 15;
        assertCompare(i1,i2,-1);
        assertCompare(i1,i1,0);
        assertCompare(i2,i1,1);
    }
    private static void assertCompare(Object i1, Object i2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(i1,i2));}
    
    private static testmethod void testLong(){ 
        Long i1 = -10;
        Long i2 = 15;
        assertCompareLong(i1,i2,-1);
        assertCompareLong(i1,i1,0);
        assertCompareLong(i2,i1,1);
    }
    private static void assertCompareLong(Object l1, Object l2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(l1,l2));}
    
    private static testmethod void testTime(){
        Time t1 = Time.newInstance(18, 30, 2, 20);
        Time t2 = Time.newInstance(18, 30, 2, 21);
        assertCompareTime(t1,t2,-1);
        assertCompareTime(t2,t2,0);
        assertCompareTime(t2,t1,1);
    }
    private static void assertCompareTime(Object t1, Object t2, Integer expected){ 
        System.assertEquals(expected,(new PrimitiveComparator()).compare(t1,t2));
    }
    
    private static testmethod void testString(){ 
        String s1 = 'abc';
        String s2 = 'def';
        assertCompareString(s1,s2,-1);
        assertCompareString(s1,s1,0);
        assertCompareString(s2,s1,1);
    }
    private static void assertCompareString(Object s1, Object s2, Integer expected){ System.assertEquals(expected,(new PrimitiveComparator()).compare(s1,s2));}







}