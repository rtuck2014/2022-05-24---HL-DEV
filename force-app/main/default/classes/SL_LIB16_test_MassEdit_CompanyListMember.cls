@isTest
private class SL_LIB16_test_MassEdit_CompanyListMember
{
    public static List<Account> accounts = new List<Account>();
    /*public static List<Project__c> projects = new List<Project__c>();
public static List<Call_Log__c> calLogs = new List<Call_Log__c>();*/
    public static List<Company_List__c> companyLists = new List<Company_List__c>();
    public static List<Company_List_Member__c> companyListMembers = new List<Company_List_Member__c>();
    
    static void createData(){
        //Modified as part of State/Country Picklist - changed country and state values
        accounts.add(new Account(name='test1', BillingCountry = 'United States', BillingState = 'California'));
        insert accounts;
        
        companyLists.add(new Company_List__c(Name = 'Test company list 1'));
        insert companyLists;
        
    }
    
    public static testMethod void coverage_SL_LIB16_MassEdit_CompanyListMember()
    {
        SL_LIB16_install controller_pre = new SL_LIB16_install();
        controller_pre.runChecker();
        SL_View__c objView = new SL_View__c();
        
        createData();
        test.startTest();
        
        //  try {
        
        
        SL_Mass_Implementation__c DefaultSettings = null;
        for(SL_Mass_Implementation__c item:[Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, 
                                            parentObjectName__c, Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Name, 
                                            Id, Get_Element_from_List_Tab__c From SL_Mass_Implementation__c where Name='Company List' limit 1])
        {
            DefaultSettings = item;
        }
        
        SL_Mass_Implementation__c SL_ME1;
        if(DefaultSettings == null)
        {
            SL_ME1 = new SL_Mass_Implementation__c();
            SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
            SL_ME1.targetObjectName__c = 'Company_List_Member__c';
            SL_ME1.parentObjectName__c = 'Company_List__c';
            SL_ME1.Name = 'CompanyList';
            try{ insert SL_ME1;}
            catch(Exception e){ }
        }
        else 
        {
            
            
            objView.RowsCount__c = 50;
            objView.Name = 'All Capital Markets Stages';
            objView.Columns__c = 'View Record,Company,Status,Type,Tier,Declined / Passed,Initial Contact,Sent Teaser,Sent CA,Markup Sent,Markup Received,Executed CA,Received/Sent Book,Invited to Dataroom,Sent QoE NRL,Executed QoE NRL,Sent QoE,Sent Legal NRL,Executed Legal NRL,Sent Legal Report,Sent Other NRL,Executed Other NRL,Sent Other Report,Proposal / Indication,Met With Mgmt,Letter of Intent,Signed Term Sheet,Engagement Counterparty Comment';
            objView.Advanced_Filter__c = '((1) OR 2) OR 3';
            
            objView.Implementation__c = DefaultSettings.Id;
            objView.Implementation_Type__c = 'Target';
            objView.IsDefault__c = False;
            objView.Visibility__c = 'Public';
            objView.User__c = UserInfo.getUserId();
            insert objView;
            
            SL_View_Filter__c objViewFilter = new SL_View_Filter__c();
            objViewFilter.Value__c = 'FIG - Sellside, Sellside';
            objViewFilter.Type__c = 'REFERENCE';
            objViewFilter.SL_View__c = objView.Id;
            objViewFilter.Operator__c = 'includes';
            objViewFilter.Field__c = 'Company__r.ID';
            insert objViewFilter;
            
            if(DefaultSettings!=null)
            {
                SL_ME1 = DefaultSettings;
                //SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
                //SL_ME1.targetObjectName__c = 'Company_List_Member__c';
                //SL_ME1.parentObjectName__c = 'Company_List__c';
                //SL_ME1.Name = 'CompanyList';
                
                //update SL_ME1;
            }
            
        }
        
        
        
        PageReference pageRef = Page.SL_LIB16_MassEdit_CompanyListMember; 
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('clId',companyLists.get(0).id);
        ApexPages.currentPage().getParameters().put('target','Main');
        ApexPages.currentPage().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
        //ApexPages.currentPage().getParameters().put('mt','1');
        
        SL_LIB16_MassEdit_CompanyListMember controller = new SL_LIB16_MassEdit_CompanyListMember();
        List<SL_View__c> Obj1 = [SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c
                                 FROM SL_View__c];
        
        
        System.debug('Testing   ' + DefaultSettings.Id);                    
        
        
        system.debug('Testing' + Obj1);   
        system.debug('SL_View    ' + objView.Id);             
        
        List<SL_View_Filter__c> filters = controller.filters;
        controller.strColumnsAndFiltersTemplate = 'All';
        
        
        SL_LIB16_MassEdit.MemberContainer mc = new SL_LIB16_MassEdit.MemberContainer();
        SL_LIB16_MassEdit_CompanyListMember.MemberContainerCasted meclm = 
            new SL_LIB16_MassEdit_CompanyListMember.MemberContainerCasted(mc);
        meclm.getCastedSObject();
        
        //Get the Id from the parameter passed to the page.
        String currentPageId=ApexPages.currentPage().getParameters().get('clId');
        
        //Convert the String value to Id.
        Id currentRecordId=Id.valueOf(currentPageId);
        
        //Get the Object Name.
        String sObjName=currentRecordId.getSObjectType().getDescribe().getName();
        List<SObject> lst = new List<SObject>();
        //lst.add(sObjName);
        //controller.castAndSave(lst);
        system.debug('==== castAndSave() ==== >>>> '+controller.castAndSave(lst));
        system.debug('==== getNewTargetObject() ==== >>>> '+controller.getNewTargetObject());
        //controller.currMainCusSettings.
        controller.columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
        controller.columns.add(new SL_LIB16_MassEdit.ColumnInfo('NameInv','','NameInv',true,true));
        controller.columns.add(new SL_LIB16_MassEdit.ColumnInfo('NameInv','','NameInv',true));
        //controller.customSettingCount = 1;
        controller.selectedColumnsCallback = 'Name';
        controller.saveSelectedColumns();
        controller.getMassEditSettings();
        controller.hasNoError = false;
        controller.loadDefaults();
        
        controller.getCurrentUrlEncoded();
        controller.getConvertedCallLogs();
        controller.dummyFunction();
        controller.doCusSave();
        controller.doDelete();
        String dtformat = controller.dateFormat;
        
        String shortUrl = controller.shortUrl;
        controller.SetDefaultView();
        controller.loadDefaultsTarget();
        controller.getIsItems();
        controller.getTargetObjName();
        controller.getExtId();
        controller.addSingleItem();
        controller.addMultipleItems();
        controller.getIsShowReportBtn();
        controller.editBids();
        controller.runBidTracking();
        controller.getviewFilters();
        boolean ShowEditBids = controller.ShowEditBids;
        controller.runReport();
        Boolean OnEIT = controller.OnEIT;
        Boolean OnOIT = controller.OnOIT;
        
        //controller.refreshFilters();            
        SL_LIB209_ctrl_SearchBlockParams tmpVal = controller.getSearchCompParams();
        
        //controller.getShowColumn_Company();
        //controller.getShowColumn_Name();
        //controller.getShowColumn_CompanyType();
        //controller.getShowColumn_Contact();
        
        
        test.stopTest();
    }
    
    public static testMethod void coverage_SL_LIB16_MassEdit_CompanyListMember3()
    {
        SL_LIB16_install controller_pre = new SL_LIB16_install();
        controller_pre.runChecker();
        SL_View__c objView = new SL_View__c();
        
        createData();
        test.startTest();
        
        //  try {
        
        
        SL_Mass_Implementation__c DefaultSettings = null;
        for(SL_Mass_Implementation__c item:[Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, 
                                            parentObjectName__c, Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Name, 
                                            Id, Get_Element_from_List_Tab__c From SL_Mass_Implementation__c where Name='Company List' limit 1])
        {
            DefaultSettings = item;
        }
        
        SL_Mass_Implementation__c SL_ME1;
        if(DefaultSettings == null)
        {
            SL_ME1 = new SL_Mass_Implementation__c();
            SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
            SL_ME1.targetObjectName__c = 'Engagement_Counterparty__c';
            SL_ME1.parentObjectName__c = 'Company_List__c';
            SL_ME1.Name = 'CompanyList';
            try{ insert SL_ME1;}
            catch(Exception e){ }
        }
        else 
        {
            
            
            objView.RowsCount__c = 50;
            objView.Name = 'All Capital Markets Stages';
            objView.Columns__c = 'View Record,Company,Status,Type,Tier,Declined / Passed,Initial Contact,Sent Teaser,Sent CA,Markup Sent,Markup Received,Executed CA,Received/Sent Book,Invited to Dataroom,Sent QoE NRL,Executed QoE NRL,Sent QoE,Sent Legal NRL,Executed Legal NRL,Sent Legal Report,Sent Other NRL,Executed Other NRL,Sent Other Report,Proposal / Indication,Met With Mgmt,Letter of Intent,Signed Term Sheet,Engagement Counterparty Comment';
            objView.Advanced_Filter__c = '((1) OR 2) OR 3';
            
            objView.Implementation__c = DefaultSettings.Id;
            objView.Implementation_Type__c = 'Target';
            objView.IsDefault__c = False;
            objView.Visibility__c = 'Public';
            objView.User__c = UserInfo.getUserId();
            insert objView;
            
            SL_View_Filter__c objViewFilter = new SL_View_Filter__c();
            objViewFilter.Value__c = 'FIG - Sellside, Sellside';
            objViewFilter.Type__c = 'REFERENCE';
            objViewFilter.SL_View__c = objView.Id;
            objViewFilter.Operator__c = 'includes';
            objViewFilter.Field__c = 'Company__c';
            insert objViewFilter;
            
            if(DefaultSettings!=null)
            {
                SL_ME1 = DefaultSettings;
                //SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
                //SL_ME1.targetObjectName__c = 'Company_List_Member__c';
                //SL_ME1.parentObjectName__c = 'Company_List__c';
                //SL_ME1.Name = 'CompanyList';
                
                //update SL_ME1;
            }
            
        }
        
        
        
        PageReference pageRef = Page.SL_LIB16_MassEdit_CompanyListMember; 
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('clId',companyLists.get(0).id);
        ApexPages.currentPage().getParameters().put('target','Main');
        ApexPages.currentPage().getParameters().put('implId',''+controller_pre.ME_CompanyList_ObjID);
        //ApexPages.currentPage().getParameters().put('mt','1');
        
        SL_LIB16_MassEdit_CompanyListMember controller = new SL_LIB16_MassEdit_CompanyListMember();
        List<SL_View__c> Obj1 = [SELECT RowsCount__c, Name, ID, Columns__c, Advanced_Filter__c
                                 FROM SL_View__c];
        
        
        System.debug('Testing   ' + DefaultSettings.Id);                    
        
        
        system.debug('Testing' + Obj1);   
        system.debug('SL_View    ' + objView.Id);             
        
        List<SL_View_Filter__c> filters = controller.filters;
        controller.strColumnsAndFiltersTemplate = 'All';
        
        
        SL_LIB16_MassEdit.MemberContainer mc = new SL_LIB16_MassEdit.MemberContainer();
        SL_LIB16_MassEdit_CompanyListMember.MemberContainerCasted meclm = 
            new SL_LIB16_MassEdit_CompanyListMember.MemberContainerCasted(mc);
        meclm.getCastedSObject();
        
        //Get the Id from the parameter passed to the page.
String currentPageId=ApexPages.currentPage().getParameters().get('clId');

//Convert the String value to Id.
Id currentRecordId=Id.valueOf(currentPageId);

//Get the Object Name.
String sObjName=currentRecordId.getSObjectType().getDescribe().getName();
        List<SObject> lst = new List<SObject>();
        system.debug('==== castAndSave() ==== >>>> '+controller.castAndSave(lst));
        system.debug('==== getNewTargetObject() ==== >>>> '+controller.getNewTargetObject());
        //controller.getMT();
        //Convert the String value to Id.
        //Id currentRecordId=Id.valueOf(currentPageId);
        
        //Get the Object Name.
        //String sObjName=currentRecordId.getSObjectType().getDescribe().getName();
        //controller.putToSObject(sObjName,'Value__c',sObjName,'Value__c');
        controller.columns = new List<SL_LIB16_MassEdit.ColumnInfo>();
        controller.columns.add(new SL_LIB16_MassEdit.ColumnInfo('NameInv','','NameInv',true,true));
        controller.columns.add(new SL_LIB16_MassEdit.ColumnInfo('NameInv','','NameInv',true));
        //controller.customSettingCount = 1;
        controller.selectedColumnsCallback = 'Name';
        controller.saveSelectedColumns();
        controller.getMassEditSettings();
        controller.hasNoError = false;
        controller.loadDefaults();
        
        controller.getCurrentUrlEncoded();
        controller.getConvertedCallLogs();
        controller.dummyFunction();
        controller.doCusSave();
        controller.doDelete();
        String dtformat = controller.dateFormat;
        
        String shortUrl = controller.shortUrl;
        controller.SetDefaultView();
        controller.loadDefaultsTarget();
        controller.getIsItems();
        controller.getTargetObjName();
        controller.getExtId();
        controller.addSingleItem();
        controller.addMultipleItems();
        controller.getIsShowReportBtn();
        controller.editBids();
        controller.runBidTracking();
        controller.getviewFilters();
        boolean ShowEditBids = controller.ShowEditBids;
        controller.runReport();
        //controller.checkAccessbility();
        Boolean OnEIT = controller.OnEIT;
        Boolean OnOIT = controller.OnOIT;
        
        
        SL_LIB209_ctrl_SearchBlockParams tmpVal = controller.getSearchCompParams();
        
        //controller.getShowColumn_Company();
        //controller.getShowColumn_Name();
        //controller.getShowColumn_CompanyType();
        //controller.getShowColumn_Contact();
        
        
        test.stopTest();
    }
    
    /*
public static testMethod void coverage_SL_LIB16_MassEdit_CompanyListMember2()
{
SL_LIB16_install controller_pre = new SL_LIB16_install();
controller_pre.runChecker();
SL_View__c objView = new SL_View__c();
createData();
test.startTest();
SL_Mass_Implementation__c DefaultSettings = null;
for(SL_Mass_Implementation__c item:[Select targetObjectSearchFieldName__c, targetObjectParentFieldName__c, targetObjectName__c, searchObjectName__c, 
parentObjectName__c, Show_Views_on_MassEdit_Page__c, Show_Views_on_MassAdd_Page__c, Search_Page_Title__c, Search_Object_Title__c, Name, 
Id, Get_Element_from_List_Tab__c From SL_Mass_Implementation__c where Name='Company List' limit 1])
{
DefaultSettings = item;
}

SL_Mass_Implementation__c SL_ME1;
if(DefaultSettings == null)
{
SL_ME1 = new SL_Mass_Implementation__c();
SL_ME1.targetObjectParentFieldName__c = 'Company_List__c';
SL_ME1.targetObjectName__c = 'Company_List_Member__c';
SL_ME1.parentObjectName__c = 'Company_List__c';
SL_ME1.Name = 'CompanyList';
try{ insert SL_ME1;}
catch(Exception e){ }
}
else 
{
objView = [SELECT ID, RowsCount__c, Implementation__c from SL_View__c where Implementation_Type__c = 'ManageTargets'];
objView.RowsCount__c = 50;
// objView.Name = 'All Capital Markets Stages';
objView.Columns__c = 'View Record,Company,Status,Type,Tier,Declined / Passed,Initial Contact,Sent Teaser,Sent CA,Markup Sent,Markup Received,Executed CA,Received/Sent Book,Invited to Dataroom,Sent QoE NRL,Executed QoE NRL,Sent QoE,Sent Legal NRL,Executed Legal NRL,Sent Legal Report,Sent Other NRL,Executed Other NRL,Sent Other Report,Proposal / Indication,Met With Mgmt,Letter of Intent,Signed Term Sheet,Engagement Counterparty Comment';
objView.Advanced_Filter__c = '((1) OR 2) OR 3';

// objView.Implementation__c = DefaultSettings.Id;
//    objView.Implementation_Type__c = 'ManageTargets';
objView.IsDefault__c = False;
objView.Visibility__c = 'Public';
objView.User__c = UserInfo.getUserId();
upsert objView;

SL_View_Filter__c objViewFilter = new SL_View_Filter__c();
objViewFilter.Value__c = 'FIG - Sellside, Sellside';
objViewFilter.Type__c = 'REFERENCE';
objViewFilter.SL_View__c = objView.Id;
objViewFilter.Operator__c = 'includes';
objViewFilter.Field__c = 'Company__r.ID';
insert objViewFilter;

if(DefaultSettings!=null)
{
SL_ME1 = DefaultSettings;

}

}
SL_LIB16_MassEdit_CompanyListMember controller = new SL_LIB16_MassEdit_CompanyListMember();
PageReference pageRef = Page.SL_LIB16_MassEdit_CompanyListMember; 
Test.setCurrentPage(pageRef);

ApexPages.currentPage().getParameters().put('clId',companyLists.get(0).id);
ApexPages.currentPage().getParameters().put('target','Main');
ApexPages.currentPage().getParameters().put('implId',''+objView.Implementation__c);
ApexPages.currentPage().getParameters().put('mt','1');

controller.getviewFilters();


test.stopTest();
}
*/
}