@isTest
public class HLEngContactCounterPartyControllerTest {

    @isTest
    public static void searchContacts(){
        HLEngContactCounterPartyController.searchContacts(null,'searchTerm','Name'); 
        HLEngContactCounterPartyController.searchContacts(null,'searchTerm','Company'); 
        HLEngContactCounterPartyController.searchContacts(null,'searchTerm','Industry/Product Focus'); 
     }
    
    @isTest
    public static void filterclass(){
        
		HLEngContactCounterPartyController.filterclass filterData   = new HLEngContactCounterPartyController.filterclass();
        filterData.lastName = 'Test';
        filterData.firstName = 'Test';
        filterData.title = 'Test';
        filterData.accountName = 'Test';
        filterData.department = 'Test';
        filterData.industryFocus = 'Test';
        
        HLEngContactCounterPartyController.filterData(null,JSON.serialize(filterData),'searchTerm','Name',new List<Contact>());
        HLEngContactCounterPartyController.filterData(null,JSON.serialize(filterData),'searchTerm','Company',new List<Contact>());
        HLEngContactCounterPartyController.filterData(null,JSON.serialize(filterData),'searchTerm','Industry/Product Focus',new List<Contact>());
     }
    
    @isTest
    public static void insertContacts(){
        HLEngContactCounterPartyController.saveEngagementContacts(new List<String>(),null);
    }
    
}