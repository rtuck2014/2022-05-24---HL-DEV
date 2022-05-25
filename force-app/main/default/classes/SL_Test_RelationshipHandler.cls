/**  
* \arg ClassName        : SL_Test_RelationshipHandler
* \arg JIRATicket       : HL-108
* \arg CreatedOn        : 25/FEB/2015
* \arg LastModifiedOn   : 27/FEB/2015
* \arg CreatededBy      : Lodhi
* \arg ModifiedBy       : -
* \arg Description      : Test class for contact trigger handler
*/
@isTest
private class SL_Test_RelationshipHandler 
{
    static List<Contact> lstHLContact;
    static List<User> lstUser;
    static List<Relationship__c> lstRelationship;
    
    private static void createData() 
    {
        Profile objProfile = [SELECT Id,
                                     Name 
                                FROM Profile
                               WHERE Name = 'System Administrator'];
        
        Integer i = 0;
        lstUser = new List<User>();
        For(User objUser : SL_TestSetupUtils.CreateUser('User',10))
        {
            objUser.Lastname = 'User';
            objUser.Email = 'tuser@yahoo.in';
            objUser.Username = i+'testinguser@hl240.com';
            objUser.ProfileId = objProfile.Id;
            objUser.Alias = 'tuser';
            objUser.TimeZoneSidKey = 'GMT';
            objUser.LocaleSidKey = 'en_US';
            objUser.EmailEncodingKey = 'ISO-8859-1';
            objUser.LanguageLocaleKey = 'en_US';
            objUser.Has_Delegates__c = false;
            lstUser.add(objUser);
            i++;
        }
        insert lstUser;
        
        i = 0;
        List<Delegate_Public_Group__c> lstDPG = new List<Delegate_Public_Group__c>();
        For(Delegate_Public_Group__c objDPG : SL_TestSetupUtils.createDPG('Delegate_Public_Group__c', 2))
        {
            objDPG.Banker__c = lstUser[i].Id;
            lstDPG.add(objDPG);
            i++;
        }
        insert lstDPG;
        
        List<Account> lstAccount = SL_TestSetupUtils.CreateAccount('Account' , 1);
        insert lstAccount;
        
        i = 0;
        lstHLContact = new List<Contact>();
        for(Contact objContact : SL_TestSetupUtils.CreateContact('Contact', 10, SL_TestSetupUtils.ContactType.HOULIHAN_EMPLOYEE))
        {
            objContact.AccountId = lstAccount[0].Id;
            objContact.User__c = lstUser[i].Id;
            lstHLContact.add(objContact); 
            i++;
        }
        insert lstHLContact;
        
        i = 0;
        lstRelationship = new List<Relationship__c>();
        for(Relationship__c objRelationship : SL_TestSetupUtils.CreateRelationship('Relationship__c', 5))
        {
            lstRelationship.add(new Relationship__c(HL_Contact__c = lstHLContact[i].Id, Type__c = 'Business'));
            i++;
        }
        insert lstRelationship;  
    }           
    
    private static testMethod void testInsertCase() 
    {
        createData();
        System.assertEquals([SELECT Id FROM Relationship__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 2);
        System.assertEquals([SELECT OwnerId FROM Relationship__c LIMIT 1].OwnerId, lstUser[0].Id);
        lstRelationship[0].HL_Contact__c = lstHLContact[6].Id;
        lstRelationship[1].HL_Contact__c = lstHLContact[7].Id;
        User u = new User(Id = UserInfo.getUserId());
        System.runAs (u) 
        {
            update lstRelationship[0]; 
            update lstRelationship[1]; 
        }
        System.assertEquals([SELECT Id FROM Relationship__Share WHERE RowCause='Manual' AND AccessLevel ='Edit'].size(), 0);
        System.assertEquals([SELECT OwnerId FROM Relationship__c WHERE Id =: lstRelationship[0].Id LIMIT 1].OwnerId, lstHLContact[6].User__c);
    }
}