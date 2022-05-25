public with sharing class ContactVFController {
public List<RecentlyViewed> RecentList {get{

List<RecentlyViewed> r = [SELECT Id, Name, LastViewedDate FROM RecentlyViewed WHERE LastViewedDate <> NULL AND Type IN ('Contact')
ORDER BY LastViewedDate DESC LIMIT 10];

return r;

}
}
public ContactVFController(apexpages.standardController Controller){}

}