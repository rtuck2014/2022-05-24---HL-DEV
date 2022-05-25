@isTest
private class Test_HL_CompanyFinancialsTrg {
    @testSetup
    static void data(){
        List<Account> accs = new List<Account>();
        	accs.add(new Account(Name = 'test0')); //zero existing cfs
        	accs.add(new Account(Name = 'test1')); //one existing cfs
        	accs.add(new Account(Name = 'test2')); //two existing cfs
        insert accs;
        
        List<Company_Financial__c> cfs = new List<Company_Financial__c>();
        	cfs.add(new Company_Financial__c (Company__c = accs[1].Id, As_Of_Date__c = Date.Today(), Year__c = '2009', EBITDA_MM__c = 5, Revenue_MM__c = 6));
            cfs.add(new Company_Financial__c (Company__c = accs[2].Id, As_Of_Date__c = Date.Today(), Year__c = '2009', EBITDA_MM__c = 5, Revenue_MM__c = 6));
        	cfs.add(new Company_Financial__c (Company__c = accs[2].Id, As_Of_Date__c = Date.Today(), Year__c = '2010', EBITDA_MM__c = 8, Revenue_MM__c = 9));
        insert cfs;
        
        List<Account> accsUpdate = new List<Account>();
        	accsUpdate.add(new Account(Id =accs[1].Id, Most_Recent_Company_Financial__c = cfs[0].Id));
        	accsUpdate.add(new Account(Id =accs[2].Id, Most_Recent_Company_Financial__c = cfs[2].Id));
        update accsUpdate;
    }
    
    @isTest private static void onlyCompFin(){
        Account a = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test0'];
        test.startTest();
        	Company_Financial__c cf = new Company_Financial__c (Company__c = a.Id, As_Of_Date__c = Date.Today(), Year__c = '2011');
            insert cf;
        test.stopTest();
        
        Account a1 = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test0'];
    	System.assertEquals(a1.Most_Recent_Company_Financial__c, cf.Id);
    }
    
    @isTest private static void newerCompFin(){
        Account a = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test1'];
        test.startTest();
        	Company_Financial__c cf = new Company_Financial__c (Company__c = a.Id, As_Of_Date__c = Date.Today(), Year__c = '2011');
            insert cf;
        test.stopTest();
        
        Account a1 = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test1'];        
    	System.assertEquals(a1.Most_Recent_Company_Financial__c, cf.Id);
    }

    @isTest private static void olderCompFin(){
        Account a = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test1'];
        Company_Financial__c existingCF = [SELECT Id FROM Company_Financial__c WHERE Company__c =: a.Id AND Year__c = '2009'];
        test.startTest();
        	Company_Financial__c cf = new Company_Financial__c (Company__c = a.Id, As_Of_Date__c = Date.Today(), Year__c = '2005');
            insert cf;
        test.stopTest();
        
        Account a1 = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test1'];        
    	System.assertEquals(a1.Most_Recent_Company_Financial__c, existingCF.Id);
    }
    
    @isTest private static void delOnlyCompFin(){
		Account a = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test1'];
        Company_Financial__c cf = [SELECT Id FROM Company_Financial__c WHERE Company__c =: a.Id];
        test.startTest();
			delete cf;
        test.stopTest();
        
        Account a1 = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test1'];        
    	System.assertEquals(a1.Most_Recent_Company_Financial__c, null);
    }
    @isTest private static void delCompFin(){
		Account a = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test2'];
        Company_Financial__c cf = [SELECT Id FROM Company_Financial__c WHERE Company__c =: a.Id AND Year__c = '2009'];
        Company_Financial__c cf2 = [SELECT Id FROM Company_Financial__c WHERE Company__c =: a.Id AND Year__c = '2010'];        
        test.startTest();
			delete cf2;
        test.stopTest();
        
        Account a1 = [SELECT Id, Most_Recent_Company_Financial__c FROM Account WHERE Name = 'test2'];        
    	System.assertEquals(a1.Most_Recent_Company_Financial__c, cf.Id);
    }
}